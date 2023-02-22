UNIT LADSq6Unit;

INTERFACE

PROCEDURE Q103_REQUEST_SURFACE_DIAMETER
    (Q103AA_COMMAND : STRING;
     SurfaceOrdinal : INTEGER);
PROCEDURE Q104_REQUEST_CONIC_CONSTANT
    (CommandString  : STRING;
     VAR Valid      : BOOLEAN;
     VAR ConicConstant  : DOUBLE);
PROCEDURE Q106_REQUEST_SCATTERING_ANGLE
    (SurfaceOrdinal : INTEGER);
PROCEDURE Q107_REQUEST_SURFACE_REFLECTIVITY
    (SurfaceOrdinal : INTEGER);
PROCEDURE Q111_REQUEST_GLASS_NAME;
PROCEDURE Q112RequestGRINAlias;
PROCEDURE Q120_REQUEST_SURFACE_POSITION
    (Command        : STRING;
     SurfaceOrdinal : INTEGER);
PROCEDURE Q130_REQUEST_SURFACE_ORIENTATION
    (Command        : STRING;
     SurfaceOrdinal : INTEGER);
PROCEDURE Q140_REQUEST_SURFACE_ARRAY_DIMENSIONS
    (Command        : STRING;
     SurfaceOrdinal : INTEGER);
PROCEDURE q141_REQUEST_SURFACE_ARRAY_SPACING
    (Command        : STRING;
     SurfaceOrdinal : INTEGER);
PROCEDURE Q190_REQUEST_SURFACE_ORDINAL
    (VAR SurfaceOrdinal : INTEGER;
     VAR Valid          : BOOLEAN);
PROCEDURE Q191_REQUEST_SURF_ORDINAL_RANGE
    (VAR FirstSurface, LastSurface : INTEGER;
     VAR Valid : BOOLEAN);

IMPLEMENTATION

  USES EXPERTIO,
       LADSInitUnit,
       LADSData,
       LADSGlassVar,
       LADSGlassCompUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit,
       SysUtils;


(**  Q103_REQUEST_SURFACE_DIAMETER  *******************************************
******************************************************************************)


PROCEDURE Q103_REQUEST_SURFACE_DIAMETER;
    
  VAR
      Valid        : BOOLEAN;
      
      CODE         : INTEGER;
      
      REAL_NUMBER  : DOUBLE;

      TEMP_STRING  : STRING;
      Temp         : STRING;

BEGIN

  TEMP_STRING := Q103AA_COMMAND;

  Valid := FALSE;

  REPEAT
    BEGIN
      IF TEMP_STRING = CKAF_GET_OUTSIDE_DIA THEN	  
        Temp := 'ENTER DIAMETER OF OUTSIDE CIRCULAR PERIMETER'    
      ELSE	  
      IF TEMP_STRING = CKAG_GET_INSIDE_DIA THEN	  
        Temp := 'ENTER DIAMETER OF INSIDE CIRCULAR PERIMETER'	  
      ELSE	  
      IF TEMP_STRING = CKBF_GET_OUTSIDE_WIDTH_X THEN	  
        Temp := 'ENTER FULL WIDTH X DIMENSION OF OUTER PERIMETER'	  
      ELSE	  
      IF TEMP_STRING = CKBG_GET_OUTSIDE_WIDTH_Y THEN	  
        Temp := 'ENTER FULL WIDTH Y DIMENSION OF OUTER PERIMETER'	  
      ELSE	  
      IF TEMP_STRING = CKBH_GET_INSIDE_WIDTH_X THEN	  
        Temp := 'ENTER FULL WIDTH X DIMENSION OF INNER PERIMETER'	  
      ELSE	  
      IF TEMP_STRING = CKBI_GET_INSIDE_WIDTH_Y THEN	  
        Temp := 'ENTER FULL WIDTH Y DIMENSION OF INNER PERIMETER';
      CommandIOdlg.Caption := Temp;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add (Temp);
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpInsideAndOutsideApertures
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    IF (REAL_NUMBER >= 0) THEN
	      BEGIN
		Valid := TRUE;
                IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = CPC)
                    OR (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm =
                    HybridCPC) THEN
                  BEGIN
                    CommandIOMemo.IOHistory.Lines.add ('');
                    CommandIOMemo.IOHistory.Lines.add
                     ('Cancelling CPC status for surface ' +
                        IntToStr (SurfaceOrdinal) + '.');
                    ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := Conic
                  END;
		IF TEMP_STRING = CKAF_GET_OUTSIDE_DIA THEN
		  BEGIN
		    ZBA_SURFACE [SurfaceOrdinal].
			ZBJ_OUTSIDE_APERTURE_DIA := REAL_NUMBER;
		    IF REAL_NUMBER > 0.0 THEN
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZBH_OUTSIDE_DIMENS_SPECD := TRUE
		    ELSE
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZBH_OUTSIDE_DIMENS_SPECD := FALSE
		  END
		ELSE
		IF TEMP_STRING = CKAG_GET_INSIDE_DIA THEN
		  BEGIN
		    ZBA_SURFACE [SurfaceOrdinal].
			ZBK_INSIDE_APERTURE_DIA := REAL_NUMBER;
		    IF REAL_NUMBER > 0.0 THEN
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZCT_INSIDE_DIMENS_SPECD := TRUE
		    ELSE
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZCT_INSIDE_DIMENS_SPECD := FALSE
		  END
		ELSE
		IF TEMP_STRING = CKBF_GET_OUTSIDE_WIDTH_X THEN
		  BEGIN
		    ZBA_SURFACE [SurfaceOrdinal].
			ZCP_OUTSIDE_APERTURE_WIDTH_X := REAL_NUMBER;
		    IF (REAL_NUMBER > 0.0)
			AND (ZBA_SURFACE [SurfaceOrdinal].
			ZCQ_OUTSIDE_APERTURE_WIDTH_Y > 0.0) THEN
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZBH_OUTSIDE_DIMENS_SPECD := TRUE
		    ELSE
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZBH_OUTSIDE_DIMENS_SPECD := FALSE
		  END
		ELSE
		IF TEMP_STRING = CKBG_GET_OUTSIDE_WIDTH_Y THEN
		  BEGIN
		    ZBA_SURFACE [SurfaceOrdinal].
			ZCQ_OUTSIDE_APERTURE_WIDTH_Y := REAL_NUMBER;
		    IF (REAL_NUMBER > 0.0)
			AND (ZBA_SURFACE [SurfaceOrdinal].
			ZCP_OUTSIDE_APERTURE_WIDTH_X > 0.0) THEN
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZBH_OUTSIDE_DIMENS_SPECD := TRUE
		    ELSE
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZBH_OUTSIDE_DIMENS_SPECD := FALSE
		  END
		ELSE
		IF TEMP_STRING = CKBH_GET_INSIDE_WIDTH_X THEN
		  BEGIN
		    ZBA_SURFACE [SurfaceOrdinal].
			ZCR_INSIDE_APERTURE_WIDTH_X := REAL_NUMBER;
		    IF (REAL_NUMBER > 0.0)
			AND (ZBA_SURFACE [SurfaceOrdinal].
			ZCS_INSIDE_APERTURE_WIDTH_Y > 0.0) THEN
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZCT_INSIDE_DIMENS_SPECD := TRUE
		    ELSE
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZCT_INSIDE_DIMENS_SPECD := FALSE
		  END
		ELSE
		IF TEMP_STRING = CKBI_GET_INSIDE_WIDTH_Y THEN
		  BEGIN
		    ZBA_SURFACE [SurfaceOrdinal].
			ZCS_INSIDE_APERTURE_WIDTH_Y := REAL_NUMBER;
		    IF (REAL_NUMBER > 0.0)
			AND (ZBA_SURFACE [SurfaceOrdinal].
			ZCR_INSIDE_APERTURE_WIDTH_X > 0.0) THEN
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZCT_INSIDE_DIMENS_SPECD := TRUE
		    ELSE
		      ZBA_SURFACE [SurfaceOrdinal].
			  ZCT_INSIDE_DIMENS_SPECD := FALSE
		  END
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q104_REQUEST_CONIC_CONSTANT  *********************************************
******************************************************************************)


PROCEDURE Q104_REQUEST_CONIC_CONSTANT;

  VAR
      CODE        : INTEGER;

BEGIN

  Valid	 := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := CommandString;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add (CommandString);
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpConicConstant
      ELSE
	BEGIN
          VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, ConicConstant, CODE);
	  IF CODE = 0 THEN
            Valid := TRUE
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q106_REQUEST_SCATTERING_ANGLE  *******************************************
******************************************************************************)


PROCEDURE Q106_REQUEST_SCATTERING_ANGLE;

  VAR
      Valid        : BOOLEAN;

      CODE         : INTEGER;

      TEMP_REAL	   : DOUBLE;
      REAL_NUMBER  : DOUBLE;

BEGIN

  Valid	 := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER SCATTERING ANGLE (DEGREES)';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ENTER SCATTERING ANGLE (DEGREES)');
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpScatteringAngle
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    IF ((REAL_NUMBER >= 0.0)
                AND (REAL_NUMBER <= 89.9999999)) THEN
	      BEGIN
		Valid := TRUE;
                ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians :=
                    REAL_NUMBER / ALR_DEGREES_PER_RADIAN
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q107_REQUEST_SURFACE_REFLECTIVITY	***************************************
******************************************************************************)


PROCEDURE Q107_REQUEST_SURFACE_REFLECTIVITY;

  VAR
      Valid        : BOOLEAN;

      CODE         : INTEGER;

      REAL_NUMBER  : DOUBLE;

BEGIN

  Valid	 := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER SURFACE REFLECTIVITY';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER SURFACE REFLECTIVITY');
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpSurfaceReflectivity
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    IF (REAL_NUMBER >= CZBK_LOWEST_ACCEPTABLE_RAY_INTENSITY)
		AND (REAL_NUMBER <= 1.0) THEN
	      BEGIN
		Valid := TRUE;
		ZBA_SURFACE [SurfaceOrdinal].
		    ZCK_SURFACE_REFLECTIVITY := REAL_NUMBER
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(** Q111_REQUEST_GLASS_NAME  **************************************************
******************************************************************************)


PROCEDURE Q111_REQUEST_GLASS_NAME;

  VAR
      Valid     : BOOLEAN;

      HoldName  : GlassType;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER GLASS NAME';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER GLASS NAME');
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpGlassName
      ELSE
	BEGIN
	  IF (LENGTH (S01AF_BLANKS_STRIPPED_RESPONSE_UC) <=
	      CZAH_MAX_CHARS_IN_GLASS_NAME) THEN
	    BEGIN
	      AKJ_SPECIFIED_GLASS_NAME := S01AF_BLANKS_STRIPPED_RESPONSE_UC;
              HoldName := S01AM_BLANKS_STRIPPED_RESPONSE;
	      AKE_ADD_GLASS_TO_MINI_CATALOG := TRUE;
	      U010_SEARCH_GLASS_CATALOG
		 (AKE_ADD_GLASS_TO_MINI_CATALOG,
		  AKF_GLASS_RECORD_FOUND,
                  FoundGradientIndexMaterial,
		  ABE_GLASS_IN_MINI_CATALOG,
		  ABC_GLASS_MINI_CAT_PTR);
              IF AKF_GLASS_RECORD_FOUND THEN
	        Valid := TRUE
              ELSE
                BEGIN
	          CommandIOMemo.IOHistory.Lines.add ('');
                  CommandIOMemo.IOHistory.Lines.add ('ERROR:  Material ' +
                      HoldName + ' not found in glass catalog.')
                END
	    END
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;

      

  
(** Q112RequestGRINAlias  *****************************************************

  This procedure ensures that the alias does not match any existing glass
  name in the glass catalog.

******************************************************************************)


PROCEDURE Q112RequestGRINAlias;

  VAR
      Valid  : BOOLEAN;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER ALIAS FOR THIS GRIN MATERIAL';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ENTER ALIAS FOR THIS GRIN MATERIAL');
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpGRINAlias
      ELSE
	BEGIN
	  IF (LENGTH (S01AF_BLANKS_STRIPPED_RESPONSE_UC) <=
	      CZAH_MAX_CHARS_IN_GLASS_NAME) THEN
	    BEGIN
	      AKJ_SPECIFIED_GLASS_NAME := S01AF_BLANKS_STRIPPED_RESPONSE_UC;
	      AKE_ADD_GLASS_TO_MINI_CATALOG := FALSE;
	      U010_SEARCH_GLASS_CATALOG
		 (AKE_ADD_GLASS_TO_MINI_CATALOG,
		  AKF_GLASS_RECORD_FOUND,
                  FoundGradientIndexMaterial,
		  ABE_GLASS_IN_MINI_CATALOG,
		  ABC_GLASS_MINI_CAT_PTR);
	      IF AKF_GLASS_RECORD_FOUND THEN
                BEGIN
                  CommandIOMemo.IOHistory.Lines.add ('');
                  CommandIOMemo.IOHistory.Lines.add
                      ('ERROR:  The GRIN material alias you have' +
                      ' entered matches an');
                  CommandIOMemo.IOHistory.Lines.add
                      ('existing glass type in the glass catalog.' +
                      '  Please select a');
                  CommandIOMemo.IOHistory.Lines.add ('different alias.')
                END
              ELSE
                (* i.e., alias name not found in the glass catalog. *)
                Valid := TRUE
	    END
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q120_REQUEST_SURFACE_POSITION  *******************************************
******************************************************************************)


PROCEDURE Q120_REQUEST_SURFACE_POSITION;

  VAR
      Valid        : BOOLEAN;

      CODE         : INTEGER;

      REAL_NUMBER  : DOUBLE;

      Temp         : STRING;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      IF Command = CKAN_GET_SURF_X_POSITION THEN
        Temp := 'ENTER X-AXIS COORDINATE OF SURFACE VERTEX'
      ELSE
      IF Command = CKAP_GET_SURF_Y_POSITION THEN
        Temp := 'ENTER Y-AXIS COORDINATE OF SURFACE VERTEX'
      ELSE
      IF Command = CKAR_GET_SURF_Z_POSITION THEN
        Temp := 'ENTER Z-AXIS COORDINATE OF SURFACE VERTEX'
      ELSE
      IF Command = CKAO_GET_SURF_DELTA_X THEN
        Temp := 'ENTER DELTA X'
      ELSE
      IF Command = CKAQ_GET_SURF_DELTA_Y THEN
        Temp := 'ENTER DELTA Y'
      ELSE
      IF Command = CKAS_GET_SURF_DELTA_Z THEN
        Temp := 'ENTER DELTA Z';
      CommandIOdlg.Caption := Temp;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	      BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add (Temp);
	        CommandIOMemo.IOHistory.Lines.add ('')
	      END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	      BEGIN
	      END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	      HelpSurfacePosition
      ELSE
	      BEGIN
	        VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	        IF CODE = 0 THEN
	          BEGIN
	            Valid := TRUE;
	            IF Command = CKAN_GET_SURF_X_POSITION THEN
		            ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X := REAL_NUMBER
	            ELSE
	            IF Command = CKAP_GET_SURF_Y_POSITION THEN
		            ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y := REAL_NUMBER
	            ELSE
	            IF Command = CKAR_GET_SURF_Z_POSITION THEN
		            ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z := REAL_NUMBER
	            ELSE
              IF Command = CKAO_GET_SURF_DELTA_X THEN
	          	  ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X := REAL_NUMBER
	            ELSE
	            IF Command = CKAQ_GET_SURF_DELTA_Y THEN
		            ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y := REAL_NUMBER
	            ELSE
	            IF Command = CKAS_GET_SURF_DELTA_Z THEN
		            ZBA_SURFACE [SurfaceOrdinal].ZBR_VERTEX_DELTA_Z := REAL_NUMBER
	          END
	        ELSE
	          Q990_INPUT_ERROR_PROCESSING
	      END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q130_REQUEST_SURFACE_ORIENTATION  ****************************************
******************************************************************************)


PROCEDURE Q130_REQUEST_SURFACE_ORIENTATION;

  VAR
      Valid        : BOOLEAN;

      CODE         : INTEGER;

      REAL_NUMBER  : DOUBLE;

      Temp         : STRING;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      IF Command = CKAT_GET_SURF_ROLL THEN
        Temp := 'ENTER SURFACE ROLL ANGLE'
      ELSE
      IF Command = CKAV_GET_SURF_PITCH THEN
        Temp := 'ENTER SURFACE PITCH ANGLE'
      ELSE
      IF Command = CKAX_GET_SURF_YAW THEN
        Temp := 'ENTER SURFACE YAW ANGLE'
      ELSE
      IF Command = CKAU_GET_SURF_DELTA_ROLL THEN
        Temp := 'ENTER DELTA ROLL'
      ELSE
      IF Command = CKAW_GET_SURF_DELTA_PITCH THEN
        Temp := 'ENTER DELTA PITCH'
      ELSE
      IF Command = CKAY_GET_SURF_DELTA_YAW THEN
        Temp := 'ENTER DELTA YAW';
      CommandIOdlg.Caption := Temp;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	      BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
	        CommandIOMemo.IOHistory.Lines.add (Temp);
	        CommandIOMemo.IOHistory.Lines.add ('')
	      END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpSurfaceOrientation
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    BEGIN
	      Valid := TRUE;
	      IF Command = CKAT_GET_SURF_ROLL THEN
		ZBA_SURFACE [SurfaceOrdinal].ZBS_ROLL := REAL_NUMBER
	      ELSE
	      IF Command = CKAV_GET_SURF_PITCH THEN
		ZBA_SURFACE [SurfaceOrdinal].ZBU_PITCH := REAL_NUMBER
	      ELSE
	      IF Command = CKAX_GET_SURF_YAW THEN
		ZBA_SURFACE [SurfaceOrdinal].ZBW_YAW := REAL_NUMBER
	      ELSE
	      IF Command = CKAU_GET_SURF_DELTA_ROLL THEN
		ZBA_SURFACE [SurfaceOrdinal].ZBT_DELTA_ROLL := REAL_NUMBER
	      ELSE
	      IF Command = CKAW_GET_SURF_DELTA_PITCH THEN
		ZBA_SURFACE [SurfaceOrdinal].ZBV_DELTA_PITCH := REAL_NUMBER
	      ELSE
	      IF Command = CKAY_GET_SURF_DELTA_YAW THEN
		ZBA_SURFACE [SurfaceOrdinal].ZBX_DELTA_YAW := REAL_NUMBER
	    END
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q140_REQUEST_SURFACE_ARRAY_DIMENSIONS  ***********************************
******************************************************************************)

PROCEDURE Q140_REQUEST_SURFACE_ARRAY_DIMENSIONS;

  VAR
      Valid                                : BOOLEAN;

      CODE                                 : INTEGER;

      INTEGER_NUMBER                       : INTEGER;

      Temp                                 : STRING;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      IF Command = SurfaceArrayXRepeat THEN
        Temp := 'ENTER NUMBER OF SURFACE REPETITIONS IN X DIRECTION'
      ELSE
      IF Command = SurfaceArrayYRepeat THEN
        Temp := 'ENTER NUMBER OF SURFACE REPETITIONS IN Y DIRECTION';
      CommandIOdlg.Caption := Temp;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	      BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add (Temp);
	        CommandIOMemo.IOHistory.Lines.add ('')
	      END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
        CommandIOMemo.IOHistory.Lines.add (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	      BEGIN
	      END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	      HelpSurfaceArrayParameters
      ELSE
	      BEGIN
	        VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, INTEGER_NUMBER, CODE);
	        IF CODE = 0 THEN
            IF (INTEGER_NUMBER >= 1) THEN
              IF ((INTEGER_NUMBER MOD 2) <> 0) THEN (* i.e., is an odd number *)
                BEGIN
                  Valid := TRUE;
	                IF Command = SurfaceArrayXRepeat THEN
		                ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns :=
                        INTEGER_NUMBER
	                ELSE
                  IF Command = SurfaceArrayYRepeat THEN
		                ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows :=
                        INTEGER_NUMBER;
                  IF (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns = 1)
                      AND (ZBA_SURFACE [SurfaceOrdinal].
                      LensletArrayTotalRows = 1) THEN
                    BEGIN
                      IF S01AA_EXPERT_MODE_OFF
                          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	                      BEGIN
                          Temp := 'Cancelling lenslet array.';
                          CommandIOMemo.IOHistory.Lines.add ('');
	                        CommandIOMemo.IOHistory.Lines.add (Temp);
	                        CommandIOMemo.IOHistory.Lines.add ('')
	                      END;
                      ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE
                    END
                END
              ELSE
                BEGIN
                  IF S01AA_EXPERT_MODE_OFF
                      AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
                    BEGIN
                      Temp := 'ERROR: Number of columns in lenslet array' +
                          ' must be an odd integer (3, 5, 7, etc.).';
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add (Temp);
                      CommandIOMemo.IOHistory.Lines.add ('')
                    END;
                  Q990_INPUT_ERROR_PROCESSING
                END
            ELSE
              BEGIN
                IF S01AA_EXPERT_MODE_OFF
                    AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
                  BEGIN
                    Temp := 'ERROR: Number of columns in lenslet array' +
                        ' must be greater than or equal to one.';
                    CommandIOMemo.IOHistory.Lines.add ('');
                    CommandIOMemo.IOHistory.Lines.add (Temp);
                    CommandIOMemo.IOHistory.Lines.add ('')
                  END;
                Q990_INPUT_ERROR_PROCESSING
              END
          ELSE
            Q990_INPUT_ERROR_PROCESSING
	      END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q141_REQUEST_SURFACE_ARRAY_SPACING  **************************************
******************************************************************************)

PROCEDURE Q141_REQUEST_SURFACE_ARRAY_SPACING;

  VAR
      Valid                                : BOOLEAN;

      CODE                                 : INTEGER;

      REAL_NUMBER                          : DOUBLE;

      Temp                                 : STRING;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      IF Command = SurfaceArrayXSpacing THEN
        Temp := 'ENTER SURFACE ARRAY SPACING IN X DIRECTION'
      ELSE
      IF Command = SurfaceArrayYSpacing THEN
        Temp := 'ENTER SURFACE ARRAY SPACING IN Y DIRECTION';
      CommandIOdlg.Caption := Temp;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	      BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add (Temp);
	        CommandIOMemo.IOHistory.Lines.add ('')
	      END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
        CommandIOMemo.IOHistory.Lines.add (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	      BEGIN
	      END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	      HelpSurfaceArrayParameters
      ELSE
	      BEGIN
	        VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	        IF CODE = 0 THEN
            BEGIN
	            Valid := TRUE;
	            IF Command = SurfaceArrayXSpacing THEN
		            ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX :=
                    REAL_NUMBER
	            ELSE
              IF Command = SurfaceArrayYSpacing THEN
		            ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY :=
                    REAL_NUMBER
	          END
	        ELSE
	          Q990_INPUT_ERROR_PROCESSING
	      END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q190_REQUEST_SURFACE_ORDINAL  ********************************************
******************************************************************************)


PROCEDURE Q190_REQUEST_SURFACE_ORDINAL;

  VAR
      CODE           : INTEGER;
      
      IntegerNumber  : LONGINT;

BEGIN
  
  Valid	 := FALSE;
  
  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER SURFACE ORDINAL';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER SURFACE ORDINAL');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpSurfaceOrdinal
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
		AND (IntegerNumber > 0) THEN
	      BEGIN
		SurfaceOrdinal := IntegerNumber;
		Valid := TRUE
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q191_REQUEST_SURF_ORDINAL_RANGE  *****************************************
******************************************************************************)


PROCEDURE Q191_REQUEST_SURF_ORDINAL_RANGE;

  VAR
      Q191AA_FIRST_SURFACE_SPECIFIED  : BOOLEAN;

      Q191AB_FIRST_SURFACE	      : INTEGER;
      CODE                            : INTEGER;
      
      IntegerNumber                   : LONGINT;

      Temp                            : STRING;

BEGIN

  Valid := FALSE;

  Q191AA_FIRST_SURFACE_SPECIFIED := FALSE;

  REPEAT
    BEGIN
      IF Q191AA_FIRST_SURFACE_SPECIFIED THEN	  
        Temp := 'ENTER LAST SURFACE IN RANGE, OR "*"'	  
      ELSE	  
        Temp := 'ENTER FIRST SURFACE IN RANGE';
      CommandIOdlg.Caption := Temp;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add (Temp);
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpSurfaceOrdinalRange
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF Q191AA_FIRST_SURFACE_SPECIFIED THEN
	      IF ((IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
		  AND (IntegerNumber > 0)
		  AND (IntegerNumber >= Q191AB_FIRST_SURFACE)) THEN
		BEGIN
		  FirstSurface := Q191AB_FIRST_SURFACE;
		  LastSurface := IntegerNumber;
		  Valid := TRUE
		END
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	    ELSE
	      IF ((IntegerNumber < (CZAB_MAX_NUMBER_OF_SURFACES + 1))
		  AND (IntegerNumber > 0)) THEN
		BEGIN
		  Q191AB_FIRST_SURFACE := IntegerNumber;
		  Q191AA_FIRST_SURFACE_SPECIFIED := TRUE
		END
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = '* ' THEN
	    IF Q191AA_FIRST_SURFACE_SPECIFIED THEN
	      BEGIN
		FirstSurface := Q191AB_FIRST_SURFACE;
		LastSurface := CZAB_MAX_NUMBER_OF_SURFACES;
		Valid := TRUE
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  LADSq6Unit  *************************************************************
*****************************************************************************)


BEGIN

END.

