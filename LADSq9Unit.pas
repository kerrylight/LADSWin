UNIT LADSq9Unit;

INTERFACE

PROCEDURE Q450_REQUEST_GRAPHICS_COMMAND;
PROCEDURE Q451_REQUEST_SCREEN_ASPECT;
PROCEDURE Q500_REQUEST_LIST_FILE_NAME
    (VAR Valid                     : BOOLEAN;
     VAR ListfileName              : STRING);
PROCEDURE Q505_REQUEST_DATAFILE_NAME
    (VAR Valid                     : BOOLEAN;
     VAR DatafileName              : STRING);
PROCEDURE Q590_CHECK_NEW_FILE
    (DatafileName                  : STRING;
     VAR Valid                     : BOOLEAN);
PROCEDURE Q595_CHECK_OLD_FILE
    (DatafileName                  : STRING;
     VAR Valid                     : BOOLEAN);
PROCEDURE Q950_REQUEST_INTEGER_NUMBER
    (CommandString                 : STRING;
     VAR IntegerNumber             : INTEGER;
     VAR Valid                     : BOOLEAN);
PROCEDURE Q960_REQUEST_REAL_NUMBER
    (CommandString                 : STRING;
     VAR RealNumber                : DOUBLE;
     VAR Valid                     : BOOLEAN);

IMPLEMENTATION

  USES SysUtils,
       EXPERTIO,
       LADSInitUnit,
       LADSData,
       (*LADSF4,*)
       LADSGlassCompUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;


(**  Q450_REQUEST_GRAPHICS_COMMAND  *******************************************
******************************************************************************)


PROCEDURE Q450_REQUEST_GRAPHICS_COMMAND;

  VAR
      Valid              : BOOLEAN;
      
      CommandString      : STRING;

      RealNumber         : DOUBLE;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER GRAPHICS COMMAND:';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER GRAPHICS COMMAND:               Present values');
	  HoldXaspect := Xaspect;
	  HoldYaspect := Yaspect;
	  CommandIOMemo.IOHistory.Lines.add
		('  A .. Aspect ratio ................. ' +
	      FloatToStrF ((HoldXaspect / HoldYaspect), ffFixed, 6, 3));
	  CommandIOMemo.IOHistory.Lines.add
		('  X .. X coordinate of viewport ..... ' +
	      FloatToStrF (ZFA_OPTION.ZGC_VIEWPORT_POSITION_X, ffFixed, 12, 2));
	  CommandIOMemo.IOHistory.Lines.add
		('  Y .. Y coordinate of viewport ..... ' +
	      FloatToStrF (ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y, ffFixed, 12, 2));
	  CommandIOMemo.IOHistory.Lines.add
		('  Z .. Z coordinate of viewport ..... ' +
	      FloatToStrF (ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z, ffFixed, 12, 2));
	  CommandIOMemo.IOHistory.Lines.add
		('  O .. Diameter of viewport ......... ' +
	      FloatToStrF (ZFA_OPTION.ZGL_VIEWPORT_DIAMETER, ffFixed, 12, 2));
	  CommandIOMemo.IOHistory.Lines.add
		('  D .. Draw surfaces');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CVAA_VALID_GRAPHICS_COMMANDS) > 0 THEN
	BEGIN
	  IF S01AH_LENGTH_2_RESPONSE = CVAB_REVISE_SCREEN_ASPECT_RATIO THEN
            Q451_REQUEST_SCREEN_ASPECT
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CVAC_SET_X_COORD THEN
	    BEGIN
	      CommandString := 'ENTER X COORDINATE OF VIEWPORT';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
	        ZFA_OPTION.ZGC_VIEWPORT_POSITION_X := RealNumber
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CVAD_SET_Y_COORD THEN
	    BEGIN
	      CommandString := 'ENTER Y COORDINATE OF VIEWPORT';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
	        ZFA_OPTION.ZGD_VIEWPORT_POSITION_Y := RealNumber
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CVAE_SET_Z_COORD THEN
	    BEGIN
	      CommandString := 'ENTER Z COORDINATE OF VIEWPORT';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
	        ZFA_OPTION.ZRA_VIEWPORT_POSITION_Z := RealNumber
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CVAF_GET_VIEWPORT_DIAMETER THEN
	    BEGIN
	      CommandString := 'ENTER VIEWPORT DIAMETER (> 0)';
	      Q960_REQUEST_REAL_NUMBER (CommandString, RealNumber, Valid);
	      IF Valid THEN
	        IF RealNumber > 0.0 THEN
		  ZFA_OPTION.ZGL_VIEWPORT_DIAMETER := RealNumber
		ELSE
		  Q990_INPUT_ERROR_PROCESSING
            END
          ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CVAG_PICTURE_SURFACES THEN
	    IF ZFA_OPTION.ZGL_VIEWPORT_DIAMETER > 0.0 THEN
  	      (*F105_DRAW_SURFACES*)
	    ELSE
	      BEGIN
	        CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
		('ERROR:  Viewport diameter has not been defined.')
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
	HelpGraphicsCommands
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    S01AB_USER_IS_DONE

END;




(**  Q451_REQUEST_SCREEN_ASPECT  **********************************************
******************************************************************************)


PROCEDURE Q451_REQUEST_SCREEN_ASPECT;

  VAR
      CODE         : INTEGER;

      TempString   : STRING;

      REAL_NUMBER  : DOUBLE;

BEGIN

(*REPEAT
    BEGIN
      IF S01AA_EXPERT_MODE_OFF THEN
        BEGIN
          GraphicsDriver := Detect;
	  InitGraph (GraphicsDriver, GraphicsMode, 'DRIVERS');
	  SetTextJustify (LeftText, TopText);
	  SetColor (GetMaxColor);
	  SetAspectRatio (Xaspect, Yaspect);
	  Circle (GetMaxX DIV 2, GetMaxY DIV 2, GetMaxX DIV 4);
	  MoveTo (10, 20);
	  OutText ('The object shown below should appear circular.');
	  MoveTo (10, 30);
	  OutText ('Current screen aspect ratio is ');
	  HoldXaspect := Xaspect;
	  HoldYaspect := Yaspect;
	  Str ((HoldXaspect / HoldYaspect):6:3, TempString);
	  OutText (TempString);
	  MoveTo (10, (GetMaxY - 30));
	  SetTextJustify (LeftText, BottomText);
	  OutText ('Press enter to continue...');
	  S01_PROCESS_REQUEST;
      CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
	  CloseGraph;
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER NEW VALUE FOR ASPECT RATIO (0.1 .. 2.0)');
	  CommandIOMemo.IOHistory.Lines.add
		('(THE CURRENT VALUE IS ', (HoldXaspect / HoldYaspect):6:3,
	      ')');
	  CommandIOMemo.IOHistory.Lines.add
		('WHEN ASPECT RATIO IS CORRECT, HIT RETURN KEY TO EXIT.');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
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
		('The object displayed should appear circular.  If it');
	  CommandIOMemo.IOHistory.Lines.add
		('does not (i.e., if it appears elliptical), the');
	  CommandIOMemo.IOHistory.Lines.add
		('vertical dimension may be increased or decreased by');
	  CommandIOMemo.IOHistory.Lines.add
		('increasing or decreasing the screen aspect ratio.');
	  CommandIOMemo.IOHistory.Lines.add
		('The new value for the screen aspect ratio will be');
	  CommandIOMemo.IOHistory.Lines.add
		('used by this program when displaying graphics objects.');
	  Q980_REQUEST_MORE_OUTPUT
	END
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, REAL_NUMBER, CODE);
	  IF CODE = 0 THEN
	    IF (REAL_NUMBER >= 0.1)
                AND (REAL_NUMBER <= 2.0) THEN
	      BEGIN
	        Yaspect := 10000;
		Xaspect := Trunc (REAL_NUMBER * 10000.0)
	      END
	    ELSE
	      Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    Q990_INPUT_ERROR_PROCESSING
	END
    END
  UNTIL
    S01AB_USER_IS_DONE*)

END;




(**  Q500_REQUEST_LIST_FILE_NAME  *********************************************
******************************************************************************)


PROCEDURE Q500_REQUEST_LIST_FILE_NAME;

  VAR
      SaveIOResult  : INTEGER;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER TEXT FILE NAME';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER TEXT FILE NAME');
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
		('Please use only exact file name, including file type.');
	  CommandIOMemo.IOHistory.Lines.add
		('No wild card characters should be used.')
	END
      ELSE
	BEGIN
	  ListfileName := S01AF_BLANKS_STRIPPED_RESPONSE_UC;
	  ASSIGN (ZAG_LIST_FILE, ListfileName);
	  {$I-}
	  RESET (ZAG_LIST_FILE);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      {$I-}
	      REWRITE (ZAG_LIST_FILE);
	      {$I+}
	      SaveIOResult := IORESULT;
	      IF SaveIOResult <> 0 THEN
		BEGIN
		  CommandIOMemo.IOHistory.Lines.add ('');
		  CommandIOMemo.IOHistory.Lines.add
		('ERROR:  Attempt to create text file "' +
		      ListfileName + '" failed.');
		  CommandIOMemo.IOHistory.Lines.add
		('(IORESULT is: ' + IntToStr (SaveIOResult) + '.)')
		END
	      ELSE
		BEGIN
		  Valid := TRUE;
		  CLOSE (ZAG_LIST_FILE);
		  ERASE (ZAG_LIST_FILE)
		END
	    END
	  ELSE
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
		('ATTENTION:  File "' + ListfileName +
		  '" already exists.');
	      Q970AB_OUTPUT_STRING :=
		  'Do you wish to over-write the data?';
              Q970_REQUEST_PERMIT_TO_PROCEED;
	      IF Q970AA_OK_TO_PROCEED THEN
		BEGIN
		  {$I-}
		  REWRITE (ZAG_LIST_FILE);
		  {$I+}
		  SaveIOResult := IORESULT;
		  IF SaveIOResult <> 0 THEN
	            BEGIN
		      CommandIOMemo.IOHistory.Lines.add ('');
		      CommandIOMemo.IOHistory.Lines.add
		('ERROR:  Attempt to create text file "' +
			  ListfileName + '" failed.');
		      CommandIOMemo.IOHistory.Lines.add
		('(IORESULT is: ' + IntToStr (SaveIOResult) + '.)')
		    END
		  ELSE
		    BEGIN
		      Valid := TRUE;
		      CLOSE (ZAG_LIST_FILE);
		      ERASE (ZAG_LIST_FILE)
		    END
		END
              ELSE
		CLOSE (ZAG_LIST_FILE)
	    END
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q505_REQUEST_DATAFILE_NAME	 **********************************************
******************************************************************************)


PROCEDURE Q505_REQUEST_DATAFILE_NAME;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER DATA FILE NAME';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('ENTER DATA FILE NAME');
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
		('Please use only exact file name, including file type.');
	  CommandIOMemo.IOHistory.Lines.add
		('No wild card characters should be used.')
	END
      ELSE
	BEGIN
	  DatafileName := S01AF_BLANKS_STRIPPED_RESPONSE_UC;
	  Valid := TRUE
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q590_CHECK_NEW_FILE  *****************************************************
******************************************************************************)


PROCEDURE Q590_CHECK_NEW_FILE;

  VAR
      SaveIOResult  : INTEGER;

BEGIN

  Valid := FALSE;

  ASSIGN (ZAH_DATA_FILE, DatafileName);
  {$I-}
  RESET (ZAH_DATA_FILE);
  {$I+}

  SaveIOResult := IORESULT;

  IF SaveIOResult <> 0 THEN
    BEGIN
      {$I-}
      REWRITE (ZAH_DATA_FILE);
      {$I+}
      SaveIOResult := IORESULT;
      IF SaveIOResult <> 0 THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ERROR:  Attempt to create data file "' +
	      DatafileName + '" failed.');
	  CommandIOMemo.IOHistory.Lines.add
		('(IORESULT is: ' + IntToStr (SaveIOResult) + '.)')
	END
      ELSE
	BEGIN
	  Valid := TRUE;
	  CLOSE (ZAH_DATA_FILE);
	  ERASE (ZAH_DATA_FILE)
	END
    END
  ELSE
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
		('ATTENTION:  File "' + DatafileName +
	  '" already exists.');
      Q970AB_OUTPUT_STRING :=
	  'Do you wish to over-write the data?';
      Q970_REQUEST_PERMIT_TO_PROCEED;
      IF Q970AA_OK_TO_PROCEED THEN
	BEGIN
	  {$I-}
	  REWRITE (ZAH_DATA_FILE);
	  {$I+}
	  SaveIOResult := IORESULT;
	  IF SaveIOResult <> 0 THEN
	    BEGIN
	      CommandIOMemo.IOHistory.Lines.add ('');
	      CommandIOMemo.IOHistory.Lines.add
		('ERROR:  Attempt to create data file "' +
		  DatafileName + '" failed.');
	      CommandIOMemo.IOHistory.Lines.add
		('(IORESULT is: ' + IntToStr (SaveIOResult) + '.)')
	    END
	  ELSE
	    BEGIN
	      Valid := TRUE;
	      CLOSE (ZAH_DATA_FILE);
	      ERASE (ZAH_DATA_FILE)
	    END
	END
      ELSE
	CLOSE (ZAH_DATA_FILE)
    END

END;




(**  Q595_CHECK_OLD_FILE  *****************************************************
******************************************************************************)


PROCEDURE Q595_CHECK_OLD_FILE;

  VAR
      SaveIOResult  : INTEGER;

BEGIN

  Valid := FALSE;

  ASSIGN (ZAH_DATA_FILE, DatafileName);
  {$I-}
  RESET (ZAH_DATA_FILE);
  {$I+}

  SaveIOResult := IORESULT;

  IF SaveIOResult <> 0 THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add
		('ERROR:  Attempt to verify existence of datafile "' +
	  DatafileName + '" failed.');
      CommandIOMemo.IOHistory.Lines.add
		('(IORESULT is: ' + IntToStr (SaveIOResult) + '.)');
      Q980_REQUEST_MORE_OUTPUT
    END
  ELSE
    BEGIN
      CLOSE (ZAH_DATA_FILE);
      Valid := TRUE
    END

END;




(**  Q950_REQUEST_INTEGER_NUMBER  *********************************************
******************************************************************************)


PROCEDURE Q950_REQUEST_INTEGER_NUMBER;

  VAR
      CODE            : INTEGER;

      INTEGER_NUMBER  : LONGINT;

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
      VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, INTEGER_NUMBER, CODE);
      IF CODE = 0 THEN
	BEGIN
	(*CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('INTEGER NUMBER IS: ', INTEGER_NUMBER, '.');*)
	  IntegerNumber := INTEGER_NUMBER;
	  Valid := TRUE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('NO HELP AVAILABLE')
	END
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q960_REQUEST_REAL_NUMBER  ************************************************
******************************************************************************)


PROCEDURE Q960_REQUEST_REAL_NUMBER;

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
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('  Valid response is any numeric value -- positive,');
	  CommandIOMemo.IOHistory.Lines.add
		('  negative, or zero.  Decimal points are not required');
	  CommandIOMemo.IOHistory.Lines.add
		('  for whole numbers.  Floating point numbers may be');
	  CommandIOMemo.IOHistory.Lines.add
		('  entered in scientific notation; for example, the');
	  CommandIOMemo.IOHistory.Lines.add
		('  following are all valid input representations of the');
	  CommandIOMemo.IOHistory.Lines.add
		('  number 350.1:');
	  CommandIOMemo.IOHistory.Lines.add
		('       +35.01E+01  .3501E3   350.1   3.501E+2')
	END
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, RealNumber, CODE);
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




(**  LADSq9Unit  *************************************************************
*****************************************************************************)


BEGIN

END.

