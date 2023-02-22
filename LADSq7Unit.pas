UNIT LADSq7Unit;

INTERFACE

PROCEDURE Q192_REQUEST_DESTINATION_SURFACE
    (FirstSurface, LastSurface  : INTEGER;
     VAR DestinationSurface  : INTEGER;
     VAR Valid               : BOOLEAN);
PROCEDURE Q200_REQUEST_RAY_REVISION
    (RayOrdinal              : INTEGER);
PROCEDURE Q201_REQUEST_LIGHT_RAY_COORDINATES
    (RayOrdinal              : INTEGER;
     Command                 : STRING;
     VAR Valid               : BOOLEAN);
PROCEDURE Q208_REQUEST_RAY_WAVELENGTH
    (RayOrdinal              : INTEGER;
     VAR Valid               : BOOLEAN);
PROCEDURE Q209_REQUEST_INCIDENT_MEDIUM_INDEX
    (RayOrdinal              : INTEGER;
     VAR Valid               : BOOLEAN);
PROCEDURE Q290_REQUEST_RAY_ORDINAL
    (VAR RayOrdinal          : INTEGER;
     VAR Valid               : BOOLEAN);
PROCEDURE Q291_REQUEST_RAY_ORDINAL_RANGE
    (VAR FirstRay, LastRay   : INTEGER;
     VAR Valid               : BOOLEAN);
PROCEDURE Q292_REQUEST_DESTINATION_RAY
    (FirstRay, LastRay       : INTEGER;
     VAR DestinationRay      : INTEGER;
     VAR Valid               : BOOLEAN);
PROCEDURE Q300_REQUEST_BUNDLE_HEAD_DIAMETER
    (VAR RayOrdinal          : INTEGER);
PROCEDURE Q301_REQUEST_COMPUTED_RAY_COUNT
    (VAR RayOrdinal          : INTEGER;
     CommandString           : STRING);
PROCEDURE Q303_RequestSolidAngleInfo
    (VAR RayOrdinal          : INTEGER;
     CommandString           : STRING);
PROCEDURE Q304_GetAngularWidthOfSlice
    (VAR RayOrdinal          : INTEGER);
PROCEDURE Q310_REQUEST_GAUSSIAN_BUNDLE_PARAMS
    (VAR RayOrdinal          : INTEGER);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSData,
       LADSListUnit,
       LADSInitUnit,
       LADSGlassCompUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit,
       LADSUtilUnit;

  TYPE
      SolidAngleCommandTypes = (GetMaxZenDist,
                              GetMinZenDist,
                              GetAzAngCtr,
                              GetAzSemiLength);

  VAR
      SolidAngleCommand : SolidAngleCommandTypes;


(**  Q192_REQUEST_DESTINATION_SURFACE  ****************************************
******************************************************************************)


PROCEDURE Q192_REQUEST_DESTINATION_SURFACE;

  VAR
      CODE           : INTEGER;

      IntegerNumber  : LONGINT;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER SURFACE ORDINAL OF DESTINATION SURFACE';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
	      ('ENTER SURFACE ORDINAL OF DESTINATION SURFACE');
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
	HelpDestinationSurfaceOrdinal
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF ((IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
		AND (IntegerNumber > 0)
		AND ((IntegerNumber <= FirstSurface)
		    OR (IntegerNumber > LastSurface))) THEN
	      BEGIN
		DestinationSurface := IntegerNumber;
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




(**  Q200_REQUEST_RAY_REVISION	***********************************************
******************************************************************************)


PROCEDURE Q200_REQUEST_RAY_REVISION;

  VAR
      Valid          : BOOLEAN;

      LN             : INTEGER;
      J              : INTEGER;

      CommandString  : STRING;

      LINE           : LineArray;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER RAY REVISION CODE:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
          LN := 1;
          LINE [LN] := '';
          D12_DO_FULL_RAY_LIST (LN, LINE, RayOrdinal);
          FOR J := 1 TO LN DO
	    CommandIOMemo.IOHistory.Lines.add (LINE [J]);
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER RAY REVISION CODE:');
          CommandIOMemo.IOHistory.Lines.add ('  ' +
               CRAA_VALID_RAY_REV_COMMANDS);
          CommandIOMemo.IOHistory.Lines.add ('  ' +
               ValidRayRevCommands2);
          CommandIOMemo.IOHistory.Lines.add ('  ' +
               ValidRayRevCommands3)
	END;
      S01_PROCESS_REQUEST;
      IF (POS (S01AI_LENGTH_3_RESPONSE, CRAA_VALID_RAY_REV_COMMANDS) > 0)
          OR (POS (S01AK_LENGTH_6_RESPONSE, ValidRayRevCommands2) > 0)
          OR (POS (S01AK_LENGTH_6_RESPONSE, ValidRayRevCommands3) > 0) THEN
	BEGIN
	  IF S01AI_LENGTH_3_RESPONSE = CRAB_GET_RAY_TAIL_X_COORD THEN
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        S01AI_LENGTH_3_RESPONSE, Valid)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CRAC_GET_RAY_TAIL_Y_COORD THEN
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        S01AI_LENGTH_3_RESPONSE, Valid)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CRAD_GET_RAY_TAIL_Z_COORD THEN
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        S01AI_LENGTH_3_RESPONSE, Valid)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CRAE_GET_RAY_HEAD_X_COORD THEN
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        S01AI_LENGTH_3_RESPONSE, Valid)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CRAF_GET_RAY_HEAD_Y_COORD THEN
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        S01AI_LENGTH_3_RESPONSE, Valid)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CRAG_GET_RAY_HEAD_Z_COORD THEN
	    Q201_REQUEST_LIGHT_RAY_COORDINATES (RayOrdinal,
	        S01AI_LENGTH_3_RESPONSE, Valid)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CRAI_GET_RAY_WAVLNGTH_MICRONS THEN
	    Q208_REQUEST_RAY_WAVELENGTH (RayOrdinal, Valid)
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CRAJ_GET_INCIDENT_MED_INDEX THEN
	    Q209_REQUEST_INCIDENT_MEDIUM_INDEX (RayOrdinal, Valid)
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAD_GET_BHD_VALUE THEN
	    Q300_REQUEST_BUNDLE_HEAD_DIAMETER (RayOrdinal)
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GetMaxZenithDistance THEN
            BEGIN
              SolidAngleCommand := GetMaxZenDist;
              CommandString := 'ENTER MAXIMUM ZENITH DISTANCE (DEGREES)';
	      Q303_RequestSolidAngleInfo (RayOrdinal, CommandString)
            END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = GetMinZenithDistance THEN
            BEGIN
              SolidAngleCommand := GetMinZenDist;
              CommandString := 'ENTER MINIMUM ZENITH DISTANCE (DEGREES)';
	      Q303_RequestSolidAngleInfo (RayOrdinal, CommandString)
            END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = GetAzimuthAngularCenter THEN
            BEGIN
              SolidAngleCommand := GetAzAngCtr;
              CommandString := 'ENTER AZIMUTH ANGULAR CENTER VALUE (DEGREES)';
	      Q303_RequestSolidAngleInfo (RayOrdinal, CommandString)
            END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = GetAzimuthAngularSemiLength THEN
            BEGIN
              SolidAngleCommand := GetAzSemiLength;
              CommandString := 'ENTER AZIMUTH ANGULAR SEMI LENGTH (DEGREES)';
	      Q303_RequestSolidAngleInfo (RayOrdinal, CommandString)
            END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = GetAngularWidthOfSlice THEN
            Q304_GetAngularWidthOfSlice (RayOrdinal)
          ELSE
	  IF (POS (S01AK_LENGTH_6_RESPONSE, ValidRayRevCommands2) > 0)
              OR (POS (S01AK_LENGTH_6_RESPONSE,
              ValidRayRevCommands3) > 0) THEN
	    BEGIN
	      ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN         := FALSE;
	      ZNA_RAY [RayOrdinal].TraceLinearXFan                 := FALSE;
	      ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN          := FALSE;
	      ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN        := FALSE;
	      ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN                  := FALSE;
	      ZNA_RAY [RayOrdinal].TraceSquareGrid                 := FALSE;
	      ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE      := FALSE;
	      ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE      := FALSE;
	      ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS      := FALSE;
	      ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS           := FALSE;
	      ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS             := FALSE;
              ZNA_RAY [RayOrdinal].TraceOrangeSliceRays            := FALSE;
              ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS           := FALSE;
              ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle := 0;
	      IF S01AK_LENGTH_6_RESPONSE = CFAP_GENERATE_SYMMETRIC_FAN THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RAYS IN SYMMETRIC FAN';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = GenerateLinearXFan THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].TraceLinearXFan := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RAYS IN LINEAR X FAN';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFAV_GENERATE_LINEAR_Y_FAN THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RAYS IN LINEAR Y FAN';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFAQ_GENERATE_ASYMMETRIC_FAN THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RAYS IN ASYMMETRIC FAN';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFAE_GENERATE_3FAN THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RAYS IN TRI-LATERAL FAN';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = GenerateSquareGrid THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].TraceSquareGrid := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF SQUARE RINGS IN SQUARE GRID';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFAR_GENERATE_HEXAPOLAR_ARRAY THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RINGS IN HEXAPOLAR BUNDLE';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFAS_GENERATE_ISOMETRIC_ARRAY THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle := 420;
		  ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE := TRUE
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFBF_GENERATE_SOLID_ANGLE_ARRAY THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RANDOM RAYS IN SOLID ANGLE';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFAT_GENERATE_RANDOM_ARRAY THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RANDOM RAYS TO TRACE';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
		END
              ELSE
              IF S01AK_LENGTH_6_RESPONSE = GenerateOrangeSliceArray THEN
                BEGIN
		  ZNA_RAY [RayOrdinal].TraceOrangeSliceRays := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF ORANGE SLICE RAYS TO TRACE';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
                END
              ELSE
              IF S01AK_LENGTH_6_RESPONSE = GENERATE_LAMBERTIAN_ARRAY THEN
                BEGIN
		  ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF LAMBERTIAN RAYS TO TRACE';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString)
                END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = GENERATE_GAUSSIAN_ARRAY THEN
	        BEGIN
		  ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS := TRUE;
		  CommandString :=
		      'ENTER NUMBER OF RAYS IN GAUSSIAN BUNDLE';
		  Q301_REQUEST_COMPUTED_RAY_COUNT (RayOrdinal,
                      CommandString);
		  IF NOT S01AB_USER_IS_DONE THEN
		    BEGIN
		      Q310_REQUEST_GAUSSIAN_BUNDLE_PARAMS (RayOrdinal);
		      IF NOT S01AD_END_EXECUTION_DESIRED THEN
		        S01AB_USER_IS_DONE := FALSE
		    END
		END
	      ELSE
	      IF S01AK_LENGTH_6_RESPONSE = CFAU_DISABLE_COMPUTED_RAYS THEN
		BEGIN
		END;
	      IF S01AB_USER_IS_DONE THEN
		BEGIN
		  ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN := FALSE;
		  ZNA_RAY [RayOrdinal].TraceLinearXFan := FALSE;
		  ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN := FALSE;
		  ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN := FALSE;
		  ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN := FALSE;
		  ZNA_RAY [RayOrdinal].TraceSquareGrid := FALSE;
		  ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE := FALSE;
		  ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE := FALSE;
		  ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS := FALSE;
		  ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS := FALSE;
		  ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS := FALSE;
                  ZNA_RAY [RayOrdinal].TraceOrangeSliceRays := FALSE;
                  ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS := FALSE;
		  ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle := 0
		END
	    END;
	  IF NOT S01AD_END_EXECUTION_DESIRED THEN
	    S01AB_USER_IS_DONE := FALSE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpRayRevisionCommands
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  Q201_REQUEST_LIGHT_RAY_COORDINATES	 **************************************
******************************************************************************)


PROCEDURE Q201_REQUEST_LIGHT_RAY_COORDINATES;

  VAR
      CODE         : INTEGER;

      REAL_NUMBER  : DOUBLE;

      SaveCommand  : STRING;  (* Req'd because of compiler bug *)
      Temp         : STRING;

BEGIN

  Valid := FALSE;
  SaveCommand := Command;

  REPEAT
    BEGIN
      IF SaveCommand = CRAB_GET_RAY_TAIL_X_COORD THEN
        Temp := 'ENTER X COORDINATE OF TAIL OF LIGHT RAY'
      ELSE
      IF SaveCommand = CRAC_GET_RAY_TAIL_Y_COORD THEN
        Temp := 'ENTER Y COORDINATE OF TAIL OF LIGHT RAY'
      ELSE
      IF SaveCommand = CRAD_GET_RAY_TAIL_Z_COORD THEN
        Temp := 'ENTER Z COORDINATE OF TAIL OF LIGHT RAY'
      ELSE
      IF SaveCommand = CRAE_GET_RAY_HEAD_X_COORD THEN
        Temp := 'ENTER X COORDINATE OF HEAD OF LIGHT RAY'
      ELSE	  
      IF SaveCommand = CRAF_GET_RAY_HEAD_Y_COORD THEN
        Temp := 'ENTER Y COORDINATE OF HEAD OF LIGHT RAY'	  
      ELSE	  
      IF SaveCommand = CRAG_GET_RAY_HEAD_Z_COORD THEN	  
        Temp := 'ENTER Z COORDINATE OF HEAD OF LIGHT RAY';
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
	HelpRayCoordinates
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    BEGIN
	      Valid := TRUE;
	      IF SaveCommand = CRAB_GET_RAY_TAIL_X_COORD THEN
		ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE := REAL_NUMBER
	      ELSE
	      IF SaveCommand = CRAC_GET_RAY_TAIL_Y_COORD THEN
		ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE := REAL_NUMBER
	      ELSE
	      IF SaveCommand = CRAD_GET_RAY_TAIL_Z_COORD THEN
		ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE := REAL_NUMBER
	      ELSE
	      IF SaveCommand = CRAE_GET_RAY_HEAD_X_COORD THEN
		ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE := REAL_NUMBER
	      ELSE
	      IF SaveCommand = CRAF_GET_RAY_HEAD_Y_COORD THEN
		ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE := REAL_NUMBER
	      ELSE
	      IF SaveCommand = CRAG_GET_RAY_HEAD_Z_COORD THEN
		ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE := REAL_NUMBER
	    END
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q208_REQUEST_RAY_WAVELENGTH  *********************************************
******************************************************************************)


PROCEDURE Q208_REQUEST_RAY_WAVELENGTH;

  VAR
      CODE         : INTEGER;
      
      REAL_NUMBER  : DOUBLE;

BEGIN

  Valid := FALSE;
  
  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER RAY WAVELENGTH (MICRONS)';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER RAY WAVELENGTH (MICRONS)');
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
	HelpRayWavelength
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    BEGIN
	      Valid := TRUE;
	      ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH := REAL_NUMBER
	    END
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q209_REQUEST_INCIDENT_MEDIUM_INDEX	 **************************************
******************************************************************************)


PROCEDURE Q209_REQUEST_INCIDENT_MEDIUM_INDEX;

  VAR
      CODE         : INTEGER;

      REAL_NUMBER  : DOUBLE;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER REFRACTIVE INDEX OF INCIDENT MEDIUM';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER REFRACTIVE INDEX OF INCIDENT MEDIUM');
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
	HelpIncidentMediumIndex
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    IF REAL_NUMBER >= 1.0 THEN
	      BEGIN
		Valid := TRUE;
		ZNA_RAY [RayOrdinal].ZNK_INCIDENT_MEDIUM_INDEX := REAL_NUMBER
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	(*ELSE
	    IF LENGTH (S01AF_BLANKS_STRIPPED_RESPONSE_UC) <=
		CZAH_MAX_CHARS_IN_GLASS_NAME THEN
	      BEGIN
		AAO_RESPONSE_IS_VALID := TRUE;
		ZBA_SURFACE [ABG_SURFACE_ORDINAL].
		    ZCG_INDEX_OR_GLASS [Q102AA_MEDIUM].ZCH_GLASS_NAME :=
		    S01AF_BLANKS_STRIPPED_RESPONSE_UC;
		ZBA_SURFACE [ABG_SURFACE_ORDINAL].
		    ZCF_GLASS_NAME_SPECIFIED [Q102AA_MEDIUM] := TRUE;
		ZBA_SURFACE [ABG_SURFACE_ORDINAL].ZBD_REFLECTIVE :=
		    FALSE;
		AKJ_SPECIFIED_GLASS_NAME :=
		    S01AF_BLANKS_STRIPPED_RESPONSE_UC;
		AKE_ADD_GLASS_TO_MINI_CATALOG := TRUE;
		U010_SEARCH_GLASS_CATALOG
		   (AKE_ADD_GLASS_TO_MINI_CATALOG,
		    AKF_GLASS_RECORD_FOUND,
		    ABE_GLASS_IN_MINI_CATALOG,
		    ABC_GLASS_MINI_CAT_PTR);
		IF NOT AKF_GLASS_RECORD_FOUND THEN
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		('ATTENTION: Specified glass name "',
			AKJ_SPECIFIED_GLASS_NAME,
			'" not found in glass catalog.')
		  END
	      END*)
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q290_REQUEST_RAY_ORDINAL  ************************************************
******************************************************************************)


PROCEDURE Q290_REQUEST_RAY_ORDINAL;

  VAR
      CODE           : INTEGER;

      IntegerNumber  : LONGINT;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER RAY ORDINAL';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER RAY ORDINAL');
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
	HelpRayOrdinal
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF ((IntegerNumber < (CZAC_MAX_NUMBER_OF_RAYS + 1))
		AND (IntegerNumber > 0)) THEN
	      BEGIN
		RayOrdinal := IntegerNumber;
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




(**  Q291_REQUEST_RAY_ORDINAL_RANGE  ******************************************
******************************************************************************)


PROCEDURE Q291_REQUEST_RAY_ORDINAL_RANGE;

  VAR
      Q291AA_FIRST_RAY_SPECIFIED  : BOOLEAN;

      Q291AB_FIRST_RAY		  : INTEGER;
      CODE                        : INTEGER;

      IntegerNumber               : LONGINT;

      Temp                        : STRING;

BEGIN

  Valid := FALSE;
  Q291AA_FIRST_RAY_SPECIFIED := FALSE;

  REPEAT
    BEGIN
      IF Q291AA_FIRST_RAY_SPECIFIED THEN
        Temp := 'ENTER LAST RAY IN RANGE, OR "*"'
      ELSE
        Temp := 'ENTER FIRST RAY IN RANGE';
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
	HelpRayOrdinalRange
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF Q291AA_FIRST_RAY_SPECIFIED THEN
	      IF ((IntegerNumber < (CZAC_MAX_NUMBER_OF_RAYS + 1))
		  AND (IntegerNumber > 0)
		  AND (IntegerNumber >= Q291AB_FIRST_RAY)) THEN
		BEGIN
		  FirstRay := Q291AB_FIRST_RAY;
		  LastRay := IntegerNumber;
		  Valid := TRUE
		END
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	    ELSE
	      IF ((IntegerNumber < (CZAC_MAX_NUMBER_OF_RAYS + 1))
		  AND (IntegerNumber > 0)) THEN
		BEGIN
		  Q291AB_FIRST_RAY := IntegerNumber;
		  Q291AA_FIRST_RAY_SPECIFIED := TRUE
		END
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = '* ' THEN
	    IF Q291AA_FIRST_RAY_SPECIFIED THEN
	      BEGIN
		FirstRay := Q291AB_FIRST_RAY;
		LastRay := CZAC_MAX_NUMBER_OF_RAYS;
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




(**  Q292_REQUEST_DESTINATION_RAY  ********************************************
******************************************************************************)


PROCEDURE Q292_REQUEST_DESTINATION_RAY;

  VAR
      CODE           : INTEGER;
      
      IntegerNumber  : LONGINT;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER RAY ORDINAL OF DESTINATION RAY';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER RAY ORDINAL OF DESTINATION RAY');
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
	HelpDestinationRayOrdinal
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF ((IntegerNumber < (CZAC_MAX_NUMBER_OF_RAYS + 1))
		AND (IntegerNumber > 0)
		AND ((IntegerNumber < FirstRay)
		    OR (IntegerNumber > LastRay))) THEN
	      BEGIN
		DestinationRay := IntegerNumber;
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




(**  Q300_REQUEST_BUNDLE_HEAD_DIAMETER  ***************************************
******************************************************************************)


PROCEDURE Q300_REQUEST_BUNDLE_HEAD_DIAMETER;

  VAR
      Valid       : BOOLEAN;

      CODE        : INTEGER;

      RealNumber  : DOUBLE;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'ENTER DIAMETER OF HEAD OF LIGHT RAY BUNDLE OR FAN';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
	      ('ENTER DIAMETER OF HEAD OF LIGHT RAY BUNDLE OR FAN');
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
	HelpRayBundleHeadDiameter
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, CODE);
	  IF CODE = 0 THEN
	    IF RealNumber > 0 THEN
	      BEGIN
		Valid := TRUE;
		ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER := RealNumber
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




(**  Q301_REQUEST_COMPUTED_RAY_COUNT  *****************************************
******************************************************************************)


PROCEDURE Q301_REQUEST_COMPUTED_RAY_COUNT;

  VAR
      Valid          : BOOLEAN;

      I	             : INTEGER;
      CODE           : INTEGER;

      IntegerNumber  : LONGINT;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := CommandString;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		(CommandString);
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
	HelpComputedRayCount
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE THEN
              BEGIN
	        IF (IntegerNumber > 0)
		    AND (IntegerNumber <= MaxNumberOfRings) THEN
		  BEGIN
		    Valid := TRUE;
		    ZNA_RAY [RayOrdinal].NumberOfRings := IntegerNumber;
                    ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle := 0;
		    FOR I := 1 TO ZNA_RAY [RayOrdinal].NumberOfRings DO
                      ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle :=
                          ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle +
                          I * 6;
	            CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
                    (IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) +
		        ' computed rays in hexapolar bundle.')
		  END
	        ELSE
		  Q990_INPUT_ERROR_PROCESSING
              END
            ELSE
            IF ZNA_RAY [RayOrdinal].TraceSquareGrid THEN
              BEGIN
	        IF (IntegerNumber > 0)
		    AND (IntegerNumber <= MaxNumberOfRings) THEN
		  BEGIN
		    Valid := TRUE;
		    ZNA_RAY [RayOrdinal].NumberOfRings := IntegerNumber;
                    ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle := 0;
		    FOR I := 1 TO ZNA_RAY [RayOrdinal].NumberOfRings DO
                      ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle :=
                          ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle +
                          I * 8;
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
                    (IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle) +
		        ' computed rays in square grid.')
		  END
	        ELSE
		  Q990_INPUT_ERROR_PROCESSING
              END
	    ELSE
	    IF (IntegerNumber > 0)
		AND (IntegerNumber < CZAD_MAX_COMPUTED_RAYS) THEN
	      BEGIN
		Valid := TRUE;
                ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle :=
             	    IntegerNumber
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




(**  Q303_RequestSolidAngleInfo  **********************************************
******************************************************************************)


PROCEDURE Q303_RequestSolidAngleInfo;

  VAR
      Valid       : BOOLEAN;

      CODE        : INTEGER;

      RealNumber  : DOUBLE;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := CommandString;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		(CommandString);
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
	BEGIN
          IF SolidAngleCommand = GetMaxZenDist THEN
            HelpRayConeHalfAngle
          ELSE
          IF SolidAngleCommand = GetMinZenDist THEN
            HelpMinimumZenithDistance
          ELSE
          IF SolidAngleCommand = GetAzAngCtr THEN
            HelpAzimuthAngularCenter
          ELSE
          IF SolidAngleCommand = GetAzSemiLength THEN
            HelpAzimuthSemiLength
        END
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, CODE);
	  IF CODE = 0 THEN
            BEGIN
              IF (SolidAngleCommand = GetMaxZenDist)
                  AND (RealNumber >= 0)
                  AND (RealNumber <= 180.0) THEN
                BEGIN
                  Valid := TRUE;
                  ZNA_RAY [RayOrdinal].MaxZenithDistance := RealNumber
                END
              ELSE
              IF (SolidAngleCommand = GetMinZenDist)
                  AND (RealNumber >= 0)
                  AND (RealNumber <= 180.0) THEN
                BEGIN
                  Valid := TRUE;
                  ZNA_RAY [RayOrdinal].MinZenithDistance := RealNumber
                END
              ELSE
              IF (SolidAngleCommand = GetAzAngCtr)
                  AND (RealNumber >= 0)
                  AND (RealNumber < 360.0) THEN
                BEGIN
                  Valid := TRUE;
                  ZNA_RAY [RayOrdinal].AzimuthAngularCenter := RealNumber
                END
              ELSE
              IF (SolidAngleCommand = GetAzSemiLength)
                  AND (RealNumber >= 0)
                  AND (RealNumber < 360.0) THEN
                BEGIN
                  Valid := TRUE;
                  ZNA_RAY [RayOrdinal].AzimuthAngularSemiLength := RealNumber
                END;
              IF Valid = FALSE THEN
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




(**  Q304_GetAngularWidthOfSlice  *********************************************
******************************************************************************)


PROCEDURE Q304_GetAngularWidthOfSlice;

  VAR
      Valid       : BOOLEAN;

      CODE        : INTEGER;

      RealNumber  : DOUBLE;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER ANGULAR SEMI-WIDTH OF ORANGE SLICE';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER ANGULAR SEMI-WIDTH OF ORANGE SLICE');
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
	HelpOrangeSliceAngularWidth
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, CODE);
	  IF CODE = 0 THEN
	    IF (RealNumber >= 0.0)
		AND (RealNumber < 90.0) THEN
	      BEGIN
		Valid := TRUE;
		ZNA_RAY [RayOrdinal].OrangeSliceAngularHalfWidth :=
                    RealNumber
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




(**  Q310_REQUEST_GAUSSIAN_BUNDLE_PARAMS  *************************************
******************************************************************************)

PROCEDURE Q310_REQUEST_GAUSSIAN_BUNDLE_PARAMS;

  VAR
      Valid       : BOOLEAN;

      Command     : STRING;
      TEMP_STRING : STRING;

      RealNumber  : DOUBLE;


(**  Q31005_REQUEST_GAUSSIAN_DIMENSIONS  **************************************
******************************************************************************)

PROCEDURE Q31005_REQUEST_GAUSSIAN_DIMENSIONS;

  VAR
      CODE        : INTEGER;

BEGIN

  Valid	 := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := Command;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add (Command);
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
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('No help available.')
	END
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, CODE);
	  IF CODE = 0 THEN
	    IF (RealNumber >= 0) THEN
              Valid := TRUE
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



(**  Q310_REQUEST_GAUSSIAN_BUNDLE_PARAMS  ************************************
*****************************************************************************)


BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER GAUSSIAN BUNDLE COMMAND:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER GAUSSIAN BUNDLE COMMAND:');
          CommandIOMemo.IOHistory.Lines.add
              ('  (HXG, HXU, HYG, HYU, TXG, TXU, TYG, TYU, HX, HY, TX, TY)');
          CommandIOMemo.IOHistory.Lines.add ('    Current values:');
	  IF ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN THEN
	    CommandIOMemo.IOHistory.Lines.add
                ('      Head x dimension (Gaussian FWHM)  = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_HEAD * 2.355))
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
                ('      Head x dimension (uniform intens) = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_HEAD * 2.0));
	  IF ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN THEN
	    CommandIOMemo.IOHistory.Lines.add
                ('      Head y dimension (Gaussian FWHM)  = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD * 2.355))
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
                ('      Head y dimension (uniform intens) = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD * 2.0));
	  IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN THEN
	    CommandIOMemo.IOHistory.Lines.add
                ('      Tail x dimension (Gaussian FWHM)  = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL * 2.355))
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
                ('      Tail x dimension (uniform intens) = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL * 2.0));
	  IF ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN THEN
	    CommandIOMemo.IOHistory.Lines.add
                ('      Tail y dimension (Gaussian FWHM)  = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL * 2.355))
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
                ('      Tail y dimension (uniform intens) = ' +
                FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL * 2.0));
          CommandIOMemo.IOHistory.Lines.add
              ('      Astigmatism                       = ' +
              FloatToStr (ZNA_RAY [RayOrdinal].Astigmatism));
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AK_LENGTH_6_RESPONSE, VALID_GAUSSIAN_COMMANDS) > 0 THEN
	BEGIN
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_HEAD_X_GAUSSIAN THEN
	    ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN := TRUE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_HEAD_X_UNIFORM THEN
	    ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_HEAD_Y_GAUSSIAN THEN
	    ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN := TRUE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_HEAD_Y_UNIFORM THEN
	    ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_TAIL_X_GAUSSIAN THEN
	    ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN := TRUE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_TAIL_X_UNIFORM THEN
	    ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_TAIL_Y_GAUSSIAN THEN
	    ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN := TRUE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = ENABLE_TAIL_Y_UNIFORM THEN
	    ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GET_HEAD_X_DIMENSION THEN
	    BEGIN
	      Command := 'ENTER GAUSSIAN BUNDLE HEAD X DIMENSION';
	      Q31005_REQUEST_GAUSSIAN_DIMENSIONS;
	      IF Valid THEN
	        IF ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN THEN
	          ZNA_RAY [RayOrdinal].SIGMA_X_HEAD := RealNumber / 2.355
		ELSE
		  ZNA_RAY [RayOrdinal].SIGMA_X_HEAD := RealNumber / 2.0
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GET_HEAD_Y_DIMENSION THEN
	    BEGIN
	      Command := 'ENTER GAUSSIAN BUNDLE HEAD Y DIMENSION';
	      Q31005_REQUEST_GAUSSIAN_DIMENSIONS;
	      IF Valid THEN
	        IF ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN THEN
	          ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD := RealNumber / 2.355
		ELSE
		  ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD := RealNumber / 2.0
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GET_TAIL_X_DIMENSION THEN
	    BEGIN
	      Command := 'ENTER GAUSSIAN BUNDLE TAIL X DIMENSION';
	      Q31005_REQUEST_GAUSSIAN_DIMENSIONS;
	      IF Valid THEN
	        IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN THEN
  	          ZNA_RAY [RayOrdinal].SIGMA_X_TAIL := RealNumber / 2.355
		ELSE
  	          ZNA_RAY [RayOrdinal].SIGMA_X_TAIL := RealNumber / 2.0
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GET_TAIL_Y_DIMENSION THEN
	    BEGIN
	      Command := 'ENTER GAUSSIAN BUNDLE TAIL Y DIMENSION';
	      Q31005_REQUEST_GAUSSIAN_DIMENSIONS;
	      IF Valid THEN
	        IF ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN THEN
	          ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL := RealNumber / 2.355
		ELSE
	          ZNA_RAY [RayOrdinal].SIGMA_Y_TAIL := RealNumber / 2.0
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GET_ASTIGMATISM THEN
	    BEGIN
	      Command := 'ENTER ASTIGMATISM';
	      Q31005_REQUEST_GAUSSIAN_DIMENSIONS;
	      IF Valid THEN
                ZNA_RAY [RayOrdinal].Astigmatism := RealNumber
	    END;
	  IF S01AB_USER_IS_DONE THEN
	    IF NOT S01AD_END_EXECUTION_DESIRED THEN
	      S01AB_USER_IS_DONE := FALSE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpGaussianRayBundleCommands
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  LADSq7Unit  ***********************************************************
****************************************************************************)

BEGIN

END.
