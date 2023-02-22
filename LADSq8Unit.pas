UNIT LADSq8Unit;

INTERFACE

PROCEDURE Q400_REQUEST_OPTIMIZATION_DATA;

IMPLEMENTATION

  USES (*Graph,*)
       SysUtils,
       EXPERTIO,
       LADSInitUnit,
       LADSData,
       LADSq6Unit,
       LADSGlassCompUnit,
       LADSOptimizeUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;
       
PROCEDURE Q401_REQUEST_MERIT_FUNCTION;  FORWARD;
PROCEDURE Q404_REQUEST_SURF_DATA_FOR_OPTIMIZE
    (SurfaceOrdinal    : INTEGER);      FORWARD;
PROCEDURE Q405_REQUEST_RADIUS_BOUNDS
    (CommandString     : STRING;
     VAR Valid         : BOOLEAN;
     VAR Radius        : DOUBLE);       FORWARD;
PROCEDURE Q406_REQUEST_POSITION_BOUNDS
    (CommandString     : STRING;
     VAR Valid         : BOOLEAN;
     VAR Position      : DOUBLE);       FORWARD;


(**  Q400_REQUEST_OPTIMIZATION_DATA  ******************************************
******************************************************************************)


PROCEDURE Q400_REQUEST_OPTIMIZATION_DATA;

  VAR
      Valid           : BOOLEAN;

      SurfaceOrdinal  : INTEGER;

      TempString      : STRING;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER OPTIMIZATION COMMAND:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('NOTE:  Before optimizing, please be sure that you have:');
	  CommandIOMemo.IOHistory.Lines.add
		('  (1) specified a ray bundle type (usually "3FAN")');
	  CommandIOMemo.IOHistory.Lines.add
		('  (2) specified a ray bundle head diameter (BHD)');
	  CommandIOMemo.IOHistory.Lines.add
		('  (3) disabled ray trace error messages (EROFF)');
	  CommandIOMemo.IOHistory.Lines.add
		('  (4) specified an image surface (ORD)');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('                   ----------- OPTIMIZATION DATA ' +
	      '-----------');
	  TempString := 'OPTIMIZATION ACTIVATED: ................ ';
	  IF ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED THEN
	    CommandIOMemo.IOHistory.Lines.add (TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add (TempString + 'NO');
	  TempString := 'AUTOMATIC BOUND WIDTH REDUCTION: ....... ';
	  IF ZLA_OPTIMIZATION_DATA.ZLE_BOUND_REDUCTION_ACTIVATED THEN
	    CommandIOMemo.IOHistory.Lines.add (TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add (TempString + 'NO');
	  TempString := 'AUTOMATIC BOUND RE-CENTERING: .......... ';
	  IF ZLA_OPTIMIZATION_DATA.ZLF_BOUND_RECENTERING_ACTIVATED THEN
	    CommandIOMemo.IOHistory.Lines.add (TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add (TempString + 'NO');
	  TempString := 'MERIT FUNCTION: ........................ ';
	  IF ZLA_OPTIMIZATION_DATA.ZLD_MERIT_FUNCTION_CODE = 'R' THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'MINIMIZE RMS BLUR DIA. AT FINAL SURF.')
	  ELSE
	  IF ZLA_OPTIMIZATION_DATA.ZLD_MERIT_FUNCTION_CODE = 'F' THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'MINIMIZE FULL BLUR DIA. AT FINAL SURF.')
	  ELSE
	  IF ZLA_OPTIMIZATION_DATA.ZLD_MERIT_FUNCTION_CODE = 'U' THEN
	    WRITELN ('MAXIMIZE IMAGE UNIFORMITY AT FINAL SURF.');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER OPTIMIZATION COMMAND:');
	  CommandIOMemo.IOHistory.Lines.add
		('  A  Activate/deactivate optimization (on/off switch)');
	  CommandIOMemo.IOHistory.Lines.add
		('  B  Activate/deactivate automatic boundary width');
	  CommandIOMemo.IOHistory.Lines.add
		('       ("temperature") reduction (on/off switch)');
	  CommandIOMemo.IOHistory.Lines.add
		('  C  Activate/deactivate automatic bound re-centering');
	  CommandIOMemo.IOHistory.Lines.add
		('       (on/off switch)');
	  CommandIOMemo.IOHistory.Lines.add
		('  D  Choose merit function');
	  CommandIOMemo.IOHistory.Lines.add
		('  I  Provide by-surface optimization data');
          CommandIOMemo.IOHistory.Lines.add
                ('  Z  Clear all optimization parameters for all surfaces');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CSAA_VALID_OPTIMIZE_COMMANDS) > 0 THEN
	BEGIN
          IF S01AH_LENGTH_2_RESPONSE = CSAK_CLEAR_ALL_PARAMETERS THEN
            BEGIN
              FOR SurfaceOrdinal := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
                BEGIN
                  IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
                    BEGIN
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZMC_OPTIMIZE_RADIUS := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZMD_ENFORCE_RADIUS_BOUNDS := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZME_PERMIT_SURF_PITCH_REVERSAL := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZMG_OPTIMIZE_POSITION := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZMI_OPTIMIZE_GLASS := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZMJ_USE_PREFERRED_GLASS := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZMK_OPTIMIZE_CONIC_CONSTANT := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZML_ENFORCE_CONIC_CONST_BOUNDS := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
                          ZMB_OPTIMIZATION_SWITCHES.
		          ZMM_CONTROL_SEPARATION := FALSE;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZMS_RADIUS_BOUND_1 := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZMT_RADIUS_BOUND_2 := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZMW_CONIC_CONST_BOUND_1 := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZMX_CONIC_CONST_BOUND_2 := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZMU_POSITION_BOUND_1 := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZMV_POSITION_BOUND_2 := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZLQ_THICKNESS := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZLO_DELTA_THICKNESS := 0.0;
	              ZBA_SURFACE [SurfaceOrdinal].
	                  ZLN_NEXT_SURFACE := 0
                    END
                END
            END
          ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CSAB_OPTIMIZE_ACTIVE_SWITCH THEN
	    IF ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED THEN
	      ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED := FALSE
	    ELSE
	      ZLA_OPTIMIZATION_DATA.ZLB_OPTIMIZATION_ACTIVATED := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CSAD_BOUND_REDUCTION_SWITCH THEN
	    IF ZLA_OPTIMIZATION_DATA.ZLE_BOUND_REDUCTION_ACTIVATED THEN
	      ZLA_OPTIMIZATION_DATA.ZLE_BOUND_REDUCTION_ACTIVATED := FALSE
	    ELSE
	      ZLA_OPTIMIZATION_DATA.ZLE_BOUND_REDUCTION_ACTIVATED := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CSAE_BOUND_RECENTERING_SWITCH THEN
	    IF ZLA_OPTIMIZATION_DATA.ZLF_BOUND_RECENTERING_ACTIVATED THEN
	      ZLA_OPTIMIZATION_DATA.ZLF_BOUND_RECENTERING_ACTIVATED := FALSE
	    ELSE
	      ZLA_OPTIMIZATION_DATA.ZLF_BOUND_RECENTERING_ACTIVATED := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CSAC_GET_MERIT_FUNCTION THEN
	    Q401_REQUEST_MERIT_FUNCTION
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CSAJ_GET_SURF_OPTIMIZE_DATA THEN
	    BEGIN
	      Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
	      IF Valid THEN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
		  Q404_REQUEST_SURF_DATA_FOR_OPTIMIZE (SurfaceOrdinal)
		ELSE
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		        ('SURFACE ' + IntToStr (SurfaceOrdinal) +
                        ' NOT SPECIFIED.')
		  END
	      ELSE
	        BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
		      ('SURFACE ' + IntToStr (SurfaceOrdinal) +
                      ' NOT SPECIFIED.')
		END
	    END;
	  IF S01AC_NULL_RESPONSE_GIVEN THEN
	    S01AB_USER_IS_DONE := FALSE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpOptimizationCommands
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  Q401_REQUEST_MERIT_FUNCTION  *********************************************
******************************************************************************)


PROCEDURE Q401_REQUEST_MERIT_FUNCTION;

  VAR
      Valid  : BOOLEAN;

BEGIN

  Valid	:= FALSE;
  
  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'ENTER MERIT FUNCTION CODE: R(MSblur F(ullBlur U(niformity';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
	      ('ENTER MERIT FUNCTION CODE: R(MSblur F(ullBlur U(niformity');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE,
          CTAA_VALID_MERIT_FUNC_COMMANDS) > 0 THEN
	BEGIN
	  Valid := TRUE;
	  ZLA_OPTIMIZATION_DATA.ZLD_MERIT_FUNCTION_CODE :=
	      S01AF_BLANKS_STRIPPED_RESPONSE_UC [1]
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpOptimizationMeritFunction
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q404_REQUEST_SURF_DATA_FOR_OPTIMIZE  *************************************
******************************************************************************)


PROCEDURE Q404_REQUEST_SURF_DATA_FOR_OPTIMIZE;

  VAR
      Valid                 : BOOLEAN;

      Q404AA_HOLD_SURF_ORD  : INTEGER;

      CommandString         : STRING;
      TempString            : STRING;
      Temp                  : STRING;

      Radius                : DOUBLE;
      Position              : DOUBLE;
      ConicConstant         : DOUBLE;

BEGIN

  REPEAT
    BEGIN
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('            ===   BY-SURFACE OPTIMIZATION ' +
	      ' DATA -- SURFACE #' + IntToStr (SurfaceOrdinal) + '   ===');
	  TempString := 'OPTIMIZE RADIUS: ....................... ';
	  IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
	      ZMC_OPTIMIZE_RADIUS THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'NO');
	(*TempString := 'SURFACE ORIENTATION REVERSAL OK: ....... ';
	  IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
	      ZME_PERMIT_SURF_PITCH_REVERSAL THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'NO');*)
	  TempString := 'OPTIMIZE Z-AXIS POSITION: .............. ';
	  IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
	      ZMG_OPTIMIZE_POSITION THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'NO');
	  TempString := 'CONTROL DISTANCE TO NEXT SURFACE: ...... ';
	  IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
	      ZMM_CONTROL_SEPARATION THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'YES (CONTROLLED SURF. = ' +
		IntToStr (ZBA_SURFACE [SurfaceOrdinal].ZLN_NEXT_SURFACE) + ')')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'NO');
	  TempString := 'OPTIMIZE LENS MATERIAL (GLASS TYPE): ... ';
	  IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
	      ZMI_OPTIMIZE_GLASS THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'NO');
	  TempString := 'USE ONLY PREFERRED GLASSES: ............ ';
	  IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
	      ZMJ_USE_PREFERRED_GLASS THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'NO');
	  TempString := 'OPTIMIZE CONIC CONSTANT: ............... ';
	  IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
	      ZMK_OPTIMIZE_CONIC_CONSTANT THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'YES')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + 'NO');
	  CommandIOMemo.IOHistory.Lines.add
		('RADIUS BOUND 1: .... ' +
                FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZMS_RADIUS_BOUND_1, ffFixed, 15 ,10) +
	      '   RADIUS BOUND 2: .... ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZMT_RADIUS_BOUND_2, ffFixed, 15, 10));
	  CommandIOMemo.IOHistory.Lines.add
		('CONIC CONST BOUND 1: ' +
                FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZMW_CONIC_CONST_BOUND_1, ffFixed, 15, 10) +
	      '   CONIC CONST BOUND 2: ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZMX_CONIC_CONST_BOUND_2, ffFixed, 15, 10));
	  CommandIOMemo.IOHistory.Lines.add
		('POSITION BOUND 1: .. ' +
                FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZMU_POSITION_BOUND_1, ffFixed, 15, 10) +
	      '   POSITION_BOUND 2: .. ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZMV_POSITION_BOUND_2, ffFixed, 15, 10));
	  CommandIOMemo.IOHistory.Lines.add
		('THICKNESS: ......... ' +
                FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZLQ_THICKNESS, ffFixed, 15, 10) +
	      '   DELTA THICKNESS: ... ' +
              FloatToStrF (ZBA_SURFACE [SurfaceOrdinal].
	      ZLO_DELTA_THICKNESS, ffFixed, 15, 10))
        END;
      IF S01AA_EXPERT_MODE_OFF THEN
        Q980_REQUEST_MORE_OUTPUT;
      Temp := 'ENTER OPTIMIZATION COMMAND FOR SURFACE #' +
          IntToStr (SurfaceOrdinal) + ':';
      CommandIOdlg.Caption := Temp;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
        BEGIN
	  CommandIOMemo.IOHistory.Lines.add (Temp);
	  CommandIOMemo.IOHistory.Lines.add
		('  A  Optimize radius (toggle)');
	  CommandIOMemo.IOHistory.Lines.add
		('  B  Reset radius bounds to default values');
	  CommandIOMemo.IOHistory.Lines.add
		('  C  Enter radius bound 1 value');
	  CommandIOMemo.IOHistory.Lines.add
		('  D  Enter radius bound 2 value');
	  CommandIOMemo.IOHistory.Lines.add
		('  E  Permit surface orientation reversal (toggle)');
	  CommandIOMemo.IOHistory.Lines.add
		('  G  Optimize z-axis position (toggle)');
	  CommandIOMemo.IOHistory.Lines.add
		('  I  Enter position bound 1 value');
	  CommandIOMemo.IOHistory.Lines.add
		('  J  Enter position bound 2 value');
	  CommandIOMemo.IOHistory.Lines.add
		('  H  Control distance to next surf. (toggle)');
	  CommandIOMemo.IOHistory.Lines.add
		('  S  Surface ordinal of controlled surface');
	  CommandIOMemo.IOHistory.Lines.add
		('  Q  Ideal distance to controlled surface');
	  CommandIOMemo.IOHistory.Lines.add
		('  R  Permitted variation in ideal distance');
	  CommandIOMemo.IOHistory.Lines.add
		('  K  Optimize lens material (glass type) (toggle)');
	  CommandIOMemo.IOHistory.Lines.add
		('  L  Use only preferred glasses (toggle)');
	  CommandIOMemo.IOHistory.Lines.add
		('  M  Optimize conic constant (toggle)');
	  CommandIOMemo.IOHistory.Lines.add
		('  N  Reset conic constant bounds to default values');
	  CommandIOMemo.IOHistory.Lines.add
		('  O  Enter conic constant bound 1 value');
	  CommandIOMemo.IOHistory.Lines.add
		('  P  Enter conic constant bound 2 value');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CUAA_VALID_SURF_OPTIMIZE_CMDS) > 0 THEN
	BEGIN
	  IF S01AH_LENGTH_2_RESPONSE = CUAB_OPTIMIZE_RADIUS_SW THEN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		ZMC_OPTIMIZE_RADIUS THEN
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMC_OPTIMIZE_RADIUS := FALSE
	    ELSE
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMC_OPTIMIZE_RADIUS := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAC_RESET_RADIUS_BOUNDS THEN
	    BEGIN
	      ZBA_SURFACE [SurfaceOrdinal].ZMS_RADIUS_BOUND_1 :=
	          MIN_RADIUS;
	      ZBA_SURFACE [SurfaceOrdinal].ZMT_RADIUS_BOUND_2 :=
	          MAX_RADIUS
            (*IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
	          ZBA_SURFACE [SurfaceOrdinal].
		  ZMB_OPTIMIZATION_SWITCHES.
		  ZME_PERMIT_SURF_PITCH_REVERSAL := TRUE*)
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAD_GET_RADIUS_BOUND_1 THEN
	    BEGIN
	      CommandString := 'ENTER RADIUS BOUND 1';
	      Q405_REQUEST_RADIUS_BOUNDS (CommandString, Valid, Radius);
	      IF Valid THEN
		ZBA_SURFACE [SurfaceOrdinal].ZMS_RADIUS_BOUND_1 := Radius
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAE_GET_RADIUS_BOUND_2 THEN
	    BEGIN
	      CommandString := 'ENTER RADIUS BOUND 2';
	      Q405_REQUEST_RADIUS_BOUNDS (CommandString, Valid, Radius);
	      IF Valid THEN
		ZBA_SURFACE [SurfaceOrdinal].ZMT_RADIUS_BOUND_2 := Radius
	    END
	(*ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAF_PERMIT_SURF_PITCH_REV_SW THEN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		ZME_PERMIT_SURF_PITCH_REVERSAL THEN
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZME_PERMIT_SURF_PITCH_REVERSAL := FALSE
	    ELSE
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZME_PERMIT_SURF_PITCH_REVERSAL := TRUE*)
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAH_OPTIMIZE_POSITION_SW THEN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		ZMG_OPTIMIZE_POSITION THEN
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMG_OPTIMIZE_POSITION := FALSE
	    ELSE
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMG_OPTIMIZE_POSITION := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAJ_GET_POSITION_BOUND_1 THEN
	    BEGIN
	      CommandString := 'ENTER POSITION BOUND 1';
	      Q406_REQUEST_POSITION_BOUNDS (CommandString, Valid, Position);
	      IF Valid THEN
		ZBA_SURFACE [SurfaceOrdinal].ZMU_POSITION_BOUND_1 := Position
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAK_GET_POSITION_BOUND_2 THEN
	    BEGIN
	      CommandString := 'ENTER POSITION BOUND 2';
	      Q406_REQUEST_POSITION_BOUNDS (CommandString, Valid, Position);
	      IF Valid THEN
		ZBA_SURFACE [SurfaceOrdinal].ZMV_POSITION_BOUND_2 := Position
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAI_CONTROL_SEPARATION THEN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		ZMM_CONTROL_SEPARATION THEN
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMM_CONTROL_SEPARATION := FALSE
	    ELSE
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMM_CONTROL_SEPARATION := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAR_GET_NEXT_SURFACE THEN
	    BEGIN
	      Q404AA_HOLD_SURF_ORD := SurfaceOrdinal;
	      Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
	      IF Valid THEN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED
		    AND ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE THEN
		  BEGIN
		    ZBA_SURFACE [Q404AA_HOLD_SURF_ORD].ZLN_NEXT_SURFACE :=
			SurfaceOrdinal;
		    SurfaceOrdinal := Q404AA_HOLD_SURF_ORD
		  END
		ELSE
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		        ('Surface to be position-controlled must be' +
			' specified and active.');
		    Q990_INPUT_ERROR_PROCESSING
		  END
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAS_GET_THICKNESS THEN
	    BEGIN
	      CommandString :=
		  'ENTER IDEAL DISTANCE TO CONTROLLED SURFACE';
	      Q406_REQUEST_POSITION_BOUNDS (CommandString, Valid, Position);
	      IF Valid THEN
		ZBA_SURFACE [SurfaceOrdinal].ZLQ_THICKNESS := Position
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAT_GET_DELTA_THICKNESS THEN
	    BEGIN
	      CommandString :=
		  'ENTER PERMITTED VARIATION IN IDEAL DISTANCE';
	      Q406_REQUEST_POSITION_BOUNDS (CommandString, Valid, Position);
	      IF Valid THEN
		IF Position >= 0.0 THEN
		  ZBA_SURFACE [SurfaceOrdinal].ZLO_DELTA_THICKNESS := Position
		ELSE
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		('Thickness variation may not be negative.');
		    Q990_INPUT_ERROR_PROCESSING
		  END
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAL_OPTIMIZE_GLASS_TYPE_SW THEN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		ZMI_OPTIMIZE_GLASS THEN
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMI_OPTIMIZE_GLASS := FALSE
	    ELSE
	      BEGIN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		('Reflective surface may not be optimized for');
		    CommandIOMemo.IOHistory.Lines.add
		('glass type.');
		    Q990_INPUT_ERROR_PROCESSING
		  END
		ELSE
		  ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		      ZMI_OPTIMIZE_GLASS := TRUE
	      END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAM_USE_PREFERRED_GLASSES_SW THEN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		ZMJ_USE_PREFERRED_GLASS THEN
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMJ_USE_PREFERRED_GLASS := FALSE
	    ELSE
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMJ_USE_PREFERRED_GLASS := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAN_OPTIMIZE_CONIC_CONST_SW THEN
	    IF ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		ZMK_OPTIMIZE_CONIC_CONSTANT THEN
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMK_OPTIMIZE_CONIC_CONSTANT := FALSE
	    ELSE
	      ZBA_SURFACE [SurfaceOrdinal].ZMB_OPTIMIZATION_SWITCHES.
		  ZMK_OPTIMIZE_CONIC_CONSTANT := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAO_RESET_CONIC_CONST_BOUNDS THEN
	    BEGIN
	      ZBA_SURFACE [SurfaceOrdinal].ZMW_CONIC_CONST_BOUND_1 :=
	          MIN_CONIC_CONSTANT;
	      ZBA_SURFACE [SurfaceOrdinal].ZMX_CONIC_CONST_BOUND_2 :=
	          MAX_CONIC_CONSTANT
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAP_GET_CONIC_CONST_BOUND_1 THEN
	    BEGIN
	      CommandString := 'ENTER CONIC CONSTANT BOUND 1';
	      Q104_REQUEST_CONIC_CONSTANT (CommandString,
	          Valid, ConicConstant);
	      IF Valid THEN
		ZBA_SURFACE [SurfaceOrdinal].ZMW_CONIC_CONST_BOUND_1 :=
		    ConicConstant
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CUAQ_GET_CONIC_CONST_BOUND_2 THEN
	    BEGIN
	      CommandString := 'ENTER CONIC CONSTANT BOUND 2';
	      Q104_REQUEST_CONIC_CONSTANT (CommandString,
	          Valid, ConicConstant);
	      IF Valid THEN
		ZBA_SURFACE [SurfaceOrdinal].ZMX_CONIC_CONST_BOUND_2 :=
		    ConicConstant
	    END
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpOptimizationSurfaceDataCommands
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  Q405_REQUEST_RADIUS_BOUNDS	 **********************************************
******************************************************************************)


PROCEDURE Q405_REQUEST_RADIUS_BOUNDS;

  VAR
      CODE         : INTEGER;

BEGIN

  Valid := FALSE;

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
	HelpOptimizationRadiusBounds
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, Radius, CODE);
	  IF CODE = 0 THEN
	    IF Radius > 0.0 THEN
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




(**  Q406_REQUEST_POSITION_BOUNDS  ********************************************
******************************************************************************)


PROCEDURE Q406_REQUEST_POSITION_BOUNDS;

  VAR
      CODE  : INTEGER;

BEGIN

  Valid := FALSE;

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
	HelpOptimizationPositionBounds
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, Position, CODE);
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



(**  LADSq8Unit  ************************************************************
****************************************************************************)

BEGIN

END.
