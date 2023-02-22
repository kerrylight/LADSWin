UNIT LADSTraceUnit;

INTERFACE

USES Printers, Math;

PROCEDURE F01_EXECUTE_TRACE;
PROCEDURE F03_VALIDATE_RAY_TRACE;
PROCEDURE F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal : INTEGER);
PROCEDURE F05_INITIALIZE_FOR_TRACE;
PROCEDURE F06_INITIALIZE_FOR_GRAPHICS;
PROCEDURE F07_SET_UP_SPOT_DIAGRAM;
PROCEDURE F08_DRAW_SURFACES;
PROCEDURE F10_INITIALIZE_RAY;
PROCEDURE F20_TRACE_RAY;
PROCEDURE F21_FIND_NEXT_SEQUENTIAL_SURFACE;
PROCEDURE F22_FIND_NEXT_RECURSIVE_SURFACE;
PROCEDURE F23ComputeGRINRayPath;
PROCEDURE F25_PROCESS_SURFACE;
PROCEDURE XformGlobalCoordsToLocal;
PROCEDURE ComputeLensletApertureXYOffset;
PROCEDURE F50_INTERSECT_SURFACE;
PROCEDURE F52_REFLECT_OR_REFRACT;
PROCEDURE F53_GENERATE_REFLECTED_COMPONENT;
PROCEDURE DetranslateLenslet;
PROCEDURE F55_COMPUTE_DIA_AND_INTENSITY;
PROCEDURE XformLocalCoordsToGlobal;
PROCEDURE F65_COMPUTE_PATH_LENGTH;
PROCEDURE F70_PRINT_TRACE_RESULTS;
PROCEDURE F75DisplayLocalData;
PROCEDURE F93_FIND_SURFACE_NORMAL (X1, Y1, Z1 : DOUBLE);
PROCEDURE F95_GET_COLUMN_AND_ROW;
PROCEDURE F105_DRAW_SURFACES;

IMPLEMENTATION

  USES SysUtils,
       Graphics,
       Classes,
       LADSUtilUnit,
       LADSArchiveUnit,
       LADSEnvironUnit,
       LADSCommandIOMemoUnit,
       LADSCommandIOdlgUnit,
       LADSData,
       LADSQCPCUnit,
       LADSGlassCompUnit,
       LADSGlassVar,
       LADSPostProcUnit,
       LADSOptimizeUnit,
       LADSFileProcUnit,
       ExpertIO,
       LADSRandomUnit,
       LADSGraphics;

(**  F03_VALIDATE_RAY_TRACE  **************************************************
******************************************************************************)


PROCEDURE F03_VALIDATE_RAY_TRACE;

  TYPE
      ADH_RAY_REC			       = RECORD CASE INTEGER OF
	1: (A				       : DOUBLE;
	    B				       : DOUBLE;
	    C				       : DOUBLE;
	    X				       : DOUBLE;
	    Y				       : DOUBLE;
	    Z				       : DOUBLE);
	2: (ALL				       : ARRAY [1..6] OF DOUBLE)
	END;
	
  VAR
      F01AA_FIRST_OPD_REF_SURF_FOUND	      : BOOLEAN;
      F01AC_LAST_OPD_REF_SURF_FOUND	      : BOOLEAN;
      F01AK_APERTURE_ERROR		      : BOOLEAN;
      F01AL_FIRST_RAY_FOUND		      : BOOLEAN;
      
      I                                       : INTEGER;
      J                                       : INTEGER;
      SaveIOResult                            : INTEGER;
      SurfaceOrdinal                          : INTEGER;
      RayOrdinal                              : INTEGER;
      GroupIndex                              : INTEGER;

      F01BD_WORK_FILE_NAME		      : STRING [30];
      
      F01AJ_RAY_MAGNITUDE		      : DOUBLE;
      H_MAX				      : DOUBLE;

      RAY0				      : ADH_RAY_REC;
      RAY1				      : ADH_RAY_REC;
      
      F01ZDF_BLOCK_INITIALIZER		      : ZXA_INPUT_OUTPUT_BLOCK;

BEGIN

  NoErrors := TRUE;
  
  GraphicsActive                    := FALSE;
  RectangularViewportEnabled        := FALSE;
  EllipticalViewportEnabled         := FALSE;
  CircularViewportEnabled           := FALSE;
  RECURS_INTERCEPT_WORK_FILE_OPEN   := FALSE;
  INTERCEPT_WORK_FILE_OPEN          := FALSE;
  LIST_FILE_OPEN                    := FALSE;
  PRINT_FILE_OPEN                   := FALSE;
  DIFFRACT_WORK_FILE_OPEN           := FALSE;
  OUTPUT_RAY_FILE_OPEN              := FALSE;

  ARL_SEQUENCER_HI_INDEX := 0;
  ADA_LAST_RAY := 0;
  ARX_ACCUM_INITIAL_INTENSITY := 0.0;
  ARY_ACCUM_FINAL_INTENSITY := 0.0;
  ARB_TOTAL_RECURS_INTERCEPTS := 0;
  BSIndex := 0;
  
  F01AA_FIRST_OPD_REF_SURF_FOUND := FALSE;
  F01AC_LAST_OPD_REF_SURF_FOUND := FALSE;

  IF ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER THEN
    BEGIN
      IF (ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	    CZBP_NORMAL_PROCESSING_SEQUENCE)
	  OR (ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	    CZBR_AUTO_SEQUENCING) THEN
	BEGIN
	  FOR J := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	    ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := 0;
	  J := 0;
	  FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	    IF ZBA_SURFACE [I].ZBB_SPECIFIED
		AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	      BEGIN
		J := J + 1;
		ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := I
	      END;
	  ARL_SEQUENCER_HI_INDEX := J
	END
      ELSE
      IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	  CZBQ_REVERSE_PROCESSING_SEQUENCE THEN
	BEGIN
	  FOR J := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	    ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := 0;
	  J := 0;
	  FOR I := CZAB_MAX_NUMBER_OF_SURFACES DOWNTO 1 DO
	    IF ZBA_SURFACE [I].ZBB_SPECIFIED
		AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	      BEGIN
		J := J + 1;
		ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := I
	      END;
	  ARL_SEQUENCER_HI_INDEX := J
	END
      ELSE
	(* Implies a user-specified sequence. *)
	BEGIN
	  (* Throw out the deadwood *)
	  FOR J := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	    BEGIN
	      I := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
	      IF (I > 0)
		  AND (I <= CZAB_MAX_NUMBER_OF_SURFACES) THEN
		IF ZBA_SURFACE [I].ZBB_SPECIFIED
		    AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
		  BEGIN
		    ARL_SEQUENCER_HI_INDEX := ARL_SEQUENCER_HI_INDEX + 1;
		    ZFA_OPTION.ZGT_SURFACE_SEQUENCER
			[ARL_SEQUENCER_HI_INDEX] := I
		  END
	    END
	END
    END
  ELSE
    BEGIN
      FOR J := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := 0;
      J := 0;
      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	IF ZBA_SURFACE [I].ZBB_SPECIFIED
	    AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	  BEGIN
	    J := J + 1;
	    ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := I
	  END;
      ARL_SEQUENCER_HI_INDEX := J
    END;

  IF ARL_SEQUENCER_HI_INDEX = 0 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('FATAL ERROR:  No surfaces available to trace.');
      NoErrors := FALSE
    END
  ELSE
    BEGIN
      FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
	BEGIN
	  I := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
	  IF F01AC_LAST_OPD_REF_SURF_FOUND THEN
	    BEGIN
	    END
	  ELSE
	    ADF_END_OPD_REF_SURFACE := I;
	  IF ZBA_SURFACE [I].ZBF_OPD_REFERENCE THEN
	    IF F01AA_FIRST_OPD_REF_SURF_FOUND THEN
	      F01AC_LAST_OPD_REF_SURF_FOUND := TRUE
	    ELSE
	      BEGIN
		ADG_BEGIN_OPD_REF_SURFACE := I;
		F01AA_FIRST_OPD_REF_SURF_FOUND := TRUE
	      END
	END
    END;
      
  IF NoErrors THEN
    FOR GroupIndex := 1 TO CZBO_MAX_SEQUENCER_GROUPS DO
      IF ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
	  ZGX_GROUP_PROCESS_CONTROL_CODE = GroupActive THEN
            IF ZBA_SURFACE [ZFA_OPTION.
                  ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                  ZGV_SEQUENCER_START_SLOT].ZBB_SPECIFIED
                AND ZBA_SURFACE [ZFA_OPTION.
                  ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                  ZGV_SEQUENCER_START_SLOT].ZBC_ACTIVE
                AND ZBA_SURFACE [ZFA_OPTION.
                  ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                  ZGW_SEQUENCER_END_SLOT].ZBB_SPECIFIED
                AND ZBA_SURFACE [ZFA_OPTION.
                  ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                  ZGW_SEQUENCER_END_SLOT].ZBC_ACTIVE THEN
              BEGIN
              END
            ELSE
              BEGIN
                CommandIOMemo.IOHistory.Lines.add ('');
                CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  Surfaces specified as starting');
                CommandIOMemo.IOHistory.Lines.add
                    ('and/or ending surfaces in sequencer group ' +
                    IntToStr (GroupIndex) + ' are either not');
                CommandIOMemo.IOHistory.Lines.add
                    ('defined or are not active.');
                NoErrors := FALSE
              END;

  IF NoErrors THEN
    BEGIN
      IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE
	  OR ZFA_OPTION.ZGF_DISPLAY_FULL_OPD
	  OR ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
	IF F01AA_FIRST_OPD_REF_SURF_FOUND
	    AND F01AC_LAST_OPD_REF_SURF_FOUND THEN
	  BEGIN
	  END
	ELSE
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('FATAL ERROR:  OPD reference surface(s) have not been' +
		' identified.');
	    NoErrors := FALSE
	  END
    END;
    
  IF NoErrors THEN
    FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
      BEGIN
	SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
	IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HighOrderAsphere THEN
          BEGIN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD THEN
	      BEGIN
	      END
	    ELSE
	      BEGIN
	        CommandIOMemo.IOHistory.Lines.add ('');
	        CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  Outside aperture not specified for');
	        CommandIOMemo.IOHistory.Lines.add
                    ('high-order aspheric surface ' +
	            IntToStr (SurfaceOrdinal) + '.');
	        NoErrors := FALSE
	      END
          END
        ELSE
        IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = CPC)
            OR (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC) THEN
          BEGIN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD
	        AND ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD THEN
	      BEGIN
	      END
	    ELSE
	      BEGIN
	        CommandIOMemo.IOHistory.Lines.add ('');
	        CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  Entrance and/or exit aperture');
	        CommandIOMemo.IOHistory.Lines.add
                    ('diameters not specified for CPC surface ' +
	            IntToStr (SurfaceOrdinal) + '.');
	        NoErrors := FALSE
	      END;
            IF abs (ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV -
                DefaultCPCRadius) > CPCRadiusError THEN
              BEGIN
                CommandIOMemo.IOHistory.Lines.add ('');
                CommandIOMemo.IOHistory.Lines.add
                    ('ATTENTION:  Resetting radius for CPC surface ' +
                    IntToStr (SurfaceOrdinal) + ' to default value ' +
                    FloatToStrF (DefaultCPCRadius, ffFixed, 6, 3) + '.');
                ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV :=
                    DefaultCPCRadius
              END;
            IF abs (ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT) >
                CPCConicConstantError THEN
              BEGIN
                CommandIOMemo.IOHistory.Lines.add ('');
                CommandIOMemo.IOHistory.Lines.add
                    ('ATTENTION:  Resetting conic constant for CPC surface ' +
                    IntToStr (SurfaceOrdinal) + ' to default value ' +
                    FloatToStrF (DefaultCPCConicConstant, ffFixed, 6, 3) + '.');
                ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT :=
                    DefaultCPCConicConstant
              END;
            IF NoErrors THEN
              CPCComputations (SurfaceOrdinal)
          END
      END;
		
  IF NoErrors THEN
    FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
      BEGIN
	SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
	IF ZBA_SURFACE [SurfaceOrdinal].
	    ZBY_BEAMSPLITTER_SURFACE THEN
	  IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
	  ELSE
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('FATAL ERROR:  You must activate non-sequential' +
	          ' (recursive) ray tracing,');
	      CommandIOMemo.IOHistory.Lines.add
                  ('or cancel beamsplitter status for surface ' +
	          IntToStr (SurfaceOrdinal) + '.');
	      NoErrors := FALSE
	    END
      END;

  IF NoErrors THEN
    FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
      BEGIN
	SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
        IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
          IF (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns > 0)
              AND (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows > 0) THEN
            IF (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns > 1)
                OR (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows > 1) THEN
              BEGIN
              END
            ELSE
              BEGIN
	        CommandIOMemo.IOHistory.Lines.add ('');
	        CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  Lenslet array specified, but no rows or' +
	            ' columns specified.');
	        NoErrors := FALSE
              END
          ELSE
            BEGIN
              CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
                  ('FATAL ERROR:  Lenslet array specified, but no rows or' +
	          ' columns specified.');
              NoErrors := FALSE
            END
      END;

  IF NoErrors THEN
    FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
      BEGIN
	SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
        IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
          IF NOT ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD THEN
            BEGIN
              CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
                  ('FATAL ERROR:  Lenslet array specified for surface ' +
                  IntToStr (SurfaceOrdinal) + ', but lenslet ' +
                  'center-to-center spacing not specified.');
              NoErrors := FALSE
            END
      END;

  IF NoErrors THEN
    FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
      BEGIN
	SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
        IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
          BEGIN
            IF ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR
                OR ZBA_SURFACE [SurfaceOrdinal].
                ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
              BEGIN
                IF (ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX <
                    ZBA_SURFACE [SurfaceOrdinal].ZCP_OUTSIDE_APERTURE_WIDTH_X)
                    OR (ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY <
                    ZBA_SURFACE [SurfaceOrdinal].
                    ZCQ_OUTSIDE_APERTURE_WIDTH_Y) THEN
                  BEGIN
                    CommandIOMemo.IOHistory.Lines.add ('');
                    CommandIOMemo.IOHistory.Lines.add
                        ('FATAL ERROR:  Specified dimensions of lenslets for ' +
                        'surface ' + IntToStr (SurfaceOrdinal) + ' exceeds ' +
                        'specified center-to-center spacing of lenslets.');
                    NoErrors := FALSE
                  END
              END
            ELSE
              BEGIN
                IF (ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX <
                    ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA)
                    OR (ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY <
                    ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA) THEN
                  BEGIN
                    CommandIOMemo.IOHistory.Lines.add ('');
                    CommandIOMemo.IOHistory.Lines.add
                        ('FATAL ERROR:  Specified dimensions of lenslets for ' +
                        'surface ' + IntToStr (SurfaceOrdinal) + ' exceeds ' +
                        'specified center-to-center spacing of lenslets.');
                    NoErrors := FALSE
                  END
              END
          END
      END;

  IF NoErrors THEN
    FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
      BEGIN
	SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
	IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD
	    AND (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = Conic)
	    AND (NOT ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT)
	    AND (ZBA_SURFACE [SurfaceOrdinal].
		ZBL_CONIC_CONSTANT > -1.0) THEN
	  BEGIN
	    F01AK_APERTURE_ERROR := FALSE;
	    H_MAX := ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV /
		SQRT (ZBA_SURFACE [SurfaceOrdinal].
		ZBL_CONIC_CONSTANT + 1.0);
	    IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
	      BEGIN
		IF ZBA_SURFACE [SurfaceOrdinal].
		    ZCL_OUTSIDE_APERTURE_IS_SQR
		    OR ZBA_SURFACE [SurfaceOrdinal].
		    ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
		  IF (ZBA_SURFACE [SurfaceOrdinal].
		      ZCQ_OUTSIDE_APERTURE_WIDTH_Y < (2.0 * H_MAX)) THEN
		    BEGIN
		    END
		  ELSE
		    F01AK_APERTURE_ERROR := TRUE
		ELSE
		  IF (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		      ZBJ_OUTSIDE_APERTURE_DIA) < H_MAX THEN
		    BEGIN
		    END
		  ELSE
		    F01AK_APERTURE_ERROR := TRUE
	      END
	    ELSE
	    IF ZBA_SURFACE [SurfaceOrdinal].
		ZCL_OUTSIDE_APERTURE_IS_SQR THEN
	      IF (SQRT (SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		  ZCP_OUTSIDE_APERTURE_WIDTH_X) +
		  SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		  ZCQ_OUTSIDE_APERTURE_WIDTH_Y))) < H_MAX THEN
		BEGIN
		END
	      ELSE
		F01AK_APERTURE_ERROR := TRUE
	    ELSE
	    IF ZBA_SURFACE [SurfaceOrdinal].
		ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
	      IF ((0.5 * ZBA_SURFACE [SurfaceOrdinal].
		  ZCP_OUTSIDE_APERTURE_WIDTH_X) < H_MAX)
		AND ((0.5 * ZBA_SURFACE [SurfaceOrdinal].
		  ZCQ_OUTSIDE_APERTURE_WIDTH_Y) < H_MAX) THEN
		BEGIN
		END
	      ELSE
		F01AK_APERTURE_ERROR := TRUE
	    ELSE
	      IF (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		  ZBJ_OUTSIDE_APERTURE_DIA) < H_MAX THEN
		BEGIN
		END
	      ELSE
		F01AK_APERTURE_ERROR := TRUE;
	    IF F01AK_APERTURE_ERROR THEN
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  Specified outside aperture too' +
		    ' large for surface ' + IntToStr (SurfaceOrdinal) + '.');
		NoErrors := FALSE
	      END
	  END
      END;
	  
  IF NoErrors THEN
    FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
      BEGIN
	SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
	IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD
	    AND ZBA_SURFACE [SurfaceOrdinal].
	      ZCT_INSIDE_DIMENS_SPECD THEN
	  BEGIN
	    F01AK_APERTURE_ERROR := FALSE;
	    IF ZBA_SURFACE [SurfaceOrdinal].
		ZCL_OUTSIDE_APERTURE_IS_SQR THEN
	      IF ZBA_SURFACE [SurfaceOrdinal].
		  ZCM_INSIDE_APERTURE_IS_SQR
		  OR ZBA_SURFACE [SurfaceOrdinal].
		  ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
		IF (ZBA_SURFACE [SurfaceOrdinal].
		    ZCP_OUTSIDE_APERTURE_WIDTH_X >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZCR_INSIDE_APERTURE_WIDTH_X)
		  AND (ZBA_SURFACE [SurfaceOrdinal].
		    ZCQ_OUTSIDE_APERTURE_WIDTH_Y >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZCS_INSIDE_APERTURE_WIDTH_Y) THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE
	      ELSE
		IF (ZBA_SURFACE [SurfaceOrdinal].
		    ZCP_OUTSIDE_APERTURE_WIDTH_X >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZBK_INSIDE_APERTURE_DIA)
		  AND (ZBA_SURFACE [SurfaceOrdinal].
		    ZCQ_OUTSIDE_APERTURE_WIDTH_Y >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZBK_INSIDE_APERTURE_DIA) THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE
	    ELSE
	    IF ZBA_SURFACE [SurfaceOrdinal].
		ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
	      IF ZBA_SURFACE [SurfaceOrdinal].
		  ZCM_INSIDE_APERTURE_IS_SQR THEN
		IF (SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		    ZCP_OUTSIDE_APERTURE_WIDTH_X) /
		    SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		    ZCR_INSIDE_APERTURE_WIDTH_X)) +
		    (SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		    ZCQ_OUTSIDE_APERTURE_WIDTH_Y) /
		    SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		    ZCS_INSIDE_APERTURE_WIDTH_Y)) < 1.0 THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE
	      ELSE
	      IF ZBA_SURFACE [SurfaceOrdinal].
		  ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
		IF (ZBA_SURFACE [SurfaceOrdinal].
		    ZCP_OUTSIDE_APERTURE_WIDTH_X >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZCR_INSIDE_APERTURE_WIDTH_X)
		  AND (ZBA_SURFACE [SurfaceOrdinal].
		    ZCQ_OUTSIDE_APERTURE_WIDTH_Y >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZCS_INSIDE_APERTURE_WIDTH_Y) THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE
	      ELSE
		IF (ZBA_SURFACE [SurfaceOrdinal].
		    ZCP_OUTSIDE_APERTURE_WIDTH_X >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZBK_INSIDE_APERTURE_DIA)
		  AND (ZBA_SURFACE [SurfaceOrdinal].
		    ZCQ_OUTSIDE_APERTURE_WIDTH_Y >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZBK_INSIDE_APERTURE_DIA) THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE
	    ELSE
	      IF ZBA_SURFACE [SurfaceOrdinal].
		  ZCM_INSIDE_APERTURE_IS_SQR THEN
		IF (ZBA_SURFACE [SurfaceOrdinal].
		    ZBJ_OUTSIDE_APERTURE_DIA >
		    SQRT (SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		    ZCR_INSIDE_APERTURE_WIDTH_X) +
		    SQR (0.5 * ZBA_SURFACE [SurfaceOrdinal].
		    ZCS_INSIDE_APERTURE_WIDTH_Y))) THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE
	      ELSE
	      IF ZBA_SURFACE [SurfaceOrdinal].
		  ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
		IF (ZBA_SURFACE [SurfaceOrdinal].
		    ZBJ_OUTSIDE_APERTURE_DIA >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZCR_INSIDE_APERTURE_WIDTH_X)
		  AND (ZBA_SURFACE [SurfaceOrdinal].
		    ZBJ_OUTSIDE_APERTURE_DIA >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZCS_INSIDE_APERTURE_WIDTH_Y) THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE
	      ELSE
		IF (ZBA_SURFACE [SurfaceOrdinal].
		    ZBJ_OUTSIDE_APERTURE_DIA >
		    ZBA_SURFACE [SurfaceOrdinal].
		    ZBK_INSIDE_APERTURE_DIA) THEN
		  BEGIN
		  END
		ELSE
		  F01AK_APERTURE_ERROR := TRUE;
	    IF F01AK_APERTURE_ERROR THEN
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  Inconsistent apertures detected' +
		    ' for surface ' + IntToStr (SurfaceOrdinal) + '.');
		NoErrors := FALSE
	      END
	  END
      END;

  IF NoErrors THEN
    BEGIN
      U070_FILL_IN_LAMBDAS_AND_INDICES (ALP_OUT_OF_ROOM_IN_MINI_CAT,
	  NoErrors);
      IF ALP_OUT_OF_ROOM_IN_MINI_CAT THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ERROR:  Failure in updating on-line mini glass catalog.');
          CommandIOMemo.IOHistory.Lines.add
              ('Too many glass materials and/or wavelengths were specified.');
	  NoErrors := FALSE
	END
      ELSE
      IF NOT NoErrors THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ERROR:  Failure in updating on-line mini glass catalog.');
          CommandIOMemo.IOHistory.Lines.add
              ('Possible causes of this error are:');
          CommandIOMemo.IOHistory.Lines.add
              ('  1.  The specified glass name was not found in the' +
              ' glass catalog.');
          CommandIOMemo.IOHistory.Lines.add
              ('  2.  A gradient index material was referenced' +
              ' directly, rather than');
          CommandIOMemo.IOHistory.Lines.add
              ('      indirectly by an alias.  Use' +
              ' the G(lass command');
          CommandIOMemo.IOHistory.Lines.add
              ('      to establish an alias for this material.')
	END
    END;
    
  IF NoErrors THEN
    IF ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED THEN
      BEGIN
	NoErrors := FALSE;
	J := 1;
	REPEAT
	  BEGIN
	    IF ZFA_OPTION.ZGK_DESIGNATED_SURFACE =
		ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] THEN
	      NoErrors := TRUE
	    ELSE
	      J := J + 1
	  END
	UNTIL
	  NoErrors
	  OR (J > ARL_SEQUENCER_HI_INDEX);
	IF NoErrors THEN
	  BEGIN
	    IF NOT (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER > 1.0E-12) THEN
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('ERROR: Cannot obtain diameter for designated' +
		    ' image surface ' +
		    IntToStr (ZFA_OPTION.ZGK_DESIGNATED_SURFACE) + '.');
                NoErrors := FALSE
	      END
	  END
	ELSE
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('ERROR: Designated image surface ' +
		IntToStr (ZFA_OPTION.ZGK_DESIGNATED_SURFACE) +
		' not in sequence table.');
	    NoErrors := FALSE
	  END
      END
    ELSE
      IF ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM
  	  OR ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE
	  OR ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST
	  OR ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST THEN
        BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ERROR: You have selected one or more trace options');
	  CommandIOMemo.IOHistory.Lines.add
              ('which cannot be executed without a designated image');
	  CommandIOMemo.IOHistory.Lines.add ('surface.');
	  NoErrors := FALSE
        END;

  IF ZFA_OPTION.DRAW_RAYS THEN
    IF ZFA_OPTION.ZGL_VIEWPORT_DIAMETER < 1.0E-12 THEN
      BEGIN
        CommandIOMemo.IOHistory.Lines.add ('');
        CommandIOMemo.IOHistory.Lines.add
            ('ERROR:  The viewport diameter must be greater than zero.');
        NoErrors := FALSE
      END;

  IF NoErrors THEN
    IF ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
      BEGIN
        ASA_OUTRAY_BLOCK_SLOT := 2;
        ASB_OUTRAY_BLOCK_NMBR := 0;
        ASC_OUTPUT_RAY_COUNT := 0;
        NoErrors := FALSE;
        J := 1;
        REPEAT
	  BEGIN
	    IF ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE =
	        ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] THEN
	      NoErrors := TRUE
	    ELSE
	      J := J + 1
	  END
        UNTIL
	  NoErrors
	  OR (J > ARL_SEQUENCER_HI_INDEX);
        IF NoErrors THEN
        ELSE
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('FATAL ERROR:  Reference surface for production of');
	    CommandIOMemo.IOHistory.Lines.add
                ('alternate ray file not in sequence table.');
	    NoErrors := FALSE
	  END
      END;
    
  IF NoErrors THEN
    FOR I := 1 TO CZBG_CHARS_IN_ONE_BLOCK DO
      F01ZDF_BLOCK_INITIALIZER.ZXD_ALL_BLOCK_DATA [I] := CHR (0);
      
  IF NoErrors THEN
    IF ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE THEN
      BEGIN
	ASSIGN (ZAI_INTERCEPT_WORK_FILE,
	    ZFA_OPTION.ZGO_ALT_INPUT_RAY_FILE_NAME);
	{$I-}
	RESET (ZAI_INTERCEPT_WORK_FILE, CZBG_CHARS_IN_ONE_BLOCK);
	{$I+}
	SaveIOResult := IORESULT;
	IF SaveIOResult <> 0 THEN
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('FATAL ERROR:  Could not reset alternate ray');
	    CommandIOMemo.IOHistory.Lines.add ('file "' +
		ZFA_OPTION.ZGO_ALT_INPUT_RAY_FILE_NAME + '" at F01.1.');
	    CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
                IntToStr (SaveIOResult) + '.');
	    NoErrors := FALSE
	  END
	ELSE
	  BEGIN
	    INTERCEPT_WORK_FILE_OPEN := TRUE;
	    X15_REWIND_AND_READ_INTRCPT (NoErrors);
	    AAA_TOTAL_RAYS_TO_TRACE :=
		ZSA_SURFACE_INTERCEPTS.ZSJ_TOTAL_RAYS_TO_TRACE;
	    IF AAA_TOTAL_RAYS_TO_TRACE > 0 THEN
	    ELSE
	      BEGIN
	        INTERCEPT_WORK_FILE_OPEN := FALSE;
		CLOSE (ZAI_INTERCEPT_WORK_FILE);
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  No rays available to trace at F01.2.');
		NoErrors := FALSE
	      END
	  END
      END
    ELSE
      BEGIN
	F01AL_FIRST_RAY_FOUND := FALSE;
	AAA_TOTAL_RAYS_TO_TRACE := 0;
	FOR RayOrdinal := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
	  IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED
	      AND ZNA_RAY [RayOrdinal].ZNC_ACTIVE THEN
	    BEGIN
	      RAY0.X := ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE;
	      RAY0.Y := ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE;
	      RAY0.Z := ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE;
	      RAY1.X := ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE;
	      RAY1.Y := ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE;
	      RAY1.Z := ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE;
	      F01AJ_RAY_MAGNITUDE :=
		  SQRT ((RAY1.X - RAY0.X) * (RAY1.X - RAY0.X) +
		  (RAY1.Y - RAY0.Y) * (RAY1.Y - RAY0.Y) +
		  (RAY1.Z - RAY0.Z) * (RAY1.Z - RAY0.Z));
	      IF F01AJ_RAY_MAGNITUDE < 1.0E-12 THEN
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                      ('FATAL ERROR:  User-specified ray ' +
		      IntToStr (RayOrdinal) + ' has 0 magnitude.');
		  NoErrors := FALSE
		END;
	      IF NoErrors THEN
	        IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS THEN
	          IF (ZNA_RAY [RayOrdinal].SIGMA_X_HEAD = 0.0)
	              OR (ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD = 0.0)
		      OR (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL = 0.0)
		      OR (ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL = 0.0) THEN
	            BEGIN
	              WRITELN;
		      WRITELN ('FATAL ERROR:  Ray ', RayOrdinal,
                          ' Gaussian ray bundle has zero width and/or',
		          ' height.');
		      NoErrors := FALSE
	            END;
              IF NoErrors THEN
                IF ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS THEN
                  IF ZNA_RAY [RayOrdinal].MinZenithDistance >
                      ZNA_RAY [RayOrdinal].MaxZenithDistance THEN
                    BEGIN
		      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                          ('FATAL ERROR:  Ray ' + IntToStr (RayOrdinal) +
                          ' Lambertian ray bundle has inconsistent values for' +
                          ' the minimum and maximum zenith distance.');
                      NoErrors := FALSE
                    END;
	      ADA_LAST_RAY := RayOrdinal;
	      AAA_TOTAL_RAYS_TO_TRACE := AAA_TOTAL_RAYS_TO_TRACE + 1 +
		  ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle;
	      IF F01AL_FIRST_RAY_FOUND THEN
	      ELSE
		F01AL_FIRST_RAY_FOUND := TRUE
	    END;
	IF AAA_TOTAL_RAYS_TO_TRACE = 0 THEN
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('FATAL ERROR:  No rays available to trace.');
	    NoErrors := FALSE
	  END;
	IF NoErrors THEN
	  BEGIN
	    F01BD_WORK_FILE_NAME := 'TEMPXXX.DAT';
	    ASSIGN (ZAI_INTERCEPT_WORK_FILE, F01BD_WORK_FILE_NAME);
	    {$I-}
	    REWRITE (ZAI_INTERCEPT_WORK_FILE, CZBG_CHARS_IN_ONE_BLOCK);
	    {$I+}
	    SaveIOResult := IORESULT;
	    IF SaveIOResult <> 0 THEN
	      BEGIN
	        INTERCEPT_WORK_FILE_OPEN := FALSE;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('FATAL ERROR:  Could not create intercept');
		CommandIOMemo.IOHistory.Lines.add ('work file "' +
                    F01BD_WORK_FILE_NAME + '" at F01.3.');
		CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
                    IntToStr (SaveIOResult) + '.');
		NoErrors := FALSE
	      END
	    ELSE
	      BEGIN
	        INTERCEPT_WORK_FILE_OPEN := TRUE;
		ZZA_INTERCEPT_DATA_BLOCK := F01ZDF_BLOCK_INITIALIZER;
		ARP_INTRCPT_BLOCK_SLOT := 1;
		ARQ_INTRCPT_BLOCK_NMBR := 0
	      END
	  END
      END;

  IF NoErrors THEN
    IF ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
	BEGIN
	  F01BD_WORK_FILE_NAME := ZFA_OPTION.ZGQ_ALT_OUTPUT_RAY_FILE_NAME;
	  ASSIGN (ZAL_OUTPUT_RAY_FILE, F01BD_WORK_FILE_NAME);
	  {$I-}
	  REWRITE (ZAL_OUTPUT_RAY_FILE, CZBG_CHARS_IN_ONE_BLOCK);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('FATAL ERROR:  Could not create alternate ray');
	      CommandIOMemo.IOHistory.Lines.add
                  ('file "' + F01BD_WORK_FILE_NAME + '" at F01.4.');
	      CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
                  IntToStr (SaveIOResult) + '.');
	      NoErrors := FALSE
	    END
	  ELSE
	    BEGIN
	      OUTPUT_RAY_FILE_OPEN := TRUE;
	      ZZC_OUTRAY_DATA_BLOCK := F01ZDF_BLOCK_INITIALIZER;
	      ASA_OUTRAY_BLOCK_SLOT := 2;
	      ASB_OUTRAY_BLOCK_NMBR := 0
	    END
	END;
      
  IF NoErrors THEN
    BEGIN
      F01BD_WORK_FILE_NAME := 'TEMPXXZ.DAT';
      ASSIGN (ZAK_RECURS_INTERCEPT_WORK_FILE, F01BD_WORK_FILE_NAME);
      {$I-}
      REWRITE (ZAK_RECURS_INTERCEPT_WORK_FILE, CZBG_CHARS_IN_ONE_BLOCK);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('FATAL ERROR:  Could not create ray work');
	  CommandIOMemo.IOHistory.Lines.add
              ('file "' + F01BD_WORK_FILE_NAME + '" at F01.5.');
	  CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
              IntToStr (SaveIOResult) + '.');
	  NoErrors := FALSE
	END
      ELSE
	BEGIN
	  RECURS_INTERCEPT_WORK_FILE_OPEN := TRUE;
	  ZZB_RECURS_INTERCEPT_DATA_BLOCK := F01ZDF_BLOCK_INITIALIZER;
	  ARC_RECURS_INT_BLOCK_SLOT := 1;
	  ARW_RECURS_INT_BLOCK_NMBR := 0
	END
    END;

  IF NoErrors THEN
    BEGIN
      IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE
	  OR ZFA_OPTION.ZGF_DISPLAY_FULL_OPD
	  OR ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
	BEGIN
	  F01BD_WORK_FILE_NAME := 'TEMPXXY.DAT';
	  ASSIGN (ZAJ_DIFFRACT_WORK_FILE, F01BD_WORK_FILE_NAME);
	  {$I-}
	  REWRITE (ZAJ_DIFFRACT_WORK_FILE, CZBG_CHARS_IN_ONE_BLOCK);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('FATAL ERROR:  Could not create diffraction');
	      CommandIOMemo.IOHistory.Lines.add
                  ('work file "' + F01BD_WORK_FILE_NAME + '" at F01.6.');
	      CommandIOMemo.IOHistory.Lines.add ('IORESULT is ' +
                  IntToStr (SaveIOResult) + '.');
	      NoErrors := FALSE
	    END
	  ELSE
	    BEGIN
	      DIFFRACT_WORK_FILE_OPEN := TRUE;
	      ZYA_DIFFRACTION_DATA_BLOCK := F01ZDF_BLOCK_INITIALIZER;
	      ARR_DIFF_BLOCK_SLOT := 1;
	      ARS_DIFF_BLOCK_NMBR := 0;
	      ARO_DIFF_RECORD_COUNT := 0
	    END
	END
    END;

  IF NoErrors THEN
    BEGIN
      IF ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER THEN
	BEGIN
	  AssignPrn (ZAF_PRINT_FILE);
	  {$I-}
	  REWRITE (ZAF_PRINT_FILE);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('ERROR: Could not bring printer on-line, at F01.7.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Printer output is now disabled.');
	      ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER := FALSE;
	      Q970AB_OUTPUT_STRING :=
		  'Do you wish to continue with listing to CONSOLE?  (Y or N)';
	      Q970_REQUEST_PERMIT_TO_PROCEED;
	      IF NOT Q970AA_OK_TO_PROCEED THEN
		NoErrors := FALSE
	    END
	  ELSE
	    PRINT_FILE_OPEN := TRUE
	END;
      IF ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE THEN
	BEGIN
	  F01BD_WORK_FILE_NAME := ZFA_OPTION.ZGB_TRACE_DETAIL_FILE;
	  ASSIGN (ZAG_LIST_FILE, F01BD_WORK_FILE_NAME);
	  {$I-}
	  REWRITE (ZAG_LIST_FILE);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('ERROR: Could not create file "' + F01BD_WORK_FILE_NAME +
                  '" at F01.8.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('IORESULT is ' + IntToStr (SaveIOResult) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('List file output is now disabled.');
	      ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE := FALSE;
	      Q970AB_OUTPUT_STRING :=
		  'Do you wish to continue with listing to CONSOLE?  (Y or N)';
	      Q970_REQUEST_PERMIT_TO_PROCEED;
	      IF NOT Q970AA_OK_TO_PROCEED THEN
		NoErrors := FALSE
	    END
	  ELSE
	    BEGIN
	      LIST_FILE_OPEN := TRUE;
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Writing trace detail output to file "' +
		  ZFA_OPTION.ZGB_TRACE_DETAIL_FILE + '"...')
	    END
	END
    END

END;




(**  F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES  ********************************
******************************************************************************)


PROCEDURE F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal : INTEGER);

    VAR
      HOLD_X0			   : DOUBLE;
      HOLD_Y0			   : DOUBLE;
      HOLD_Z0			   : DOUBLE;
      HOLD_X1			   : DOUBLE;
      HOLD_Y1			   : DOUBLE;
      HOLD_Z1			   : DOUBLE;
      DELTA_X			   : DOUBLE;
      DELTA_Y			   : DOUBLE;
      DELTA_Z			   : DOUBLE;
      INCIDENT_RAY_MAGNITUDE	   : DOUBLE;

BEGIN

  IF COORDINATE_ROTATION_NEEDED THEN
    BEGIN
      (* Rotate head of computed light ray. *)
      HOLD_X1 := ZSA_SURFACE_INTERCEPTS.ZSE_X1;
      HOLD_Y1 := ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
      HOLD_Z1 := ZSA_SURFACE_INTERCEPTS.ZSG_Z1;
      ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
	  (RayRotationMatrix.T11 * HOLD_X1) +
          (RayRotationMatrix.T12 * HOLD_Y1) +
          (RayRotationMatrix.T13 * HOLD_Z1);
      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
	  (RayRotationMatrix.T21 * HOLD_X1) +
          (RayRotationMatrix.T22 * HOLD_Y1) +
          (RayRotationMatrix.T23 * HOLD_Z1);
      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 :=
	  (RayRotationMatrix.T31 * HOLD_X1) +
          (RayRotationMatrix.T32 * HOLD_Y1) +
          (RayRotationMatrix.T33 * HOLD_Z1)
    END;

  IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
    BEGIN
      (* Translate head of computed light ray. *)
      ZSA_SURFACE_INTERCEPTS.ZSE_X1 := ZSA_SURFACE_INTERCEPTS.ZSE_X1 + X0;
      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 + Y0;
      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 + Z0
    END
  ELSE
  IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS
      OR ZNA_RAY [RayOrdinal].TraceOrangeSliceRays
      OR ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS THEN
    BEGIN
      IF COORDINATE_ROTATION_NEEDED THEN
        BEGIN
          (* Rotate tail of computed light ray. *)
	  HOLD_X0 := X0;
	  HOLD_Y0 := Y0;
	  HOLD_Z0 := Z0;
	  X0 := (RayRotationMatrix.T11 * HOLD_X0) +
              (RayRotationMatrix.T12 * HOLD_Y0) +
              (RayRotationMatrix.T13 * HOLD_Z0);
	  Y0 := (RayRotationMatrix.T21 * HOLD_X0) +
              (RayRotationMatrix.T22 * HOLD_Y0) +
              (RayRotationMatrix.T23 * HOLD_Z0);
	  Z0 := (RayRotationMatrix.T31 * HOLD_X0) +
              (RayRotationMatrix.T32 * HOLD_Y0) +
              (RayRotationMatrix.T33 * HOLD_Z0)
	END;
      (* Translate head of computed light ray. *)
      ZSA_SURFACE_INTERCEPTS.ZSE_X1 := ZSA_SURFACE_INTERCEPTS.ZSE_X1 +
	  ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE;
      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 +
	  ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE;
      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 +
	  ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE;
      (* Translate tail of computed light ray. *)
      IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS THEN
        BEGIN
          X0 := X0 + ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE;
          Y0 := Y0 + ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE;
          Z0 := Z0 + ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE
        END
      ELSE
        BEGIN
          X0 := X0 + ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE;
          Y0 := Y0 + ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE;
          Z0 := Z0 + ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE
        END
    END
  ELSE
    BEGIN
      (* Translate head of computed light ray. *)
      ZSA_SURFACE_INTERCEPTS.ZSE_X1 := ZSA_SURFACE_INTERCEPTS.ZSE_X1 +
	  ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE;
      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 +
	  ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE;
      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 +
	  ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE
    END;

  IF ParallelLightExists THEN
    BEGIN
      ZSA_SURFACE_INTERCEPTS.ZSB_A1 := A1;
      ZSA_SURFACE_INTERCEPTS.ZSC_B1 := B1;
      ZSA_SURFACE_INTERCEPTS.ZSD_C1 := C1
    END
  ELSE
    BEGIN
      DELTA_X := ZSA_SURFACE_INTERCEPTS.ZSE_X1 - X0;
      DELTA_Y := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 - Y0;
      DELTA_Z := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 - Z0;
      INCIDENT_RAY_MAGNITUDE := SQRT (DELTA_X * DELTA_X +
	  DELTA_Y * DELTA_Y + DELTA_Z * DELTA_Z);
      ZSA_SURFACE_INTERCEPTS.ZSB_A1 := DELTA_X / INCIDENT_RAY_MAGNITUDE;
      ZSA_SURFACE_INTERCEPTS.ZSC_B1 := DELTA_Y / INCIDENT_RAY_MAGNITUDE;
      ZSA_SURFACE_INTERCEPTS.ZSD_C1 := DELTA_Z / INCIDENT_RAY_MAGNITUDE
    END

END;




(**  F05_INITIALIZE_FOR_TRACE  ************************************************
******************************************************************************)


PROCEDURE F05_INITIALIZE_FOR_TRACE;

  CONST
      CELL_BASE = 0.0944911182;
      CELL_HEIGHT = 0.0818317088;
      PARALLEL_LIGHT_MIN_F_NUMBER  = 9.9999E9;

  VAR
      ADD_CELL_OFFSET		   : BOOLEAN;
      F05AB_COMPUTED_RAYS_EXIST	   : BOOLEAN;

      POINTS_IN_CIRCLE		   : INTEGER;
      LoopControl                  : INTEGER;

      U				   : DOUBLE;
      V				   : DOUBLE;
      W				   : DOUBLE;
      OD			   : DOUBLE;
      ID			   : DOUBLE;
      SAG			   : DOUBLE;
      UNDER_RADICAL		   : DOUBLE;
      ROLL			   : DOUBLE;
      PITCH			   : DOUBLE;
      YAW			   : DOUBLE;
      COS_R			   : DOUBLE;
      SIN_R			   : DOUBLE;
      COS_P			   : DOUBLE;
      SIN_P			   : DOUBLE;
      COS_Y			   : DOUBLE;
      SIN_Y			   : DOUBLE;
      RING_WIDTH_ACCUM		   : DOUBLE;
      WIDTH_PER_RING		   : DOUBLE;
      RING_AREA_ACCUM		   : DOUBLE;
      AREA_PER_RING		   : DOUBLE;
      DELTA_X			   : DOUBLE;
      DELTA_Y			   : DOUBLE;
      DELTA_Z			   : DOUBLE;
      PRINCIPAL_RAY_MAGNITUDE	   : DOUBLE;
      MAG			   : DOUBLE;
      ANGLE_STEP		   : DOUBLE;
      ANGLE			   : DOUBLE;
      CIRCLE_RADIUS		   : DOUBLE;
      MAX_X			   : DOUBLE;
      X				   : DOUBLE;
      Y				   : DOUBLE;
      F_NUMBER			   : DOUBLE;
      COS_ZENITH_DISTANCE	   : DOUBLE;
      SIN_ZENITH_DISTANCE	   : DOUBLE;
      CenterPitch                  : DOUBLE;
      DeltaPitch                   : DOUBLE;
      WorkPitch                    : DOUBLE;
      CosAzprime                   : DOUBLE;
      Azprime                      : DOUBLE;
      xprime                       : DOUBLE;
      yprime                       : DOUBLE;
      zprime                       : DOUBLE;
      DirCosX                      : DOUBLE;
      DirCosY                      : DOUBLE;
      DirCosZ                      : DOUBLE;
      TempEl                       : DOUBLE;
      DeltaEl                      : DOUBLE;
      El                           : DOUBLE;
      MAX_SOLID_ANGLE		   : DOUBLE;
      MinSolidAngle                : DOUBLE;
      RADIUS			   : DOUBLE;
      COS_RAND_RAY_DIV_ANGLE	   : DOUBLE;
      COS_BEAM_DIVERGE_HALF_ANGLE  : DOUBLE;


(**  F0505_GENERATE_COMPUTED_RAYS  ********************************************
******************************************************************************)


PROCEDURE F0505_GENERATE_COMPUTED_RAYS;

  VAR
      TailIsGaussian             : BOOLEAN;
      ApplyAstigmaticCorrection  : BOOLEAN;

      J                          : INTEGER;
      K                          : INTEGER;
      L                          : INTEGER;
      MaxRows                    : INTEGER;
      MaxColumns                 : INTEGER;
      StopRow                    : INTEGER;
      StopColumn                 : INTEGER;

      RayCounter                 : LONGINT;
      I                          : LONGINT;

      Fraction                   : DOUBLE;
      Range                      : DOUBLE;
      Azimuth                    : DOUBLE;
      TailSemiMajorAxis          : DOUBLE;
      AstigmaticCorrection       : DOUBLE;
      StartGridX                 : DOUBLE;
      RodRadius                  : DOUBLE;
      RodLength                  : DOUBLE;
      TailX                      : DOUBLE;
      TailY                      : DOUBLE;
      TailZ                      : DOUBLE;
      ZenithDistance             : DOUBLE;
      ElevationAngle             : DOUBLE;
      AzimuthAngle               : DOUBLE;
      HeadX                      : DOUBLE;
      HeadY                      : DOUBLE;
      HeadZ                      : DOUBLE;
      AN                         : DOUBLE;
      BN                         : DOUBLE;
      CN                         : DOUBLE;
      M11                        : DOUBLE;
      M12                        : DOUBLE;
      M13                        : DOUBLE;
      M21                        : DOUBLE;
      M22                        : DOUBLE;
      M23                        : DOUBLE;
      M31                        : DOUBLE;
      M32                        : DOUBLE;
      M33                        : DOUBLE;
      MagX                       : DOUBLE;
      MagY                       : DOUBLE;
      MagZ                       : DOUBLE;
      TempX                      : DOUBLE;
      TempY                      : DOUBLE;
      TempZ                      : DOUBLE;
      GridPointX                 : DOUBLE;
      GridPointY                 : DOUBLE;
      GridSpacing                : DOUBLE;
      X                          : DOUBLE;
      Y                          : DOUBLE;
      HoldX                      : DOUBLE;
      HoldY                      : DOUBLE;
      HoldZ                      : DOUBLE;
      HoldAzimuth                : DOUBLE;

(** GetAstigmatism *********************************************************
***************************************************************************)

PROCEDURE GetAstigmatism;

BEGIN

  IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS THEN
    BEGIN
      ApplyAstigmaticCorrection := TRUE;
      (* Compute the semimajor axis of the tail of the
      Gaussian ray bundle, at the 1/e^2 isophote (i.e.,
      at 2 sigma). *)
      IF ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN THEN
        IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN THEN
          IF ZNA_RAY [RayOrdinal].SIGMA_X_TAIL >
              ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL THEN
            TailSemiMajorAxis := 2.0 * ZNA_RAY [RayOrdinal].SIGMA_X_TAIL
          ELSE
            TailSemiMajorAxis := 2.0 * ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL
        ELSE
          TailSemiMajorAxis := 2.0 * ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL
      ELSE
      IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN THEN
        TailSemiMajorAxis := 2.0 * ZNA_RAY [RayOrdinal].SIGMA_X_TAIL
      ELSE
        ApplyAstigmaticCorrection := FALSE;
      IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN
          AND ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN THEN
        TailIsGaussian := TRUE
      ELSE
        TailIsGaussian := FALSE
    END;

END;



(**  F0505_GENERATE_COMPUTED_RAYS  ********************************************
******************************************************************************)


BEGIN

  ZSA_SURFACE_INTERCEPTS.ZSJ_TOTAL_RAYS_TO_TRACE :=
      AAA_TOTAL_RAYS_TO_TRACE;

  RayCounter := 0;

  X05_SIMPLE_WRITE_INTRCPT (NoErrors);

  FOR L := 1 TO ADA_LAST_RAY DO
    IF (ZNA_RAY [L].ZNB_SPECIFIED
	AND ZNA_RAY [L].ZNC_ACTIVE) THEN
      BEGIN
        RayOrdinal := L;
	ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
	    ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE;
	ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
	    ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE;
	ZSA_SURFACE_INTERCEPTS.ZSG_Z1 :=
	    ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE;
	X0 := ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE;
	Y0 := ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE;
	Z0 := ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE;
	DELTA_X := ZSA_SURFACE_INTERCEPTS.ZSE_X1 - X0;
	DELTA_Y := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 - Y0;
	DELTA_Z := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 - Z0;
	PRINCIPAL_RAY_MAGNITUDE := SQRT (DELTA_X * DELTA_X +
	    DELTA_Y * DELTA_Y + DELTA_Z * DELTA_Z);
	A1 := DELTA_X / PRINCIPAL_RAY_MAGNITUDE;
	B1 := DELTA_Y / PRINCIPAL_RAY_MAGNITUDE;
	C1 := DELTA_Z / PRINCIPAL_RAY_MAGNITUDE;
	ZSA_SURFACE_INTERCEPTS.ZSB_A1 := A1;
	ZSA_SURFACE_INTERCEPTS.ZSC_B1 := B1;
	ZSA_SURFACE_INTERCEPTS.ZSD_C1 := C1;
	ZSA_SURFACE_INTERCEPTS.ZSL_WAVELENGTH :=
	    ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH;
	(* A negative value of refractive index indicates principal ray. *)
	ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := -1.0 *
	    ZNA_RAY [RayOrdinal].ZNK_INCIDENT_MEDIUM_INDEX;
	(* Ray begins life with an intensity of 1.0 *)
        ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY := 1.0;
	X05_SIMPLE_WRITE_INTRCPT (NoErrors);
        RayCounter := RayCounter + 1;
	(* Restore positive value of ref. index for computed rays. *)
	ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := -1.0 *
	    ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX;
        IF (ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN
            OR ZNA_RAY [RayOrdinal].TraceLinearXFan
            OR ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN
            OR ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN
            OR ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN
            OR ZNA_RAY [RayOrdinal].TraceSquareGrid
            OR ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE
            OR ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE
            OR ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS
            OR ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS
            OR ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS
            OR ZNA_RAY [RayOrdinal].TraceOrangeSliceRays
            OR ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS) THEN
          F05AB_COMPUTED_RAYS_EXIST := TRUE
        ELSE
          F05AB_COMPUTED_RAYS_EXIST := FALSE;
	IF F05AB_COMPUTED_RAYS_EXIST THEN
	  BEGIN
            BHR := ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER / 2;
	    F_NUMBER := PRINCIPAL_RAY_MAGNITUDE /
		ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER;
	    ParallelLightExists := FALSE;
	    IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS
	        OR ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS
                OR ZNA_RAY [RayOrdinal].TraceOrangeSliceRays
                OR ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS THEN
	    ELSE
	      IF F_NUMBER >= PARALLEL_LIGHT_MIN_F_NUMBER THEN
		ParallelLightExists := TRUE;
	    COORDINATE_ROTATION_NEEDED := FALSE;
	    IF C1 < 1.0 THEN
	      BEGIN
		COORDINATE_ROTATION_NEEDED := TRUE;
		IF ABS (A1) < ROOT_3_OVER_3 THEN
		  BEGIN
		    MAG := SQRT (SQR (B1) + SQR (C1));
		    RayRotationMatrix.T11 := MAG;
		    RayRotationMatrix.T12 := 0.0;
		    RayRotationMatrix.T13 := A1;
		    RayRotationMatrix.T21 := -1.0 * A1 * B1 / MAG;
		    RayRotationMatrix.T22 := C1 / MAG;
		    RayRotationMatrix.T23 := B1;
		    RayRotationMatrix.T31 := -1.0 * A1 * C1 / MAG;
		    RayRotationMatrix.T32 := -1.0 * B1 / MAG;
		    RayRotationMatrix.T33 := C1
		  END
		ELSE
		IF ABS (B1) <= ABS (C1) THEN
		  BEGIN
		    MAG := SQRT (SQR (A1) + SQR (C1));
		    RayRotationMatrix.T11 := C1 / MAG;
		    RayRotationMatrix.T12 := -1.0 * A1 * B1 / MAG;
		    RayRotationMatrix.T13 := A1;
		    RayRotationMatrix.T21 := 0.0;
		    RayRotationMatrix.T22 := MAG;
		    RayRotationMatrix.T23 := B1;
		    RayRotationMatrix.T31 := -1.0 * A1 / MAG;
		    RayRotationMatrix.T32 := -1.0 * B1 * C1 / MAG;
		    RayRotationMatrix.T33 := C1
		  END
		ELSE
		  BEGIN
		    MAG := SQRT (SQR (A1) + SQR (B1));
		    RayRotationMatrix.T11 := A1 * C1 / MAG;
		    RayRotationMatrix.T12 := -1.0 * B1 / MAG;
		    RayRotationMatrix.T13 := A1;
		    RayRotationMatrix.T21 := B1 * C1 / MAG;
		    RayRotationMatrix.T22 := A1 / MAG;
		    RayRotationMatrix.T23 := B1;
		    RayRotationMatrix.T31 := -1.0 * MAG;
		    RayRotationMatrix.T32 := 0.0;
		    RayRotationMatrix.T33 := C1
		  END
	      END;
	    IF ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN THEN
	      BEGIN
		RING_AREA_ACCUM := 1.0;
		AREA_PER_RING := 2 / ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle;
		FOR I := 1 TO
                    ((ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle + 1) DIV 2) DO
		  BEGIN
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
			SQRT (RING_AREA_ACCUM) * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := -1.0 *
			(SQRT (RING_AREA_ACCUM) * BHR);
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    RING_AREA_ACCUM := RING_AREA_ACCUM - AREA_PER_RING
		  END
	      END
	    ELSE
	    IF ZNA_RAY [RayOrdinal].TraceLinearXFan THEN
	      BEGIN
		RING_WIDTH_ACCUM := 1.0;
		WIDTH_PER_RING := 2.0 / ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle;
		FOR I := 1 TO
                    ((ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle + 1) DIV 2) DO
		  BEGIN
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
			RING_WIDTH_ACCUM * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
                        RING_WIDTH_ACCUM * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := -1.0 *
			RING_WIDTH_ACCUM * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    RING_WIDTH_ACCUM := RING_WIDTH_ACCUM - WIDTH_PER_RING
		  END
	      END
	    ELSE
	    IF ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN THEN
	      BEGIN
		RING_WIDTH_ACCUM := 1.0;
		WIDTH_PER_RING := 2.0 / ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle;
		FOR I := 1 TO
                    ((ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle + 1) DIV 2) DO
		  BEGIN
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
			RING_WIDTH_ACCUM * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := -1.0 *
			RING_WIDTH_ACCUM * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    RING_WIDTH_ACCUM := RING_WIDTH_ACCUM - WIDTH_PER_RING
		  END
	      END
	    ELSE
	    IF ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN THEN
	      BEGIN
		RING_AREA_ACCUM := 1.0;
		AREA_PER_RING := 1.0 / ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle;
		FOR I := 1 TO ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle DO
		  BEGIN
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
			SQRT (RING_AREA_ACCUM) * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    RING_AREA_ACCUM := RING_AREA_ACCUM - AREA_PER_RING
		  END
	      END
	    ELSE
	    IF ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN THEN
	      BEGIN
		ANGLE_STEP := (2.0 * PI) / 3.0;
		ANGLE := PI / 6.0;
		RING_AREA_ACCUM := 1.0;
		AREA_PER_RING := 1.0 / ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle;
		FOR I := 1 TO ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle DO
		  BEGIN
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := COS (ANGLE) *
			SQRT (RING_AREA_ACCUM) * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := SIN (ANGLE) *
			SQRT (RING_AREA_ACCUM) * BHR;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    ANGLE := ANGLE + ANGLE_STEP;
		    RING_AREA_ACCUM := RING_AREA_ACCUM - AREA_PER_RING
		  END
	      END
	    ELSE
            IF ZNA_RAY [RayOrdinal].TraceSquareGrid THEN
              BEGIN
                (* This is temporary code for generation of rays from a rod
                   which acts as a Lambertian source.  The rod length is
                   aligned with the x-axis. *)
                RodRadius := 0.375;
                RodLength := 12.0;
                FOR I := 1 TO ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle DO
		  BEGIN
                    (* Choose azimuth position at random on circumference of
                       rod for tail of light ray. *)
                    RANDGEN;
                    Azimuth := RANDOM * 2.0 * PI;
                    (* Convert to (y,z) coordinates on circumference of rod. *)
                    TailZ := RodRadius * cos (Azimuth);
                    TailY := RodRadius * sin (Azimuth);
                    (* Choose random position (x) along length of rod. *)
                    RANDGEN;
                    TailX := (1.0 - 2.0 * RANDOM) * 0.5 * RodLength;
                    (* Choose random postion (x,y,z) of head of light ray on
                       unit hemisphere.  The direction of the head of the light
                       ray will be chosen according to Lambert's law. *)
                    RANDGEN;
                    ZenithDistance := ArcCos (Power (RANDOM, 0.25));
                    ElevationAngle := (pi / 2.0) - ZenithDistance;
                    RANDGEN;
                    AzimuthAngle := (1.0 - 2.0 * RANDOM) * Pi;
                    HeadX := cos (ElevationAngle) * cos (AzimuthAngle);
                    HeadY := cos (ElevationAngle) * sin (AzimuthAngle);
                    HeadZ := sin (ElevationAngle);
                    (* Find surface normal vector at point (x,y,z) on surface
                       of rod. *)
                    AN := 0.0;
                    BN := TailY;
                    CN := TailZ;
                    MAG := SQRT (BN * BN + CN * CN);
                    BN := BN / Mag;
                    CN := CN / Mag;
                    (* Set up elements of rotation matrix. *)
                    M11 := 1.0;
                    M12 := 0.0;
                    M13 := 0.0;
                    M21 := 0.0;
                    M22 := Cos (Azimuth);
                    M23 := Sin (Azimuth);
                    M31 := 0.0;
                    M32 := -1.0 * Sin (Azimuth);
                    M33 := Cos (Azimuth);
                    (* Rotate head of computed light ray into coordinates
                       represented by surface normal vector. *)
                    TempX := HeadX;
                    TempY := HeadY;
                    TempZ := HeadZ;
                    HeadX := (M11 * TempX) + (M12 * TempY) + (M13 * TempZ);
                    HeadY := (M21 * TempX) + (M22 * TempY) + (M23 * TempZ);
                    HeadZ := (M31 * TempX) + (M32 * TempY) + (M33 * TempZ);
                    (* Translate coordinates of head of light ray into
                       coordinates centered at the tail of the light ray. *)
                    HeadX := HeadX + TailX;
                    HeadY := HeadY + TailY;
                    HeadZ := HeadZ + TailZ;
                    (* Get magnitude of components of rotated, translated
                       vector. *)
                    MagX := HeadX - TailX;
                    MagY := HeadY - TailY;
                    MagZ := HeadZ - TailZ;
                    Mag := Sqrt (Sqr(MagX) + Sqr (MagY) + Sqr (MagZ));
                    ZSA_SURFACE_INTERCEPTS.ZSB_A1 := MagX / Mag;
                    ZSA_SURFACE_INTERCEPTS.ZSC_B1 := MagY / Mag;
                    ZSA_SURFACE_INTERCEPTS.ZSD_C1 := MagZ / Mag;
                    (* Note that the tail of the light ray just computed, is
                       really treated as the head of the light ray.  Translate
                       head of computed light ray into principal ray coords. *)
                    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := TailX +
	                ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE;
                    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := TailY +
	                ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE;
                    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := TailZ +
	                ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE;
                    X05_SIMPLE_WRITE_INTRCPT (NoErrors)
                  END
              END
            (*BEGIN
                (*GridSpacing := BHR / ZNA_RAY [RayOrdinal].NumberOfRings;
                GridPointY := -1 * ZNA_RAY [RayOrdinal].NumberOfRings *
                    GridSpacing;
                StartGridX := GridPointY;
                MaxRows := 2 * ZNA_RAY [RayOrdinal].NumberOfRings + 1;
                MaxColumns := MaxRows;
                StopRow := ZNA_RAY [RayOrdinal].NumberOfRings + 1;
                StopColumn := StopRow;
		FOR J := 1 TO MaxRows DO
                  BEGIN
                    GridPointX := StartGridX;
                    FOR K := 1 TO MaxColumns DO
                      BEGIN
		        IF (J = StopRow)
                            AND (K = StopColumn) THEN
                        ELSE
                          BEGIN
                            ZSA_SURFACE_INTERCEPTS.ZSE_X1 := GridPointX;
		            ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := GridPointY;
		            ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		            F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		            X05_SIMPLE_WRITE_INTRCPT (NoErrors)
                          END;
                        GridPointX := GridPointX + GridSpacing
                      END;
                    GridPointY := GridPointY + GridSpacing
                  END
              END*)
            ELSE
	    IF ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE THEN
	      FOR J := ZNA_RAY [RayOrdinal].
                  NumberOfRings DOWNTO 1 DO
		BEGIN
		  POINTS_IN_CIRCLE := 6 * J;
		  ANGLE_STEP := (2 * PI) / POINTS_IN_CIRCLE;
		  ANGLE := 0.0;
		  CIRCLE_RADIUS := (J / ZNA_RAY [RayOrdinal].
                      NumberOfRings) * BHR;
		  FOR K := 1 TO POINTS_IN_CIRCLE DO
		    BEGIN
		      ANGLE := ANGLE + ANGLE_STEP;
		      ZSA_SURFACE_INTERCEPTS.ZSE_X1 := COS (ANGLE) *
			  CIRCLE_RADIUS;
		      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := SIN (ANGLE) *
			  CIRCLE_RADIUS;
		      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		      F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		      X05_SIMPLE_WRITE_INTRCPT (NoErrors)
		    END
		END
  	    ELSE
	    IF ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE THEN
	      BEGIN
		DELTA_X := CELL_BASE * BHR;
		X := DELTA_X;
		WHILE X <= BHR DO
		  BEGIN
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := X;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := -X;
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors);
		    X := X + DELTA_X
		  END;
		DELTA_Y := CELL_HEIGHT * BHR;
		Y := DELTA_Y;
		ADD_CELL_OFFSET := TRUE;
		WHILE Y <= BHR DO
		  BEGIN
		    MAX_X := SQRT ((BHR * BHR) - (Y * Y));
		    IF ADD_CELL_OFFSET THEN
		      BEGIN
			X := 0.5 * DELTA_X;
			ADD_CELL_OFFSET := FALSE
		      END
		    ELSE
		      BEGIN
			ZSA_SURFACE_INTERCEPTS.ZSE_X1 := 0.0;
			ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := Y;
			ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
			F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
			X05_SIMPLE_WRITE_INTRCPT (NoErrors);
			ZSA_SURFACE_INTERCEPTS.ZSE_X1 := 0.0;
			ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := -Y;
			ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
			F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
			X05_SIMPLE_WRITE_INTRCPT (NoErrors);
			X := DELTA_X;
			ADD_CELL_OFFSET := TRUE
		      END;
		    WHILE X <= MAX_X DO
		      BEGIN
			ZSA_SURFACE_INTERCEPTS.ZSE_X1 := X;
			ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := Y;
			ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
			F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
			X05_SIMPLE_WRITE_INTRCPT (NoErrors);
			ZSA_SURFACE_INTERCEPTS.ZSE_X1 := -X;
			ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := Y;
			ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
			F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
			X05_SIMPLE_WRITE_INTRCPT (NoErrors);
			ZSA_SURFACE_INTERCEPTS.ZSE_X1 := X;
			ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := -Y;
			ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
			F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
			X05_SIMPLE_WRITE_INTRCPT (NoErrors);
			ZSA_SURFACE_INTERCEPTS.ZSE_X1 := -X;
			ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := -Y;
			ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
			F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
			X05_SIMPLE_WRITE_INTRCPT (NoErrors);
			X := X + DELTA_X
		      END;
		    Y := Y + DELTA_Y
		  END
	      END
  	    ELSE
	    IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
	      BEGIN
		MAX_SOLID_ANGLE := 2.0 * PI *
		    (1.0 - COS (ZNA_RAY [RayOrdinal].
                    MaxZenithDistance / ALR_DEGREES_PER_RADIAN));
		FOR I := 1 TO ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle DO
		  BEGIN
		    RANDGEN;
		    Azimuth := RANDOM * 2.0 * PI;
		    RANDGEN;
		    COS_ZENITH_DISTANCE :=
			1.0 - (RANDOM * MAX_SOLID_ANGLE / (2.0 * PI));
		    SIN_ZENITH_DISTANCE :=
			SQRT (1.0 - SQR (COS_ZENITH_DISTANCE));
		    ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
			PRINCIPAL_RAY_MAGNITUDE *
			SIN_ZENITH_DISTANCE * COS (Azimuth);
		    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
			PRINCIPAL_RAY_MAGNITUDE *
			SIN_ZENITH_DISTANCE * SIN (Azimuth);
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 :=
			PRINCIPAL_RAY_MAGNITUDE * COS_ZENITH_DISTANCE;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors)
		  END
	      END
	    ELSE
	    IF ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS THEN
	      BEGIN
		IF F_NUMBER > 5 THEN
		  FOR I := 1 TO ZNA_RAY [RayOrdinal].
                      NumberOfRaysInFanOrBundle DO
		    BEGIN
		      RANDGEN;
		      Azimuth := RANDOM * 2 * PI;
		      RANDGEN;
		      RADIUS := (SQRT (RANDOM)) * BHR;
		      ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
			  RADIUS * COS (Azimuth);
		      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
			  RADIUS * SIN (Azimuth);
		      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		      F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		      X05_SIMPLE_WRITE_INTRCPT (NoErrors)
		    END
		ELSE
		  BEGIN
		    COS_BEAM_DIVERGE_HALF_ANGLE := PRINCIPAL_RAY_MAGNITUDE /
			SQRT (PRINCIPAL_RAY_MAGNITUDE *
			PRINCIPAL_RAY_MAGNITUDE + BHR * BHR);
		    FOR I := 1 TO ZNA_RAY [RayOrdinal].
                        NumberOfRaysInFanOrBundle DO
		      BEGIN
		        RANDGEN;
			COS_RAND_RAY_DIV_ANGLE := 1.0 - RANDOM * (1.0 -
                            COS_BEAM_DIVERGE_HALF_ANGLE);
			RANDGEN;
			Azimuth := RANDOM * 2.0 * PI;
			RADIUS := PRINCIPAL_RAY_MAGNITUDE *
			    SQRT (1.0 - COS_RAND_RAY_DIV_ANGLE *
			    COS_RAND_RAY_DIV_ANGLE);
			ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
			    RADIUS * COS (Azimuth);
			ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
			    RADIUS * SIN (Azimuth);
			ZSA_SURFACE_INTERCEPTS.ZSG_Z1 :=
			    PRINCIPAL_RAY_MAGNITUDE *
			    (COS_RAND_RAY_DIV_ANGLE - 1.0);
			F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
			X05_SIMPLE_WRITE_INTRCPT (NoErrors)
		      END
		  END
	      END
            ELSE
            IF ZNA_RAY [RayOrdinal].TraceOrangeSliceRays THEN
              BEGIN
                CenterPitch :=
                    ZNA_RAY [RayOrdinal].MaxZenithDistance /
                    ALR_DEGREES_PER_RADIAN;
                DeltaPitch :=
                    ZNA_RAY [RayOrdinal].OrangeSliceAngularHalfWidth /
                    ALR_DEGREES_PER_RADIAN;
		FOR I := 1 TO ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle DO
		  BEGIN
                    (* Get coordinates of tail of computed slice ray in
                       "prime" (rotated) coordinate system. *)
                    (* Select a zenith angle at random over the entire 4 pi
                       steradian maximum solid angle. This simply amounts to
                       a random selection on cosine over the range -1 to +1. *)
		    RANDGEN;
                    COS_ZENITH_DISTANCE := 1.0 - 2.0 * RANDOM;
                    IF ABS (COS_ZENITH_DISTANCE) < 1.0E-12 THEN
                      COS_ZENITH_DISTANCE := 1.0E-12;
		    SIN_ZENITH_DISTANCE :=
			SQRT (1.0 - SQR (COS_ZENITH_DISTANCE));
                    (* Select an azimuth angle at random over the slice angular
                       width. *)
                    RANDGEN;
           	    Azimuth := (1.0 - 2.0 * RANDOM) * DeltaPitch;
                    HoldAzimuth := Azimuth;
                    (* Get the (x,y,z) coordinates of the tail of the light
                       ray in the prime coord. system. *)
                    xprime := PRINCIPAL_RAY_MAGNITUDE * SIN_ZENITH_DISTANCE *
                        COS (Azimuth);
                    yprime := PRINCIPAL_RAY_MAGNITUDE * SIN_ZENITH_DISTANCE *
                        SIN (Azimuth);
                    zprime := PRINCIPAL_RAY_MAGNITUDE * COS_ZENITH_DISTANCE;
                    (* Rotate the primed coordinates into a temporary holding
                       coord. system.  This is the same as world coordinates,
                       except that the pitch angle has not been introduced.*)
                    HoldX := zprime;
                    HoldY := yprime;
                    HoldZ := -1.0 * xprime;
                    (* Rotate the primed coordinates of the pitched coord
                       system into world coordinates. *)
                    X0 := HoldX;
                    Y0 := HoldY * cos (CenterPitch) - HoldZ * sin (CenterPitch);
                    Z0 := HoldY * sin (CenterPitch) + HoldZ * cos (CenterPitch);
                    (* Get direction cosines of radius vector for (XO,YO,ZO) *)
                    DirCosX := X0 / PRINCIPAL_RAY_MAGNITUDE;
                    DirCosY := Y0 / PRINCIPAL_RAY_MAGNITUDE;
                    DirCosZ := Z0 / PRINCIPAL_RAY_MAGNITUDE;
                    (* Get head of computed Lambertian ray. *)
		    RANDGEN;
		    Azimuth := RANDOM * 2 * PI;
		    RANDGEN;
                    (* The head of the computed rays populate the BHR
                       with an even density. *)
		    RADIUS := (SQRT (RANDOM)) * BHR;
                    X := RADIUS * COS (Azimuth);
                    Y := RADIUS * SIN (Azimuth);
                    (* Introduce obliquity factor by stretching beam
                    footprint along Y axis *)
                    Y := Y / DirCosZ;
                    (* Rotate elliptical beam footprint so as to be aligned
                    with azimuth of incident ray. *)
                    HoldX := X;
                    HoldY := Y;
                    X := HoldX * Cos (HoldAzimuth) -
                        HoldY * Sin (HoldAzimuth);
                    Y := HoldX * Sin (HoldAzimuth) +
                        HoldY * Cos (HoldAzimuth);
                    IF (Sqrt (Sqr (X) + Sqr (Y)) < BHR) THEN
                      BEGIN
		        ZSA_SURFACE_INTERCEPTS.ZSE_X1 := X;
		        ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := Y;
		        ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		        F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		        X05_SIMPLE_WRITE_INTRCPT (NoErrors);
                        RayCounter := RayCounter + 1
                      END
		  END
              END
            ELSE
            IF ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS THEN
              BEGIN
		MAX_SOLID_ANGLE := 2.0 * PI *
		    (1.0 - COS (ZNA_RAY [RayOrdinal].MaxZenithDistance /
		    ALR_DEGREES_PER_RADIAN));
                MinSolidAngle := 2.0 * PI *
                    (1.0 - COS (ZNA_RAY [RayOrdinal].MinZenithDistance /
                        ALR_DEGREES_PER_RADIAN));
		FOR I := 1 TO ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle DO
		  BEGIN
                    (* Get coordinates of tail of computed Lambertian ray. *)
                    (* Select a zenith angle at random over the specified
                       maximum solid angle. Light rays must arrive with equal
                       probability from annular segments of solid angle
                       containing the same volume. For example, a light ray
                       arriving within a central cone with a zenith angle
                       of 30 degrees must have the same probability as a
                       light ray arriving from an annular cone with a zenith
                       angle ranging from 30 degrees to 42.94 degrees. *)
		    RANDGEN;
                    COS_ZENITH_DISTANCE :=
                        1.0 - (((RANDOM * (MAX_SOLID_ANGLE - MinSolidAngle)) +
                        MinSolidAngle) / (2.0 * PI));
                    IF ABS (COS_ZENITH_DISTANCE) < 1.0E-12 THEN
                      COS_ZENITH_DISTANCE := 1.0E-12;
		    SIN_ZENITH_DISTANCE :=
			SQRT (1.0 - SQR (COS_ZENITH_DISTANCE));
                    (* Select an azimuth angle at random over the user-selected
                       range. *)
                    RANDGEN;
           	    Azimuth := (ZNA_RAY [RayOrdinal].AzimuthAngularCenter +
                        (1.0 - 2.0 * RANDOM) *
                        ZNA_RAY [RayOrdinal].AzimuthAngularSemiLength) /
                        ALR_DEGREES_PER_RADIAN;
                    HoldAzimuth := Azimuth;
                    (* The coordinates of the tail of the computed ray lie
                       on the inside surface of a sphere with a radius equal
                       to the PRINCIPAL_RAY_MAGNITUDE. *)
    		    X0 := PRINCIPAL_RAY_MAGNITUDE *
			SIN_ZENITH_DISTANCE * COS (Azimuth);
		    Y0 := PRINCIPAL_RAY_MAGNITUDE *
			SIN_ZENITH_DISTANCE * SIN (Azimuth);
		    Z0 := -1.0 * PRINCIPAL_RAY_MAGNITUDE *
                        COS_ZENITH_DISTANCE;
                    (* Get head of computed Lambertian ray. *)
  		    RANDGEN;
		    Azimuth := RANDOM * 2 * PI;
		    RANDGEN;
                    (* The head of the computed rays populate the BHR
                       with an even density. *)
  		    RADIUS := (SQRT (RANDOM)) * BHR;
                    X := RADIUS * COS (Azimuth);
                    Y := RADIUS * SIN (Azimuth);
                    (* Introduce obliquity factor by stretching beam
                    footprint along Y axis *)
                    Y := Y / COS_ZENITH_DISTANCE;
                    (* Rotate elliptical beam footprint so as to be aligned
                    with azimuth of incident ray. *)
                    HoldX := X;
                    HoldY := Y;
                    X := HoldX * Cos (HoldAzimuth) -
                        HoldY * Sin (HoldAzimuth);
                    Y := HoldX * Sin (HoldAzimuth) +
                        HoldY * Cos (HoldAzimuth);
                    IF (Sqrt (Sqr (X) + Sqr (Y)) < BHR) THEN
                      BEGIN
		        ZSA_SURFACE_INTERCEPTS.ZSE_X1 := X;
		        ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := Y;
		        ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
		        F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		        X05_SIMPLE_WRITE_INTRCPT (NoErrors);
                        RayCounter := RayCounter + 1
                      END
		  END
              END
	    ELSE
	    IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS THEN(*@*)
	      BEGIN
		FOR I := 1 TO ZNA_RAY [RayOrdinal].
                    NumberOfRaysInFanOrBundle DO
	          BEGIN
		    IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN THEN
	              BEGIN
		        RANDGEN;
                        (* Get random Gaussian-weighted radial distance from
                        peak of unit Gaussian curve (i.e., sigma = 1). *)
      		        Range := SQRT (-2.0 * LN (RANDOM));
                        (* Scale the range by actual value of sigma. *)
                        Range := Range * ZNA_RAY [RayOrdinal].SIGMA_X_TAIL;
		        RANDGEN;
                        (* Get a random azimuth angle. *)
		        Azimuth := 2.0 * PI * RANDOM;
                        (* Define the x coord. of a point at the range and
                        azimuth defined above. *)
		        X0 := Range * Sin (Azimuth)
	              END
		    ELSE
		      BEGIN
		        RANDGEN;
		        X0 := ZNA_RAY [RayOrdinal].SIGMA_X_TAIL *
                            (RANDOM * 2.0 - 1.0)
		      END;
		    IF ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN THEN
	              BEGIN
		        RANDGEN;
      		        Range := SQRT (-2.0 * LN (RANDOM)) *
                            ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL;
		        RANDGEN;
		        Azimuth := 2.0 * PI * RANDOM;
		        Y0 := Range * SIN (Azimuth)
	              END
		    ELSE
		      BEGIN
		        RANDGEN;
		        Y0 := ZNA_RAY [RayOrdinal].
                            SIGMA_Y_TAIL * (RANDOM * 2.0 - 1.0)
		      END;
                    (* Identify isophote containing X0 and Y0 as a fraction
                       of the size of the isophote containing SigmaX
                       and SigmaY.  Both isophotes are assumed to have the
                       same elliptical shape.  Thus, "fraction" is the ratio
                       of the size of the ellipse containing X0 and Y0, to
                       the size of the ellipse containing SigmaX and
                       SigmaY.  *)
                    GetAstigmatism;
                    IF TailIsGaussian THEN
                      Fraction := Sqrt (Sqr (ZNA_RAY [RayOrdinal].
                          SIGMA_X_TAIL) *
                          Sqr (Y0) + Sqr (ZNA_RAY [RayOrdinal].
                          SIGMA_Y_TAIL) *
                          Sqr (X0)) / (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL *
                          ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL);
                    (*  The following statement is placed here for debugging
                        purposes. *)
                    TailIsGaussian := FALSE;
		    IF ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN THEN  (*@*)
	              BEGIN
                        IF TailIsGaussian THEN
                          BEGIN
                            RANDGEN;
                            Azimuth := 2.0 * PI * RANDOM;
                            Range := Fraction * ZNA_RAY [RayOrdinal].
                                SIGMA_X_HEAD;
                            ZSA_SURFACE_INTERCEPTS.ZSE_X1 := Range *
                                Cos (Azimuth);
                            IF ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN THEN
                              BEGIN
                                Range := Fraction * ZNA_RAY [RayOrdinal].
                                    SIGMA_Y_HEAD;
                                ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := Range *
                                    Sin (Azimuth)
                              END
                          END
                        ELSE
                          BEGIN
                            RANDGEN;
      		            Range := SQRT (-2.0 * LN (RANDOM)) *
                                ZNA_RAY [RayOrdinal].SIGMA_X_HEAD;
		            RANDGEN;
		            Azimuth := 2.0 * PI * RANDOM;
		            ZSA_SURFACE_INTERCEPTS.ZSE_X1 := Range *
                                SIN (Azimuth)
                          END
	              END
		    ELSE
		      BEGIN
		        RANDGEN;
		        ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
		            ZNA_RAY [RayOrdinal].SIGMA_X_HEAD *
                            (RANDOM * 2.0 - 1.0)
		      END;
		    IF ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN THEN
	              BEGIN
                        IF TailIsGaussian
                            AND ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN THEN
                          BEGIN
                            (* This condition has already been processed. *)
                          END
                        ELSE
                          BEGIN
		            RANDGEN;
      		            Range := SQRT (-2.0 * LN (RANDOM)) *
                                ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD;
		            RANDGEN;
		            Azimuth := 2.0 * PI * RANDOM;
		            ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := Range *
                                SIN (Azimuth)
                          END
	              END
		    ELSE
		      BEGIN
		        RANDGEN;
		        ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
		            ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD *
                            (RANDOM * 2.0 - 1.0)
		      END;
		    Z0 := 0.0;
		    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := 0.0;
                    (* Apply astigmatism, proportional to slope of
                    incident light ray. *)
                    IF ApplyAstigmaticCorrection THEN
                      AstigmaticCorrection := ((Sqrt (Sqr (X0) + Sqr (Y0)) /
                          TailSemiMajorAxis) - 1.0) * ZNA_RAY [RayOrdinal].
                          Astigmatism
                    ELSE
                      AstigmaticCorrection := 0.0;
                    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 :=
                        ZSA_SURFACE_INTERCEPTS.ZSG_Z1 + AstigmaticCorrection;
		    F04_ROTATE_AND_TRANSLATE_RAY_COORDINATES (RayOrdinal);
		    X05_SIMPLE_WRITE_INTRCPT (NoErrors)
		  END
	      END
	  END
      END;

  IF ARP_INTRCPT_BLOCK_SLOT > 1 THEN
    X45_WRITE_LAST_BLOCK_INTRCPT (NoErrors);

  IF ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS
      OR ZNA_RAY [RayOrdinal].TraceOrangeSliceRays THEN
    BEGIN
      (* Put actual ray count in first slot of first block *)
      SEEK (ZAI_INTERCEPT_WORK_FILE, 0);
      BLOCKREAD (ZAI_INTERCEPT_WORK_FILE,
          ZZA_INTERCEPT_DATA_BLOCK, 1, K);
      ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA :=
          ZZA_INTERCEPT_DATA_BLOCK.ZXB_BLOCK_DATA [1].
          ZXC_REAL_VALUES;
      ZSA_SURFACE_INTERCEPTS.ZSJ_TOTAL_RAYS_TO_TRACE :=
          RayCounter;
      ZZA_INTERCEPT_DATA_BLOCK.ZXB_BLOCK_DATA [1].
          ZXC_REAL_VALUES :=
          ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA;
      SEEK (ZAI_INTERCEPT_WORK_FILE, 0);
      BLOCKWRITE (ZAI_INTERCEPT_WORK_FILE,
          ZZA_INTERCEPT_DATA_BLOCK, 1, K)
    END

END;




(**  F0510_FIT_HIGH_ORDER_ASPHERES  *****************************************
*                                                                           *
*  This procedure searches through all defined surfaces, looking for high   *
*  order aspheres.  A least-squares fit is done for each high-order asphere *
*  with a fitting equation of (CC + 1)Z^2 + 2RZ + H^2 = 0 over the          *
*  specified diameter.  The values for CC and R are placed in temporary     *
*  storage, and are only used to find an initial point of intersection      *
*  between an incident light ray and the conic surface which most closely   *
*  represents each high-order asphere.  The initial point of intersection   *
*  constitutes a first guess, which is then refined using an iterative      *
*  technique.                                                               *
*                                                                           *
****************************************************************************)

PROCEDURE F0510_FIT_HIGH_ORDER_ASPHERES;

  CONST
      MAX_K         = 15;
      
  VAR
      I             : INTEGER;
      J             : INTEGER;
      K             : INTEGER;
      SLOT          : INTEGER;

      H             : ARRAY [1..MAX_K] OF DOUBLE;
      Z             : ARRAY [1..MAX_K] OF DOUBLE;
      R2            : DOUBLE;
      A0            : DOUBLE;
      A1            : DOUBLE;
      A2            : DOUBLE;
      A3            : DOUBLE;
      A4            : DOUBLE;
      A5            : DOUBLE;
      A6            : DOUBLE;
      A7            : DOUBLE;
      A8            : DOUBLE;
      A9            : DOUBLE;
      Z2            : DOUBLE;
      Z3            : DOUBLE;
      Z4            : DOUBLE;
      MAX_RADIUS    : DOUBLE;
      MIN_RADIUS    : DOUBLE;
      DELTA_RADIUS  : DOUBLE;
      SUM_Z2        : DOUBLE;
      SUM_Z3        : DOUBLE;
      SUM_Z4        : DOUBLE;
      SUM_H2Z2      : DOUBLE;
      SUM_H2Z       : DOUBLE;
      DENOM         : DOUBLE;
      COEF_A        : DOUBLE;
      COEF_B        : DOUBLE;

BEGIN

  FOR SLOT := 1 TO MAX_SLOTS DO
    TEMP_RADIUS_AND_CC [SLOT].SURFACE_ORD := 0;

  SLOT := 1;

  FOR J := 1 TO ARL_SEQUENCER_HI_INDEX DO
    BEGIN
      I := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
      IF (ZBA_SURFACE [I].SurfaceForm = HighOrderAsphere)
          AND (SLOT <= MAX_SLOTS) THEN
        BEGIN
	  R := ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV;
	  R2 := SQR (R);
	  CC := ZBA_SURFACE [I].ZBL_CONIC_CONSTANT;
	  A0 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [1];
	  A1 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [2];
	  A2 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [3];
	  A3 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [4];
	  A4 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [5];
	  A5 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [6];
	  A6 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [7];
	  A7 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [8];
	  A8 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [9];
	  A9 := ZBA_SURFACE [I].SurfaceShapeParameters.
              ZCA_DEFORMATION_CONSTANT [10];
	  IF ZBA_SURFACE [I].ZCL_OUTSIDE_APERTURE_IS_SQR THEN
	    MAX_RADIUS := SQRT (SQR (0.5 * ZBA_SURFACE [I].
		ZCP_OUTSIDE_APERTURE_WIDTH_X) +
		SQR (0.5 * ZBA_SURFACE [I].
		ZCQ_OUTSIDE_APERTURE_WIDTH_Y))
	  ELSE
	  IF ZBA_SURFACE [I].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
	    BEGIN
	      IF ZBA_SURFACE [I].ZCP_OUTSIDE_APERTURE_WIDTH_X >
		  ZBA_SURFACE [I].ZCQ_OUTSIDE_APERTURE_WIDTH_Y THEN
		MAX_RADIUS :=
		    0.5 * ZBA_SURFACE [I].ZCP_OUTSIDE_APERTURE_WIDTH_X
	      ELSE
		MAX_RADIUS := 0.5 * ZBA_SURFACE [I].
		    ZCQ_OUTSIDE_APERTURE_WIDTH_Y
	    END
	  ELSE
	    MAX_RADIUS := 0.5 * ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA;
	  IF ZBA_SURFACE [I].ZCT_INSIDE_DIMENS_SPECD THEN
	    BEGIN
	      IF ZBA_SURFACE [I].ZCM_INSIDE_APERTURE_IS_SQR
		  OR ZBA_SURFACE [I].ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
		IF ZBA_SURFACE [I].ZCR_INSIDE_APERTURE_WIDTH_X <
		    ZBA_SURFACE [I].ZCS_INSIDE_APERTURE_WIDTH_Y THEN
		  MIN_RADIUS := 0.5 * ZBA_SURFACE [I].
		      ZCR_INSIDE_APERTURE_WIDTH_X
		ELSE
		  MIN_RADIUS := 0.5 * ZBA_SURFACE [I].
		      ZCS_INSIDE_APERTURE_WIDTH_Y
	      ELSE
		MIN_RADIUS := 0.5 * ZBA_SURFACE [I].ZBK_INSIDE_APERTURE_DIA
	    END
	  ELSE
	    MIN_RADIUS := 0.0;
	  DELTA_RADIUS := MAX_RADIUS - MIN_RADIUS;
	  FOR K := 1 TO MAX_K DO
	    BEGIN
	      H [K] := (K / MAX_K) * DELTA_RADIUS + MIN_RADIUS;
	      HH := SQR (H [K]);
	      H4 := SQR (HH);
	      H6 := HH * H4;
	      H8 := SQR (H4);
	      H10 := H4 * H6;
	      H12 := SQR (H6);
	      H14 := H6 * H8;
	      H16 := SQR (H8);
	      H18 := H10 * H8;
	      H20 := SQR (H10);
	      H22 := H12 * H10;
	      IF ZBA_SURFACE [I].ZBZ_SURFACE_IS_FLAT THEN
	        Z [K] := -1.0 * (A0 * H4 + A1 * H6 + A2 * H8 + A3 * H10 +
		    A4 * H12 + A5 * H14 + A6 * H16 + A7 * H18 + A8 * H20 +
		    A9 * H22)
	      ELSE
                Z [K] := -1.0 * (((HH / R) / (1.0 + SQRT (1.0 - (CC + 1.0) *
  	            (HH / R2)))) + A0 * H4 + A1 * H6 + A2 * H8 + A3 * H10 +
		    A4 * H12 + A5 * H14 + A6 * H16 + A7 * H18 + A8 * H20 +
		    A9 * H22)
	    END;
	  SUM_Z2 := 0.0;
	  SUM_Z3 := 0.0;
	  SUM_Z4 := 0.0;
	  SUM_H2Z2 := 0.0;
	  SUM_H2Z := 0.0;
	  FOR K := 1 TO MAX_K DO
	    BEGIN
	      HH := SQR (H [K]);
	      Z2 := SQR (Z [K]);
	      Z3 := SQR (Z [K]) * Z [K];
	      Z4 := SQR (Z2);
	      SUM_Z2 := SUM_Z2 + Z2;
	      SUM_Z3 := SUM_Z3 + Z3;
	      SUM_Z4 := SUM_Z4 + Z4;
	      SUM_H2Z2 := SUM_H2Z2 + HH * Z2;
	      SUM_H2Z := SUM_H2Z + HH * Z [K]
	    END;
	  DENOM := (SUM_Z4 * SUM_Z2) - SQR (SUM_Z3);
	  COEF_A := ((SUM_H2Z2 * SUM_Z2) - (SUM_Z3 * SUM_H2Z)) / DENOM;
	  COEF_B := ((SUM_Z4 * SUM_H2Z) - (SUM_H2Z2 * SUM_Z3)) / DENOM;
	  TEMP_RADIUS_AND_CC [SLOT].SURFACE_ORD := I;
	  TEMP_RADIUS_AND_CC [SLOT].TEMP_CC := -1.0 * (COEF_A + 1.0);
	  TEMP_RADIUS_AND_CC [SLOT].TEMP_R := -1.0 * (COEF_B / 2.0);
	  SLOT := SLOT + 1
	END
    END;

END;




(**  F05_INITIALIZE_FOR_TRACE  ************************************************
******************************************************************************)


BEGIN

  IF AimPrincipalRays THEN
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('INITIALIZING FOR TRACE...')
    END;

  T99_CHECK_KEYBOARD_ACTIVITY;

  FOR LoopControl := 1 TO ARL_SEQUENCER_HI_INDEX DO
    BEGIN
      I := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [LoopControl];
      IF ZBA_SURFACE [I].ZBH_OUTSIDE_DIMENS_SPECD THEN
      ELSE
	ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA := 0.0
    END;

  F0510_FIT_HIGH_ORDER_ASPHERES;

  FOR LoopControl := 1 TO ARL_SEQUENCER_HI_INDEX DO
    BEGIN
      I := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [LoopControl];
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T11 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T12 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T13 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T21 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T22 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T23 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T31 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T32 := 0.0;
      ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T33 := 0.0;
      ZVA_ROTATION_MATRIX [I].ZVK_COORDINATE_TRANSLATION_NEEDED := FALSE;
      ZVA_ROTATION_MATRIX [I].ZVL_COORDINATE_ROTATION_NEEDED := FALSE
    END;

  FOR LoopControl := 1 TO ARL_SEQUENCER_HI_INDEX DO
    BEGIN
      I := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [LoopControl];
      IF (ZBA_SURFACE [I].ZBM_VERTEX_X <> 0.0)
	  OR (ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X <> 0.0)
	  OR (ZBA_SURFACE [I].ZBO_VERTEX_Y <> 0.0)
	  OR (ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y <> 0.0) THEN
	ZVA_ROTATION_MATRIX [I].
	    ZVK_COORDINATE_TRANSLATION_NEEDED := TRUE
      ELSE
	ZVA_ROTATION_MATRIX [I].
	    ZVK_COORDINATE_TRANSLATION_NEEDED := FALSE;
      IF (ZBA_SURFACE [I].ZBS_ROLL <> 0.0)
	  OR (ZBA_SURFACE [I].ZBT_DELTA_ROLL <> 0.0)
	  OR (ZBA_SURFACE [I].ZBU_PITCH <> 0.0)
	  OR (ZBA_SURFACE [I].ZBV_DELTA_PITCH <> 0.0)
	  OR (ZBA_SURFACE [I].ZBW_YAW <> 0.0)
	  OR (ZBA_SURFACE [I].ZBX_DELTA_YAW <> 0.0) THEN
	BEGIN
	  ZVA_ROTATION_MATRIX [I].
	      ZVL_COORDINATE_ROTATION_NEEDED := TRUE;
	  ROLL := ZBA_SURFACE [I].ZBS_ROLL + ZBA_SURFACE [I].ZBT_DELTA_ROLL;
	  PITCH := ZBA_SURFACE [I].ZBU_PITCH + ZBA_SURFACE [I].
	      ZBV_DELTA_PITCH;
	  YAW := ZBA_SURFACE [I].ZBW_YAW + ZBA_SURFACE [I].ZBX_DELTA_YAW;
	  COS_R := COS (ROLL / ALR_DEGREES_PER_RADIAN);
	  SIN_R := SIN (ROLL / ALR_DEGREES_PER_RADIAN);
	  COS_P := COS (PITCH / ALR_DEGREES_PER_RADIAN);
	  SIN_P := SIN (PITCH / ALR_DEGREES_PER_RADIAN);
	  COS_Y := COS (YAW / ALR_DEGREES_PER_RADIAN);
	  SIN_Y := SIN (YAW / ALR_DEGREES_PER_RADIAN);
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T11 :=
	      COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T12 :=
	      SIN_R * COS_P;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T13 :=
	      -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T21 :=
	      -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T22 :=
	      COS_R * COS_P;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T23 :=
	      SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T31 :=
	      COS_P * SIN_Y;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T32 :=
	      SIN_P;
	  ZVA_ROTATION_MATRIX [I].SurfaceRotationMatrix.T33 :=
	      COS_P * COS_Y
	END
      ELSE
	ZVA_ROTATION_MATRIX [I].ZVL_COORDINATE_ROTATION_NEEDED := FALSE
    END;

  FOR LoopControl := 1 TO MaxBulkGRINMaterials DO
    IF Length (GRINMaterial [LoopControl].GRINMatlAlias) > 0 THEN
      BEGIN
        GRINMaterial [LoopControl].CoordinateRotationNeeded := FALSE;
        GRINMaterial [LoopControl].CoordinateTranslationNeeded := FALSE;
        GRINMaterial [LoopControl].RotationMatrixElements.T11 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T12 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T13 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T21 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T22 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T33 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T31 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T32 := 0.0;
        GRINMaterial [LoopControl].RotationMatrixElements.T33 := 0.0
      END;

  FOR LoopControl := 1 TO MaxBulkGRINMaterials DO
    IF Length (GRINMaterial [LoopControl].GRINMatlAlias) > 0 THEN
      BEGIN
        IF (GRINMaterial [LoopControl].BulkMaterialPosition.Rx <> 0.0)
            OR (GRINMaterial [LoopControl].BulkMaterialPosition.Ry <> 0.0)
            OR (GRINMaterial [LoopControl].BulkMaterialPosition.Rz <> 0.0) THEN
          BEGIN
            GRINMaterial [LoopControl].CoordinateTranslationNeeded := TRUE;
            GRINMaterial [LoopControl].TranslationVectorElements.OriginX :=
              GRINMaterial [LoopControl].BulkMaterialPosition.Rx;
            GRINMaterial [LoopControl].TranslationVectorElements.OriginY :=
              GRINMaterial [LoopControl].BulkMaterialPosition.Ry;
            GRINMaterial [LoopControl].TranslationVectorElements.OriginZ :=
              GRINMaterial [LoopControl].BulkMaterialPosition.Rz
          END;
        IF (GRINMaterial [LoopControl].BulkMaterialOrientation.Tx <> 0.0)
            OR (GRINMaterial [LoopControl].BulkMaterialOrientation.Ty <> 0.0)
            OR (GRINMaterial [LoopControl].BulkMaterialOrientation.Tz <> 0.0) THEN
          BEGIN
            GRINMaterial [LoopControl].CoordinateRotationNeeded := TRUE;
	    YAW := GRINMaterial [LoopControl].BulkMaterialOrientation.Tx;
	    PITCH := GRINMaterial [LoopControl].BulkMaterialOrientation.Ty;
	    ROLL := GRINMaterial [LoopControl].BulkMaterialOrientation.Tz;
	    COS_R := COS (ROLL / ALR_DEGREES_PER_RADIAN);
	    SIN_R := SIN (ROLL / ALR_DEGREES_PER_RADIAN);
	    COS_P := COS (PITCH / ALR_DEGREES_PER_RADIAN);
	    SIN_P := SIN (PITCH / ALR_DEGREES_PER_RADIAN);
	    COS_Y := COS (YAW / ALR_DEGREES_PER_RADIAN);
	    SIN_Y := SIN (YAW / ALR_DEGREES_PER_RADIAN);
	    GRINMaterial [LoopControl].RotationMatrixElements.T11 :=
	        COS_R * COS_Y - SIN_R * SIN_P * SIN_Y;
	    GRINMaterial [LoopControl].RotationMatrixElements.T12 :=
	        SIN_R * COS_P;
	    GRINMaterial [LoopControl].RotationMatrixElements.T13 :=
	        -COS_R * SIN_Y - SIN_R * SIN_P * COS_Y;
	    GRINMaterial [LoopControl].RotationMatrixElements.T21 :=
	        -SIN_R * COS_Y - COS_R * SIN_P * SIN_Y;
	    GRINMaterial [LoopControl].RotationMatrixElements.T22 :=
	        COS_R * COS_P;
	    GRINMaterial [LoopControl].RotationMatrixElements.T23 :=
	        SIN_R * SIN_Y - COS_R * SIN_P * COS_Y;
	    GRINMaterial [LoopControl].RotationMatrixElements.T31 :=
	        COS_P * SIN_Y;
	    GRINMaterial [LoopControl].RotationMatrixElements.T32 :=
	        SIN_P;
	    GRINMaterial [LoopControl].RotationMatrixElements.T33 :=
	        COS_P * COS_Y
          END
      END;

  IF ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE THEN
  ELSE
    F0505_GENERATE_COMPUTED_RAYS;

  ARN_MAX_IMAGE_DIAMETER := 0.0;

  IF AimPrincipalRays THEN
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('TRACING RAYS...')
    END

END;




(**  F06_INITIALIZE_FOR_GRAPHICS  *********************************************
******************************************************************************)


PROCEDURE F06_INITIALIZE_FOR_GRAPHICS;

BEGIN

  GraphicsActive := TRUE;

  GraphicsOutputForm.Visible := TRUE;
  GraphicsOutputForm.SetFocus;
  GraphicsOutputForm.Color := clWhite;

  LADSBitmap := TBitmap.Create;

  LADSBitmap.Height := GraphicsOutputForm.Height;
  LADSBitmap.Width := GraphicsOutputForm.Width;

(*  LADSBitmap.Canvas.Font.Create;*)
  LADSBitmap.Canvas.Font := GraphicsOutputForm.Font;

  GraphicsOutputForm.Canvas.Pen.Color := clBlack;
  LADSBitmap.Canvas.Pen.Color := clBlack;

  RasterColumns := GraphicsOutputForm.Width;
  RasterRows := GraphicsOutputForm.Height;

  (* Find radius of circle representing active area of spot diagram. *)

  IF RasterColumns < RasterRows THEN
    SpotRadius := RasterColumns DIV 4
  ELSE
    SpotRadius := RasterRows DIV 4;

  ColumnsInRasterRadius := SpotRadius;
  RasterCenterColumn    := (RasterColumns DIV 2) + 0.5;
  RowsInRasterRadius    := ColumnsInRasterRadius;
  RasterCenterRow       := (RasterRows DIV 2) + 0.5

END;




(**  F07_SET_UP_SPOT_DIAGRAM  *************************************************
******************************************************************************)


PROCEDURE F07_SET_UP_SPOT_DIAGRAM;

  VAR
      TempString  : STRING;
      String1     : STRING;
      StringGap1  : STRING;
      String2     : STRING;
      StringGap2  : STRING;
      String3     : STRING;


(**  DrawCircularViewport  ****************************************************
******************************************************************************)

PROCEDURE DrawCircularViewport;

BEGIN

  (* The following is from the old DOS code ...
  Circle (GetMaxX DIV 2, GetMaxY DIV 2, GetMaxX DIV 4);

  MoveTo (10, 20);

  SetTextJustify (LeftText, TopText);

  OutText ('DIAMETER OF DESIGNATED (IMAGE) SURFACE: ');
  Str (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER, TempString);
  OutText (TempString)
  ... end section from old DOS code... *)

  (* Draw a circle representing the active area of the spot diagram, in the
  center of the client area. *)

  LADSBitmap.Canvas.Ellipse (Trunc (RasterCenterColumn - SpotRadius),
      Trunc (RasterCenterRow - SpotRadius),
      Trunc (RasterCenterColumn + SpotRadius),
      Trunc (RasterCenterRow + SpotRadius));

  GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);

  Str (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER, TempString);

  LADSBitmap.Canvas.TextOut (10, 10,
      'DIAMETER OF DESIGNATED (IMAGE) SURFACE: ' + TempString);

  GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);

  String1 := 'INTENSITY: ';
  StringGap1 := '         ';
  String2 := ' INITIAL   ';
  StringGap2 := '         ';
  String3 := ' ACCUM. (DERATED) AT SURF. ';
  Str (ZFA_OPTION.ZGK_DESIGNATED_SURFACE, TempString);
  TempString := Concat (String1, StringGap1, String2, StringGap2,
      String3, TempString);

  LADSBitmap.Canvas.TextOut (10, (RasterRows - 60), TempString);
  GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);

  SpotInitialPixelPosition := LADSBitmap.Canvas.TextWidth (String1);
  TempString := Concat (String1, StringGap1, String2);
  SpotAccumPixelPosition := LADSBitmap.Canvas.TextWidth (TempString);

  LastInitialIntensityString    := '';
  LastAccumIntensityString      := ''

  END;




(**  DrawRectangularViewport  *************************************************
******************************************************************************)

PROCEDURE DrawRectangularViewport;

  VAR
      ulx         : INTEGER;
      uly         : INTEGER;
      lrx         : INTEGER;
      lry         : INTEGER;

      Aspect      : DOUBLE;

BEGIN

  Aspect := ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
      ZCP_OUTSIDE_APERTURE_WIDTH_X /
      ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
      ZCQ_OUTSIDE_APERTURE_WIDTH_Y;

  IF Aspect >= 1.0 THEN (* Width greater than height *)
    BEGIN
      ulx := Round (RasterCenterColumn - ColumnsInRasterRadius);
      uly := Round (RasterCenterRow - RowsInRasterRadius / Aspect);
      lrx := Round (RasterCenterColumn + ColumnsInRasterRadius);
      lry := Round (RasterCenterRow + RowsInRasterRadius / Aspect)
    END
  ELSE
    BEGIN  (* Height greater than width *)
      ulx := Round (RasterCenterColumn - ColumnsInRasterRadius * Aspect);
      uly := Round (RasterCenterRow - RowsInRasterRadius);
      lrx := Round (RasterCenterColumn + ColumnsInRasterRadius * Aspect);
      lry := Round (RasterCenterRow + RowsInRasterRadius)
    END;

  GraphicsOutputForm.Canvas.Rectangle (ulx, uly, lrx, lry);
  LADSBitmap.Canvas.Rectangle (ulx, uly, lrx, lry);

  (* Draw scale bars... *)

  (* Draw a horizontal line segment that represents the user-specified
     x-dimension. *)

  GraphicsOutputForm.Canvas.MoveTo
      (ulx, (lry + Round (0.125 * RowsInRasterRadius)));
  LADSBitmap.Canvas.MoveTo
      (ulx, (lry + Round (0.125 * RowsInRasterRadius)));
  GraphicsOutputForm.Canvas.LineTo
      (lrx, (lry + Round (0.125 * RowsInRasterRadius)));
  LADSBitmap.Canvas.LineTo
      (lrx, (lry + Round (0.125 * RowsInRasterRadius)));

  (* Draw short vertical line segments at the left and right ends of the
     horizontal line segment.*)

  GraphicsOutputForm.Canvas.MoveTo
      (ulx, (lry + Round (0.105 * RowsInRasterRadius)));
  LADSBitmap.Canvas.MoveTo
      (ulx, (lry + Round (0.105 * RowsInRasterRadius)));
  GraphicsOutputForm.Canvas.LineTo
      (ulx, (lry + Round (0.145 * RowsInRasterRadius)));
  LADSBitmap.Canvas.LineTo
      (ulx, (lry + Round (0.145 * RowsInRasterRadius)));

  GraphicsOutputForm.Canvas.MoveTo
      (lrx, (lry + Round (0.105 * RowsInRasterRadius)));
  LADSBitmap.Canvas.MoveTo
      (lrx, (lry + Round (0.105 * RowsInRasterRadius)));
  GraphicsOutputForm.Canvas.LineTo
      (lrx, (lry + Round (0.145 * RowsInRasterRadius)));
  LADSBitmap.Canvas.LineTo
      (lrx, (lry + Round (0.145 * RowsInRasterRadius)));

  Str (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
      ZCP_OUTSIDE_APERTURE_WIDTH_X:15, TempString);

  (* Put text starting at x-dimension at center of horizontal scale bar. *)

  GraphicsOutputForm.Canvas.TextOut (Round (RasterCenterColumn),
      (lry + Round (0.145 * RowsInRasterRadius)), TempString);
  LADSBitmap.Canvas.TextOut (Round (RasterCenterColumn),
      (lry + Round (0.145 * RowsInRasterRadius)), TempString);

  (* If the output aperture is not square, display a height dimension. *)

  IF abs (1.0 - (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
      ZCP_OUTSIDE_APERTURE_WIDTH_X /
      ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
      ZCQ_OUTSIDE_APERTURE_WIDTH_Y)) > 0.00001 THEN
    BEGIN

      (* Draw a vertical line segment that represents the user-specified
         y-dimension. *)

      GraphicsOutputForm.Canvas.MoveTo
          ((ulx - Round (0.125 * ColumnsInRasterRadius)), uly);
      LADSBitmap.Canvas.MoveTo
          ((ulx - Round (0.125 * ColumnsInRasterRadius)), uly);
      GraphicsOutputForm.Canvas.LineTo
          ((ulx - Round (0.125 * ColumnsInRasterRadius)), lry);
      LADSBitmap.Canvas.LineTo
          ((ulx - Round (0.125 * ColumnsInRasterRadius)), lry);

      (* Draw short horizontal line segments at the top and bottom of the
         vertical line segment.*)

      GraphicsOutputForm.Canvas.MoveTo
          ((ulx - Round (0.105 * ColumnsInRasterRadius)), uly);
      LADSBitmap.Canvas.MoveTo
          ((ulx - Round (0.105 * ColumnsInRasterRadius)), uly);
      GraphicsOutputForm.Canvas.LineTo
          ((ulx - Round (0.145 * ColumnsInRasterRadius)), uly);
      LADSBitmap.Canvas.LineTo
          ((ulx - Round (0.145 * ColumnsInRasterRadius)), uly);

      GraphicsOutputForm.Canvas.MoveTo
          ((ulx - Round (0.105 * ColumnsInRasterRadius)), lry);
      LADSBitmap.Canvas.MoveTo
          ((ulx - Round (0.105 * ColumnsInRasterRadius)), lry);
      GraphicsOutputForm.Canvas.LineTo
          ((ulx - Round (0.145 * ColumnsInRasterRadius)), lry);
      LADSBitmap.Canvas.LineTo
          ((ulx - Round (0.145 * ColumnsInRasterRadius)), lry);

      (* Put y-dimension at center of vertical scale bar. *)

      GraphicsOutputForm.Canvas.MoveTo
          ((ulx - Round (0.145 * ColumnsInRasterRadius)),
          Round (RasterCenterRow));
      LADSBitmap.Canvas.MoveTo
          ((ulx - Round (0.145 * ColumnsInRasterRadius)),
          Round (RasterCenterRow));

      (* Orient text for vertical output. *)

(*    SetTextStyle (DefaultFont, VertDir, 1);

      SetTextJustify (BottomText, CenterText);

      Str (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
          ZCQ_OUTSIDE_APERTURE_WIDTH_Y:15, TempString);

      OutText (TempString);

      SetTextStyle (DefaultFont, HorizDir, 1)*)
    END

END;




(**  F07_SET_UP_SPOT_DIAGRAM  *************************************************
******************************************************************************)


BEGIN

  IF ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
      ZCL_OUTSIDE_APERTURE_IS_SQR THEN
    BEGIN
      IF ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
          ZCP_OUTSIDE_APERTURE_WIDTH_X >
          ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
          ZCQ_OUTSIDE_APERTURE_WIDTH_Y THEN
        IF abs (1.0 - (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER /
            ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZCP_OUTSIDE_APERTURE_WIDTH_X)) < 0.00001 THEN
          RectangularViewportEnabled := TRUE
        ELSE
          CircularViewportEnabled := TRUE
      ELSE
        IF abs (1.0 - (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER /
            ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZCQ_OUTSIDE_APERTURE_WIDTH_Y)) < 0.00001 THEN
          RectangularViewportEnabled := TRUE
        ELSE
          CircularViewportEnabled := TRUE
    END
  ELSE
    CircularViewportEnabled := TRUE;

  IF RectangularViewportEnabled THEN
    IF (NOT ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZBZ_SURFACE_IS_FLAT)
        AND (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZBH_OUTSIDE_DIMENS_SPECD)
        AND (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZCT_INSIDE_DIMENS_SPECD)
        AND (NOT ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZCL_OUTSIDE_APERTURE_IS_SQR)
        AND (NOT ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZCM_INSIDE_APERTURE_IS_SQR)
        AND (NOT ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZCN_OUTSIDE_APERTURE_ELLIPTICAL)
        AND (NOT ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZCO_INSIDE_APERTURE_ELLIPTICAL)
        AND (abs (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	  ZCW_APERTURE_POSITION_Y) > 1.0E-12) THEN
      BEGIN
        IF (abs (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].ZBM_VERTEX_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZBN_VERTEX_DELTA_X)) < 1E-10)
            AND (abs (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y -
	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].ZBO_VERTEX_Y +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZBP_VERTEX_DELTA_Y)) < 1E-10) THEN
        ELSE
          RectangularViewportEnabled := FALSE
      END
    ELSE
      BEGIN
        IF (abs (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
    	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZCV_APERTURE_POSITION_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].ZBM_VERTEX_X +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZBN_VERTEX_DELTA_X)) < 1.0E-10)
            AND (abs (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y -
    	    (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
	    ZCW_APERTURE_POSITION_Y +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].ZBO_VERTEX_Y +
	    ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
            ZBP_VERTEX_DELTA_Y)) < 1.0E-10) THEN
        ELSE
          RectangularViewportEnabled := FALSE
      END;
    IF (abs (ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z -
        (ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].ZBQ_VERTEX_Z +
        ZBA_SURFACE [ZFA_OPTION.ZGK_DESIGNATED_SURFACE].
        ZBR_VERTEX_DELTA_Z)) < 1.0E-10) THEN
    ELSE
      RectangularViewportEnabled := FALSE;

  IF RectangularViewportEnabled THEN
    DrawRectangularViewport
  ELSE
  IF CircularViewportEnabled THEN
    DrawCircularViewport

END;




(**  F08_DRAW_SURFACES  *****************************************************
****************************************************************************)


PROCEDURE F08_DRAW_SURFACES;

  VAR
      LineStartFound            : BOOLEAN;
      DrawThisBorder            : BOOLEAN;
      NextSurfaceFound          : BOOLEAN;
      NewLensGroup              : BOOLEAN;
      BorderDrawInProgress      : BOOLEAN;

      J                         : INTEGER;
      I                         : INTEGER;
      GroupIndex                : INTEGER;
      SequencerSlot             : INTEGER;
      LineEndColumnIndex        : INTEGER;
      LineEndRowIndex           : INTEGER;
      LineStartColumnIndex      : INTEGER;
      LineStartRowIndex         : INTEGER;
      HoldSurfaceOrdinal        : INTEGER;
      SaveSurfaceOrdinal        : INTEGER;
      ViewportLeft              : INTEGER;
      ViewportRight             : INTEGER;

      COLUMNS_PER_UNIT_DIST     : DOUBLE;
      DISTANCE_PER_COLUMN       : DOUBLE;
      ROWS_PER_UNIT_DIST        : DOUBLE;
      DISTANCE_PER_ROW          : DOUBLE;
      MIN_X                     : DOUBLE;
      MAX_X                     : DOUBLE;
      MIN_Y                     : DOUBLE;
      MAX_Y                     : DOUBLE;
      MIN_Z                     : DOUBLE;
      MAX_Z                     : DOUBLE;
      H2                        : DOUBLE;
      PowerH                    : DOUBLE;
      h                         : DOUBLE;
      r                         : DOUBLE;
      cc                        : DOUBLE;
      y1l                       : DOUBLE;
      y2l                       : DOUBLE;
      z1l                       : DOUBLE;
      z2l                       : DOUBLE;
      y1g                       : DOUBLE;
      y2g                       : DOUBLE;
      z1g                       : DOUBLE;
      z2g                       : DOUBLE;
      y1s                       : DOUBLE;
      y2s                       : DOUBLE;
      z1s                       : DOUBLE;
      z2s                       : DOUBLE;
      y1o                       : DOUBLE;
      y2o                       : DOUBLE;
      z1o                       : DOUBLE;
      z2o                       : DOUBLE;
      y1savel                   : DOUBLE;
      y2savel                   : DOUBLE;
      z1savel                   : DOUBLE;
      z2savel                   : DOUBLE;
      y1saveg                   : DOUBLE;
      y2saveg                   : DOUBLE;
      z1saveg                   : DOUBLE;
      z2saveg                   : DOUBLE;
      y1saves                   : DOUBLE;
      y2saves                   : DOUBLE;
      z1saves                   : DOUBLE;
      z2saves                   : DOUBLE;
      y1inners                  : DOUBLE;
      y2inners                  : DOUBLE;
      z1inners                  : DOUBLE;
      z2inners                  : DOUBLE;
      d11                       : DOUBLE;
      d12                       : DOUBLE;
      d21                       : DOUBLE;
      d22                       : DOUBLE;

      RAY_SAVE                  : ADH_RAY_REC;

      TempString                : STRING;

BEGIN

  HOLD_OPTIONS := ZFA_OPTION.ZFX_OPTION_ARCHIVE_DATA;

  FOR I := 1 TO CZAQ_OPTION_DATA_BOOLEAN_FIELDS DO
    ZFA_OPTION.ZFS_ALL_OPTION_DATA.ZFT_BOOLEAN_DATA [I] := FALSE;

  ZFA_OPTION.ZGR_QUIET_ERRORS := TRUE;

  COLUMNS_PER_UNIT_DIST := (2.0 * ColumnsInRasterRadius) /
      ZFA_OPTION.ZGL_VIEWPORT_DIAMETER;
  DISTANCE_PER_COLUMN := 1.0 / COLUMNS_PER_UNIT_DIST;

(*ROWS_PER_UNIT_DIST := COLUMNS_PER_UNIT_DIST * HoldXaspect /
      HoldYaspect;*)
  ROWS_PER_UNIT_DIST := COLUMNS_PER_UNIT_DIST * ColumnsInRasterRadius /
      RowsInRasterRadius;

  DISTANCE_PER_ROW := 1.0 / ROWS_PER_UNIT_DIST;

  ViewportLeft := Round (RasterCenterColumn) - ColumnsInRasterRadius;
  ViewportRight := ViewportLeft + ColumnsInRasterRadius +
      ColumnsInRasterRadius;

  MIN_Y := ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y -
      DISTANCE_PER_ROW * (RasterRows DIV 2);
  MAX_Y := ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y +
      DISTANCE_PER_ROW * (RasterRows DIV 2);

  MIN_X := ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
      DISTANCE_PER_ROW * (RasterRows DIV 2);
  MAX_X := ZFA_OPTION.ZGC_VIEWPORT_POSITION_X +
      DISTANCE_PER_ROW * (RasterRows DIV 2);

  MIN_Z := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z -
      DISTANCE_PER_COLUMN * (RasterColumns DIV 2);
  MAX_Z := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z +
      DISTANCE_PER_COLUMN * (RasterColumns DIV 2);

  RAY1.X := ZFA_OPTION.ZGC_VIEWPORT_POSITION_X;
  RAY1.Y := MIN_Y;
  RAY1.Z := MIN_Z;
  RAY1.A := 0.0;
  RAY1.B := 0.0;
  RAY1.C := 1.0;

(*RAY1.X := MIN_X;
  RAY1.Y := ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
  RAY1.Z := MIN_Z;
  RAY1.A := 0.0;
  RAY1.B := 0.0;
  RAY1.C := 1.0;*)

  RAY_SAVE.ALL := RAY1.ALL;

  J := 1;

  REPEAT
    BEGIN
      SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
      REPEAT
        BEGIN
	  RAY0.ALL := RAY_SAVE.ALL;
	  REPEAT
	    BEGIN
	      XformGlobalCoordsToLocal;
              IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
                ComputeLensletApertureXYOffset;
              IF NoErrors THEN
                F50_INTERSECT_SURFACE
              ELSE
                F01AB_NO_INTERSECTION := TRUE;
	      IF NOT F01AB_NO_INTERSECTION THEN
	        BEGIN
		  RAY1.A := RAY0.A;
		  RAY1.B := RAY0.B;
		  RAY1.C := RAY0.C;
	          XformLocalCoordsToGlobal;
	          VERTICAL_DISPLACEMENT :=
		      RAY1.Y - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
                (*VERTICAL_DISPLACEMENT :=
		      RAY1.X - ZFA_OPTION.ZGC_VIEWPORT_POSITION_X;*)
	          HORIZONTAL_DISPLACEMENT :=
		      ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - RAY1.Z;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOnScreen THEN
                    BEGIN
	              GraphicsOutputForm.Canvas.Pixels
                          [ColumnIndex, RowIndex] := clBlack;
	              LADSBitmap.Canvas.Pixels
                          [ColumnIndex, RowIndex] := clBlack
                    END;
                  RAY0.ALL := RAY1.ALL;
                  RAY0.X := RAY0.X + RAY0.A * RayAdvanceFactor;
                  RAY0.Y := RAY0.Y + RAY0.B * RayAdvanceFactor;
                  RAY0.Z := RAY0.Z + RAY0.C * RayAdvanceFactor
		END
	    END
	  UNTIL
	    F01AB_NO_INTERSECTION;
          RAY_SAVE.Y := RAY_SAVE.Y + DISTANCE_PER_ROW
	(*RAY_SAVE.X := RAY_SAVE.X + DISTANCE_PER_ROW*)
	END
      UNTIL
        RAY_SAVE.Y > MAX_Y;
      (*RAY_SAVE.X > MAX_X;*)
      RAY_SAVE.Y := MIN_Y;
    (*RAY_SAVE.X := MIN_X;*)
      J := J + 1
    END
  UNTIL
    (J > ARL_SEQUENCER_HI_INDEX);

  RAY1.X := ZFA_OPTION.ZGC_VIEWPORT_POSITION_X;
  RAY1.Y := MIN_Y;
  RAY1.Z := MIN_Z;
  RAY1.A := 0.0;
  RAY1.B := 1.0;
  RAY1.C := 0.0;

  RAY_SAVE.ALL := RAY1.ALL;

  J := 1;

  REPEAT
    BEGIN
      SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
      REPEAT
        BEGIN
	  RAY0.ALL := RAY_SAVE.ALL;
	  REPEAT
	    BEGIN
	      XformGlobalCoordsToLocal;
              IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
                ComputeLensletApertureXYOffset;
              IF NoErrors THEN
                F50_INTERSECT_SURFACE
              ELSE
                F01AB_NO_INTERSECTION := TRUE;
	      IF NOT F01AB_NO_INTERSECTION THEN
	        BEGIN
		  RAY1.A := RAY0.A;
		  RAY1.B := RAY0.B;
		  RAY1.C := RAY0.C;
	          XformLocalCoordsToGlobal;
	          VERTICAL_DISPLACEMENT :=
		      RAY1.Y - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
	          HORIZONTAL_DISPLACEMENT :=
		      ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - RAY1.Z;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOnScreen THEN
                    BEGIN
	              GraphicsOutputForm.Canvas.Pixels [ColumnIndex, RowIndex] :=
                          clBlack;
	              LADSBitmap.Canvas.Pixels [ColumnIndex, RowIndex] :=
                          clBlack
                    END;
                  RAY0.ALL := RAY1.ALL;
                  RAY0.X := RAY0.X + RAY0.A * RayAdvanceFactor;
                  RAY0.Y := RAY0.Y + RAY0.B * RayAdvanceFactor;
                  RAY0.Z := RAY0.Z + RAY0.C * RayAdvanceFactor
		END
	    END
	  UNTIL
	    F01AB_NO_INTERSECTION;
          RAY_SAVE.Z := RAY_SAVE.Z + DISTANCE_PER_COLUMN
	END
      UNTIL
        RAY_SAVE.Z > MAX_Z;
      RAY_SAVE.Z := MIN_Z;
      J := J + 1
    END
  UNTIL
    (J > ARL_SEQUENCER_HI_INDEX);

  ZFA_OPTION.ZFX_OPTION_ARCHIVE_DATA := HOLD_OPTIONS;

  (* Draw lens borders in y-z plane. *)
  (* Get the first surface. *)

  GroupIndex := 1;
  SequencerSlot := 1;
  NextSurfaceFound := FALSE;
  NewLensGroup := FALSE;
  BorderDrawInProgress := FALSE;

  IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
    IF ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
        ZGX_GROUP_PROCESS_CONTROL_CODE = GroupActive THEN
      BEGIN
        (*  Get the surface sequencer starting slot for Group 1. *)
        SequencerSlot := ZFA_OPTION.
            ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
            ZGV_SEQUENCER_START_SLOT;
        (*  Get the surface ordinal specified by the sequencer starting
            slot for Group 1. *)
        SurfaceOrdinal :=
            ZFA_OPTION.ZGT_SURFACE_SEQUENCER [SequencerSlot];
        NextSurfaceFound := TRUE;
        NewLensGroup := TRUE
      END
    ELSE
      BEGIN
        (* If non-sequential ray-tracing is active, then there MUST be
           lens groups specified.  We get to this location because group
           1 is not defined.  This may be upgraded in the future to search
           through all possible group indexes. *)
      END
  ELSE
    BEGIN
      (* Not a recursive trace, therefore Group 1 not defined. *)
      SurfaceOrdinal :=
          ZFA_OPTION.ZGT_SURFACE_SEQUENCER [SequencerSlot];
      NextSurfaceFound := TRUE
    END;

  WHILE NextSurfaceFound DO
    BEGIN
      (* The following code tests whether the selected surface is actually
         a candidate for border draw. *)
      DrawThisBorder := FALSE;
      IF (NOT ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1])
          AND (abs (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
          ZBI_REFRACTIVE_INDEX - 1.0) < 1.0E-10)
          AND (NOT ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2])
          AND (abs (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
          ZBI_REFRACTIVE_INDEX - 1.0) < 1.0E-10) THEN
        BEGIN
          (* Hard-coded n1 = 1 and hard-coded n2 = 1.  This is a mirror in
             air, or a non-immersed dummy surface with refractive index of 1.
             Should not participate in border draw. *)
        END
      ELSE
      IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1]
          AND ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] THEN
        BEGIN
          (* Two glass names specified. *)
          IF ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
              ZCH_GLASS_NAME =
              ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
              ZCH_GLASS_NAME THEN
            BEGIN
              (* Glass names are identical. *)
              IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE OR
                  ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
                BEGIN
                  (* This is a Mangin mirror or an immersed beamsplitter.
                     Draw the border. *)
                  DrawThisBorder := TRUE
                END
              ELSE
                BEGIN
                 (* This is a dummy immersed surface.
                    Should not participate in border draw. *)
                END
            END
          ELSE
            BEGIN
              (* Non-identical glass names. *)
              DrawThisBorder := TRUE
            END
        END
      ELSE
      IF (NOT ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1])
          AND (NOT ZBA_SURFACE [SurfaceOrdinal].
          ZCF_GLASS_NAME_SPECIFIED [2]) THEN
        BEGIN
          (* Two hard-coded refractive indices. *)
          IF abs (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
              ZBI_REFRACTIVE_INDEX -
              ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
              ZBI_REFRACTIVE_INDEX) < 1.0E-10 THEN
            BEGIN
              (* Hard-coded refractive indices are identical. *)
              IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE OR
                  ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
                BEGIN
                  (* This is a Mangin mirror or an immersed beamsplitter.
                     Draw the border. *)
                  DrawThisBorder := TRUE
                END
              ELSE
                BEGIN
                 (* This is a dummy immersed surface.
                    Should not participate in border draw. *)
                END
            END
          ELSE
            (* Hard-coded refractive indices are not identical. *)
            BEGIN
              DrawThisBorder := TRUE;
              IF (abs (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
                  ZBI_REFRACTIVE_INDEX - 1.0) < 1.0E-10)
                  OR (abs (ZBA_SURFACE [SurfaceOrdinal].
                  ZCG_INDEX_OR_GLASS [2].
                  ZBI_REFRACTIVE_INDEX - 1.0) < 1.0E-10) THEN
                (* One refractive index is air.  Thus, if this is not a
                   recursive ray trace, then we are either
                   entering a lens group, or exiting a lens group.
                   If border drawing is currently in progress, then
                   we are leaving a lens group.  Otherwise, we are
                   entering a lens group. *)
                BEGIN
                  IF NOT ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
                    IF BorderDrawInProgress THEN
                      BorderDrawInProgress := FALSE
                    ELSE
                      NewLensGroup := TRUE
                END
            END
        END
      ELSE
        BEGIN
          (* One hard-coded refractive index and one glass name (hopefully
             with a different refractive index than the hard-coded value). *)
          DrawThisBorder := TRUE;
          IF (NOT ZBA_SURFACE [SurfaceOrdinal].
              ZCF_GLASS_NAME_SPECIFIED [1]) THEN
            BEGIN
              (* n1 is hard-coded. *)
              IF (abs (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
                  ZBI_REFRACTIVE_INDEX - 1.0) < 1.0E-10) THEN
                BEGIN
                  (* n1 is air.  Thus, if this is not a
                     recursive ray trace, then we are either
                     entering a lens group, or exiting a lens group. *)
                  IF NOT ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
                    IF BorderDrawInProgress THEN
                      BorderDrawInProgress := FALSE
                    ELSE
                      NewLensGroup := TRUE
                END
            END
          ELSE
          IF (NOT ZBA_SURFACE [SurfaceOrdinal].
              ZCF_GLASS_NAME_SPECIFIED [2]) THEN
            BEGIN
              (* n2 is hard-coded. *)
              IF (abs (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
                  ZBI_REFRACTIVE_INDEX - 1.0) < 1.0E-10) THEN
                BEGIN
                  (* n2 is air.  Thus, if this is not a
                     recursive ray trace, then we are either
                     entering a lens group, or exiting a lens group. *)
                  IF NOT ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
                    IF BorderDrawInProgress THEN
                      BorderDrawInProgress := FALSE
                    ELSE
                      NewLensGroup := TRUE
                END
            END
        END;
      IF DrawThisBorder THEN
        BEGIN
          (* This code draws borders between adjacent surfaces. *)
          (* First, find edge of lens in local surface coordinates. *)
          (* ATTENTION:  This code currently doesn't handle CPCs. *)
          IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD THEN
            IF ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR
                OR ZBA_SURFACE [SurfaceOrdinal].
                ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
              h := ZBA_SURFACE [SurfaceOrdinal].
                  ZCQ_OUTSIDE_APERTURE_WIDTH_Y / 2.0
            ELSE
              h := ZBA_SURFACE [SurfaceOrdinal].
                  ZBJ_OUTSIDE_APERTURE_DIA / 2.0
          ELSE
            (* This is actually an "error" condition, since the user
               should have specified a diameter of some kind. Therefore,
               take a default diameter of 1. *)
            h := 0.5;
          (* Get coordinates of the upper and lower edges of the lens,
             in local coordinates. *)
          y1l := h + ZBA_SURFACE [SurfaceOrdinal].
              ZCW_APERTURE_POSITION_Y;
          y2l := -h + ZBA_SURFACE [SurfaceOrdinal].
              ZCW_APERTURE_POSITION_Y;
          r := -1.0 * ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV;
          cc := ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT;
          IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
            BEGIN
              z1l := 0.0;
              z2l := 0.0
            END
          ELSE
            BEGIN
              z1l := (sqr (y1l) / r) / (1.0 + sqrt (1.0 - (cc + 1.0) *
                  (sqr (y1l) / sqr (r))));
              z2l := (sqr (y2l) / r) / (1.0 + sqrt (1.0 - (cc + 1.0) *
                  (sqr (y2l) / sqr (r))))
            END;
          IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm =
              HighOrderAsphere THEN
            BEGIN
              H2 := sqr (y1l);
              PowerH := H2;
              FOR I := 1 TO CZAI_MAX_DEFORM_CONSTANTS DO
                BEGIN
                  PowerH := PowerH * H2;
                  z1l := z1l - ZBA_SURFACE [SurfaceOrdinal].
                      SurfaceShapeParameters.
                      ZCA_DEFORMATION_CONSTANT [I] * PowerH
                END;
              IF abs (ZBA_SURFACE [SurfaceOrdinal].
                  ZCW_APERTURE_POSITION_Y) < 1.0E-12 THEN
                z2l := z1l
              ELSE
                BEGIN
                  H2 := sqr (y2l);
                  PowerH := H2;
                  FOR I := 1 TO CZAI_MAX_DEFORM_CONSTANTS DO
                    BEGIN
                      PowerH := PowerH * H2;
                      z2l := z2l - ZBA_SURFACE [SurfaceOrdinal].
                          SurfaceShapeParameters.
                          ZCA_DEFORMATION_CONSTANT [I] * PowerH
                    END
                END
            END;
          (* Extend lens edge diameter for sub-diameter surface. *)
          IF NewLensGroup THEN (*@*)
            BEGIN
              y1savel := y1l;
              y2savel := y2l;
              z1savel := z1l;
              z2savel := z2l;
              SaveSurfaceOrdinal := SurfaceOrdinal
            END
          ELSE
            BEGIN
              IF Abs ((y1l - y2l) / (y1savel - y2savel)) > 1.02 THEN
                (* Previous surface is sub-diameter. *)
                BEGIN
                  (* Use present h (y) values and previous sag (z) values to
                     compute new lens edge for previous lens. *)
                  y1savel := y1l;
                  y2savel := y2l;
                  RAY_SAVE.ALL := RAY1.ALL;
                  HoldSurfaceOrdinal := SurfaceOrdinal;
                  SurfaceOrdinal := SaveSurfaceOrdinal;
                  Ray1.X := 0.0;
                  Ray1.Y := y1savel;
                  Ray1.Z := z1savel;
	          XformLocalCoordsToGlobal;
                  y1saveg := Ray1.Y;
                  z1saveg := Ray1.Z;
                  Ray1.X := 0.0;
                  Ray1.Y := y2savel;
                  Ray1.Z := z2savel;
                  XformLocalCoordsToGlobal;
                  y2saveg := Ray1.Y;
                  z2saveg := Ray1.Z;
                  RAY1.ALL := RAY_SAVE.ALL;
                  SurfaceOrdinal := HoldSurfaceOrdinal;
                  (* Transform global coords (y1saveg,z1saveg) and
                     (y2saveg,z2saveg) into screen coords (y1saves,z1saves)
                     and (y2saves,z2saves). *)
                  (* y1saves and y2saves are equivalent to
                     VERTICAL_DISPLACEMENT. *)
                  y1saves := y1saveg - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
                  y2saves := y2saveg - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
                  (* z1saves and z2saves are equivalent to
                     HORIZONTAL_DISPLACEMENT. *)
                  z1saves := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z1saveg;
                  z2saves := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z2saveg;
                  (* Draw line from (y1o,z1o) to (y1saves,z1saves). *)
                  VERTICAL_DISPLACEMENT := y1o;
                  HORIZONTAL_DISPLACEMENT := z1o;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y1saves;
                      HORIZONTAL_DISPLACEMENT := z1saves;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END;
                  (* Draw line from (y2o,z2o) to (y2saves,z2saves). *)
                  VERTICAL_DISPLACEMENT := y2o;
                  HORIZONTAL_DISPLACEMENT := z2o;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y2saves;
                      HORIZONTAL_DISPLACEMENT := z2saves;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END;
                  y1o := y1saves;
                  z1o := z1saves;
                  y2o := y2saves;
                  z2o := z2saves
                END
              ELSE
              IF Abs ((y1l - y2l) / (y1savel - y2savel)) < 0.98 THEN
                (* Present surface is sub-diameter. *)
                BEGIN (*@*)
                  (* Convert inner edge coordinates for present lens to
                     global coordinates. *)
                  RAY_SAVE.ALL := RAY1.ALL;
                  Ray1.X := 0.0;
                  Ray1.Y := y1l;
                  Ray1.Z := z1l;
	          XformLocalCoordsToGlobal;
                  y1g := Ray1.Y;
                  z1g := Ray1.Z;
                  Ray1.X := 0.0;
                  Ray1.Y := y2l;
                  Ray1.Z := z2l;
                  XformLocalCoordsToGlobal;
                  y2g := Ray1.Y;
                  z2g := Ray1.Z;
                  RAY1.ALL := RAY_SAVE.ALL;
                  (* Transform global coords (y1g,z1g) and (y2g,z2g) for
                     lens inner edge into
                     screen coords (y1s,z1s) and (y2s,z2s). *)
                  (* y1s and y2s are equivalent to VERTICAL_DISPLACEMENT. *)
                  y1inners := y1g - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
                  y2inners := y2g - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
                  (* z1s and z2s are equivalent to HORIZONTAL_DISPLACEMENT. *)
                  z1inners := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z1g;
                  z2inners := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z2g;
                  (* Use present sag (local z) values and previous h (local
                     y) values to compute new outer edge global coordinates
                     for present lens. *)
                  RAY_SAVE.ALL := RAY1.ALL;
                  Ray1.X := 0.0;
                  Ray1.Y := y1savel;
                  Ray1.Z := z1l;
	          XformLocalCoordsToGlobal;
                  y1g := Ray1.Y;
                  z1g := Ray1.Z;
                  Ray1.X := 0.0;
                  Ray1.Y := y2savel;
                  Ray1.Z := z2l;
                  XformLocalCoordsToGlobal;
                  y2g := Ray1.Y;
                  z2g := Ray1.Z;
                  RAY1.ALL := RAY_SAVE.ALL;
                  (* Transform global coords (y1g,z1g) and (y2g,z2g) for
                     lens new outer edge into
                     screen coords (y1s,z1s) and (y2s,z2s). *)
                  (* y1s and y2s are equivalent to VERTICAL_DISPLACEMENT. *)
                  y1s := y1g - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
                  y2s := y2g - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
                  (* z1s and z2s are equivalent to HORIZONTAL_DISPLACEMENT. *)
                  z1s := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z1g;
                  z2s := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z2g;
                  (* Draw line from (y1inners,z1inners) to (y1s,z1s). *)
                  VERTICAL_DISPLACEMENT := y1inners;
                  HORIZONTAL_DISPLACEMENT := z1inners;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y1s;
                      HORIZONTAL_DISPLACEMENT := z1s;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END;
                  (* Draw line from (y2inners,z2inners) to (y2s,z2s). *)
                  VERTICAL_DISPLACEMENT := y2inners;
                  HORIZONTAL_DISPLACEMENT := z2inners;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y2s;
                      HORIZONTAL_DISPLACEMENT := z2s;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END;
                  y1l := y1savel;
                  y2l := y2savel
                END
            END;
          (* Transform local coords (y1l,z1l) and (y2l,z2l) into global
             coords (y1g,z1g) and (y2g,z2g). *)
          RAY_SAVE.ALL := RAY1.ALL;
          Ray1.X := 0.0;
          Ray1.Y := y1l;
          Ray1.Z := z1l;
	  XformLocalCoordsToGlobal;
          y1g := Ray1.Y;
          z1g := Ray1.Z;
          Ray1.X := 0.0;
          Ray1.Y := y2l;
          Ray1.Z := z2l;
          XformLocalCoordsToGlobal;
          y2g := Ray1.Y;
          z2g := Ray1.Z;
          RAY1.ALL := RAY_SAVE.ALL;
          (* Transform global coords (y1g,z1g) and (y2g,z2g) into
             screen coords (y1s,z1s) and (y2s,z2s). *)
          (* y1s and y2s are equivalent to VERTICAL_DISPLACEMENT. *)
          y1s := y1g - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
          y2s := y2g - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
          (* z1s and z2s are equivalent to HORIZONTAL_DISPLACEMENT. *)
          z1s := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z1g;
          z2s := ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - z2g;
          IF NewLensGroup THEN
            BEGIN
              (* Borders will not be drawn.  Simply store the lens edge
                 coordinates as "old" coordinates. *)
              y1o := y1s;
              z1o := z1s;
              y2o := y2s;
              z2o := z2s;
              NewLensGroup := FALSE;
              BorderDrawInProgress := TRUE
            END
          ELSE
            BEGIN
              (* Draw borders from old screen coordinates to the current
                 screen coordinates. *)
              (* First, determine which coordinates match up. *)
              d11 := sqrt (sqr (y1s - y1o) + sqr (z1s - z1o));
              d12 := sqrt (sqr (y1s - y2o) + sqr (z1s - z2o));
              d21 := sqrt (sqr (y2s - y1o) + sqr (z2s - z1o));
              d22 := sqrt (sqr (y2s - y2o) + sqr (z2s - z2o));
              IF (d11 + d22) < (d12 + d21) THEN
                BEGIN
                  (* Draw line from (y1o,z1o) to (y1s,z1s). *)
                  VERTICAL_DISPLACEMENT := y1o;
                  HORIZONTAL_DISPLACEMENT := z1o;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y1s;
                      HORIZONTAL_DISPLACEMENT := z1s;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END;
                  (* Draw line from (y2o,z2o) to (y2s,z2s). *)
                  VERTICAL_DISPLACEMENT := y2o;
                  HORIZONTAL_DISPLACEMENT := z2o;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y2s;
                      HORIZONTAL_DISPLACEMENT := z2s;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END
                END
              ELSE
                BEGIN
                  (* Draw line from (y1o,z1o) to (y2s,z2s). *)
                  VERTICAL_DISPLACEMENT := y1o;
                  HORIZONTAL_DISPLACEMENT := z1o;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y2s;
                      HORIZONTAL_DISPLACEMENT := z2s;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END;
                  (* Draw line from (y2o,z2o) to (y1s,z1s). *)
                  VERTICAL_DISPLACEMENT := y2o;
                  HORIZONTAL_DISPLACEMENT := z2o;
	          F95_GET_COLUMN_AND_ROW;
	          IF ColumnAndRowOK THEN
                    BEGIN
                      LineStartColumnIndex := ColumnIndex;
                      LineStartRowIndex := RowIndex;
                      VERTICAL_DISPLACEMENT := y1s;
                      HORIZONTAL_DISPLACEMENT := z1s;
                      F95_GET_COLUMN_AND_ROW;
                      IF ColumnAndRowOK THEN
                        BEGIN
                          LineEndColumnIndex := ColumnIndex;
                          LineEndRowIndex := RowIndex;
                          GraphicsOutputForm.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          LADSBitmap.Canvas.MoveTo
                              (LineStartColumnIndex, LineStartRowIndex);
                          GraphicsOutputForm.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex);
                          LADSBitmap.Canvas.LineTo
                              (LineEndColumnIndex, LineEndRowIndex)
                        END
                    END
                END;
              (* Save current data as old data. *)
              y1o := y1s;
              z1o := z1s;
              y2o := y2s;
              z2o := z2s;
            END
        END;
      (* This next code segment finds the next candidate surface for border
         draw, or terminates the border draw code if no next surface
         exists. *)
      NextSurfaceFound := FALSE;
      IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
        BEGIN
          (* Check to see if current sequencer slot equals the last slot
             in the current group.  If so, increment the group index,
             and enable the NewLensGroup flag. *)
          IF SequencerSlot = ZFA_OPTION.
              ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
              ZGW_SEQUENCER_END_SLOT THEN
            BEGIN
              (* End of the current group.  Search for next active group. *)
              GroupIndex := GroupIndex + 1;
              WHILE (NOT NewLensGroup)
                  AND (GroupIndex <= CZBO_MAX_SEQUENCER_GROUPS) DO
                BEGIN
                  IF ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                      ZGX_GROUP_PROCESS_CONTROL_CODE = GroupActive THEN
                    BEGIN
                      SequencerSlot := ZFA_OPTION.
                          ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                          ZGV_SEQUENCER_START_SLOT;
                      SurfaceOrdinal :=
                          ZFA_OPTION.ZGT_SURFACE_SEQUENCER [SequencerSlot];
                      NextSurfaceFound := TRUE;
                      NewLensGroup := TRUE
                    END
                  ELSE
                    GroupIndex := GroupIndex + 1
                END
            END
          ELSE
            BEGIN
              (* Nonsequential trace, still processing current group. *)
              SequencerSlot := SequencerSlot + 1;
              SurfaceOrdinal :=
                  ZFA_OPTION.ZGT_SURFACE_SEQUENCER [SequencerSlot];
              NextSurfaceFound := TRUE
            END
        END
      ELSE
        BEGIN
          (* Sequential trace. *)
          SequencerSlot := SequencerSlot + 1;
          IF SequencerSlot <= ARL_SEQUENCER_HI_INDEX THEN
            BEGIN
              SurfaceOrdinal :=
                  ZFA_OPTION.ZGT_SURFACE_SEQUENCER [SequencerSlot];
              NextSurfaceFound := TRUE
            END
        END
    END;

  (*  Display surface ordinal numbers. *)

  IF ZFA_OPTION.ShowSurfaceNumbers THEN
    BEGIN
      GraphicsOutputForm.Canvas.Font.Color := clGreen;
      LADSBitmap.Canvas.Font.Color := clGreen;
      J := 1;
      REPEAT
        BEGIN
          SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
          VERTICAL_DISPLACEMENT :=
	      (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
	      ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y) -
	      ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
          HORIZONTAL_DISPLACEMENT :=
              ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z -
	      (ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z +
              ZBA_SURFACE [SurfaceOrdinal].ZBR_VERTEX_DELTA_Z);
          F95_GET_COLUMN_AND_ROW;
          IF ColumnAndRowOnScreen THEN
            BEGIN
	      str (SurfaceOrdinal, TempString);
              GraphicsOutputForm.Canvas.TextOut
                  (ColumnIndex, RowIndex, TempString);
	      LADSBitmap.Canvas.TextOut
                  (ColumnIndex, RowIndex, TempString)
	    END;
          J := J + 1
        END
      UNTIL
        (J > ARL_SEQUENCER_HI_INDEX);
      GraphicsOutputForm.Canvas.Font.Color := clBlack;
      LADSBitmap.Canvas.Font.Color := clBlack
    END;

  (* Draw a horizontal scale bar (line segment) that represents the
     user-specified viewscreen diameter.  Draw vertical lines at each
     end of the scale bar.  *)

  GraphicsOutputForm.Canvas.MoveTo (ViewportLeft, 25);
  LADSBitmap.Canvas.MoveTo (ViewportLeft, 25);
  GraphicsOutputForm.Canvas.LineTo (ViewportRight, 25);
  LADSBitmap.Canvas.LineTo (ViewportRight, 25);

  GraphicsOutputForm.Canvas.MoveTo (ViewportLeft, 20);
  LADSBitmap.Canvas.MoveTo (ViewportLeft, 20);
  GraphicsOutputForm.Canvas.LineTo (ViewportLeft, 30);
  LADSBitmap.Canvas.LineTo (ViewportLeft, 30);

  GraphicsOutputForm.Canvas.MoveTo (ViewportRight, 20);
  LADSBitmap.Canvas.MoveTo (ViewportRight, 20);
  GraphicsOutputForm.Canvas.LineTo (ViewportRight, 30);
  LADSBitmap.Canvas.LineTo (ViewportRight, 30);

  Str (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER:16, TempString);

(*SetTextJustify (CenterText, BottomText);*)
  GraphicsOutputForm.Canvas.TextOut
      (Round (RasterCenterColumn), 25, TempString);
  LADSBitmap.Canvas.TextOut
      (Round (RasterCenterColumn), 25, TempString)
(*OutTextXY (Round (RasterCenterColumn), 25, TempString);
  SetTextJustify (LeftText, BottomText)*)

END;




(**  F10_INITIALIZE_RAY	 ******************************************************
******************************************************************************)


PROCEDURE F10_INITIALIZE_RAY;

  VAR
      J            : INTEGER;

      TempString   : STRING;

BEGIN

  IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
    IF ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER THEN
      IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	  CZBR_AUTO_SEQUENCING THEN
	IF F01AF_RAY_COUNTER = 1 THEN
	  BEGIN
	    F01AP_TEMP_SEQ_HI_INDEX := 0;
	    FOR J := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	      F01AN_TEMPORARY_SEQUENCER [J] := 0
	  END
	ELSE
	IF F01AF_RAY_COUNTER = 2 THEN
	  BEGIN
	    ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE :=
		CZBS_USER_SPECIFIED_SEQUENCE;
	    ZFA_OPTION.ZGI_RECURSIVE_TRACE := FALSE;
	    ARL_SEQUENCER_HI_INDEX := F01AP_TEMP_SEQ_HI_INDEX;
	    ZFA_OPTION.ZGT_SURFACE_SEQUENCER :=
		F01AN_TEMPORARY_SEQUENCER
	  END;

  RAY1.A := ZSA_SURFACE_INTERCEPTS.ZSB_A1;
  RAY1.B := ZSA_SURFACE_INTERCEPTS.ZSC_B1;
  RAY1.C := ZSA_SURFACE_INTERCEPTS.ZSD_C1;

  RAY1.X := ZSA_SURFACE_INTERCEPTS.ZSE_X1;
  RAY1.Y := ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
  RAY1.Z := ZSA_SURFACE_INTERCEPTS.ZSG_Z1;

  IF AimPrincipalRays THEN
    (* De-translate the ray head back into local coordinates. *)
    BEGIN
      (* The value of RayOrdinal and the components of the ray
         rotation matrix are left over from F0505_GENERATE_COMPUTED_RAYS. *)
      ZSA_SURFACE_INTERCEPTS.ZSE_X1 := ZSA_SURFACE_INTERCEPTS.ZSE_X1 -
	  ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE;
      ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := ZSA_SURFACE_INTERCEPTS.ZSF_Y1 -
	  ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE;
      ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := ZSA_SURFACE_INTERCEPTS.ZSG_Z1 -
	  ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE;
      IF COORDINATE_ROTATION_NEEDED THEN
        (* De-rotate the ray head back into local coordinates. *)
        BEGIN
          HoldX := ZSA_SURFACE_INTERCEPTS.ZSE_X1;
          HoldY := ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
          HoldZ := ZSA_SURFACE_INTERCEPTS.ZSG_Z1;
          ZSA_SURFACE_INTERCEPTS.ZSE_X1 :=
	      (RayRotationMatrix.T11 * HoldX) +
              (RayRotationMatrix.T21 * HoldY) +
              (RayRotationMatrix.T31 * HoldZ);
          ZSA_SURFACE_INTERCEPTS.ZSF_Y1 :=
	      (RayRotationMatrix.T12 * HoldX) +
              (RayRotationMatrix.T22 * HoldY) +
              (RayRotationMatrix.T32 * HoldZ);
          ZSA_SURFACE_INTERCEPTS.ZSG_Z1 :=
	      (RayRotationMatrix.T13 * HoldX) +
              (RayRotationMatrix.T32 * HoldY) +
              (RayRotationMatrix.T33 * HoldZ)
        END;
      HoldX := ZSA_SURFACE_INTERCEPTS.ZSE_X1;
      HoldY := ZSA_SURFACE_INTERCEPTS.ZSF_Y1;
      HoldZ := ZSA_SURFACE_INTERCEPTS.ZSG_Z1
    END;

  IF TracingBeamsplitRay THEN
  ELSE
    ARX_ACCUM_INITIAL_INTENSITY := ARX_ACCUM_INITIAL_INTENSITY +
        ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;

  N1 := ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX;

  IF N1 < 0.0 THEN
    BEGIN
      N1 := N1 * -1.0;
      F01AO_TRACING_PRINCIPAL_RAY := TRUE
    END
  ELSE
    F01AO_TRACING_PRINCIPAL_RAY := FALSE;

  IF ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM THEN
    BEGIN
      (* Erase the old intensity value on the graphics screen... *)
      TempString := LastInitialIntensityString;
      GraphicsOutputForm.Canvas.Font.Color := clWhite;
      LADSBitmap.Canvas.Font.Color := clWhite;
      GraphicsOutputForm.Canvas.TextOut
          ((10 + SpotInitialPixelPosition),
          (RasterRows - 60), TempString);
      LADSBitmap.Canvas.TextOut ((10 + SpotInitialPixelPosition),
          (RasterRows - 60), TempString);
      (* Put the new intensity value on the graphics screen... *)
      GraphicsOutputForm.Canvas.Font.Color := clBlack;
      LADSBitmap.Canvas.Font.Color := clBlack;
      Str (ARX_ACCUM_INITIAL_INTENSITY:9:2, TempString);
      GraphicsOutputForm.Canvas.TextOut ((10 + SpotInitialPixelPosition),
          (RasterRows - 60), TempString);
      LADSBitmap.Canvas.TextOut ((10 + SpotInitialPixelPosition),
          (RasterRows - 60), TempString);
      LastInitialIntensityString := TempString
    END
  ELSE
  IF ZFA_OPTION.DRAW_RAYS THEN
    BEGIN
      VERTICAL_DISPLACEMENT :=
	  RAY1.Y - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
    (*VERTICAL_DISPLACEMENT :=
	  RAY1.X - ZFA_OPTION.ZGC_VIEWPORT_POSITION_X;*)
      HORIZONTAL_DISPLACEMENT :=
	  ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - RAY1.Z;
      F95_GET_COLUMN_AND_ROW;
      LineBroken := FALSE;
      IF ColumnAndRowOK THEN
        BEGIN
	  GraphicsOutputForm.Canvas.MoveTo (ColumnIndex, RowIndex);
	  LADSBitmap.Canvas.MoveTo (ColumnIndex, RowIndex)
        END
      ELSE
        LineBroken := TRUE
    END

END;




(**  F20_TRACE_RAY  ***********************************************************
******************************************************************************)


PROCEDURE F20_TRACE_RAY;

BEGIN

  F10_INITIALIZE_RAY;

  F01AD_HEADINGS_NOT_PRINTED := TRUE;
  F01AM_SUMMING_PATH_LENGTHS := FALSE;
  CurrentMaterialIsGradientIndex := FALSE;

  IF NoErrors THEN
    BEGIN
      IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
	BEGIN
	  F01AH_PREV_WORKING_SURFACE := CZAB_MAX_NUMBER_OF_SURFACES + 1;
	  REPEAT
	    BEGIN
	      F22_FIND_NEXT_RECURSIVE_SURFACE;
	      IF NOT F01AG_RAY_TERMINATION_OCCURRED THEN
		BEGIN
		  F25_PROCESS_SURFACE;
		  IF ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER THEN
		    IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
			CZBR_AUTO_SEQUENCING THEN
		      BEGIN
			F01AP_TEMP_SEQ_HI_INDEX := F01AP_TEMP_SEQ_HI_INDEX + 1;
			F01AN_TEMPORARY_SEQUENCER [F01AP_TEMP_SEQ_HI_INDEX] :=
			    SurfaceOrdinal
		      END
		END;
	      F01AH_PREV_WORKING_SURFACE := SurfaceOrdinal;
	      T99_CHECK_KEYBOARD_ACTIVITY
	    END
	  UNTIL
	    (NOT NoErrors)
	    OR F01AG_RAY_TERMINATION_OCCURRED
	    OR (KeyboardActivityDetected)
	END
      ELSE
	BEGIN
	  J := 1;
	  REPEAT
	    BEGIN
	      SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
              IF CurrentMaterialIsGradientIndex THEN
                F23ComputeGRINRayPath
              ELSE
	        F21_FIND_NEXT_SEQUENTIAL_SURFACE;
	      IF NOT F01AB_NO_INTERSECTION THEN
		F25_PROCESS_SURFACE;
	      T99_CHECK_KEYBOARD_ACTIVITY;
	      J := J + 1
	    END
	  UNTIL
	    (J > ARL_SEQUENCER_HI_INDEX)
	    OR F01AB_NO_INTERSECTION
            OR F01AG_RAY_TERMINATION_OCCURRED
	    OR (NOT NoErrors)
	    OR (KeyboardActivityDetected)
	END
    END

END;




(**  F21_FIND_NEXT_SEQUENTIAL_SURFACE  ****************************************
******************************************************************************)


PROCEDURE F21_FIND_NEXT_SEQUENTIAL_SURFACE;

BEGIN

  RAY0.ALL := RAY1.ALL;
  RAY_OLD.ALL := RAY1.ALL;

  F01AG_RAY_TERMINATION_OCCURRED := FALSE;

  XformGlobalCoordsToLocal;

  IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
    ComputeLensletApertureXYOffset;

  IF NoErrors THEN
    F50_INTERSECT_SURFACE
  ELSE
    F01AB_NO_INTERSECTION := TRUE

END;




(**  F22_FIND_NEXT_RECURSIVE_SURFACE  *****************************************
******************************************************************************)


PROCEDURE F22_FIND_NEXT_RECURSIVE_SURFACE;

  VAR
      HOLD_SURFACE_ORDINAL    : INTEGER;

      HOLD_RAY0		      : ADH_RAY_REC;
      HOLD_RAY1		      : ADH_RAY_REC;
      SaveRay0                : ADH_RAY_REC;
      SaveRayOld              : ADH_RAY_REC;
      DISTANCE		      : DOUBLE;
      HOLD_DISTANCE	      : DOUBLE;
      HOLD_R		      : DOUBLE;
      HOLD_CC		      : DOUBLE;
      HoldNX                  : DOUBLE;
      HoldNY                  : DOUBLE;
      HoldNZ                  : DOUBLE;


(**  AdvanceRay  **************************************************************
******************************************************************************)

PROCEDURE AdvanceRay;

BEGIN

  (* For recursive ray tracing, the ray starting point is advanced by a
     small amount after interaction with the present surface.  This reduces
     the possibility of multiple intercepts at the same point on the same
     surface due to round-off error. *)

  SaveRay0.All := RAY0.All;
  SaveRayOld.All := RAY_OLD.ALL;

  RAY0.X := RAY0.X + RAY0.A * RayAdvanceFactor;
  RAY0.Y := RAY0.Y + RAY0.B * RayAdvanceFactor;
  RAY0.Z := RAY0.Z + RAY0.C * RayAdvanceFactor;

  RAY_OLD.X := RAY0.X;
  RAY_OLD.Y := RAY0.Y;
  RAY_OLD.Z := RAY0.Z;

END;




(**  DeAdvanceRay  ************************************************************
******************************************************************************)

PROCEDURE DeAdvanceRay;

BEGIN

  RAY0.All := SaveRay0.All;
  RAY_OLD.ALL := SaveRayOld.All

END;




(**  F22_FIND_NEXT_RECURSIVE_SURFACE  *****************************************
******************************************************************************)


BEGIN

  RAY0.ALL := RAY1.ALL;
  RAY_OLD.ALL := RAY1.ALL;

  F01AG_RAY_TERMINATION_OCCURRED := TRUE;
  HOLD_DISTANCE := 1.0E99;
  J := 1;

  WHILE (J <= ARL_SEQUENCER_HI_INDEX) DO
    BEGIN
      SurfaceOrdinal := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J];
      IF (SurfaceOrdinal = F01AH_PREV_WORKING_SURFACE)
	  AND ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT
	  AND (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = Conic) THEN
      ELSE
	BEGIN
	  XformGlobalCoordsToLocal;
          IF (SurfaceOrdinal = F01AH_PREV_WORKING_SURFACE) THEN
            AdvanceRay;
          IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
            ComputeLensletApertureXYOffset;
          IF NoErrors THEN
            BEGIN
              F50_INTERSECT_SURFACE;
              IF (SurfaceOrdinal = F01AH_PREV_WORKING_SURFACE) THEN
                DeAdvanceRay
            END
          ELSE
            F01AB_NO_INTERSECTION := TRUE;
	  IF NOT F01AB_NO_INTERSECTION THEN
	    BEGIN
	      IF D1 < HOLD_DISTANCE THEN
		  BEGIN
		    F01AG_RAY_TERMINATION_OCCURRED := FALSE;
		    HOLD_DISTANCE := D1;
		    HOLD_RAY0.ALL := RAY0.ALL;
		    HOLD_RAY1.ALL := RAY1.ALL;
		    HOLD_R := R;
		    HOLD_CC := CC;
                    HoldNX := NX;
                    HoldNY := NY;
                    HoldNZ := NZ;
		    HOLD_SURFACE_ORDINAL := SurfaceOrdinal
		  END
	    END
	END;
      RAY0.ALL := RAY_OLD.ALL;
      J := J + 1
    END;

  IF NOT F01AG_RAY_TERMINATION_OCCURRED THEN
    BEGIN
      RAY0.ALL := HOLD_RAY0.ALL;
      RAY1.ALL := HOLD_RAY1.ALL;
      R := HOLD_R;
      CC := HOLD_CC;
      NX := HoldNX;
      NY := HoldNY;
      NZ := HoldNZ;
      SurfaceOrdinal := HOLD_SURFACE_ORDINAL
    END

END;




(**  F23ComputeGRINRayPath  ***************************************************
******************************************************************************)

PROCEDURE F23ComputeGRINRayPath;

  VAR
      SavePreviousPosition     : PositionVector;
      SavePreviousOrientation  : OrientationVector;
      SaveNewPosition          : PositionVector;
      SaveNewOrientation       : OrientationVector;

      DeltaT                   : DOUBLE;

(**  ComputeOneGRINPathSegment  **********************************************

  This procedure follows the technique described by Anurag Sharma in Applied
  Optics, vol. 21, no. 6, pg. 984 (15 March 1982), for tracing rays through
  gradient index media.

*****************************************************************************)

PROCEDURE ComputeOneGRINPathSegment;

  VAR
      SaveRefractiveIndex  : DOUBLE;

      XformOperands        : TransformationRecord;

      SaveXformedPosition  : PositionVector;

BEGIN

  (* U050_CALCULATE_REFRACTIVE_INDEX is accessed directly, rather than
  through U060, since U060 was just executed in the process of finding
  the refractive index at the most recent interface.  Thus, the
  details for the gradient index glass, wavelength, etc., are still in
  memory. *)

  (* Compute refractive index (and gradient of refractive index) at current
  position (Rx,Ry,Rz). This position must be expressed in terms of the
  bulk GRIN material coordinates. *)

  (* First, convert global coordinates of ray tail position and ray vector
  orientation into the coordinates of the bulk GRIN material. *)

  XformOperands.CoordinateRotationNeeded :=
      GRINMaterial [GRINMaterialOrdinal].CoordinateRotationNeeded;

  XformOperands.CoordinateTranslationNeeded :=
      GRINMaterial [gRINMaterialOrdinal].CoordinateTranslationNeeded;

  XformOperands.RotationMatrixElements :=
      GRINMaterial [GRINMaterialOrdinal].RotationMatrixElements;

  XformOperands.TranslationVectorElements :=
      GRINMaterial [GRINMaterialOrdinal].TranslationVectorElements;

  (* RAY0.X, .Y, and .Z are expressed in global coordinates. *)

  XformOperands.Position.Rx := RAY0.X;
  XformOperands.Position.Ry := RAY0.Y;
  XformOperands.Position.Rz := RAY0.Z;

  (* RAY0.A, .B, and .C are expressed in global coordinates. *)

  XformOperands.Orientation.Tx := RAY0.A;
  XformOperands.Orientation.Ty := RAY0.B;
  XformOperands.Orientation.Tz := RAY0.C;

  TransformGlobalCoordsToLocal (XformOperands);

  SaveXformedPosition := XformOperands.Position;

  (* Compute refractive index and gradient of refractive index at the
  position of the tail of the light ray, where position is in terms of
  bulk material coordinates. *)

  ComputeGradientOnly := FALSE;

  U050_CALCULATE_REFRACTIVE_INDEX
      (ComputeGradientOnly,
       XformOperands.Position,
       AKO_SPECIFIED_WAVELENGTH,
       ZKZ_GLASS_DATA_IO_AREA,
       AKP_REFRACTIVE_INDEX_CALCULATED,
       AKQ_CALCULATED_REFRACTIVE_INDEX,
       RefIndexGradient);

  (* Compute x,y,z components of coefs A, B, and C of Runge-Cutta
     algorithm. *)

  Ax := DeltaT * RefIndexGradient.Dx;
  Ay := DeltaT * RefIndexGradient.Dy;
  Az := DeltaT * RefIndexGradient.Dz;

  (* Weight direction cosines by refractive index. *)

  XformOperands.Orientation.Tx := AKQ_CALCULATED_REFRACTIVE_INDEX *
      XformOperands.Orientation.Tx;
  XformOperands.Orientation.Ty := AKQ_CALCULATED_REFRACTIVE_INDEX *
      XformOperands.Orientation.Ty;
  XformOperands.Orientation.Tz := AKQ_CALCULATED_REFRACTIVE_INDEX *
      XformOperands.Orientation.Tz;

  SaveRefractiveIndex := AKQ_CALCULATED_REFRACTIVE_INDEX;

  (* Shift Rx,Ry,Rz by the first amount specified by Runge-Kutta. *)

  XformOperands.Position.Rx := SaveXformedPosition.Rx +
      0.5 * DeltaT * XformOperands.Orientation.Tx + 0.125 * DeltaT * Ax;
  XformOperands.Position.Ry := SaveXformedPosition.Ry +
      0.5 * DeltaT * XformOperands.Orientation.Ty + 0.125 * DeltaT * Ay;
  XformOperands.Position.Rz := SaveXformedPosition.Rz +
      0.5 * DeltaT * XformOperands.Orientation.Tz + 0.125 * DeltaT * Az;

  (* Get gradient of refractive index field at shifted position Rx,Ry,Rz. *)
  (* Do we need the refractive index also, at the shifted position? *)

  ComputeGradientOnly := TRUE;
  U050_CALCULATE_REFRACTIVE_INDEX
      (ComputeGradientOnly,
       XformOperands.Position,
       AKO_SPECIFIED_WAVELENGTH,
       ZKZ_GLASS_DATA_IO_AREA,
       AKP_REFRACTIVE_INDEX_CALCULATED,
       AKQ_CALCULATED_REFRACTIVE_INDEX,
       RefIndexGradient);

  Bx := DeltaT * RefIndexGradient.Dx;
  By := DeltaT * RefIndexGradient.Dy;
  Bz := DeltaT * RefIndexGradient.Dz;

  (* Shift Rx,Ry,Rz by the second amount specified by Runge-Kutta. *)

  XformOperands.Position.Rx := SaveXformedPosition.Rx +
      DeltaT * XformOperands.Orientation.Tx + 0.5 * DeltaT * Bx;
  XformOperands.Position.Ry := SaveXformedPosition.Ry +
      DeltaT * XformOperands.Orientation.Ty + 0.5 * DeltaT * By;
  XformOperands.Position.Rz := SaveXformedPosition.Rz +
      DeltaT * XformOperands.Orientation.Tz + 0.5 * DeltaT * Bz;

  (* Do we need the refractive index also, at the shifted position? *)

  ComputeGradientOnly := TRUE;
  U050_CALCULATE_REFRACTIVE_INDEX
      (ComputeGradientOnly,
       XformOperands.Position,
       AKO_SPECIFIED_WAVELENGTH,
       ZKZ_GLASS_DATA_IO_AREA,
       AKP_REFRACTIVE_INDEX_CALCULATED,
       AKQ_CALCULATED_REFRACTIVE_INDEX,
       RefIndexGradient);

  Cx := DeltaT * RefIndexGradient.Dx;
  Cy := DeltaT * RefIndexGradient.Dy;
  Cz := DeltaT * RefIndexGradient.Dz;

  (* Get updated ray starting position. *)

  XformOperands.Position.Rx := SaveXformedPosition.Rx +
      DeltaT * (XformOperands.Orientation.Tx + ((Ax + 2.0 * Bx) / 6.0));
  XformOperands.Position.Ry := SaveXformedPosition.Ry +
      DeltaT * (XformOperands.Orientation.Ty + ((Ay + 2.0 * By) / 6.0));
  XformOperands.Position.Rz := SaveXformedPosition.Rz +
      DeltaT * (XformOperands.Orientation.Tz + ((Az + 2.0 * Bz) / 6.0));

  (* Get updated ray direction cosines. *)

  XformOperands.Orientation.Tx := XformOperands.Orientation.Tx +
      (Ax + 4.0 * Bx + Cx) / 6.0;
  XformOperands.Orientation.Ty := XformOperands.Orientation.Ty +
      (Ay + 4.0 * By + Cy) / 6.0;
  XformOperands.Orientation.Tz := XformOperands.Orientation.Tz +
      (Az + 4.0 * Bz + Cz) / 6.0;

  (* Un-weight direction cosines, in preparation for converting to
  global coordinates. *)

  (* Is this correct???  Why do we have to divide by the refractive
  index? *)

  XformOperands.Orientation.Tx := XformOperands.Orientation.Tx /
      SaveRefractiveIndex;
  XformOperands.Orientation.Ty := XformOperands.Orientation.Ty /
      SaveRefractiveIndex;
  XformOperands.Orientation.Tz := XformOperands.Orientation.Tz /
      SaveRefractiveIndex;

  TransformLocalCoordsToGlobal (XformOperands);

  SavePreviousPosition := SaveNewPosition;
  SavePreviousOrientation := SaveNewOrientation;

  SaveNewPosition := XformOperands.Position;
  SaveNewOrientation := XformOperands.Orientation

END;




(**  F23ComputeGRINRayPath  ***************************************************
******************************************************************************)


BEGIN

  RAY0.ALL := RAY1.ALL;
  RAY_OLD.ALL := RAY1.ALL;

  (* Take snapshot of initial position and orientation of incident ray, in
  global coords. *)

  SaveNewPosition.Rx := RAY1.X;
  SaveNewPosition.Ry := RAY1.Y;
  SaveNewPosition.Rz := RAY1.Z;
  SaveNewOrientation.Tx := RAY1.A;
  SaveNewOrientation.Ty := RAY1.B;
  SaveNewOrientation.Tz := RAY1.C;

  F01AG_RAY_TERMINATION_OCCURRED := FALSE;

  DeltaT := 0.2;

  REPEAT
    BEGIN
      ComputeOneGRINPathSegment;
      XformGlobalCoordsToLocal;
      IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
        ComputeLensletApertureXYOffset;
      IF NoErrors THEN
        F50_INTERSECT_SURFACE
      ELSE
        F01AB_NO_INTERSECTION := TRUE;
      IF F01AB_NO_INTERSECTION THEN
        BEGIN
          (* Starting position for light ray is beyond the target surface.*)
          (* Backup to previous starting position and orientation, in
             global coords, and set DeltaT to a smaller value. *)
          RAY0.X := SavePreviousPosition.Rx;
          RAY0.Y := SavePreviousPosition.Ry;
          RAY0.Z := SavePreviousPosition.Rz;
          RAY0.A := SavePreviousOrientation.Tx;
          RAY0.B := SavePreviousOrientation.Ty;
          RAY0.C := SavePreviousOrientation.Tz;
          DeltaT := DeltaT * 0.1;
          IF DeltaT < 0.001 THEN
            BEGIN
              (* We might as well quit.  Convert the previous position and
                 orientation into local coords, prior to exiting this
                 procedure. *)
              F01AB_NO_INTERSECTION := FALSE;
              XformGlobalCoordsToLocal
            END
        END
      ELSE
        BEGIN
          (* Intersection found. *)
          IF (DeltaT < 0.001) THEN
            BEGIN
              (* This DeltaT value is sufficiently small to result in an
                 accurate intercept. Therefore, the current ray starting
                 position and orientation, RAY0.X, .Y, etc. (in local
                 coords) will be retained. *)
            END
          ELSE
            BEGIN
              (* Update ray starting position and orientation with most
                 recent values, in global coords. *)
              RAY0.X := SaveNewPosition.Rx;
              RAY0.Y := SaveNewPosition.Ry;
              RAY0.Z := SaveNewPosition.Rz;
              RAY0.A := SaveNewOrientation.Tx;
              RAY0.B := SaveNewOrientation.Ty;
              RAY0.C := SaveNewOrientation.Tz
            END;
          (* If drawing is enabled, draw this ray segment. *)
          IF ZFA_OPTION.DRAW_RAYS THEN
            BEGIN
              VERTICAL_DISPLACEMENT :=
	          SaveNewPosition.Ry - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
           (* VERTICAL_DISPLACEMENT :=
	          RAY1.X - ZFA_OPTION.ZGC_VIEWPORT_POSITION_X;*)
              HORIZONTAL_DISPLACEMENT :=
	          ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - SaveNewPosition.Rz;
              F95_GET_COLUMN_AND_ROW;
              IF ColumnAndRowOK THEN
                IF LineBroken THEN
                  BEGIN
	            GraphicsOutputForm.Canvas.MoveTo (ColumnIndex, RowIndex);
	            LADSBitmap.Canvas.MoveTo (ColumnIndex, RowIndex);
                    LineBroken := FALSE
                  END
                ELSE
                  BEGIN
	            GraphicsOutputForm.Canvas.LineTo (ColumnIndex, RowIndex);
	            LADSBitmap.Canvas.LineTo (ColumnIndex, RowIndex)
                  END
              ELSE
                LineBroken := TRUE
            END
        END
    END
  UNTIL (DeltaT < 0.001)

END;




(**  F25_PROCESS_SURFACE  *****************************************************
******************************************************************************)


PROCEDURE F25_PROCESS_SURFACE;

BEGIN

  F52_REFLECT_OR_REFRACT;

  IF NoErrors THEN
    IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
      DetranslateLenslet;

  IF NoErrors THEN
    BEGIN
      F55_COMPUTE_DIA_AND_INTENSITY;
      IF F01AG_RAY_TERMINATION_OCCURRED THEN
	BEGIN
	  RAY1.A := RAY0.A;
	  RAY1.B := RAY0.B;
	  RAY1.C := RAY0.C
	END
    END;

  IF NoErrors THEN
    XformLocalCoordsToGlobal;

  IF NoErrors THEN
    IF ZFA_OPTION.DRAW_RAYS THEN
      BEGIN
        VERTICAL_DISPLACEMENT :=
	    RAY1.Y - ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y;
     (* VERTICAL_DISPLACEMENT :=
	    RAY1.X - ZFA_OPTION.ZGC_VIEWPORT_POSITION_X;*)
        HORIZONTAL_DISPLACEMENT :=
	    ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z - RAY1.Z;
        F95_GET_COLUMN_AND_ROW;
        IF ColumnAndRowOK THEN
          IF LineBroken THEN
            BEGIN
              GraphicsOutputForm.Canvas.MoveTo (ColumnIndex, RowIndex);
              LADSBitmap.Canvas.MoveTo (ColumnIndex, RowIndex);
              LineBroken := FALSE
            END
          ELSE
            BEGIN
	      GraphicsOutputForm.Canvas.LineTo (ColumnIndex, RowIndex);
	      LADSBitmap.Canvas.LineTo (ColumnIndex, RowIndex)
            END
        ELSE
          LineBroken := TRUE
      END;

  IF NoErrors THEN
    F65_COMPUTE_PATH_LENGTH;

  IF NoErrors THEN
    IF ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE
	OR ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER
	OR ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE THEN
      F70_PRINT_TRACE_RESULTS
    ELSE
    IF ZFA_OPTION.DisplayLocalData THEN
      F75DisplayLocalData

END;




(**  XformGlobalCoordsToLocal	***********************************************
******************************************************************************)


PROCEDURE XformGlobalCoordsToLocal;

  VAR
      F45AA_A0_HOLD  : DOUBLE;
      F45AB_B0_HOLD  : DOUBLE;
      F45AC_C0_HOLD  : DOUBLE;
      F45AD_X0_HOLD  : DOUBLE;
      F45AE_Y0_HOLD  : DOUBLE;
      F45AF_Z0_HOLD  : DOUBLE;

BEGIN

(**  This section of code serves the purpose of simplifying the mathematics
     required for finding the point of intersection of a light ray with an
     optical surface.  The generalized solution for this problem in 3
     dimensions is a bit tedious.  However, formulae have been devised which
     permit a simplified solution to this problem.  The simplified formulae
     assume that the optical surface is a conic surface of revolution about
     the z-axis.  (The z-axis is generally called the optical axis.)

     This program makes no assumptions about the optical axis, or about the
     orientation of optical surfaces.  The user has complete freedom to
     specify the position and orientation of each optical surface within an
     arbitrary reference coordinate system.  Therefore, in order to take
     advantage of the simplified, standard formulae, we are required to
     perform coordinate transformations, as necessary, at each optical
     surface, so as to cause the surface to appear to satisfy the condition of
     rotational symmetry about the z-axis.

     In order to perform the required coordinate transformations, we must
     define a local coordinate system.	The origin of this local coordinate
     system coincides with the surface vertex.	The gradient of the function
     representing the surface, evaluated at the surface vertex, is defined to
     be co-linear with the positive z-axis of the local coordinate system. The
     specification of the x- and y-axes is completely arbitrary for surfaces
     which have rotational symmetry.  For surfaces such as cylinders, the long
     axis is assumed to coincide with the local x-axis.

     The orientation of the local coordinate system attached to the optical
     surface is specified by 3 parameters: roll, pitch, and yaw.  Thus, in
     addition to the 3 spatial parameters which specify the position of the
     surface vertex, each optical surface has an additional 3 rotational
     parameters which, along with the spatial parameters, completely constrain
     the 6 possible degrees of freedom for the position and orientation of the
     surface within the reference coordinate system.

     The order of rotational transformation from the reference coordinate
     system into the local coordinate system is defined as follows: (1) yaw --
     rotate about reference system y-axis according to right hand rule; (2)
     pitch -- rotate about "yawed" x-axis according to left hand rule; and (3)
     roll -- rotate about "yawed" and "pitched" z-axis according to right hand
     rule.  By transforming in this order, we achieve a clear correlation with
     azimuth and elevation, if we picture what is happening to the local z-
     axis, and if we imagine a reference coordinate system where the positive
     z-axis extends toward the right, the positive x-axis extends away from
     us, and the positive y-axis extends upward.  In fact, the correlation
     between yaw and azimuth, and pitch and elevation, is so good that data
     input commands generated by this program are stated in terms of azimuth
     and elevation, rather than yaw and pitch, because we believe the former
     are more intuitively obvious in meaning than the latter.

     When the position and orientation of the optical surface have been
     specified, it is a fairly simple task to express the starting point and
     vector component magnitudes of the incident light ray in terms of the
     local coordinate system attached to the optical surface.  We first
     translate the starting point coordinates of the light ray into the local
     coordinate system, by subtracting the surface vertex x-, y-, and z-
     coordinates from the x-, y-, and z-coordinates of the starting point of
     the incident light ray.  We then rotate the light ray starting point
     coordinates and component magnitudes into the local coordinate space by
     application of the previously computed direction cosine matrix.  After
     the ray-surface intersection and ray-surface interaction has been
     computed, we apply the reverse procedure to put the exiting light ray
     back into the reference coordinate system.	 That is, we de-rotate the
     exiting light ray (i.e., its point of intersection with the present
     optical surface, and its new vector component magnitudes) back into the
     reference coordinate system by means of the transpose of the direction
     cosine matrix, and then de-translate the ray-surface intersection point,
     which becomes the new starting point of the light ray for the next
     optical surface.  **)

(**  First, translate starting point of incident light ray into local
     coordinate system attached to optical surface vertex.  **)

  IF ZVA_ROTATION_MATRIX [SurfaceOrdinal].
      ZVK_COORDINATE_TRANSLATION_NEEDED THEN
    BEGIN
      RAY0.X := RAY0.X -
	  (ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
	  ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X);
      RAY0.Y := RAY0.Y -
	  (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
	  ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y)
    END;

  RAY0.Z := RAY0.Z -
      (ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z +
      ZBA_SURFACE [SurfaceOrdinal].ZBR_VERTEX_DELTA_Z);

(**  We will now express the x,y,z coordinates of the originating point of
     the incident light ray in terms of their values in the local, rotated
     surface vertex coordinate system.	To do this we use the previously
     computed coordinate transformation (direction cosine) matrix associated
     with this surface.	 The matrix relationship is

	       | X' |	  | T11 T12 T13 |  | X |
	       | Y' |  =  | T21 T22 T23 |  | Y |
	       | Z' |	  | T31 T32 T33 |  | Z |,

     where X, Y, and Z are the coordinates of the starting point of the
     incident light ray in the reference coordinate system, and X', Y',
     and Z' are the coordinates as expressed in the local coordinate system
     "attached" to the surface vertex.	**)

  IF ZVA_ROTATION_MATRIX [SurfaceOrdinal].
      ZVL_COORDINATE_ROTATION_NEEDED THEN
    BEGIN
      F45AD_X0_HOLD := RAY0.X;
      F45AE_Y0_HOLD := RAY0.Y;
      F45AF_Z0_HOLD := RAY0.Z;

      RAY0.X := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T11 * F45AD_X0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T12 * F45AE_Y0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T13 * F45AF_Z0_HOLD;
      RAY0.Y := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T21 * F45AD_X0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T22 * F45AE_Y0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T23 * F45AF_Z0_HOLD;
      RAY0.Z := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T31 * F45AD_X0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T32 * F45AE_Y0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T33 * F45AF_Z0_HOLD;

(**  We will now perform the same procedure to obtain the magnitudes of the
     components of the vector representing the incident light ray.  **)

      F45AA_A0_HOLD := RAY0.A;
      F45AB_B0_HOLD := RAY0.B;
      F45AC_C0_HOLD := RAY0.C;

      RAY0.A := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T11 * F45AA_A0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T12 * F45AB_B0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T13 * F45AC_C0_HOLD;
      RAY0.B := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T21 * F45AA_A0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T22 * F45AB_B0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T23 * F45AC_C0_HOLD;
      RAY0.C := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T31 * F45AA_A0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T32 * F45AB_B0_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T33 * F45AC_C0_HOLD
    END;

  IF ABS (RAY0.X) < 1.0E-12 THEN
    RAY0.X := 0.0;

  IF ABS (RAY0.Y) < 1.0E-12 THEN
    RAY0.Y := 0.0;

  IF ABS (RAY0.Z) < 1.0E-12 THEN
    RAY0.Z := 0.0;

  IF ABS (RAY0.A) < 1.0E-12 THEN
    RAY0.A := 0.0;

  IF ABS (RAY0.B) < 1.0E-12 THEN
    RAY0.B := 0.0;

  IF (RAY0.A = 0.0)
      AND (RAY0.B = 0.0) THEN
    IF RAY0.C > 0.0 THEN
      RAY0.C := 1.0
    ELSE
      RAY0.C := -1.0

END;




(**  ComputeLensletApertureXYOffset  ******************************************
******************************************************************************)

PROCEDURE ComputeLensletApertureXYOffset;

  VAR
      ODX                        : DOUBLE;
      ODY                        : DOUBLE;
      LensletSemiX               : DOUBLE;
      LensletSemiY               : DOUBLE;
      XIntercept                 : DOUBLE;
      YIntercept                 : DOUBLE;
      ULXIntercept               : DOUBLE;
      ULYIntercept               : DOUBLE;
      ULLensletXCoordinate       : DOUBLE;
      ULLensletYCoordinate       : DOUBLE;

      Column                     : INTEGER;
      Row                        : INTEGER;
      TotalColumns               : INTEGER;
      TotalRows                  : INTEGER;

BEGIN

  TempHoldIncidentRayTailXCoord := RAY0.X;
  TempHoldIncidentRayTailYCoord := RAY0.Y;

  LensletXCoordinate := 0.0;
  LensletYCoordinate := 0.0;

  (* Make sure that the incident light ray has a sufficient magnitude in the z
     direction. *)

  IF ABS (RAY0.C) > 0.4 THEN
    BEGIN
      TotalColumns := ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns;
      TotalRows := ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows;
      (* As a convenience, compute the outside dimensions of the array. *)
      ODX := ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns *
          ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX;
      ODY := ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows *
          ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY;
      LensletSemiX := 0.5 * ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX;
      LensletSemiY := 0.5 * ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY;
      (* Where does the incident light ray hit a plane corresponding to the
        lenslet array? *)
      XIntercept := RAY0.X - (RAY0.A / RAY0.C) * RAY0.Z;
      YIntercept := RAY0.Y - (RAY0.B / RAY0.C) * RAY0.Z;
      (* Verify that the ray intercept on the plane is within the stated
         bounds. *)
      IF (ABS (XIntercept) < (0.5 * ODX))
          AND (ABS (YIntercept) < (0.5 * ODY)) THEN
        BEGIN
          (* Translate the ray X and Y plane intercepts into a coordinate
             system with origin at the upper left corner of the lenslet
             array. *)
          ULXIntercept := XIntercept + 0.5 * ODX;
          ULYIntercept := YIntercept - 0.5 * ODY;
          (* Get 0-based column and row coordinates of upper left corner of
             intercepted lenslet. *)
          Column := trunc ((ULXIntercept / ODX) * TotalColumns);
          Row := trunc ((ULYIntercept / ODY) * TotalRows);
          (* Get X and Y coordinates of the vertex of the intercepted
             lenslet. Origin of coordinates is upper left corner of array. *)
          ULLensletXCoordinate := (Column / TotalColumns) * ODX + LensletSemiX;
          ULLensletYCoordinate := (Row / TotalRows) * ODY - LensletSemiY;
          (* De-translate vertex coordinates of intercepted lenslet back into
             coordinate system centered at the center of the lenslet array. *)
          LensletXCoordinate := ULLensletXCoordinate - 0.5 * ODX;
          LensletYCoordinate := ULLensletYCoordinate + 0.5 * ODY;
          (* Translate tail of incident light ray into the vertex coordinates
             of the intercepted lenslet. *)
          RAY0.X := RAY0.X - LensletXCoordinate;
          RAY0.Y := RAY0.Y - LensletYCoordinate
        END
      ELSE
        F01AB_NO_INTERSECTION := TRUE
    END
  ELSE
    F01AB_NO_INTERSECTION := TRUE

END;




(**  F50_INTERSECT_SURFACE  ***************************************************
******************************************************************************)


PROCEDURE F50_INTERSECT_SURFACE;

  VAR
      F50AA_TWO_INTERCEPTS		       : BOOLEAN;
      OutsideSquare                            : BOOLEAN;
      OutsideElliptical                        : BOOLEAN;
      OutsideDimensSpecd                       : BOOLEAN;
      InsideDimensSpecd                        : BOOLEAN;
      InsideSquare                             : BOOLEAN;
      InsideElliptical                         : BOOLEAN;

      ABS_MAG				       : DOUBLE;
      TEMP_X0				       : DOUBLE;
      TEMP_A0				       : DOUBLE;
      TEMP_B0				       : DOUBLE;
      TEMP_C0				       : DOUBLE;
      L					       : DOUBLE;
      M					       : DOUBLE;
      U					       : DOUBLE;
      V					       : DOUBLE;
      W					       : DOUBLE;
      UNDER_RADICAL			       : DOUBLE;
      X2				       : DOUBLE;
      Y2				       : DOUBLE;
      Z2				       : DOUBLE;
      X3				       : DOUBLE;
      Y3				       : DOUBLE;
      Z3				       : DOUBLE;
      D2				       : DOUBLE;
      D3				       : DOUBLE;
      Z_MIDDLE				       : DOUBLE;
      ApertureShiftX                           : DOUBLE;
      ApertureShiftY                           : DOUBLE;
      OutsideWidthX                            : DOUBLE;
      OutsideWidthY                            : DOUBLE;
      OutsideDia                               : DOUBLE;
      InsideWidthX                             : DOUBLE;
      InsideWidthY                             : DOUBLE;
      InsideDia                                : DOUBLE;
      LambdaSquared                            : DOUBLE;
      Lambda4th                                : DOUBLE;

      I					       : INTEGER;


(**  InitializeVariables  *****************************************************
******************************************************************************)

PROCEDURE InitializeVariables;

PROCEDURE ApplyRadiusManufacturingError;

  VAR
      Sigma     : DOUBLE;
      Range     : DOUBLE;
      Azimuth   : DOUBLE;
      Error     : DOUBLE;

BEGIN

  IF SurfaceOrdinal = 3 THEN
    BEGIN
      Sigma := 0.002938748;
      R := 0.2649108
    END
  ELSE
  IF SurfaceOrdinal = 4 THEN
    BEGIN
      Sigma := 0.008060811;
      R := 0.2494524
    END
  ELSE
    BEGIN
      Sigma := 0.005313185;
      R := 0.2530041
    END;

(*Sigma := 0.01;*)

  RANDGEN;
  Range := SQRT (-2.0 * LN (RANDOM)) * Sigma;
  RANDGEN;
  Azimuth := 2.0 * PI * RANDOM;
  Error := Range * SIN (Azimuth);

  R := R + Error

END;

PROCEDURE ApplyAsphericShapeManufacturingError;

  VAR
      Sigma     : DOUBLE;
      Range     : DOUBLE;
      Azimuth   : DOUBLE;
      Error     : DOUBLE;

BEGIN

  IF SurfaceOrdinal = 3 THEN
    BEGIN
      Sigma := 1.059375;
      CC := -2.51494
    END
  ELSE
  IF SurfaceOrdinal = 4 THEN
    BEGIN
      Sigma := 3.183725;
      CC := -4.90806
    END
  ELSE
    BEGIN
      Sigma := 2.827139;
      CC := -14.6536
    END;

(*Sigma := 4;*)

  RANDGEN;
  Range := SQRT (-2.0 * LN (RANDOM)) * Sigma;
  RANDGEN;
  Azimuth := 2.0 * PI * RANDOM;
  Error := Range * SIN (Azimuth);

  CC := CC + Error

END;

BEGIN

  F50AA_TWO_INTERCEPTS := TRUE;
  F01AB_NO_INTERSECTION := FALSE;
  R := ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV;
  (*IF (SurfaceOrdinal = 3)
      OR (SurfaceOrdinal = 4)
      OR (SurfaceOrdinal = 5) THEN
    ApplyRadiusManufacturingError;*)
  CC := ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT;
  (*IF (SurfaceOrdinal = 3)
      OR (SurfaceOrdinal = 4)
      OR (SurfaceOrdinal = 5) THEN
    ApplyAsphericShapeManufacturingError;*)
  ApertureShiftX := ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X;
  ApertureShiftY := ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y;
  OutsideSquare := ZBA_SURFACE [SurfaceOrdinal].
      ZCL_OUTSIDE_APERTURE_IS_SQR;
  OutsideWidthX := ZBA_SURFACE [SurfaceOrdinal].
      ZCP_OUTSIDE_APERTURE_WIDTH_X;
  OutsideWidthY := ZBA_SURFACE [SurfaceOrdinal].
      ZCQ_OUTSIDE_APERTURE_WIDTH_Y;
  OutsideElliptical := ZBA_SURFACE [SurfaceOrdinal].
      ZCN_OUTSIDE_APERTURE_ELLIPTICAL;
  OutsideDimensSpecd := ZBA_SURFACE [SurfaceOrdinal].
      ZBH_OUTSIDE_DIMENS_SPECD;
  OutsideDia := ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA;
  InsideDimensSpecd := ZBA_SURFACE [SurfaceOrdinal].
      ZCT_INSIDE_DIMENS_SPECD;
  InsideSquare := ZBA_SURFACE [SurfaceOrdinal].
      ZCM_INSIDE_APERTURE_IS_SQR;
  InsideWidthX := ZBA_SURFACE [SurfaceOrdinal].
      ZCR_INSIDE_APERTURE_WIDTH_X;
  InsideWidthY := ZBA_SURFACE [SurfaceOrdinal].
      ZCS_INSIDE_APERTURE_WIDTH_Y;
  InsideElliptical := ZBA_SURFACE [SurfaceOrdinal].
      ZCO_INSIDE_APERTURE_ELLIPTICAL;
  InsideDia := ZBA_SURFACE [SurfaceOrdinal].
      ZBK_INSIDE_APERTURE_DIA

END;




(**  FindAsphericIntercept  **************************************************
*****************************************************************************)


PROCEDURE FindAsphericIntercept;

  CONST
      F50AM_MAXIMUM_ACCEPTABLE_ITERATION_ERROR = 1.0E-12;
      F50AO_MAX_ITERATIONS		       = 25;

  VAR
      D					       : DOUBLE;
      XS				       : DOUBLE;
      YS				       : DOUBLE;
      ZS				       : DOUBLE;
      XA				       : DOUBLE;
      YA				       : DOUBLE;
      ZA				       : DOUBLE;
      XP				       : DOUBLE;
      YP				       : DOUBLE;
      ZP				       : DOUBLE;
      VECTOR_MAGNITUDE                         : DOUBLE;
      F50AK_ITERATION_ERROR		       : DOUBLE;

      F50AN_LOOP_COUNTER		       : INTEGER;
      I                                        : INTEGER;

      F50AL_ITERATION_ERROR_ACCEPTABLE	       : BOOLEAN;

BEGIN

(*   This procedure is invoked if ZBA_SURFACE [SurfaceOrdinal].
     ZCE_USE_DEFORMATION_CONSTANTS is TRUE.  This means that the user has
     defined one or more higher order aspheric deformation constants.  Since
     there is no elegant simultaneous solution for the point of intersection
     between a line and a higher-order aspheric, we will use an iterative
     approach to find the point of intersection.

     The "industry standard" sag equation is generally stated to be

      sag = (H^2/R)/(1 + sqrt(1 - (CC + 1)(H^2/R^2))) +
		A0H^4 + A1H^6 + A2H^8 + A3H^10

      where:
	      sag is displacement along the z-axis,
	      H is the distance from the z-axis (equals sqrt (X^2 + Y^2)),
	      R is the radius of curvature (always positive),
	      CC is the conic constant, with values and meanings of:
		  CC < -1     : Hyperboloid
		  CC = -1     : Paraboloid
		  -1 < CC < 0 : Ellipsoid of revolution about major axis
		  CC = 0      : Sphere
		  CC > 0      : Ellipsoid of revolution about minor axis,
	  and A0, A1, A2, and A3 are the aspheric deformation constants.

     The aspheric sag equation used by LADS is identical to the industry
     standard equation, except that all terms on the right side of the
     equation are multiplied by -1, thus forcing the equation to yield
     negative values of sag.  If the gradient of the LADS equation is taken
     at the vertex of the surface, a vector colinear and codiretional with
     the z axis will be obtained.

     Our initial task is to compute the point of intersection of the
     incoming light ray with the tangent sphere.  This yields a set of
     three coordinates (Xs,Ys,Zs), where the subscript "s" stands for
     the tangent sphere.  We now compute an initial value for Za (where
     the subscript "a" refers to the aspheric surface) by utilizing the
     aspheric sag equation and the values for Xs and Ys.  We are now in a
     position to compare the value Zs against the value Za.  If the
     difference between the two values is acceptably small, then there is
     no further work to be done.  However, this will usually not be the
     case, and the following iterative procedure will be invoked:

     1.)  Compute aspheric surface normal vector at point (Xa,Ya,Za).
	  (Recall that Xa=Xs and Ya=Ys.)  This is done by taking the
	  partial derivative of the aspheric sag equation with respect to
	  x, y, and z respectively, to yield:

	  Nx = X*[((H^2*(CC + 1))/(R^3*Q^2*SQRT(P))) + (2/(R*Q)) +
	       4*A0*H^2 + 6*A1*H^4 + 8*A2*H^6 + 10*A3*H^8 + ...]

	  Ny = Y*[((H^2*(CC + 1))/(R^3*Q^2*SQRT(P))) + (2/(R*Q)) +
	       4*A0*H^2 + 6*A1*H^4 + 8*A2*H^6 + 10*A3*H^8 + ...]

	  Nz = 1

	  where:  Q   = 1 + SQRT (P)
	          P   = [1 - (CC + 1) * H^2 / R^2]
	          H^2 = X^2 + Y^2

     2.)  We now find the point of intersection between the incoming light
	  ray and the tangent plane represented by the surface normal
	  vector obtained in step 1.), as follows:

	  Equation of plane:
	    d = Nx*X + Ny*Y + Nz*Z,   where d = Nx*Xa + Ny*Ya + Nz*Za

	  Equation of line:
	    (X - Xs)/A = (Y - Ys)/B = (Z - Zs)/C
	    where A = x component of light ray vector
		  B = y component of light ray vector
		  C = z component of light ray vector

	  Solving for X and Y in terms of Z (from line equation):
	    X = ((Z - Zs)/C)*A + Xs
	    Y = ((Z - Zs)/C)*B + Ys

	  Substituting X and Y in equation of plane:
	    d = Nx*(((Z - Zs)/C)*A + Xs) + Ny*(((Z - Zs)/C)*B + Ys) + Nz*Z

	  Solving for Z:
	    Zp = (d + V*Zs - Nx*Xs - Ny*Ys) / (V + Nz)

	  where V = (Nx*A + Ny*B) / C

	  and where subscript "p" stands for point of intersection of incident
	  light ray with aspheric surface tangent plane.

	  Solving for Xp and Yp:
	    Xp = ((Zp - Zs)/C)*A + Xs
	    Yp = ((Zp - Zs)/C)*B + Ys

     3.)  We are now in a position to recompute Za from the aspheric sag
	  equation, based on the values just obtained for Xp and Yp
	  (i.e., H = (Xp**2 + Yp**2)**0.5).

     4.)  Compare new value for Za obtained in step 3.) against value for
	  Zp obtained in step 2.).  If the difference Za-Zp is
	  acceptably small, then the iteration ends; if not, then repeat
	  steps 1.) thru 4.) after performing the substitution
				Xs = Xp, Ys = Yp.
	  (The subscripts "s" on Xs and Ys no longer refer to points on the
	  tangent sphere, but, rather, points on the tangent plane.)  *)

  F50AA_TWO_INTERCEPTS := FALSE;

  FOR I := 1 TO CZAI_MAX_DEFORM_CONSTANTS DO
    C [I] := ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
	ZCA_DEFORMATION_CONSTANT [I];

  XS := RAY1.X;
  YS := RAY1.Y;
  ZS := RAY1.Z;
  
  F50AL_ITERATION_ERROR_ACCEPTABLE := FALSE;
  F50AN_LOOP_COUNTER := 0;

  REPEAT
    BEGIN
      XA := XS;
      YA := YS;
      IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
	HH := YA * YA
      ELSE
	HH := XA * XA + YA * YA;
      H4 := HH * HH;
      H6 := H4 * HH;
      H8 := H4 * H4;
      H10 := H6 * H4;
      H12 := H6 * H6;
      H14 := H8 * H6;
      H16 := H8 * H8;
      H18 := H10 * H8;
      H20 := H10 * H10;
      H22 := H12 * H10;
      IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
	ZA := -1.0 * (C [1] * H4 + C [2] * H6 + C [3] * H8 + C [4] * H10 +
	    C [5] * H12 + C [6] * H14 + C [7] * H16 + C [8] * H18 +
	    C [9] * H20 + C [10] * H22)
      ELSE
	BEGIN
	  RR := R * R;
	  P := (1.0 - (CC + 1.0) * (HH / RR));
          IF P < 0.0 THEN
            F01AB_NO_INTERSECTION := TRUE
          ELSE
            BEGIN
	      Q := 1.0 + SQRT (P);
	      ZA := -1.0 * ((HH / (R * Q)) + C [1] * H4 + C [2] * H6 +
	          C [3] * H8 + C [4] * H10 + C [5] * H12 + C [6] * H14 +
	          C [7] * H16 + C [8] * H18 + C [9] * H20 + C [10] * H22)
            END
	END;
      IF F01AB_NO_INTERSECTION THEN
      ELSE
        BEGIN
	  F93_FIND_SURFACE_NORMAL (XA, YA, ZA);
          F50AK_ITERATION_ERROR := ZA - ZS;
          IF ABS (F50AK_ITERATION_ERROR) <=
	      F50AM_MAXIMUM_ACCEPTABLE_ITERATION_ERROR THEN
	    F50AL_ITERATION_ERROR_ACCEPTABLE := TRUE
          ELSE
	    BEGIN
	      IF ABS (RAY0.A) > ROOT_3_OVER_3 THEN  (* SQRT 1/3 *)
	        BEGIN
	          V := (NY * RAY0.B + NZ * RAY0.C) / RAY0.A;
	          D := NX * XA + NY * YA + NZ * ZA;
	          XP := (D + V * XS - NY * YS - NZ * ZS) / (V + NX);
	          YP := (((XP - XS) / RAY0.A) * RAY0.B) + YS;
	          ZP := (((XP - XS) / RAY0.A) * RAY0.C) + ZS
	        END
	      ELSE
	      IF ABS (RAY0.B) > ROOT_3_OVER_3 THEN
	        BEGIN
	          V := (NX * RAY0.A + NZ * RAY0.C) / RAY0.B;
	          D := NX * XA + NY * YA + NZ * ZA;
	          YP := (D + V * YS - NX * XS - NZ * ZS) / (V + NY);
	          XP := (((YP - YS) / RAY0.B) * RAY0.A) + XS;
	          ZP := (((YP - YS) / RAY0.B) * RAY0.C) + ZS
	        END
	      ELSE
	        BEGIN
	          V := (NX * RAY0.A + NY * RAY0.B) / RAY0.C;
	          D := NX * XA + NY * YA + NZ * ZA;
	          ZP := (D + V * ZS - NX * XS - NY * YS) / (V + NZ);
	          XP := (((ZP - ZS) / RAY0.C) * RAY0.A) + XS;
	          YP := (((ZP - ZS) / RAY0.C) * RAY0.B) + YS
	        END;
	      ZS := ZP;
	      XS := XP;
	      YS := YP;
	      F50AN_LOOP_COUNTER := F50AN_LOOP_COUNTER + 1;
	      IF F50AN_LOOP_COUNTER > F50AO_MAX_ITERATIONS THEN
	        F01AB_NO_INTERSECTION := TRUE
	    END
        END
    END
  UNTIL F50AL_ITERATION_ERROR_ACCEPTABLE
      OR F01AB_NO_INTERSECTION;

  IF NOT F01AB_NO_INTERSECTION THEN
    BEGIN
      X2 := XA;
      Y2 := YA;
      Z2 := ZA
    END
  ELSE
    IF NOT GraphicsActive THEN
      IF NOT ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
        BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('Could not find point of intersection between incident');
	  CommandIOMemo.IOHistory.Lines.add
              ('light ray and high-order aspheric surface ' +
              IntToStr (SurfaceOrdinal) + '.');
	  CommandIOMemo.IOHistory.Lines.add
              ('After ' + IntToStr (F50AO_MAX_ITERATIONS) + ' iterations,' +
	      ' iteration error was ' +
              FloatToStr (ABS (F50AK_ITERATION_ERROR)) + '.')
        END

END;




(**  FindConicIntercept  *****************************************************
*****************************************************************************)

PROCEDURE FindConicIntercept;


(**  COMPUTE_X_INTERCEPT  *****************************************************
******************************************************************************)


PROCEDURE COMPUTE_X_INTERCEPT;

BEGIN

  L := ((CC + 1.0) * RAY0.C * RAY0.C + RAY0.B * RAY0.B) / (RAY0.A * RAY0.A);
  M := ((CC + 1.0) * RAY0.C * RAY0.Z + RAY0.B * RAY0.Y + R * RAY0.C) / RAY0.A;
  U := L + 1.0;
  V := 2.0 * (M - L * RAY0.X);
  W := RAY0.X * RAY0.X * L - 2.0 * RAY0.X * M + (CC + 1.0) * RAY0.Z * RAY0.Z +
       2.0 * R * RAY0.Z + RAY0.Y * RAY0.Y;

(**  If "U" is very small (i.e., -1.0E-08 < U < 1.0E-08), this implies
     that the conic constant must be less than, or equal to, -1; which, in
     turn, implies an "open" conic section such as a parabola or hyperbola.
     In such cases where U is near zero, the quadratic equation
     for Z1
		   U * Z1*Z1  +	 V * Z1	 +  W  =  0
     becomes
		   V * Z1  +  W	 =  0.					**)

  IF ABS (U) < 1.0E-08 THEN
    BEGIN
      IF ABS (V) < 1.0E-12 THEN
	F01AB_NO_INTERSECTION := TRUE
      ELSE
	BEGIN
	  X2 := -W / V;
	  F50AA_TWO_INTERCEPTS := FALSE
	END
    END
  ELSE
    BEGIN
      UNDER_RADICAL := V * V - 4 * U * W;
      IF UNDER_RADICAL < 0.0 THEN
	F01AB_NO_INTERSECTION := TRUE
      ELSE
      IF UNDER_RADICAL >= 1.0E-12 THEN
	BEGIN
	  X2 := (-V + SQRT (UNDER_RADICAL)) / (2 * U);
	  X3 := (-V - SQRT (UNDER_RADICAL)) / (2 * U);
	END
      ELSE
	BEGIN
	  X2 := -V / (2 * U);
	  F50AA_TWO_INTERCEPTS := FALSE
	END
    END

  END;




(**  COMPUTE_Y_INTERCEPT  *****************************************************
******************************************************************************)


PROCEDURE COMPUTE_Y_INTERCEPT;

BEGIN

  L := ((CC + 1.0) * RAY0.C * RAY0.C + RAY0.A * RAY0.A) / (RAY0.B * RAY0.B);
  M := ((CC + 1.0) * RAY0.C * RAY0.Z + RAY0.A * RAY0.X + R * RAY0.C) / RAY0.B;
  U := L + 1.0;
  V := 2.0 * (M - L * RAY0.Y);
  W := RAY0.Y * RAY0.Y * L - 2.0 * RAY0.Y * M +
       (CC + 1.0) * RAY0.Z * RAY0.Z + 2.0 * R * RAY0.Z + RAY0.X * RAY0.X;

  IF ABS (U) < 1.0E-08 THEN
    BEGIN
      IF ABS (V) < 1.0E-12 THEN
	F01AB_NO_INTERSECTION := TRUE
      ELSE
	BEGIN
	  Y2 := -W / V;
	  F50AA_TWO_INTERCEPTS := FALSE
	END
    END
  ELSE
    BEGIN
      UNDER_RADICAL := V * V - 4 * U * W;
      IF UNDER_RADICAL < 0.0 THEN
	F01AB_NO_INTERSECTION := TRUE
      ELSE
      IF UNDER_RADICAL >= 1.0E-12 THEN
	BEGIN
	  Y2 := (-V + SQRT (UNDER_RADICAL)) / (2 * U);
	  Y3 := (-V - SQRT (UNDER_RADICAL)) / (2 * U);
	END
      ELSE
	BEGIN
	  Y2 := -V / (2 * U);
	  F50AA_TWO_INTERCEPTS := FALSE
	END
    END
      
  END;




(**  COMPUTE_Z_INTERCEPT  *****************************************************
******************************************************************************)


PROCEDURE COMPUTE_Z_INTERCEPT;

BEGIN

  L := (RAY0.A * RAY0.A + RAY0.B * RAY0.B) / (RAY0.C * RAY0.C);
  M := (RAY0.A * RAY0.X + RAY0.B * RAY0.Y) / RAY0.C;
  U := (CC + 1.0) + L;
  V := 2.0 * (M - L * RAY0.Z + R);
  W := L * RAY0.Z * RAY0.Z - 2.0 * RAY0.Z * M + RAY0.X * RAY0.X +
      RAY0.Y * RAY0.Y;
      
  IF ABS (U) < 1.0E-08 THEN
    BEGIN
      IF ABS (V) < 1.0E-12 THEN
	F01AB_NO_INTERSECTION := TRUE
      ELSE
	BEGIN
	  Z2 := -W / V;
	  F50AA_TWO_INTERCEPTS := FALSE
	END
    END
  ELSE
    BEGIN
      UNDER_RADICAL := V * V - 4 * U * W;
      IF UNDER_RADICAL < 0.0 THEN
	F01AB_NO_INTERSECTION := TRUE
      ELSE
      IF UNDER_RADICAL >= 1.0E-12 THEN
	BEGIN
	  Z2 := (-V + SQRT (UNDER_RADICAL)) / (2 * U);
	  Z3 := (-V - SQRT (UNDER_RADICAL)) / (2 * U);
	END
      ELSE
	BEGIN
	  Z2 := -V / (2 * U);
	  F50AA_TWO_INTERCEPTS := FALSE
	END
    END
  
END;




(**  FindConicIntercept  *****************************************************
*****************************************************************************)


BEGIN

  (* The "industry standard" aspheric sag equation reduces to
	 
	(CC + 1)Z^2 - 2RZ + H^2 = 0
	
     when the aspheric terms are zero.  The sag equation used by LADS for
     all conic surfaces is
  
	(CC + 1)Z^2 + 2RZ + H^2 = 0
	
     which is identical, except for the reversed sign on the "2RZ" term.
     The solution of the LADS quadratic equation always yields negative
     values for sag (except in the case of a hyperbola, where both negative
     and positive values are produced).  The "+" solution of the quadratic
     equation is always used, except when a closed surface has been specified.

     The LADS sag equation above is consistent with a surface which is
     axially symmetric with the z-axis, and which opens up toward the
     negative z direction.  The gradient of the surface at the surface
     vertex (i.e., the surface normal vector) is, thus, a vector parallel
     to, and in the same direction as, the positive z axis.

     For a parabola, where CC = -1, the sag
     equation reduces to

	2 * R * Z + H**2 = 0

     or

	Z = -1.0 * H**2 / (2 * R).

     The following code uses a closed-form solution for establishing the
     coordinates of the point of intersection between a line and a conic
     surface.  If the surface is defined as a high-order asphere, the high
     order terms will be initially ignored and the following code will be
     used first to establish a point of intersection between the incident
     light ray and a simple conic surface with conic consant CC and radius R.
     The actual point of intersection between the incident light ray and the
     high-order aspheric surface is then obtained by an iterative process. *)

  IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
    BEGIN
      IF ABS (RAY0.C) <= 1.0E-12 THEN
	F01AB_NO_INTERSECTION := TRUE
      ELSE
	BEGIN
	  F50AA_TWO_INTERCEPTS := FALSE;
	  X2 := RAY0.X - (RAY0.A / RAY0.C) * RAY0.Z;
	  Y2 := RAY0.Y - (RAY0.B / RAY0.C) * RAY0.Z;
	  Z2 := 0.0
	END
    END
  ELSE
    BEGIN
      IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
	BEGIN
	  TEMP_A0 := RAY0.A;
	  RAY0.A := 0.0;
	  TEMP_X0 := RAY0.X;
	  RAY0.X := 0.0;
	  TEMP_B0 := RAY0.B;
	  TEMP_C0 := RAY0.C;
	  ABS_MAG := SQRT (RAY0.B * RAY0.B + RAY0.C * RAY0.C);
	  IF ABS_MAG > 1.0E-10 THEN
	    BEGIN
	      RAY0.B := RAY0.B / ABS_MAG;
	      RAY0.C := RAY0.C / ABS_MAG
	    END
	  ELSE
	    BEGIN
	      RAY0.A := TEMP_A0;
	      RAY0.X := TEMP_X0;
	      RAY0.B := TEMP_B0;
	      RAY0.C := TEMP_C0;
	      F01AB_NO_INTERSECTION := TRUE
	    END
	END;
      IF NOT F01AB_NO_INTERSECTION THEN
	IF ABS (RAY0.A) > ROOT_3_OVER_3 THEN  (* SQRT 1/3 *)
	  BEGIN
	    COMPUTE_X_INTERCEPT;
	    IF NOT F01AB_NO_INTERSECTION THEN
	      BEGIN
		Y2 := ((X2 - RAY0.X) / RAY0.A) * RAY0.B + RAY0.Y;
		Z2 := ((X2 - RAY0.X) / RAY0.A) * RAY0.C + RAY0.Z;
		IF F50AA_TWO_INTERCEPTS THEN
		  BEGIN
		    Y3 := ((X3 - RAY0.X) / RAY0.A) * RAY0.B + RAY0.Y;
		    Z3 := ((X3 - RAY0.X) / RAY0.A) * RAY0.C + RAY0.Z
		  END
	      END
	  END
	ELSE
	IF ABS (RAY0.B) > ROOT_3_OVER_3 THEN
	  BEGIN
	    COMPUTE_Y_INTERCEPT;
	    IF NOT F01AB_NO_INTERSECTION THEN
	      BEGIN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
		  BEGIN
		    RAY0.A := TEMP_A0;
		    RAY0.X := TEMP_X0;
		    RAY0.B := TEMP_B0;
		    RAY0.C := TEMP_C0
		  END;
		X2 := ((Y2 - RAY0.Y) / RAY0.B) * RAY0.A + RAY0.X;
		Z2 := ((Y2 - RAY0.Y) / RAY0.B) * RAY0.C + RAY0.Z;
		IF F50AA_TWO_INTERCEPTS THEN
		  BEGIN
		    X3 := ((Y3 - RAY0.Y) / RAY0.B) * RAY0.A + RAY0.X;
		    Z3 := ((Y3 - RAY0.Y) / RAY0.B) * RAY0.C + RAY0.Z
		  END
	      END
	  END
	ELSE
	  BEGIN
	    COMPUTE_Z_INTERCEPT;
	    IF NOT F01AB_NO_INTERSECTION THEN
	      BEGIN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
		  BEGIN
		    RAY0.A := TEMP_A0;
		    RAY0.X := TEMP_X0;
		    RAY0.B := TEMP_B0;
		    RAY0.C := TEMP_C0
		  END;
		X2 := ((Z2 - RAY0.Z) / RAY0.C) * RAY0.A + RAY0.X;
		Y2 := ((Z2 - RAY0.Z) / RAY0.C) * RAY0.B + RAY0.Y;
		IF F50AA_TWO_INTERCEPTS THEN
		  BEGIN
		    X3 := ((Z3 - RAY0.Z) / RAY0.C) * RAY0.A + RAY0.X;
		    Y3 := ((Z3 - RAY0.Z) / RAY0.C) * RAY0.B + RAY0.Y
		  END
	      END
	  END
    END

END;




(**  CHECK_Z_VALUE  **********************************************************
*****************************************************************************)

PROCEDURE CHECK_Z_VALUE;

BEGIN

  (* Throw out Z intercept values > 0.0 *)

  IF ABS (Z2) <= 1.0E-12 THEN
    Z2 := 0.0;

  IF F50AA_TWO_INTERCEPTS THEN
    IF ABS (Z3) <= 1.0E-12 THEN
      Z3 := 0.0;

  IF F50AA_TWO_INTERCEPTS THEN
    IF Z3 > 0.0 THEN
      F50AA_TWO_INTERCEPTS := FALSE;

  IF Z2 > 0.0 THEN
    IF F50AA_TWO_INTERCEPTS THEN
      BEGIN
	F50AA_TWO_INTERCEPTS := FALSE;
	X2 := X3;
	Y2 := Y3;
	Z2 := Z3
      END
    ELSE
      F01AB_NO_INTERSECTION := TRUE

END;




(**  CHECK_CLEAR_APERTURE  ***************************************************
This procedure determines two things: (1) whether or not the intercept lies
within the confines of the outside perimeter of the surface; and (2) whether
or not the intercept lands inside any defined internal aperture.

There is complicated logic regarding how to handle a user-specified
aperture shift.  If an aperture shift is specified and an internal aperture is
also defined, then the aperture shift will apply only to the internal aperture.
If no internal aperture is defined, then the aperture shift will be applied to
the user-defined outer perimeter of the surface.
*****************************************************************************)

PROCEDURE CHECK_CLEAR_APERTURE;

VAR
      CoordinateTranslationReqd  : BOOLEAN;
      ShiftIntercept             : BOOLEAN;

      HOLD_X2                    : DOUBLE;
      HOLD_Y2                    : DOUBLE;
      HOLD_X3                    : DOUBLE;
      HOLD_Y3                    : DOUBLE;

BEGIN

  (* Process outer perimeter. *)

  IF OutsideDimensSpecd THEN
    BEGIN
      (* Determine whether or not an internal aperture is defined.  If an
      internal aperture is defined, and an aperture shift is specified, then the
      aperture shift will apply only to the internal aperture and not to the
      outer perimeter of the surface.  If no internal aperture is defined, and
      an outer perimeter is specified, the aperture shift will be applied to the
      outer perimeter of the surface. *)
      CoordinateTranslationReqd := FALSE;
      ShiftIntercept := FALSE;
      IF (ABS (ApertureShiftX) > 1.0E-12)
          OR (ABS (ApertureShiftY) > 1.0E-12) THEN
        IF InsideDimensSpecd THEN
          BEGIN
            (* Aperture shift will not be applied to outer perimeter. *)
          END
        ELSE
          BEGIN
            CoordinateTranslationReqd := TRUE;
            HOLD_X2 := X2;
            X2 := X2 - ApertureShiftX;
            HOLD_X3 := X3;
            X3 := X3 - ApertureShiftX;
            HOLD_Y2 := Y2;
            Y2 := Y2 - ApertureShiftY;
            HOLD_Y3 := Y3;
            Y3 := Y3 - ApertureShiftY
          END;
      IF OutsideSquare THEN
        BEGIN
          IF F50AA_TWO_INTERCEPTS THEN
            BEGIN
              IF (ABS (X2) < (0.5 * OutsideWidthX))
      	          AND (ABS (Y2) < (0.5 * OutsideWidthY)) THEN
                BEGIN
                  IF (ABS (X3) < (0.5 * OutsideWidthX))
      	              AND (ABS (Y3) < (0.5 * OutsideWidthY)) THEN
                    BEGIN
                    END
                  ELSE
                    BEGIN
                      F50AA_TWO_INTERCEPTS := FALSE
                    END
                END
              ELSE
                BEGIN
                  F50AA_TWO_INTERCEPTS := FALSE;
                  IF (ABS (X3) < (0.5 * OutsideWidthX))
      	              AND (ABS (Y3) < (0.5 * OutsideWidthY)) THEN
                    BEGIN
                      ShiftIntercept := TRUE
                    END
                  ELSE
                    BEGIN
                      F01AB_NO_INTERSECTION := TRUE
                    END
                END
            END
          ELSE
            BEGIN
              IF (ABS (X2) < (0.5 * OutsideWidthX))
      	          AND (ABS (Y2) < (0.5 * OutsideWidthY)) THEN
                BEGIN
                END
              ELSE
                BEGIN
                  F01AB_NO_INTERSECTION := TRUE
                END
            END
        END
      ELSE
      IF OutsideElliptical THEN
        BEGIN
          IF F50AA_TWO_INTERCEPTS THEN
            BEGIN
              IF ((X2 * X2 / SQR (0.5 * OutsideWidthX)) +
      	          (Y2 * Y2 / SQR (0.5 * OutsideWidthY))) < 1.0 THEN
                BEGIN
                  IF ((X3 * X3 / SQR (0.5 * OutsideWidthX)) +
      	              (Y3 * Y3 / SQR (0.5 * OutsideWidthY))) < 1.0 THEN
                    BEGIN
                    END
                  ELSE
                    BEGIN
                      F50AA_TWO_INTERCEPTS := FALSE
                    END
                END
              ELSE
                BEGIN
                  F50AA_TWO_INTERCEPTS := FALSE;
                  IF ((X3 * X3 / SQR (0.5 * OutsideWidthX)) +
      	              (Y3 * Y3 / SQR (0.5 * OutsideWidthY))) < 1.0 THEN
                    BEGIN
                      ShiftIntercept := TRUE
                    END
                  ELSE
                    BEGIN
                      F01AB_NO_INTERSECTION := TRUE
                    END
                END
            END
          ELSE
            BEGIN
              IF ((X2 * X2 / SQR (0.5 * OutsideWidthX)) +
      	          (Y2 * Y2 / SQR (0.5 * OutsideWidthY))) < 1.0 THEN
                BEGIN
                END
              ELSE
                BEGIN
                  F01AB_NO_INTERSECTION := TRUE
                END
            END
        END
      ELSE
        (* Check circular outside aperture. *)
        BEGIN
          IF F50AA_TWO_INTERCEPTS THEN
            BEGIN
              IF (SQRT (X2 * X2 + Y2 * Y2) < (0.5 * OutsideDia)) THEN
                BEGIN
                  IF (SQRT (X3 * X3 + Y3 * Y3) < (0.5 * OutsideDia)) THEN
                    BEGIN
                    END
                  ELSE
                    BEGIN
                      F50AA_TWO_INTERCEPTS := FALSE
                    END
                END
              ELSE
                BEGIN
                  F50AA_TWO_INTERCEPTS := FALSE;
                  IF (SQRT (X3 * X3 + Y3 * Y3) < (0.5 * OutsideDia)) THEN
                    BEGIN
                      ShiftIntercept := TRUE
                    END
                  ELSE
                    BEGIN
                      F01AB_NO_INTERSECTION := TRUE
                    END
                END
            END
          ELSE
            BEGIN
              IF (SQRT (X2 * X2 + Y2 * Y2) < (0.5 * OutsideDia)) THEN
                BEGIN
                END
              ELSE
                BEGIN
                  F01AB_NO_INTERSECTION := TRUE
                END
            END
        END;
      IF CoordinateTranslationReqd THEN
        BEGIN
          X2 := HOLD_X2;
          X3 := HOLD_X3;
          Y2 := HOLD_Y2;
          Y3 := HOLD_Y3
        END;
      IF ShiftIntercept THEN
        BEGIN
          X2 := X3;
          Y2 := Y3;
          Z2 := Z3
        END
    END;

  (* Now we can determine whether the intercepts lie within any defined
     internal apertures.  Here we use the opposite logic, i.e., if the
     intercept lies within a defined internal aperture, the intercept is
     discarded. *)

  IF NOT F01AB_NO_INTERSECTION THEN
    IF InsideDimensSpecd THEN
      BEGIN
        (* Do temporary coordinate translation into local internal
           aperture coordinates. *)
        CoordinateTranslationReqd := FALSE;
        ShiftIntercept := FALSE;
        IF (ABS (ApertureShiftX) > 1.0E-12)
            OR (ABS (ApertureShiftY) > 1.0E-12) THEN
          BEGIN
            CoordinateTranslationReqd := TRUE;
            HOLD_X2 := X2;
            X2 := X2 - ApertureShiftX;
            HOLD_X3 := X3;
            X3 := X3 - ApertureShiftX;
            HOLD_Y2 := Y2;
            Y2 := Y2 - ApertureShiftY;
            HOLD_Y3 := Y3;
            Y3 := Y3 - ApertureShiftY
          END;
        IF InsideSquare THEN
          BEGIN
            IF F50AA_TWO_INTERCEPTS THEN
              BEGIN
                IF NOT ((ABS (X2) < (0.5 * InsideWidthX))
	            AND (ABS (Y2) < (0.5 * InsideWidthY))) THEN
                  BEGIN
                    IF NOT ((ABS (X3) < (0.5 * InsideWidthX))
	                AND (ABS (Y3) < (0.5 * InsideWidthY))) THEN
                      BEGIN
                      END
                    ELSE
                      BEGIN
                        F50AA_TWO_INTERCEPTS := FALSE
                      END
                  END
                ELSE
                  BEGIN
                    F50AA_TWO_INTERCEPTS := FALSE;
                    IF NOT ((ABS (X3) < (0.5 * InsideWidthX))
	                AND (ABS (Y3) < (0.5 * InsideWidthY))) THEN
                      BEGIN
                        ShiftIntercept := TRUE
                      END
                    ELSE
                      BEGIN
                        F01AB_NO_INTERSECTION := TRUE
                      END
                  END
              END
            ELSE
              BEGIN
                IF NOT ((ABS (X2) < (0.5 * InsideWidthX))
	            AND (ABS (Y2) < (0.5 * InsideWidthY))) THEN
                  BEGIN
                  END
                ELSE
                  BEGIN
                    F01AB_NO_INTERSECTION := TRUE
                  END
              END
          END
        ELSE
        IF InsideElliptical THEN
          BEGIN
            IF F50AA_TWO_INTERCEPTS THEN
              BEGIN
                IF NOT (((X2 * X2 / SQR (0.5 * InsideWidthX)) +
	            (Y2 * Y2 / SQR (0.5 * InsideWidthY))) < 1.0) THEN
                  BEGIN
                    IF NOT (((X3 * X3 / SQR (0.5 * InsideWidthX)) +
	                (Y3 * Y3 / SQR (0.5 * InsideWidthY))) < 1.0) THEN
                      BEGIN
                      END
                    ELSE
                      BEGIN
                        F50AA_TWO_INTERCEPTS := FALSE
                      END
                  END
                ELSE
                  BEGIN
                    F50AA_TWO_INTERCEPTS := FALSE;
                    IF NOT (((X3 * X3 / SQR (0.5 * InsideWidthX)) +
	                (Y3 * Y3 / SQR (0.5 * InsideWidthY))) < 1.0) THEN
                      BEGIN
                        ShiftIntercept := TRUE
                      END
                    ELSE
                      BEGIN
                        F01AB_NO_INTERSECTION := TRUE
                      END
                  END
              END
            ELSE
              BEGIN
                IF NOT (((X2 * X2 / SQR (0.5 * InsideWidthX)) +
	            (Y2 * Y2 / SQR (0.5 * InsideWidthY))) < 1.0) THEN
                  BEGIN
                  END
                ELSE
                  BEGIN
                    F01AB_NO_INTERSECTION := TRUE
                  END
              END
          END
        ELSE
          (* Check circular inside aperture. *)
          BEGIN
            IF F50AA_TWO_INTERCEPTS THEN
              BEGIN
                IF NOT (SQRT (X2 * X2 + Y2 * Y2) < (0.5 * InsideDia)) THEN
                  BEGIN
                    IF NOT (SQRT (X3 * X3 + Y3 * Y3) < (0.5 * InsideDia)) THEN
                      BEGIN
                      END
                    ELSE
                      BEGIN
                        F50AA_TWO_INTERCEPTS := FALSE
                      END
                  END
                ELSE
                  BEGIN
                    F50AA_TWO_INTERCEPTS := FALSE;
                    IF NOT (SQRT (X3 * X3 + Y3 * Y3) < (0.5 * InsideDia)) THEN
                      BEGIN
                        ShiftIntercept := TRUE
                      END
                    ELSE
                      BEGIN
                        F01AB_NO_INTERSECTION := TRUE
                      END
                  END
              END
            ELSE
              BEGIN
                IF NOT (SQRT (X2 * X2 + Y2 * Y2) < (0.5 * InsideDia)) THEN
                  BEGIN
                  END
                ELSE
                  BEGIN
                    F01AB_NO_INTERSECTION := TRUE
                  END
              END
          END;
        IF CoordinateTranslationReqd THEN
          BEGIN
            X2 := HOLD_X2;
            X3 := HOLD_X3;
            Y2 := HOLD_Y2;
            Y3 := HOLD_Y3
          END;
        IF ShiftIntercept THEN
          BEGIN
            X2 := X3;
            Y2 := Y3;
            Z2 := Z3
          END
      END;

(*HOLD_X2 := 0.0;
  HOLD_X3 := 0.0;
  HOLD_Y2 := 0.0;
  HOLD_Y3 := 0.0;

  (* Assure that intercepts are within clear aperture limits. *)

(*IF ABS (ApertureShiftX) > 1.0E-12 THEN
    BEGIN
      HOLD_X2 := X2;
      X2 := X2 - ApertureShiftX
    END;

  IF ABS (ApertureShiftY) > 1.0E-12 THEN
    BEGIN
      HOLD_Y2 := Y2;
      Y2 := Y2 - ApertureShiftY
    END;

  IF F50AA_TWO_INTERCEPTS THEN
    BEGIN
      IF ABS (ApertureShiftX) > 1.0E-12 THEN
	BEGIN
	  HOLD_X3 := X3;
	  X3 := X3 - ApertureShiftX
	END;
      IF ABS (ApertureShiftY) > 1.0E-12 THEN
	BEGIN
	  HOLD_Y3 := Y3;
	  Y3 := Y3 - ApertureShiftY
	END;
      IF OutsideDimensSpecd THEN
	IF OutsideSquare THEN
	  IF (ABS (X3) < (0.5 * OutsideWidthX))
	    AND (ABS (Y3) < (0.5 * OutsideWidthY)) THEN
	    BEGIN
	    END
	  ELSE
	    F50AA_TWO_INTERCEPTS := FALSE
	ELSE
	IF OutsideElliptical THEN
	  IF ((X3 * X3 / SQR (0.5 * OutsideWidthX)) +
	      (Y3 * Y3 / SQR (0.5 * OutsideWidthY))) < 1.0 THEN
	    BEGIN
	    END
	  ELSE
	    F50AA_TWO_INTERCEPTS := FALSE
	ELSE
	  IF (SQRT (X3 * X3 + Y3 * Y3) <
	      (0.5 * OutsideDia)) THEN
	    BEGIN
	    END
	  ELSE
	    F50AA_TWO_INTERCEPTS := FALSE;
      IF InsideDimensSpecd THEN
	IF InsideSquare THEN
	  IF (ABS (X3) > (0.5 * InsideWidthX))
	    OR (ABS (Y3) > (0.5 * InsideWidthY)) THEN
	    BEGIN
	    END
	  ELSE
	    F50AA_TWO_INTERCEPTS := FALSE
	ELSE
	IF InsideElliptical THEN
	  IF ((X3 * X3 / SQR (0.5 * InsideWidthX)) +
	      (Y3 * Y3 / SQR (0.5 * InsideWidthY))) > 1.0 THEN
	    BEGIN
	    END
	  ELSE
	    F50AA_TWO_INTERCEPTS := FALSE
	ELSE
	  IF (SQRT (X3 * X3 + Y3 * Y3) >
	      (0.5 * InsideDia)) THEN
	    BEGIN
	    END
	  ELSE
	    F50AA_TWO_INTERCEPTS := FALSE
    END;

  IF OutsideDimensSpecd THEN
    IF OutsideSquare THEN
      IF (ABS (X2) < (0.5 * OutsideWidthX))
	AND (ABS (Y2) < (0.5 * OutsideWidthY)) THEN
	BEGIN
	END
      ELSE
	IF F50AA_TWO_INTERCEPTS THEN
	  BEGIN
	    F50AA_TWO_INTERCEPTS := FALSE;
	    X2 := X3;
	    HOLD_X2 := HOLD_X3;
	    Y2 := Y3;
	    HOLD_Y2 := HOLD_Y3;
	    Z2 := Z3
	  END
	ELSE
	  F01AB_NO_INTERSECTION := TRUE
    ELSE
    IF OutsideElliptical THEN
      IF ((X2 * X2 / SQR (0.5 * OutsideWidthX)) +
	  (Y2 * Y2 / SQR (0.5 * OutsideWidthY))) < 1.0 THEN
	BEGIN
	END
      ELSE
	IF F50AA_TWO_INTERCEPTS THEN
	  BEGIN
	    F50AA_TWO_INTERCEPTS := FALSE;
	    X2 := X3;
	    HOLD_X2 := HOLD_X3;
	    Y2 := Y3;
	    HOLD_Y2 := HOLD_Y3;
	    Z2 := Z3
	  END
	ELSE
	  F01AB_NO_INTERSECTION := TRUE
    ELSE
      IF (SQRT (X2 * X2 + Y2 * Y2) <
	  (0.5 * OutsideDia)) THEN
	BEGIN
	END
      ELSE
	IF F50AA_TWO_INTERCEPTS THEN
	  BEGIN
	    F50AA_TWO_INTERCEPTS := FALSE;
	    X2 := X3;
	    HOLD_X2 := HOLD_X3;
	    Y2 := Y3;
	    HOLD_Y2 := HOLD_Y3;
	    Z2 := Z3
	  END
	ELSE
	  F01AB_NO_INTERSECTION := TRUE;

  IF InsideDimensSpecd THEN
    IF InsideSquare THEN
      IF (ABS (X2) > (0.5 * InsideWidthX))
	OR (ABS (Y2) > (0.5 * InsideWidthY)) THEN
	BEGIN
	END
      ELSE
	IF F50AA_TWO_INTERCEPTS THEN
	  BEGIN
	    F50AA_TWO_INTERCEPTS := FALSE;
	    X2 := X3;
	    HOLD_X2 := HOLD_X3;
	    Y2 := Y3;
	    HOLD_Y2 := HOLD_Y3;
	    Z2 := Z3
	  END
	ELSE
	  F01AB_NO_INTERSECTION := TRUE
    ELSE
    IF InsideElliptical THEN
      IF ((X2 * X2 / SQR (0.5 * InsideWidthX)) +
	  (Y2 * Y2 / SQR (0.5 * InsideWidthY))) > 1.0 THEN
	BEGIN
	END
      ELSE
	IF F50AA_TWO_INTERCEPTS THEN
	  BEGIN
	    F50AA_TWO_INTERCEPTS := FALSE;
	    X2 := X3;
	    HOLD_X2 := HOLD_X3;
	    Y2 := Y3;
	    HOLD_Y2 := HOLD_Y3;
	    Z2 := Z3
	  END
	ELSE
	  F01AB_NO_INTERSECTION := TRUE
    ELSE
      IF (SQRT (X2 * X2 + Y2 * Y2) >
	  (0.5 * InsideDia)) THEN
	BEGIN
	END
      ELSE
	IF F50AA_TWO_INTERCEPTS THEN
	  BEGIN
	    F50AA_TWO_INTERCEPTS := FALSE;
	    X2 := X3;
	    HOLD_X2 := HOLD_X3;
	    Y2 := Y3;
	    HOLD_Y2 := HOLD_Y3;
	    Z2 := Z3
	  END
	ELSE
	  F01AB_NO_INTERSECTION := TRUE;

  IF ABS (ApertureShiftX) > 1.0E-12 THEN
    X2 := HOLD_X2;

  IF ABS (ApertureShiftY) > 1.0E-12 THEN
    Y2 := HOLD_Y2;

  IF F50AA_TWO_INTERCEPTS THEN
    BEGIN
      IF ABS (ApertureShiftX) > 1.0E-12 THEN
	X3 := HOLD_X3;
      IF ABS (ApertureShiftY) > 1.0E-12 THEN
	Y3 := HOLD_Y3
    END*)

END;




(**  CHECK_ANGULAR_APERTURE  *************************************************
*
*  An angular zone is formed between a circular ID and a circular OD, both
*  of which are centered on the axis of symmetry of the surface.  The angular
*  extent of the zone is the region bounded by the minimum and maximum
*  azimuth angles of the zone.
*
*****************************************************************************)

PROCEDURE CHECK_ANGULAR_APERTURE;

VAR
      ZoneCenterAzimuthRadians  : DOUBLE;
      ZoneAngularRadiusRadians  : DOUBLE;
      MaxZoneBound              : DOUBLE;
      MinZoneBound              : DOUBLE;
      AngleOffset               : DOUBLE;
      RadiusOfFirstIntercept    : DOUBLE;
      RadiusOfSecondIntercept   : DOUBLE;
      AzimuthOfFirstIntercept   : DOUBLE;
      AzimuthOfSecondIntercept  : DOUBLE;

BEGIN

  ZoneCenterAzimuthRadians := ApertureShiftX * pi / 180.0;
  ZoneAngularRadiusRadians := 0.5 * (ApertureShiftY * pi / 180.0);

  MinZoneBound := ZoneCenterAzimuthRadians - ZoneAngularRadiusRadians;

  IF MinZoneBound < 0.0 THEN
    AngleOffset := abs (MinZoneBound)
  ELSE
    AngleOffset := 0.0 - MinZoneBound;

  MinZoneBound := MinZoneBound + AngleOffset;

  MaxZoneBound := ZoneCenterAzimuthRadians + ZoneAngularRadiusRadians +
      AngleOffset;

  RadiusOfFirstIntercept := Sqrt (Sqr (X2) + Sqr (Y2));

  IF F50AA_TWO_INTERCEPTS THEN
    RadiusOfSecondIntercept := Sqrt (Sqr (X3) + Sqr (Y3));

  IF abs (X2) < 1.0E-12 THEN
    IF Y2 > 0.0 THEN
      AzimuthOfFirstIntercept := pi / 2.0
    ELSE
      AzimuthOfFirstIntercept := 3.0 * pi / 2.0
  ELSE
    BEGIN
      AzimuthOfFirstIntercept := ArcTan (abs (Y2) / abs (X2));
      IF (Y2 > 0.0)
          AND (X2 < 0.0) THEN
        (* In 2nd quadrant *)
        AzimuthOfFirstIntercept := pi - AzimuthOfFirstIntercept
      ELSE
      IF (Y2 < 0.0)
          AND (X2 < 0.0) THEN
        (* In 3rd quadrant *)
        AzimuthOfFirstIntercept := pi + AzimuthOfFirstIntercept
      ELSE
      IF (Y2 < 0.0)
          AND (X2 > 0.0) THEN
        (* In 4th quadrant *)
        AzimuthOfFirstIntercept := 2.0 * pi - AzimuthOfFirstIntercept
    END;

  AzimuthOfFirstIntercept := AzimuthOfFirstIntercept + AngleOffset;

  IF AzimuthOfFirstIntercept < 0.0 THEN
    AzimuthOfFirstIntercept := AzimuthOfFirstIntercept + 2 * pi
  ELSE
  IF AzimuthOfFirstIntercept > (2.0 * pi) THEN
    AzimuthOfFirstIntercept := AzimuthOfFirstIntercept - 2 * pi;

  IF F50AA_TWO_INTERCEPTS THEN
    BEGIN
      IF abs (X3) < 1.0E-12 THEN
        IF Y3 > 0.0 THEN
          AzimuthOfSecondIntercept := pi / 2.0
        ELSE
          AzimuthOfSecondIntercept := 3.0 * pi / 2.0
      ELSE
        BEGIN
          AzimuthOfSecondIntercept := ArcTan (abs (Y3) / abs (X3));
          IF (Y3 > 0.0)
              AND (X3 < 0.0) THEN
            AzimuthOfSecondIntercept := pi - AzimuthOfSecondIntercept
          ELSE
          IF (Y3 < 0.0)
              AND (X3 < 0.0) THEN
            AzimuthOfSecondIntercept := pi + AzimuthOfSecondIntercept
          ELSE
          IF (Y3 < 0.0)
              AND (X3 > 0.0) THEN
            AzimuthOfSecondIntercept := 2.0 * pi - AzimuthOfSecondIntercept
        END;
      AzimuthOfSecondIntercept := AzimuthOfSecondIntercept + AngleOffset;
      IF AzimuthOfSecondIntercept < 0.0 THEN
        AzimuthOfSecondIntercept := AzimuthOfSecondIntercept + 2 * pi
      ELSE
      IF AzimuthOfSecondIntercept > (2.0 * pi) THEN
        AzimuthOfSecondIntercept := AzimuthOfSecondIntercept - 2 * pi
    END;

  IF (AzimuthOfFirstIntercept > MaxZoneBound) THEN
    IF F50AA_TWO_INTERCEPTS THEN
      BEGIN
        F50AA_TWO_INTERCEPTS := FALSE;
        X2 := X3;
        Y2 := Y3;
        Z2 := Z3;
        RadiusOfFirstIntercept := RadiusOfSecondIntercept;
        AzimuthOfFirstIntercept := AzimuthOfSecondIntercept;
        IF (AzimuthOfFirstIntercept > MaxZoneBound) THEN
          F01AB_NO_INTERSECTION := TRUE
      END
    ELSE
      F01AB_NO_INTERSECTION := TRUE
  ELSE
    BEGIN
      IF F50AA_TWO_INTERCEPTS THEN
        BEGIN
          IF (AzimuthOfSecondIntercept > MaxZoneBound) THEN
            F50AA_TWO_INTERCEPTS := FALSE
        END
    END;

  (* Verify that point of intersection is between inner and outer radii of
     surface. *)

  IF NOT F01AB_NO_INTERSECTION THEN
    BEGIN
      IF InsideDimensSpecd THEN
        IF RadiusOfFirstIntercept < (0.5 * InsideDia) THEN
          IF F50AA_TWO_INTERCEPTS THEN
            BEGIN
              F50AA_TWO_INTERCEPTS := FALSE;
              X2 := X3;
              Y2 := Y3;
              Z2 := Z3;
              RadiusOfFirstIntercept := RadiusOfSecondIntercept;
              IF RadiusOfFirstIntercept < (0.5 * InsideDia) THEN
                F01AB_NO_INTERSECTION := TRUE
            END
          ELSE
            F01AB_NO_INTERSECTION := TRUE
        ELSE
          BEGIN
            IF F50AA_TWO_INTERCEPTS THEN
              IF RadiusOfSecondIntercept < (0.5 * InsideDia) THEN
                F50AA_TWO_INTERCEPTS := FALSE
          END;
      IF OutsideDimensSpecd THEN
        IF RadiusOfFirstIntercept > (0.5 * OutsideDia) THEN
          IF F50AA_TWO_INTERCEPTS THEN
            BEGIN
              F50AA_TWO_INTERCEPTS := FALSE;
              X2 := X3;
              Y2 := Y3;
              Z2 := Z3;
              RadiusOfFirstIntercept := RadiusOfSecondIntercept;
              IF RadiusOfFirstIntercept > (0.5 * OutsideDia) THEN
                F01AB_NO_INTERSECTION := TRUE
            END
          ELSE
            F01AB_NO_INTERSECTION := TRUE
        ELSE
          BEGIN
            IF F50AA_TWO_INTERCEPTS THEN
              IF RadiusOfSecondIntercept > (0.5 * OutsideDia) THEN
                F50AA_TWO_INTERCEPTS := FALSE
          END
    END

END;




(**  CHECK_SAG  **************************************************************
*****************************************************************************)

PROCEDURE CHECK_SAG;

BEGIN

  (* Assure that Z intercepts are within acceptable sag limits.
     This limitation is invoked only when a clear outside aperture
     size has been specified for a sphere or an ellipse.  *)

  IF OutsideDimensSpecd
      AND (NOT ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT)
      AND (CC > -1.0) THEN
    BEGIN
      Z_MIDDLE := -R / (CC + 1.0);
      IF F50AA_TWO_INTERCEPTS THEN
	IF Z3 <= Z_MIDDLE THEN
	  F50AA_TWO_INTERCEPTS := FALSE;
      IF Z2 <= Z_MIDDLE THEN
	IF F50AA_TWO_INTERCEPTS THEN
	  BEGIN
	    F50AA_TWO_INTERCEPTS := FALSE;
	    X2 := X3;
	    Y2 := Y3;
	    Z2 := Z3
	  END
	ELSE
	  F01AB_NO_INTERSECTION := TRUE
    END

END;




(**  CHECK_DISTANCE  *********************************************************
*****************************************************************************)

PROCEDURE CHECK_DISTANCE;

BEGIN

  (* Get SIGNED distances from last intercept to present intercepts.
     Only those intercepts with NON-ZERO positive distances are allowed. *)

  D2 := RAY0.A * (X2 - RAY0.X) + RAY0.B * (Y2 - RAY0.Y) +
      RAY0.C * (Z2 - RAY0.Z);

  IF F50AA_TWO_INTERCEPTS THEN
    BEGIN
      D3 := RAY0.A * (X3 - RAY0.X) + RAY0.B * (Y3 - RAY0.Y) +
          RAY0.C * (Z3 - RAY0.Z);
      IF NOT (D3 > 0.0) THEN
	F50AA_TWO_INTERCEPTS := FALSE
    END;

  IF NOT (D2 > 0.0) THEN
    IF F50AA_TWO_INTERCEPTS THEN
      BEGIN
	F50AA_TWO_INTERCEPTS := FALSE;
	X2 := X3;
	Y2 := Y3;
	Z2 := Z3;
	D2 := D3
      END
    ELSE
      F01AB_NO_INTERSECTION := TRUE

END;




(**  CHOOSE_NEAR_INTERCEPT  **************************************************
*****************************************************************************)

PROCEDURE CHOOSE_NEAR_INTERCEPT;

BEGIN

  (* Choose intercept.	Proper intercept will be the one with the smallest
     (positive) distance from the previous intercept. *)

  IF F50AA_TWO_INTERCEPTS THEN
    IF D2 <= D3 THEN
      BEGIN
	RAY1.X := X2;
	RAY1.Y := Y2;
	RAY1.Z := Z2;
	D1 := D2
      END
    ELSE
      BEGIN
	RAY1.X := X3;
	RAY1.Y := Y3;
	RAY1.Z := Z3;
	D1 := D3
      END
  ELSE
    BEGIN
      RAY1.X := X2;
      RAY1.Y := Y2;
      RAY1.Z := Z2;
      D1 := D2
    END

END;




(**  CHOOSE_FAR_INTERCEPT  ***************************************************
*****************************************************************************)

PROCEDURE CHOOSE_FAR_INTERCEPT;

BEGIN

  (* Choose intercept.	Proper intercept will be the one with the largest
     (positive) distance from the previous intercept. *)

  IF F50AA_TWO_INTERCEPTS THEN
    IF D2 > D3 THEN
      BEGIN
	RAY1.X := X2;
	RAY1.Y := Y2;
	RAY1.Z := Z2;
	D1 := D2
      END
    ELSE
      BEGIN
	RAY1.X := X3;
	RAY1.Y := Y3;
	RAY1.Z := Z3;
	D1 := D3
      END
  ELSE
    BEGIN
      RAY1.X := X2;
      RAY1.Y := Y2;
      RAY1.Z := Z2;
      D1 := D2
    END

END;




(**  CPCProcess  *************************************************************
*****************************************************************************)

PROCEDURE CPCProcess;


(**  FindCPCIntersection  ****************************************************
*****************************************************************************)

PROCEDURE FindCPCIntersection;

  CONST
      AngleSteps = 20;

  VAR
      ResidualIsAcceptable        : BOOLEAN;
      UseNearIntercept            : BOOLEAN;
      FirstIntersectionOccurred   : BOOLEAN;
      SecondIntersectionOccurred  : BOOLEAN;
      UseD2                       : BOOLEAN;

      I                           : INTEGER;

      PhiIncrement                : DOUBLE;
      Phi                         : DOUBLE;
      rCPC                        : DOUBLE;
      zCPC                        : DOUBLE;
      PreviousRadius              : DOUBLE;
      PreviousSag                 : DOUBLE;
      DeltaSag                    : DOUBLE;
      MinPhi                      : DOUBLE;
      MaxPhi                      : DOUBLE;
      MinPhi2                     : DOUBLE;
      MaxPhi2                     : DOUBLE;
      CC2                         : DOUBLE;
      DeltaSag2                   : DOUBLE;
      rCPC2                       : DOUBLE;
      zCPC2                       : DOUBLE;
      MinPhi3                     : DOUBLE;
      MaxPhi3                     : DOUBLE;
      CC3                         : DOUBLE;
      DeltaSag3                   : DOUBLE;
      rCPC3                       : DOUBLE;
      zCPC3                       : DOUBLE;
      SaveX2                      : DOUBLE;
      SaveY2                      : DOUBLE;
      SaveZ2                      : DOUBLE;

      SaveRay0                    : ADH_RAY_REC;
      TempHoldRay0                : ADH_RAY_REC;


(**  ComputeConicConstant  **************************************************
****************************************************************************)

PROCEDURE ComputeConicConstant (PreviousRadius, PreviousSag,
                                rCPC, zCPC : DOUBLE;
                                VAR CC, DeltaSag : DOUBLE);

  VAR
      ConeSlope                   : DOUBLE;
      ConeSemiVertexAngleRad      : DOUBLE;
      arg                         : DOUBLE;
      Tan90MinusTheta             : DOUBLE;

BEGIN

  (* PreviousRadius is the radius of the major diameter of the conical ring
  segment.  The distance from the center of the major diameter of the conical
  ring segment, to the vertex of the cone is given by
  PreviousRadius * Run / Rise.  The distance from the center of the major
  diameter of the conical ring segment, to the vertex of the CPC is given by
  PreviousSag.  DeltaSag is the difference between these two values, and is
  the distance from the origin of coordinates to the vertex of the cone.  The
  incident light ray will be translated along the z-axis by an amount equal
  to DeltaSag, so as to make the vertex of the cone appear to be located at
  the origin of coordinates. *)

  ConeSlope := (PreviousRadius - rCPC) / (zCPC -
      PreviousSag);
  ConeSemiVertexAngleRad := ArcTan (ConeSlope);
  arg := ((pi / 2.0) - ConeSemiVertexAngleRad);
  Tan90MinusTheta := sin (arg) / cos (arg);
  CC := -1.0 * ((1.0 / (sqr(Tan90MinusTheta))) + 1.0);
  DeltaSag := (PreviousRadius / ConeSlope) + PreviousSag

END;




(**  ComputePhiForConeIntercept  ********************************************
****************************************************************************)

PROCEDURE ComputePhiForConeIntercept (X, Y, Z : DOUBLE; VAR Phi : DOUBLE);

  VAR
      Run         : DOUBLE;
      Rise        : DOUBLE;
      Beta        : DOUBLE;
      rCone       : DOUBLE;

BEGIN

  rCone := sqrt (sqr (X) + sqr (Y));
  Run := rCone + ZBA_SURFACE [SurfaceOrdinal].
      SurfaceShapeParameters.RadiusOfOutputAperture;
  Rise := abs (Z);
  Beta := Arctan (Rise / Run);
  Phi := (pi / 2.0) +
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxEntranceAngleInCPCRad - Beta

END;




(**  GetIntersectionWithCone  ***********************************************
****************************************************************************)

PROCEDURE GetIntersectionWithCone (DeltaSag : DOUBLE);

BEGIN

  F50AA_TWO_INTERCEPTS := TRUE;
  F01AB_NO_INTERSECTION := FALSE;

  (* Translate ray coordinates *)

  Ray0.Z := Ray0.Z - DeltaSag;

  FindConicIntercept;

  CHECK_Z_VALUE;

  (* Untranslate ray coordinates *)

  Ray0.Z := Ray0.Z + DeltaSag;

  (* Untranslate z coord. of intercept *)

  IF NOT F01AB_NO_INTERSECTION THEN
    BEGIN
      Z2 := Z2 + DeltaSag;
      IF F50AA_TWO_INTERCEPTS THEN
        Z3 := Z3 + DeltaSag
    END;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_CLEAR_APERTURE

END;




(**  RefineIntersection  *****************************************************
*****************************************************************************)

PROCEDURE RefineIntersection;

  CONST
      MaxAllowableIterations  = 40;
      MaxAcceptableResidual   = 1.0E-7;

  VAR
      IterationCounter           : INTEGER;

      ConeShift                  : DOUBLE;
      rCone                      : DOUBLE;


(**  FindConeShift  **********************************************************

     The following code finds the maximum separation along the z-axis
     between the CPC and the matching cone segment, for a given radius.

*****************************************************************************)

PROCEDURE FindConeShift (MaxPhi, MinPhi, rCPC, zCPC, DeltaSag : DOUBLE;
                         VAR ConeShift : DOUBLE);

  VAR
      I             : INTEGER;

      PhiIncrement  : DOUBLE;
      Phi           : DOUBLE;
      MaxConeShift  : DOUBLE;
      zCone         : DOUBLE;

BEGIN

  PhiIncrement := (MaxPhi - MinPhi) / 10.0;
  Phi := MinPhi;
  MaxConeShift := 0.0;

  FOR I := 1 TO 11 DO
    BEGIN
      (* Find sag (zCPC) and height (rCPC) for CPC at present value of Phi *)
      LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);
      (* Find sag for previously-defined cone at a height equal to rCPC *)
      zCone := -1.0 * (sqr (rCPC) / R) / (1.0 + sqrt (1.0 - (CC + 1.0) *
          (sqr (rCPC / R))));
      zCone := zCone + DeltaSag;
      ConeShift := zCPC - zCone;
      IF ConeShift > MaxConeShift THEN
        MaxConeShift := ConeShift;
      Phi := Phi + PhiIncrement
    END;

  ConeShift := MaxConeShift * 1.1

END;




(**  GetResidual  ***********************************************************
****************************************************************************)

PROCEDURE GetResidual (X, Y, Z, rCPC, zCPC : DOUBLE;
                       VAR rCone : DOUBLE;
                       VAR ResidualIsAcceptable : BOOLEAN);

  VAR
      zCone     : DOUBLE;
      Residual  : DOUBLE;

BEGIN

  rCone := sqrt (sqr (X) + sqr (Y));

  zCone := Z;

  Residual := sqrt (sqr (rCone - rCPC) +
      sqr (zCone - zCPC));

  IF abs (Residual) < MaxAcceptableResidual THEN
    ResidualIsAcceptable := TRUE
  ELSE
    ResidualIsAcceptable := FALSE

END;




(**  RefineIntersection  ****************************************************

   This procedure takes the previously identified cone, and slides it back
   and forth along the z axis until the ray intersection point with the
   cone coincides with the surface of the CPC.

****************************************************************************)


BEGIN

  FindConeShift (MaxPhi, MinPhi, rCPC, zCPC, DeltaSag, ConeShift);

  IF ConeShift <= MaxAcceptableResidual THEN
    BEGIN
      F01AB_NO_INTERSECTION := FALSE;
      ResidualIsAcceptable := TRUE
    END
  ELSE
    BEGIN
      ComputePhiForConeIntercept (Ray1.X, Ray1.Y, Ray1.Z, Phi);
      LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);
      GetResidual (Ray1.X, Ray1.Y, Ray1.Z, rCPC, zCPC, rCone,
          ResidualIsAcceptable);
      IF NOT ResidualIsAcceptable THEN
        BEGIN
          DeltaSag := DeltaSag + ConeShift;
	  GetIntersectionWithCone (DeltaSag);
          CHECK_DISTANCE;
          IF F50AA_TWO_INTERCEPTS THEN
            IF UseNearIntercept THEN
              CHOOSE_NEAR_INTERCEPT
            ELSE
              CHOOSE_FAR_INTERCEPT
          ELSE
            CHOOSE_NEAR_INTERCEPT;
	  IF NOT F01AB_NO_INTERSECTION THEN
	    ComputePhiForConeIntercept (Ray1.X, Ray1.Y, Ray1.Z, Phi);
          IterationCounter := 0;
          (* Get Phi within acceptable range *)
	  WHILE NOT F01AB_NO_INTERSECTION
	      AND (IterationCounter < MaxAllowableIterations)
	      AND ((Phi > MaxPhi)
	      OR (Phi < MinPhi)) DO
	    BEGIN
              IterationCounter := IterationCounter + 1;
	      ConeShift := ConeShift * 0.5;
	      DeltaSag := DeltaSag - ConeShift;
	      GetIntersectionWithCone (DeltaSag);
              CHECK_DISTANCE;
              IF F50AA_TWO_INTERCEPTS THEN
                IF UseNearIntercept THEN
                  CHOOSE_NEAR_INTERCEPT
                ELSE
                  CHOOSE_FAR_INTERCEPT
              ELSE
                CHOOSE_NEAR_INTERCEPT;
	      IF NOT F01AB_NO_INTERSECTION THEN
	        ComputePhiForConeIntercept (Ray1.X, Ray1.Y, Ray1.Z, Phi)
	    END;
	  IF NOT F01AB_NO_INTERSECTION THEN
	    BEGIN
	      LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);
              GetResidual (Ray1.X, Ray1.Y, Ray1.Z, rCPC, zCPC, rCone,
                  ResidualIsAcceptable)
	    END;
          IterationCounter := 0;
	  WHILE (NOT F01AB_NO_INTERSECTION)
	      AND (IterationCounter < MaxAllowableIterations)
	      AND (NOT ResidualIsAcceptable) DO
	    BEGIN
              IterationCounter := IterationCounter + 1;
	      ConeShift := ConeShift * 0.5;
	      IF rCone < rCPC THEN
	        DeltaSag := DeltaSag + ConeShift
	      ELSE
	        DeltaSag := DeltaSag - ConeShift;
	      GetIntersectionWithCone (DeltaSag);
              CHECK_DISTANCE;
              IF F50AA_TWO_INTERCEPTS THEN
                IF UseNearIntercept THEN
                  CHOOSE_NEAR_INTERCEPT
                ELSE
                  CHOOSE_FAR_INTERCEPT
              ELSE
                CHOOSE_NEAR_INTERCEPT;
	      IF NOT F01AB_NO_INTERSECTION THEN
	        BEGIN
		  ComputePhiForConeIntercept (Ray1.X, Ray1.Y, Ray1.Z, Phi);
		  LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);
                  GetResidual (Ray1.X, Ray1.Y, Ray1.Z, rCPC, zCPC, rCone,
                      ResidualIsAcceptable)
		END
	    END
	END
    END

END;




(**  ComputeSurfaceNormal  ***************************************************
*****************************************************************************)

PROCEDURE ComputeSurfaceNormal;

  VAR
      Phi                            : DOUBLE;
      rCPC                           : DOUBLE;
      zCPC                           : DOUBLE;
      DeltaSag                       : DOUBLE;
      PreviousRadius                 : DOUBLE;
      PreviousSag                    : DOUBLE;

BEGIN

  ComputePhiForConeIntercept (Ray1.X, Ray1.Y, Ray1.Z, Phi);

  Phi := Phi - 0.001;

  LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);

  PreviousRadius := rCPC;
  PreviousSag := zCPC;

  Phi := Phi + 0.002;

  LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);

  ComputeConicConstant (PreviousRadius, PreviousSag, rCPC, zCPC,
                        CC, DeltaSag);

  Ray1.Z := Ray1.Z - DeltaSag;

  F93_FIND_SURFACE_NORMAL (Ray1.X, Ray1.Y, Ray1.Z);

  Ray1.Z := Ray1.Z + DeltaSag

END;




(**  GetNearOrFar  ***********************************************************
*****************************************************************************)

PROCEDURE GetNearOrFar;

BEGIN

  (* Determine whether to use subsequent near intercepts
     with the expanded cone, or subsequent far intercepts. *)

  IF F50AA_TWO_INTERCEPTS THEN
    BEGIN
      IF (Abs (X2 - Ray1.X) < 1.0E-10)
          AND (Abs (Y2 - Ray1.Y) < 1.0E-10)
          AND (Abs (Z2 - Ray1.Z) < 1.0E-10) THEN
        UseD2 := TRUE
      ELSE
        UseD2 := FALSE;
      CHECK_DISTANCE;
      IF D2 < D3 THEN
        IF UseD2 THEN
          UseNearIntercept := TRUE
        ELSE
          UseNearIntercept := FALSE
      ELSE
        IF UseD2 THEN
          UseNearIntercept := FALSE
        ELSE
          UseNearIntercept := TRUE
    END
  ELSE
    UseNearIntercept := TRUE

END;




(**  FindCPCIntersection  ****************************************************

  The process of finding a point of intersection between an incident light
  ray and a CPC occurs in two steps.  In the first step, the CPC is
  approximated by a concatenation of AngleSteps number of adjacent conical
  ring segments.  By virtue of the manner in which the modelling is done,
  the conical ring segments lie inside the CPC, with the leading and trailing
  edges of the ring segments just touching the inside surface of the CPC.

  Thus, the first step involves finding the point of intersection between
  the incident light ray and one or more of the ring segments.  With this
  approach, there is the possibility that an incident light ray which
  approaches the outside of the CPC at nearly grazing incidence will not
  intersect any of the ring segments.  However, a light ray which approaches
  the inside of the CPC at nearly grazing incidence will ALWAYS intersect a
  ring segment.

  After finding a point, or points, of intersection of the incident light ray
  with one or more conical ring segments, the next step is to refine the
  point, or points, of intersection with the CPC itself.  If only a single
  point of intersection has occurred, the conical ring segment which was
  intersected is converted to a cone with the same conic constant and radius
  of curvature, but with arbitrarily large z-axis extent.  The cone is then
  shifted back and forth on the z-axis.  At each z-axis position, the point
  of intersection between the incident light ray and the cone is obtained.
  An angle between the vertex of the CPC and the point of intersection of the
  light ray with the cone, is then computed.  This angle is then used to
  compute a sag and height value for the CPC, based on the CPC design
  parameters.  The error (residual) is then computed, which is the difference
  between the sag and height values for the ray/cone intercept, versus the
  sag and height values for the CPC.

  An iterative, binary-search procedure is used to adjust the position of the
  cone on the z-axis, until the error is acceptably small.  When the error
  has been driven to an acceptably low value, the point of intersection of
  the incident light ray with the cone will be taken as the point of
  intersection with the CPC.  This iterative process also yields the angle
  between the vertex of the CPC, and the point of intersection of the light
  ray with the CPC.  The normal vector for the CPC may now be computed by
  simply computing the slope of the surface of the CPC at the point of
  intersection with the incident light ray.  This is done numerically, since
  there is no convenient functional form which represents the shape of the
  CPC surface.

*****************************************************************************)


BEGIN

  FirstIntersectionOccurred := FALSE;
  SecondIntersectionOccurred := FALSE;

  PhiIncrement := (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
      MaxPhi - ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.MinPhi) /
      AngleSteps;

  Phi := ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.MinPhi;

  LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);

  (* Slide ray starting point in backward direction, so that two
     intersections will be assured (given the appropriate launch
     geometry). The amount of backward slide is scaled by an amount
     equal to 20 times the radius of the entrance aperture of the CPC. *)

(*SaveRay0.All := Ray0.All;

  Ray0.X := Ray0.X - Ray0.A * 20.0 * rCPC;
  Ray0.Y := Ray0.Y - Ray0.B * 20.0 * rCPC;
  Ray0.Z := Ray0.Z - Ray0.C * 20.0 * rCPC;*)

  I := 1;

  REPEAT
    BEGIN
      PreviousRadius := rCPC;
      PreviousSag := zCPC;
      OutsideDia := 2.0 * rCPC;
      Phi := Phi + PhiIncrement;
      LADSQCPCUnit.GetRAndZForCPC (SurfaceOrdinal, Phi, rCPC, zCPC);
      InsideDia := 2.0 * rCPC;
      ComputeConicConstant (PreviousRadius, PreviousSag, rCPC, zCPC,
                            CC, DeltaSag);
      GetIntersectionWithCone (DeltaSag);
      CHECK_DISTANCE;
      IF NOT F01AB_NO_INTERSECTION THEN
        IF FirstIntersectionOccurred THEN
          BEGIN
            SecondIntersectionOccurred := TRUE;
	    MinPhi3 := Phi - PhiIncrement;
	    MaxPhi3 := Phi;
            CC3 := CC;
            DeltaSag3 := DeltaSag;
            rCPC3 := rCPC;
            zCPC3 := zCPC;
            X3 := X2;
            X2 := SaveX2;
            Y3 := Y2;
            Y2 := SaveY2;
            Z3 := Z2;
            Z2 := SaveZ2
          END
        ELSE
          BEGIN
            FirstIntersectionOccurred := TRUE;
	    MinPhi2 := Phi - PhiIncrement;
	    MaxPhi2 := Phi;
            CC2 := CC;
            DeltaSag2 := DeltaSag;
            rCPC2 := rCPC;
            zCPC2 := zCPC;
            SaveX2 := X2;
            SaveY2 := Y2;
            SaveZ2 := Z2;
            IF F50AA_TWO_INTERCEPTS THEN
              BEGIN
                SecondIntersectionOccurred := TRUE;
	        MinPhi3 := Phi - PhiIncrement;
	        MaxPhi3 := Phi;
                CC3 := CC;
                DeltaSag3 := DeltaSag;
                rCPC3 := rCPC;
                zCPC3 := zCPC
              END
          END;
      I := I + 1
    END;
  UNTIL SecondIntersectionOccurred
      OR (I > AngleSteps);

  UseNearIntercept := FALSE;
  ResidualIsAcceptable := FALSE;
  OutsideDia := 1.0E10;
  InsideDia := 0.0;

  IF FirstIntersectionOccurred THEN
    BEGIN
      IF SecondIntersectionOccurred THEN
        BEGIN
          F50AA_TWO_INTERCEPTS := TRUE;
          CHECK_DISTANCE;
          IF F01AH_PREV_WORKING_SURFACE <> SurfaceOrdinal THEN
            CHOOSE_NEAR_INTERCEPT
          ELSE
            CHOOSE_FAR_INTERCEPT;
          (* The following statement relies on maintaining the identity
             of the group of data items identified by the "2" suffix. *)
          IF (Ray1.X = SaveX2)
              AND (Ray1.Y = SaveY2)
              AND (Ray1.Z = SaveZ2) THEN
            BEGIN
              CC := CC2;
              DeltaSag := DeltaSag2;
              MinPhi := MinPhi2;
              MaxPhi := MaxPhi2;
              rCPC := rCPC2;
              zCPC := zCPC2
            END
          ELSE
            BEGIN
              CC := CC3;
              DeltaSag := DeltaSag3;
              MinPhi := MinPhi3;
              MaxPhi := MaxPhi3;
              rCPC := rCPC3;
              zCPC := zCPC3
            END;
          GetIntersectionWithCone (DeltaSag);(* This is the expanded cone *)
          CHECK_DISTANCE;
          GetNearOrFar;
          RefineIntersection
        END
      ELSE
        BEGIN
          (* If the only intersection found is the previous intersection,
             then we are done.  First, we need to temporarily deadvance
             the saved version of Ray0, to remove the advancement applied
             earlier in procedure F22_FIND_NEXT_RECURSIVE_SURFACE. *)
          IF (F01AH_PREV_WORKING_SURFACE = SurfaceOrdinal) THEN
            BEGIN
              TempHoldRay0.All := Ray0.All;
              Ray0.X := Ray0.X - Ray0.A * RayAdvanceFactor;
              Ray0.Y := Ray0.Y - Ray0.B * RayAdvanceFactor;
              Ray0.Z := Ray0.Z - Ray0.C * RayAdvanceFactor
            END;
          IF (Abs (Ray0.X - SaveX2) < 1.0E-10)
              AND (Abs (Ray0.Y - SaveY2) < 1.0E-10)
              AND (Abs (Ray0.Z - SaveZ2) < 1.0E-10) THEN
            BEGIN
              IF (F01AH_PREV_WORKING_SURFACE = SurfaceOrdinal) THEN
                Ray0.All := TempHoldRay0.All
            END
          ELSE
            BEGIN
              IF (F01AH_PREV_WORKING_SURFACE = SurfaceOrdinal) THEN
                Ray0.All := TempHoldRay0.All;
              MinPhi := MinPhi2;
              MaxPhi := MaxPhi2;
              CC := CC2;
              DeltaSag := DeltaSag2;
              rCPC := rCPC2;
              zCPC := zCPC2;
              Ray1.X := SaveX2;
              Ray1.Y := SaveY2;
              Ray1.Z := SaveZ2;
              GetIntersectionWithCone (DeltaSag);
              CHECK_DISTANCE;
              GetNearOrFar;
              RefineIntersection
            END
        END
    END;

(*Ray0.All := SaveRay0.All;*)

  IF ResidualIsAcceptable THEN
    ComputeSurfaceNormal
  ELSE
    F01AB_NO_INTERSECTION := TRUE

END;




(**  CPCProcess  *************************************************************
*****************************************************************************)


BEGIN

  FindCPCIntersection;

END;




(**  HIGH_ORDER_ASPHERE_PROCESS  *********************************************
*****************************************************************************)

PROCEDURE HIGH_ORDER_ASPHERE_PROCESS;

  VAR
      UseTempRAndCC  : BOOLEAN;

      SLOT           : INTEGER;

BEGIN

  UseTempRAndCC := FALSE;

  FOR SLOT := 1 TO MAX_SLOTS DO
    IF TEMP_RADIUS_AND_CC [SLOT].SURFACE_ORD = SurfaceOrdinal THEN
      BEGIN
        UseTempRAndCC := TRUE;
        R := TEMP_RADIUS_AND_CC [SLOT].TEMP_R;
        CC := TEMP_RADIUS_AND_CC [SLOT].TEMP_CC
      END;

  FindConicIntercept;

(*IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_Z_VALUE;*)

  IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_DISTANCE;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHOOSE_NEAR_INTERCEPT;
  
  IF UseTempRAndCC THEN
    BEGIN
      R := ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV;
      CC := ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT
    END;
  
  IF NOT F01AB_NO_INTERSECTION THEN
    FindAsphericIntercept;
    
  IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_CLEAR_APERTURE;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_DISTANCE;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHOOSE_NEAR_INTERCEPT

END;




(**  CONIC_SURFACE_PROCESS  **************************************************
*****************************************************************************)

PROCEDURE CONIC_SURFACE_PROCESS;

BEGIN

  FindConicIntercept;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_Z_VALUE;

  IF NOT F01AB_NO_INTERSECTION THEN
    BEGIN
      IF (NOT ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT)
          AND (ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD)
	  AND (ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD)
          AND (NOT ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR)
          AND (NOT ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR)
          AND (NOT ZBA_SURFACE [SurfaceOrdinal].
              ZCN_OUTSIDE_APERTURE_ELLIPTICAL)
          AND (NOT ZBA_SURFACE [SurfaceOrdinal].
              ZCO_INSIDE_APERTURE_ELLIPTICAL)
          AND (abs (ApertureShiftY) > 1.0E-12) THEN
        CHECK_ANGULAR_APERTURE
      ELSE
        CHECK_CLEAR_APERTURE
    END;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_SAG;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHECK_DISTANCE;

  IF NOT F01AB_NO_INTERSECTION THEN
    CHOOSE_NEAR_INTERCEPT

END;




(**  F50_INTERSECT_SURFACE  ***************************************************
******************************************************************************)


BEGIN

  InitializeVariables;

  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = Conic THEN
    CONIC_SURFACE_PROCESS
  ELse
  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HighOrderAsphere THEN
    HIGH_ORDER_ASPHERE_PROCESS
  ELSE
  IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = CPC)
      OR (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC) THEN
    CPCProcess;

  IF F01AB_NO_INTERSECTION THEN
    IF ZFA_OPTION.ZGI_RECURSIVE_TRACE
        OR ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM
        OR ZFA_OPTION.DRAW_RAYS
	OR ZFA_OPTION.ZGR_QUIET_ERRORS THEN
    ELSE
      BEGIN
	CommandIOMemo.IOHistory.Lines.add ('');
	CommandIOMemo.IOHistory.Lines.add ('RAY ' +
            IntToStr (F01AF_RAY_COUNTER) +
	    ' DOES NOT INTERSECT SURFACE ' + IntToStr (SurfaceOrdinal) + '.')
      END

END;




(**  F52_REFLECT_OR_REFRACT  **************************************************
******************************************************************************)


PROCEDURE F52_REFLECT_OR_REFRACT;

  VAR
      NULL_INTERACTION		   : BOOLEAN;
      N1IsGRIN                     : BOOLEAN;
      N2IsGRIN                     : BOOLEAN;

      N_DOT_N			   : DOUBLE;
      N_DOT_L0			   : DOUBLE;
      L0_DOT_L0			   : DOUBLE;
      N_DOT_L1                     : DOUBLE;
      UNDER_RADICAL		   : DOUBLE;
      RADICAL_VALUE		   : DOUBLE;
      ALPHA			   : DOUBLE;
      MaxSolidAngle                : DOUBLE;
      Azimuth                      : DOUBLE;
      COS_ZENITH_DISTANCE          : DOUBLE;
      SIN_ZENITH_DISTANCE          : DOUBLE;
      VECTOR_MAGNITUDE		   : DOUBLE;
      MAG			   : DOUBLE;
      Arg                          : DOUBLE;
      SX                           : DOUBLE;
      SY                           : DOUBLE;
      SZ                           : DOUBLE;
      Test                         : DOUBLE;
      VALUE1			   : DOUBLE;
      VALUE2			   : DOUBLE;
      T11			   : DOUBLE;
      T12			   : DOUBLE;
      T13			   : DOUBLE;
      T21			   : DOUBLE;
      T22			   : DOUBLE;
      T23			   : DOUBLE;
      T31			   : DOUBLE;
      T32			   : DOUBLE;
      T33			   : DOUBLE;
      SCAT_A			   : DOUBLE;
      SCAT_B			   : DOUBLE;
      SCAT_C			   : DOUBLE;
      HOLD_A			   : DOUBLE;
      HOLD_B			   : DOUBLE;
      HOLD_C			   : DOUBLE;
      HOLD_X			   : DOUBLE;
      HOLD_Y			   : DOUBLE;
      HOLD_Z			   : DOUBLE;
      X_HOLD                       : DOUBLE;
      Y_HOLD                       : DOUBLE;
      Z_HOLD                       : DOUBLE;

BEGIN

  IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HighOrderAsphere)
      OR (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = CPC)
      OR (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC) THEN
        (* No work to be done here, since the normal vector was already
         obtained in the process of finding the point of intersection
	 with the aspheric surface or CPC. *)
  ELSE
    F93_FIND_SURFACE_NORMAL (RAY1.X, RAY1.Y, RAY1.Z);

  N_DOT_L0 := NX * RAY0.A + NY * RAY0.B + NZ * RAY0.C;

  NULL_INTERACTION := FALSE;
  N1IsGRIN := FALSE;
  N2IsGRIN := FALSE;
  CurrentMaterialIsGradientIndex := FALSE;
  TIR := FALSE;

  (* Initialize incident index to the prior exit index value. *)

  N0 := N1;

  (* Calculate 2 possible values N1 and N2 for the new exit index. *)

  IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1] THEN
    BEGIN
      AKJ_SPECIFIED_GLASS_NAME := ZBA_SURFACE [SurfaceOrdinal].
	  ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME;
      AKO_SPECIFIED_WAVELENGTH := ZSA_SURFACE_INTERCEPTS.ZSL_WAVELENGTH;
      U060_READ_REFRACTIVE_INDEX (N1, NoErrors,
          N1IsGRIN);
    END
  ELSE
    N1 := ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
	ZBI_REFRACTIVE_INDEX;

  IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] THEN
    BEGIN
      AKJ_SPECIFIED_GLASS_NAME :=
	  ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
	  ZCH_GLASS_NAME;
      AKO_SPECIFIED_WAVELENGTH := ZSA_SURFACE_INTERCEPTS.ZSL_WAVELENGTH;
      U060_READ_REFRACTIVE_INDEX (N2, NoErrors,
          N2IsGRIN)
    END
  ELSE
    N2 := ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
	ZBI_REFRACTIVE_INDEX;

  (* Determine which refractive index, N1 or N2, should be the next exit
     index.  Also calculate alpha. *)
  IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
    BEGIN
      IF (ABS (N1 - N0) > 1.0E-12)
          AND (ABS (N2 - N0) > 1.0E-12) THEN
	BEGIN
          NoErrors := FALSE;
	  IF ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED
	      OR GraphicsActive
              OR AimPrincipalRays THEN
	  ELSE
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('DISCREPANT REFRACTIVE INDICES ENCOUNTERED.');
	      IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
		IF F01AH_PREV_WORKING_SURFACE =
		    (CZAB_MAX_NUMBER_OF_SURFACES + 1) THEN
		  CommandIOMemo.IOHistory.Lines.add ('INCIDENT INDEX = ' +
                      FloatToStrF (N0, ffFixed, 10, 7))
		ELSE
		  CommandIOMemo.IOHistory.Lines.add ('PREVIOUS SURFACE: ' +
		      IntToStr (F01AH_PREV_WORKING_SURFACE) + '   N0 = ' +
                      FloatToStrF (N0, ffFixed, 10, 7))
	      ELSE
		CommandIOMemo.IOHistory.Lines.add ('INCIDENT INDEX = ' +
                    FloatToStrF (N0, ffFixed, 10, 7));
	      CommandIOMemo.IOHistory.Lines.add ('PRESENT SURFACE:  ' +
                  IntToStr (SurfaceOrdinal) + '   N1 = ' +
                  FloatToStrF (N1, ffFixed, 10, 7) + '   N2 = ' +
                  FloatToStrF (N2, ffFixed, 10, 7))
	    END
	END
      ELSE
        BEGIN
          ALPHA := -2 * N_DOT_L0;
          IF ABS (N1 - N0) > 1.0E-12 THEN  (* i.e., N2 is the right one. *)
            BEGIN
              N1 := N2;
              IF N2IsGRIN THEN
                CurrentMaterialIsGradientIndex := TRUE
            END
          ELSE
            BEGIN
              IF N1IsGRIN THEN
                CurrentMaterialIsGradientIndex := TRUE
            END
        END
    END
  ELSE
    BEGIN
      IF ABS (N1 - N0) > 1.0E-12 THEN
	BEGIN
	  IF ABS (N2 - N0) > 1.0E-12 THEN
	    BEGIN
	      NoErrors := FALSE;
	      IF ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED
	          OR GraphicsActive
                  OR AimPrincipalRays THEN
	      ELSE
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                      ('DISCREPANT REFRACTIVE INDICES ENCOUNTERED.');
		  IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
		    IF F01AH_PREV_WORKING_SURFACE =
			(CZAB_MAX_NUMBER_OF_SURFACES + 1) THEN
		      CommandIOMemo.IOHistory.Lines.add ('INCIDENT INDEX = ' +
                          FloatToStrF (N0, ffFixed, 10, 7))
		    ELSE
		      CommandIOMemo.IOHistory.Lines.add ('PREVIOUS SURFACE: ' +
		          IntToStr (F01AH_PREV_WORKING_SURFACE) + '   N0 = ' +
                          FloatToStrF (N0, ffFixed, 10, 7))
		  ELSE
		    CommandIOMemo.IOHistory.Lines.add ('INCIDENT INDEX = ' +
                        FloatToStrF (N0, ffFixed, 10, 7));
		  CommandIOMemo.IOHistory.Lines.add ('PRESENT SURFACE:  ' +
                      IntToStr (SurfaceOrdinal) + '   N1 = ' +
                      FloatToStrF (N1, ffFixed, 10, 7) + '   N2 = ' +
                      FloatToStrF (N2, ffFixed, 10, 7))
		END
	    END
          ELSE  (* i.e., N1 is correct index. *)
            BEGIN
              IF N1IsGRIN THEN
                CurrentMaterialIsGradientIndex := TRUE
            END
	END
      ELSE  (* i.e., N2 is correct index. *)
        BEGIN
	  N1 := N2;
          IF N2IsGRIN THEN
            CurrentMaterialIsGradientIndex := TRUE
        END;
      IF NoErrors THEN
	IF ABS (N1 - N0) <= 1.0E-12 THEN
	  BEGIN
	    IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
	      IF ZBA_SURFACE [SurfaceOrdinal].
		  ZBY_BEAMSPLITTER_SURFACE THEN
		F53_GENERATE_REFLECTED_COMPONENT;
	    NULL_INTERACTION := TRUE
	  END
	ELSE
	  BEGIN
	    UNDER_RADICAL :=
		N_DOT_L0 * N_DOT_L0 + (((N1 * N1) / (N0 * N0)) - 1.0);
	    IF UNDER_RADICAL < 0.0 THEN	 (* Total internal reflection *)
	      IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
		BEGIN
		  TIR := TRUE;
		  ALPHA := -2 * N_DOT_L0; (* Do reflection instead *)
		  N1 := N0  (* Restore refractive index to pre-intercept *)
		END
	      ELSE
		BEGIN
		  NoErrors := FALSE;
		  IF ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED
		      OR GraphicsActive
                      OR AimPrincipalRays THEN
		  ELSE
		    BEGIN
		      CommandIOMemo.IOHistory.Lines.add ('');
		      CommandIOMemo.IOHistory.Lines.add
                          ('TOTAL INTERNAL REFLECTION ENCOUNTERED AT SURFACE ' +
			  IntToStr (SurfaceOrdinal) + '.')
		    END
		END
	    ELSE
	      BEGIN
		RADICAL_VALUE := SQRT (UNDER_RADICAL);
		IF N_DOT_L0 > 0.0 THEN
		  ALPHA := -N_DOT_L0 + RADICAL_VALUE
		ELSE
		  ALPHA := -N_DOT_L0 - RADICAL_VALUE;
                IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
                  IF ZBA_SURFACE [SurfaceOrdinal].
		      ZBY_BEAMSPLITTER_SURFACE THEN
    	            F53_GENERATE_REFLECTED_COMPONENT
	      END
	  END
    END;

(**  Compute x, y, and z vector components of exiting light ray.  **)

  IF NoErrors THEN
    IF NULL_INTERACTION THEN
      BEGIN
	RAY1.A := RAY0.A;
	RAY1.B := RAY0.B;
	RAY1.C := RAY0.C
      END
    ELSE
      BEGIN
	RAY1.A := ALPHA * NX + RAY0.A;
	RAY1.B := ALPHA * NY + RAY0.B;
	RAY1.C := ALPHA * NZ + RAY0.C;
	VECTOR_MAGNITUDE := SQRT (RAY1.A * RAY1.A + RAY1.B * RAY1.B +
	    RAY1.C * RAY1.C);
	RAY1.A := RAY1.A / VECTOR_MAGNITUDE;
	RAY1.B := RAY1.B / VECTOR_MAGNITUDE;
	RAY1.C := RAY1.C / VECTOR_MAGNITUDE
      END;

(* The following procedure checks whether the current surface is a scattering
   surface.  If it is, then the light ray exiting the present surface will be
   scattered in one of two possible ways, depending on the value entered by
   the user for the 1-sigma scattering angle.  If this value is less than or
   equal to 45 degrees, then Gaussian scattering is assumed.  In this case,
   the head of the scattered light ray will be computed as an x-y coordinate
   on a plane perpendicular to the normal (unscattered) direction of the
   exiting light ray.  The x-y coordinate is computed based on a Box-Mueller
   emulation of Gaussian statistics.

   If the 1-sigma scattering angle is greater than 45 degrees, then
   Lambertian scattering is assumed, wherein the scattering angle is
   assumed to be unrelated to the direction of the incident or reflected or
   refracted light ray.  This is appropriate for a material like
   Spectralon or Spectraflect, which exhibit near-perfect Lambertian
   scattering, with little specular characteristics. *)

  IF NoErrors THEN
    IF ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE THEN
      IF ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians <=
          (pi / 4.0) THEN (* i.e., <= 45 degrees *)
        BEGIN
          (* This is temporary hardcoded code. *)
          (*IF SurfaceOrdinal = 17 THEN (* Surface 17 is the target. *)
            (* The new light ray will be redirected toward the vertex
               of the next (destination) surface, surface 19.  We need to
               compute the direction cosines of the redirected ray.  The
               vertex of surface 19 needs to first be translated and rotated
               into the local coordinates of surface 17. *)
            (*BEGIN
              HOLD_X := ZBA_SURFACE [19].ZBM_VERTEX_X;
              HOLD_Y := ZBA_SURFACE [19].ZBO_VERTEX_Y;
              HOLD_Z := ZBA_SURFACE [19].ZBQ_VERTEX_Z;
              IF ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                  ZVK_COORDINATE_TRANSLATION_NEEDED THEN
                BEGIN
                  HOLD_X := HOLD_X -
	              (ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
	              ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X);
                  HOLD_Y := HOLD_Y -
	              (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
	              ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y)
                END;
              HOLD_Z := HOLD_Z -
                  (ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z +
                  ZBA_SURFACE [SurfaceOrdinal].ZBR_VERTEX_DELTA_Z);
              IF ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                  ZVL_COORDINATE_ROTATION_NEEDED THEN
                BEGIN
                  X_HOLD := HOLD_X;
                  Y_HOLD := HOLD_Y;
                  Z_HOLD := HOLD_Z;
                  HOLD_X := ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T11 * X_HOLD +
	              ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T12 * Y_HOLD +
	              ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T13 * Z_HOLD;
                  HOLD_Y := ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T21 * X_HOLD +
	              ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T22 * Y_HOLD +
	              ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T23 * Z_HOLD;
                  HOLD_Z := ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T31 * X_HOLD +
	              ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T32 * Y_HOLD +
	              ZVA_ROTATION_MATRIX [SurfaceOrdinal].
                      SurfaceRotationMatrix.T33 * Z_HOLD
                END;
              RAY1.A := HOLD_X - RAY1.X;
              RAY1.B := HOLD_Y - RAY1.Y;
              RAY1.C := HOLD_Z - RAY1.Z;
	      VECTOR_MAGNITUDE := SQRT (RAY1.A * RAY1.A + RAY1.B * RAY1.B +
	          RAY1.C * RAY1.C);
	      RAY1.A := RAY1.A / VECTOR_MAGNITUDE;
	      RAY1.B := RAY1.B / VECTOR_MAGNITUDE;
	      RAY1.C := RAY1.C / VECTOR_MAGNITUDE
            END;*)
	  (* The X- and Y-magnitudes of the heads of the scattered light
             ray vectors are generated by the Box-Mueller method. *)
	  RANDGEN;
	  VALUE1 :=
              (sin (ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians) /
              cos (ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians)) *
              SQRT (-2.0 * LN (RANDOM));
	  RANDGEN;
	  VALUE2 := 2.0 * PI * RANDOM;
	  SCAT_A := VALUE1 * COS (VALUE2);
	  SCAT_B := VALUE1 * SIN (VALUE2);
	  SCAT_C := 0.0;
        (* We have just calculated a point which lies in a plane.  The points
           in this plane form the heads of scattered light ray vectors.  This
           plane is supposed to be normal to the direction of the unscattered
           light ray.  Therefore, rotate the plane containing the coordinates
           of the heads of the scattered light ray vectors so that this plane
           (and the points contained therein) are perpendicular to the
           unscattered light ray. *)
	  IF ABS (RAY1.A) < ROOT_3_OVER_3 THEN
	    BEGIN
	      MAG := SQRT (SQR (RAY1.B) + SQR (RAY1.C));
	      T11 := MAG;
	      T12 := 0.0;
	      T13 := RAY1.A;
	      T21 := -1.0 * RAY1.A * RAY1.B / MAG;
	      T22 := RAY1.C / MAG;
	      T23 := RAY1.B;
	      T31 := -1.0 * RAY1.A * RAY1.C / MAG;
	      T32 := -1.0 * RAY1.B / MAG;
	      T33 := RAY1.C
	    END
	  ELSE
	  IF ABS (RAY1.B) <= ABS (RAY1.C) THEN
	    BEGIN
	      MAG := SQRT (SQR (RAY1.A) + SQR (RAY1.C));
	      T11 := RAY1.C / MAG;
	      T12 := -1.0 * RAY1.A * RAY1.B / MAG;
	      T13 := RAY1.A;
	      T21 := 0.0;
	      T22 := MAG;
	      T23 := RAY1.B;
	      T31 := -1.0 * RAY1.A / MAG;
	      T32 := -1.0 * RAY1.B * RAY1.C / MAG;
	      T33 := RAY1.C
	    END
	  ELSE
	    BEGIN
	      MAG := SQRT (SQR (RAY1.A) + SQR (RAY1.B));
	      T11 := RAY1.A * RAY1.C / MAG;
	      T12 := -1.0 * RAY1.B / MAG;
	      T13 := RAY1.A;
	      T21 := RAY1.B * RAY1.C / MAG;
	      T22 := RAY1.A / MAG;
	      T23 := RAY1.B;
	      T31 := -1.0 * MAG;
	      T32 := 0.0;
	      T33 := RAY1.C
	    END;
	  HOLD_A := SCAT_A;
	  HOLD_B := SCAT_B;
	  HOLD_C := SCAT_C;
	  SCAT_A := (T11 * HOLD_A) + (T12 * HOLD_B) + (T13 * HOLD_C);
	  SCAT_B := (T21 * HOLD_A) + (T22 * HOLD_B) + (T23 * HOLD_C);
	  SCAT_C := (T31 * HOLD_A) + (T32 * HOLD_B) + (T33 * HOLD_C);
	  RAY1.A := RAY1.A + SCAT_A;
	  RAY1.B := RAY1.B + SCAT_B;
	  RAY1.C := RAY1.C + SCAT_C;
	  VECTOR_MAGNITUDE :=
	      SQRT (RAY1.A * RAY1.A + RAY1.B * RAY1.B + RAY1.C * RAY1.C);
	  RAY1.A := RAY1.A / VECTOR_MAGNITUDE;
	  RAY1.B := RAY1.B / VECTOR_MAGNITUDE;
	  RAY1.C := RAY1.C / VECTOR_MAGNITUDE
        END
      ELSE
        BEGIN
          (* Compute N_DOT_L1, which is the dot product of the surface
             normal with the exiting light ray.  If this product is negative,
             the negative of the surface normal will be used to define the
             axis of the scattering cone.  Otherwise, the surface normal
             will be used to define the axis of the scattering cone. *)
          SX := NX;
          SY := NY;
          SZ := NZ;
          Test := SX * RAY1.A + SY * RAY1.B + SZ * RAY1.C;
          IF Test < 0.0 THEN
            BEGIN
              SX := -SX;
              SY := -SY;
              SZ := -SZ
            END;
          (* The following could be speeded up by storing the cosine of the
          angle, rather than the angle. *)
(*	  MaxSolidAngle := 2.0 * PI * (1.0 - COS (ZBA_SURFACE [SurfaceOrdinal].
	      ScatteringAngleRadians));*)
	  MaxSolidAngle := 2.0 * PI;
	  RANDGEN;
	  Azimuth := RANDOM * 2.0 * PI;
	  RANDGEN;
	  COS_ZENITH_DISTANCE := 1.0 - (RANDOM * MaxSolidAngle / (2.0 * PI));
	  SIN_ZENITH_DISTANCE := SQRT (1.0 - SQR (COS_ZENITH_DISTANCE));
          (*  Compute unit vector direction cosines. *)
	  SCAT_A := SIN_ZENITH_DISTANCE * COS (Azimuth);
	  SCAT_B := SIN_ZENITH_DISTANCE * SIN (Azimuth);
	  SCAT_C := COS_ZENITH_DISTANCE;
          (*  Get elements of rotation matrix, based on orientation of surface
          normal at intercept. *)
	  IF ABS (SX) < ROOT_3_OVER_3 THEN
	    BEGIN
	      MAG := SQRT (SQR (SY) + SQR (SZ));
	      T11 := MAG;
	      T12 := 0.0;
	      T13 := SX;
	      T21 := -1.0 * SX * SY / MAG;
	      T22 := SZ / MAG;
	      T23 := SY;
	      T31 := -1.0 * SX * SZ / MAG;
	      T32 := -1.0 * SY / MAG;
	      T33 := SZ
	    END
	  ELSE
	  IF ABS (SY) <= ABS (SZ) THEN
	    BEGIN
	      MAG := SQRT (SQR (SX) + SQR (SZ));
	      T11 := SZ / MAG;
	      T12 := -1.0 * SX * SY / MAG;
	      T13 := SX;
	      T21 := 0.0;
	      T22 := MAG;
	      T23 := SY;
	      T31 := -1.0 * SX / MAG;
	      T32 := -1.0 * SY * SZ / MAG;
	      T33 := SZ
	    END
	  ELSE
	    BEGIN
	      MAG := SQRT (SQR (SX) + SQR (SY));
	      T11 := SX * SZ / MAG;
	      T12 := -1.0 * SY / MAG;
	      T13 := SX;
	      T21 := SY * SZ / MAG;
	      T22 := SX / MAG;
	      T23 := SY;
	      T31 := -1.0 * MAG;
	      T32 := 0.0;
	      T33 := SZ
	    END;
          (* Rotate scattered light unit vector into the local
             coordinate system defined by the normal at the intercept. *)
          RAY1.A := (T11 * SCAT_A) + (T12 * SCAT_B) + (T13 * SCAT_C);
	  RAY1.B := (T21 * SCAT_A) + (T22 * SCAT_B) + (T23 * SCAT_C);
	  RAY1.C := (T31 * SCAT_A) + (T32 * SCAT_B) + (T33 * SCAT_C);
	  VECTOR_MAGNITUDE :=
	      SQRT (RAY1.A * RAY1.A + RAY1.B * RAY1.B + RAY1.C * RAY1.C);
	  RAY1.A := RAY1.A / VECTOR_MAGNITUDE;
	  RAY1.B := RAY1.B / VECTOR_MAGNITUDE;
	  RAY1.C := RAY1.C / VECTOR_MAGNITUDE
        END;

  IF NoErrors THEN
    IF ZFA_OPTION.DisplayLocalData THEN
      BEGIN
        (* Compute incident angle in local coordinates.  Use previously
           computed value N_DOT_L0, which is the cosine of the angle which the
           incident light ray L0 makes with the present surface. *)
        IF Abs (N_DOT_L0) < 1.0E-12 THEN
          LocalIncidentAngle := 90.0
        ELSE
        IF Abs (N_DOT_L0) >= 1.0 THEN
          LocalIncidentAngle := 0.0
        ELSE
          LocalIncidentAngle := ArcTan (Sqrt (1.0 - Sqr (N_DOT_L0)) /
              N_DOT_L0) * ALR_DEGREES_PER_RADIAN;
        (* Compute exit angle in local coordinates.  First, get cosine of
           angle which exiting light ray L1 makes with the present surface. *)
        N_DOT_L1 := NX * RAY1.A + NY * RAY1.B + NZ * RAY1.C;
        Arg := 1.0 - Sqr (N_DOT_L1);
        IF (Arg < 0.0) THEN
          IF (Abs (Arg) < 1.0E-12) THEN
            LocalExitAngle := 0.0
          ELSE
            NoErrors := FALSE
        ELSE
          LocalExitAngle := ArcTan (Sqrt (Arg) / N_DOT_L1) *
              ALR_DEGREES_PER_RADIAN;
        LocalXIntercept := Ray1.X;
        LocalYIntercept := Ray1.Y;
        LocalZIntercept := Ray1.Z
      END;

  IF NoErrors THEN
    IF CurrentMaterialIsGradientIndex THEN
      BEGIN
        LocalXDirection := Ray1.A;
        LocalYDirection := Ray1.B;
        LocalZDirection := Ray1.C;
        LocalXIntercept := Ray1.X;
        LocalYIntercept := Ray1.Y;
        LocalZIntercept := Ray1.Z
      END

END;




(**  F53_GENERATE_REFLECTED_COMPONENT ****************************************

    If this is a beamsplitter surface and we are doing recursive
    ray tracing, then this procedure is executed to generate the
    reflected component of the beamsplit ray.  The refracted
    component has just been generated.  The refracted component
    will be traced through any remaining surfaces, perhaps generating
    additional beamsplit reflected components, before the reflected
    components are traced.  Meanwhile, the reflected components are held in
    temporary storage.

*****************************************************************************)


PROCEDURE F53_GENERATE_REFLECTED_COMPONENT;

  VAR
      F53_HOLD_ALT_RAY_FILE_SW            : BOOLEAN;

      PostInteractionIntensity            : DOUBLE;
      N_DOT_L0                            : DOUBLE;
      ALPHA                               : DOUBLE;
      VECTOR_MAGNITUDE                    : DOUBLE;
      F53AA_A1_HOLD                       : DOUBLE;
      F53AB_B1_HOLD                       : DOUBLE;
      F53AC_C1_HOLD                       : DOUBLE;
      F53AD_X1_HOLD                       : DOUBLE;
      F53AE_Y1_HOLD                       : DOUBLE;
      F53AF_Z1_HOLD                       : DOUBLE;

      F53_SAVE_RAY                        : ADH_RAY_REC;

BEGIN

  (*  Test to see if the reflected component will have sufficient
      intensity to worry about. *)
      
  PostInteractionIntensity := ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY *
      ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY;

  IF PostInteractionIntensity <
      CZBK_LOWEST_ACCEPTABLE_RAY_INTENSITY THEN
  ELSE
  IF BSIndex >= MaxBeamsplitRays THEN
  ELSE
    BEGIN
      (*  BSIndex was initialized to zero. *)
      BSIndex := BSIndex + 1;
      (*  Put reflected ray intensity in temporary storage. *)
      BeamsplitRays [BSIndex].Intensity := PostInteractionIntensity;
      (*  Put incident medium index in temporary storage. *)
      BeamsplitRays [BSIndex].ExitIndex := N0;
      (*  Put wavelength in temporary storage. *)
      BeamsplitRays [BSIndex].Wavelength :=
          ZSA_SURFACE_INTERCEPTS.ZSL_WAVELENGTH;
      (*  Compute vector components of reflected ray, and put in
	  temporary storage. *)
      N_DOT_L0 := NX * RAY0.A + NY * RAY0.B + NZ * RAY0.C;
      ALPHA := -2.0 * N_DOT_L0;
      F53AA_A1_HOLD := RAY1.A;
      F53AB_B1_HOLD := RAY1.B;
      F53AC_C1_HOLD := RAY1.C;
      F53AD_X1_HOLD := RAY1.X;
      F53AE_Y1_HOLD := RAY1.Y;
      F53AF_Z1_HOLD := RAY1.Z;
      F53_HOLD_ALT_RAY_FILE_SW := ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE;
      ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE := FALSE;
      F53_SAVE_RAY.ALL := RAY0.ALL;
      RAY1.A := ALPHA * NX + RAY0.A;
      RAY1.B := ALPHA * NY + RAY0.B;
      RAY1.C := ALPHA * NZ + RAY0.C;
      VECTOR_MAGNITUDE := SQRT (RAY1.A * RAY1.A + RAY1.B * RAY1.B +
          RAY1.C * RAY1.C);
      RAY1.A := RAY1.A / VECTOR_MAGNITUDE;
      RAY1.B := RAY1.B / VECTOR_MAGNITUDE;
      RAY1.C := RAY1.C / VECTOR_MAGNITUDE;
      XformLocalCoordsToGlobal;
      BeamsplitRays [BSIndex].A := RAY1.A;
      BeamsplitRays [BSIndex].B := RAY1.B;
      BeamsplitRays [BSIndex].C := RAY1.C;
      BeamsplitRays [BSIndex].X := RAY1.X;
      BeamsplitRays [BSIndex].Y := RAY1.Y;
      BeamsplitRays [BSIndex].Z := RAY1.Z;
      RAY1.A := F53AA_A1_HOLD;
      RAY1.B := F53AB_B1_HOLD;
      RAY1.C := F53AC_C1_HOLD;
      RAY1.X := F53AD_X1_HOLD;
      RAY1.Y := F53AE_Y1_HOLD;
      RAY1.Z := F53AF_Z1_HOLD;
      ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE := F53_HOLD_ALT_RAY_FILE_SW;
      RAY0.ALL := F53_SAVE_RAY.ALL
    END

END;




(**  DetranslateLenslet  *****************************************************
*****************************************************************************)


PROCEDURE DetranslateLenslet;

BEGIN

  RAY0.X := TempHoldIncidentRayTailXCoord;
  RAY0.Y := TempHoldIncidentRayTailYCoord;      
  RAY1.X := RAY1.X + LensletXCoordinate;      
  RAY1.Y := RAY1.Y + LensletYCoordinate

END;




(**  F55_COMPUTE_DIA_AND_INTENSITY  ******************************************
*****************************************************************************)


PROCEDURE F55_COMPUTE_DIA_AND_INTENSITY;

  VAR
      TempString               : STRING;

      F55AK_COMPUTED_DIAMETER  : DOUBLE;

BEGIN

  (* THE FOLLOWING CODE EXISTS HERE SO AS TO NOT SLOW DOWN
     RECURSIVE SEARCHING. *)

  (* Get the size of the current surface.  If the current surface is the
     designated image surface, then take into account the fact that the
     viewport may have been shifted.  *)

  IF ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED THEN
    IF SurfaceOrdinal = ZFA_OPTION.ZGK_DESIGNATED_SURFACE THEN
      F55AK_COMPUTED_DIAMETER :=
	  2.0 * SQRT (SQR (RAY1.X - (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
	  (ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X +
	  ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
	  ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X))) +
	  SQR (RAY1.Y - (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y -
	  (ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y +
	  ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
	  ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y))))
    ELSE
      F55AK_COMPUTED_DIAMETER :=
	  2.0 * SQRT (SQR (RAY1.X - ZBA_SURFACE [SurfaceOrdinal].
	  ZCV_APERTURE_POSITION_X) +
	  SQR (RAY1.Y - ZBA_SURFACE [SurfaceOrdinal].
	  ZCW_APERTURE_POSITION_Y))
  ELSE
    F55AK_COMPUTED_DIAMETER :=
	2.0 * SQRT (SQR (RAY1.X - ZBA_SURFACE [SurfaceOrdinal].
	ZCV_APERTURE_POSITION_X) +
	SQR (RAY1.Y - ZBA_SURFACE [SurfaceOrdinal].
	ZCW_APERTURE_POSITION_Y));

  IF NOT ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD THEN
    IF F55AK_COMPUTED_DIAMETER > ZBA_SURFACE [SurfaceOrdinal].
	ZBJ_OUTSIDE_APERTURE_DIA THEN
      ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA :=
	  F55AK_COMPUTED_DIAMETER;

  IF ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED THEN
    IF SurfaceOrdinal = ZFA_OPTION.ZGK_DESIGNATED_SURFACE THEN
      IF AimPrincipalRays THEN
        (* Wipe out whatever direction
           cosine data may be hanging around in the ZSA data structure,
           and replace it with the local (x,y,z) coordinates of the head
           of the original ray (stored previously in HoldX,
           HoldY, and HoldZ). This is so that the head coordinates of
           the ray may be matched to the image surface ray
           intercept, in order to facilitate automated ray aiming. *)
        BEGIN
	  ZSA_SURFACE_INTERCEPTS.ZSB_A1 := HoldX;
	  ZSA_SURFACE_INTERCEPTS.ZSC_B1 := HoldY;
	  ZSA_SURFACE_INTERCEPTS.ZSD_C1 := HoldZ
        END;

  IF ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED THEN
    IF SurfaceOrdinal = ZFA_OPTION.ZGK_DESIGNATED_SURFACE THEN
      BEGIN
	(**  Display spot diagram (in rotated, translated coordinates)	**)
        IF ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM THEN
	  BEGIN
            SpotPending := TRUE;
	    IF RectangularViewportEnabled THEN
	      SpotPendingOKToAddIntensity := TRUE
            ELSE
            IF (F55AK_COMPUTED_DIAMETER <=
	        ZFA_OPTION.ZGL_VIEWPORT_DIAMETER) THEN
	      SpotPendingOKToAddIntensity := TRUE;
            SpotPendingIntensity := ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY;
            SpotPendingDiameter := F55AK_COMPUTED_DIAMETER;
            SpotPendingInterceptX := RAY1.X;
            SpotPendingInterceptY := RAY1.Y;
            SpotPendingInterceptZ := RAY1.Z;
	    IF F01AO_TRACING_PRINCIPAL_RAY THEN
	      SpotPendingRefIndex := -1.0 * N1
	    ELSE
	      SpotPendingRefIndex := N1;
	    SpotX :=
	        RAY1.X - (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X -
	        (ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
	        ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X));
	    SpotY :=
	        RAY1.Y - (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y -
	        (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
	        ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y))
	  END
        ELSE
          BEGIN
            (* Test to see if ray count should be incremented.  The ray count
               will be incremented if the ray intercept falls within the
               viewport defined under Trace Options.  The viewport
               defined under Trace Options is identical to the aperture
               defined by the surface specification for the surface selected
               as the image surface, unless the user specifically changes
               the viewport diameter value under Trace Options or the
               viewport offset. *)
	    IF RectangularViewportEnabled THEN
	      ARY_ACCUM_FINAL_INTENSITY :=
	          ARY_ACCUM_FINAL_INTENSITY +
	          ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY
            ELSE
            IF (F55AK_COMPUTED_DIAMETER <=
	        ZFA_OPTION.ZGL_VIEWPORT_DIAMETER) THEN
	      BEGIN
	        ARY_ACCUM_FINAL_INTENSITY :=
		    ARY_ACCUM_FINAL_INTENSITY +
		    ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY
	      END;
	    (**  Gather statistics (in rotated, translated coordinates)  **)
	    ZSA_SURFACE_INTERCEPTS.ZSE_X1 := RAY1.X;
	    ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := RAY1.Y;
	    ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := RAY1.Z;
	    IF F01AO_TRACING_PRINCIPAL_RAY THEN
	      ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := -1.0 * N1
	    ELSE
	      ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := N1;
	    X06_SIMPLE_WRITE_RECURSIVE_INTRCPT (NoErrors);
	    ARB_TOTAL_RECURS_INTERCEPTS := ARB_TOTAL_RECURS_INTERCEPTS + 1
          END
      END;

  (* The next code depends on the fact that we will never get this
     far if there is no intersection with the aperture stop surface. *)

  IF SpotPending THEN
    IF SurfaceOrdinal = ZFA_OPTION.ApertureStopSurface THEN
      BEGIN
        SpotPending := FALSE;
        IF SpotPendingOKToAddIntensity THEN
          BEGIN
            ARY_ACCUM_FINAL_INTENSITY := ARY_ACCUM_FINAL_INTENSITY +
                SpotPendingIntensity;
            SpotPendingOKToAddIntensity := FALSE
          END;
	IF SpotPendingDiameter > ARN_MAX_IMAGE_DIAMETER THEN
	  ARN_MAX_IMAGE_DIAMETER := SpotPendingDiameter;
	(**  Gather statistics (in rotated, translated coordinates)  **)
	ZSA_SURFACE_INTERCEPTS.ZSE_X1 := SpotPendingInterceptX;
	ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := SpotPendingInterceptY;
	ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := SpotPendingInterceptZ;
	ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := SpotPendingRefIndex;
	X06_SIMPLE_WRITE_RECURSIVE_INTRCPT (NoErrors);
	ARB_TOTAL_RECURS_INTERCEPTS := ARB_TOTAL_RECURS_INTERCEPTS + 1;
	HORIZONTAL_DISPLACEMENT := SpotX;
	VERTICAL_DISPLACEMENT := SpotY;
        F95_GET_COLUMN_AND_ROW;
        IF ColumnAndRowOnScreen THEN
          BEGIN
	    GraphicsOutputForm.Canvas.Pixels [ColumnIndex, RowIndex] :=
                clBlack;
	    LADSBitmap.Canvas.Pixels [ColumnIndex, RowIndex] :=
                clBlack
          END;
        (* Erase old intensity value on graphics screen... *)
	TempString := LastAccumIntensityString;
        GraphicsOutputForm.Canvas.Font.Color := clWhite;
        LADSBitmap.Canvas.Font.Color := clWhite;
        GraphicsOutputForm.Canvas.TextOut ((10 + SpotAccumPixelPosition),
            (RasterRows - 60), TempString);
	LADSBitmap.Canvas.TextOut ((10 + SpotAccumPixelPosition),
            (RasterRows - 60), TempString);
        (* Put new intensity value on graphics screen... *)
        GraphicsOutputForm.Canvas.Font.Color := clBlack;
        LADSBitmap.Canvas.Font.Color := clBlack;
	Str (ARY_ACCUM_FINAL_INTENSITY:9:2, TempString);
        GraphicsOutputForm.Canvas.TextOut ((10 + SpotAccumPixelPosition),
            (RasterRows - 60), TempString);
	LADSBitmap.Canvas.TextOut ((10 + SpotAccumPixelPosition),
            (RasterRows - 60), TempString);
        LastAccumIntensityString := TempString
      END;


  IF ZBA_SURFACE [SurfaceOrdinal].ZCI_RAY_TERMINATION_SURFACE THEN
    BEGIN
      ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY := 0.0;
      F01AG_RAY_TERMINATION_OCCURRED := TRUE
    END
  ELSE
    BEGIN
      IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
	ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY :=
	    ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY *
	    ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY
      ELSE
      IF TIR THEN
      ELSE
	ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY :=
	    ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY * (1.0 -
	    ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY);
      IF (ZSA_SURFACE_INTERCEPTS.ZSH_INTENSITY <
	  CZBK_LOWEST_ACCEPTABLE_RAY_INTENSITY) THEN
	IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
	  F01AG_RAY_TERMINATION_OCCURRED := TRUE
    END;
    
  TIR := FALSE

END;




(**  XformLocalCoordsToGlobal  ************************************************
******************************************************************************)


PROCEDURE XformLocalCoordsToGlobal;

  VAR
      F60AA_A1_HOLD  : DOUBLE;
      F60AB_B1_HOLD  : DOUBLE;
      F60AC_C1_HOLD  : DOUBLE;
      F60AD_X1_HOLD  : DOUBLE;
      F60AE_Y1_HOLD  : DOUBLE;
      F60AF_Z1_HOLD  : DOUBLE;
      NXHold         : DOUBLE;
      NYHold         : DOUBLE;
      NZHold         : DOUBLE;

BEGIN

(**  The coordinate restoration process is essentially the opposite of the
     coordinate transformation process performed earlier.  We will first
     perform a de-rotation transformation for the point of intersection of
     the incident light ray with the present surface, and for the vector
     component magnitudes of the exiting light ray.  We will then perform
     a de-translation for the point of intersection of the incident light
     ray with the present surface.

     The de-rotation transformation utilizes the transpose of the matrix
     used earlier to rotate coordinates.  The transposed matrix is
     
	       | X |	 | T11 T21 T31 |  | X' |
	       | Y |  =	 | T12 T22 T32 |  | Y' |
	       | Z |	 | T13 T23 T33 |  | Z' |,

     where X', Y', and Z' are the coordinates in the rotated system,
     X, Y, and Z are the coordinates in the reference system, and the
     rows and columns in the matrix have been interchanged.  **)

  IF ZVA_ROTATION_MATRIX [SurfaceOrdinal].
      ZVL_COORDINATE_ROTATION_NEEDED THEN
    BEGIN
      F60AA_A1_HOLD := RAY1.A;
      F60AB_B1_HOLD := RAY1.B;
      F60AC_C1_HOLD := RAY1.C;
      RAY1.A := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T11 * F60AA_A1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T21 * F60AB_B1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T31 * F60AC_C1_HOLD;
      RAY1.B := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T12 * F60AA_A1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T22 * F60AB_B1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T32 * F60AC_C1_HOLD;
      RAY1.C := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T13 * F60AA_A1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T23 * F60AB_B1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T33 * F60AC_C1_HOLD;
      IF ABS (RAY1.A) < 1.0E-12 THEN
	RAY1.A := 0.0;
      IF ABS (RAY1.B) < 1.0E-12 THEN
	RAY1.B := 0.0;
      IF (RAY1.A = 0.0)
	  AND (RAY1.B = 0.0) THEN
	BEGIN
	  IF RAY1.C > 0.0 THEN
	    RAY1.C := 1.0
	  ELSE
	    RAY1.C := -1.0
	END;
      F60AD_X1_HOLD := RAY1.X;
      F60AE_Y1_HOLD := RAY1.Y;
      F60AF_Z1_HOLD := RAY1.Z;
      RAY1.X := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T11 * F60AD_X1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T21 * F60AE_Y1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T31 * F60AF_Z1_HOLD;
      RAY1.Y := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T12 * F60AD_X1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T22 * F60AE_Y1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T32 * F60AF_Z1_HOLD;
      RAY1.Z := ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T13 * F60AD_X1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T23 * F60AE_Y1_HOLD +
	  ZVA_ROTATION_MATRIX [SurfaceOrdinal].SurfaceRotationMatrix.
          T33 * F60AF_Z1_HOLD;
      IF ABS (RAY1.X) < 1.0E-12 THEN
	RAY1.X := 0.0;
      IF ABS (RAY1.Y) < 1.0E-12 THEN
	RAY1.Y := 0.0;
      IF ABS (RAY1.Z) < 1.0E-12 THEN
	RAY1.Z := 0.0
    END;

  IF ZFA_OPTION.DisplayLocalData THEN
    IF ZVA_ROTATION_MATRIX [SurfaceOrdinal].
        ZVL_COORDINATE_ROTATION_NEEDED THEN
      BEGIN
        NXHold := NX;
        NYHold := NY;
        NZHold := NZ;
        NXWorld := ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T11 * NXHold +
	    ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T21 * NYHold +
	    ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T31 * NZHold;
        NYWorld := ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T12 * NXHold +
	    ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T22 * NYHold +
	    ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T32 * NZHold;
        NZWorld := ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T13 * NXHold +
	    ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T23 * NYHold +
	    ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix.T33 * NZHold;
        IF ABS (NXWorld) < 1.0E-12 THEN
	  NXWorld := 0.0;
        IF ABS (NYWorld) < 1.0E-12 THEN
	  NYWorld := 0.0;
        IF (NXWorld = 0.0)
	    AND (NYWorld = 0.0) THEN
	  BEGIN
	    IF NZWorld > 0.0 THEN
	      NZWorld := 1.0
	    ELSE
	      NZWorld := -1.0
	  END
      END
    ELSE
      BEGIN
        NXWorld := NX;
        NYWorld := NY;
        NZWorld := NZ
      END;

(**  We will now de-translate the point of intersection of the incident
     light ray with the present optical surface, back into the reference
     coordinate system.	 **)
  
  IF ZVA_ROTATION_MATRIX [SurfaceOrdinal].
      ZVK_COORDINATE_TRANSLATION_NEEDED THEN
    BEGIN
      RAY1.X := RAY1.X +
	  (ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
	  ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X);
      RAY1.Y := RAY1.Y +
	  (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
	  ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y)
    END;

  RAY1.Z := RAY1.Z +
      (ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z +
      ZBA_SURFACE [SurfaceOrdinal].ZBR_VERTEX_DELTA_Z);
  
  RAY0.ALL := RAY_OLD.ALL;

  IF ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
    IF SurfaceOrdinal = ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE THEN
      IF NOT F01AG_RAY_TERMINATION_OCCURRED THEN
	BEGIN
	  ZSA_SURFACE_INTERCEPTS.ZSE_X1 := RAY1.X;
	  ZSA_SURFACE_INTERCEPTS.ZSF_Y1 := RAY1.Y;
	  ZSA_SURFACE_INTERCEPTS.ZSG_Z1 := RAY1.Z;
	  ZSA_SURFACE_INTERCEPTS.ZSB_A1 := RAY1.A;
	  ZSA_SURFACE_INTERCEPTS.ZSC_B1 := RAY1.B;
	  ZSA_SURFACE_INTERCEPTS.ZSD_C1 := RAY1.C;
	  ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := N1;
	  IF F01AO_TRACING_PRINCIPAL_RAY THEN
	    ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX := -1.0 *
	        ZSA_SURFACE_INTERCEPTS.ZSP_EXIT_INDEX;
	  X07_SIMPLE_WRITE_OUTPUT_RAY (NoErrors);
	  ASC_OUTPUT_RAY_COUNT := ASC_OUTPUT_RAY_COUNT + 1
	END

END;




(**  F65_COMPUTE_PATH_LENGTH  *************************************************
******************************************************************************)


PROCEDURE F65_COMPUTE_PATH_LENGTH;

  VAR
      I  : INTEGER;

BEGIN

  IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE
      OR ZFA_OPTION.ZGF_DISPLAY_FULL_OPD
      OR ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
    BEGIN
      IF F01AM_SUMMING_PATH_LENGTHS THEN
	BEGIN
	  F01AT_PATH_LENGTH := F01AT_PATH_LENGTH +
	      N0 * SQRT (SQR (RAY1.X - RAY0.X) + SQR (RAY1.Y - RAY0.Y) +
	      SQR (RAY1.Z - RAY0.Z));
	  IF (SurfaceOrdinal = ADG_BEGIN_OPD_REF_SURFACE)
	      OR (SurfaceOrdinal = ADF_END_OPD_REF_SURFACE) THEN
	    BEGIN
	      F01AM_SUMMING_PATH_LENGTHS := FALSE;
	      ZTA_DIFFRACTION_DATA.ZTB_X := RAY1.X;
	      ZTA_DIFFRACTION_DATA.ZTC_Y := RAY1.Y;
	      ZTA_DIFFRACTION_DATA.ZTD_Z := RAY1.Z;
	      ZTA_DIFFRACTION_DATA.ZTE_A := RAY1.A;
	      ZTA_DIFFRACTION_DATA.ZTF_B := RAY1.B;
	      ZTA_DIFFRACTION_DATA.ZTG_C := RAY1.C;
	      ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH :=
		  F01AT_PATH_LENGTH;
	      ZTA_DIFFRACTION_DATA.ZTI_INTENSITY := 1.0;
	      X10_SIMPLE_WRITE_DIFF (NoErrors);
	      ARO_DIFF_RECORD_COUNT := ARO_DIFF_RECORD_COUNT + 1;
              (* The following initialization code should be done only
                 once. *)
              IF ARO_DIFF_RECORD_COUNT = 1 THEN
                BEGIN
                  DiffractionStuff.WorkingWavelength :=
                      ZSA_SURFACE_INTERCEPTS.ZSL_WAVELENGTH;
                  DiffractionStuff.ExitIndex := N1;
                  DiffractionStuff.FinalOPDSurface := SurfaceOrdinal;
                  DiffractionStuff.ImageSurface :=
                      ZFA_OPTION.ZGK_DESIGNATED_SURFACE;
                  I := ZFA_OPTION.ZGK_DESIGNATED_SURFACE;
                  (* Determine the distance or range from the exit OPD
                     surface to the designated image surface.  It is
                     assumed that the final segment of geometrical
                     path lies in the current medium, i.e., the medium
                     for the exit OPD reference surface. *)
                  DiffractionStuff.Range :=
                      Sqrt (Sqr ((ZBA_SURFACE [I].ZBM_VERTEX_X +
	              ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X) -
                      (ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
	              ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X)) +
	              Sqr ((ZBA_SURFACE [I].ZBO_VERTEX_Y +
	              ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y) -
	              (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
	              ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y)) +
	              Sqr ((ZBA_SURFACE [I].ZBQ_VERTEX_Z +
	              ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z) -
	              (ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z +
	              ZBA_SURFACE [SurfaceOrdinal].ZBR_VERTEX_DELTA_Z)))
                END
	    END
	END
      ELSE
	IF (SurfaceOrdinal = ADG_BEGIN_OPD_REF_SURFACE)
	    OR (SurfaceOrdinal = ADF_END_OPD_REF_SURFACE) THEN
	  BEGIN
	    F01AM_SUMMING_PATH_LENGTHS := TRUE;
	    F01AT_PATH_LENGTH := 0.0
	  END
    END

(*IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE
      OR ZFA_OPTION.ZGF_DISPLAY_FULL_OPD
      OR ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
    IF SurfaceOrdinal = ADG_BEGIN_OPD_REF_SURFACE THEN
      F01AT_PATH_LENGTH := 0.0
    ELSE
    IF (SurfaceOrdinal > ADG_BEGIN_OPD_REF_SURFACE)
	AND (SurfaceOrdinal <= ADF_END_OPD_REF_SURFACE) THEN
      BEGIN
	F01AT_PATH_LENGTH := F01AT_PATH_LENGTH +
	    N0 * SQRT (SQR (RAY1.X - RAY0.X) + SQR (RAY1.Y - RAY0.Y) +
	    SQR (RAY1.Z - RAY0.Z));
	IF SurfaceOrdinal = ADF_END_OPD_REF_SURFACE THEN
	  BEGIN
	    ZTA_DIFFRACTION_DATA.ZTB_X := RAY1.X;
	    ZTA_DIFFRACTION_DATA.ZTC_Y := RAY1.Y;
	    ZTA_DIFFRACTION_DATA.ZTD_Z := RAY1.Z;
	    ZTA_DIFFRACTION_DATA.ZTE_A := RAY1.A;
	    ZTA_DIFFRACTION_DATA.ZTF_B := RAY1.B;
	    ZTA_DIFFRACTION_DATA.ZTG_C := RAY1.C;
	    ZTA_DIFFRACTION_DATA.ZTH_PATH_LENGTH :=
		F01AT_PATH_LENGTH;
	    ZTA_DIFFRACTION_DATA.ZTI_INTENSITY := 1.0;
	    X10_SIMPLE_WRITE_DIFF;
	    ARO_DIFF_RECORD_COUNT := ARO_DIFF_RECORD_COUNT + 1
	  END
      END*)
  
END;




(**  F70_PRINT_TRACE_RESULTS  *************************************************
******************************************************************************)


PROCEDURE F70_PRINT_TRACE_RESULTS;

  VAR
      TempString                        : STRING;

      F70AA_A0				: DOUBLE;
      F70AB_B0				: DOUBLE;
      F70AC_C0				: DOUBLE;
      F70AD_A1				: DOUBLE;
      F70AE_B1				: DOUBLE;
      F70AF_C1				: DOUBLE;
      F70AG_X1				: DOUBLE;
      F70AH_Y1				: DOUBLE;
      F70AI_Z1				: DOUBLE;

FUNCTION StringIt (Num : DOUBLE; Prec : INTEGER; Format : INTEGER): STRING;

  VAR
      S  : STRING [25];

BEGIN

  str (Num:Prec:Format, S);
  StringIt := S

END;
BEGIN

  IF F01AD_HEADINGS_NOT_PRINTED THEN
    BEGIN
      F70AA_A0 := RAY0.A;
      F70AB_B0 := RAY0.B;
      F70AC_C0 := RAY0.C;
      IF (F70AA_A0 < 1.0E-15)
	  AND (F70AA_A0 > -1.0E-15) THEN
	F70AA_A0 := 0.0;
      IF (F70AB_B0 < 1.0E-15)
	  AND (F70AB_B0 > -1.0E-15) THEN
	F70AB_B0 := 0.0;
      IF (F70AC_C0 < 1.0E-15)
	  AND (F70AC_C0 > -1.0E-15) THEN
	F70AC_C0 := 0.0;
      IF ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('RAY ' + IntToStr (F01AF_RAY_COUNTER) + ':');
	  CommandIOMemo.IOHistory.Lines.add
              ('  INCIDENT LIGHT RAY VECTOR COMPONENT MAGNITUDES:');
	  CommandIOMemo.IOHistory.Lines.add
              ('  X = ' + FloatToStrF (F70AA_A0, ffFixed, 11, 6) + ', Y = ' +
	      FloatToStrF (F70AB_B0, ffFixed, 11, 6) + ', Z = ' +
              FloatToStrF (F70AC_C0, ffFixed, 11, 6));
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('SURF  X-INTERCEPT   Y-INTERCEPT   Z-INTERCEPT ' +
	      '  DIR COS X  DIR COS Y  DIR COS Z');
	  CommandIOMemo.IOHistory.Lines.add
              ('  -- ------------- ------------- -------------' +
	      ' ---------- ---------- ----------')
	END;
      IF ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER THEN
	BEGIN
	  WRITELN (ZAF_PRINT_FILE);
	  WRITELN (ZAF_PRINT_FILE, 'RAY ', F01AF_RAY_COUNTER, ':');
	  WRITELN (ZAF_PRINT_FILE,
	      '  INCIDENT LIGHT RAY VECTOR COMPONENT MAGNITUDES:');
	  WRITELN (ZAF_PRINT_FILE, '  X = ', F70AA_A0:11:6, ', Y = ',
	      F70AB_B0:11:6, ', Z = ', F70AC_C0:11:6);
	  WRITELN (ZAF_PRINT_FILE);
	  WRITELN (ZAF_PRINT_FILE,
	      'SURF  X-INTERCEPT   Y-INTERCEPT   Z-INTERCEPT ',
	      '  DIR COS X  DIR COS Y  DIR COS Z');
	  WRITELN (ZAF_PRINT_FILE,
	      '  -- ------------- ------------- -------------',
	      ' ---------- ---------- ----------')
	END;
      IF ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE THEN
	BEGIN
	  WRITELN (ZAG_LIST_FILE);
	  WRITELN (ZAG_LIST_FILE, 'RAY ', F01AF_RAY_COUNTER, ':');
	  WRITELN (ZAG_LIST_FILE,
	      '  INCIDENT LIGHT RAY VECTOR COMPONENT MAGNITUDES:');
	  WRITELN (ZAG_LIST_FILE, '  X = ', F70AA_A0:11:6, ', Y = ',
	      F70AB_B0:11:6, ', Z = ', F70AC_C0:11:6);
	  WRITELN (ZAG_LIST_FILE);
	  WRITELN (ZAG_LIST_FILE,
	      'SURF  X-INTERCEPT   Y-INTERCEPT   Z-INTERCEPT ',
	      '  DIR COS X  DIR COS Y  DIR COS Z');
	  WRITELN (ZAG_LIST_FILE,
	      '  -- ------------- ------------- -------------',
	      ' ---------- ---------- ----------')
	END;
      F01AD_HEADINGS_NOT_PRINTED := FALSE
    END;

  F70AD_A1 := RAY1.A;
  F70AE_B1 := RAY1.B;
  F70AF_C1 := RAY1.C;
  F70AG_X1 := RAY1.X;
  F70AH_Y1 := RAY1.Y;
  F70AI_Z1 := RAY1.Z;

  IF (F70AD_A1 < 1.0E-15)
      AND (F70AD_A1 > -1.0E-15) THEN
    F70AD_A1 := 0.0;
  IF (F70AE_B1 < 1.0E-15)
      AND (F70AE_B1 > -1.0E-15) THEN
    F70AE_B1 := 0.0;
  IF (F70AF_C1 < 1.0E-15)
      AND (F70AF_C1 > -1.0E-15) THEN
    F70AF_C1 := 0.0;
  IF (F70AG_X1 < 1.0E-15)
      AND (F70AG_X1 > -1.0E-15) THEN
    F70AG_X1 := 0.0;
  IF (F70AH_Y1 < 1.0E-15)
      AND (F70AH_Y1 > -1.0E-15) THEN
    F70AH_Y1 := 0.0;
  IF (F70AI_Z1 < 1.0E-15)
      AND (F70AI_Z1 > -1.0E-15) THEN
    F70AI_Z1 := 0.0;

  IF ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE THEN
    BEGIN
      Str (SurfaceOrdinal:2, TempString);
      CommandIOMemo.IOHistory.Lines.add ('  ' + TempString + ' ' +
(*        FloatToStrF (F70AG_X1, ffFixed, 13, 6) + ' ' +
          FloatToStrF (F70AH_Y1, ffFixed, 13, 6) + ' ' +
          FloatToStrF (F70AI_Z1, ffFixed, 13, 6) + ' ' +
          FloatToStrF (F70AD_A1, ffFixed, 10, 7) + ' ' +
          FloatToStrF (F70AE_B1, ffFixed, 10, 7) + ' ' +
          FloatToStrF (F70AF_C1, ffFixed, 10, 7))*)
          StringIt (F70AG_X1, 13, 6) + ' ' +
          StringIt (F70AH_Y1, 13, 6) + ' ' +
          StringIt (F70AI_Z1, 13, 6) + ' ' +
          StringIt (F70AD_A1, 10, 7) + ' ' +
          StringIt (F70AE_B1, 10, 7) + ' ' +
          StringIt (F70AF_C1, 10, 7))
    END;

  IF ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER THEN
    WRITELN (ZAF_PRINT_FILE,
	'  ', SurfaceOrdinal:2, ' ', F70AG_X1:13:6, ' ',
	F70AH_Y1:13:6, ' ', F70AI_Z1:13:6, ' ', F70AD_A1:10:7, ' ',
	F70AE_B1:10:7, ' ', F70AF_C1:10:7);

  IF ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE THEN
    WRITELN (ZAG_LIST_FILE,
	'  ', SurfaceOrdinal:2, ' ', F70AG_X1:13:6, ' ',
	F70AH_Y1:13:6, ' ', F70AI_Z1:13:6, ' ', F70AD_A1:10:7, ' ',
	F70AE_B1:10:7, ' ', F70AF_C1:10:7)

END;




(**  F75DisplayLocalData  *****************************************************
******************************************************************************)

PROCEDURE F75DisplayLocalData;

FUNCTION StringIt (Num : DOUBLE; Prec : INTEGER; Format : INTEGER): STRING;

  VAR
      S  : STRING [25];

BEGIN

  str (Num:Prec:Format, S);
  StringIt := S

END;
BEGIN

  IF F01AD_HEADINGS_NOT_PRINTED THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('RAY ' + IntToStr (F01AF_RAY_COUNTER) + ':');
      CommandIOMemo.IOHistory.Lines.add
          ('  INCIDENT LIGHT RAY VECTOR COMPONENT MAGNITUDES:');
      CommandIOMemo.IOHistory.Lines.add ('  X = ' +
          FloatToStrF (RAY0.A, ffFixed, 11, 6) + ', Y = ' +
          FloatToStrF (RAY0.B, ffFixed, 11, 6) + ', Z = ' +
          FloatToStrF (RAY0.C, ffFixed, 11, 6));
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add ('S# X (LOCAL) Y (LOCAL) Z (LOCAL)' +
	  ' IN ANG  EX ANG  NX (WRLD) NY (WRLD) NZ (WRLD)');
      CommandIOMemo.IOHistory.Lines.add ('-- --------- --------- ---------' +
	  ' ------- ------- --------- --------- ---------');
      F01AD_HEADINGS_NOT_PRINTED := FALSE
    END;

  CommandIOMemo.IOHistory.Lines.add (StringIt (SurfaceOrdinal, 2, 0) + ' ' +
      StringIt (LocalXIntercept, 9, 4) + ' ' +
      StringIt (LocalYIntercept, 9, 4) + ' ' +
      StringIt (LocalZIntercept, 9, 4) + ' ' +
      StringIt (LocalIncidentAngle, 7, 3) + ' ' +
      StringIt (LocalExitAngle, 7, 3) + ' ' +
      StringIt (NXWorld, 9, 6) + ' ' +
      StringIt (NYWorld, 9, 6) + ' ' +
      StringIt (NZWorld, 9, 6))

END;




(**  F93_FIND_SURFACE_NORMAL  *************************************************
******************************************************************************)


PROCEDURE F93_FIND_SURFACE_NORMAL;

  VAR
      TEMP              : DOUBLE;
      VECTOR_MAGNITUDE  : DOUBLE;

BEGIN

(**  Find unit vector normal to surface at (X1,Y1,Z1).	**)

  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HighOrderAsphere THEN
    BEGIN
      IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
	TEMP := 
	    4.0 * C [1] * HH +
	    6.0 * C [2] * H4 +
	    8.0 * C [3] * H6 +
	    10.0 * C [4] * H8 +
	    12.0 * C [5] * H10 +
	    14.0 * C [6] * H12 +
	    16.0 * C [7] * H14 +
	    18.0 * C [8] * H16 +
	    20.0 * C [9] * H18 +
	    22.0 * C [10] * H20
      ELSE
	TEMP := (HH * (CC + 1.0)) / (R * RR * Q * Q * (Q - 1.0)) +
	    2.0 / (R * Q) +
	    4.0 * C [1] * HH +
	    6.0 * C [2] * H4 +
	    8.0 * C [3] * H6 +
	    10.0 * C [4] * H8 +
	    12.0 * C [5] * H10 +
	    14.0 * C [6] * H12 +
	    16.0 * C [7] * H14 +
	    18.0 * C [8] * H16 +
	    20.0 * C [9] * H18 +
	    22.0 * C [10] * H20;
      IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
	NX := 0.0
      ELSE
	NX := X1 * TEMP;
      NY := Y1 * TEMP;
      NZ := 1.0;
    END
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
    BEGIN
      NX := 0.0;
      NY := 0.0;
      NZ := 1.0
    END
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
    BEGIN
      NX := 0.0;
      NY := Y1;
      NZ := (CC + 1.0) * Z1 + R
    END
  ELSE
    BEGIN
      NX := X1;
      NY := Y1;
      NZ := (CC + 1.0) * Z1 + R
    END;

  VECTOR_MAGNITUDE := SQRT (NX * NX + NY * NY + NZ * NZ);

  NX := NX / VECTOR_MAGNITUDE;
  NY := NY / VECTOR_MAGNITUDE;
  NZ := NZ / VECTOR_MAGNITUDE

END;




(**  F95_GET_COLUMN_AND_ROW  ************************************************
****************************************************************************)


PROCEDURE F95_GET_COLUMN_AND_ROW;

  VAR
      ROW_INDEX_REAL      : DOUBLE;
      COLUMN_INDEX_REAL   : DOUBLE;

BEGIN

  ROW_INDEX_REAL :=
      (-1.0 * VERTICAL_DISPLACEMENT
      * 2.0 / ZFA_OPTION.ZGL_VIEWPORT_DIAMETER) *
      RowsInRasterRadius + RasterCenterRow;

  COLUMN_INDEX_REAL :=
      (-1.0 * HORIZONTAL_DISPLACEMENT
      * 2.0 / ZFA_OPTION.ZGL_VIEWPORT_DIAMETER) *
      ColumnsInRasterRadius + RasterCenterColumn;
      
  IF (COLUMN_INDEX_REAL < -32768.0)
      OR (COLUMN_INDEX_REAL > 32767.0)
      OR (ROW_INDEX_REAL < -32768.0)
      OR (ROW_INDEX_REAL > 32767.0) THEN
    BEGIN
      ColumnAndRowOK := FALSE;
      ColumnAndRowOnScreen := FALSE
    END
  ELSE
    BEGIN
      ColumnIndex := TRUNC (COLUMN_INDEX_REAL);
      RowIndex := TRUNC (ROW_INDEX_REAL);
      ColumnAndRowOK := TRUE;
      IF (ColumnIndex < 1)
	  OR (ColumnIndex > RasterColumns)
	  OR (RowIndex < 1)
	  OR (RowIndex > RasterRows) THEN
	ColumnAndRowOnScreen := FALSE
      ELSE
        ColumnAndRowOnScreen := TRUE
    END

END;




(**  F01_EXECUTE_TRACE	*******************************************************
******************************************************************************)


PROCEDURE F01_EXECUTE_TRACE;

  VAR
      XformOperands  : TransformationRecord;

      TempString     : STRING;

BEGIN

  F03_VALIDATE_RAY_TRACE;

  IF NoErrors THEN
  ELSE
    Q980_REQUEST_MORE_OUTPUT;

  IF NoErrors THEN
    F05_INITIALIZE_FOR_TRACE;

  IF NoErrors THEN
    IF ZFA_OPTION.DRAW_RAYS
        OR ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM THEN
      F06_INITIALIZE_FOR_GRAPHICS;
      
  IF NoErrors THEN
    IF ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM THEN
      F07_SET_UP_SPOT_DIAGRAM
    ELSE
    IF ZFA_OPTION.DRAW_RAYS THEN
      F08_DRAW_SURFACES;

  IF NoErrors THEN
    IF ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED THEN
      W90_INITIALIZE_OPTIMIZATION (NoErrors);
  
  IF NoErrors THEN
    F01AI_TRACE_COMPLETE := FALSE;

  IF NoErrors THEN
    REPEAT
      BEGIN
        NoMoreRaysToTrace := FALSE;
        KeyboardActivityDetected := FALSE;
	X15_REWIND_AND_READ_INTRCPT (NoErrors);
	AAA_TOTAL_RAYS_TO_TRACE :=
	    ZSA_SURFACE_INTERCEPTS.ZSJ_TOTAL_RAYS_TO_TRACE;
	X35_SIMPLE_READ_INTRCPT (NoErrors);
	F01AF_RAY_COUNTER := 1;
	REPEAT
	  BEGIN
	    F20_TRACE_RAY;
	    IF NOT NoErrors THEN
(*	      IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN*)
	        IF GraphicsActive THEN
		  NoErrors := TRUE;
            IF NoErrors THEN
              IF (ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE
                  OR ZFA_OPTION.DisplayLocalData) THEN
                Q980_REQUEST_MORE_OUTPUT;
	    TracingBeamsplitRay := FALSE;
	    IF BSIndex > 0 THEN
	      BEGIN
                TracingBeamsplitRay := TRUE;
		ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA :=
	            BeamsplitRays [BSIndex].All;
		BSIndex := BSIndex - 1
	      END
	    ELSE
	      BEGIN
		F01AF_RAY_COUNTER := F01AF_RAY_COUNTER + 1;
		IF F01AF_RAY_COUNTER > AAA_TOTAL_RAYS_TO_TRACE THEN
		  NoMoreRaysToTrace := TRUE
		ELSE
		  X35_SIMPLE_READ_INTRCPT (NoErrors)
	      END
	  END
	UNTIL
	  NoMoreRaysToTrace
	  OR (NOT NoErrors)
	  OR (KeyboardActivityDetected);
	IF ARC_RECURS_INT_BLOCK_SLOT > 1 THEN
	  X46_WRITE_LAST_BLOCK_RECURS_INTRCPT (NoErrors);
        IF AimPrincipalRays THEN
          BEGIN
            V15_AIM_PRINCIPAL_RAY;
            F01AI_TRACE_COMPLETE := TRUE
          END
        ELSE
	IF ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED THEN
	  BEGIN
            V20_COMPUTE_TRACE_STATISTICS;
	    W01_PROCESS_OPTIMIZATION;
	    X17_REWIND_RECURSIVE_INTRCPT
	  END
	ELSE
          BEGIN
            V20_COMPUTE_TRACE_STATISTICS;
	    F01AI_TRACE_COMPLETE := TRUE
          END;
	IF KeyboardActivityDetected THEN
	  F01AI_TRACE_COMPLETE := TRUE
      END
    UNTIL
      F01AI_TRACE_COMPLETE;

  IF KeyboardActivityDetected THEN
    NoErrors := FALSE;
    
  IF NoErrors THEN
    BEGIN
      IF ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
	BEGIN
	  IF ASA_OUTRAY_BLOCK_SLOT > 1 THEN
	    X47_WRITE_LAST_BLOCK_OUTRAY (NoErrors);
	  ZSA_SURFACE_INTERCEPTS.ZSJ_TOTAL_RAYS_TO_TRACE :=
	      ASC_OUTPUT_RAY_COUNT;
	  SEEK (ZAL_OUTPUT_RAY_FILE, 0);
	  BLOCKREAD (ZAL_OUTPUT_RAY_FILE, ZZC_OUTRAY_DATA_BLOCK, 1);
	  ZZC_OUTRAY_DATA_BLOCK.ZXB_BLOCK_DATA [1].ZXC_REAL_VALUES :=
	      ZSA_SURFACE_INTERCEPTS.ZSM_ALL_INTERCEPT_DATA;
	  SEEK (ZAL_OUTPUT_RAY_FILE, 0);
	  BLOCKWRITE (ZAL_OUTPUT_RAY_FILE, ZZC_OUTRAY_DATA_BLOCK, 1)
	END;
      IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE
	  OR ZFA_OPTION.ZGF_DISPLAY_FULL_OPD
	  OR ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
	IF ARR_DIFF_BLOCK_SLOT > 1 THEN
	  X50_WRITE_LAST_BLOCK_DIFF (NoErrors)
    END;

  IF NoErrors THEN
    BEGIN
      IF AimPrincipalRays THEN
      ELSE
      IF ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM THEN
        BEGIN
	  Str (ARD_BLUR_SPHERE_DIAMETER, TempString);
	  TempString := Concat ('FULL SPOT DIAMETER (CENTROID-BASED): ',
	      TempString);
          GraphicsOutputForm.Canvas.TextOut (10, (RasterRows - 50), TempString);
	  LADSBitmap.Canvas.TextOut
              (10, (RasterRows - 50), TempString);
          GraphicsOutputForm.Canvas.TextOut (10, (RasterRows - 40),
	      '  Press ENTER key to continue...');
	  LADSBitmap.Canvas.TextOut
	      (10, (RasterRows - 40),
	      '  Press ENTER key to continue...');
(*        GraphicsOutputForm.Visible := TRUE;
          GraphicsOutputForm.Color := clWhite;*)
          GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);
          CommandIOdlg.Caption := 'Press ENTER key to continue...';
	  S01_PROCESS_REQUEST;
          GraphicsOutputForm.Canvas.Brush.Color := clWhite;
          LADSBitmap.Canvas.Brush.Color := clWhite;
          GraphicsOutputForm.Canvas.FillRect
              (Rect (0, 0, RasterColumns, RasterRows));
          LADSBitmap.Canvas.FillRect (Rect (0, 0, RasterColumns, RasterRows));
          V25_PRODUCE_SPOT_DIAGRAM;
          GraphicsOutputForm.Canvas.TextOut ((Round (RasterColumns * 0.5) + 10),
              (RasterRows - 40), 'Press ENTER key to continue...');
	  LADSBitmap.Canvas.TextOut
	      ((Round (RasterColumns * 0.5) + 10),
              (RasterRows - 40),
	      'Press ENTER key to continue...');
          GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);
	  S01_PROCESS_REQUEST
	END
      ELSE
      IF ZFA_OPTION.DRAW_RAYS THEN
        BEGIN
          GraphicsOutputForm.Canvas.TextOut (10, (RasterRows - 40),
              '  Press ENTER key to continue...');
	  LADSBitmap.Canvas.TextOut
              (10, (RasterRows - 40),
              '  Press ENTER key to continue...');
(*        GraphicsOutputForm.Visible := TRUE;
          GraphicsOutputForm.Color := clWhite;*)
          GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);
          S01_PROCESS_REQUEST
	END
      ELSE
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('FULL SPOT DIAMETER (CENTROID-BASED): ' +
	      FloatToStr (ARD_BLUR_SPHERE_DIAMETER))
	END
    END;

  IF GraphicsActive THEN
    BEGIN
      IF AimPrincipalRays THEN
      ELSE
      IF KeyboardActivityDetected THEN
      ELSE
      IF NoErrors THEN
      ELSE
        BEGIN
          GraphicsOutputForm.Canvas.TextOut (10, (RasterRows - 50),
              'ATTENTION:  FATAL ERROR OCCURRED DURING RAY TRACE.');
	  LADSBitmap.Canvas.TextOut
              (10, (RasterRows - 50),
              'ATTENTION:  FATAL ERROR OCCURRED DURING RAY TRACE.');
          GraphicsOutputForm.Canvas.TextOut (10, (RasterRows - 10),
              '  Press ENTER key to continue...');
	  LADSBitmap.Canvas.TextOut
              (10, (RasterRows - 10),
              '  Press ENTER key to continue...');
(*        GraphicsOutputForm.Visible := TRUE;
          GraphicsOutputForm.Color := clWhite;*)
          GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);
	  S01_PROCESS_REQUEST
        END;
      LADSBitmap.Free;
      GraphicsOutputForm.Visible := FALSE;
      GraphicsActive := FALSE
    END;

  IF KeyboardActivityDetected THEN
    ResetKeyboardActivity;

  IF NoErrors THEN
    IF AimPrincipalRays THEN
      BEGIN
      END
    ELSE
      BEGIN
        IF ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED THEN
	  CommandIOMemo.IOHistory.Lines.add
              ('RMS SPOT DIAMETER AT DESIGNATED IMAGE SURFACE = ' +
	      FloatToStr (ARF_RMS_SPOT_DIAMETER));
        CommandIOMemo.IOHistory.Lines.add
            ('APERTURE-CENTERED DIA. OF DESIGNATED IMAGE SURFACE = ' +
        	  FloatToStr (ARN_MAX_IMAGE_DIAMETER));
        CommandIOMemo.IOHistory.Lines.add ('');
        CommandIOMemo.IOHistory.Lines.add
            ('SPOT CENTROID LOCATION IN LOCAL IMAGE SURF. COORDINATES:');
        CommandIOMemo.IOHistory.Lines.add ('  X = ' +
            FloatToStr (ARG_SPOT_X_CENTROID) + '  Y = ' +
        	  FloatToStr (ARH_SPOT_Y_CENTROID));
        SurfaceOrdinal := ZFA_OPTION.ZGK_DESIGNATED_SURFACE;
        XformOperands.CoordinateRotationNeeded :=
            ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            ZVL_COORDINATE_ROTATION_NEEDED;
        XformOperands.CoordinateTranslationNeeded :=
            ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            ZVK_COORDINATE_TRANSLATION_NEEDED;
        XformOperands.RotationMatrixElements :=
            ZVA_ROTATION_MATRIX [SurfaceOrdinal].
            SurfaceRotationMatrix;
        XformOperands.TranslationVectorElements.OriginX :=
            ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X;
        XformOperands.TranslationVectorElements.OriginY :=
            ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y;
        XformOperands.TranslationVectorElements.OriginZ :=
            ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z;
        XformOperands.Position.Rx := ARG_SPOT_X_CENTROID;
        XformOperands.Position.Ry := ARH_SPOT_Y_CENTROID;
        XformOperands.Position.Rz := ARI_SPOT_Z_CENTROID;
        XformOperands.Orientation.Tx := 0.0;
        XformOperands.Orientation.Ty := 0.0;
        XformOperands.Orientation.Tz := 0.0;
        TransformLocalCoordsToGlobal (XformOperands);
        CommandIOMemo.IOHistory.Lines.add
            ('SPOT CENTROID LOCATION IN WORLD COORDINATES:');
        CommandIOMemo.IOHistory.Lines.add ('  X = ' +
            FloatToStr (XformOperands.Position.Rx));
        CommandIOMemo.IOHistory.Lines.add ('  Y = ' +
            FloatToStr (XformOperands.Position.Ry));
        CommandIOMemo.IOHistory.Lines.add ('  Z = ' +
            FloatToStr (XformOperands.Position.Rz));
        SpotCentroidGlobalCoordsX := XformOperands.Position.Rx;
        SpotCentroidGlobalCoordsY := XformOperands.Position.Ry;
        SpotCentroidGlobalCoordsZ := XformOperands.Position.Rz;
        Q980_REQUEST_MORE_OUTPUT; (* Moved here from 5 lines down. *)
        IF ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST
	    OR ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST
            OR ZFA_OPTION.EnableLinearIntensityHist THEN
	  BEGIN
	    (*Q980_REQUEST_MORE_OUTPUT;*)
            IF (ARN_MAX_IMAGE_DIAMETER < 1.0E-12)
                OR (ARY_ACCUM_FINAL_INTENSITY < 1.0E-12)
                OR (ARX_ACCUM_INITIAL_INTENSITY < 1.0E-12) THEN
              BEGIN
                CommandIOMemo.IOHistory.Lines.add ('');
                CommandIOMemo.IOHistory.Lines.add
                ('ERROR:  Image surface diameter too small and/or');
                CommandIOMemo.IOHistory.Lines.add
                ('accumulated intensity value(s) too small to permit');
                CommandIOMemo.IOHistory.Lines.add
                ('computation of intensity histogram.')
              END
            ELSE
              BEGIN
                HistogramBuckets := 40;
                IF ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST THEN
	          V30_DISPLAY_INTENSITY_HISTOGRAM (FullDisplay,
                      TwoDimensEqualRadiusHistogram, HistogramBuckets,
                      MeritFunction)
                ELSE
                IF ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST THEN
	          V30_DISPLAY_INTENSITY_HISTOGRAM (FullDisplay,
                      TwoDimensEqualAreaHistogram, HistogramBuckets,
                      MeritFunction)
                ELSE
                IF ZFA_OPTION.EnableLinearIntensityHist THEN
	          V30_DISPLAY_INTENSITY_HISTOGRAM (FullDisplay,
                      OneDimensHistogram, HistogramBuckets, MeritFunction)
              END
          END;
        IF ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE THEN
          BEGIN
            (*V35_PRODUCE_SPOT_DIAGRAM_FILE;*)
            ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE := FALSE
          END;
        IF ZFA_OPTION.ZGF_DISPLAY_FULL_OPD THEN
	  BEGIN
	    Q980_REQUEST_MORE_OUTPUT;
	    V45_DISPLAY_OPD_STATISTICS
	  END
        ELSE
        IF ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
          V45_DISPLAY_OPD_STATISTICS;
        IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE THEN
          BEGIN
            V40_PRODUCE_PSF_FILE;
            ZFA_OPTION.ZFL_PRODUCE_PSF_FILE := FALSE;
            Q980_REQUEST_MORE_OUTPUT
          END
      END;

  IF OUTPUT_RAY_FILE_OPEN THEN
    BEGIN
      CLOSE (ZAL_OUTPUT_RAY_FILE);
      OUTPUT_RAY_FILE_OPEN := FALSE
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

  IF LIST_FILE_OPEN THEN
    BEGIN
      ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE := FALSE;
      IF NoErrors THEN
        WRITELN (ZAG_LIST_FILE);
      CLOSE (ZAG_LIST_FILE);
      LIST_FILE_OPEN := FALSE
    END;

  IF PRINT_FILE_OPEN THEN
    BEGIN
      IF NoErrors THEN
        WRITELN (ZAF_PRINT_FILE);
      CLOSE (ZAF_PRINT_FILE);
      PRINT_FILE_OPEN := FALSE
    END;

  IF DIFFRACT_WORK_FILE_OPEN THEN
    BEGIN
      CLOSE (ZAJ_DIFFRACT_WORK_FILE);
      ERASE (ZAJ_DIFFRACT_WORK_FILE);
      DIFFRACT_WORK_FILE_OPEN := FALSE
    END

END;




(**  F105_DRAW_SURFACES  ****************************************************
****************************************************************************)


PROCEDURE F105_DRAW_SURFACES;

BEGIN

  F03_VALIDATE_RAY_TRACE;

  IF NoErrors THEN
    BEGIN
      F05_INITIALIZE_FOR_TRACE;
      F06_INITIALIZE_FOR_GRAPHICS;
      F08_DRAW_SURFACES;
      GraphicsOutputForm.Canvas.TextOut (10, (RasterRows - 10),
          '  Press ENTER key to continue...');
      LADSBitmap.Canvas.TextOut
          (10, (RasterRows - 10),
          '  Press ENTER key to continue...');
(*    GraphicsOutputForm.Visible := TRUE;
      GraphicsOutputForm.Color := clWhite;*)
      GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap);
      S01_PROCESS_REQUEST;
      LADSBitmap.Free;
      GraphicsOutputForm.Visible := FALSE;
      GraphicsActive := FALSE
    END
  ELSE
    Q980_REQUEST_MORE_OUTPUT;

  IF OUTPUT_RAY_FILE_OPEN THEN
    BEGIN
      CLOSE (ZAL_OUTPUT_RAY_FILE);
      OUTPUT_RAY_FILE_OPEN := FALSE
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

  IF LIST_FILE_OPEN THEN
    BEGIN
      ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE := FALSE;
      IF NoErrors THEN
        WRITELN (ZAG_LIST_FILE);
      CLOSE (ZAG_LIST_FILE);
      LIST_FILE_OPEN := FALSE
    END;

  IF PRINT_FILE_OPEN THEN
    BEGIN
      IF NoErrors THEN
        WRITELN (ZAF_PRINT_FILE);
      CLOSE (ZAF_PRINT_FILE);
      PRINT_FILE_OPEN := FALSE
    END;

  IF DIFFRACT_WORK_FILE_OPEN THEN
    BEGIN
      CLOSE (ZAJ_DIFFRACT_WORK_FILE);
      ERASE (ZAJ_DIFFRACT_WORK_FILE);
      DIFFRACT_WORK_FILE_OPEN := FALSE
    END

END;




(**  LADSTraceUnit  **********************************************************
*****************************************************************************)

BEGIN

END.

