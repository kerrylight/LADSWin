UNIT LADSEnvironUnit;

INTERFACE

  CONST
      CZAV_ENVIRONMENT_DATA_BOOLEAN_FIELDS  = 8;
      CZAW_ENVIRONMENT_DATA_INTEGER_FIELDS  = 5;
      CZAX_ENVIRONMENT_DATA_REAL_FIELDS	    = 14;
      CZAY_SIZE_OF_ENVIRONMENT_RECORD =
          2 * CZAV_ENVIRONMENT_DATA_BOOLEAN_FIELDS +
          2 * CZAW_ENVIRONMENT_DATA_INTEGER_FIELDS +
          8 * CZAX_ENVIRONMENT_DATA_REAL_FIELDS;

  TYPE
      ENVIRONMENT_DATA_REC                     = RECORD
	  ZIB_BOOLEAN_DATA		       : ARRAY
	    [1..CZAV_ENVIRONMENT_DATA_BOOLEAN_FIELDS] OF BOOLEAN;
	  ZID_INTEGER_DATA		       : ARRAY
	    [1..CZAW_ENVIRONMENT_DATA_INTEGER_FIELDS] OF INTEGER;
	  ZIE_REAL_DATA		       : ARRAY
	    [1..CZAX_ENVIRONMENT_DATA_REAL_FIELDS] OF DOUBLE
      END;

      ENVIRONMENT_ARCHIVE_REC                  = PACKED ARRAY
	  [1..CZAY_SIZE_OF_ENVIRONMENT_RECORD] OF CHAR;

  VAR
      AIN_TRANSLATE			       : BOOLEAN;
      AIQ_ADJUST_THICKNESS		       : BOOLEAN;
      AIP_PERFORM_SYSTEMIC_ROTATION	       : BOOLEAN;
      AdjustScale                              : BOOLEAN;
      ADW_CLEAR_ZERO			       : BOOLEAN;
      ADZ_CLEAR_INCORPORATE		       : BOOLEAN;
      AimPrincipalRays                         : BOOLEAN;

      ZHA_ENVIRONMENT			       : RECORD CASE INTEGER OF
	1: (ZHC_USE_EULER_AXIS		       : BOOLEAN;
	    ZHD_USE_LOCAL_COORDS	       : BOOLEAN;
	    ZHF_PIVOT_SURF_REFL		       : BOOLEAN;
	    ZHG_PIVOT_SURF_NULL		       : BOOLEAN;
	    ZHH_PIVOT_SURF_FULL		       : BOOLEAN;
	    ZHI_REVISIONS_ARE_TEMPORARY	       : BOOLEAN;
            SurfaceRangeActivated              : BOOLEAN;
            RayRangeActivated                  : BOOLEAN;
	    ZHY_REFERENCE_SURFACE	       : INTEGER;
	    ZHJ_FIRST_SURF_IN_BLOCK	       : INTEGER;
	    ZHK_LAST_SURF_IN_BLOCK	       : INTEGER;
            FirstRayInBlock                    : INTEGER;
            LastRayInBlock                     : INTEGER;
	    ZHL_PIVOT_POINT_X		       : DOUBLE;
	    ZHM_PIVOT_POINT_Y		       : DOUBLE;
	    ZHN_PIVOT_POINT_Z		       : DOUBLE;
	    ZHO_DX_VALUE		       : DOUBLE;
	    ZHP_DY_VALUE		       : DOUBLE;
	    ZHQ_DZ_VALUE		       : DOUBLE;
            ScaleFactor                        : DOUBLE;
	    ZHR_ROLL			       : DOUBLE;
	    ZHS_PITCH			       : DOUBLE;
	    ZHT_YAW			       : DOUBLE;
	    ZHU_EULER_AXIS_X_MAG	       : DOUBLE;
	    ZHV_EULER_AXIS_Y_MAG	       : DOUBLE;
	    ZHW_EULER_AXIS_Z_MAG	       : DOUBLE;
	    ZHX_EULER_AXIS_ROT		       : DOUBLE);
	2: (ZIA_ALL_ENVIRONMENT_DATA	       : ENVIRONMENT_DATA_REC);
	3: (ZIF_ENVIRONMENT_ARCHIVE_DATA       : ENVIRONMENT_ARCHIVE_REC)
      END;

      ENVIRONMENT_DATA_INITIALIZER             : ENVIRONMENT_DATA_REC;

PROCEDURE H01_SET_UP_ENVIRONMENT;

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSCommandIOMemoUnit,
       LADSData,
       LADSq4Unit,
       LADSUtilUnit,
       LADSTraceUnit,
       LADSRandomUnit;


(**  H01_SET_UP_ENVIRONMENT  **************************************************
******************************************************************************)


PROCEDURE H01_SET_UP_ENVIRONMENT;




(**  H06_TRANSLATE_SURFACES  **************************************************
******************************************************************************)


PROCEDURE H06_TRANSLATE_SURFACES;

  VAR
      I		   : INTEGER;

      DX	   : DOUBLE;
      DY	   : DOUBLE;
      DZ	   : DOUBLE;
      COS_R	   : DOUBLE;
      SIN_R	   : DOUBLE;
      COS_P	   : DOUBLE;
      SIN_P	   : DOUBLE;
      COS_Y	   : DOUBLE;
      SIN_Y	   : DOUBLE;
      T11	   : DOUBLE;
      T12	   : DOUBLE;
      T13	   : DOUBLE;
      T21	   : DOUBLE;
      T22	   : DOUBLE;
      T23	   : DOUBLE;
      T31	   : DOUBLE;
      T32	   : DOUBLE;
      T33	   : DOUBLE;
      OLD_DX	   : DOUBLE;
      OLD_DY	   : DOUBLE;
      OLD_DZ	   : DOUBLE;

BEGIN

  (* For surfaces flagged as "specified" within the specifed range of
  surfaces, add the values stored in the delta x, y, and z fields to the
  respective values stored in the x, y, and z position fields; then
  zero-out the values stored in the delta x, y, and z fields.
  *)

  FOR I := ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK TO
      ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK DO
    IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
      BEGIN
	ZBA_SURFACE [I].ZBM_VERTEX_X := ZBA_SURFACE [I].ZBM_VERTEX_X +
	    ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X;
	ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X := 0;
	ZBA_SURFACE [I].ZBO_VERTEX_Y := ZBA_SURFACE [I].ZBO_VERTEX_Y +
	    ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y;
	ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y := 0;
	ZBA_SURFACE [I].ZBQ_VERTEX_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z +
	    ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z;
	ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z := 0
      END;

  IF ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].ZBB_SPECIFIED THEN
    BEGIN
      (* Compute elements of the rotation matrix per the current yaw, pitch,
         and roll values. *)
      COS_R := COS (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      SIN_R := SIN (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      COS_P := COS (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      SIN_P := SIN (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      COS_Y := COS (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      SIN_Y := SIN (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      T11 := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
      T12 := SIN_R * COS_P;
      T13 := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
      T21 := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
      T22 := COS_R * COS_P;
      T23 := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
      T31 := COS_P * SIN_Y;
      T32 := SIN_P;
      T33 := COS_P * COS_Y;
      (* Rotate the user-specified displacements into the current rotated
         coordinate system. *)
      OLD_DX := ZHA_ENVIRONMENT.ZHO_DX_VALUE;
      OLD_DY := ZHA_ENVIRONMENT.ZHP_DY_VALUE;
      OLD_DZ := ZHA_ENVIRONMENT.ZHQ_DZ_VALUE;
      DX := T11 * OLD_DX + T21 * OLD_DY + T31 * OLD_DZ;
      DY := T12 * OLD_DX + T22 * OLD_DY + T32 * OLD_DZ;
      DZ := T13 * OLD_DX + T23 * OLD_DY + T33 * OLD_DZ;
      IF AIQ_ADJUST_THICKNESS THEN
	BEGIN
	  DX := DX + ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X -
	      ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBM_VERTEX_X;
	  DY := DY + ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y -
	      ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBO_VERTEX_Y;
	  DZ := DZ + ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z -
	      ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBQ_VERTEX_Z
	END;
      FOR I := ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK TO
	  ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK DO
	IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
	  IF ZHA_ENVIRONMENT.ZHI_REVISIONS_ARE_TEMPORARY THEN
	    BEGIN
	      ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X := DX;
	      ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y := DY;
	      ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z := DZ
	    END
	  ELSE
	    BEGIN
	      ZBA_SURFACE [I].ZBM_VERTEX_X := ZBA_SURFACE [I].ZBM_VERTEX_X +
		  DX;
	      ZBA_SURFACE [I].ZBO_VERTEX_Y := ZBA_SURFACE [I].ZBO_VERTEX_Y +
		  DY;
	      ZBA_SURFACE [I].ZBQ_VERTEX_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z +
		  DZ
	    END
    END
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR:  Surface # ' +
	  IntToStr (ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK) +
	  ' in specified block has not been defined.')
    END

END;




(**  H07_TRANSLATE_RAYS  ******************************************************
******************************************************************************)

PROCEDURE H07_TRANSLATE_RAYS;

  VAR
      I		   : INTEGER;

      DX	   : DOUBLE;
      DY	   : DOUBLE;
      DZ	   : DOUBLE;
      COS_R	   : DOUBLE;
      SIN_R	   : DOUBLE;
      COS_P	   : DOUBLE;
      SIN_P	   : DOUBLE;
      COS_Y	   : DOUBLE;
      SIN_Y	   : DOUBLE;
      T11	   : DOUBLE;
      T12	   : DOUBLE;
      T13	   : DOUBLE;
      T21	   : DOUBLE;
      T22	   : DOUBLE;
      T23	   : DOUBLE;
      T31	   : DOUBLE;
      T32	   : DOUBLE;
      T33	   : DOUBLE;
      OLD_DX	   : DOUBLE;
      OLD_DY	   : DOUBLE;
      OLD_DZ	   : DOUBLE;

BEGIN

  IF ZNA_RAY [ZHA_ENVIRONMENT.FirstRayInBlock].ZNB_SPECIFIED THEN
    BEGIN
      (* Compute elements of the rotation matrix per the current yaw, pitch,
         and roll values. *)
      COS_R := COS (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      SIN_R := SIN (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      COS_P := COS (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      SIN_P := SIN (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      COS_Y := COS (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      SIN_Y := SIN (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      T11 := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
      T12 := SIN_R * COS_P;
      T13 := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
      T21 := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
      T22 := COS_R * COS_P;
      T23 := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
      T31 := COS_P * SIN_Y;
      T32 := SIN_P;
      T33 := COS_P * COS_Y;
      (* Rotate the user-specified displacements into the current rotated
         coordinate system. *)
      OLD_DX := ZHA_ENVIRONMENT.ZHO_DX_VALUE;
      OLD_DY := ZHA_ENVIRONMENT.ZHP_DY_VALUE;
      OLD_DZ := ZHA_ENVIRONMENT.ZHQ_DZ_VALUE;
      DX := T11 * OLD_DX + T21 * OLD_DY + T31 * OLD_DZ;
      DY := T12 * OLD_DX + T22 * OLD_DY + T32 * OLD_DZ;
      DZ := T13 * OLD_DX + T23 * OLD_DY + T33 * OLD_DZ;
      IF AIQ_ADJUST_THICKNESS THEN
	BEGIN
	  DX := DX + ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X -
	      ZNA_RAY [ZHA_ENVIRONMENT.FirstRayInBlock].
	      ZNG_HEAD_X_COORDINATE;
	  DY := DY + ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y -
	      ZNA_RAY [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZNH_HEAD_Y_COORDINATE;
	  DZ := DZ + ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z -
	      ZNA_RAY [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZNI_HEAD_Z_COORDINATE
	END;
      FOR I := ZHA_ENVIRONMENT.FirstRayInBlock TO
	  ZHA_ENVIRONMENT.LastRayInBlock DO
	IF ZNA_RAY [I].ZNB_SPECIFIED THEN
	  BEGIN
	    ZNA_RAY [I].ZND_TAIL_X_COORDINATE :=
                ZNA_RAY [I].ZND_TAIL_X_COORDINATE + DX;
	    ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE :=
                ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE + DY;
	    ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE :=
                ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE + DZ;
	    ZNA_RAY [I].ZNG_HEAD_X_COORDINATE :=
                ZNA_RAY [I].ZNG_HEAD_X_COORDINATE + DX;
	    ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE :=
                ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE + DY;
	    ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE :=
                ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE + DZ
	  END
    END
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR:  Ray # ' +
	  IntToStr (ZHA_ENVIRONMENT.FirstRayInBlock) +
	  ' in specified block has not been defined.')
    END

END;




(**  H10_PERFORM_SYSTEMIC_SURF_ROT  *******************************************
******************************************************************************)


PROCEDURE H10_PERFORM_SYSTEMIC_SURF_ROT;

  CONST
      COS_45_DEGREES = 0.7071067811865476;
      SIN_45_DEGREES = 0.7071067811865476;

  VAR
      SOLUTION_FOUND			      : BOOLEAN;

      I					      : INTEGER;

      PIVOT_TO_1ST_SURF_DISTANCE	      : DOUBLE;
      ROLL				      : DOUBLE;
      PITCH				      : DOUBLE;
      YAW				      : DOUBLE;
      OLD_ROLL				      : DOUBLE;
      OLD_PITCH				      : DOUBLE;
      OLD_YAW				      : DOUBLE;
      COS_R				      : DOUBLE;
      SIN_R				      : DOUBLE;
      COS_P				      : DOUBLE;
      SIN_P				      : DOUBLE;
      COS_Y				      : DOUBLE;
      SIN_Y				      : DOUBLE;
      T11				      : DOUBLE;
      T12				      : DOUBLE;
      T13				      : DOUBLE;
      T21				      : DOUBLE;
      T22				      : DOUBLE;
      T23				      : DOUBLE;
      T31				      : DOUBLE;
      T32				      : DOUBLE;
      T33				      : DOUBLE;
      T11_PIVOT				      : DOUBLE;
      T12_PIVOT				      : DOUBLE;
      T13_PIVOT				      : DOUBLE;
      T21_PIVOT				      : DOUBLE;
      T22_PIVOT				      : DOUBLE;
      T23_PIVOT				      : DOUBLE;
      T31_PIVOT				      : DOUBLE;
      T32_PIVOT				      : DOUBLE;
      T33_PIVOT				      : DOUBLE;
      T11_DEST				      : DOUBLE;
      T12_DEST				      : DOUBLE;
      T13_DEST				      : DOUBLE;
      T21_DEST				      : DOUBLE;
      T22_DEST				      : DOUBLE;
      T23_DEST				      : DOUBLE;
      T31_DEST				      : DOUBLE;
      T32_DEST				      : DOUBLE;
      T33_DEST				      : DOUBLE;
      OLD_X				      : DOUBLE;
      OLD_Y				      : DOUBLE;
      OLD_Z				      : DOUBLE;
      EX				      : DOUBLE;
      EY				      : DOUBLE;
      EZ				      : DOUBLE;
      EX_HOLD				      : DOUBLE;
      EY_HOLD				      : DOUBLE;
      EZ_HOLD				      : DOUBLE;
      ABS_MAG_E				      : DOUBLE;
      COS_A				      : DOUBLE;
      SIN_A				      : DOUBLE;
      TAN_A				      : DOUBLE;
      HOLD_COS_A			      : DOUBLE;
      HOLD_SIN_A			      : DOUBLE;
      ANGLE				      : DOUBLE;
      E_DOT_R				      : DOUBLE;
      E_CROSS_R_X			      : DOUBLE;
      E_CROSS_R_Y			      : DOUBLE;
      E_CROSS_R_Z			      : DOUBLE;
      E_DOT_I				      : DOUBLE;
      E_CROSS_I_X			      : DOUBLE;
      E_CROSS_I_Y			      : DOUBLE;
      E_CROSS_I_Z			      : DOUBLE;
      E_DOT_J				      : DOUBLE;
      E_CROSS_J_X			      : DOUBLE;
      E_CROSS_J_Y			      : DOUBLE;
      E_CROSS_J_Z			      : DOUBLE;
      E_DOT_K				      : DOUBLE;
      E_CROSS_K_X			      : DOUBLE;
      E_CROSS_K_Y			      : DOUBLE;
      E_CROSS_K_Z			      : DOUBLE;
      

(**  H1005_ROTATE_POSITION  ***************************************************
******************************************************************************)


PROCEDURE H1005_ROTATE_POSITION;

BEGIN

  (*  TREAT POSITION OF SURFACE I AS IF AT THE "HEAD" OF A
      RADIUS VECTOR, WITH THE "TAIL" OF THE RADIUS VECTOR
      LOCATED AT THE PIVOT POINT.  WE MAY THEN ROTATE THIS
      RADIUS VECTOR ABOUT THE EULER AXIS TO OBTAIN THE NEW
      POSITION OF SURFACE I WITH RESPECT TO THE PIVOT
      POINT.  *)

  OLD_X := ZBA_SURFACE [I].ZBM_VERTEX_X - ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X;
  OLD_Y := ZBA_SURFACE [I].ZBO_VERTEX_Y - ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y;
  OLD_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z - ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z;

  E_DOT_R := EX * OLD_X + EY * OLD_Y + EZ * OLD_Z;
  E_CROSS_R_X := EY * OLD_Z - EZ * OLD_Y;
  E_CROSS_R_Y := EZ * OLD_X - EX * OLD_Z;
  E_CROSS_R_Z := EX * OLD_Y - EY * OLD_X;

  IF ZHA_ENVIRONMENT.ZHI_REVISIONS_ARE_TEMPORARY THEN
    BEGIN
      ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X :=
	  SIN_A * E_CROSS_R_X + (1 - COS_A) * E_DOT_R * EX + COS_A * OLD_X +
	  ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X - ZBA_SURFACE [I].ZBM_VERTEX_X;
      ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y :=
	  SIN_A * E_CROSS_R_Y + (1 - COS_A) * E_DOT_R * EY + COS_A * OLD_Y +
	  ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y - ZBA_SURFACE [I].ZBO_VERTEX_Y;
      ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z :=
	  SIN_A * E_CROSS_R_Z + (1 - COS_A) * E_DOT_R * EZ + COS_A * OLD_Z +
	  ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z - ZBA_SURFACE [I].ZBQ_VERTEX_Z
    END
  ELSE
    BEGIN
      ZBA_SURFACE [I].ZBM_VERTEX_X :=
	  SIN_A * E_CROSS_R_X + (1 - COS_A) * E_DOT_R * EX + COS_A * OLD_X +
	  ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X;
      ZBA_SURFACE [I].ZBO_VERTEX_Y :=
	  SIN_A * E_CROSS_R_Y + (1 - COS_A) * E_DOT_R * EY + COS_A * OLD_Y +
	  ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y;
      ZBA_SURFACE [I].ZBQ_VERTEX_Z :=
	  SIN_A * E_CROSS_R_Z + (1 - COS_A) * E_DOT_R * EZ + COS_A * OLD_Z +
	  ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z
    END

END;




(**  H1010_ROTATE_ORIENTATION  ************************************************
******************************************************************************)


PROCEDURE H1010_ROTATE_ORIENTATION;


(**  H101005_GET_ROLL_PITCH_YAW	 **********************************************
******************************************************************************)


PROCEDURE H101005_GET_ROLL_PITCH_YAW;

  VAR
      J				  : INTEGER;
      K				  : INTEGER;
      L				  : INTEGER;
      NR			  : INTEGER;
      NP			  : INTEGER;
      NY			  : INTEGER;

      X				  : DOUBLE;
      T11_HOLD			  : DOUBLE;
      T12_HOLD			  : DOUBLE;
      T13_HOLD			  : DOUBLE;
      T21_HOLD			  : DOUBLE;
      T22_HOLD			  : DOUBLE;
      T23_HOLD			  : DOUBLE;
      T31_HOLD			  : DOUBLE;
      T32_HOLD			  : DOUBLE;
      T33_HOLD			  : DOUBLE;
      SIN_R			  : DOUBLE;
      COS_R			  : DOUBLE;
      SIN_P			  : DOUBLE;
      COS_P			  : DOUBLE;
      SIN_Y			  : DOUBLE;
      COS_Y			  : DOUBLE;
      R				  : ARRAY [1..2] OF DOUBLE;
      P				  : ARRAY [1..2] OF DOUBLE;
      Y				  : ARRAY [1..2] OF DOUBLE;

BEGIN

  IF ABS (T11) < 1E-14 THEN
    T11 := 0
  ELSE
    BEGIN
      IF T11 > 0 THEN
	BEGIN
	  X := 1 - T11;
	  IF X < 1E-14 THEN
	    T11 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T11;
	  IF X > -1E-14 THEN
	    T11 := -1
	END
    END;

  IF ABS (T12) < 1E-14 THEN
    T12 := 0
  ELSE
    BEGIN
      IF T12 > 0 THEN
	BEGIN
	  X := 1 - T12;
	  IF X < 1E-14 THEN
	    T12 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T12;
	  IF X > -1E-14 THEN
	    T12 := -1
	END
    END;

  IF ABS (T13) < 1E-14 THEN
    T13 := 0
  ELSE
    BEGIN
      IF T13 > 0 THEN
	BEGIN
	  X := 1 - T13;
	  IF X < 1E-14 THEN
	    T13 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T13;
	  IF X > -1E-14 THEN
	    T13 := -1
	END
    END;

  IF ABS (T21) < 1E-14 THEN
    T21 := 0
  ELSE
    BEGIN
      IF T21 > 0 THEN
	BEGIN
	  X := 1 - T21;
	  IF X < 1E-14 THEN
	    T21 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T21;
	  IF X > -1E-14 THEN
	    T21 := -1
	END
    END;

  IF ABS (T22) < 1E-14 THEN
    T22 := 0
  ELSE
    BEGIN
      IF T22 > 0 THEN
	BEGIN
	  X := 1 - T22;
	  IF X < 1E-14 THEN
	    T22 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T22;
	  IF X > -1E-14 THEN
	    T22 := -1
	END
    END;

  IF ABS (T23) < 1E-14 THEN
    T23 := 0
  ELSE
    BEGIN
      IF T23 > 0 THEN
	BEGIN
	  X := 1 - T23;
	  IF X < 1E-14 THEN
	    T23 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T23;
	  IF X > -1E-14 THEN
	    T23 := -1
	END
    END;

  IF ABS (T31) < 1E-14 THEN
    T31 := 0
  ELSE
    BEGIN
      IF T31 > 0 THEN
	BEGIN
	  X := 1 - T31;
	  IF X < 1E-14 THEN
	    T31 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T31;
	  IF X > -1E-14 THEN
	    T31 := -1
	END
    END;

  IF ABS (T32) < 1E-14 THEN
    T32 := 0
  ELSE
    BEGIN
      IF T32 > 0 THEN
	BEGIN
	  X := 1 - T32;
	  IF X < 1E-14 THEN
	    T32 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T32;
	  IF X > -1E-14 THEN
	    T32 := -1
	END
    END;

  IF ABS (T33) < 1E-14 THEN
    T33 := 0
  ELSE
    BEGIN
      IF T33 > 0 THEN
	BEGIN
	  X := 1 - T33;
	  IF X < 1E-14 THEN
	    T33 := 1
	END
      ELSE
	BEGIN
	  X := -1 - T33;
	  IF X > -1E-14 THEN
	    T33 := -1
	END
    END;

  IF T32 = 0 THEN
    BEGIN
      P [1] := 0;
      P [2] := PI;
      NP := 2
    END
  ELSE
  IF (T32 > 0)
      AND (T32 < 1) THEN
    BEGIN
      P [1] := ARCTAN (T32 /
	  (SQRT (1.0 - T32 * T32)));
      P [2] := PI - P [1];
      IF P [2] > PI THEN
	P [2] := P [2] - (2.0 * PI);
      NP := 2
    END
  ELSE
  IF T32 = 1 THEN
    BEGIN
      P [1] := PI / 2;
      NP := 1
    END
  ELSE
  IF (T32 < 0)
      AND (T32 > -1) THEN
    BEGIN
      P [1] := ARCTAN (T32 /
	  (SQRT (1.0 - T32 * T32)));
      P [2] := -PI - P [1];
      IF P [2] < -PI THEN
	P [2] := P [2] + (2.0 * PI);
      NP := 2
    END
  ELSE
  IF T32 = -1 THEN
    BEGIN
      P [1] := -PI / 2;
      NP := 1
    END;

  IF (((T12 = 0)
      AND (T22 = 0))
      OR ((T31 = 0)
      AND (T33 = 0))) THEN
    BEGIN
      R [1] := 0;
      NR := 1;
      IF T23 = 0 THEN
	BEGIN
	  Y [1] := PI / 2;
	  Y [2] := -PI / 2;
	  NY := 2
	END
      ELSE
	BEGIN
	  Y [1] := ARCTAN (T21 / T23);
	  NY := 1
	END
    END
  ELSE
    BEGIN
      IF T22 = 0 THEN
	BEGIN
	  R [1] := PI / 2;
	  R [2] := -PI / 2;
	  NR := 2
	END
      ELSE
      IF T12 = 0 THEN
	BEGIN
	  R [1] := 0;
	  R [2] := PI;
	  NR := 2
	END
      ELSE
	BEGIN
	  R [1] := ARCTAN (T12 / T22);
	  R [2] := -PI + R [1];
	  IF R [2] < -PI THEN
	    R [2] := R [2] + (2.0 * PI);
	  NR := 2
	END;
      IF T33 = 0 THEN
	BEGIN
	  Y [1] := PI / 2;
	  Y [2] := -PI / 2;
	  NY := 2
	END
      ELSE
      IF T31 = 0 THEN
	BEGIN
	  Y [1] := 0;
	  Y [2] := PI;
	  NY := 2
	END
      ELSE
	BEGIN
	  Y [1] := ARCTAN (T31 / T33);
	  NY := 1
	END
    END;

(*WRITELN;
  WRITELN ('T11 = ', T11);
  WRITELN ('T12 = ', T12);
  WRITELN ('T13 = ', T13);
  WRITELN ('T21 = ', T21);
  WRITELN ('T22 = ', T22);
  WRITELN ('T23 = ', T23);
  WRITELN ('T31 = ', T31);
  WRITELN ('T32 = ', T32);
  WRITELN ('T33 = ', T33);
  WRITELN;
  FOR J := 1 TO NR DO
    BEGIN
      X := R [J] * (180 / PI);
      WRITELN ('ROLL = ', X)
    END;
  FOR J := 1 TO NP DO
    BEGIN
      X := P [J] * (180 / PI);
      WRITELN ('PITCH = ', X)
    END;
  FOR J := 1 TO NY DO
    BEGIN
      X := Y [J] * (180 / PI);
      WRITELN ('YAW = ', X)
    END;
  Q980_REQUEST_MORE_OUTPUT;*)

  SOLUTION_FOUND := FALSE;

  FOR J := 1 TO NR DO
    FOR K := 1 TO NP DO
      FOR L := 1 TO NY DO
	BEGIN
	  SIN_R := SIN (R [J]);
	  COS_R := COS (R [J]);
	  SIN_P := SIN (P [K]);
	  COS_P := COS (P [K]);
	  SIN_Y := SIN (Y [L]);
	  COS_Y := COS (Y [L]);
	  T11_HOLD := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
	  T12_HOLD := SIN_R * COS_P;
	  T13_HOLD := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
	  T21_HOLD := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
	  T22_HOLD := COS_R * COS_P;
	  T23_HOLD := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
	  T31_HOLD := COS_P * SIN_Y;
	  T32_HOLD := SIN_P;
	  T33_HOLD := COS_P * COS_Y;
	  IF (ABS (T11_HOLD - T11) < 1E-9)
	      AND (ABS (T12_HOLD - T12) < 1E-9)
	      AND (ABS (T13_HOLD - T13) < 1E-9)
	      AND (ABS (T21_HOLD - T21) < 1E-9)
	      AND (ABS (T22_HOLD - T22) < 1E-9)
	      AND (ABS (T23_HOLD - T23) < 1E-9)
	      AND (ABS (T31_HOLD - T31) < 1E-9)
	      AND (ABS (T32_HOLD - T32) < 1E-9)
	      AND (ABS (T33_HOLD - T33) < 1E-9) THEN
	    IF SOLUTION_FOUND THEN
	      BEGIN
	      END
	    ELSE
	      BEGIN
		ROLL := R [J] * (180 / PI);
		PITCH := P [K] * (180 / PI);
		YAW := Y [L] * (180 / PI);
		SOLUTION_FOUND := TRUE
	      END
	END

END;




(**  H1010_ROTATE_ORIENTATION  ***********************************************
*****************************************************************************)


BEGIN

  (*  DEFINE DIRECTION COSINES FOR INITIAL ORIENTATION OF
      DESTINATION SURFACE IN REFERENCE COORDINATE SYSTEM.  *)

  ROLL := ZBA_SURFACE [I].ZBS_ROLL;
  PITCH := ZBA_SURFACE [I].ZBU_PITCH;
  YAW := ZBA_SURFACE [I].ZBW_YAW;

  COS_R := COS (ROLL / ALR_DEGREES_PER_RADIAN);
  SIN_R := SIN (ROLL / ALR_DEGREES_PER_RADIAN);
  COS_P := COS (PITCH / ALR_DEGREES_PER_RADIAN);
  SIN_P := SIN (PITCH / ALR_DEGREES_PER_RADIAN);
  COS_Y := COS (YAW / ALR_DEGREES_PER_RADIAN);
  SIN_Y := SIN (YAW / ALR_DEGREES_PER_RADIAN);

  T11_DEST := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
  T12_DEST := SIN_R * COS_P;
  T13_DEST := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
  T21_DEST := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
  T22_DEST := COS_R * COS_P;
  T23_DEST := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
  T31_DEST := COS_P * SIN_Y;
  T32_DEST := SIN_P;
  T33_DEST := COS_P * COS_Y;
  
  (*  ROTATE DESTINATION SURFACE ABOUT EULER AXIS.  *)

  E_DOT_I := EX * T11_DEST + EY * T12_DEST + EZ * T13_DEST;
  E_CROSS_I_X := EY * T13_DEST - EZ * T12_DEST;
  E_CROSS_I_Y := EZ * T11_DEST - EX * T13_DEST;
  E_CROSS_I_Z := EX * T12_DEST - EY * T11_DEST;
  
  E_DOT_J := EX * T21_DEST + EY * T22_DEST + EZ * T23_DEST;
  E_CROSS_J_X := EY * T23_DEST - EZ * T22_DEST;
  E_CROSS_J_Y := EZ * T21_DEST - EX * T23_DEST;
  E_CROSS_J_Z := EX * T22_DEST - EY * T21_DEST;

  E_DOT_K := EX * T31_DEST + EY * T32_DEST + EZ * T33_DEST;
  E_CROSS_K_X := EY * T33_DEST - EZ * T32_DEST;
  E_CROSS_K_Y := EZ * T31_DEST - EX * T33_DEST;
  E_CROSS_K_Z := EX * T32_DEST - EY * T31_DEST;
  
  T11 := SIN_A * E_CROSS_I_X + (1 - COS_A) * E_DOT_I * EX +
      COS_A * T11_DEST;
  T12 := SIN_A * E_CROSS_I_Y + (1 - COS_A) * E_DOT_I * EY +
      COS_A * T12_DEST;
  T13 := SIN_A * E_CROSS_I_Z + (1 - COS_A) * E_DOT_I * EZ +
      COS_A * T13_DEST;
      
  T21 := SIN_A * E_CROSS_J_X + (1 - COS_A) * E_DOT_J * EX +
      COS_A * T21_DEST;
  T22 := SIN_A * E_CROSS_J_Y + (1 - COS_A) * E_DOT_J * EY +
      COS_A * T22_DEST;
  T23 := SIN_A * E_CROSS_J_Z + (1 - COS_A) * E_DOT_J * EZ +
      COS_A * T23_DEST;

  T31 := SIN_A * E_CROSS_K_X + (1 - COS_A) * E_DOT_K * EX +
      COS_A * T31_DEST;
  T32 := SIN_A * E_CROSS_K_Y + (1 - COS_A) * E_DOT_K * EY +
      COS_A * T32_DEST;
  T33 := SIN_A * E_CROSS_K_Z + (1 - COS_A) * E_DOT_K * EZ +
      COS_A * T33_DEST;
      
  (*  GET NEW ORIENTATION OF DESTINATION SURFACE IN
      REFERENCE COORDINATE SYSTEM.  *)

  H101005_GET_ROLL_PITCH_YAW;
  
  IF SOLUTION_FOUND THEN
    IF ZHA_ENVIRONMENT.ZHI_REVISIONS_ARE_TEMPORARY THEN
      BEGIN
	ZBA_SURFACE [I].ZBT_DELTA_ROLL := ROLL -  ZBA_SURFACE [I].ZBS_ROLL;
	ZBA_SURFACE [I].ZBV_DELTA_PITCH := PITCH - ZBA_SURFACE [I].ZBU_PITCH;
	ZBA_SURFACE [I].ZBX_DELTA_YAW := YAW - ZBA_SURFACE [I].ZBW_YAW
      END
    ELSE
      BEGIN
	ZBA_SURFACE [I].ZBS_ROLL := ROLL;
	ZBA_SURFACE [I].ZBU_PITCH := PITCH;
	ZBA_SURFACE [I].ZBW_YAW := YAW
      END
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('COULD NOT DETERMINE SURFACE ' +
          IntToStr (I) + ' ORIENTATION.')
    END

END;




(**  H10_PERFORM_SYSTEMIC_ROTATION  *******************************************
******************************************************************************)


BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('INCORPORATING TEMPORARY POSITION AND ORIENTATION DATA FOR');
  CommandIOMemo.IOHistory.Lines.add ('SURFACES ' +
      IntToStr (ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK) + ' THRU ' +
      IntToStr (ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK) + '...');

  FOR I := ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK TO
      ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK DO
    BEGIN
      ZBA_SURFACE [I].ZBM_VERTEX_X := ZBA_SURFACE [I].ZBM_VERTEX_X +
	  ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X;
      ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X := 0;
      ZBA_SURFACE [I].ZBO_VERTEX_Y := ZBA_SURFACE [I].ZBO_VERTEX_Y +
	  ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y;
      ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y := 0;
      ZBA_SURFACE [I].ZBQ_VERTEX_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z +
	  ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z;
      ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z := 0;
      ZBA_SURFACE [I].ZBS_ROLL := ZBA_SURFACE [I].ZBS_ROLL +
	  ZBA_SURFACE [I].ZBT_DELTA_ROLL;
      ZBA_SURFACE [I].ZBT_DELTA_ROLL := 0;
      ZBA_SURFACE [I].ZBU_PITCH := ZBA_SURFACE [I].ZBU_PITCH +
	  ZBA_SURFACE [I].ZBV_DELTA_PITCH;
      ZBA_SURFACE [I].ZBV_DELTA_PITCH := 0;
      ZBA_SURFACE [I].ZBW_YAW := ZBA_SURFACE [I].ZBW_YAW +
	  ZBA_SURFACE [I].ZBX_DELTA_YAW;
      ZBA_SURFACE [I].ZBX_DELTA_YAW := 0
    END;

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add ('PROCESSING SYSTEMIC SURFACE ROTATION...');

  (*  GET ELEMENTS OF THE SYSTEMIC ROTATION QUATERNION.	 THESE ELEMENTS
      CONSIST OF THE COMPONENTS (DIRECTION COSINES) OF A UNIT VECTOR IN THE
      DIRECTION OF THE EULER AXIS, AND A ROTATION ABOUT THE EULER AXIS.	 *)

  IF ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS THEN
    BEGIN
    (*	PRIMARY USER INPUT WAS IN THE FORM OF THE ELEMENTS OF THE SYSTEMIC
	ROTATION QUATERNION.  MAKE SURE EULER AXIS, AS ENTERED BY USER, IS
	A UNIT VECTOR.	*)
      EX := ZHA_ENVIRONMENT.ZHU_EULER_AXIS_X_MAG;
      EY := ZHA_ENVIRONMENT.ZHV_EULER_AXIS_Y_MAG;
      EZ := ZHA_ENVIRONMENT.ZHW_EULER_AXIS_Z_MAG;
      ABS_MAG_E := SQRT (EX * EX + EY * EY + EZ * EZ);
      EX := EX / ABS_MAG_E;
      EY := EY / ABS_MAG_E;
      EZ := EZ / ABS_MAG_E;
      COS_A := COS (ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT /
	  ALR_DEGREES_PER_RADIAN);
      SIN_A := SIN (ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT /
	  ALR_DEGREES_PER_RADIAN)
    END
  ELSE
    BEGIN
    (*	PRIMARY INPUT DATA WAS ENTERED IN THE FORM OF YAW, PITCH,
	AND ROLL.  THEREFORE, WE MUST FIRST COMPUTE THE DIRECTION COSINE
	MATRIX, FROM WHICH WE CAN THEN EXTRACT THE QUATERNION CONSISTING
	OF THE EULER AXIS UNIT VECTOR AND THE AMOUNT OF THE DESIRED
	ROTATION.  *)
      COS_R := COS (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      SIN_R := SIN (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      COS_P := COS (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      SIN_P := SIN (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      COS_Y := COS (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      SIN_Y := SIN (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      T11 := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
      T12 := SIN_R * COS_P;
      T13 := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
      T21 := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
      T22 := COS_R * COS_P;
      T23 := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
      T31 := COS_P * SIN_Y;
      T32 := SIN_P;
      T33 := COS_P * COS_Y;
      EX := T23 - T32;
      EY := T31 - T13;
      EZ := T12 - T21;
      COS_A := 0.5 * (T11 + T22 + T33 - 1);
      SIN_A := SQRT (1 - COS_A * COS_A);
      ABS_MAG_E := SQRT (EX * EX + EY * EY + EZ * EZ);
      EX := EX / ABS_MAG_E;
      EY := EY / ABS_MAG_E;
      EZ := EZ / ABS_MAG_E
    END;

  IF ZHA_ENVIRONMENT.ZHD_USE_LOCAL_COORDS THEN
    BEGIN
    (*	THE USER HAS DEFINED HIS DESIRED ROTATION WITH RESPECT TO THE LOCAL
	ORIENTATION OF THE PIVOT SURFACE.  THEREFORE, WE MUST COMPUTE THE
	ROTATION MATRIX FOR THIS SURFACE, AND THEN DE-ROTATE THE EULER AXIS
	BACK INTO THE MASTER REFERENCE COORDINATE SYSTEM, BEFORE PROCEEDING
	WITH THE SYSTEMIC ROTATION.  *)
      ROLL := ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].ZBS_ROLL;
      PITCH := ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].ZBU_PITCH;
      YAW := ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].ZBW_YAW;
      COS_R := COS (ROLL / ALR_DEGREES_PER_RADIAN);
      SIN_R := SIN (ROLL / ALR_DEGREES_PER_RADIAN);
      COS_P := COS (PITCH / ALR_DEGREES_PER_RADIAN);
      SIN_P := SIN (PITCH / ALR_DEGREES_PER_RADIAN);
      COS_Y := COS (YAW / ALR_DEGREES_PER_RADIAN);
      SIN_Y := SIN (YAW / ALR_DEGREES_PER_RADIAN);
      T11_PIVOT := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
      T12_PIVOT := SIN_R * COS_P;
      T13_PIVOT := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
      T21_PIVOT := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
      T22_PIVOT := COS_R * COS_P;
      T23_PIVOT := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
      T31_PIVOT := COS_P * SIN_Y;
      T32_PIVOT := SIN_P;
      T33_PIVOT := COS_P * COS_Y;
    (*	NOW WE CAN DE-ROTATE THE EULER AXIS BACK INTO THE MASTER REFERENCE
	COORDINATE SYSTEM.  *)
      EX_HOLD := EX;
      EY_HOLD := EY;
      EZ_HOLD := EZ;
      EX := (T11_PIVOT * EX_HOLD) + (T21_PIVOT * EY_HOLD) +
	  (T31_PIVOT * EZ_HOLD);
      EY := (T12_PIVOT * EX_HOLD) + (T22_PIVOT * EY_HOLD) +
	  (T32_PIVOT * EZ_HOLD);
      EZ := (T13_PIVOT * EX_HOLD) + (T23_PIVOT * EY_HOLD) +
	  (T33_PIVOT * EZ_HOLD)
    END;

  (*  THE MASTER SYSTEMIC ROTATION QUATERNION IS NOW AVAILABLE, AND IS DEFINED
      IN TERMS OF THE MASTER REFERENCE COORDINATE SYSTEM.  WE ARE NOW IN A
      POSITION TO ROTATE THE POSITION AND ORIENTATION OF ALL DESIGNATED
      SURFACES, ABOUT THE EULER AXIS.  *)

  FOR I := ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK TO
      ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK DO
    IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
      IF (I = ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK) THEN
	BEGIN
	  (* Determine if the vertex of the first surface in the block
	     is the pivot point. *)
	  PIVOT_TO_1ST_SURF_DISTANCE :=
	      SQRT (SQR (ZBA_SURFACE [I].ZBM_VERTEX_X -
	      ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X) +
	      SQR (ZBA_SURFACE [I].ZBO_VERTEX_Y -
	      ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y) +
	      SQR (ZBA_SURFACE [I].ZBQ_VERTEX_Z -
	      ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z));
	  IF PIVOT_TO_1ST_SURF_DISTANCE < 1.0E-12 THEN
	    BEGIN  (* First surface is pivot *)
	      IF ZHA_ENVIRONMENT.ZHF_PIVOT_SURF_REFL THEN
		BEGIN
		  HOLD_COS_A := COS_A;
		  HOLD_SIN_A := SIN_A;
		  IF ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS THEN
		    BEGIN
		      COS_A := COS (0.5 * ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT /
			  ALR_DEGREES_PER_RADIAN);
		      SIN_A := SIN (0.5 * ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT /
			  ALR_DEGREES_PER_RADIAN)
		    END
		  ELSE
		    BEGIN
		      IF ABS (COS_A) < 1.0E-14 THEN
			IF SIN_A > 0 THEN
			  BEGIN
			    COS_A := COS_45_DEGREES;
			    SIN_A := SIN_45_DEGREES
			  END
			ELSE
			  BEGIN
			    COS_A := COS_45_DEGREES;
			    SIN_A := -SIN_45_DEGREES
			  END
		      ELSE
			BEGIN
			  TAN_A := SIN_A / COS_A;
			  ANGLE := ARCTAN (TAN_A);
			  IF COS_A < 0 THEN
			    ANGLE := ANGLE + PI;
			  COS_A := COS (0.5 * ANGLE);
			  SIN_A := SIN (0.5 * ANGLE)
			END
		    END;
		  H1010_ROTATE_ORIENTATION;
		  COS_A := HOLD_COS_A;
		  SIN_A := HOLD_SIN_A
		END
	      ELSE
	      IF ZHA_ENVIRONMENT.ZHH_PIVOT_SURF_FULL THEN
		BEGIN
		  H1005_ROTATE_POSITION;
		  H1010_ROTATE_ORIENTATION
		END
	    END
	  ELSE
	    BEGIN
	      H1005_ROTATE_POSITION;
	      H1010_ROTATE_ORIENTATION
	    END
	END
      ELSE
	BEGIN
	  H1005_ROTATE_POSITION;
	  H1010_ROTATE_ORIENTATION
	END

END;




(**  H11_PERFORM_SYSTEMIC_RAY_ROT  ********************************************
******************************************************************************)

PROCEDURE H11_PERFORM_SYSTEMIC_RAY_ROT;

  VAR
      DataDefinitionError                     : BOOLEAN;

      I					      : INTEGER;

      EX				      : DOUBLE;
      EY				      : DOUBLE;
      EZ				      : DOUBLE;
      SIN_A				      : DOUBLE;
      COS_A				      : DOUBLE;
      COS_R				      : DOUBLE;
      SIN_R				      : DOUBLE;
      ABS_MAG_E				      : DOUBLE;
      COS_P				      : DOUBLE;
      SIN_P				      : DOUBLE;
      COS_Y				      : DOUBLE;
      SIN_Y				      : DOUBLE;
      T11				      : DOUBLE;
      T12				      : DOUBLE;
      T13				      : DOUBLE;
      T21				      : DOUBLE;
      T22				      : DOUBLE;
      T23				      : DOUBLE;
      T31				      : DOUBLE;
      T32				      : DOUBLE;
      T33				      : DOUBLE;
      ROLL				      : DOUBLE;
      PITCH				      : DOUBLE;
      YAW				      : DOUBLE;
      T11_PIVOT				      : DOUBLE;
      T12_PIVOT				      : DOUBLE;
      T13_PIVOT				      : DOUBLE;
      T21_PIVOT				      : DOUBLE;
      T22_PIVOT				      : DOUBLE;
      T23_PIVOT				      : DOUBLE;
      T31_PIVOT				      : DOUBLE;
      T32_PIVOT				      : DOUBLE;
      T33_PIVOT				      : DOUBLE;
      EX_HOLD				      : DOUBLE;
      EY_HOLD				      : DOUBLE;
      EZ_HOLD				      : DOUBLE;


(**  H1105_ROTATE_POSITION  ***************************************************
******************************************************************************)


PROCEDURE H1105_ROTATE_POSITION;

  VAR
      OLD_X				      : DOUBLE;
      OLD_Y				      : DOUBLE;
      OLD_Z				      : DOUBLE;
      E_DOT_R				      : DOUBLE;
      E_CROSS_R_X			      : DOUBLE;
      E_CROSS_R_Y			      : DOUBLE;
      E_CROSS_R_Z			      : DOUBLE;

BEGIN

  (*  Treat the position of the head of ray I as if at the "head" of a
  radius vector, with the "tail" of the radius vector located at the pivot
  point.  We may then rotate this radius vector about the Euler axis to
  obtain the new position of the head of the radius vector, which thus
  becomes the new position for the head of ray I with respect to the pivot
  point.  We may then repeat the process to obtain the new position of the
  tail of ray I. *)

  (*  Find new coordinates for head of rotated light ray. *)

  OLD_X := ZNA_RAY [I].ZNG_HEAD_X_COORDINATE -
      ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X;
  OLD_Y := ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE -
      ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y;
  OLD_Z := ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE -
      ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z;

  E_DOT_R := EX * OLD_X + EY * OLD_Y + EZ * OLD_Z;
  E_CROSS_R_X := EY * OLD_Z - EZ * OLD_Y;
  E_CROSS_R_Y := EZ * OLD_X - EX * OLD_Z;
  E_CROSS_R_Z := EX * OLD_Y - EY * OLD_X;

  ZNA_RAY [I].ZNG_HEAD_X_COORDINATE :=
      SIN_A * E_CROSS_R_X + (1 - COS_A) * E_DOT_R * EX + COS_A * OLD_X +
      ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X;
  ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE :=
      SIN_A * E_CROSS_R_Y + (1 - COS_A) * E_DOT_R * EY + COS_A * OLD_Y +
      ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y;
  ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE :=
      SIN_A * E_CROSS_R_Z + (1 - COS_A) * E_DOT_R * EZ + COS_A * OLD_Z +
      ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z;

  (*  Find new coordinates for tail of rotated light ray. *)

  OLD_X := ZNA_RAY [I].ZND_TAIL_X_COORDINATE -
      ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X;
  OLD_Y := ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE -
      ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y;
  OLD_Z := ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE -
      ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z;

  E_DOT_R := EX * OLD_X + EY * OLD_Y + EZ * OLD_Z;
  E_CROSS_R_X := EY * OLD_Z - EZ * OLD_Y;
  E_CROSS_R_Y := EZ * OLD_X - EX * OLD_Z;
  E_CROSS_R_Z := EX * OLD_Y - EY * OLD_X;

  ZNA_RAY [I].ZND_TAIL_X_COORDINATE :=
      SIN_A * E_CROSS_R_X + (1 - COS_A) * E_DOT_R * EX + COS_A * OLD_X +
      ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X;
  ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE :=
      SIN_A * E_CROSS_R_Y + (1 - COS_A) * E_DOT_R * EY + COS_A * OLD_Y +
      ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y;
  ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE :=
      SIN_A * E_CROSS_R_Z + (1 - COS_A) * E_DOT_R * EZ + COS_A * OLD_Z +
      ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z

END;




(**  H11_PERFORM_SYSTEMIC_RAY_ROT  ********************************************
******************************************************************************)


BEGIN

  DataDefinitionError := FALSE;

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add ('PROCESSING SYSTEMIC RAY ROTATION...');

  (*  GET ELEMENTS OF THE SYSTEMIC ROTATION QUATERNION.	 THESE ELEMENTS
      CONSIST OF THE COMPONENTS (DIRECTION COSINES) OF A UNIT VECTOR IN THE
      DIRECTION OF THE EULER AXIS, AND A ROTATION ABOUT THE EULER AXIS.	 *)

  IF ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS THEN
    BEGIN
    (*	PRIMARY USER INPUT WAS IN THE FORM OF THE ELEMENTS OF THE SYSTEMIC
	ROTATION QUATERNION.  MAKE SURE EULER AXIS, AS ENTERED BY USER, IS
	A UNIT VECTOR.	*)
      EX := ZHA_ENVIRONMENT.ZHU_EULER_AXIS_X_MAG;
      EY := ZHA_ENVIRONMENT.ZHV_EULER_AXIS_Y_MAG;
      EZ := ZHA_ENVIRONMENT.ZHW_EULER_AXIS_Z_MAG;
      ABS_MAG_E := SQRT (EX * EX + EY * EY + EZ * EZ);
      EX := EX / ABS_MAG_E;
      EY := EY / ABS_MAG_E;
      EZ := EZ / ABS_MAG_E;
      COS_A := COS (ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT /
	  ALR_DEGREES_PER_RADIAN);
      SIN_A := SIN (ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT /
	  ALR_DEGREES_PER_RADIAN)
    END
  ELSE
    BEGIN
    (*	PRIMARY INPUT DATA WAS ENTERED IN THE FORM OF YAW, PITCH,
	AND ROLL.  THEREFORE, WE MUST FIRST COMPUTE THE DIRECTION COSINE
	MATRIX, FROM WHICH WE CAN THEN EXTRACT THE QUATERNION CONSISTING
	OF THE EULER AXIS UNIT VECTOR AND THE AMOUNT OF THE DESIRED
	ROTATION.  *)
      COS_R := COS (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      SIN_R := SIN (ZHA_ENVIRONMENT.ZHR_ROLL / ALR_DEGREES_PER_RADIAN);
      COS_P := COS (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      SIN_P := SIN (ZHA_ENVIRONMENT.ZHS_PITCH / ALR_DEGREES_PER_RADIAN);
      COS_Y := COS (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      SIN_Y := SIN (ZHA_ENVIRONMENT.ZHT_YAW / ALR_DEGREES_PER_RADIAN);
      T11 := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
      T12 := SIN_R * COS_P;
      T13 := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
      T21 := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
      T22 := COS_R * COS_P;
      T23 := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
      T31 := COS_P * SIN_Y;
      T32 := SIN_P;
      T33 := COS_P * COS_Y;
      EX := T23 - T32;
      EY := T31 - T13;
      EZ := T12 - T21;
      COS_A := 0.5 * (T11 + T22 + T33 - 1);
      SIN_A := SQRT (1 - COS_A * COS_A);
      ABS_MAG_E := SQRT (EX * EX + EY * EY + EZ * EZ);
      EX := EX / ABS_MAG_E;
      EY := EY / ABS_MAG_E;
      EZ := EZ / ABS_MAG_E
    END;

  IF ZHA_ENVIRONMENT.ZHD_USE_LOCAL_COORDS THEN
    IF (ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE > 0)
        AND (ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE <=
            CZAB_MAX_NUMBER_OF_SURFACES) THEN
      IF ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
          ZBB_SPECIFIED THEN
        BEGIN
    (*	THE USER HAS DEFINED HIS DESIRED ROTATION WITH RESPECT TO THE LOCAL
	ORIENTATION OF THE PIVOT SURFACE.  THEREFORE, WE MUST COMPUTE THE
	ROTATION MATRIX FOR THIS SURFACE, AND THEN DE-ROTATE THE EULER AXIS
	BACK INTO THE MASTER REFERENCE COORDINATE SYSTEM, BEFORE PROCEEDING
	WITH THE SYSTEMIC ROTATION.  *)
          ROLL := ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
              ZBS_ROLL;
          PITCH := ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
              ZBU_PITCH;
          YAW := ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].ZBW_YAW;
          COS_R := COS (ROLL / ALR_DEGREES_PER_RADIAN);
          SIN_R := SIN (ROLL / ALR_DEGREES_PER_RADIAN);
          COS_P := COS (PITCH / ALR_DEGREES_PER_RADIAN);
          SIN_P := SIN (PITCH / ALR_DEGREES_PER_RADIAN);
          COS_Y := COS (YAW / ALR_DEGREES_PER_RADIAN);
          SIN_Y := SIN (YAW / ALR_DEGREES_PER_RADIAN);
          T11_PIVOT := COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
          T12_PIVOT := SIN_R * COS_P;
          T13_PIVOT := -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
          T21_PIVOT := -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
          T22_PIVOT := COS_R * COS_P;
          T23_PIVOT := SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
          T31_PIVOT := COS_P * SIN_Y;
          T32_PIVOT := SIN_P;
          T33_PIVOT := COS_P * COS_Y;
        (*	NOW WE CAN DE-ROTATE THE EULER AXIS BACK INTO THE MASTER REFERENCE
	    COORDINATE SYSTEM.  *)
          EX_HOLD := EX;
          EY_HOLD := EY;
          EZ_HOLD := EZ;
          EX := (T11_PIVOT * EX_HOLD) + (T21_PIVOT * EY_HOLD) +
	      (T31_PIVOT * EZ_HOLD);
          EY := (T12_PIVOT * EX_HOLD) + (T22_PIVOT * EY_HOLD) +
	      (T32_PIVOT * EZ_HOLD);
          EZ := (T13_PIVOT * EX_HOLD) + (T23_PIVOT * EY_HOLD) +
	      (T33_PIVOT * EZ_HOLD)
        END
      ELSE
        BEGIN
          DataDefinitionError := TRUE;
          CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add
              ('ERROR:  Systemic rotation of light ray(s) with respect');
          CommandIOMemo.IOHistory.Lines.add
              ('to the local orientation of the reference surface is');
          CommandIOMemo.IOHistory.Lines.add
              ('not possible.  The reference surface is not specified.');
          Q980_REQUEST_MORE_OUTPUT
        END
    ELSE
      BEGIN
        DataDefinitionError := TRUE;
        CommandIOMemo.IOHistory.Lines.add ('');
        CommandIOMemo.IOHistory.Lines.add
            ('ERROR:  Systemic rotation of light ray(s) with respect');
        CommandIOMemo.IOHistory.Lines.add
            ('to the local orientation of the reference surface is');
        CommandIOMemo.IOHistory.Lines.add
            ('not possible.  The reference surface is not defined.');
        Q980_REQUEST_MORE_OUTPUT
      END;

  (*  THE MASTER SYSTEMIC ROTATION QUATERNION IS NOW AVAILABLE, AND IS DEFINED
      IN TERMS OF THE MASTER REFERENCE COORDINATE SYSTEM.  WE ARE NOW IN A
      POSITION TO ROTATE THE POSITION AND ORIENTATION OF ALL DESIGNATED
      RAYS, ABOUT THE EULER AXIS.  *)

  IF NOT DataDefinitionError THEN
    FOR I := ZHA_ENVIRONMENT.FirstRayInBlock TO
        ZHA_ENVIRONMENT.LastRayInBlock DO
      IF ZNA_RAY [I].ZNB_SPECIFIED THEN
        H1105_ROTATE_POSITION

END;




(**  H15_AdjustSurfaceScale  **************************************************
******************************************************************************)


PROCEDURE H15_AdjustSurfaceScale;

  VAR
      I              : INTEGER;
      J              : INTEGER;

      Temp           : DOUBLE;

BEGIN

  FOR I := ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK TO
      ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK DO
    IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
      BEGIN
        (*  Incorporate temporary values. *)
	ZBA_SURFACE [I].ZBM_VERTEX_X := ZBA_SURFACE [I].ZBM_VERTEX_X +
	    ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X;
	ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X := 0;
	ZBA_SURFACE [I].ZBO_VERTEX_Y := ZBA_SURFACE [I].ZBO_VERTEX_Y +
	    ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y;
	ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y := 0;
	ZBA_SURFACE [I].ZBQ_VERTEX_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z +
	    ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z;
	ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z := 0;
        (*  Scale everything that needs to be scaled. *)
        ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV :=
            ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA :=
	    ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZBK_INSIDE_APERTURE_DIA :=
	    ZBA_SURFACE [I].ZBK_INSIDE_APERTURE_DIA *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZCP_OUTSIDE_APERTURE_WIDTH_X :=
	    ZBA_SURFACE [I].ZCP_OUTSIDE_APERTURE_WIDTH_X *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZCQ_OUTSIDE_APERTURE_WIDTH_Y :=
	    ZBA_SURFACE [I].ZCQ_OUTSIDE_APERTURE_WIDTH_Y *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZCR_INSIDE_APERTURE_WIDTH_X :=
	    ZBA_SURFACE [I].ZCR_INSIDE_APERTURE_WIDTH_X *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZCS_INSIDE_APERTURE_WIDTH_Y :=
	    ZBA_SURFACE [I].ZCS_INSIDE_APERTURE_WIDTH_Y *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZCV_APERTURE_POSITION_X :=
	    ZBA_SURFACE [I].ZCV_APERTURE_POSITION_X *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZCW_APERTURE_POSITION_Y :=
	    ZBA_SURFACE [I].ZCW_APERTURE_POSITION_Y *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 :=
	    ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 :=
	    ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZMU_POSITION_BOUND_1 :=
            ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z + ZHA_ENVIRONMENT.ScaleFactor *
	    (ZBA_SURFACE [I].ZMU_POSITION_BOUND_1 -
            ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z);
	ZBA_SURFACE [I].ZMV_POSITION_BOUND_2 :=
            ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z + ZHA_ENVIRONMENT.ScaleFactor *
	    (ZBA_SURFACE [I].ZMV_POSITION_BOUND_2 -
            ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z);
	ZBA_SURFACE [I].ZLQ_THICKNESS :=
	    ZBA_SURFACE [I].ZLQ_THICKNESS *
            ZHA_ENVIRONMENT.ScaleFactor;
	ZBA_SURFACE [I].ZLO_DELTA_THICKNESS :=
	    ZBA_SURFACE [I].ZLO_DELTA_THICKNESS *
            ZHA_ENVIRONMENT.ScaleFactor;
        IF ZBA_SURFACE [I].SurfaceForm = HighOrderAsphere THEN
          BEGIN
            FOR J := 1 TO CZAI_MAX_DEFORM_CONSTANTS DO
              BEGIN
                Temp := exp ((J * 2 + 1) * ln (ZHA_ENVIRONMENT.ScaleFactor));
                ZBA_SURFACE [I].SurfaceShapeParameters.
                    ZCA_DEFORMATION_CONSTANT [J] := ZBA_SURFACE [I].
                    SurfaceShapeParameters.ZCA_DEFORMATION_CONSTANT [J] /
                    Temp
              END
          END
        ELSE
        IF (ZBA_SURFACE [I].SurfaceForm = CPC)
            OR (ZBA_SURFACE [I].SurfaceForm = HybridCPC) THEN
          BEGIN
            ZBA_SURFACE [I].SurfaceShapeParameters.RadiusOfOutputAperture :=
                ZBA_SURFACE [I].SurfaceShapeParameters.
                RadiusOfOutputAperture * ZHA_ENVIRONMENT.ScaleFactor;
            ZBA_SURFACE [I].SurfaceShapeParameters.RadiusOfInputAperture :=
                ZBA_SURFACE [I].SurfaceShapeParameters.
                RadiusOfInputAperture * ZHA_ENVIRONMENT.ScaleFactor
          END;
        (*  Scale position of surface. *)
        ZBA_SURFACE [I].ZBM_VERTEX_X :=
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X + ZHA_ENVIRONMENT.ScaleFactor *
            (ZBA_SURFACE [I].ZBM_VERTEX_X -
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X);
        ZBA_SURFACE [I].ZBO_VERTEX_Y :=
            ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y + ZHA_ENVIRONMENT.ScaleFactor *
            (ZBA_SURFACE [I].ZBO_VERTEX_Y -
            ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y);
        ZBA_SURFACE [I].ZBQ_VERTEX_Z :=
            ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z + ZHA_ENVIRONMENT.ScaleFactor *
            (ZBA_SURFACE [I].ZBQ_VERTEX_Z -
            ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z)
      END

END;




(**  H16_AdjustRayScale  ******************************************************
******************************************************************************)


PROCEDURE H16_AdjustRayScale;

  VAR
      I              : INTEGER;

BEGIN

  FOR I := ZHA_ENVIRONMENT.FirstRayInBlock TO
      ZHA_ENVIRONMENT.LastRayInBlock DO
    IF ZNA_RAY [I].ZNB_SPECIFIED THEN
      BEGIN
        ZNA_RAY [I].ZND_TAIL_X_COORDINATE :=
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X + ZHA_ENVIRONMENT.ScaleFactor *
            (ZNA_RAY [I].ZND_TAIL_X_COORDINATE -
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X);
        ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE :=
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X + ZHA_ENVIRONMENT.ScaleFactor *
            (ZNA_RAY [I].ZNE_TAIL_Y_COORDINATE -
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X);
        ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE :=
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X + ZHA_ENVIRONMENT.ScaleFactor *
            (ZNA_RAY [I].ZNF_TAIL_Z_COORDINATE -
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X);
        ZNA_RAY [I].ZNG_HEAD_X_COORDINATE :=
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X + ZHA_ENVIRONMENT.ScaleFactor *
            (ZNA_RAY [I].ZNG_HEAD_X_COORDINATE -
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X);
        ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE :=
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X + ZHA_ENVIRONMENT.ScaleFactor *
            (ZNA_RAY [I].ZNH_HEAD_Y_COORDINATE -
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X);
        ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE :=
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X + ZHA_ENVIRONMENT.ScaleFactor *
            (ZNA_RAY [I].ZNI_HEAD_Z_COORDINATE -
            ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X);
        ZNA_RAY [I].ZFR_BUNDLE_HEAD_DIAMETER :=
            ZNA_RAY [I].ZFR_BUNDLE_HEAD_DIAMETER *
            ZHA_ENVIRONMENT.ScaleFactor
      END

END;




(**  H20_CLEAR_ZERO  **********************************************************
******************************************************************************)


PROCEDURE H20_CLEAR_ZERO;

  VAR
      I	 : INTEGER;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('CLEARING (ZEROING) TEMPORARY POSITION AND ORIENTATION DATA,');
  CommandIOMemo.IOHistory.Lines.add ('FOR SURFACES ' +
      IntToStr (ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK) + ' THRU ' +
      IntToStr (ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK) + '...');

  FOR I := ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK TO
      ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK DO
    BEGIN
      ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X := 0;
      ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y := 0;
      ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z := 0;
      ZBA_SURFACE [I].ZBT_DELTA_ROLL := 0;
      ZBA_SURFACE [I].ZBV_DELTA_PITCH := 0;
      ZBA_SURFACE [I].ZBX_DELTA_YAW := 0
    END

END;




(**  H25_CLEAR_INCORPORATE  ***************************************************
******************************************************************************)


PROCEDURE H25_CLEAR_INCORPORATE;

  VAR
      I	 : INTEGER;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add
      ('INCORPORATING TEMPORARY POSITION AND ORIENTATION DATA AS');
  CommandIOMemo.IOHistory.Lines.add ('PERMANENT DATA, FOR SURFACES ' +
      IntToStr (ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK) + ' THRU ' +
      IntToStr (ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK) + '...');

  FOR I := ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK TO
      ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK DO
    BEGIN
      ZBA_SURFACE [I].ZBM_VERTEX_X := ZBA_SURFACE [I].ZBM_VERTEX_X +
	  ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X;
      ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X := 0;
      ZBA_SURFACE [I].ZBO_VERTEX_Y := ZBA_SURFACE [I].ZBO_VERTEX_Y +
	  ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y;
      ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y := 0;
      ZBA_SURFACE [I].ZBQ_VERTEX_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z +
	  ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z;
      ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z := 0;
      ZBA_SURFACE [I].ZBS_ROLL := ZBA_SURFACE [I].ZBS_ROLL +
	  ZBA_SURFACE [I].ZBT_DELTA_ROLL;
      ZBA_SURFACE [I].ZBT_DELTA_ROLL := 0;
      ZBA_SURFACE [I].ZBU_PITCH := ZBA_SURFACE [I].ZBU_PITCH +
	  ZBA_SURFACE [I].ZBV_DELTA_PITCH;
      ZBA_SURFACE [I].ZBV_DELTA_PITCH := 0;
      ZBA_SURFACE [I].ZBW_YAW := ZBA_SURFACE [I].ZBW_YAW +
	  ZBA_SURFACE [I].ZBX_DELTA_YAW;
      ZBA_SURFACE [I].ZBX_DELTA_YAW := 0
    END

END;




(**  H30_AIM_PRINCIPAL_RAYS  ************************************************
*                                                                           *
*  This procedure is called by the Aim command, from within the Environment *
*  menu.  RBLOK must have previously been specified, for the range of rays  *
*  which are to participate in ray aiming.  The user must also have         *
*  previously specified the surface, pupil, or aperture to aim at, by       *
*  setting a value for the Ref surface within the Environment menu.         *
*                                                                           *
****************************************************************************)


PROCEDURE H30_AIM_PRINCIPAL_RAYS;

  CONST
      MinSurfaceDiameter            = 2.0E-5;
      MaxFractionalDia              = 0.001;
      RaysInAimFan                  = 20;
      MaxErrorAttempts              = 6;
      MaxLoopCount                  = 500;

  VAR
      NonsequentialTraceEnabled     : BOOLEAN;
      AimErrorAcceptable            : BOOLEAN;
      RepositionPrincipalRay        : BOOLEAN;

      J                             : INTEGER;
      RefSurf                       : INTEGER;
      ErrorAttempt                  : INTEGER;
      LoopCount                     : INTEGER;

      Magnitude                     : DOUBLE;
      XDisplacement                 : DOUBLE;
      YDisplacement                 : DOUBLE;
      OldMerit                      : DOUBLE;
      Merit                         : DOUBLE;
      SurfaceDiameter               : DOUBLE;
      BundleDiameter                : DOUBLE;
      BundleReductionFraction       : DOUBLE;
      PreviousAimError              : DOUBLE;
      PredictedCorrection           : DOUBLE;
      Azimuth                       : DOUBLE;
      RADIUS                        : DOUBLE;
      SaveX                         : DOUBLE;
      SaveY                         : DOUBLE;
      SaveZ                         : DOUBLE;

      HoldOptions                   : OPTION_DATA_REC;

      HoldRays                      : ARRAY [1..CZAC_MAX_NUMBER_OF_RAYS] OF
                                          ZPE_ALL_RAY_DATA;

      TempHold                      : ZPE_ALL_RAY_DATA;
      BackupRay                     : ZPE_ALL_RAY_DATA;

      HoldInterceptData             : ZXE_REAL_VALUES;

BEGIN

  NoErrors := TRUE;

  (* Store image of current trace option switches and data. *)

  HoldOptions := ZFA_OPTION.ZFS_ALL_OPTION_DATA;

  IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
    NonsequentialTraceEnabled := TRUE
  ELSE
    NonsequentialTraceEnabled := FALSE;

  (* Disable all trace option switches, and then re-enable some, as
     appropriate to this procedure. *)

  FOR J := 1 TO CZAQ_OPTION_DATA_BOOLEAN_FIELDS DO
    ZFA_OPTION.ZFS_ALL_OPTION_DATA.
        ZFT_BOOLEAN_DATA [J] := FALSE;

  (* Disable error messages. *)

  ZFA_OPTION.ZGR_QUIET_ERRORS := TRUE;

  (* If appropriate, re-enable nonsequential trace switch. *)

  IF NonsequentialTraceEnabled THEN
    ZFA_OPTION.ZGI_RECURSIVE_TRACE := TRUE;

  (* Enable designated image surface switch, and set ordinal value for
     image surface to the value designated by the Ref surface in the
     Environment menu. *)

  ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED := TRUE;
  ZFA_OPTION.ZGK_DESIGNATED_SURFACE := ZHA_ENVIRONMENT.
      ZHY_REFERENCE_SURFACE;

  (* Validate reference surface parameters. *)

  RefSurf := ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE;

  IF ZBA_SURFACE [RefSurf].ZBB_SPECIFIED
      AND ZBA_SURFACE [RefSurf].ZBC_ACTIVE THEN
    IF ZBA_SURFACE [RefSurf].ZBH_OUTSIDE_DIMENS_SPECD THEN
      IF ZBA_SURFACE [RefSurf].ZCL_OUTSIDE_APERTURE_IS_SQR
          OR ZBA_SURFACE [RefSurf].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
        BEGIN
	  SurfaceDiameter := Sqrt (Sqr (ZBA_SURFACE [RefSurf].
              ZCP_OUTSIDE_APERTURE_WIDTH_X) +
	      Sqr (ZBA_SURFACE [RefSurf].ZCQ_OUTSIDE_APERTURE_WIDTH_Y));
        END
      ELSE
          SurfaceDiameter := ZBA_SURFACE [RefSurf].ZBJ_OUTSIDE_APERTURE_DIA
    ELSE
      BEGIN
        NoErrors := FALSE;
        CommandIOMemo.IOHistory.Lines.add ('');
        CommandIOMemo.IOHistory.Lines.add
            ('ERROR:  Reference surface ' + IntToStr (RefSurf) +
            ' for ray aiming');
        CommandIOMemo.IOHistory.Lines.add
            ('does not have a specified diameter.');
        CommandIOMemo.IOHistory.Lines.add ('Press <ENTER> to continue...');
        READLN (trash)
      END
  ELSE
    BEGIN
      NoErrors := FALSE;
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('ERROR:  Reference surface ' +
          IntToStr (RefSurf) + ' for ray aiming');
      CommandIOMemo.IOHistory.Lines.add ('is not specified and/or active.');
      CommandIOMemo.IOHistory.Lines.add ('Press <ENTER> to continue...');
      READLN (trash)
    END;

  IF NoErrors THEN
    IF SurfaceDiameter > MinSurfaceDiameter THEN
    ELSE
      BEGIN
        NoErrors := FALSE;
        CommandIOMemo.IOHistory.Lines.add ('');
        CommandIOMemo.IOHistory.Lines.add ('ERROR:  Reference surface ' +
            IntToStr (RefSurf) + ' for ray aiming');
        CommandIOMemo.IOHistory.Lines.add
            ('has a diameter which is too small.');
        CommandIOMemo.IOHistory.Lines.add ('Press <ENTER> to continue...');
        READLN (trash)
      END;

  (* Check validity of principal rays in designated block. *)

  FOR J := ZHA_ENVIRONMENT.FirstRayInBlock TO
      ZHA_ENVIRONMENT.LastRayInBlock DO
    IF ZNA_RAY [J].ZNB_SPECIFIED
	AND ZNA_RAY [J].ZNC_ACTIVE THEN
      BEGIN
	RAY0.X := ZNA_RAY [J].ZND_TAIL_X_COORDINATE;
	RAY0.Y := ZNA_RAY [J].ZNE_TAIL_Y_COORDINATE;
	RAY0.Z := ZNA_RAY [J].ZNF_TAIL_Z_COORDINATE;
	RAY1.X := ZNA_RAY [J].ZNG_HEAD_X_COORDINATE;
	RAY1.Y := ZNA_RAY [J].ZNH_HEAD_Y_COORDINATE;
	RAY1.Z := ZNA_RAY [J].ZNI_HEAD_Z_COORDINATE;
	Magnitude :=
	    SQRT ((RAY1.X - RAY0.X) * (RAY1.X - RAY0.X) +
	    (RAY1.Y - RAY0.Y) * (RAY1.Y - RAY0.Y) +
	    (RAY1.Z - RAY0.Z) * (RAY1.Z - RAY0.Z));
	IF Magnitude < 1.0E-12 THEN
	  BEGIN
	    NoErrors := FALSE;
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add ('ERROR:  Principal ray ' +
                IntToStr (J) + ' selected for ray aiming');
            CommandIOMemo.IOHistory.Lines.add ('has 0 magnitude.');
            CommandIOMemo.IOHistory.Lines.add ('Press <ENTER> to continue...');
            READLN (trash)
	  END
      END
    ELSE
      BEGIN
        NoErrors := FALSE;
        CommandIOMemo.IOHistory.Lines.add ('');
        CommandIOMemo.IOHistory.Lines.add ('ERROR:  Principal ray ' +
            IntToStr (J) + ' selected for ray aiming');
        CommandIOMemo.IOHistory.Lines.add ('is not specified and/or active.');
        CommandIOMemo.IOHistory.Lines.add ('Press <ENTER> to continue...');
        READLN (trash)
      END;

  (* Store image of current principal ray specifications, for all rays. *)

  FOR J := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
    HoldRays [J] := ZNA_RAY [J].ZPA_ALL_RAY_DATA;

  (* Turn off active status and ray bundle generation for all rays.
     Otherwise, rays outside of designated block will get processed by
     F05_INITIALIZE_FOR_TRACE. *)

  FOR J := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
    BEGIN
      ZNA_RAY [J].ZNB_SPECIFIED := FALSE;
      ZNA_RAY [J].ZNC_ACTIVE := FALSE;
      (* Turn off ray bundle generation for this ray. *)
      (* We need one switch here to turn off all bundle ray
         generation, instead of 10 different switches.  *)
      ZNA_RAY [J].ZFC_TRACE_SYMMETRIC_FAN := FALSE;
      ZNA_RAY [J].TraceLinearXFan := FALSE;
      ZNA_RAY [J].ZFB_TRACE_LINEAR_Y_FAN := FALSE;
      ZNA_RAY [J].ZFD_TRACE_ASYMMETRIC_FAN := FALSE;
      ZNA_RAY [J].ZFQ_TRACE_3FAN := FALSE;
      ZNA_RAY [J].ZFE_TRACE_HEXAPOLAR_BUNDLE := FALSE;
      ZNA_RAY [J].ZFF_TRACE_ISOMETRIC_BUNDLE := FALSE;
      ZNA_RAY [J].ZFG_TRACE_RANDOM_RAYS := FALSE;
      ZNA_RAY [J].ZGG_TRACE_SOLID_ANGLE_RAYS := FALSE;
      ZNA_RAY [J].TRACE_GAUSSIAN_RAYS := FALSE;
      ZNA_RAY [J].TraceOrangeSliceRays := FALSE;
      ZNA_RAY [J].TRACE_LAMBERTIAN_RAYS := FALSE
    END;

  J := ZHA_ENVIRONMENT.FirstRayInBlock;

  ErrorAttempt := 0;
  TracePrincipalRayOnly := FALSE;
  BundleReductionFraction := 1.0;
  AimErrorAcceptable := FALSE;
  RepositionPrincipalRay := FALSE;

  IF NoErrors THEN
    BEGIN
      REPEAT
        BEGIN
          (* Re-enable some things for this ray. *)
          (* First, temporarily store current ray. *)
          TempHold := ZNA_RAY [J].ZPA_ALL_RAY_DATA;
          (* Restore image of original ray. *)
          ZNA_RAY [J].ZPA_ALL_RAY_DATA := HoldRays [J];
          (* Get bundle head diameter. *)
          BundleDiameter := BundleReductionFraction *
              ZNA_RAY [J].ZFR_BUNDLE_HEAD_DIAMETER;
          (* Restore current ray from temporary image. *)
          ZNA_RAY [J].ZPA_ALL_RAY_DATA := TempHold;
          ZNA_RAY [J].ZNB_SPECIFIED := TRUE;
          ZNA_RAY [J].ZNC_ACTIVE := TRUE;
          ZNA_RAY [J].TraceLinearXFan := TRUE;
          ZNA_RAY [J].ZFB_TRACE_LINEAR_Y_FAN := FALSE;
          ZNA_RAY [J].NumberOfRaysInFanOrBundle := RaysInAimFan;
          ZNA_RAY [J].ZFR_BUNDLE_HEAD_DIAMETER := BundleDiameter;
          (* Trace this ray. *)
          LSFitOK := FALSE;
          F01_EXECUTE_TRACE;
          IF LSFitOK THEN
            BEGIN
              (* This concludes the first pass through the ray trace
                 for the X-fan of rays.  A second pass through the ray
                 trace will now be done, for a Y-fan of rays. *)
              ZNA_RAY [J].TraceLinearXFan := FALSE;
              ZNA_RAY [J].ZFB_TRACE_LINEAR_Y_FAN := TRUE;
              LSFitOK := FALSE;
              F01_EXECUTE_TRACE;
              (* Check if predicted correction is reasonable. *)
              IF LSFitOK THEN
                BEGIN
                  PredictedCorrection := Sqrt (Sqr (RayHeadXShift) +
                      Sqr (RayHeadYShift));
                  IF PredictedCorrection > (0.5 * SurfaceDiameter) THEN
                    BEGIN
                      LSFitOK := FALSE;
                      RepositionPrincipalRay := TRUE
                    END
                END
              ELSE
                RepositionPrincipalRay := TRUE;
              IF LSFitOK THEN
                BEGIN
                  (* This concludes the second pass through the ray
                     trace for this principal ray, for a Y-fan of rays.
                     We now have sufficient data to perform a coordinate
                     rotation of the local coordinates for the new head
                     location for the principal ray, back into global
                     coordinates. *)
                  (* The value of RayOrdinal and the components of the ray
                     rotation matrix are as they were after the last pass
                     through F0505_GENERATE_COMPUTED_RAYS. *)
                  PreviousAimError := AimError;
                  RayHeadZShift := 0.0;
                  ZSA_SURFACE_INTERCEPTS.ZSE_X1 := RayHeadXShift;
                  ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := RayHeadYShift;
                  ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := RayHeadZShift;
                  (* Put working ray in temporary storage. *)
                  TempHold := ZNA_RAY [J].ZPA_ALL_RAY_DATA;
                  (* Restore image of original ray. *)
                  ZNA_RAY [J].ZPA_ALL_RAY_DATA := HoldRays [J];
                  (* Store a 2nd copy of original ray. *)
                  BackupRay := HoldRays [J];
                  (* The next statement converts the newly computed local
                     coords for the head of the aimed principal ray, into
                     global coordinates. *)
                  F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (J);
                  ZNA_RAY [J].ZNG_HEAD_X_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSE_X1;
                  ZNA_RAY [J].ZNH_HEAD_Y_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
                  ZNA_RAY [J].ZNI_HEAD_Z_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSG_Z1;
                  (* Put this ray back into storage. *)
                  HoldRays [J] := ZNA_RAY [J].ZPA_ALL_RAY_DATA;
                  (* Retrieve working ray. *)
                  ZNA_RAY [J].ZPA_ALL_RAY_DATA := TempHold;
                  (* Update working ray with new coords of ray head. *)
                  ZNA_RAY [J].ZNG_HEAD_X_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSE_X1;
                  ZNA_RAY [J].ZNH_HEAD_Y_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
                  ZNA_RAY [J].ZNI_HEAD_Z_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSG_Z1;
                  ZNA_RAY [J].ZFB_TRACE_LINEAR_Y_FAN := FALSE;
                  ZNA_RAY [J].NumberOfRaysInFanOrBundle := 0;
                  LSFitOK := FALSE;
                  TracePrincipalRayOnly := TRUE;
                  F01_EXECUTE_TRACE;
                  TracePrincipalRayOnly := FALSE;
                  IF LSFitOK THEN
                    BEGIN
                      IF AimError > PreviousAimError THEN
                        BEGIN
                          RepositionPrincipalRay := TRUE;
                          HoldRays [J] := BackupRay
                        END
                      ELSE
                      IF AimError < (MaxFractionalDia *
                          SurfaceDiameter) THEN
                        (* We're done! *)
                        AimErrorAcceptable := TRUE
                      ELSE
                        (* Try again. *)
                        BundleReductionFraction := AimError /
                            PreviousAimError;
                    END
                  ELSE
                    BEGIN
                      RepositionPrincipalRay := TRUE;
                      HoldRays [J] := BackupRay
                    END
                END
            END
          ELSE
            RepositionPrincipalRay := TRUE;
          IF AimErrorAcceptable THEN
            BEGIN
              CommandIOMemo.IOHistory.Lines.add
                  ('Aim successful for principal ray ' + IntToStr (J) + '.');
              (* Disable this ray to prevent any further processing. *)
              ZNA_RAY [J].ZNB_SPECIFIED := FALSE;
              ZNA_RAY [J].ZNC_ACTIVE := FALSE;
              (* Initialize some stuff. *)
              BundleReductionFraction := 1.0;
              AimErrorAcceptable := FALSE;
              ErrorAttempt := 0;
              (* Go to the next principal ray. *)
              J := J + 1
            END
          ELSE
          IF RepositionPrincipalRay THEN
            BEGIN
              (* This is a last-ditch effort to correct the processing
                 error, most likely caused by the x- or y-fan intersecting
                 the center of the Ref surface, thus leading to failure
                 of the Levenberg-Marquardt non-linear LSF.  A possible
                 way to overcome this problem is to shift the x- and
                 y-fans by a small fraction of the diameter of the Ref
                 surface.  We will attempt this approach MaxErrorAttempts
                 times before finally giving up. *)
              RepositionPrincipalRay := FALSE;
              ErrorAttempt := ErrorAttempt + 1;
              IF ErrorAttempt < MaxErrorAttempts THEN
                BEGIN
                  Randgen;
                  ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
                      (Random * 2.0 - 1.0) * 0.2 * BundleDiameter;
                  Randgen;
                  ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
                      (Random * 2.0 - 1.0) * 0.2 * BundleDiameter;
                  ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
                  (* Put ray we have been working on in temporary storage.*)
                  TempHold := ZNA_RAY [J].ZPA_ALL_RAY_DATA;
                  (* Restore image of original ray. *)
                  ZNA_RAY [J].ZPA_ALL_RAY_DATA := HoldRays [J];
                  F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (J);
                  (* Restore the working ray. *)
                  ZNA_RAY [J].ZPA_ALL_RAY_DATA := TempHold;
                  (* Update the working ray with the new head coords. *)
                  ZNA_RAY [J].ZNG_HEAD_X_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSE_X1;
                  ZNA_RAY [J].ZNH_HEAD_Y_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
                  ZNA_RAY [J].ZNI_HEAD_Z_COORDINATE :=
                      ZSA_SURFACE_INTERCEPTS.ZSG_Z1
                END
              ELSE
              IF ErrorAttempt = MaxErrorAttempts THEN
                (* Try random walk. *)
                BEGIN
                  TracePrincipalRayOnly := TRUE;
                  LoopCount := 0;
                  ZNA_RAY [J].TraceLinearXFan := FALSE;
                  ZNA_RAY [J].ZFB_TRACE_LINEAR_Y_FAN := FALSE;
                  RayHeadZShift := 0.0;
                  ZNA_RAY [J].NumberOfRaysInFanOrBundle := 0;
                  LSFitOK := FALSE;
                  F01_EXECUTE_TRACE;
                  IF LSFitOK THEN
                    PreviousAimError := AimError
                  ELSE
                    BEGIN
                      PreviousAimError := SurfaceDiameter;
                      AimError := SurfaceDiameter + 1
                    END;
                  WHILE (AimError > (MaxFractionalDia * SurfaceDiameter))
                      AND (LoopCount < MaxLoopCount) DO
                    BEGIN
                      LoopCount := LoopCount + 1;
                      (* Add a random x-y offset to the head of the
                         principal ray, and then trace it. *)
                      RANDGEN;
		      Azimuth := RANDOM * 2 * PI;
		      RANDGEN;
		      RADIUS := (SQRT (RANDOM)) * BundleDiameter;
		      ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
			  RADIUS * COS (Azimuth);
		      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
			  RADIUS * SIN (Azimuth);
		      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
                      (* Put working ray in temporary storage. *)
                      TempHold := ZNA_RAY [J].ZPA_ALL_RAY_DATA;
                      (* Restore image of original ray. *)
                      ZNA_RAY [J].ZPA_ALL_RAY_DATA := HoldRays [J];
                      (* The next statement converts the newly computed local
                         coords for the head of the aimed principal ray, into
                         global coordinates. *)
                      F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (J);
                      (* Bring working ray back. *)
                      ZNA_RAY [J].ZPA_ALL_RAY_DATA := TempHold;
                      (* Update working ray with new position of head of
                         principal ray. *)
                      ZNA_RAY [J].ZNG_HEAD_X_COORDINATE :=
                          ZSA_SURFACE_INTERCEPTS.ZSE_X1;
                      ZNA_RAY [J].ZNH_HEAD_Y_COORDINATE :=
                          ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
                      ZNA_RAY [J].ZNI_HEAD_Z_COORDINATE :=
                          ZSA_SURFACE_INTERCEPTS.ZSG_Z1;
                      LSFitOK := FALSE;
                      (* Trace new working ray. *)
                      F01_EXECUTE_TRACE;
                      IF LSFitOK THEN
                        BEGIN
                          IF AimError < PreviousAimError THEN
                            BEGIN
                              BundleDiameter := BundleDiameter * (AimError /
                                  PreviousAimError);
                              PreviousAimError := AimError;
                              (* Save working ray head coords. *)
                              SaveX := ZNA_RAY [J].ZNG_HEAD_X_COORDINATE;
                              SaveY := ZNA_RAY [J].ZNH_HEAD_Y_COORDINATE;
                              SaveZ := ZNA_RAY [J].ZNI_HEAD_Z_COORDINATE;
                              (* Put working ray in temporary storage. *)
                              TempHold := ZNA_RAY [J].ZPA_ALL_RAY_DATA;
                              (* Bring back original ray. *)
                              ZNA_RAY [J].ZPA_ALL_RAY_DATA := HoldRays [J];
                              (* Update original ray with new head coords. *)
                              ZNA_RAY [J].ZNG_HEAD_X_COORDINATE := SaveX;
                              ZNA_RAY [J].ZNH_HEAD_Y_COORDINATE := SaveY;
                              ZNA_RAY [J].ZNI_HEAD_Z_COORDINATE := SaveZ;
                              (* Put original ray back into storage. *)
                              HoldRays [J] := ZNA_RAY [J].ZPA_ALL_RAY_DATA;
                              (* Retrieve working ray. *)
                              ZNA_RAY [J].ZPA_ALL_RAY_DATA := TempHold
                            END
                        END
                    END;
                  TracePrincipalRayOnly := FALSE;
                  IF LoopCount >= MaxLoopCount THEN
                    BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                          ('ATTENTION:  Automated ray aiming failed for' +
                          ' principal');
                      CommandIOMemo.IOHistory.Lines.add
                          ('ray number ' + IntToStr (RayOrdinal) +
                          '.  Try adjusting the position of');
                      CommandIOMemo.IOHistory.Lines.add ('the principal ray.');
                      (*Q980_REQUEST_MORE_OUTPUT;*)
                      (* Disable this ray to prevent any further
                         processing. *)
                      ZNA_RAY [J].ZNB_SPECIFIED := FALSE;
                      ZNA_RAY [J].ZNC_ACTIVE := FALSE;
                      (* Initialize some stuff. *)
                      BundleReductionFraction := 1.0;
                      AimErrorAcceptable := FALSE;
                      ErrorAttempt := 0;
                      (* Go to the next principal ray. *)
                      J := J + 1
                    END
                END
              ELSE
                BEGIN
                  CommandIOMemo.IOHistory.Lines.add ('');
                  CommandIOMemo.IOHistory.Lines.add
                      ('ATTENTION:  Automated ray aiming failed for principal');
                  CommandIOMemo.IOHistory.Lines.add ('ray number ' +
                      IntToStr (RayOrdinal) + '.  Try adjusting' +
                      ' the position of');
                  CommandIOMemo.IOHistory.Lines.add ('the principal ray.');
                  (*Q980_REQUEST_MORE_OUTPUT;*)
                  (* Disable this ray to prevent any further processing. *)
                  ZNA_RAY [J].ZNB_SPECIFIED := FALSE;
                  ZNA_RAY [J].ZNC_ACTIVE := FALSE;
                  (* Initialize some stuff. *)
                  BundleReductionFraction := 1.0;
                  AimErrorAcceptable := FALSE;
                  ErrorAttempt := 0;
                  (* Go to the next principal ray. *)
                  J := J + 1
                END
            END
        END
      UNTIL (J > ZHA_ENVIRONMENT.LastRayInBlock)
    END;

  IF INTERCEPT_WORK_FILE_OPEN THEN
    BEGIN
      IF ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE THEN
        CLOSE (ZAI_INTERCEPT_WORK_FILE)
      ELSE
        BEGIN
          CLOSE (ZAI_INTERCEPT_WORK_FILE);
          ERASE (ZAI_INTERCEPT_WORK_FILE)
        END;
      INTERCEPT_WORK_FILE_OPEN := FALSE
    END;

  IF RECURS_INTERCEPT_WORK_FILE_OPEN THEN
    BEGIN
      CLOSE (ZAK_RECURS_INTERCEPT_WORK_FILE);
      ERASE (ZAK_RECURS_INTERCEPT_WORK_FILE);
      RECURS_INTERCEPT_WORK_FILE_OPEN := FALSE
    END;

  (* Restore trace options and principal ray specifications from
     stored images. *)

  FOR J := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
    ZNA_RAY [J].ZPA_ALL_RAY_DATA := HoldRays [J];

  ZFA_OPTION.ZFS_ALL_OPTION_DATA := HoldOptions

END;




(**  H01_SET_UP_ENVIRONMENT  **************************************************
******************************************************************************)


BEGIN

  Q070_REQUEST_ENVIRONMENT;

  WHILE NOT S01AB_USER_IS_DONE DO
    BEGIN
      IF AIN_TRANSLATE
          OR AIQ_ADJUST_THICKNESS THEN
        BEGIN
          IF ZHA_ENVIRONMENT.SurfaceRangeActivated THEN
            H06_TRANSLATE_SURFACES;
          IF ZHA_ENVIRONMENT.RayRangeActivated THEN
            H07_TRANSLATE_RAYS;
          IF ZHA_ENVIRONMENT.SurfaceRangeActivated
              OR ZHA_ENVIRONMENT.RayRangeActivated THEN
          ELSE
            BEGIN
              CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
                  ('ERROR:  You must first specify a range of surfaces');
              CommandIOMemo.IOHistory.Lines.add
                  ('and/or a range of rays to be translated.');
              Q980_REQUEST_MORE_OUTPUT
            END
        END
      ELSE
      IF AIP_PERFORM_SYSTEMIC_ROTATION THEN
        BEGIN
	  IF ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS THEN
	    BEGIN
	      IF (ZHA_ENVIRONMENT.ZHU_EULER_AXIS_X_MAG = 0)
		  AND (ZHA_ENVIRONMENT.ZHV_EULER_AXIS_Y_MAG = 0)
		  AND (ZHA_ENVIRONMENT.ZHW_EULER_AXIS_Z_MAG = 0) THEN
	        BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                    ('ERROR:  Could not perform requested systemic rotation.');
		  CommandIOMemo.IOHistory.Lines.add ('Euler axis not defined.');
                  Q980_REQUEST_MORE_OUTPUT
	        END
	      ELSE
	      IF ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT = 0 THEN
	        BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                    ('ERROR:  Could not perform requested systemic rotation.');
		  CommandIOMemo.IOHistory.Lines.add
                    ('Angle of rotation about Euler axis was not specified.');
                  Q980_REQUEST_MORE_OUTPUT
	        END
	      ELSE
	        BEGIN
                  IF ZHA_ENVIRONMENT.SurfaceRangeActivated THEN
                    H10_PERFORM_SYSTEMIC_SURF_ROT;
                  IF ZHA_ENVIRONMENT.RayRangeActivated THEN
                    H11_PERFORM_SYSTEMIC_RAY_ROT;
                  IF ZHA_ENVIRONMENT.SurfaceRangeActivated
                      OR ZHA_ENVIRONMENT.RayRangeActivated THEN
                  ELSE
                    BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                        ('ERROR:  You must first specify a range of surfaces');
                      CommandIOMemo.IOHistory.Lines.add
                        ('and/or a range of rays to be rotated.');
                      Q980_REQUEST_MORE_OUTPUT
                    END
	        END
	    END
	  ELSE
	    BEGIN
	      IF (ZHA_ENVIRONMENT.ZHR_ROLL = 0)
		  AND (ZHA_ENVIRONMENT.ZHS_PITCH = 0)
		  AND (ZHA_ENVIRONMENT.ZHT_YAW = 0) THEN
	        BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                    ('ERROR:  Could not perform requested systemic rotation.');
		  CommandIOMemo.IOHistory.Lines.add
                    ('Yaw, pitch, and/or roll not specified.');
                  Q980_REQUEST_MORE_OUTPUT
	        END
	      ELSE
	        BEGIN
                  IF ZHA_ENVIRONMENT.SurfaceRangeActivated THEN
                    H10_PERFORM_SYSTEMIC_SURF_ROT;
                  IF ZHA_ENVIRONMENT.RayRangeActivated THEN
                    H11_PERFORM_SYSTEMIC_RAY_ROT;
                  IF ZHA_ENVIRONMENT.SurfaceRangeActivated
                      OR ZHA_ENVIRONMENT.RayRangeActivated THEN
                  ELSE
                    BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                        ('ERROR:  You must first specify a range of surfaces');
                      CommandIOMemo.IOHistory.Lines.add
                        ('and/or a range of rays to be rotated.');
                      Q980_REQUEST_MORE_OUTPUT
                    END
	        END
	    END
        END
      ELSE
      IF AdjustScale THEN
        BEGIN
          IF ZHA_ENVIRONMENT.SurfaceRangeActivated THEN
            H15_AdjustSurfaceScale;
          IF ZHA_ENVIRONMENT.RayRangeActivated THEN
            H16_AdjustRayScale;
          IF ZHA_ENVIRONMENT.SurfaceRangeActivated
              OR ZHA_ENVIRONMENT.RayRangeActivated THEN
          ELSE
            BEGIN
              CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
                ('ERROR:  You must first specify a range of surfaces');
              CommandIOMemo.IOHistory.Lines.add
                ('and/or a range of rays to be scaled.');
              Q980_REQUEST_MORE_OUTPUT
            END
        END
      ELSE
      IF AimPrincipalRays THEN
        BEGIN
          IF ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
              ZBB_SPECIFIED
              AND ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
              ZBC_ACTIVE
              AND ZHA_ENVIRONMENT.RayRangeActivated THEN
            H30_AIM_PRINCIPAL_RAYS
          ELSE
            BEGIN
              CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
                  ('ERROR:  You must first specify a range of rays,');
              CommandIOMemo.IOHistory.Lines.add
                  ('an/or a valid reference surface as a target.');
              Q980_REQUEST_MORE_OUTPUT
            END
        END
      ELSE
      IF ADW_CLEAR_ZERO THEN
        H20_CLEAR_ZERO
      ELSE
      IF ADZ_CLEAR_INCORPORATE THEN
        H25_CLEAR_INCORPORATE;
      Q070_REQUEST_ENVIRONMENT
    END

END;




(**  LADSEnvironUnit  ********************************************************
*****************************************************************************)


BEGIN

END.

