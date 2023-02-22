UNIT LADSq4Unit;

INTERFACE

PROCEDURE Q070_REQUEST_ENVIRONMENT;

IMPLEMENTATION

  USES SysUtils,
       LADSUtilUnit,
       EXPERTIO,
       LADSEnvironUnit,
       LADSData,
       LADSq6Unit,
       LADSq7Unit,
       LADSq9Unit,
       LADSInitUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;


(**  Q070_REQUEST_ENVIRONMENT  ************************************************
******************************************************************************)


PROCEDURE Q070_REQUEST_ENVIRONMENT;

  VAR
      Valid           : BOOLEAN;
      
      TEMP_STRING     : STRING;
      CommandString   : STRING;
      
      SurfaceOrdinal  : INTEGER;
      FirstSurface    : INTEGER;
      LastSurface     : INTEGER;
      FirstRay        : INTEGER;
      LastRay         : INTEGER;

      THICKNESS	      : DOUBLE;
      PIVOT_DISTANCE  : DOUBLE;
      X		      : DOUBLE;
      Y		      : DOUBLE;
      Z		      : DOUBLE;
      ROLL	      : DOUBLE;
      PITCH	      : DOUBLE;
      YAW	      : DOUBLE;
      RealNumber      : DOUBLE;

BEGIN

  Valid		                 := FALSE;

  AIN_TRANSLATE			 := FALSE;
  AIQ_ADJUST_THICKNESS		 := FALSE;
  AIP_PERFORM_SYSTEMIC_ROTATION	 := FALSE;
  AdjustScale                    := FALSE;
  ADW_CLEAR_ZERO		 := FALSE;
  ADZ_CLEAR_INCORPORATE		 := FALSE;
  AimPrincipalRays               := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER ENVIRONMENT COMMAND:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  IF ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS THEN
	    TEMP_STRING := 'YPR / EULER ........... EULER'
	  ELSE
	    TEMP_STRING := 'YPR / EULER ........... YPR  ';
	  TEMP_STRING := TEMP_STRING + '       REFL / NULL / FULL .... ';
	  IF ZHA_ENVIRONMENT.ZHF_PIVOT_SURF_REFL THEN
	    CommandIOMemo.IOHistory.Lines.add (TEMP_STRING + 'REFL')
	  ELSE
	  IF ZHA_ENVIRONMENT.ZHG_PIVOT_SURF_NULL THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING + 'NULL')
	  ELSE
	  IF ZHA_ENVIRONMENT.ZHH_PIVOT_SURF_FULL THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING + 'FULL');
	  IF ZHA_ENVIRONMENT.ZHD_USE_LOCAL_COORDS THEN
	    TEMP_STRING := 'SYSTEM / LOCAL ........ LOCAL '
	  ELSE
	    TEMP_STRING := 'SYSTEM / LOCAL ........ SYSTEM';
	  TEMP_STRING := TEMP_STRING + '      PERM / TEMP ........... ';
	  IF ZHA_ENVIRONMENT.ZHI_REVISIONS_ARE_TEMPORARY THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING + 'TEMP')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING + 'PERM');
          TEMP_STRING := 'REF(erenceSurface ..... ' +
              IntToStrF (ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE, 2) +
              '          SBLOK / NS (Surf range / cancel) .... ';
          IF ZHA_ENVIRONMENT.SurfaceRangeActivated THEN
            CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING +
                IntToStrF (ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK, 2) +
	        '-' + IntToStrF (ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK, 2))
          ELSE
            CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING + '**-**');
          TEMP_STRING := '                                    ' +
              'RBLOK / NR (Ray range / cancel) ..... ';
          IF ZHA_ENVIRONMENT.RayRangeActivated THEN
            CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING +
                IntToStrF (ZHA_ENVIRONMENT.FirstRayInBlock, 2) + '-' +
                IntToStrF (ZHA_ENVIRONMENT.LastRayInBlock, 2))
          ELSE
            CommandIOMemo.IOHistory.Lines.add
		(TEMP_STRING + '**-**');
	  THICKNESS := SQRT (SQR (ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X -
	      (ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBM_VERTEX_X +
	      ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBN_VERTEX_DELTA_X)) +
	      SQR (ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y -
	      (ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBO_VERTEX_Y +
	      ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBP_VERTEX_DELTA_Y)) +
	      SQR (ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z -
	      (ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBQ_VERTEX_Z +
	      ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
	      ZBR_VERTEX_DELTA_Z)));
          Str (THICKNESS:12, TEMP_STRING);
	  CommandIOMemo.IOHistory.Lines.add
	      ('PRESENT THICKNESS (Reference point --> Surf. ' +
	      IntToStr (ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK)
              + ') = ' + TEMP_STRING);
	  Str (ZHA_ENVIRONMENT.ZHO_DX_VALUE, TEMP_STRING);
	  CommandIOMemo.IOHistory.Lines.add
		('DX (x displacement) ...... ' + TEMP_STRING);
	  Str (ZHA_ENVIRONMENT.ZHP_DY_VALUE, TEMP_STRING);
	  CommandIOMemo.IOHistory.Lines.add
		('DY (y displacement) ...... ' + TEMP_STRING);
	  Str (ZHA_ENVIRONMENT.ZHQ_DZ_VALUE, TEMP_STRING);
	  CommandIOMemo.IOHistory.Lines.add
		('DZ (z displacement) ...... ' + TEMP_STRING);
	  Str (ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X, TEMP_STRING);
	  CommandIOMemo.IOHistory.Lines.add
		('X (pivot/ref point x) .... ' + TEMP_STRING);
	  Str (ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y, TEMP_STRING);
	  CommandIOMemo.IOHistory.Lines.add
		('Y (pivot/ref point y) .... ' + TEMP_STRING);
	  Str (ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z, TEMP_STRING);
	  CommandIOMemo.IOHistory.Lines.add
		('Z (pivot/ref point z) .... ' + TEMP_STRING);
          Str (ZHA_ENVIRONMENT.ScaleFactor, TEMP_STRING);
          CommandIOMemo.IOHistory.Lines.add
		('FACTOR (scale factor) .... ' + TEMP_STRING);
	  IF ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS THEN
	    BEGIN
	      Str (ZHA_ENVIRONMENT.ZHU_EULER_AXIS_X_MAG, TEMP_STRING);
	      CommandIOMemo.IOHistory.Lines.add
		('EX (Euler axis x mag.) ... ' + TEMP_STRING);
	      Str (ZHA_ENVIRONMENT.ZHV_EULER_AXIS_Y_MAG, TEMP_STRING);
	      CommandIOMemo.IOHistory.Lines.add
		('EY (Euler axis y mag.) ... ' + TEMP_STRING);
	      Str (ZHA_ENVIRONMENT.ZHW_EULER_AXIS_Z_MAG, TEMP_STRING);
	      CommandIOMemo.IOHistory.Lines.add
		('EZ (Euler axis z mag.) ... ' + TEMP_STRING);
	      Str (ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT, TEMP_STRING);
	      CommandIOMemo.IOHistory.Lines.add
		('ER (Euler axis rot.) ..... ' + TEMP_STRING)
	    END
	  ELSE
	    BEGIN
	      Str (ZHA_ENVIRONMENT.ZHR_ROLL, TEMP_STRING);
	      CommandIOMemo.IOHistory.Lines.add
		('ROLL ..................... ' + TEMP_STRING);
	      Str (ZHA_ENVIRONMENT.ZHS_PITCH, TEMP_STRING);
	      CommandIOMemo.IOHistory.Lines.add
		('PITCH .................... ' + TEMP_STRING);
	      Str (ZHA_ENVIRONMENT.ZHT_YAW, TEMP_STRING);
	      CommandIOMemo.IOHistory.Lines.add
		('YAW ...................... ' + TEMP_STRING)
	    END;
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER ENVIRONMENT COMMAND:');
          CommandIOMemo.IOHistory.Lines.add
		('  TR(anslate, TH(ick, RO(tate, SC(ale, *, *P, *O,' +
	      ' *-, ZERO, INC, AIM, CLR');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF (POS (S01AI_LENGTH_3_RESPONSE, CIAA_VALID_ENVIRON_COMMANDS_1) > 0)
	  OR (POS (S01AK_LENGTH_6_RESPONSE, CIAB_VALID_ENVIRON_COMMANDS_2) > 0)
	  OR (POS (S01AK_LENGTH_6_RESPONSE, CIAC_VALID_ENVIRON_COMMANDS_3) > 0)
	  OR (POS (S01AK_LENGTH_6_RESPONSE, CIAD_VALID_ENVIRON_COMMANDS_4) > 0)
	  OR (POS (S01AL_LENGTH_11_RESPONSE,
	      CIAE_VALID_ENVIRON_COMMANDS_5) > 0) THEN
	BEGIN
	  IF S01AK_LENGTH_6_RESPONSE = CIBH_PERFORM_TRANSLATION THEN
	    BEGIN
	      Valid := TRUE;
	      AIN_TRANSLATE := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIBJ_ADJUST_THICKNESS THEN
	    BEGIN
	      Valid := TRUE;
	      AIQ_ADJUST_THICKNESS := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = PerformScaleAdjustment THEN
	    BEGIN
	      Valid := TRUE;
	      AdjustScale := TRUE
	    END
	  ELSE
	  IF S01AL_LENGTH_11_RESPONSE = GetScaleFactor THEN
	    BEGIN
	      CommandString := 'ENTER SCALE FACTOR';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
                BEGIN
                  Valid := FALSE;
                  IF RealNumber > 0.0 THEN
		    ZHA_ENVIRONMENT.ScaleFactor := RealNumber
                  ELSE
                    BEGIN
                      AdjustScale := FALSE;
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                          ('ERROR:  The scale factor must be a number' +
                          ' greater than zero.')
                    END
                END
              ELSE
                BEGIN
                  Q990_INPUT_ERROR_PROCESSING;
	          AdjustScale := FALSE
                END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAG_GET_DX_VALUE THEN
	    BEGIN
	      CommandString := 'ENTER X DISPLACEMENT';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHO_DX_VALUE := RealNumber
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAH_GET_DY_VALUE THEN
	    BEGIN
	      CommandString := 'ENTER Y DISPLACEMENT';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHP_DY_VALUE := RealNumber
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAI_GET_DZ_VALUE THEN
	    BEGIN
	      CommandString := 'ENTER Z DISPLACEMENT';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHQ_DZ_VALUE := RealNumber
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = PerformRayAiming THEN
	    BEGIN
	      Valid := TRUE;
	      AimPrincipalRays := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIBI_PERFORM_ROTATION THEN
	    BEGIN
	      Valid := TRUE;
	      AIP_PERFORM_SYSTEMIC_ROTATION := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIBC_ZERO_OUT_TEMPORARY_CHNGS THEN
	    BEGIN
	      Valid := TRUE;
	      ADW_CLEAR_ZERO := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIBD_INCORPORATE_TEMP_CHNGS THEN
	    BEGIN
	      Valid := TRUE;
	      ADZ_CLEAR_INCORPORATE := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAX_ENVIRON_MODS_ARE_PERM THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
		('SYSTEMIC SPATIAL REVISIONS WILL BE PERMANENT.');
	      ZHA_ENVIRONMENT.ZHI_REVISIONS_ARE_TEMPORARY := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAY_ENVIRON_MODS_ARE_TEMP THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
		('SYSTEMIC SPATIAL REVISIONS WILL BE TEMPORARY.');
	      ZHA_ENVIRONMENT.ZHI_REVISIONS_ARE_TEMPORARY := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAR_SPECIFY_ENVIRON_BLOCK THEN
	    BEGIN
	      Q191_REQUEST_SURF_ORDINAL_RANGE
	          (FirstSurface, LastSurface, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK := FirstSurface;
		  ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK := LastSurface;
		  ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE := FirstSurface;
                  ZHA_ENVIRONMENT.SurfaceRangeActivated := TRUE
		END
	    END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = SpecifyEnvironmentRayBlock THEN
            BEGIN
	      Q291_REQUEST_RAY_ORDINAL_RANGE
	          (FirstRay, LastRay, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.FirstRayInBlock := FirstRay;
		  ZHA_ENVIRONMENT.LastRayInBlock := LastRay;
                  ZHA_ENVIRONMENT.RayRangeActivated := TRUE
		END
            END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = ClearEnvironmentVariables THEN
            BEGIN
              ZHA_ENVIRONMENT.ZIA_ALL_ENVIRONMENT_DATA :=
                  ENVIRONMENT_DATA_INITIALIZER;
              ZHA_ENVIRONMENT.ZHH_PIVOT_SURF_FULL := TRUE;
              ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE := 1;
              ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK := 1;
              ZHA_ENVIRONMENT.ZHK_LAST_SURF_IN_BLOCK :=
                  CZAB_MAX_NUMBER_OF_SURFACES;
              ZHA_ENVIRONMENT.FirstRayInBlock := 1;
              ZHA_ENVIRONMENT.LastRayInBlock := CZAC_MAX_NUMBER_OF_RAYS;
            END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = DeactivateSurfaceRange THEN
            ZHA_ENVIRONMENT.SurfaceRangeActivated := FALSE
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = DeactivateRayRange THEN
            ZHA_ENVIRONMENT.RayRangeActivated := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIBN_GET_ENVIRON_REF_SURF THEN
	    BEGIN
	      Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE := SurfaceOrdinal;
                  IF ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
                      ZBB_SPECIFIED
                      AND ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
                      ZBC_ACTIVE THEN
                  ELSE
                    BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                          ('WARNING:  Specified reference surface ' +
                          IntToStr (ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE) +
                          ' not specified and/or active.')
                    END
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAJ_PICKUP_POS_AND_ORIENT THEN
	    BEGIN
	      ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBM_VERTEX_X +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBN_VERTEX_DELTA_X;
	      ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBO_VERTEX_Y +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBP_VERTEX_DELTA_Y;
	      ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBQ_VERTEX_Z +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBR_VERTEX_DELTA_Z;
	      ZHA_ENVIRONMENT.ZHR_ROLL :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBS_ROLL +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBT_DELTA_ROLL;
	      ZHA_ENVIRONMENT.ZHS_PITCH :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBU_PITCH +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBV_DELTA_PITCH;
	      ZHA_ENVIRONMENT.ZHT_YAW :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBW_YAW +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBX_DELTA_YAW
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIBK_PICKUP_REF_SURF_POS THEN
	    BEGIN
	      ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBM_VERTEX_X +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBN_VERTEX_DELTA_X;
	      ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBO_VERTEX_Y +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBP_VERTEX_DELTA_Y;
	      ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBQ_VERTEX_Z +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBR_VERTEX_DELTA_Z
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIBL_PICKUP_REF_SURF_ORIENT THEN
	    BEGIN
	      ZHA_ENVIRONMENT.ZHR_ROLL :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBS_ROLL +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBT_DELTA_ROLL;
	      ZHA_ENVIRONMENT.ZHS_PITCH :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBU_PITCH +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBV_DELTA_PITCH;
	      ZHA_ENVIRONMENT.ZHT_YAW :=
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBW_YAW +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBX_DELTA_YAW
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIBM_PICKUP_REF_SURF_NEG_ORIENT THEN
	    BEGIN
	      ZHA_ENVIRONMENT.ZHR_ROLL := -1.0 *
		  (ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBS_ROLL +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBT_DELTA_ROLL);
	      ZHA_ENVIRONMENT.ZHS_PITCH := -1.0 *
		  (ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBU_PITCH +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBV_DELTA_PITCH);
	      ZHA_ENVIRONMENT.ZHT_YAW := -1.0 *
		  (ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBW_YAW +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.ZHY_REFERENCE_SURFACE].
		  ZBX_DELTA_YAW)
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAK_GET_PIVOT_POINT_X_COORD THEN
	    BEGIN
	      CommandString := 'ENTER PIVOT POINT X-COORDINATE';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X := RealNumber
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAL_GET_PIVOT_POINT_Y_COORD THEN
	    BEGIN
	      CommandString := 'ENTER PIVOT POINT Y-COORDINATE';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y := RealNumber
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAM_GET_PIVOT_POINT_Z_COORD THEN
	    BEGIN
	      CommandString := 'ENTER PIVOT POINT Z-COORDINATE';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z := RealNumber
		END
	    END
	  ELSE
	  IF (S01AK_LENGTH_6_RESPONSE = CIAZ_1ST_BLOCK_SURF_REFLECTOR)
	      OR (S01AK_LENGTH_6_RESPONSE = CIBA_1ST_BLOCK_SURF_IS_NULL)
	      OR (S01AK_LENGTH_6_RESPONSE = CIBB_1ST_BLOCK_SURF_FULL_ROT) THEN
	    BEGIN
	      (* Determine if the vertex of the first surface in the block
		 is the pivot point. *)
	      PIVOT_DISTANCE :=
		  SQRT (SQR ((ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBM_VERTEX_X +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBN_VERTEX_DELTA_X) -
		  ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X) +
		  SQR ((ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBO_VERTEX_Y +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBP_VERTEX_DELTA_Y) -
		  ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y) +
		  SQR ((ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBQ_VERTEX_Z +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBR_VERTEX_DELTA_Z) -
		  ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z));
	      IF PIVOT_DISTANCE < 1.0E-12 THEN
		(* First surface is pivot *)
		BEGIN
		  IF S01AK_LENGTH_6_RESPONSE =
		      CIAZ_1ST_BLOCK_SURF_REFLECTOR THEN
		    IF ZBA_SURFACE [ZHA_ENVIRONMENT.ZHJ_FIRST_SURF_IN_BLOCK].
		       ZBD_REFLECTIVE THEN
		      BEGIN
			ZHA_ENVIRONMENT.ZHF_PIVOT_SURF_REFL := TRUE;
			ZHA_ENVIRONMENT.ZHG_PIVOT_SURF_NULL := FALSE;
			ZHA_ENVIRONMENT.ZHH_PIVOT_SURF_FULL := FALSE
		      END
		    ELSE
		      BEGIN
			CommandIOMemo.IOHistory.Lines.add ('');
			CommandIOMemo.IOHistory.Lines.add
		            ('FIRST SURFACE IN BLOCK IS NOT A REFLECTIVE' +
			    ' SURFACE');
			Q990_INPUT_ERROR_PROCESSING
		      END
		  ELSE
		  IF S01AK_LENGTH_6_RESPONSE =
		      CIBA_1ST_BLOCK_SURF_IS_NULL THEN
		    BEGIN
		      ZHA_ENVIRONMENT.ZHF_PIVOT_SURF_REFL := FALSE;
		      ZHA_ENVIRONMENT.ZHG_PIVOT_SURF_NULL := TRUE;
		      ZHA_ENVIRONMENT.ZHH_PIVOT_SURF_FULL := FALSE
		    END
		  ELSE
		    BEGIN
		      ZHA_ENVIRONMENT.ZHF_PIVOT_SURF_REFL := FALSE;
		      ZHA_ENVIRONMENT.ZHG_PIVOT_SURF_NULL := FALSE;
		      ZHA_ENVIRONMENT.ZHH_PIVOT_SURF_FULL := TRUE
		    END
		END
	      ELSE
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
		('FIRST SURFACE IN BLOCK IS NOT PIVOT POINT.');
		  Q990_INPUT_ERROR_PROCESSING
		END
	    END
	  ELSE
	  IF S01AL_LENGTH_11_RESPONSE = CIBF_COORDS_ARE_REF_SYSTEM THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
		('ROTATION PARAMETERS ARE DEFINED WITH RESPECT TO');
	      CommandIOMemo.IOHistory.Lines.add
		('MASTER COORDINATE SYSTEM.');
	      ZHA_ENVIRONMENT.ZHD_USE_LOCAL_COORDS := FALSE
	    END
	  ELSE
	  IF S01AL_LENGTH_11_RESPONSE = CIBG_COORDS_ARE_LOCAL THEN
	    BEGIN
	      (* Determine if the vertex of the first surface in the block
		 is the pivot point. *)
	      PIVOT_DISTANCE :=
		  SQRT (SQR ((ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBM_VERTEX_X +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBN_VERTEX_DELTA_X) -
		  ZHA_ENVIRONMENT.ZHL_PIVOT_POINT_X) +
		  SQR ((ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBO_VERTEX_Y +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBP_VERTEX_DELTA_Y) -
		  ZHA_ENVIRONMENT.ZHM_PIVOT_POINT_Y) +
		  SQR ((ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBQ_VERTEX_Z +
		  ZBA_SURFACE [ZHA_ENVIRONMENT.
		  ZHJ_FIRST_SURF_IN_BLOCK].ZBR_VERTEX_DELTA_Z) -
		  ZHA_ENVIRONMENT.ZHN_PIVOT_POINT_Z));
	      IF PIVOT_DISTANCE < 1.0E-12 THEN
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
		('ROTATION PARAMETERS ARE DEFINED WITH RESPECT TO');
		  CommandIOMemo.IOHistory.Lines.add
		('LOCAL (SURFACE VERTEX) COORDINATE SYSTEM.');
		  ZHA_ENVIRONMENT.ZHD_USE_LOCAL_COORDS := TRUE
		END
	      ELSE
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
		('FIRST SURFACE IN BLOCK IS NOT PIVOT POINT.');
		  Q990_INPUT_ERROR_PROCESSING
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAS_ENABLE_YAW_PITCH_ROLL THEN
	    ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAV_GET_YAW_VALUE THEN
	    BEGIN
	      CommandString := 'ENTER INCREMENTAL YAW IN DEGREES';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHT_YAW := RealNumber;
		  ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := FALSE
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAU_GET_PITCH_VALUE THEN
	    BEGIN
	      CommandString := 'ENTER INCREMENTAL PITCH IN DEGREES';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHS_PITCH := RealNumber;
		  ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := FALSE
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAT_GET_ROLL_VALUE THEN
	    BEGIN
	      CommandString := 'ENTER INCREMENTAL ROLL IN DEGREES';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHR_ROLL := RealNumber;
		  ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := FALSE
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CIAW_ENABLE_EULER_AXIS_ROT THEN
	    ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := TRUE
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAN_GET_EULER_AXIS_X_MAG THEN
	    BEGIN
	      CommandString := 'ENTER X-MAGNITUDE OF EULER AXIS';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHU_EULER_AXIS_X_MAG := RealNumber;
		  ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := TRUE
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAO_GET_EULER_AXIS_Y_MAG THEN
	    BEGIN
	      CommandString := 'ENTER Y-MAGNITUDE OF EULER AXIS';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHV_EULER_AXIS_Y_MAG := RealNumber;
		  ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := TRUE
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAP_GET_EULER_AXIS_Z_MAG THEN
	    BEGIN
	      CommandString := 'ENTER Z-MAGNITUDE OF EULER AXIS';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHW_EULER_AXIS_Z_MAG := RealNumber;
		  ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := TRUE
		END
	    END
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CIAQ_GET_EULER_AXIS_ROT_VALUE THEN
	    BEGIN
	      CommandString :=
		  'ENTER (SIGNED) ANGLE OF ROTATION ABOUT EULER AXIS';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		BEGIN
		  Valid := FALSE;
		  ZHA_ENVIRONMENT.ZHX_EULER_AXIS_ROT := RealNumber;
		  ZHA_ENVIRONMENT.ZHC_USE_EULER_AXIS := TRUE
		END
	    END
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpEnvironment
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  LADSq4Unit  *************************************************************
*****************************************************************************)


BEGIN

END.

