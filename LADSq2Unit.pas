UNIT LADSq2Unit;

INTERFACE

PROCEDURE Q050_REQUEST_TRACE_OPTION;

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSData,
       LADSq3Unit,
       LADSq6Unit,
       LADSq7Unit,
       LADSq9Unit,
       LADSInitUnit,
       LADSRandomUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;


(**  Q050_REQUEST_TRACE_OPTION	***********************************************
******************************************************************************)


PROCEDURE Q050_REQUEST_TRACE_OPTION; (* NEW *)

  VAR
      Valid                        : BOOLEAN;

      I				   : INTEGER;
      SurfaceOrdinal               : INTEGER;

      ListfileName                 : STRING;
      DatafileName                 : STRING;
      CommandString                : STRING;
      TempString                   : STRING;

      RealNumber                   : DOUBLE;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER TRACE OPTIONS:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Clear;
	  CommandIOMemo.IOHistory.Lines.add ('');
          CommandIOMemo.IOHistory.Lines.add ('CURRENT TRACE OPTIONS:');
	  TempString := 'DRAW SURFACES AND RAYS ......................';
	  IF ZFA_OPTION.DRAW_RAYS THEN
	    BEGIN
	      TempString := TempString + '....... ON';
              IF ZFA_OPTION.ShowSurfaceNumbers THEN
                CommandIOMemo.IOHistory.Lines.add
		(TempString + ' (WITH SURFACE NUMBERS)')
              ELSE
                CommandIOMemo.IOHistory.Lines.add
		(TempString + ' (NO SURFACE NUMBERS)');
	      CommandIOMemo.IOHistory.Lines.add
		  ('  DIA. = ' +
                FloatToStrF (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER, ffFixed, 12, 4) +
	          '  VX = ' +
              FloatToStrF (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X, ffFixed, 12, 4) +
		  '  VY = ' +
              FloatToStrF (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y, ffFixed, 12, 4) +
		  '  VZ = ' +
              FloatToStrF (ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z, ffFixed, 12, 4))
	    END
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'DESIGNATED "IMAGE" SURFACE ..................';
	  IF ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (SURFACE ' +
		  IntToStr (ZFA_OPTION.ZGK_DESIGNATED_SURFACE) + ')');
	      CommandIOMemo.IOHistory.Lines.add
                  ('  CA DIA. = ' +
              FloatToStrF (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER, ffFixed, 12, 4) +
	          '  VX = ' +
              FloatToStrF (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X, ffFixed, 12, 4) +
		  '  VY = ' +
              FloatToStrF (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y, ffFixed, 12, 4) +
		  '  VZ = ' +
              FloatToStrF (ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z, ffFixed, 12, 4));
              CommandIOMemo.IOHistory.Lines.add
                  ('  LIMITING APERTURE SURFACE = ' +
                  IntToStr (ZFA_OPTION.ApertureStopSurface))
	    END
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'SURFACE SEQUENCER ...........................';
	  IF ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'NON-SEQUENTIAL TRACE ........................';
	  IF ZFA_OPTION.ZGI_RECURSIVE_TRACE THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'ALTERNATE RAY FILE STATUS ...................';
	  IF ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE
	      OR ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  IF ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE THEN
	    CommandIOMemo.IOHistory.Lines.add
		('  INPUT FILE NAME: ' +
		ZFA_OPTION.ZGO_ALT_INPUT_RAY_FILE_NAME);
	  IF ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE THEN
	    CommandIOMemo.IOHistory.Lines.add
		('  OUTPUT FILE NAME: ' +
		ZFA_OPTION.ZGQ_ALT_OUTPUT_RAY_FILE_NAME +
		', WRITTEN AFTER SURFACE ' +
		IntToStr (ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE));
          TempString := 'INCIDENT/EXIT ANGLE DETAIL ON CONSOLE .......';
          IF ZFA_OPTION.DisplayLocalData THEN
            CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
          ELSE
            CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'TRACE DETAIL INFO. ON CONSOLE ...............';
	  IF ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'TRACE DETAIL INFO. ON PRINTER ...............';
	  IF ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'TRACE DETAIL INFO. ON FILE ..................';
	  IF ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString +
                '....... ON (' + ZFA_OPTION.ZGB_TRACE_DETAIL_FILE + ')')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'DISPLAY SPOT DIAGRAM ON CONSOLE .............';
	  IF ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'PRODUCE SPOT DIAGRAM FILE ...................';
	  IF ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (' +
		ZFA_OPTION.ZFM_SPOT_DIAGRAM_FILE_NAME + ')')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'DISPLAY OPTICAL PATH DIFFERENCE STATS .......';
	  IF ZFA_OPTION.ZGF_DISPLAY_FULL_OPD THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (FULL)')
	  ELSE
	  IF ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (BRIEF)')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'PRODUCE POINT SPREAD FUNCTION FILE ..........';
	  IF ZFA_OPTION.ZFL_PRODUCE_PSF_FILE THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (' +
                ZFA_OPTION.ZFN_PSF_FILE_NAME + ')')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'PRINT INTENSITY HISTOGRAM ...................';
	  IF ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (AHIST)')
	  ELSE
	  IF ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (RHIST)')
          ELSE
          IF ZFA_OPTION.EnableLinearIntensityHist THEN
            CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON (LHIST)')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF');
	  TempString := 'DISABLE ERROR DISPLAY .......................';
	  IF ZFA_OPTION.ZGR_QUIET_ERRORS THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '....... ON')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' OFF')
        END;
      IF S01AA_EXPERT_MODE_OFF THEN
	  Q980_REQUEST_MORE_OUTPUT;
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
        BEGIN
	  CommandIOMemo.IOHistory.Lines.add
              ('ENTER TRACE OPTION:');
          CommandIOMemo.IOHistory.Lines.add
              ('  Viewport size and position ........ DIA, VX, VY');
          CommandIOMemo.IOHistory.Lines.add
              ('  Image surface designation ......... ORD, DES, XDES');
          CommandIOMemo.IOHistory.Lines.add
              ('  Non-sequential trace .............. REC, XREC');
          CommandIOMemo.IOHistory.Lines.add
              ('  Trace detail coordinates .......... CDTL, XCDTL, ' +
              'LDTL, XLDTL');
          CommandIOMemo.IOHistory.Lines.add
              ('  Alternate output for trace info ... PDTL, XPDTL,' +
              ' FDTL, XFDTL');
          CommandIOMemo.IOHistory.Lines.add
              ('  Spot diagrams enable/disable ...... CSPT, CTRL, XCSPT');
          CommandIOMemo.IOHistory.Lines.add
              ('  Optical path difference output .... FOPD, BOPD, XOPD');
          CommandIOMemo.IOHistory.Lines.add
              ('  Enable/disable error reporting .... ERRON, EROFF');
          CommandIOMemo.IOHistory.Lines.add
              ('  Point spread function file ........ FPSF, XFPSF');
          CommandIOMemo.IOHistory.Lines.add
              ('  Enclosed energy histograms ........ AHIST, LHIST,' +
              ' RHIST, XHIST');
          CommandIOMemo.IOHistory.Lines.add
              ('  Alternate ray file ................ RRAY, WRAY, NRAY');
          CommandIOMemo.IOHistory.Lines.add
              ('  Draw commands ..................... DRAW, VX, VY, VZ,' +
              ' DIA, XDRAW, NUM, XNUM');
          CommandIOMemo.IOHistory.Lines.add
              ('  Define trace sequence ............. SDEF, SON, SOFF');
          CommandIOMemo.IOHistory.Lines.add
              ('  Random number generator ........... SEED');
          CommandIOMemo.IOHistory.Lines.add
              ('  Reset all parameters .............. CLR');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('>')
	END;
      S01_PROCESS_REQUEST;
      IF (POS (S01AK_LENGTH_6_RESPONSE, CFAA_VALID_OPTION_COMMANDS_1) > 0)
	  OR (POS (S01AK_LENGTH_6_RESPONSE, CFAB_VALID_OPTION_COMMANDS_2) > 0)
	  OR (POS (S01AK_LENGTH_6_RESPONSE, CFCA_VALID_OPTION_COMMANDS_4) > 0)
	  OR (POS (S01AK_LENGTH_6_RESPONSE,
	      CFCB_VALID_OPTION_COMMANDS_5) > 0) THEN
	BEGIN
	  IF S01AK_LENGTH_6_RESPONSE = CFBI_ENABLE_DESIGNATED_SURFACE THEN
	    ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED := TRUE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBJ_DISABLE_DESIGNATED_SURFACE THEN
	    ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBL_GET_DESIG_SURF_ORDINAL THEN
	    BEGIN
	      Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
	      IF Valid THEN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
		  BEGIN
	            ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED := TRUE;
		    ZFA_OPTION.ZGK_DESIGNATED_SURFACE := SurfaceOrdinal;
                    ZFA_OPTION.ApertureStopSurface := SurfaceOrdinal;
                    IF (NOT ZBA_SURFACE [SurfaceOrdinal].
                          ZBZ_SURFACE_IS_FLAT)
                        AND (ZBA_SURFACE [SurfaceOrdinal].
                          ZBH_OUTSIDE_DIMENS_SPECD)
	                AND (ZBA_SURFACE [SurfaceOrdinal].
                          ZCT_INSIDE_DIMENS_SPECD)
                        AND (NOT ZBA_SURFACE [SurfaceOrdinal].
                          ZCL_OUTSIDE_APERTURE_IS_SQR)
                        AND (NOT ZBA_SURFACE [SurfaceOrdinal].
                          ZCM_INSIDE_APERTURE_IS_SQR)
                        AND (NOT ZBA_SURFACE [SurfaceOrdinal].
                          ZCN_OUTSIDE_APERTURE_ELLIPTICAL)
                        AND (NOT ZBA_SURFACE [SurfaceOrdinal].
                          ZCO_INSIDE_APERTURE_ELLIPTICAL)
    			AND (abs (ZBA_SURFACE [SurfaceOrdinal].
			  ZCW_APERTURE_POSITION_Y) > 1.0E-12) THEN
                      BEGIN
		        ZFA_OPTION.ZGC_VIEWPORT_POSITION_X :=
			    ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
			    ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X;
		        ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y :=
			    ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
			    ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y
                      END
                    ELSE
		      BEGIN
                        ZFA_OPTION.ZGC_VIEWPORT_POSITION_X :=
    			    ZBA_SURFACE [SurfaceOrdinal].
			    ZCV_APERTURE_POSITION_X +
			    ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X +
			    ZBA_SURFACE [SurfaceOrdinal].ZBN_VERTEX_DELTA_X;
		        ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y :=
    			    ZBA_SURFACE [SurfaceOrdinal].
			    ZCW_APERTURE_POSITION_Y +
			    ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y +
			    ZBA_SURFACE [SurfaceOrdinal].ZBP_VERTEX_DELTA_Y
                      END;
		    ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z :=
			ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z +
			ZBA_SURFACE [SurfaceOrdinal].ZBR_VERTEX_DELTA_Z;
		    IF ZBA_SURFACE [SurfaceOrdinal].
			ZBH_OUTSIDE_DIMENS_SPECD THEN
		      BEGIN
			IF ZBA_SURFACE [SurfaceOrdinal].
			    ZCL_OUTSIDE_APERTURE_IS_SQR THEN
                          BEGIN
                            IF ZBA_SURFACE [SurfaceOrdinal].
                                ZCP_OUTSIDE_APERTURE_WIDTH_X >
                                ZBA_SURFACE [SurfaceOrdinal].
                                ZCQ_OUTSIDE_APERTURE_WIDTH_Y THEN
                              ZFA_OPTION.ZGL_VIEWPORT_DIAMETER :=
                                  ZBA_SURFACE [SurfaceOrdinal].
                                  ZCP_OUTSIDE_APERTURE_WIDTH_X
                            ELSE
                              ZFA_OPTION.ZGL_VIEWPORT_DIAMETER :=
                                  ZBA_SURFACE [SurfaceOrdinal].
                                  ZCQ_OUTSIDE_APERTURE_WIDTH_Y
                          END
(*			  ZFA_OPTION.ZGL_VIEWPORT_DIAMETER :=
			      SQRT (SQR (ZBA_SURFACE [SurfaceOrdinal].
			      ZCP_OUTSIDE_APERTURE_WIDTH_X) +
			      SQR (ZBA_SURFACE [SurfaceOrdinal].
			      ZCQ_OUTSIDE_APERTURE_WIDTH_Y))*)
			ELSE
			IF ZBA_SURFACE [SurfaceOrdinal].
			    ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
			  BEGIN
			    IF ZBA_SURFACE [SurfaceOrdinal].
				ZCP_OUTSIDE_APERTURE_WIDTH_X >
				ZBA_SURFACE [SurfaceOrdinal].
				ZCQ_OUTSIDE_APERTURE_WIDTH_Y THEN
			      ZFA_OPTION.ZGL_VIEWPORT_DIAMETER :=
				  ZBA_SURFACE [SurfaceOrdinal].
				  ZCP_OUTSIDE_APERTURE_WIDTH_X
			    ELSE
			      ZFA_OPTION.ZGL_VIEWPORT_DIAMETER :=
				  ZBA_SURFACE [SurfaceOrdinal].
				  ZCQ_OUTSIDE_APERTURE_WIDTH_Y
			  END
			ELSE
			  ZFA_OPTION.ZGL_VIEWPORT_DIAMETER :=
			      ZBA_SURFACE [SurfaceOrdinal].
			      ZBJ_OUTSIDE_APERTURE_DIA
		      END
		    ELSE
		      ZFA_OPTION.ZGL_VIEWPORT_DIAMETER :=
			    CZBM_DEFAULT_VIEWPORT_DIAMETER
		  END
		ELSE
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
                        ('ERROR: SPECIFIED SURFACE ' +
                        IntToStr (SurfaceOrdinal) + ' IS NOT DEFINED.')
		  END
	    END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = GetApertureStopSurface THEN
            BEGIN
	      Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
	      IF Valid THEN
		IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
                  ZFA_OPTION.ApertureStopSurface := SurfaceOrdinal
                ELSE
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
                        ('ERROR: Spot-controlling surface ' +
                        IntToStr (SurfaceOrdinal) + ' is not defined.')
		  END
            END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBK_GET_VIEWPORT_DIAMETER THEN
	    BEGIN
	      CommandString := 'ENTER VIEWPORT DIAMETER (>= 0)';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		IF RealNumber >= 0.0 THEN
		  ZFA_OPTION.ZGL_VIEWPORT_DIAMETER := RealNumber
		ELSE
		  Q990_INPUT_ERROR_PROCESSING
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBN_GET_VIEWPORT_POSITION_X THEN
	    BEGIN
	      CommandString := 'ENTER VIEWPORT X POSITION';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		ZFA_OPTION.ZGC_VIEWPORT_POSITION_X := RealNumber
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBO_GET_VIEWPORT_POSITION_Y THEN
	    BEGIN
	      CommandString := 'ENTER VIEWPORT Y POSITION';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y := RealNumber
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBU_GET_VIEWPORT_POSITION_Z THEN
	    BEGIN
	      CommandString := 'ENTER VIEWPORT Z POSITION';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
		ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z := RealNumber
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFCD_ENABLE_SURFACE_SEQUENCER THEN
	    ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER := TRUE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFCE_DISABLE_SURFACE_SEQUENCER THEN
	    ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFCC_GET_SURFACE_SEQUENCE THEN
	    Q052_REQUEST_SURFACE_SEQUENCE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBG_ENABLE_RECURSIVE_TRACE THEN
	    ZFA_OPTION.ZGI_RECURSIVE_TRACE := TRUE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBH_DISABLE_RECURSIVE_TRACE THEN
	    ZFA_OPTION.ZGI_RECURSIVE_TRACE := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBD_CLEAR_ALL_OPTION_SWITCHES THEN
	    BEGIN
	      FOR I := 1 TO CZAQ_OPTION_DATA_BOOLEAN_FIELDS DO
	        ZFA_OPTION.ZFS_ALL_OPTION_DATA.ZFT_BOOLEAN_DATA [I] := FALSE
(*	      ZFA_OPTION.ZFO_COMPUTED_RAY_COUNT	:= 0*)
	    END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE =
              CFCJ_ENABLE_LOCAL_DETAIL_TO_CONSOLE THEN
            BEGIN
              ZFA_OPTION.DisplayLocalData := TRUE;
	      ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE := FALSE;
	      ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER := FALSE;
	      ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE := FALSE;
	      ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM := FALSE;
	      ZFA_OPTION.DRAW_RAYS := FALSE
            END
          ELSE
          IF S01AK_LENGTH_6_RESPONSE =
              CFCK_DISABLE_LOCAL_DETAIL_TO_CONSOLE THEN
              ZFA_OPTION.DisplayLocalData := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAX_ENABLE_DETAIL_PRINT THEN
            BEGIN
	      ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER := TRUE;
              ZFA_OPTION.DisplayLocalData := FALSE
            END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAY_DISABLE_DETAIL_PRINT THEN
	    ZFA_OPTION.ZFZ_PUT_TRACE_DETAIL_ON_PRINTER := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAF_ENABLE_DETAIL_TO_CONSOLE THEN
	    BEGIN
	      ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE := TRUE;
              ZFA_OPTION.DisplayLocalData := FALSE;
	      ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM := FALSE;
	      ZFA_OPTION.DRAW_RAYS := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAG_DISABLE_DETAIL_TO_CONSOLE THEN
	    ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAZ_ENABLE_DETAIL_TO_FILE THEN
	    BEGIN
	      ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE := FALSE;
	      Q500_REQUEST_LIST_FILE_NAME (Valid, ListfileName);
	      IF Valid THEN
		BEGIN
		  ZFA_OPTION.ZGB_TRACE_DETAIL_FILE := ListfileName;
		  ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE := TRUE;
                  ZFA_OPTION.DisplayLocalData := FALSE
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBA_DISABLE_DETAIL_TO_FILE THEN
	    ZFA_OPTION.ZGA_PUT_TRACE_DETAIL_ON_FILE := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAH_ENABLE_SPOT_DIAGRAM THEN
	    BEGIN
	      ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM := TRUE;
	      ZFA_OPTION.ZGR_QUIET_ERRORS := TRUE;
	      ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE := FALSE;
              ZFA_OPTION.DRAW_RAYS := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAI_DISABLE_SPOT_DIAGRAM THEN
	    ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAL_ENABLE_SPOT_DIAGRAM_FILE THEN
	    BEGIN
	      ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE := FALSE;
	      Q505_REQUEST_DATAFILE_NAME (Valid, DatafileName);
	      IF Valid THEN
		BEGIN
		  Q590_CHECK_NEW_FILE (DatafileName, Valid);
		  IF Valid THEN
		    BEGIN
		      ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE := TRUE;
		      ZFA_OPTION.ZFM_SPOT_DIAGRAM_FILE_NAME :=
			  DatafileName
		    END
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAM_DISABLE_SPOT_DIAGRAM_FILE THEN
	    ZFA_OPTION.ZFK_PRODUCE_SPOT_DIAGRAM_FILE := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBV_ENABLE_DRAW_RAYS THEN
	    BEGIN
	      ZFA_OPTION.DRAW_RAYS := TRUE;
	      ZFA_OPTION.ZGJ_IMAGE_SURFACE_DESIGNATED := FALSE;
	      ZFA_OPTION.ZGK_DESIGNATED_SURFACE := CZBL_DEFAULT_IMAGE_SURFACE;
	      ZFA_OPTION.ZFH_DISPLAY_SPOT_DIAGRAM := FALSE;
	      ZFA_OPTION.ZFI_PUT_TRACE_DETAIL_ON_CONSOLE := FALSE;
              ZFA_OPTION.DisplayLocalData := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBW_DISABLE_DRAW_RAYS THEN
	    ZFA_OPTION.DRAW_RAYS := FALSE
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = EnableDisplaySurfaceNumbers THEN
            ZFA_OPTION.ShowSurfaceNumbers := TRUE
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = DisableDisplaySurfaceNumbers THEN
            ZFA_OPTION.ShowSurfaceNumbers := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBB_ENABLE_FULL_OPD_DISPLAY THEN
	    BEGIN
	      ZFA_OPTION.ZGF_DISPLAY_FULL_OPD := TRUE;
	      ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBM_ENABLE_BRIEF_OPD_DISPLAY THEN
	    BEGIN
	      ZFA_OPTION.ZGF_DISPLAY_FULL_OPD := FALSE;
	      ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBC_DISABLE_OPD_DISPLAY THEN
	    BEGIN
	      ZFA_OPTION.ZGF_DISPLAY_FULL_OPD := FALSE;
	      ZFA_OPTION.ZGM_DISPLAY_BRIEF_OPD := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAJ_ENABLE_AREA_INTENSITY_HIST THEN
	    BEGIN
	      ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST := TRUE;
	      ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST := FALSE;
              ZFA_OPTION.EnableLinearIntensityHist := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAW_ENABLE_RADIUS_INTENSITY_HIST THEN
	    BEGIN
	      ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST := FALSE;
	      ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST := TRUE;
              ZFA_OPTION.EnableLinearIntensityHist := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = EnableLinearIntensityHistogram THEN
	    BEGIN
	      ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST := FALSE;
	      ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST := FALSE;
              ZFA_OPTION.EnableLinearIntensityHist := TRUE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAK_DISABLE_INTENSITY_HISTOGRAM THEN
	    BEGIN
	      ZFA_OPTION.ZFJ_PRINT_AREA_INTENSITY_HIST := FALSE;
	      ZFA_OPTION.ZFY_PRINT_RADIUS_INTENSITY_HIST := FALSE;
              ZFA_OPTION.EnableLinearIntensityHist := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAN_ENABLE_PSF_FILE THEN
	    BEGIN
	      ZFA_OPTION.ZFL_PRODUCE_PSF_FILE := FALSE;
	      Q505_REQUEST_DATAFILE_NAME (Valid, DatafileName);
	      IF Valid THEN
		BEGIN
		  Q590_CHECK_NEW_FILE (DatafileName, Valid);
		  IF Valid THEN
		    BEGIN
		      ZFA_OPTION.ZFL_PRODUCE_PSF_FILE := TRUE;
		      ZFA_OPTION.ZFN_PSF_FILE_NAME := DatafileName
		    END
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFAO_DISABLE_PSF_FILE THEN
	    ZFA_OPTION.ZFL_PRODUCE_PSF_FILE := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBQ_ENABLE_RAY_FILE_WRITE THEN
	    BEGIN
	      Q505_REQUEST_DATAFILE_NAME (Valid, DatafileName);
	      IF Valid THEN
		IF ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE THEN
		  IF ZFA_OPTION.ZGO_ALT_INPUT_RAY_FILE_NAME <>
		      DatafileName THEN
		    BEGIN
		      Q590_CHECK_NEW_FILE (DatafileName, Valid);
		      IF Valid THEN
			BEGIN
			  Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal,
			      Valid);
			  IF Valid THEN
			    IF ZBA_SURFACE [SurfaceOrdinal].
				ZBB_SPECIFIED THEN
			      BEGIN
				ZFA_OPTION.ZGQ_ALT_OUTPUT_RAY_FILE_NAME :=
				    DatafileName;
				ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE :=
				    TRUE;
				ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE :=
				    SurfaceOrdinal
			      END
			    ELSE
			      BEGIN
				CommandIOMemo.IOHistory.Lines.add ('');
				CommandIOMemo.IOHistory.Lines.add
                                    ('ERROR:  Surface ' +
				    IntToStr (SurfaceOrdinal) +
                                    ' is not specified.')
			      END
			END
		    END
		  ELSE
		    BEGIN
		      Q595_CHECK_OLD_FILE (DatafileName, Valid);
		      IF Valid THEN
			BEGIN
			  Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal,
			      Valid);
			  IF Valid THEN
			    IF ZBA_SURFACE [SurfaceOrdinal].
				ZBB_SPECIFIED THEN
			      BEGIN
				ZFA_OPTION.ZGQ_ALT_OUTPUT_RAY_FILE_NAME :=
				    DatafileName;
				ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE :=
				    TRUE;
				ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE :=
				    SurfaceOrdinal
			      END
			    ELSE
			      BEGIN
				CommandIOMemo.IOHistory.Lines.add ('');
				CommandIOMemo.IOHistory.Lines.add
                                    ('ERROR:  Surface ' +
				    IntToStr (SurfaceOrdinal) +
                                    ' is not specified.')
			      END
			END
		    END
		ELSE
		  BEGIN
		    Q590_CHECK_NEW_FILE (DatafileName, Valid);
		    IF Valid THEN
		      BEGIN
			Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
			IF Valid THEN
			  IF ZBA_SURFACE [SurfaceOrdinal].
			      ZBB_SPECIFIED THEN
			    BEGIN
			      ZFA_OPTION.ZGQ_ALT_OUTPUT_RAY_FILE_NAME :=
				  DatafileName;
			      ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE :=
				  TRUE;
			      ZFA_OPTION.ZGP_REF_SURF_FOR_RAY_WRITE :=
				  SurfaceOrdinal
			    END
			  ELSE
			    BEGIN
			      CommandIOMemo.IOHistory.Lines.add ('');
			      CommandIOMemo.IOHistory.Lines.add
                                  ('ERROR:  Surface ' +
				  IntToStr (SurfaceOrdinal) +
                                  ' is not specified.')
			    END
		      END
		  END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBR_ENABLE_RAY_FILE_READ THEN
	    BEGIN
	      Q505_REQUEST_DATAFILE_NAME (Valid, DatafileName);
	      IF Valid THEN
		BEGIN
		  Q595_CHECK_OLD_FILE (DatafileName, Valid);
		  IF Valid THEN
		    BEGIN
		      ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE := TRUE;
		      ZFA_OPTION.ZGO_ALT_INPUT_RAY_FILE_NAME := DatafileName
		    END
		END
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBP_DISABLE_RAY_FILE THEN
	    BEGIN
	      ZFA_OPTION.ZGE_READ_ALTERNATE_RAY_FILE := FALSE;
	      ZFA_OPTION.ZGN_WRITE_ALTERNATE_RAY_FILE := FALSE
	    END
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBS_ENABLE_ERROR_DISPLAY THEN
	    ZFA_OPTION.ZGR_QUIET_ERRORS := FALSE
	  ELSE
	  IF S01AK_LENGTH_6_RESPONSE = CFBT_DISABLE_ERROR_DISPLAY THEN
	    ZFA_OPTION.ZGR_QUIET_ERRORS := TRUE
          ELSE
          IF S01AK_LENGTH_6_RESPONSE = GET_SEEDS_FOR_RAND_NUMBER_GEN THEN
            SeedRandomNumberGenerator;
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
	HelpTraceOption
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  LADSq2Unit  *************************************************************
*****************************************************************************)


BEGIN

END.

