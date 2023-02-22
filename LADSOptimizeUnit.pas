UNIT LADSOptimizeUnit;

INTERFACE

  VAR
      ZLA_OPTIMIZATION_DATA                    : RECORD
	ZLB_OPTIMIZATION_ACTIVATED             : BOOLEAN;
	ZLE_BOUND_REDUCTION_ACTIVATED          : BOOLEAN;
	ZLF_BOUND_RECENTERING_ACTIVATED        : BOOLEAN;
	ZLD_MERIT_FUNCTION_CODE                : STRING [1];
	ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE     : DOUBLE;
	ZLY_OLD_MERIT_VALUE                    : DOUBLE
      END;

PROCEDURE W01_PROCESS_OPTIMIZATION;
PROCEDURE W90_INITIALIZE_OPTIMIZATION
    (VAR NoErrors  : BOOLEAN);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSRandomUnit,
       LADSData,
       LADSArchiveUnit,
       LADSEnvironUnit,
       LADSInitUnit,
       LADSGlassVar,
       LADSCommandIOMemoUnit;
       
  VAR
      PositionBubbleSortReqd  : BOOLEAN;
      OptimizeByRMSBlur       : BOOLEAN;
      OptimizeByFullBlur      : BOOLEAN;
      OptimizeByAngle         : BOOLEAN;
      
      HiJ                     : INTEGER;
      
      AAB_SURFACE_Z_ORDER : ARRAY [1..CZAB_MAX_NUMBER_OF_SURFACES] OF 0..255;
      
       
(**  W01_PROCESS_OPTIMIZATION  ************************************************
******************************************************************************)


PROCEDURE W01_PROCESS_OPTIMIZATION;

VAR
    SaveIOResult : INTEGER;
    
    HOLD_STRING  : STRING [20];
    
    YEAR         : WORD;
    MONTH        : WORD;
    DAY          : WORD;
    WEEKDAY      : WORD;
    HOUR         : WORD;
    MINUTE       : WORD;
    SECOND       : WORD;
    FRACTION     : WORD;


(**  W10_GLOBAL_PARAMETER_VARIATION  ******************************************
******************************************************************************)


PROCEDURE W10_GLOBAL_PARAMETER_VARIATION;

  VAR
      NO_POSITION_ERRORS              : BOOLEAN;
  
      I                               : INTEGER;
      J                               : INTEGER;
      NEXT_SURF                       : INTEGER;
      
      W10AA_TEMP_HOLD                 : DOUBLE;
      W10AB_LOWER_BOUND               : DOUBLE;
      W10AC_UPPER_BOUND               : DOUBLE;
      NEXT_Z                          : DOUBLE;
      

(**  W1005_BUBBLE_SORT_ON_POSITION  *******************************************
******************************************************************************)


PROCEDURE W1005_BUBBLE_SORT_ON_POSITION;

  VAR
      DONE    : BOOLEAN;
      
      I       : INTEGER;
      HOLD_I  : INTEGER;
      
      HOLD_Z  : DOUBLE;

BEGIN

  I := 2;

  REPEAT
    IF ZBA_SURFACE [AAB_SURFACE_Z_ORDER [I]].ZBQ_VERTEX_Z >
	ZBA_SURFACE [AAB_SURFACE_Z_ORDER [I - 1]].ZBQ_VERTEX_Z THEN
      I := I + 1
    ELSE
      BEGIN
	HOLD_Z := ZBA_SURFACE [AAB_SURFACE_Z_ORDER [I]].ZBQ_VERTEX_Z;
	HOLD_I := I;
	DONE := FALSE;
	REPEAT
	  BEGIN
	    ZBA_SURFACE [AAB_SURFACE_Z_ORDER [I]].ZBQ_VERTEX_Z :=
		ZBA_SURFACE [AAB_SURFACE_Z_ORDER [I - 1]].ZBQ_VERTEX_Z;
	    I := I - 1;
	    IF I < 2 THEN
	      DONE := TRUE
	    ELSE
	      IF (HOLD_Z > ZBA_SURFACE [AAB_SURFACE_Z_ORDER [I - 1]].
		  ZBQ_VERTEX_Z) THEN
		DONE := TRUE
	  END
	UNTIL DONE;
	ZBA_SURFACE [AAB_SURFACE_Z_ORDER [I]].ZBQ_VERTEX_Z := HOLD_Z;
	I := HOLD_I + 1
      END
  UNTIL
    I > HiJ

END;




(**  W10_GLOBAL_PARAMETER_VARIATION  ******************************************
******************************************************************************)


BEGIN

  I := 1;
  
  REPEAT
    BEGIN
      IF ZBA_SURFACE [I].ZBB_SPECIFIED
	  AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	BEGIN
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMC_OPTIMIZE_RADIUS THEN
	    BEGIN
	      W10AB_LOWER_BOUND := LN (ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1);
	      W10AC_UPPER_BOUND := LN (ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2);
	      RANDGEN;
	      ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV :=
		  EXP ((W10AC_UPPER_BOUND - W10AB_LOWER_BOUND) *
		  RANDOM + W10AB_LOWER_BOUND);
	    (*IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
		  ZME_PERMIT_SURF_PITCH_REVERSAL THEN
		BEGIN
		  RANDGEN;
		  IF RANDOM < 0.5 THEN
		    ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV := -1.0 *
			ABS (ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV)
		  ELSE
		    ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV :=
			ABS (ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV)
		END;*)
	      (* Set surface diameter based on radius of curvature. *)
	      IF ZBA_SURFACE [I].ZCL_OUTSIDE_APERTURE_IS_SQR
		  OR ZBA_SURFACE [I].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
		BEGIN
		END
	      ELSE
		BEGIN
		  IF ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV <> 0.0 THEN
		    IF ZBA_SURFACE [I].ZBH_OUTSIDE_DIMENS_SPECD THEN
		    ELSE
		      ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA :=
			  1.9 * ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV
		  ELSE
		    ZBA_SURFACE [I].ZBJ_OUTSIDE_APERTURE_DIA := 1.0E20
		END
	    END;
	  IF ZBA_SURFACE [I].
	      ZMB_OPTIMIZATION_SWITCHES.ZMK_OPTIMIZE_CONIC_CONSTANT THEN
	    BEGIN
	      RANDGEN;
	      ZBA_SURFACE [I].ZBL_CONIC_CONSTANT :=
		  (ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 -
		  ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1) * RANDOM +
		  ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1
	    END;
	  IF ZBA_SURFACE [I].
	      ZMB_OPTIMIZATION_SWITCHES.ZMI_OPTIMIZE_GLASS THEN
	    BEGIN
	      IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [1] THEN
		ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME :=
		    ZBA_SURFACE [I - 1].ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME;
	      IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2] THEN
		BEGIN
		  RANDGEN;
		  ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME :=
		      ZKA_MINI_GLASS_CATALOG.
		      ZKB_GLASS_DATA [TRUNC (RANDOM *
		      ABD_GLASS_HIGH_PTR) + 1].ZJC_GLASS_NAME
		END
	    END
	END;
      I := I + 1
    END
  UNTIL
    (I > CZAB_MAX_NUMBER_OF_SURFACES);
    
  NO_POSITION_ERRORS := TRUE;
  
  REPEAT
    BEGIN
      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
	IF ZBA_SURFACE [I].ZBB_SPECIFIED
	    AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	  IF ZBA_SURFACE [I].
	      ZMB_OPTIMIZATION_SWITCHES.ZMG_OPTIMIZE_POSITION THEN
	    BEGIN
	      W10AB_LOWER_BOUND := ZBA_SURFACE [I].ZMU_POSITION_BOUND_1;
	      W10AC_UPPER_BOUND := ZBA_SURFACE [I].ZMV_POSITION_BOUND_2;
	      IF W10AB_LOWER_BOUND > W10AC_UPPER_BOUND THEN
		BEGIN
		  W10AA_TEMP_HOLD := W10AC_UPPER_BOUND;
		  W10AC_UPPER_BOUND := W10AB_LOWER_BOUND;
		  W10AB_LOWER_BOUND := W10AA_TEMP_HOLD
		END;
	      RANDGEN;
	      ZBA_SURFACE [I].ZBQ_VERTEX_Z :=
		  (W10AC_UPPER_BOUND - W10AB_LOWER_BOUND) * RANDOM +
		  W10AB_LOWER_BOUND
	    END;
      IF PositionBubbleSortReqd THEN
	BEGIN
	  W1005_BUBBLE_SORT_ON_POSITION;
	  NO_POSITION_ERRORS := TRUE;
	  J := 1;
	  NEXT_SURF := 0;
	  REPEAT
	    BEGIN
	      I := AAB_SURFACE_Z_ORDER [J];
	      IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
		  ZMM_CONTROL_SEPARATION THEN
		BEGIN
		  NEXT_SURF := ZBA_SURFACE [I].ZLN_NEXT_SURFACE;
		  RANDGEN;
		  NEXT_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z + ZBA_SURFACE [I].
		      ZLQ_THICKNESS + ZBA_SURFACE [I].ZLO_DELTA_THICKNESS *
		      (RANDOM - 0.5);
		  W10AB_LOWER_BOUND := ZBA_SURFACE [I].ZMU_POSITION_BOUND_1;
		  W10AC_UPPER_BOUND := ZBA_SURFACE [I].ZMV_POSITION_BOUND_2;
		  IF W10AB_LOWER_BOUND > W10AC_UPPER_BOUND THEN
		    BEGIN
		      W10AA_TEMP_HOLD := W10AC_UPPER_BOUND;
		      W10AC_UPPER_BOUND := W10AB_LOWER_BOUND;
		      W10AB_LOWER_BOUND := W10AA_TEMP_HOLD
		    END;
		  IF NEXT_Z > ZBA_SURFACE [I].ZBQ_VERTEX_Z THEN
		    BEGIN
		      IF (NEXT_Z <= W10AC_UPPER_BOUND) THEN
			IF (J + 2) <= HiJ THEN
			  IF (NEXT_Z <
			      ZBA_SURFACE [AAB_SURFACE_Z_ORDER [J + 2]].
			      ZBQ_VERTEX_Z) THEN
			  ELSE
			    NO_POSITION_ERRORS := FALSE
			ELSE
		      ELSE
			NO_POSITION_ERRORS := FALSE;
		      IF NO_POSITION_ERRORS THEN
			ZBA_SURFACE [NEXT_SURF].ZBQ_VERTEX_Z := NEXT_Z
		    END
		  ELSE
		    BEGIN
		      IF (NEXT_Z >= W10AB_LOWER_BOUND) THEN
			IF (J - 2) > 0 THEN
			  IF (NEXT_Z >
			      ZBA_SURFACE [AAB_SURFACE_Z_ORDER [J - 2]].
			      ZBQ_VERTEX_Z) THEN
			  ELSE
			    NO_POSITION_ERRORS := FALSE
			ELSE
		      ELSE
			NO_POSITION_ERRORS := FALSE;
		      IF NO_POSITION_ERRORS THEN
			ZBA_SURFACE [NEXT_SURF].ZBQ_VERTEX_Z := NEXT_Z
		    END
		END;
	      J := J + 1
	    END
	  UNTIL (NOT NO_POSITION_ERRORS)
	      OR (J >= HiJ)
	END
    END
  UNTIL
    NO_POSITION_ERRORS
    
END;




(**  W15_ADJUST_OPTIMIZATION_BOUNDS  ******************************************
******************************************************************************)


PROCEDURE W15_ADJUST_OPTIMIZATION_BOUNDS;

  VAR
      I       : INTEGER;
      
      DELTA   : DOUBLE;
      FACTOR  : DOUBLE;

BEGIN
	  
  (* Re-center optimization bounds about present values for the radius
     and the conic constant. *)
     
  IF ZLA_OPTIMIZATION_DATA.ZLF_BOUND_RECENTERING_ACTIVATED THEN
    FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
      IF ZBA_SURFACE [I].ZBB_SPECIFIED
	  AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	BEGIN
	  IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	      ZMC_OPTIMIZE_RADIUS THEN
	    BEGIN
	      DELTA := LN (ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2) -
		  LN (ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1);
	      IF ZLA_OPTIMIZATION_DATA.ZLE_BOUND_REDUCTION_ACTIVATED THEN
		BEGIN
		  FACTOR := ZLA_OPTIMIZATION_DATA.
		      ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE /
		      ZLA_OPTIMIZATION_DATA.ZLY_OLD_MERIT_VALUE;
		  IF FACTOR >= 0.2 THEN
		    DELTA := DELTA * FACTOR
		END;
	      ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 :=
		  EXP (LN (ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV) - 0.5 * DELTA);
	      ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 :=
		  EXP (LN (ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV) + 0.5 * DELTA)
	    END;
	  IF ZBA_SURFACE [I].
	      ZMB_OPTIMIZATION_SWITCHES.ZMK_OPTIMIZE_CONIC_CONSTANT THEN
	    BEGIN
	      DELTA := ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 -
		  ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1;
	      IF ZLA_OPTIMIZATION_DATA.ZLE_BOUND_REDUCTION_ACTIVATED THEN
		BEGIN
		  FACTOR := ZLA_OPTIMIZATION_DATA.
		      ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE /
		      ZLA_OPTIMIZATION_DATA.ZLY_OLD_MERIT_VALUE;
		  IF FACTOR >= 0.2 THEN
		    DELTA := DELTA * FACTOR
		END;
	      ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 :=
		  ZBA_SURFACE [I].ZBL_CONIC_CONSTANT - 0.5 * DELTA;
	      ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 :=
		  ZBA_SURFACE [I].ZBL_CONIC_CONSTANT + 0.5 * DELTA
	    END
	END

END;




(**  W20_CLEAN_UP_RADII  ******************************************************
******************************************************************************)


PROCEDURE W20_CLEAN_UP_RADII;

  VAR
      I                 : INTEGER;
      
      SAVE_ENVIRONMENT  : ENVIRONMENT_DATA_REC;

BEGIN

(*FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    IF ZBA_SURFACE [I].ZBB_SPECIFIED
	AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
      IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	    ZMC_OPTIMIZE_RADIUS
	  AND ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	    ZME_PERMIT_SURF_PITCH_REVERSAL THEN
	IF ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV < 0.0 THEN
	  BEGIN
	    ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV :=
		ABS (ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV);
	    SAVE_ENVIRONMENT := ZHA_ENVIRONMENT.ZIA_ALL_ENVIRONMENT_DATA;
	    ZHA_ENVIRONMENT.ZIA_ALL_ENVIRONMENT_DATA :=
		ENVIRONMENT_DATA_INITIALIZER;
	    ZHA_ENVIRONMENT.ZHD_USE_LOCAL_COORDS := TRUE;
	    ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK := I;
	    ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK := I;
	    ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X := ZBA_SURFACE [I].
		ZBM_VERTEX_X + ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X;
	    ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y := ZBA_SURFACE [I].
		ZBO_VERTEX_Y + ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y;
	    ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z := ZBA_SURFACE [I].
		ZBQ_VERTEX_Z + ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z;
	    ZHA_ENVIRONMENT.ZHS_PITCH := 180.0;
	    AIN_TRANSLATE := FALSE;
	    AIQ_ADJUST_THICKNESS := FALSE;
	    AIP_PERFORM_SYSTEMIC_ROTATION := TRUE;
	    H01_SET_UP_ENVIRONMENT;
	    ZHA_ENVIRONMENT.ZIA_ALL_ENVIRONMENT_DATA := SAVE_ENVIRONMENT
	  END*)

END;




(**  W01_PROCESS_OPTIMIZATION  ************************************************
******************************************************************************)


BEGIN

  (* We come into here from LADSF and LADSV (i.e., V20) with an RMS or full
     blur circle size for the present set of optimization parameter values.
     If an intensity of 0.0 has been detected at the designated surface by
     V20, the RMS and full blur diameters will have been set to 1.0E20 by
     V20. *)

  IF KeyboardActivityDetected THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('KEYBOARD ACTIVITY DETECTED.  RESTORING SURFACE INFO...');
      Q980_REQUEST_MORE_OUTPUT;
      AKA_PUT_DATA_IN_TEMPORARY_STORAGE := FALSE;
      AKB_GET_DATA_FROM_TEMPORARY_STORAGE := TRUE;
      G01_ARCHIVE_DATA
    END
  ELSE
    BEGIN
      IF ARB_TOTAL_RECURS_INTERCEPTS =
	  AAA_TOTAL_RAYS_TO_TRACE THEN
	IF OptimizeByRMSBlur THEN
	  BEGIN
	    IF (ARF_RMS_SPOT_DIAMETER < ZLA_OPTIMIZATION_DATA.
		ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE) THEN
	      BEGIN
                HOLD_STRING := DateToStr (Date) + ' ' + TimeToStr (Time);
		CommandIOMemo.IOHistory.Lines.add ('RMS SPOT DIA. = ' +
                    FloatToStr (ARF_RMS_SPOT_DIAMETER) + '  ' + HOLD_STRING);
		ZLA_OPTIMIZATION_DATA.ZLY_OLD_MERIT_VALUE :=
		    ZLA_OPTIMIZATION_DATA.ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE;
		ZLA_OPTIMIZATION_DATA.ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE :=
		    ARF_RMS_SPOT_DIAMETER;
		AKA_PUT_DATA_IN_TEMPORARY_STORAGE := TRUE;
		AKB_GET_DATA_FROM_TEMPORARY_STORAGE := FALSE;
		ASSIGN (ZAB_ARCHIVE_FILE, AKZ_ARCHIVE_FILE_NAME);
		{$I-}
		RESET (ZAB_ARCHIVE_FILE, CZBG_CHARS_IN_ONE_BLOCK);
		{$I+}
		SaveIOResult := IORESULT;
		IF SaveIOResult = 0 THEN
		  BEGIN
		    CLOSE (ZAB_ARCHIVE_FILE);
		    ERASE (ZAB_ARCHIVE_FILE)
		  END;
		W20_CLEAN_UP_RADII;
		W15_ADJUST_OPTIMIZATION_BOUNDS;
		G01_ARCHIVE_DATA
	      END
	  END
	ELSE
	IF OptimizeByFullBlur THEN
	  BEGIN
	    IF (ARD_BLUR_SPHERE_DIAMETER < ZLA_OPTIMIZATION_DATA.
		ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE) THEN
	      BEGIN
                HOLD_STRING := DateToStr (Date) + ' ' + TimeToStr (Time);
		CommandIOMemo.IOHistory.Lines.add ('FULL SPOT DIA. = ' +
                    FloatToStr (ARD_BLUR_SPHERE_DIAMETER) + '  ' + HOLD_STRING);
		ZLA_OPTIMIZATION_DATA.ZLY_OLD_MERIT_VALUE :=
		    ZLA_OPTIMIZATION_DATA.ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE;
		ZLA_OPTIMIZATION_DATA.ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE :=
		    ARD_BLUR_SPHERE_DIAMETER;
		AKA_PUT_DATA_IN_TEMPORARY_STORAGE := TRUE;
		AKB_GET_DATA_FROM_TEMPORARY_STORAGE := FALSE;
		ASSIGN (ZAB_ARCHIVE_FILE, AKZ_ARCHIVE_FILE_NAME);
		{$I-}
		RESET (ZAB_ARCHIVE_FILE, CZBG_CHARS_IN_ONE_BLOCK);
		{$I+}
		SaveIOResult := IORESULT;
		IF SaveIOResult = 0 THEN
		  BEGIN
		    CLOSE (ZAB_ARCHIVE_FILE);
		    ERASE (ZAB_ARCHIVE_FILE)
		  END;
		W20_CLEAN_UP_RADII;
		W15_ADJUST_OPTIMIZATION_BOUNDS;
		G01_ARCHIVE_DATA
	      END
	  END;
      W10_GLOBAL_PARAMETER_VARIATION
    END;
      
  ARC_RECURS_INT_BLOCK_SLOT := 1;
  ARW_RECURS_INT_BLOCK_NMBR := 0;
  ARX_ACCUM_INITIAL_INTENSITY := 0.0;
  ARY_ACCUM_FINAL_INTENSITY := 0.0;
  ARB_TOTAL_RECURS_INTERCEPTS := 0;
  NoErrors := TRUE
    
END;




(**  W90_INITIALIZE_OPTIMIZATION  *********************************************
******************************************************************************)


PROCEDURE W90_INITIALIZE_OPTIMIZATION;

  VAR
      I                                  : INTEGER;
      J                                  : INTEGER;
      K                                  : INTEGER;
      L                                  : INTEGER;
      HOLD_J                             : INTEGER;
      
      DONE                               : BOOLEAN;
      W90AE_POSITION_OPTIMIZATION_SPECD  : BOOLEAN;
      W90AF_OPTIMIZE_GLASS               : BOOLEAN;
      
      W90AD_TEMP_HOLD                    : DOUBLE;
      W90AC_UPPER_BOUND                  : DOUBLE;
      W90AB_LOWER_BOUND                  : DOUBLE;
      REF_Z                              : DOUBLE;
      
      W90AA_TEMP_STRING                  : STRING [1];


(**  W9005_VALIDATE_POSITION_OPTIM  *******************************************
******************************************************************************)


PROCEDURE W9005_VALIDATE_POSITION_OPTIM;

  VAR
      I  : INTEGER;
      J  : INTEGER;

BEGIN

  FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    IF ZBA_SURFACE [I].ZBB_SPECIFIED
	AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
      BEGIN
	ZBA_SURFACE [I].ZBQ_VERTEX_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z +
	    ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z;
	ZBA_SURFACE [I].ZBR_VERTEX_DELTA_Z := 0.0
      END;
  
  DONE := FALSE;
  I := 1;
  
  REPEAT
    IF ZBA_SURFACE [I].ZBB_SPECIFIED
	AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
      DONE := TRUE
    ELSE
      I := I + 1
  UNTIL DONE;
  
  AAB_SURFACE_Z_ORDER [1] := I;
  I := I + 1;
  HiJ := 1;
  
  WHILE (I <= CZAB_MAX_NUMBER_OF_SURFACES) DO
    BEGIN
      IF ZBA_SURFACE [I].ZBB_SPECIFIED
	  AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	BEGIN
	  J := 1;
	  DONE := FALSE;
	  REPEAT
	    BEGIN
	      IF ZBA_SURFACE [I].ZBQ_VERTEX_Z > 
		  ZBA_SURFACE [AAB_SURFACE_Z_ORDER [J]].ZBQ_VERTEX_Z THEN
		BEGIN
		  J := J + 1;
		  IF J > HiJ THEN
		    BEGIN
		      HiJ := J;
		      AAB_SURFACE_Z_ORDER [HiJ] := I;
		      DONE := TRUE
		    END
		END
	      ELSE
		BEGIN
		  HOLD_J := J;
		  FOR J := HiJ DOWNTO J DO
		    AAB_SURFACE_Z_ORDER [J + 1] := AAB_SURFACE_Z_ORDER [J];
		  J := HOLD_J;
		  AAB_SURFACE_Z_ORDER [J] := I;
		  HiJ := HiJ + 1;
		  DONE := TRUE
		END
	    END
	  UNTIL DONE
	END;
      I := I + 1
    END;
  
  FOR J := 1 TO HiJ DO
    BEGIN
      I := AAB_SURFACE_Z_ORDER [J];
      IF ZBA_SURFACE [I].
	  ZMB_OPTIMIZATION_SWITCHES.ZMG_OPTIMIZE_POSITION THEN
	BEGIN
	  W90AB_LOWER_BOUND := ZBA_SURFACE [I].ZMU_POSITION_BOUND_1;
	  W90AC_UPPER_BOUND := ZBA_SURFACE [I].ZMV_POSITION_BOUND_2;
	  IF W90AB_LOWER_BOUND > W90AC_UPPER_BOUND THEN
	    BEGIN
	      W90AD_TEMP_HOLD := W90AC_UPPER_BOUND;
	      W90AC_UPPER_BOUND := W90AB_LOWER_BOUND;
	      W90AB_LOWER_BOUND := W90AD_TEMP_HOLD
	    END;
	  IF (ZBA_SURFACE [I].ZBQ_VERTEX_Z >= W90AB_LOWER_BOUND)
	      AND (ZBA_SURFACE [I].ZBQ_VERTEX_Z <= W90AC_UPPER_BOUND) THEN
	    ELSE
	      BEGIN
		NoErrors := FALSE;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('OPTIMIZATION VALIDATION ERROR, surface ' +
                    IntToStr (I) + '.');
		CommandIOMemo.IOHistory.Lines.add
                    ('Initial position of surface is outside stated');
		CommandIOMemo.IOHistory.Lines.add ('position bounds.');
                Q980_REQUEST_MORE_OUTPUT
	      END
	END;
      IF ZBA_SURFACE [I].
	  ZMB_OPTIMIZATION_SWITCHES.ZMM_CONTROL_SEPARATION THEN
	BEGIN
	  IF ZBA_SURFACE [ZBA_SURFACE [I].ZLN_NEXT_SURFACE].
	      ZMB_OPTIMIZATION_SWITCHES.ZMG_OPTIMIZE_POSITION THEN
	  ELSE
	    NoErrors := FALSE;
	  IF ZBA_SURFACE [I].ZMU_POSITION_BOUND_1 =
	      ZBA_SURFACE [ZBA_SURFACE [I].ZLN_NEXT_SURFACE].
	      ZMU_POSITION_BOUND_1 THEN
	  ELSE
	    NoErrors := FALSE;
	  IF ZBA_SURFACE [I].ZMV_POSITION_BOUND_2 =
	      ZBA_SURFACE [ZBA_SURFACE [I].ZLN_NEXT_SURFACE].
	      ZMV_POSITION_BOUND_2 THEN
	  ELSE
	    NoErrors := FALSE;
	  IF (ABS (ZBA_SURFACE [I].ZLQ_THICKNESS) - 0.5 *
	      ZBA_SURFACE [I].ZLO_DELTA_THICKNESS) >= 0.0 THEN
	  ELSE
	    NoErrors := FALSE;
	  IF ZBA_SURFACE [I].
	      ZLQ_THICKNESS >= 0.0 THEN
	    IF J < HiJ THEN
	      IF ZBA_SURFACE [I].ZLN_NEXT_SURFACE =
		  AAB_SURFACE_Z_ORDER [J + 1] THEN
	      ELSE
		NoErrors := FALSE
	    ELSE
	      NoErrors := FALSE
	  ELSE
	    IF J > 1 THEN
	      IF ZBA_SURFACE [I].ZLN_NEXT_SURFACE =
		  AAB_SURFACE_Z_ORDER [J - 1] THEN
	      ELSE
		NoErrors := FALSE
	    ELSE
	      NoErrors := FALSE;
	  IF NOT NoErrors THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('OPTIMIZATION VALIDATION ERROR, surface ' +
                  IntToStr (I) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Thickness discrepancy found.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('The primary and secondary surface position bounds' +
		  ' are not equal, or');
	      CommandIOMemo.IOHistory.Lines.add
                  ('the secondary surface is not the closest' +
		  ' surface to the primary surface,');
	      CommandIOMemo.IOHistory.Lines.add
                  ('or the secondary surface does not initially lie' +
		  ' within the stated');
	      CommandIOMemo.IOHistory.Lines.add
                  ('thickness bounds for the primary surface.');
              Q980_REQUEST_MORE_OUTPUT
	    END
	END
    END;

  J := 1;

  WHILE NoErrors
      AND (J <= HiJ) DO
    BEGIN
      I := AAB_SURFACE_Z_ORDER [J];
      IF ZBA_SURFACE [I].
	  ZMB_OPTIMIZATION_SWITCHES.ZMG_OPTIMIZE_POSITION THEN
	BEGIN
	  IF (ABS (ZBA_SURFACE [I].ZBM_VERTEX_X) > 1.0E-12)
	      OR (ABS (ZBA_SURFACE [I].ZBN_VERTEX_DELTA_X) > 1.0E-12)
	      OR (ABS (ZBA_SURFACE [I].ZBO_VERTEX_Y) > 1.0E-12)
	      OR (ABS (ZBA_SURFACE [I].ZBP_VERTEX_DELTA_Y) > 1.0E-12) THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('OPTIMIZATION VALIDATION MESSAGE, surface ' +
                  IntToStr (I) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Position optimization will only affect the');
	      CommandIOMemo.IOHistory.Lines.add
                  ('z-axis position for this surface.');
              Q980_REQUEST_MORE_OUTPUT
	    END
	END
      ELSE
	BEGIN
	  REF_Z := ZBA_SURFACE [I].ZBQ_VERTEX_Z;
	  K := 1;
	  REPEAT
	    BEGIN
	      L := AAB_SURFACE_Z_ORDER [K];
	      IF ZBA_SURFACE [L].ZMB_OPTIMIZATION_SWITCHES.
		  ZMG_OPTIMIZE_POSITION THEN
		IF ((REF_Z > ZBA_SURFACE [L].ZMU_POSITION_BOUND_1)
		    AND (REF_Z > ZBA_SURFACE [L].ZMV_POSITION_BOUND_2))
		  OR
			((REF_Z < ZBA_SURFACE [L].ZMU_POSITION_BOUND_1)
		    AND (REF_Z < ZBA_SURFACE [L].ZMV_POSITION_BOUND_2)) THEN
		ELSE
		  NoErrors := FALSE;
	      IF NoErrors THEN
		K := K + 1
	      ELSE
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                      ('OPTIMIZATION VALIDATION ERROR, surface ' +
                      IntToStr (L) + '.');
		  CommandIOMemo.IOHistory.Lines.add
                      ('Position bounds on surface ' + IntToStr (L) +
		      ' overlap the position');
		  CommandIOMemo.IOHistory.Lines.add ('of stationary surface ' +
                      IntToStr (I) + '.');
                  Q980_REQUEST_MORE_OUTPUT
		END
	    END
	  UNTIL (NOT NoErrors)
	      OR (K > HiJ)
	END;
	J := J + 1
    END
  
END;




(**  W9010_VALIDATE_GLASS_OPTIM  **********************************************
******************************************************************************)


PROCEDURE W9010_VALIDATE_GLASS_OPTIM;

  VAR
      DONE                             : BOOLEAN;
      W9010AA_FIRST_SURF_OF_LENS       : BOOLEAN;
      W9010AG_OPTIMIZE_LENS_GLASS      : BOOLEAN;
      
      I                                : INTEGER;
      W9010AB_PREV_SURF                : INTEGER;
      
      W9010AC_PREV_INDEX_OR_GLASS      : ZCZ_INDEX_RECORD;
      W9010AF_HOLD_INCIDENT_INDEX      : ZCZ_INDEX_RECORD;

BEGIN

  I := 1;
  DONE := FALSE;
  
  REPEAT
    IF ZNA_RAY [I].ZNB_SPECIFIED
	AND ZNA_RAY [I].ZNC_ACTIVE THEN
      BEGIN
	W9010AF_HOLD_INCIDENT_INDEX.ZBI_REFRACTIVE_INDEX :=
	    ZNA_RAY [I].ZNK_INCIDENT_MEDIUM_INDEX;
	DONE := TRUE
      END
    ELSE
      I := I + 1
  UNTIL DONE
      OR (I > CZAC_MAX_NUMBER_OF_RAYS);
      
  IF NOT DONE THEN
    BEGIN
      NoErrors := FALSE;
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
          ('OPTIMIZATION VALIDATION ERROR: Incident refractive index');
      CommandIOMemo.IOHistory.Lines.add ('not specified.');
      Q980_REQUEST_MORE_OUTPUT
    END;
    
  I := 1;
  W9010AC_PREV_INDEX_OR_GLASS := W9010AF_HOLD_INCIDENT_INDEX;
  W9010AA_FIRST_SURF_OF_LENS := TRUE;
  
  WHILE NoErrors
      AND (I <= CZAB_MAX_NUMBER_OF_SURFACES) DO
    BEGIN
      IF ZBA_SURFACE [I].ZBB_SPECIFIED
	  AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
	IF (ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [1]
	    AND (W9010AC_PREV_INDEX_OR_GLASS.ZCH_GLASS_NAME =
	    ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME))
	    OR ((NOT ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [1])
	    AND (W9010AC_PREV_INDEX_OR_GLASS.ZBI_REFRACTIVE_INDEX =
	    ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [1].ZBI_REFRACTIVE_INDEX)) THEN
	  BEGIN
	    IF ZBA_SURFACE [I].ZBD_REFLECTIVE THEN
	      BEGIN
		IF (ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2]
		    AND (W9010AC_PREV_INDEX_OR_GLASS.ZCH_GLASS_NAME =
		    ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME))
		    OR ((NOT ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2])
		    AND (W9010AC_PREV_INDEX_OR_GLASS.ZBI_REFRACTIVE_INDEX =
		    ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2].
		    ZBI_REFRACTIVE_INDEX)) THEN
		  BEGIN
		    IF NOT ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
			ZMI_OPTIMIZE_GLASS THEN
		    ELSE
		      BEGIN
			NoErrors := FALSE;
			CommandIOMemo.IOHistory.Lines.add ('');
			CommandIOMemo.IOHistory.Lines.add
                            ('OPTIMIZATION VALIDATION ERROR, surface ' +
			    IntToStr (I) + '.');
			CommandIOMemo.IOHistory.Lines.add
                            ('Reflective surface may not be selected');
			CommandIOMemo.IOHistory.Lines.add
                            ('for glass optimization.');
                        Q980_REQUEST_MORE_OUTPUT
		      END
		  END
		ELSE
		  BEGIN
		    NoErrors := FALSE;
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
                        ('OPTIMIZATION VALIDATION ERROR, surface ' +
			IntToStr (I) + '.');
		    CommandIOMemo.IOHistory.Lines.add
                        ('Exit medium refractive index for');
		    CommandIOMemo.IOHistory.Lines.add ('reflective surface ' +
                        IntToStr (I) + ' not equal to incident');
		    CommandIOMemo.IOHistory.Lines.add
                        ('medium refractive index.');
                    Q980_REQUEST_MORE_OUTPUT
		  END
	      END
	    ELSE
	      BEGIN
		W9010AC_PREV_INDEX_OR_GLASS :=
		    ZBA_SURFACE [I].ZCG_INDEX_OR_GLASS [2];
		IF W9010AA_FIRST_SURF_OF_LENS THEN
		  BEGIN
		    W9010AB_PREV_SURF := I;
		    W9010AA_FIRST_SURF_OF_LENS := FALSE;
		    IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
			ZMI_OPTIMIZE_GLASS THEN
		      BEGIN
			IF ZBA_SURFACE [I].ZCF_GLASS_NAME_SPECIFIED [2] THEN
			ELSE
			  BEGIN
			    NoErrors := FALSE;
			    CommandIOMemo.IOHistory.Lines.add ('');
			    CommandIOMemo.IOHistory.Lines.add
                                ('OPTIMIZATION VALIDATION ERROR,' +
				' surface ' + IntToStr (I) + '.');
			    CommandIOMemo.IOHistory.Lines.add
                                ('Glass optimization specified, but' +
				' surface has no glass type');
                            Q980_REQUEST_MORE_OUTPUT
			  END
		      END
		  END
		ELSE
		  BEGIN
		    W9010AA_FIRST_SURF_OF_LENS := TRUE;
		    IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
			  ZMI_OPTIMIZE_GLASS THEN
		      BEGIN
			IF ZBA_SURFACE [W9010AB_PREV_SURF].
			    ZMB_OPTIMIZATION_SWITCHES.ZMI_OPTIMIZE_GLASS THEN
			ELSE
			  BEGIN
			    NoErrors := FALSE;
			    CommandIOMemo.IOHistory.Lines.add ('');
			    CommandIOMemo.IOHistory.Lines.add
                                ('OPTIMIZATION VALIDATION ERROR, surface ' +
                                IntToStr (I) + '.');
			    CommandIOMemo.IOHistory.Lines.add
                                ('Glass optimization must be' +
				' specified for pairs of surfaces,');
			    CommandIOMemo.IOHistory.Lines.add
                                ('i.e., for an entire lens.');
                            Q980_REQUEST_MORE_OUTPUT
			  END
		      END
		  END
	      END
	  END
	ELSE
	  BEGIN
	    NoErrors := FALSE;
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('OPTIMIZATION VALIDATION ERROR, surface ' +
                IntToStr (I) + '.');
	    CommandIOMemo.IOHistory.Lines.add
                ('Incident medium refractive index specified for surface');
	    CommandIOMemo.IOHistory.Lines.add
                (IntToStr (I) + ' not consistent with exit medium');
	    CommandIOMemo.IOHistory.Lines.add
                ('refractive index for previous surface.');
            Q980_REQUEST_MORE_OUTPUT
	  END;
      I := I + 1
    END
  
END;




(**  W90_INITIALIZE_OPTIMIZATION  *********************************************
******************************************************************************)


BEGIN

  AKZ_ARCHIVE_FILE_NAME := 'ANNEAL.DATA';
  AED_TRANSFER_SURFACE_DATA := TRUE;
  AEE_TRANSFER_RAY_DATA := FALSE;
  AEF_TRANSFER_OPTION_DATA := FALSE;
  AEG_TRANSFER_ENVIRONMENT_DATA := FALSE;
  AKA_PUT_DATA_IN_TEMPORARY_STORAGE := FALSE;
  AKB_GET_DATA_FROM_TEMPORARY_STORAGE := FALSE;
  AKC_PUT_DATA_IN_PERMANENT_STORAGE := FALSE;
  AKD_GET_DATA_FROM_PERMANENT_STORAGE := FALSE;
  
  ZLA_OPTIMIZATION_DATA.ZLX_BEST_COMPUTED_MERIT_FUNC_VALUE := 1.0E19;
  ZLA_OPTIMIZATION_DATA.ZLY_OLD_MERIT_VALUE := 1.0E19;
  
  W90AA_TEMP_STRING := ' ';
    
  OptimizeByRMSBlur := FALSE;
  OptimizeByFullBlur := FALSE;
  OptimizeByAngle := FALSE;
  
  W90AA_TEMP_STRING [1] := ZLA_OPTIMIZATION_DATA.ZLD_MERIT_FUNCTION_CODE [1];
  
  IF POS (W90AA_TEMP_STRING, CTAB_GET_RMS_BLUR_DIA_CODE) > 0 THEN
    OptimizeByRMSBlur := TRUE
  ELSE
  IF POS (W90AA_TEMP_STRING, CTAC_GET_FULL_BLUR_DIA_CODE) > 0 THEN
    OptimizeByFullBlur := TRUE;
  
  PositionBubbleSortReqd := FALSE;
  W90AE_POSITION_OPTIMIZATION_SPECD := FALSE;
  I := 1;
  
  REPEAT
    IF ZBA_SURFACE [I].ZBB_SPECIFIED
	AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
      IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.ZMG_OPTIMIZE_POSITION THEN
	IF W90AE_POSITION_OPTIMIZATION_SPECD THEN
	  PositionBubbleSortReqd := TRUE
	ELSE
	  BEGIN
	    W90AE_POSITION_OPTIMIZATION_SPECD := TRUE;
	    I := I + 1
	  END
      ELSE
	I := I + 1
    ELSE
      I := I + 1
  UNTIL PositionBubbleSortReqd
      OR (I > CZAB_MAX_NUMBER_OF_SURFACES);
      
  IF W90AE_POSITION_OPTIMIZATION_SPECD THEN
    W9005_VALIDATE_POSITION_OPTIM;
  
  FOR  I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    IF ZBA_SURFACE [I].ZBB_SPECIFIED
	AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
      IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.ZMC_OPTIMIZE_RADIUS THEN
	BEGIN
          (* The following two lines of code are temporary. Eventually, this
             code will be implemented so that the user can select a percentage
             bound. *)
          ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 := 0.98 *
		  ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV;
          ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 := 1.02 *
		  ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV;
	  IF (ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 < MIN_RADIUS)
	      OR (ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 > MAX_RADIUS)
	      OR (ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 < MIN_RADIUS)
	      OR (ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 > MAX_RADIUS) THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('OPTIMIZATION VALIDATION MESSAGE, surface ' + IntToStr (I) +
		  '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Resetting radius bound #1 to ' +
                  FloatToStr (MIN_RADIUS) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Resetting radius bound #2 to ' +
                  FloatToStr (MAX_RADIUS) + '.');
              Q980_REQUEST_MORE_OUTPUT;
	      ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 := MAX_RADIUS;
	      ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 := MIN_RADIUS;
	      IF ZBA_SURFACE [I].ZBZ_SURFACE_IS_FLAT THEN
		BEGIN
		(*CommandIOMemo.IOHistory.Lines.add
                     ('Permit orientation reversal.');*)
		  ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV := MAX_RADIUS;
		  ZBA_SURFACE [I].ZBZ_SURFACE_IS_FLAT := FALSE
		(*ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
		      ZME_PERMIT_SURF_PITCH_REVERSAL := TRUE*)
		END
	    END;
	  IF ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 =
	      ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 THEN
	    BEGIN
	      NoErrors := FALSE;
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('OPTIMIZATION VALIDATION ERROR, surface ' + IntToStr (I) +
		  '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Radius bounds must not be equal.');
              Q980_REQUEST_MORE_OUTPUT
	    END
	  ELSE
	    IF ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 >
		ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 THEN
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('OPTIMIZATION VALIDATION MESSAGE, surface ' +
                    IntToStr (I) + '.');
		CommandIOMemo.IOHistory.Lines.add
                    ('Re-ordering radius bounds.');
                Q980_REQUEST_MORE_OUTPUT;
		W90AD_TEMP_HOLD := ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2;
		ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 :=
		    ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1;
		ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 := W90AD_TEMP_HOLD
	      END;
	  IF NoErrors THEN
	    IF ZBA_SURFACE [I].ZBZ_SURFACE_IS_FLAT THEN
	    (*IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
		  ZME_PERMIT_SURF_PITCH_REVERSAL THEN
		BEGIN
		  ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV := MAX_RADIUS;
		  ZBA_SURFACE [I].ZBZ_SURFACE_IS_FLAT := FALSE
		END
	      ELSE*)
		BEGIN
		  NoErrors := FALSE;
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                      ('OPTIMIZATION VALIDATION ERROR, surface ' +
                      IntToStr (I) + '.');
		  CommandIOMemo.IOHistory.Lines.add
                      ('Flat surface not compatible with stated' +
		      ' radius bounds.');
		  CommandIOMemo.IOHistory.Lines.add
                      ('Initial value for radius must be within' +
		      ' stated bounds.');
                  Q980_REQUEST_MORE_OUTPUT
		END
	    ELSE
	      IF (ZBA_SURFACE [I].ZMS_RADIUS_BOUND_1 <=
		  ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV)
		  AND (ZBA_SURFACE [I].ZMT_RADIUS_BOUND_2 >=
		  ZBA_SURFACE [I].ZBG_RADIUS_OF_CURV) THEN
	      ELSE
		BEGIN
		  NoErrors := FALSE;
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
                      ('OPTIMIZATION VALIDATION ERROR, surface ' +
                      IntToStr (I) + '.');
		  CommandIOMemo.IOHistory.Lines.add
                      ('Initial radius of curvature not within');
		  CommandIOMemo.IOHistory.Lines.add
                      ('stated radius optimization bounds.');
                  Q980_REQUEST_MORE_OUTPUT
		END
	END;

  FOR  I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    IF ZBA_SURFACE [I].ZBB_SPECIFIED
	AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
      IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.
	  ZMK_OPTIMIZE_CONIC_CONSTANT THEN
	BEGIN
          (* The following two lines of code are temporary. Eventually, this
             code will be implemented so that the user can select a percentage
             bound. *)
          ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 := 0.98 *
		  ZBA_SURFACE [I].ZBL_CONIC_CONSTANT;
          ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 := 1.02 *
		  ZBA_SURFACE [I].ZBL_CONIC_CONSTANT;
	  IF (ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 <
	      MIN_CONIC_CONSTANT)
	      OR (ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 >
	      MAX_CONIC_CONSTANT)
	      OR (ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 <
	      MIN_CONIC_CONSTANT)
	      OR (ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 >
	      MAX_CONIC_CONSTANT) THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('OPTIMIZATION VALIDATION MESSAGE, surface ' +
                  IntToStr (I) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Resetting conic constant bound #1 to ' +
		  FloatToStr (MIN_CONIC_CONSTANT) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Resetting conic constant bound #2 to ' +
		  FloatToStr (MAX_CONIC_CONSTANT) + '.');
              Q980_REQUEST_MORE_OUTPUT;
	      ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 := MAX_CONIC_CONSTANT;
	      ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 := MIN_CONIC_CONSTANT
	    END;
	  IF ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 >
	      ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('OPTIMIZATION VALIDATION MESSAGE, surface ' +
                  IntToStr (I) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Re-ordering conic constant bounds.');
              Q980_REQUEST_MORE_OUTPUT;
	      W90AD_TEMP_HOLD := ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2;
	      ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 :=
		  ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1;
	      ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 := W90AD_TEMP_HOLD
	    END
	  ELSE
	  IF ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 =
	      ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 THEN
	    BEGIN
	      NoErrors := FALSE;
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
                  ('OPTIMIZATION VALIDATION ERROR, surface ' +
                  IntToStr (I) + '.');
	      CommandIOMemo.IOHistory.Lines.add
                  ('Conic constant bounds must not be equal.');
              Q980_REQUEST_MORE_OUTPUT
	    END;
	  IF NoErrors THEN
	    IF (ZBA_SURFACE [I].ZMW_CONIC_CONST_BOUND_1 <=
		ZBA_SURFACE [I].ZBL_CONIC_CONSTANT)
		AND (ZBA_SURFACE [I].ZMX_CONIC_CONST_BOUND_2 >=
		ZBA_SURFACE [I].ZBL_CONIC_CONSTANT) THEN
	    ELSE
	      BEGIN
		NoErrors := FALSE;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('OPTIMIZATION VALIDATION ERROR, surface ' +
                    IntToStr (I) + '.');
		CommandIOMemo.IOHistory.Lines.add
                    ('Initial conic constant not within stated');
		CommandIOMemo.IOHistory.Lines.add
                    ('conic constant optimization bounds.');
                Q980_REQUEST_MORE_OUTPUT
	      END
	END;
  
  I := 1;
  W90AF_OPTIMIZE_GLASS := FALSE;
  
  REPEAT
    IF ZBA_SURFACE [I].ZBB_SPECIFIED
	AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
      IF ZBA_SURFACE [I].ZMB_OPTIMIZATION_SWITCHES.ZMI_OPTIMIZE_GLASS THEN
	W90AF_OPTIMIZE_GLASS := TRUE
      ELSE
	I := I + 1
    ELSE
      I := I + 1
  UNTIL W90AF_OPTIMIZE_GLASS
      OR (I > CZAB_MAX_NUMBER_OF_SURFACES);
      
  IF W90AF_OPTIMIZE_GLASS THEN
    W9010_VALIDATE_GLASS_OPTIM

END;




(**  LADSOptimizeUnit  *******************************************************
*****************************************************************************)


BEGIN

END.

