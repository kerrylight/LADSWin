UNIT LADSq5bUnit;

INTERFACE

PROCEDURE Q100_REQUEST_SURFACE_REVISION (SurfaceOrdinal : INTEGER);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSData,
       LADSInitUnit,
       LADSq5cUnit,
       LADSq6Unit,
       LADSq9Unit,
       LADSqCPCUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;


(**  Q100_REQUEST_SURFACE_REVISION  *******************************************
******************************************************************************)


PROCEDURE Q100_REQUEST_SURFACE_REVISION;

  VAR

    Valid                                  : BOOLEAN;
      
    TEMP_STRING                            : STRING;
    CommandString                          : STRING;
      
    TEMP_SUM	                             : DOUBLE;
    ConicConstant                          : DOUBLE;
    RealNumber                             : DOUBLE;
      
    I		                                   : INTEGER;
    CODE                                   : INTEGER;
    DeformConstIndex                       : INTEGER;
      
    IntegerNumber                          : LONGINT;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER SURFACE REVISION CODE:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
        BEGIN
	        CommandIOMemo.IOHistory.Lines.add ('');
	        CommandIOMemo.IOHistory.Lines.add	('ENTER SURFACE REVISION CODE:');
	        CommandIOMemo.IOHistory.Lines.add
		          ('  RA N1 N2 M CC O TE BE SC CY CN DE nn CP SI RE');
	        CommandIOMemo.IOHistory.Lines.add
		          ('  X DX Y DY Z DZ YA DA P DP R DR AS XR YR XS YS');
          CommandIOMemo.IOHistory.Lines.add
		          ('  OD ID OX OY IX IY AX AY CO CI QO QI EO EI');
	        CommandIOMemo.IOHistory.Lines.add ('')
	      END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
        CommandIOMemo.IOHistory.Lines.add (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF (POS (S01AI_LENGTH_3_RESPONSE, CKAA_VALID_SURF_REV_COMMANDS_1) > 0)
          OR (POS (S01AI_LENGTH_3_RESPONSE,
          CKAB_VALID_SURF_REV_COMMANDS_2) > 0) THEN
	      BEGIN
	        IF S01AI_LENGTH_3_RESPONSE = CKAZ_DEFINE_CPC THEN
            BEGIN
	            IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = CPC)
                  OR (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm =
                  HybridCPC) THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := Conic;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL CPC STATUS FOR SURFACE ' +
                      IntToStr (SurfaceOrdinal) + '.')
		            END
	            ELSE
	              DesignCPC (SurfaceOrdinal)
            END
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKAD_GET_RADIUS THEN
            Q101_REQUEST_RADIUS_OF_CURVATURE (SurfaceOrdinal, Valid)
          ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKAC_GET_INDEX_1 THEN
	          Q102_REQUEST_INDEX_OF_REFRACTION (1, SurfaceOrdinal, Valid)
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKAE_GET_INDEX_2 THEN
	          Q102_REQUEST_INDEX_OF_REFRACTION (2, SurfaceOrdinal, Valid)
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKBP_REFLECTIVE_SURFACE_SW THEN
	          BEGIN
	            IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE;
		              ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY := 0.0;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                 ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW' +
		                 ' REFRACTIVE.  (RE(flectance set to 0.)');
		            END
	            ELSE
		            BEGIN
		              IF ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
		                BEGIN
		                  CommandIOMemo.IOHistory.Lines.add ('');
		                  CommandIOMemo.IOHistory.Lines.add
		                      ('CANCELLING BEAMSPLITTER STATUS FOR SURFACE ' +
		                      IntToStr (SurfaceOrdinal) + '.');
		                  ZBA_SURFACE [SurfaceOrdinal].
                          ZBY_BEAMSPLITTER_SURFACE := FALSE
		                END;
		              ZBA_SURFACE [SurfaceOrdinal].
                  ZBD_REFLECTIVE := TRUE;
		              ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY := 1.0;
		              CommandIOMemo.IOHistory.Lines.add ('');
                  CommandIOMemo.IOHistory.Lines.add
		                  ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW' +
		                  ' REFLECTIVE.  (RE(flectance set to 1.)');
		            END
            END
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKAF_GET_OUTSIDE_DIA THEN
            Q103_REQUEST_SURFACE_DIAMETER (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKAG_GET_INSIDE_DIA THEN
	          Q103_REQUEST_SURFACE_DIAMETER (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBF_GET_OUTSIDE_WIDTH_X THEN
            Q103_REQUEST_SURFACE_DIAMETER (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBG_GET_OUTSIDE_WIDTH_Y THEN
	          Q103_REQUEST_SURFACE_DIAMETER (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKBH_GET_INSIDE_WIDTH_X THEN
            Q103_REQUEST_SURFACE_DIAMETER (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBI_GET_INSIDE_WIDTH_Y THEN
	          Q103_REQUEST_SURFACE_DIAMETER (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKBR_GET_APERTURE_POSITION_X THEN
	          BEGIN
	            CommandString :=
		              'ENTER X OFFSET OF APERTURE (RELATIVE TO SURFACE VERTEX)';
	            Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	            IF Valid THEN
                ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X :=
                    RealNumber
	          END
          ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBS_GET_APERTURE_POSITION_Y THEN
	          BEGIN
	            CommandString :=
		              'ENTER Y OFFSET OF APERTURE (RELATIVE TO SURFACE VERTEX)';
              Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	            IF Valid THEN
		            ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y :=
                    RealNumber
	           END
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKBJ_CIRCULAR_OUTSIDE_SW THEN
	          BEGIN
	            ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR := FALSE;
	            ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL :=
                  FALSE;
	            CommandIOMemo.IOHistory.Lines.add ('');
	            CommandIOMemo.IOHistory.Lines.add
		              ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' OUTSIDE' +
		              ' APERTURE IS NOW CIRCULAR.')
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBK_CIRCULAR_INSIDE_SW THEN
	          BEGIN
	            ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR := FALSE;
	            ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL :=
                  FALSE;
              CommandIOMemo.IOHistory.Lines.add ('');
	            CommandIOMemo.IOHistory.Lines.add
		              ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' INSIDE' +
		              ' APERTURE IS NOW CIRCULAR.')
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBL_SQUARE_OUTSIDE_SW THEN
	          BEGIN
              ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR := TRUE;
	            ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL :=
                  FALSE;
	            CommandIOMemo.IOHistory.Lines.add ('');
	            CommandIOMemo.IOHistory.Lines.add
		              ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' OUTSIDE' +
		              ' APERTURE IS NOW RECTANGULAR.')
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBM_SQUARE_INSIDE_SW THEN
	          BEGIN
	            ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR := TRUE;
	            ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL :=
                  FALSE;
	            CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
		              ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' INSIDE' +
		              ' APERTURE IS NOW RECTANGULAR.')
            END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBN_ELLIPTICAL_OUTSIDE_SW THEN
	          BEGIN
	            ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR := FALSE;
              ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL :=
                  TRUE;
	            CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
		              ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' OUTSIDE' +
		              ' APERTURE IS NOW ELLIPTICAL.')
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBO_ELLIPTICAL_INSIDE_SW THEN
            BEGIN
	            ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR := FALSE;
	            ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL :=
                  TRUE;
	            CommandIOMemo.IOHistory.Lines.add ('');
	            CommandIOMemo.IOHistory.Lines.add
		              ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' INSIDE' +
		              ' APERTURE IS NOW ELLIPTICAL.')
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAH_GET_CONIC_CONSTANT THEN
	          BEGIN
	            CommandString := 'ENTER CONIC CONSTANT';
	            Q104_REQUEST_CONIC_CONSTANT (CommandString, Valid, ConicConstant);
              IF Valid THEN
	              ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT := ConicConstant
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBC_OPD_REF_SURF_SWITCH THEN
	          BEGIN
	            IF ZBA_SURFACE [SurfaceOrdinal].ZBF_OPD_REFERENCE THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].ZBF_OPD_REFERENCE := FALSE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL OPD REFERENCE STATUS FOR SURFACE ' +
		                  IntToStr (SurfaceOrdinal) + '.')
		            END
	            ELSE
		            BEGIN
		              IF ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
		                BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
		                  CommandIOMemo.IOHistory.Lines.add
		                      ('CANCELLING BEAMSPLITTER STATUS FOR SURFACE ' +
		                      IntToStr (SurfaceOrdinal) + '.');
                      ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE :=
                          FALSE
		                END;
		              ZBA_SURFACE [SurfaceOrdinal].ZBF_OPD_REFERENCE := TRUE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW' +
		                  ' AN OPD REFERENCE SURFACE.')
		            END
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAM_CYLINDRICAL_SURF_SW THEN
	          BEGIN
	            IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := FALSE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL CYLINDER STATUS FOR SURFACE ' +
                      IntToStr (SurfaceOrdinal) + '.')
		            END
	            ELSE
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := TRUE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW ' +
		                  'CYLINDRICAL.')
		            END
	          END
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = SurfaceArraySwitch THEN
            BEGIN
              IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
                BEGIN
                  ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL SURFACE ARRAY STATUS FOR SURFACE ' +
                      IntToStr (SurfaceOrdinal) + '.')
                END
              ELSE
                BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].LensletArray := TRUE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW ' +
		                  'A SURFACE ARRAY')
                END
            END
          ELSE
          IF S01AI_LENGTH_3_RESPONSE = SurfaceArrayXRepeat THEN
            Q140_REQUEST_SURFACE_ARRAY_DIMENSIONS (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
          ELSE
          IF S01AI_LENGTH_3_RESPONSE = SurfaceArrayYRepeat THEN
            Q140_REQUEST_SURFACE_ARRAY_DIMENSIONS (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
          ELSE
          IF S01AI_LENGTH_3_RESPONSE = SurfaceArrayXSpacing THEN
            Q141_REQUEST_SURFACE_ARRAY_SPACING (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
          ELSE
          IF S01AI_LENGTH_3_RESPONSE = SurfaceArrayYSpacing THEN
            Q141_REQUEST_SURFACE_ARRAY_SPACING (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
          ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAI_DEFORMATION_CONSTS_SW THEN
	          BEGIN
	            IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm =
                  HighOrderAsphere THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := Conic;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL USE OF DEFORMATION CONSTANTS FOR ' +
                      'SURFACE ' + IntToStr (SurfaceOrdinal) + '.')
		            END
              ELSE
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].SurfaceForm :=
                      HighOrderAsphere;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('DEFORMATION CONSTANTS WILL NOW BE USED FOR ' +
                      'SURFACE ' + IntToStr (SurfaceOrdinal) + '.')
		            END
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAJ_RAY_TERMINATION_SURF_SW THEN
	          BEGIN
	            IF ZBA_SURFACE [SurfaceOrdinal].ZCI_RAY_TERMINATION_SURFACE THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].ZCI_RAY_TERMINATION_SURFACE :=
                      FALSE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL ABSORBER STATUS FOR SURFACE ' +
		                  IntToStr (SurfaceOrdinal) + '.')
		            END
              ELSE
		            BEGIN
		              IF ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
		                BEGIN
		                  CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
		                      ('CANCELLING BEAMSPLITTER STATUS FOR SURFACE ' +
                          IntToStr (SurfaceOrdinal) + '.');
		                  ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE :=
                          FALSE
		                END;
		              ZBA_SURFACE [SurfaceOrdinal].ZCI_RAY_TERMINATION_SURFACE :=
                      TRUE;
		              CommandIOMemo.IOHistory.Lines.add ('');
                  CommandIOMemo.IOHistory.Lines.add
		                  ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW' +
		                  ' AN ABSORBER.')
		            END
	          END
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKAK_BEAMSPLITTER_SURF_SW THEN
	          BEGIN
	            IF ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE :=
                      FALSE;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL BEAMSPLITTER STATUS FOR SURFACE ' +
		                  IntToStr (SurfaceOrdinal) + '.')
		            END
	            ELSE
		            BEGIN
		              IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
		                BEGIN
		                  CommandIOMemo.IOHistory.Lines.add ('');
		                  CommandIOMemo.IOHistory.Lines.add
		                      ('CANCELLING MIRROR STATUS FOR SURFACE ' +
		                      IntToStr (SurfaceOrdinal) + '.');
		                  ZBA_SURFACE [SurfaceOrdinal].
		                  ZBD_REFLECTIVE := FALSE
		                END;
	                IF ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE THEN
		                BEGIN
		                  CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
		                      ('CANCELLING SCATTERER STATUS FOR SURFACE ' +
		                      IntToStr (SurfaceOrdinal) + '.');
		                  ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE :=
                          FALSE
		                END;
		              ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE := TRUE;
		              ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY :=
                      DefaultBeamsplitRatio;
		              CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW' +
		                  ' A BEAMSPLITTER.  (REFLECTIVITY SET TO ' +
                      FloatToStrF (DefaultBeamsplitRatio, ffFixed, 6, 4) + '.)')
		            END
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAL_SCATTERING_SURF_SW THEN
	          BEGIN
              IF ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE THEN
		            BEGIN
		              ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE := FALSE;
                  CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('CANCEL SCATTERING STATUS FOR SURFACE ' +
                      IntToStr (SurfaceOrdinal) + '.')
		            END
	            ELSE
		            BEGIN
		              IF ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
		                BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
		                  CommandIOMemo.IOHistory.Lines.add
		                  ('CANCELLING BEAMSPLITTER STATUS FOR SURFACE ' +
		                  IntToStr (SurfaceOrdinal) + '.');
		                  ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE :=
                          FALSE
		                END;
		              ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE := TRUE;
                  CommandIOMemo.IOHistory.Lines.add ('');
		              CommandIOMemo.IOHistory.Lines.add
		                  ('SURFACE ' + IntToStr (SurfaceOrdinal) + ' IS NOW' +
		                  ' A SCATTERER.')
		            END
	          END
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBD_GET_SCATTERING_ANGLE THEN
	          Q106_REQUEST_SCATTERING_ANGLE (SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKBE_GET_SURFACE_REFLECTIVITY THEN
	          Q107_REQUEST_SURFACE_REFLECTIVITY (SurfaceOrdinal)
          ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAN_GET_SURF_X_POSITION THEN
	          Q120_REQUEST_SURFACE_POSITION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAO_GET_SURF_DELTA_X THEN
	          Q120_REQUEST_SURFACE_POSITION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAP_GET_SURF_Y_POSITION THEN
	          Q120_REQUEST_SURFACE_POSITION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAQ_GET_SURF_DELTA_Y THEN
	          Q120_REQUEST_SURFACE_POSITION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAR_GET_SURF_Z_POSITION THEN
	          Q120_REQUEST_SURFACE_POSITION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAS_GET_SURF_DELTA_Z THEN
	          Q120_REQUEST_SURFACE_POSITION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
          IF S01AI_LENGTH_3_RESPONSE = CKAT_GET_SURF_ROLL THEN
	          Q130_REQUEST_SURFACE_ORIENTATION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAU_GET_SURF_DELTA_ROLL THEN
	          Q130_REQUEST_SURFACE_ORIENTATION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAV_GET_SURF_PITCH THEN
	          Q130_REQUEST_SURFACE_ORIENTATION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAW_GET_SURF_DELTA_PITCH THEN
	          Q130_REQUEST_SURFACE_ORIENTATION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAX_GET_SURF_YAW THEN
	          Q130_REQUEST_SURFACE_ORIENTATION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal)
	        ELSE
	        IF S01AI_LENGTH_3_RESPONSE = CKAY_GET_SURF_DELTA_YAW THEN
	          Q130_REQUEST_SURFACE_ORIENTATION (S01AI_LENGTH_3_RESPONSE,
	              SurfaceOrdinal);
	        IF NOT S01AD_END_EXECUTION_DESIRED THEN
	          S01AB_USER_IS_DONE := FALSE
        END
      ELSE
      IF S01AB_USER_IS_DONE THEN
        BEGIN
        END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpSurfaceRevisionCommands
      ELSE
        BEGIN
          VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
          IF CODE = 0 THEN
	          IF (IntegerNumber > 0)
		            AND (IntegerNumber <= CZAI_MAX_DEFORM_CONSTANTS) THEN
	            BEGIN
		            DeformConstIndex := IntegerNumber;
		            STR (DeformConstIndex, TEMP_STRING);
		            CommandString := CONCAT ('ENTER ', TEMP_STRING);
		            IF DeformConstIndex = 1 THEN
                  CommandString := CONCAT (CommandString,
		                  'ST ORDER DEFORMATION CONSTANT')
		            ELSE
		            IF DeformConstIndex = 2 THEN
		              CommandString := CONCAT (CommandString,
		                  'ND ORDER DEFORMATION CONSTANT')
		            ELSE
		            IF DeformConstIndex = 3 THEN
                  CommandString := CONCAT (CommandString,
		                  'RD ORDER DEFORMATION CONSTANT')
		            ELSE
		              CommandString := CONCAT (CommandString,
		                  'TH ORDER DEFORMATION CONSTANT');
		            Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
		            IF Valid THEN
                  BEGIN
		                ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
                        ZCA_DEFORMATION_CONSTANT [DeformConstIndex] :=
			                  RealNumber;
		                TEMP_SUM := 0.0;
		                FOR I := 1 TO CZAI_MAX_DEFORM_CONSTANTS DO
                    TEMP_SUM := TEMP_SUM + ZBA_SURFACE [SurfaceOrdinal].
			                  SurfaceShapeParameters.
                        ZCA_DEFORMATION_CONSTANT [I];
		                IF TEMP_SUM = 0 THEN
		                  ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := Conic
                    ELSE
		                  ZBA_SURFACE [SurfaceOrdinal].SurfaceForm :=
                          HighOrderAsphere
		              END
		            ELSE
                IF NOT S01AD_END_EXECUTION_DESIRED THEN
                  S01AB_USER_IS_DONE := FALSE
	            END
	          ELSE
	            Q990_INPUT_ERROR_PROCESSING
	        ELSE
	          Q990_INPUT_ERROR_PROCESSING
	      END
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  LADSq5bUnit  ***********************************************************
****************************************************************************)

BEGIN

END.
