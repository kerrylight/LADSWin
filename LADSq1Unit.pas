UNIT LADSq1Unit;

INTERFACE

  VAR
      ABB_EXECUTE_TRACE        : BOOLEAN;
      ABZ_ARCHIVE_DATA         : BOOLEAN;

PROCEDURE Q010_REQUEST_COMMAND;
PROCEDURE Q020_REQUEST_SURFACE_COMMAND;
PROCEDURE Q030_REQUEST_RAY_COMMAND;
PROCEDURE Q040_REQUEST_LIST_COMMAND;
PROCEDURE Q041_REQUEST_FULL_OR_BRIEF_LIST
    (VAR Valid, ListFullData : BOOLEAN);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSSurfUnit,
       LADSRayUnit,
       LADSSurfaceOpsUnit,
       LADSRayOpsUnit,
       LADSListUnit,
       LADSData,
       LADSEnvironUnit,
       LADSGlassUnit,
       LADSq2Unit,
       LADSq5bUnit,
       LADSq6Unit,
       LADSq7Unit,
       LADSq8Unit,
       LADSq9Unit,
       LADSInitUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;


(******************************************************************************
*******************************************************************************
*									      *
*									      *
*  The following procedures, which begin with the letter "Q," are where the   *
*  program commands are generated, and where the input responses from the     *
*  user are validated for correctness.	These "Q" procedures are "looped"     *
*  (via the PASCAL "REPEAT UNTIL" construct) until either the user enters a   *
*  correct response (at which point AAO_RESPONSE_IS_VALID is set to TRUE)     *
*  or the user enters a blank (null) response, or the reserved word END.      *
*									      *
*									      *
*******************************************************************************
******************************************************************************)




(**  Q010_REQUEST_COMMAND  ****************************************************
******************************************************************************)

PROCEDURE Q010_REQUEST_COMMAND;

  VAR
      Valid  : BOOLEAN;

BEGIN

  Valid := FALSE;

  ABB_EXECUTE_TRACE        := FALSE;
  ABZ_ARCHIVE_DATA         := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER COMMAND:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Clear;
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER COMMAND:');
	  CommandIOMemo.IOHistory.Lines.add
		('  S .. Surface specification       ' +
	      '  A .. Archive/librarian functions');
	  CommandIOMemo.IOHistory.Lines.add
		('  R .. Ray specification           ' +
	      '  I .. Initialize LADS1 memory');
	  CommandIOMemo.IOHistory.Lines.add
		('  G .. Glass catalog enquiry       ' +
	      '  X .. Optimize surface parameters');
	  CommandIOMemo.IOHistory.Lines.add
		('  E .. Coordinate transformations  ' +
	      '  V .. Version information for LADS1');
	  CommandIOMemo.IOHistory.Lines.add
		('  L .. List surface or ray data    ' +
	      '  Z .. Introductory tutorial for LADS1');
	  CommandIOMemo.IOHistory.Lines.add
		('  O .. Options for ray trace       ' +
	      '  HELP');
	  CommandIOMemo.IOHistory.Lines.add
		('  T .. Trace rays                  ' +
	      '  END');
	  CommandIOMemo.IOHistory.Lines.add
		('  D .. Graphics functions');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CAAA_VALID_LADS_COMMANDS) > 0 THEN
	BEGIN
	  Valid := TRUE;
	  IF S01AH_LENGTH_2_RESPONSE = CAAM_TEACH_LADS THEN
	    TeachLADS
	  ELSE
  	  IF S01AH_LENGTH_2_RESPONSE = CAAN_SET_UP_GRAPHICS THEN
	    Q450_REQUEST_GRAPHICS_COMMAND
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAL_SET_UP_OPTIMIZATION THEN
	    Q400_REQUEST_OPTIMIZATION_DATA
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAB_SET_UP_SURFACE_DATA THEN
	    Q020_REQUEST_SURFACE_COMMAND
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAC_SET_UP_RAY_DATA THEN
	    Q030_REQUEST_RAY_COMMAND
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAD_SET_UP_GLASS_CATALOG THEN
	    I01_SET_UP_GLASS_CATALOG
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAE_SET_UP_ENVIRONMENT THEN
	    H01_SET_UP_ENVIRONMENT
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAF_SET_UP_LIST_PARAMS THEN
	    Q040_REQUEST_LIST_COMMAND
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAG_SET_UP_TRACE_OPTIONS THEN
	    Q050_REQUEST_TRACE_OPTION
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAH_EXECUTE_RAY_TRACE THEN
	    ABB_EXECUTE_TRACE := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAI_ARCHIVE_DATA THEN
	    ABZ_ARCHIVE_DATA := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAJ_INIT_LADS_MEMORY THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
		('ATTENTION: You are about to initialize LADS1' +
	          ' memory.');
	      Q970AB_OUTPUT_STRING :=
		  'Do you wish to initialize LADS1 memory?';
	      Q970_REQUEST_PERMIT_TO_PROCEED;
	      IF Q970AA_OK_TO_PROCEED THEN
		Y005_INITIALIZE_LADS
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CAAK_LIST_VERSION_REPORT THEN
	    BEGIN
              CommandIOMemo.IOHistory.Clear;
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
		('No changes to report.');
	    END
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpLADS
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q020_REQUEST_SURFACE_COMMAND  ********************************************
******************************************************************************)


PROCEDURE Q020_REQUEST_SURFACE_COMMAND;

  VAR
      Valid           : BOOLEAN;

      CODE            : INTEGER;
      SurfaceOrdinal  : INTEGER;

      INTEGER_NUMBER  : LONGINT;

      CommandString   : STRING;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER SURFACE COMMAND:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER SURFACE COMMAND:');
	  CommandIOMemo.IOHistory.Lines.add
		('  N(ew/replace I(nsert D(elete C(opy M(ove' +
	      ' S(leep W(ake R(evise nn');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CBAA_VALID_SURFACE_COMMANDS) > 0 THEN
	BEGIN
	  CommandString := S01AH_LENGTH_2_RESPONSE;
	  IF CommandString = CBAI_REVISE_SURFACE_SPECS THEN
	    BEGIN
	      Q190_REQUEST_SURFACE_ORDINAL (SurfaceOrdinal, Valid);
	      IF Valid THEN
	        BEGIN
		  IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
		    BEGIN
		      Q100_REQUEST_SURFACE_REVISION (SurfaceOrdinal);
		      IF NOT S01AD_END_EXECUTION_DESIRED THEN
		        S01AB_USER_IS_DONE := FALSE;
		    END
		  ELSE
		    BEGIN
		      CommandIOMemo.IOHistory.Lines.add ('');
		      CommandIOMemo.IOHistory.Lines.add
		          ('SURFACE ' + IntToStr (SurfaceOrdinal) +
                          ' NOT DEFINED.' +
		          '  USE "N(ew/replace" TO SPECIFY ' +
			  'SURFACE ' + IntToStr (SurfaceOrdinal) + '.')
		    END
		END
	    END
	  ELSE
	    B01_SET_UP_SURFACE_DATA (CommandString)
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
        HelpSurfaceCommands
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, INTEGER_NUMBER, CODE);
	  IF CODE = 0 THEN
	    IF (INTEGER_NUMBER <= CZAB_MAX_NUMBER_OF_SURFACES)
		AND (INTEGER_NUMBER > 0) THEN
	      BEGIN
		SurfaceOrdinal := INTEGER_NUMBER;
		IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
		  BEGIN
		    Q100_REQUEST_SURFACE_REVISION (SurfaceOrdinal);
		    IF NOT S01AD_END_EXECUTION_DESIRED THEN
		      S01AB_USER_IS_DONE := FALSE
		  END
		ELSE
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		        ('SURFACE ' + IntToStr (SurfaceOrdinal) +
                        ' NOT DEFINED.' +
		        '  USE "N(ew/replace" TO SPECIFY ' +
			'SURFACE ' + IntToStr (SurfaceOrdinal) + '.')
		  END
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  Q030_REQUEST_RAY_COMMAND  ************************************************
******************************************************************************)


PROCEDURE Q030_REQUEST_RAY_COMMAND;

  VAR
      Valid           : BOOLEAN;

      CODE            : INTEGER;
      RayOrdinal      : INTEGER;

      INTEGER_NUMBER  : LONGINT;

      CommandString   : STRING;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER RAY COMMAND:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER RAY COMMAND:');
	  CommandIOMemo.IOHistory.Lines.add
		('  N(ew/replace I(nsert D(elete C(opy M(ove' +
	      ' S(leep W(ake R(evise nnn');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CCAA_VALID_RAY_COMMANDS) > 0 THEN
	BEGIN
	  CommandString := S01AH_LENGTH_2_RESPONSE;
	  IF CommandString = CCAI_REVISE_RAY_SPECS THEN
	    BEGIN
	      Q290_REQUEST_RAY_ORDINAL (RayOrdinal, Valid);
	      IF Valid THEN
	        BEGIN
		  IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
		    BEGIN
		      Q200_REQUEST_RAY_REVISION (RayOrdinal);
		      IF NOT S01AD_END_EXECUTION_DESIRED THEN
		        S01AB_USER_IS_DONE := FALSE
		    END
		  ELSE
		    BEGIN
		      CommandIOMemo.IOHistory.Lines.add ('');
		      CommandIOMemo.IOHistory.Lines.add
		          ('RAY ' + IntToStr (RayOrdinal) + ' NOT DEFINED.' +
		          '  USE "N(ew/replace" TO SPECIFY ' +
			  'RAY ' + IntToStr (RayOrdinal) + '.')
		    END
		END
	    END
	  ELSE
	    C01_SET_UP_RAY_DATA (CommandString)
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpRayCommands
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, INTEGER_NUMBER, CODE);
	  IF CODE = 0 THEN
	    IF (INTEGER_NUMBER <= CZAC_MAX_NUMBER_OF_RAYS)
		AND (INTEGER_NUMBER > 0) THEN
	      BEGIN
		RayOrdinal := INTEGER_NUMBER;
		IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
		  BEGIN
		    Q200_REQUEST_RAY_REVISION (RayOrdinal);
		    IF NOT S01AD_END_EXECUTION_DESIRED THEN
		      S01AB_USER_IS_DONE := FALSE
		  END
		ELSE
		  BEGIN
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		        ('RAY ' + IntToStr (RayOrdinal) + ' NOT DEFINED.' +
		        '  USE "N(ew/replace" TO SPECIFY ' +
			'RAY ' + IntToStr (RayOrdinal) + '.')
		  END
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    S01AB_USER_IS_DONE

END;




(**  Q040_REQUEST_LIST_COMMAND	***********************************************
******************************************************************************)


PROCEDURE Q040_REQUEST_LIST_COMMAND;

  VAR
      Valid         : BOOLEAN;
      NeedPrintout  : BOOLEAN;
      NeedListfile  : BOOLEAN;

      ListfileName  : STRING;
      CommandString : STRING;

BEGIN

  NeedPrintout := FALSE;
  NeedListfile := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'ENTER LIST COMMAND: S(urface R(ay P(rint L(istFile';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER LIST COMMAND: S(urface R(ay P(rint L(istFile');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CDAA_VALID_LIST_COMMANDS) > 0 THEN
	BEGIN
	  IF S01AH_LENGTH_2_RESPONSE = CDAD_PRINTER_OUTPUT_SWITCH THEN
	    IF NeedPrintout THEN
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
		('Printer output disabled.');
		NeedPrintout := FALSE
	      END
	    ELSE
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
		('Printer output enabled.');
		CommandIOMemo.IOHistory.Lines.add
		('Please be sure printer is online.');
		NeedPrintout := TRUE
	      END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CDAE_LISTFILE_OUTPUT_SWITCH THEN
	    IF NeedListfile THEN
	      BEGIN
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
		('List file output disabled.');
		NeedListfile := FALSE
	      END
	    ELSE
	      BEGIN
		Q500_REQUEST_LIST_FILE_NAME (Valid, ListfileName);
		IF Valid THEN
		  BEGIN
		    NeedListfile := TRUE;
		    CommandIOMemo.IOHistory.Lines.add ('');
		    CommandIOMemo.IOHistory.Lines.add
		('List file output enabled.')
		  END
	      END
	  ELSE
	    BEGIN
	      CommandString := S01AH_LENGTH_2_RESPONSE;
	      ListInputData (NeedListfile, NeedPrintout, CommandString,
	          ListfileName)
	    END
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpListCommand
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL S01AB_USER_IS_DONE

END;




(**  Q041_REQUEST_FULL_OR_BRIEF_LIST  *****************************************
******************************************************************************)


PROCEDURE Q041_REQUEST_FULL_OR_BRIEF_LIST;

BEGIN

  Valid        := FALSE;
  ListFullData := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER LIST TYPE: F(ull B(rief';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Lines.add
              ('');
          CommandIOMemo.IOHistory.Lines.add
	      ('ENTER LIST TYPE: F(ull B(rief');
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.Add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CEAA_VALID_LIST_TYPES) > 0 THEN
	BEGIN
	  Valid := TRUE;
	  IF S01AH_LENGTH_2_RESPONSE = CEAB_FULL_LIST_DESIRED THEN
	    ListFullData := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CEAC_BRIEF_LIST_DESIRED THEN
	    ListFullData := FALSE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpFullOrBriefList
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE  

END;



(**  LADSq1Unit  ************************************************************
****************************************************************************)

BEGIN

END.
