UNIT LADSGlassUnit;

INTERFACE

PROCEDURE I01_SET_UP_GLASS_CATALOG;

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSInitUnit,
       LADSGlassVar,
       LADSq5aUnit,
       LADSq6Unit,
       LADSq9Unit,
       LADSCommandIOMemoUnit,
       LADSGlassCompUnit,
       LADSUtilUnit;
       
       
(**  I01_SET_UP_GLASS_CATALOG  ************************************************
******************************************************************************)


PROCEDURE I01_SET_UP_GLASS_CATALOG;

  VAR
      HoldGlassName  : GlassType;

(**  I07_LIST_GLASS_DATA  *****************************************************
******************************************************************************)


PROCEDURE I07_LIST_GLASS_DATA;

  VAR
      I			   : INTEGER;
      I07AA_DISPLAY_COUNT  : INTEGER;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');

  CommandIOMemo.IOHistory.Lines.add
      ('Glass ..................................... : ' +
      ZKZ_GLASS_DATA_IO_AREA.GlassNameMixedCase);
  
  CommandIOMemo.IOHistory.Lines.add
      ('Manufacturer .............................. : ' +
      ZKZ_GLASS_DATA_IO_AREA.ZJD_MANUFACTURER_CODE);
  
  IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = Schott THEN
    CommandIOMemo.IOHistory.Lines.add
        ('Material type ............................. : S')
  ELSE
  IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = Hoya THEN
    CommandIOMemo.IOHistory.Lines.add
        ('Material type ............................. : G')
  ELSE
  IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = Crystal THEN
    CommandIOMemo.IOHistory.Lines.add
        ('Material type ............................. : C')
  ELSE
  IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = GRINGLC THEN
    CommandIOMemo.IOHistory.Lines.add
        ('Material type ............................. : GLC')
  ELSE
    CommandIOMemo.IOHistory.Lines.add
        ('Material type ............................. : Unknown');

  CommandIOMemo.IOHistory.Lines.add
      ('Glass preference code ..................... : ' +
      ZKZ_GLASS_DATA_IO_AREA.ZJF_PREFERENCE_CODE);
  
  CommandIOMemo.IOHistory.Lines.add
      ('Ordinary or extraordinary index type ...... : ' +
      ZKZ_GLASS_DATA_IO_AREA.ZJG_INDEX_TYPE);
  
  CommandIOMemo.IOHistory.Lines.add
      ('Shortwave cutoff for dispersion formula ... : ' +
      FloatToStr (ZKZ_GLASS_DATA_IO_AREA.ZJH_SHORT_WAVE_CUTOFF) + ' microns');
  
  CommandIOMemo.IOHistory.Lines.add
      ('Longwave cutoff for dispersion formula .... : ' +
      FloatToStr (ZKZ_GLASS_DATA_IO_AREA.ZJI_LONG_WAVE_CUTOFF) + ' microns');
  
  CommandIOMemo.IOHistory.Lines.add
      ('Dispersion constant 1 ..................... : ' +
      FloatToStr (ZKZ_GLASS_DATA_IO_AREA.ZJJ_DISPERSION_CONSTANT [1]));
  IF (ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = Schott)
      OR (ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = Hoya) THEN
    FOR I := 2 TO 6 DO
      CommandIOMemo.IOHistory.Lines.add ('                    ' +
	  IntToStr (I) + ' ..................... : ' +
	  FloatToStr (ZKZ_GLASS_DATA_IO_AREA.
	  ZJJ_DISPERSION_CONSTANT [AKS_DISPERSION_INDEX]))
  ELSE
  IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = Crystal THEN
    FOR I := 2 TO 10 DO
      CommandIOMemo.IOHistory.Lines.add ('                    ' +
	  IntToStr (I) + ' ..................... : ' +
	  FloatToStr (ZKZ_GLASS_DATA_IO_AREA.
	  ZJJ_DISPERSION_CONSTANT [AKS_DISPERSION_INDEX]))
  ELSE
  IF ZKZ_GLASS_DATA_IO_AREA.ZJB_DISPERSION_FORMULA = GRINGLC THEN
    FOR I := 2 TO 12 DO
      CommandIOMemo.IOHistory.Lines.add ('                    ' +
	  IntToStr (I) + ' ..................... : ' +
	  FloatToStr (ZKZ_GLASS_DATA_IO_AREA.
	  ZJJ_DISPERSION_CONSTANT [AKS_DISPERSION_INDEX]))
  ELSE
    FOR I := 2 TO CZBF_MAX_GLASS_DISPERSION_CONSTS DO
      CommandIOMemo.IOHistory.Lines.add ('                    ' +
	  IntToStr (I) + ' ..................... : ' +
	  FloatToStr (ZKZ_GLASS_DATA_IO_AREA.
	  ZJJ_DISPERSION_CONSTANT [AKS_DISPERSION_INDEX]));

  Q980_REQUEST_MORE_OUTPUT

END;




(**  I15_COMPUTE_REFRACTIVE_INDEX  ********************************************
******************************************************************************)


PROCEDURE I15_COMPUTE_REFRACTIVE_INDEX;

  VAR
      Valid                : BOOLEAN;
      ComputeGradientOnly  : BOOLEAN;

      RealNumber           : DOUBLE;
      
      CommandString        : STRING;

BEGIN

  CommandString := 'ENTER WAVELENGTH (IN MICRONS)';

  Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
  
  IF Valid THEN
    IF RealNumber > 0.0 THEN
      BEGIN
        AKO_SPECIFIED_WAVELENGTH := RealNumber;
        ComputeGradientOnly := FALSE;
	U050_CALCULATE_REFRACTIVE_INDEX
           (ComputeGradientOnly,
            BulkMatlPosition,
            AKO_SPECIFIED_WAVELENGTH,
            ZKZ_GLASS_DATA_IO_AREA,
            AKP_REFRACTIVE_INDEX_CALCULATED,
            AKQ_CALCULATED_REFRACTIVE_INDEX,
            RefIndexGradient);
        IF AKP_REFRACTIVE_INDEX_CALCULATED THEN
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add ('Refractive index for "' +
	        AKJ_SPECIFIED_GLASS_NAME + '" at wavelength ' +
	        FloatToStrF (AKO_SPECIFIED_WAVELENGTH, ffFixed, 9, 6) +
                ' microns is ' +
	        FloatToStrF (AKQ_CALCULATED_REFRACTIVE_INDEX, ffFixed, 9, 6))
	  END
      END

END;




(**  SetupGRINMaterialAliasInfo  **********************************************
******************************************************************************)

PROCEDURE SetupGRINMaterialAliasInfo;

  VAR
      AliasEntered   : BOOLEAN;
      OK             : BOOLEAN;
      Done           : BOOLEAN;

      I              : INTEGER;

(**  DisplayCurrentAliases  *************************************************
****************************************************************************)

PROCEDURE DisplayCurrentAliases;

BEGIN

  CommandIOMemo.IOHistory.Lines.add ('');
  CommandIOMemo.IOHistory.Lines.add ('Current bulk GRIN material aliases:');
  CommandIOMemo.IOHistory.Lines.add
      ('    ALIAS     GRIN MATL  X-COORD   Y-COORD   Z-COORD ' +
      '   YAW    PITCH   ROLL  ');
  CommandIOMemo.IOHistory.Lines.add
      ('--------------- ------- --------- --------- ---------' +
      ' ------- ------- -------');
  IF Length (GRINMaterial [1].GRINMatlAlias) = 0 THEN
    CommandIOMemo.IOHistory.Lines.add ('(NONE)')
  ELSE
    BEGIN
      I := 1;
      Done := FALSE;
      REPEAT
        CommandIOMemo.IOHistory.Lines.add
            (LeftJustifyBlankFill (GRINMaterial [I].
            GRINMatlAlias, 15) + ' ' +
            LeftJustifyBlankFill (GRINMaterial [I].
            GRINMatlName, 7) + ' ' +
            FloatToStrF
                (GRINMaterial [I].BulkMaterialPosition.Rx, ffFixed, 9, 3)
                + ' ' +
            FloatToStrF
                (GRINMaterial [I].BulkMaterialPosition.Ry, ffFixed, 9, 3)
                + ' ' +
            FloatToStrF
                (GRINMaterial [I].BulkMaterialPosition.Rz, ffFixed, 9, 3)
                + ' ' +
            FloatToStrF
                (GRINMaterial [I].BulkMaterialOrientation.Tx, ffFixed, 7, 3)
                + ' ' +
            FloatToStrF
                (GRINMaterial [I].BulkMaterialOrientation.Ty, ffFixed, 7, 3)
                + ' ' +
            FloatToStrF
                (GRINMaterial [I].BulkMaterialOrientation.Tz, ffFixed, 7, 3)
                + ' ');
        I := I + 1;
        IF I > MaxBulkGRINMaterials THEN
          Done := TRUE
        ELSE
        IF Length (GRINMaterial [I].GRINMatlAlias) = 0 THEN
          Done := TRUE
      UNTIL Done
    END;
END;




(**  RequestAlias  **********************************************************
****************************************************************************)

PROCEDURE RequestAlias;

BEGIN

  AliasEntered := FALSE;

  IF S01AA_EXPERT_MODE_OFF THEN
    DisplayCurrentAliases;

  Q112RequestGRINAlias;  (* Returns alias in AKJ_SPECIFIED_GLASS_NAME,
                            and verifies that the selected alias does
                            not match any existing glass in the glass
                            catalog. *)

  IF NOT S01AB_USER_IS_DONE THEN
    BEGIN
      I := 1;
      REPEAT
        IF Pos (AKJ_SPECIFIED_GLASS_NAME,
             GRINMaterial [I].GRINMatlAlias) > 0 THEN
          BEGIN
            GRINMaterialOrdinal := I;
            AliasEntered := TRUE
          END
        ELSE
        IF Length (GRINMaterial [I].GRINMatlAlias) = 0 THEN
          BEGIN
            GRINMaterial [I].GRINMatlAlias :=
                AKJ_SPECIFIED_GLASS_NAME;
            GRINMaterial [I].GRINMatlName :=
                HoldGlassName;
            GRINMaterialOrdinal := I;
            AliasEntered := TRUE
          END
        ELSE
          I := I + 1
      UNTIL AliasEntered
          OR (I > MaxBulkGRINMaterials);
      IF NOT AliasEntered THEN
        BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');;
          CommandIOMemo.IOHistory.Lines.add
              ('ERROR:  Maximum number of aliases have' +
              ' already been entered.');
          CommandIOMemo.IOHistory.Lines.add
              ('If possible, please re-use an existing alias.')
        END
    END

END;




(**  RequestBulkGRINDetails  ************************************************
****************************************************************************)

PROCEDURE RequestBulkGRINDetails;

BEGIN

  REPEAT
    BEGIN
      IF S01AA_EXPERT_MODE_OFF THEN
	BEGIN
          DisplayCurrentAliases;
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              ('ENTER COMMAND (X, Y, Z, YAW, PITCH, ROLL, ALIAS)');
          CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('>')
	END;
      S01_PROCESS_REQUEST;
      IF POS (S01AK_LENGTH_6_RESPONSE, GRINMaterialAliasCommands) > 0 THEN
	BEGIN
	  IF S01AK_LENGTH_6_RESPONSE = GetXPosition THEN
	    BEGIN
              Q960_REQUEST_REAL_NUMBER ('Enter global x coordinate' +
                  ' of bulk GRIN material', RealNumber, OK);
              IF OK THEN
                GRINMaterial [GRINMaterialOrdinal].
                    BulkMaterialPosition.Rx := RealNumber
            END
          ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GetYPosition THEN
	    BEGIN
              Q960_REQUEST_REAL_NUMBER ('Enter global y coordinate' +
                  ' of bulk GRIN material', RealNumber, OK);
              IF OK THEN
                GRINMaterial [GRINMaterialOrdinal].
                    BulkMaterialPosition.Ry := RealNumber
            END
          ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GetZPosition THEN
	    BEGIN
              Q960_REQUEST_REAL_NUMBER ('Enter global z coordinate' +
                  ' of bulk GRIN material', RealNumber, OK);
              IF OK THEN
                GRINMaterial [GRINMaterialOrdinal].
                    BulkMaterialPosition.Rz := RealNumber
            END
          ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GetYawOrientation THEN
	    BEGIN
              Q960_REQUEST_REAL_NUMBER ('Enter global yaw orientation' +
                  ' of bulk GRIN material', RealNumber, OK);
              IF OK THEN
                GRINMaterial [GRINMaterialOrdinal].
                    BulkMaterialOrientation.Tx := RealNumber
            END
          ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GetPitchOrientation THEN
	    BEGIN
              Q960_REQUEST_REAL_NUMBER ('Enter global pitch' +
                  ' orientation of bulk GRIN material', RealNumber, OK);
              IF OK THEN
                GRINMaterial [GRINMaterialOrdinal].
                    BulkMaterialOrientation.Ty := RealNumber
            END
          ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GetRollOrientation THEN
	    BEGIN
              Q960_REQUEST_REAL_NUMBER ('Enter global roll orientation' +
                  ' of bulk GRIN material', RealNumber, OK);
              IF OK THEN
                GRINMaterial [GRINMaterialOrdinal].
                    BulkMaterialOrientation.Tz := RealNumber
            END
          ELSE
	  IF S01AK_LENGTH_6_RESPONSE = GetAlias THEN
            RequestAlias
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add ('Valid commands are:');
	  CommandIOMemo.IOHistory.Lines.add
              ('  X, Y, Z ........... Position of bulk material in' +
              ' global coordinates.');
	  CommandIOMemo.IOHistory.Lines.add
              ('  Yaw, Pitch, Roll .. Orientation of bulk material' +
	      ' in global coordinates.');
	  CommandIOMemo.IOHistory.Lines.add
              ('  Alias ............. Name by which this GRIN' +
	      ' material may be');
	  CommandIOMemo.IOHistory.Lines.add
              ('                      referenced for ray tracing' +
	      ' purposes.  Alias may');
          CommandIOMemo.IOHistory.Lines.add
              ('                      contain up to ' +
              IntToStr (CZAH_MAX_CHARS_IN_GLASS_NAME) + ' characters.')
	END
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  SetupGRINMaterialAliasInfo  **********************************************
******************************************************************************)


BEGIN

  AliasEntered := FALSE;

  RequestAlias;

  IF AliasEntered THEN
    RequestBulkGRINDetails

END;




(**  I01_SET_UP_GLASS_CATALOG  ************************************************
******************************************************************************)


BEGIN

  Q080_REQUEST_GLASS_CATALOG_COMMAND;
  
  IF GlassCommandIsValid THEN
    BEGIN
      Q111_REQUEST_GLASS_NAME;
      IF AKF_GLASS_RECORD_FOUND THEN
	BEGIN
	  IF AKW_LIST_GLASS_DATA THEN
	    I07_LIST_GLASS_DATA
	  ELSE
	  IF AKX_COMPUTE_REFRACTIVE_INDEX THEN
	    I15_COMPUTE_REFRACTIVE_INDEX
	END
      ELSE
      IF NOT S01AB_USER_IS_DONE THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('Glass "' +
              AKJ_SPECIFIED_GLASS_NAME + '" not found in glass catalog.')
	END
    END

END;




(**  LADSGlassUnit  **********************************************************
*****************************************************************************)


BEGIN

END.

