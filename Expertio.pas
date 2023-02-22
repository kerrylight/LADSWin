 (*
	EXPERTIO  -  A unit to provide a sophisticated interface between
		     the user and an interactive program.

	Date: 4 August 1989
	Programmer: Stephen K. Wilcken

	Copyright (c) 1989 Horizon Optical


   This unit qualifies the following procedures for export:
      Q970_REQUEST_PERMIT_TO_PROCEED;
      Q980_REQUEST_MORE_OUTPUT;
      Q990_INPUT_ERROR_PROCESSING;
      S01_PROCESS_REQUEST;
      ResetKeyboardActivity;
      T99_CHECK_KEYBOARD_ACTIVITY;

   This unit qualifies the following variables for export:

      Q970AA_OK_TO_PROCEED		       : BOOLEAN;
      S01AA_EXPERT_MODE_OFF		       : BOOLEAN;
      S01AB_USER_IS_DONE		       : BOOLEAN;
      S01AC_NULL_RESPONSE_GIVEN		       : BOOLEAN;
      S01AD_END_EXECUTION_DESIRED	       : BOOLEAN;
      S01AE_USER_NEEDS_HELP		       : BOOLEAN;
      S01AU_USER_WANTS_BLANK_ENTRY	       : BOOLEAN;
      S01AO_USE_ALTERNATE_INPUT_FILE	       : BOOLEAN;
      S01AP_FORCE_END_OF_LINE		       : BOOLEAN;
      S01AQ_FORCE_END_OF_FILE		       : BOOLEAN;
      S01BH_REWIND_FILE_BEFORE_READ	       : BOOLEAN;
      KeyboardActivityDetected	               : BOOLEAN;
      
      Q970AB_OUTPUT_STRING		       : STRING;
      S01AF_BLANKS_STRIPPED_RESPONSE_UC	       : STRING;
      S01AM_BLANKS_STRIPPED_RESPONSE	       : STRING;
      S01AG_ALTERNATE_INPUT_FILE_NAME	       : STRING;
      S01AH_LENGTH_2_RESPONSE		       : STRING [2];
      S01AI_LENGTH_3_RESPONSE		       : STRING [3];
      S01AJ_LENGTH_4_RESPONSE		       : STRING [4];
      S01AK_LENGTH_6_RESPONSE		       : STRING [6];
      S01AL_LENGTH_11_RESPONSE		       : STRING [11];
      
   We will now explain the meaning of the exported procedures and variables:
      
   Q970_REQUEST_PERMIT_TO_PROCEED -- This commonly used procedure is employed
   when it is desirable to make sure the user wishes to proceed with a
   critical process.  It is the responsibility of the client program to
   supply a message to be displayed by Q970_REQUEST_PERMIT_TO_PROCEED.	This
   message must be contained in the string variable Q970AB_OUTPUT_STRING.
   After the user's message has been displayed, the user will be requested to
   indicate whether or not he desires to proceed with the critical process.
   If the user enters "Y", then the BOOLEAN variable Q970AA_OK_TO_PROCEED
   will be set to TRUE, otherwise Q970AA_OK_TO_PROCEED will be set to FALSE.

      Q970AB_OUTPUT_STRING -- This STRING variable is filled by the client
   program with a message to be displayed by procedure
   Q970_REQUEST_PERMIT_TO_PROCEED.

   Q980_REQUEST_MORE_OUTPUT -- This procedure is used for programming
   convenience.	 When more than one screenful of text is to be displayed,
   then this procedure can be invoked after a maximum of 22 lines of text
   have been written to the terminal.  The effect is to allow the user to
   have sufficient time to read the current contents of the screen before
   more text is displayed.  The user is asked to press the return key when he
   is ready to continue.  If the return key is pressed, then the BOOLEAN
   variable S01AC_NULL_RESPONSE_GIVEN will be set to TRUE, and this procedure
   will be exited.  Otherwise, an invalid response will be flagged, and the
   user will be requested again to hit the return key when he is ready to
   continue.  Since control is passed back to the client procedure after the
   user presses the return key, it is not necessary for the client procedure
   to look at S01AC_NULL_RESPONSE_GIVEN before proceeding with its task.  The
   final two lines of code in this procedure set S01AB_USER_IS_DONE to FALSE
   and S01AD_END_EXECUTION_DESIRED to FALSE.  Thus, this procedure violates
   the otherwise standard rule whereby a blank carriage return always causes
   S01AB_USER_IS_DONE to be set TRUE, or whereby entry of the reserved word
   "end" always causes S01AD_END_EXECUTION_DESIRED to be set TRUE.
   
   Q990_INPUT_ERROR_PROCESSING -- This procedure is invoked when the client
   program detects an error in the user's input data.  The invalid response
   will be displayed on the terminal.  If the invalid response was embedded
   in a long line of input data, then this procedure will indicate that an
   "expert mode" input error has been detected, and will underline that
   portion of the input line that needs to be reentered.

   S01_PROCESS_REQUEST -- This procedure constitutes the main body of the
   code for EXPERTIO.  S01_PROCESS_REQUEST is a general input parsing routine
   for interactive programs.  The interactive client program will call
   S01_PROCESS_REQUEST, rather than READ or READLN, whenever input is needed.
   S01_PROCESS_REQUEST parses the user's input line via the rules described
   below, and returns a single input entity to the client program.  Within
   S01_PROCESS_REQUEST, actual calls to READLN are made when all input
   entities from the previous line of input have been exhausted.  EXPERTIO,
   via S01_PROCESS_REQUEST, makes each input entity available to the client
   program in a variety of useful forms (to be described below).  In
   addition, EXPERTIO provides ASCII-to-INTEGER and ASCII-to-REAL data
   conversion routines, with BOOLEAN variables indicating the success of the
   conversion.	Thus, numeric data input validation may be performed by the
   client program without risk of run-time errors resulting from non-
   numeric input data.	S01_PROCESS_REQUEST parses a line of input according
   to the following rules:

	I.)  A line of input consists of a sequence of ASCII characters
	     terminated by a carriage return character.	 In fact,
	     S01_PROCESS_REQUEST obtains a line of input by a simple
	     call to READLN (var), where var is of type STRING.
       II.)  Input may consist of quoted and/or unquoted data items.
	     Both quoted and unquoted data items may appear on the same input
	     line.
      III.)  Spaces and commas delimit data items; the quote character (")
	     further delimits quoted data items.
	     A.)  Quoted data consists of text which begins with a quote
		  character (") and ends with: (1) a quote character followed
		  by a space; (2) a quote character followed by a carriage
		  return; or (3) a carriage return with no terminating
		  quote mark.
	     B.)  If a quote character is required as input data, two quote
		  characters must be used together.  For example, the
		  following text
			     "This is a quote mark: """
		  will be interpreted as
			     This is a quote mark: "
		  After EXPERTIO has detected the initial quote character,
		  subsequent single quote marks, when followed by a non-blank
		  character, will be ignored.  The following text
			     "Now is the time f"or all "good men"
		  will be returned to the client program as
			     Now is the time for all good men
	     C.)  Spaces and commas are preserved as input data if they occur
		  inside a quoted data item.
       IV.)  When used as data item delimiters, spaces and commas obey
	     the following rules:
	     A.)  One or more preceeding and following spaces may be
		  used to delimit a quoted or unquoted data item.
		  (Preceeding spaces are not required at the beginning
		  of a new line.)
	     B.)  A single comma (with optional preceeding and following
		  spaces) may be used to delimit a quoted or unquoted
		  data item from another quoted or unquoted data item.
	     C.)  One or more commas appearing as the first character of
		  text or the final character of text on a line of input
		  will cause EXPERTIO to assert the BOOLEAN variables
		  S01AB_USER_IS_DONE and S01AC_NULL_RESPONSE_GIVEN
		  (described below).  The client program may interpret
		  this condition as being equivalent to a blank carriage
		  return.  Two or more commas appearing between data
		  items will have the same effect, and will cause one or
		  more null responses to be generated.	If the client
		  program uses null inputs to ascend from lower levels
		  of a tree-structure to higher levels, this capability
		  of allowing null inputs to be imbedded in the input
		  line may be very useful for providing the means for
		  the adept ("expert") user to migrate throughout the
		  entire range of the input data space while reducing
		  the frequency of BIOS "hits," thus minimizing the wait
		  time associated with input processing in a time-shared
		  environment.
		      
   In addition to the input parsing feature described above, EXPERTIO also
   provides a "batch" processing mode, described below.	 The batch processing
   mode allows input to be retrieved from up to three concurrent input files.

   Procedure S01_PROCESS_REQUEST modifies the following variables
   according to the following rules:
      
      S01AA_EXPERT_MODE_OFF -- After procedure S01_PROCESS_REQUEST has
   retrieved a data input entity, either from the present line of input, or
   from a new line, and before control is passed back to the client program,
   a procedure (internal to S01_PROCESS_REQUEST) is executed to find the
   starting location for the next input entity on the present line of user
   input.  If there are no further input entities on the present input line,
   then the BOOLEAN variable S01AA_EXPERT_MODE_OFF is set TRUE.	 The client
   procedure, therefore, can check S01AA_EXPERT_MODE_OFF to determine whether
   or not it is appropriate to issue an input command to the user in
   preparation to receive the next input entity, based on the TRUE/FALSE
   status of S01AA_EXPERT_MODE_OFF.  If S01AA_EXPERT_MODE_OFF is FALSE, then
   it will usually be inappropriate for the client procedure to issue an
   input command to the user, since the user has apparently anticipated the
   next command and has already entered the required response, which is
   available as the next input entity on the present input line.  This next
   input entity is retrievable by the very next call to S01_PROCESS_REQUEST.

      S01AB_USER_IS_DONE -- This BOOLEAN variable is set TRUE if the user
   enters either the reserved word "end" or a blank entry.

      S01AC_NULL_RESPONSE_GIVEN -- This BOOLEAN variable is set TRUE if the
   user enters a blank entry.
      
      S01AD_END_EXECUTION_DESIRED -- This BOOLEAN variable is set TRUE if the
   user enters the reserved word "end".
      
      S01AE_USER_NEEDS_HELP -- This BOOLEAN variable is set TRUE if the user
   enters the reserved word "help".
      
      S01AU_USER_WANTS_BLANK_ENTRY -- This BOOLEAN variable is set TRUE if the
   user enters a hyphen ("-").	The user response, containing a hyphen, will
   be passed back to the client procedure.  However, the client program
   should be ready to observe the condition of S01AU_USER_WANTS_BLANK_ENTRY
   before accepting the actual contents of the user response.

      S01AO_USE_ALTERNATE_INPUT_FILE -- This BOOLEAN variable is set TRUE by
   the client program when it is necessary to pickup ASCII input (program
   commands, input data, etc.) from a source, or sources, other than the
   default input device (e.g., the system terminal).  This BOOLEAN variable
   will remain TRUE until EOF is reached on the alternate input file(s).
   (The alternate input file name is also supplied by the client program.
   See description of S01AG_ALTENATE_INPUT_FILE_NAME given below.)  When EOF
   is reached on the alternate input file(s), EXPERTIO will reset
   S01AO_USE_ALTERNATE_INPUT_FILE to FALSE.  EXPERTIO performs context
   switching on the input processing environment, as soon as
   S01AO_USE_ALTERNATE_INPUT_FILE is asserted TRUE. This means that the
   remaining (yet-unprocessed) contents of the present input from the system
   terminal, as well as all affected pointers, will be saved until EOF is
   reached on the alternate input file(s).  The processing context for input
   from the system terminal will then be restored.  It is possible to have a
   maximum of 3 alternate input files open at any one time.  Processing of
   input data and/or commands from the alternate input files occurrs in a
   nested fashion: the last-opened file will be processed until EOF is
   encountered, at which time the processing context of the previously opened
   file will be restored, and processing continued until EOF, etc.
   
      S01AP_FORCE_END_OF_LINE -- This BOOLEAN variable is set TRUE by the
   client program.  This causes EXPERTIO to ignore any further input data
   items on the present line of input, and will force an immediate file read
   on the present file being processed (either keyboard input, or from an
   alternate input file).  EXPERTIO immediately sets S01AP_FORCE_END_OF_LINE
   to FALSE, as soon as a new input line has been obtained.  If an alternate
   file is being processed, and if the forced file read causes EOF to be
   asserted TRUE, then context switching will occur so as to restore the
   processing environment associated with the previous input source.

      S01AQ_FORCE_END_OF_FILE -- This BOOLEAN variable is set TRUE by the
   client program.  This causes EXPERTIO to ignore any further input from
   the current alternate input line, and to issue a CLOSE command on the
   alternate input file.  The processing context for the previous nested file
   (or for interactive input) will then be restored.
   
      S01BH_REWIND_FILE_BEFORE_READ -- This BOOLEAN variable is set TRUE by
   the client program.	This causes EXPERTIO to ignore any further input
   from the current alternate input line, and to immediately CLOSE and then
   RESET the current alternate input file.  This has the effect of resetting
   the file pointers to BOF.  The first input entity from the first record of
   the "rewound" alternate input file will then be retrieved by EXPERTIO, and
   made available to the client program.  S01BH_REWIND_FILE_BEFORE_READ is
   immediately set FALSE by EXPERTIO.
      
      S01AM_BLANKS_STRIPPED_RESPONSE -- This variable is defined as an 80-
   character STRING variable.  The user response is placed left-justified in
   this string.	 The length of this string variable will be exactly equal to
   the number of non-blank characters entered by the user; i.e., there is no
   blank-padding on the right.
   
      S01AF_BLANKS_STRIPPED_RESPONSE_UC -- This variable is defined as an 80-
   character STRING variable.  The user response, converted to upper case,
   is placed left-justified in this string.  The length of this string
   variable will be exactly equal to the number of non-blank characters
   entered by the user; i.e., there is no blank-padding on the right.
      
      S01AG_ALTERNATE_INPUT_FILE_NAME -- This string variable is defined
   by the client program, and should include ".TEXT" as the file type.	An 
   error will result if the client program needs simultaneous input from 
   more than 3 files at any one time.
      
      S01AH_LENGTH_2_RESPONSE	: STRING [2];
      S01AI_LENGTH_3_RESPONSE	: STRING [3];
      S01AJ_LENGTH_4_RESPONSE	: STRING [4];
      S01AK_LENGTH_6_RESPONSE	: STRING [6];
      S01AL_LENGTH_11_RESPONSE	: STRING [11]; -- These STRING variables
   contain the user response, converted to upper case, left-justified and
   padded with a single blank on the right.  This allows the standard
   PASCAL function POS to detect the occurrence of this string among a
   number of possible valid responses as contained in a CONST string
   constant.  For example, if the user enters the response "dx", then the
   value "DX " will be contained in STRING variable S01AI_LENGTH_3_RESPONSE.
   If the string constant is "AA CD DX CP ", then the POS function will
   detect an occurrence of S01AI_LENGTH_3_RESPONSE within the string
   constant.  This is a convenient way to validate commands entered by
   the user against a set of possible valid commands.
   
   T99_CHECK_KEYBOARD_ACTIVITY -- This procedure allows the client program
   to check whether or not there has been any activity on the system keyboard
   since the previous call to this procedure.  A local (to EXPERTIO) integer
   variable stores a count of characters waiting to be read, as obtained via
   a call to UNITSTATUS.  The number of characters waiting, as obtained via
   the most recent call to UNITSTATUS, is compared to the previous value held
   in the local integer variable.  If the two values are different, keyboard
   activity must have occurred since the previous call to this procedure. The
   results of this comparion are made available to the client procedure via
   the BOOLEAN variable KeyboardActivityDetected.  It is necessary
   that the client procedure access ResetKeyboardActivity at least
   twice; the results of the first call will be to simply initialize the
   local characters-waiting variable; further calls to this procedure
   will then produce the desired result in terms of the current status of the
   BOOLEAN variable KeyboardActivityDetected.

*)


UNIT EXPERTIO;

INTERFACE

  VAR
      Q970AA_OK_TO_PROCEED		       : BOOLEAN;
      S01AA_EXPERT_MODE_OFF		       : BOOLEAN;
      S01AB_USER_IS_DONE		       : BOOLEAN;
      S01AC_NULL_RESPONSE_GIVEN		       : BOOLEAN;
      S01AD_END_EXECUTION_DESIRED	       : BOOLEAN;
      S01AE_USER_NEEDS_HELP		       : BOOLEAN;
      S01AU_USER_WANTS_BLANK_ENTRY	       : BOOLEAN;
      S01AO_USE_ALTERNATE_INPUT_FILE	       : BOOLEAN;
      S01BK_INPUT_IS_FROM_KEYBOARD             : BOOLEAN;
      S01AP_FORCE_END_OF_LINE		       : BOOLEAN;
      S01AQ_FORCE_END_OF_FILE		       : BOOLEAN;
      S01BH_REWIND_FILE_BEFORE_READ	       : BOOLEAN;
      KeyboardActivityDetected	               : BOOLEAN;
      CalledFromGUI                            : BOOLEAN;
      IntegerFound                             : BOOLEAN;
      LongIntegerFound                         : BOOLEAN;
      RealNumberFound                          : BOOLEAN;

      T99AB_CHARACTERS_WAITING		       : ARRAY [1..30] OF INTEGER;
      T99AC_PREVIOUS_CHARACTERS_WAITING	       : INTEGER;
      IntegerNumber                            : INTEGER;

      LongIntegerNumber                        : LONGINT;

      RealNumber                               : DOUBLE;

      S01BB_INPUT_AREA			       : STRING [255];
      Q970AB_OUTPUT_STRING		       : STRING [255];
      S01AF_BLANKS_STRIPPED_RESPONSE_UC	       : STRING [255];
      S01AM_BLANKS_STRIPPED_RESPONSE	       : STRING [255];
      S01AG_ALTERNATE_INPUT_FILE_NAME	       : STRING [255];
      S01AH_LENGTH_2_RESPONSE		       : STRING [2];
      S01AI_LENGTH_3_RESPONSE		       : STRING [3];
      S01AJ_LENGTH_4_RESPONSE		       : STRING [4];
      S01AK_LENGTH_6_RESPONSE		       : STRING [6];
      S01AL_LENGTH_11_RESPONSE		       : STRING [11];

PROCEDURE Q970_REQUEST_PERMIT_TO_PROCEED;
PROCEDURE Q980_REQUEST_MORE_OUTPUT;
PROCEDURE Q990_INPUT_ERROR_PROCESSING;
PROCEDURE S01_PROCESS_REQUEST;
PROCEDURE ResetKeyboardActivity;
PROCEDURE T99_CHECK_KEYBOARD_ACTIVITY;
PROCEDURE Z01_INITIALIZE;

IMPLEMENTATION

  USES Forms,
       SysUtils,
       LADSCommandIOMemoUnit,
       LADSCommandIOdlgUnit;

  CONST
      S01BI_INPUT_HOLD_AREA_SIZE = 255;
      S01BJ_MAX_CONTEXT_LEVELS	 = 3;

  VAR
      S01AN_NO_MORE_INPUT_THIS_LINE	       : BOOLEAN;
      S01AR_INPUT_DATA_ENCOUNTERED	       : BOOLEAN;
      S01AS_DATA_ENTITY_OBTAINED	       : BOOLEAN;
      S01AT_PROCESSING_QUOTED_STRING	       : BOOLEAN;

      I					       : INTEGER;
      S01AV_COMMA_COUNT			       : INTEGER;
      S01AW_INPUT_INDEX			       : INTEGER;
      S01AX_RESPONSE_INDEX		       : INTEGER;
      S01AY_CHARACTER_COUNT		       : INTEGER;
      S01AZ_CHARACTER_ORDINAL		       : INTEGER;
      S01BA_LAST_INPUT_INDEX		       : INTEGER;
      S01BL_HOLD_CHARS_WAITING		       : INTEGER;
      ValCode                                  : INTEGER;

    (*S01BB_INPUT_AREA			       : STRING [255];*)
      S01BC_USER_RESPONSE		       : STRING [255];
      S01BD_USER_RESPONSE_UPPER_CASE	       : STRING [255];
      S01BE_SPACE_LINE			       : STRING [255];
      S01BF_ONE_CHAR			       : STRING [1];

      (*  THE FOLLOWING VARIABLES ARE USED FOR CONTEXT SWITCHING  *)
      (*  The context data has the following meaning.  S01CG_INPUT_FILE_NAME
	  is the name of the file that is presently supplying input.  The
	  variables that begin with "SAVE" refer to the activity that has
	  been suspended while input is being retrieved from
	  S01CG_INPUT_FILE_NAME.  When EOF on S01CG_INPUT_FILE_NAME occurs,
	  then the data stored in the "SAVE" variables will be placed back
	  in active use. *)
      
      S01BG_ALTERNATE_FILE		       : FILE OF CHAR;

      S01CA_CURRENT_CONTEXT		       : ARRAY
	  [1..S01BJ_MAX_CONTEXT_LEVELS] OF RECORD
	S01CB_SAVE_INPUT_AREA_FULLY_SCANNED    : BOOLEAN;
	S01CC_SAVE_INPUT_INDEX		       : INTEGER;
	S01CD_SAVE_COMMA_COUNT		       : INTEGER;
	S01CE_SAVE_INPUT_AREA		       : STRING [255];
	S01CG_INPUT_FILE_NAME		       : STRING
      END;
      
      S01CX1_INTERNAL_FILE_1		       : TEXT;
      S01CX2_INTERNAL_FILE_2		       : TEXT;
      S01CX3_INTERNAL_FILE_3		       : TEXT;
      
      S01CZ_WORKING_LEVEL		       : INTEGER;


(**  Q970_REQUEST_PERMIT_TO_PROCEED  ******************************************
******************************************************************************)


PROCEDURE Q970_REQUEST_PERMIT_TO_PROCEED;

  VAR
      Q970AC_RESPONSE_IS_VALID	: BOOLEAN;

      LineCount                 : INTEGER;

BEGIN

  Q970AA_OK_TO_PROCEED := FALSE;
  Q970AC_RESPONSE_IS_VALID := FALSE;
  
  REPEAT
    BEGIN
      CommandIOdlg.Caption := Q970AB_OUTPUT_STRING + '  (Y or N)';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
              (Q970AB_OUTPUT_STRING + '  (Y or N)')
	END;
      S01_PROCESS_REQUEST;
      LineCount := CommandIOMemo.IOHistory.Lines.Count;
      CommandIOMemo.IOHistory.Lines [LineCount - 1] :=
          CommandIOMemo.IOHistory.Lines [LineCount - 1] +
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AF_BLANKS_STRIPPED_RESPONSE_UC = 'Y' THEN
	BEGIN
	  Q970AA_OK_TO_PROCEED := TRUE;
	  Q970AC_RESPONSE_IS_VALID := TRUE
	END
      ELSE
      IF S01AF_BLANKS_STRIPPED_RESPONSE_UC = 'N' THEN
	Q970AC_RESPONSE_IS_VALID := TRUE
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('Valid responses are:');
	  CommandIOMemo.IOHistory.Lines.add
              ('  Y, y   Proceed with execution of present command.');
	  CommandIOMemo.IOHistory.Lines.add
              ('  N, n   Abort present command, with no further action.')
	END
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Q970AC_RESPONSE_IS_VALID
    OR S01AB_USER_IS_DONE

END;




(**  Q980_REQUEST_MORE_OUTPUT  ************************************************
******************************************************************************)


PROCEDURE Q980_REQUEST_MORE_OUTPUT;

  VAR
      LineCount  : INTEGER;

BEGIN

  REPEAT
    BEGIN
      CommandIOdlg.Caption := '     ...Press ENTER key to continue';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
        BEGIN
          CommandIOMemo.IOHistory.Lines.add
	      ('     ...Press ENTER key to continue')
        END;
      S01_PROCESS_REQUEST;
      LineCount := CommandIOMemo.IOHistory.Lines.Count;
      CommandIOMemo.IOHistory.Lines [LineCount - 1] :=
          CommandIOMemo.IOHistory.Lines [LineCount - 1] +
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF NOT S01AC_NULL_RESPONSE_GIVEN THEN
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    S01AC_NULL_RESPONSE_GIVEN;

  S01AB_USER_IS_DONE := FALSE;
  S01AD_END_EXECUTION_DESIRED := FALSE

END;




(**  Q990_INPUT_ERROR_PROCESSING  *********************************************
******************************************************************************)


PROCEDURE Q990_INPUT_ERROR_PROCESSING;

  VAR
      Q990AA_TEMP_STRING  : STRING [255];

      I  : INTEGER;

BEGIN

  (* The following 2 lines inserts a code into the output line which causes
     a beep to sound on the computer.
  Q990AA_TEMP_STRING := ' ';
  Q990AA_TEMP_STRING [1] := CHR (07);*)

  Q990AA_TEMP_STRING := '';

  IF S01AA_EXPERT_MODE_OFF THEN
    BEGIN
      Q990AA_TEMP_STRING := CONCAT (Q990AA_TEMP_STRING,
	  'INVALID_RESPONSE: >', S01AF_BLANKS_STRIPPED_RESPONSE_UC, '<');
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add (Q990AA_TEMP_STRING)
    END
  ELSE
    BEGIN
      S01AA_EXPERT_MODE_OFF := TRUE;
      S01AN_NO_MORE_INPUT_THIS_LINE := TRUE;
      S01AV_COMMA_COUNT := 0;
      FOR I := 1 TO (S01BA_LAST_INPUT_INDEX - 1) DO
	Q990AA_TEMP_STRING := CONCAT (Q990AA_TEMP_STRING, ' ');
      Q990AA_TEMP_STRING := CONCAT (Q990AA_TEMP_STRING, '^');
      FOR I := (S01BA_LAST_INPUT_INDEX + 1) TO LENGTH (S01BB_INPUT_AREA) DO
	Q990AA_TEMP_STRING := CONCAT (Q990AA_TEMP_STRING, '?');
      CommandIOMemo.IOHistory.Lines.add ('');
      CommandIOMemo.IOHistory.Lines.add (S01BB_INPUT_AREA);
      CommandIOMemo.IOHistory.Lines.add (Q990AA_TEMP_STRING);
      CommandIOMemo.IOHistory.Lines.add
          ('Error in expert-mode input.  Please re-enter, starting' +
	  ' at "^".')
    END;
    
  ResetKeyboardActivity;
  
  CommandIOMemo.IOHistory.Lines.add
      ('                            -->  -->  -->  -->  ' +
      'Press SPACE BAR to continue...')

END;




(**  S01_PROCESS_REQUEST  *****************************************************
*******************************************************************************
*									      *
*  Note:  S01_PROCESS_REQUEST is the only entry point into the "S" procedures *
*  which comprise the general input parsing routine.			      *
*									      *
******************************************************************************)


PROCEDURE S01_PROCESS_REQUEST;

  VAR
      I  : INTEGER;
      
PROCEDURE S22_PREPROCESS_ALTERNATE_INPUT;		  FORWARD;
PROCEDURE S25_READ_INPUT_FILE;				  FORWARD;
PROCEDURE S30_READ_ALTERNATE_FILE;			  FORWARD;
PROCEDURE S35_READ_INTERACTIVE_RESPONSE;		  FORWARD;
PROCEDURE S99_INITIALIZE_FOR_NEW_INPUT;			  FORWARD;


(**  S05_PROCESS_INPUT_STRING  ************************************************
******************************************************************************)


PROCEDURE S05_PROCESS_INPUT_STRING;

BEGIN

  S01AX_RESPONSE_INDEX := 1;
  S01AS_DATA_ENTITY_OBTAINED := FALSE;
  
  REPEAT
    IF S01AT_PROCESSING_QUOTED_STRING THEN
      BEGIN
	IF S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = '"' THEN
	  BEGIN
	    S01AW_INPUT_INDEX := S01AW_INPUT_INDEX + 1;
	    IF (S01AW_INPUT_INDEX > S01BI_INPUT_HOLD_AREA_SIZE)
		OR (S01AW_INPUT_INDEX > LENGTH (S01BB_INPUT_AREA)) THEN
	      S01AN_NO_MORE_INPUT_THIS_LINE := TRUE
	    ELSE
	      IF S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = '"' THEN
		BEGIN
		  S01BC_USER_RESPONSE [S01AX_RESPONSE_INDEX] :=
			  S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
		  S01BD_USER_RESPONSE_UPPER_CASE [S01AX_RESPONSE_INDEX] :=
			  S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
		  S01AY_CHARACTER_COUNT := S01AX_RESPONSE_INDEX;
		  S01AX_RESPONSE_INDEX := S01AX_RESPONSE_INDEX + 1
		END
	      ELSE
	      IF (S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ' ')
		  OR (S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ',') THEN
		BEGIN
		  S01AS_DATA_ENTITY_OBTAINED := TRUE;
		  IF S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ',' THEN
		    S01AV_COMMA_COUNT := S01AV_COMMA_COUNT + 1
		END
	      ELSE
		BEGIN
		  S01BC_USER_RESPONSE [S01AX_RESPONSE_INDEX] :=
			  S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
		  S01BD_USER_RESPONSE_UPPER_CASE [S01AX_RESPONSE_INDEX] :=
			  S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
		  S01AZ_CHARACTER_ORDINAL :=
			  ORD (S01BC_USER_RESPONSE [S01AX_RESPONSE_INDEX]);
		  IF ((S01AZ_CHARACTER_ORDINAL > 96)
		      AND (S01AZ_CHARACTER_ORDINAL < 123)) THEN
		    BEGIN
		      S01AZ_CHARACTER_ORDINAL := S01AZ_CHARACTER_ORDINAL - 32;
		      S01BD_USER_RESPONSE_UPPER_CASE [S01AX_RESPONSE_INDEX] :=
			      ansichar (CHAR (S01AZ_CHARACTER_ORDINAL))
		    END;
		  S01AY_CHARACTER_COUNT := S01AX_RESPONSE_INDEX;
		  S01AX_RESPONSE_INDEX := S01AX_RESPONSE_INDEX + 1
		END
	  END
	ELSE
	  BEGIN
	    S01BC_USER_RESPONSE [S01AX_RESPONSE_INDEX] :=
		    S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
	    S01BD_USER_RESPONSE_UPPER_CASE [S01AX_RESPONSE_INDEX] :=
		    S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
	    S01AZ_CHARACTER_ORDINAL :=
		    ORD (S01BC_USER_RESPONSE [S01AX_RESPONSE_INDEX]);
	    IF ((S01AZ_CHARACTER_ORDINAL > 96)
		AND (S01AZ_CHARACTER_ORDINAL < 123)) THEN
	      BEGIN
		S01AZ_CHARACTER_ORDINAL := S01AZ_CHARACTER_ORDINAL - 32;
		S01BD_USER_RESPONSE_UPPER_CASE [S01AX_RESPONSE_INDEX] :=
			ansichar (CHAR (S01AZ_CHARACTER_ORDINAL))
	      END;
	    S01AY_CHARACTER_COUNT := S01AX_RESPONSE_INDEX;
	    S01AX_RESPONSE_INDEX := S01AX_RESPONSE_INDEX + 1
	  END;
	S01AW_INPUT_INDEX := S01AW_INPUT_INDEX + 1;
	IF (S01AW_INPUT_INDEX > S01BI_INPUT_HOLD_AREA_SIZE)
	    OR (S01AW_INPUT_INDEX > LENGTH (S01BB_INPUT_AREA)) THEN
	  S01AN_NO_MORE_INPUT_THIS_LINE := TRUE
      END
    ELSE
      BEGIN
	IF (S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ',')
	    OR (S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ' ') THEN
	  BEGIN
	    S01AS_DATA_ENTITY_OBTAINED := TRUE;
	    IF S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ',' THEN
	      S01AV_COMMA_COUNT := S01AV_COMMA_COUNT + 1
	  END
	ELSE
	  BEGIN
	    S01BC_USER_RESPONSE [S01AX_RESPONSE_INDEX] :=
		    S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
	    S01BD_USER_RESPONSE_UPPER_CASE [S01AX_RESPONSE_INDEX] :=
		    S01BB_INPUT_AREA [S01AW_INPUT_INDEX];
	    S01AZ_CHARACTER_ORDINAL :=
		    ORD (S01BC_USER_RESPONSE [S01AX_RESPONSE_INDEX]);
	    IF ((S01AZ_CHARACTER_ORDINAL > 96)
		AND (S01AZ_CHARACTER_ORDINAL < 123)) THEN
	      BEGIN
		S01AZ_CHARACTER_ORDINAL := S01AZ_CHARACTER_ORDINAL - 32;
		S01BD_USER_RESPONSE_UPPER_CASE [S01AX_RESPONSE_INDEX] :=
			ansichar (CHAR (S01AZ_CHARACTER_ORDINAL))
	      END;
	    S01AY_CHARACTER_COUNT := S01AX_RESPONSE_INDEX;
	    S01AX_RESPONSE_INDEX := S01AX_RESPONSE_INDEX + 1
	  END;
	S01AW_INPUT_INDEX := S01AW_INPUT_INDEX + 1;
	IF (S01AW_INPUT_INDEX > S01BI_INPUT_HOLD_AREA_SIZE) OR
		(S01AW_INPUT_INDEX > LENGTH (S01BB_INPUT_AREA)) THEN
	  S01AN_NO_MORE_INPUT_THIS_LINE := TRUE
      END
  UNTIL
    S01AS_DATA_ENTITY_OBTAINED
    OR S01AN_NO_MORE_INPUT_THIS_LINE

END;




(**  S20_FIND_NEXT_DATA_ENTITY	***********************************************
******************************************************************************)


PROCEDURE S20_FIND_NEXT_DATA_ENTITY;

BEGIN

  S01AN_NO_MORE_INPUT_THIS_LINE := FALSE;
  S01AR_INPUT_DATA_ENCOUNTERED := FALSE;
  
  REPEAT
    IF S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ' ' THEN
      BEGIN
	S01AW_INPUT_INDEX := S01AW_INPUT_INDEX + 1;
	IF (S01AW_INPUT_INDEX > S01BI_INPUT_HOLD_AREA_SIZE)
	    OR (S01AW_INPUT_INDEX > LENGTH (S01BB_INPUT_AREA)) THEN
	  BEGIN
	    S01AN_NO_MORE_INPUT_THIS_LINE := TRUE;
	    S01AV_COMMA_COUNT := 0
	  END
      END
    ELSE
    IF S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = ',' THEN
      BEGIN
	IF S01AV_COMMA_COUNT = 0 THEN
	  BEGIN
	    S01AW_INPUT_INDEX := S01AW_INPUT_INDEX + 1;
	    IF (S01AW_INPUT_INDEX > S01BI_INPUT_HOLD_AREA_SIZE)
		OR (S01AW_INPUT_INDEX > LENGTH (S01BB_INPUT_AREA)) THEN
	      S01AN_NO_MORE_INPUT_THIS_LINE := TRUE
	  END
	ELSE
	  BEGIN
	    S01AR_INPUT_DATA_ENCOUNTERED := TRUE;
	    S01AT_PROCESSING_QUOTED_STRING := FALSE
	  END;
	S01AV_COMMA_COUNT := S01AV_COMMA_COUNT + 1
      END
    ELSE
      BEGIN
	S01AV_COMMA_COUNT := 0;
	S01AR_INPUT_DATA_ENCOUNTERED := TRUE;
	IF S01BB_INPUT_AREA [S01AW_INPUT_INDEX] = '"' THEN
	  BEGIN
	    S01AT_PROCESSING_QUOTED_STRING := TRUE;
	    S01AW_INPUT_INDEX := S01AW_INPUT_INDEX + 1;
	    IF (S01AW_INPUT_INDEX > S01BI_INPUT_HOLD_AREA_SIZE)
		OR (S01AW_INPUT_INDEX > LENGTH (S01BB_INPUT_AREA)) THEN
	      S01AN_NO_MORE_INPUT_THIS_LINE := TRUE
	  END
	ELSE
	  S01AT_PROCESSING_QUOTED_STRING := FALSE
      END
  UNTIL
    S01AR_INPUT_DATA_ENCOUNTERED
    OR S01AN_NO_MORE_INPUT_THIS_LINE
    
END;




(**  S22_PREPROCESS_ALTERNATE_INPUT  ******************************************
******************************************************************************)


PROCEDURE S22_PREPROCESS_ALTERNATE_INPUT;

  VAR
      S22AA_IO_ERROR		       : BOOLEAN;
      S22AB_SPECIFIED_FILE_IN_PROCESS  : BOOLEAN;


(**  S2205_OPEN_ALTERNATE_INPUT_FILE  *****************************************
******************************************************************************)


PROCEDURE S2205_OPEN_ALTERNATE_INPUT_FILE;

BEGIN

  S22AA_IO_ERROR := FALSE;
  
  IF S01CZ_WORKING_LEVEL = 1 THEN
    BEGIN
      ASSIGN (S01CX1_INTERNAL_FILE_1, S01AG_ALTERNATE_INPUT_FILE_NAME);
      {$I-}
      RESET (S01CX1_INTERNAL_FILE_1)
      {$I+}
    END
  ELSE
  IF S01CZ_WORKING_LEVEL = 2 THEN
    BEGIN
      ASSIGN (S01CX2_INTERNAL_FILE_2, S01AG_ALTERNATE_INPUT_FILE_NAME);
      {$I-}
      RESET (S01CX2_INTERNAL_FILE_2)
      {$I+}
    END
  ELSE
  IF S01CZ_WORKING_LEVEL = 3 THEN
    BEGIN
      ASSIGN (S01CX3_INTERNAL_FILE_3, S01AG_ALTERNATE_INPUT_FILE_NAME);
      {$I-}
      RESET (S01CX3_INTERNAL_FILE_3)
      {$I+}
    END;
  
  IF IORESULT <> 0 THEN
    BEGIN
      I := IORESULT;
      S22AA_IO_ERROR := TRUE
(*    CommandIOMemo.IOHistory.Lines.add
          ('ATTENTION:  Could not access alternate input file "' +
	  S01AG_ALTERNATE_INPUT_FILE_NAME, '".');
      CommandIOMemo.IOHistory.Lines.add ('(IORESULT is: ', I, '.)');
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
	CommandIOMemo.IOHistory.Lines.add ('Reverting to keyboard input... >')*)
    END
  
END;




(**  S2210_SAVE_PREVIOUS_CONTEXT  *********************************************
******************************************************************************)


PROCEDURE S2210_SAVE_PREVIOUS_CONTEXT;

BEGIN

  S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].S01CG_INPUT_FILE_NAME :=
      S01AG_ALTERNATE_INPUT_FILE_NAME;
  
  S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
      S01CE_SAVE_INPUT_AREA := S01BB_INPUT_AREA;
  
  S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
      S01CB_SAVE_INPUT_AREA_FULLY_SCANNED := S01AN_NO_MORE_INPUT_THIS_LINE;

  S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
      S01CC_SAVE_INPUT_INDEX := S01AW_INPUT_INDEX;
  
  S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
      S01CD_SAVE_COMMA_COUNT := S01AV_COMMA_COUNT
  
END;




(**  S22_PREPROCESS_ALTERNATE_INPUT  ******************************************
*									      *
*  The purpose of this procedure is to determine if a new file needs to be    *
*  opened.  This is done by checking to see if S01BK_INPUT_IS_FROM_KEYBOARD   *
*  is TRUE.  If so, then the file name specified by S01AG_ALTERNATE_INPUT_    *
*  FILE_NAME is opened.	 If the file is successfully opened, then the current *
*  (interactive) context is saved, and S01BK_INPUT_IS_FROM_KEYBOARD is set to *
*   FALSE.								      *
*									      *
*  If S01BK_INPUT_IS_FROM_KEYBOARD is FALSE, then it is necessary to check    *
*  the current context to see if input is presently being supplied by the     *
*  file name specified by S01AG_ALTERNATE_INPUT_FILE_NAME.  (S01AG_ALTERNATE_ *
*  FILE_NAME is only set by the calling program.)  If so, no further action   *
*  is required in this procedure.  If not, then it is necessary to open	      *
*  S01AG_ALTERNATE_INPUT_FILE_NAME, and to perform a context switch in	      *
*  preparation for obtaining input from the specified S01AG_ALTERNATE_INPUT_  *
*  FILE_NAME.  However, we must first determine that the file name specified  *
*  by S01AG_ALTERNATE_INPUT_FILE_NAME is not already in use, by checking all  *
*  context levels below the present working level.			      *
*									      *
******************************************************************************)


BEGIN

  IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
    BEGIN
      S01CZ_WORKING_LEVEL := 1;
      S2205_OPEN_ALTERNATE_INPUT_FILE;
      IF NOT S22AA_IO_ERROR THEN
	BEGIN
	  S2210_SAVE_PREVIOUS_CONTEXT;
	  S01AN_NO_MORE_INPUT_THIS_LINE := TRUE;
	  S01AV_COMMA_COUNT := 0;
	  S01BK_INPUT_IS_FROM_KEYBOARD := FALSE
	END
      ELSE
	S01AO_USE_ALTERNATE_INPUT_FILE := FALSE
    END
  ELSE
    IF S01AG_ALTERNATE_INPUT_FILE_NAME <>
	S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
	S01CG_INPUT_FILE_NAME THEN
      BEGIN
	I := 1;
	S22AB_SPECIFIED_FILE_IN_PROCESS := FALSE;
	WHILE (I < S01CZ_WORKING_LEVEL)
	    AND (NOT S22AB_SPECIFIED_FILE_IN_PROCESS) DO
	  IF S01AG_ALTERNATE_INPUT_FILE_NAME =
	      S01CA_CURRENT_CONTEXT [I].S01CG_INPUT_FILE_NAME THEN
	    S22AB_SPECIFIED_FILE_IN_PROCESS := TRUE
	  ELSE
	    I := I + 1;
	IF NOT S22AB_SPECIFIED_FILE_IN_PROCESS THEN
	  BEGIN
	    IF S01CZ_WORKING_LEVEL < S01BJ_MAX_CONTEXT_LEVELS THEN
	      BEGIN
		S01CZ_WORKING_LEVEL := S01CZ_WORKING_LEVEL + 1;
		S2205_OPEN_ALTERNATE_INPUT_FILE;
		IF NOT S22AA_IO_ERROR THEN
		  BEGIN
		    S2210_SAVE_PREVIOUS_CONTEXT;
		    S01AN_NO_MORE_INPUT_THIS_LINE := TRUE;
		    S01AV_COMMA_COUNT := 0
		  END
		ELSE
		  BEGIN
		    S01CZ_WORKING_LEVEL := S01CZ_WORKING_LEVEL - 1;
		    S01AG_ALTERNATE_INPUT_FILE_NAME :=
			S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
			S01CG_INPUT_FILE_NAME
		  END
	      END
	    ELSE
	      BEGIN
		S01AG_ALTERNATE_INPUT_FILE_NAME :=
		    S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
		    S01CG_INPUT_FILE_NAME;
		CommandIOMemo.IOHistory.Lines.add ('');
		CommandIOMemo.IOHistory.Lines.add
                    ('WARNING!!!  Maximum number (' +
		    IntToStr (S01BJ_MAX_CONTEXT_LEVELS) +
                    ') of nested input files');
		CommandIOMemo.IOHistory.Lines.add
                    ('exceeded.  Proceeding with input from ' +
		    S01AG_ALTERNATE_INPUT_FILE_NAME + '.');
		CommandIOMemo.IOHistory.Lines.add ('')
	      END
	  END
	ELSE
	  BEGIN
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add ('ERROR:  Specified file ' +
		S01AG_ALTERNATE_INPUT_FILE_NAME +
		' already in use.  Proceeding');
	    CommandIOMemo.IOHistory.Lines.add
                ('with input from ' +
		S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
		S01CG_INPUT_FILE_NAME + '.');
	    S01AG_ALTERNATE_INPUT_FILE_NAME :=
		S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
		S01CG_INPUT_FILE_NAME
	  END
      END
      
END;




(**  S25_READ_INPUT_FILE  *****************************************************
******************************************************************************)


PROCEDURE S25_READ_INPUT_FILE;

BEGIN

  IF S01AO_USE_ALTERNATE_INPUT_FILE THEN
    S30_READ_ALTERNATE_FILE
  ELSE
    S35_READ_INTERACTIVE_RESPONSE

END;




(**  S30_READ_ALTERNATE_FILE  *************************************************
******************************************************************************)


PROCEDURE S30_READ_ALTERNATE_FILE;

  VAR
      S30AA_EOF_ENCOUNTERED  : BOOLEAN;
      S30AB_INPUT_OBTAINED   : BOOLEAN;


(**  S3010_ACCESS_ALT_FILE  ***************************************************
******************************************************************************)


PROCEDURE S3010_ACCESS_ALT_FILE;

BEGIN

  IF S01BH_REWIND_FILE_BEFORE_READ THEN
    BEGIN
      S01BH_REWIND_FILE_BEFORE_READ := FALSE;
      S30AA_EOF_ENCOUNTERED := FALSE;
      IF S01CZ_WORKING_LEVEL = 1 THEN
	BEGIN
	  RESET (S01CX1_INTERNAL_FILE_1);
	  READLN (S01CX1_INTERNAL_FILE_1, S01BB_INPUT_AREA);
	  IF EOF (S01CX1_INTERNAL_FILE_1) THEN
	    BEGIN
	      CLOSE (S01CX1_INTERNAL_FILE_1);
	      S30AA_EOF_ENCOUNTERED := TRUE
	    END
	END
      ELSE
      IF S01CZ_WORKING_LEVEL = 2 THEN
	BEGIN
	  RESET (S01CX2_INTERNAL_FILE_2);
	  READLN (S01CX2_INTERNAL_FILE_2, S01BB_INPUT_AREA);
	  IF EOF (S01CX2_INTERNAL_FILE_2) THEN
	    BEGIN
	      CLOSE (S01CX2_INTERNAL_FILE_2);
	      S30AA_EOF_ENCOUNTERED := TRUE
	    END
	END
      ELSE
      IF S01CZ_WORKING_LEVEL = 3 THEN
	BEGIN
	  RESET (S01CX3_INTERNAL_FILE_3);
	  READLN (S01CX3_INTERNAL_FILE_3, S01BB_INPUT_AREA);
	  IF EOF (S01CX3_INTERNAL_FILE_3) THEN
	    BEGIN
	      CLOSE (S01CX3_INTERNAL_FILE_3);
	      S30AA_EOF_ENCOUNTERED := TRUE
	    END
	END
    END
  ELSE
  IF S01AQ_FORCE_END_OF_FILE THEN
    BEGIN
      S01AQ_FORCE_END_OF_FILE := FALSE;
      S30AA_EOF_ENCOUNTERED := TRUE;
      S01BB_INPUT_AREA := '';
      IF S01CZ_WORKING_LEVEL = 1 THEN
	CLOSE (S01CX1_INTERNAL_FILE_1)
      ELSE
      IF S01CZ_WORKING_LEVEL = 2 THEN
	CLOSE (S01CX2_INTERNAL_FILE_2)
      ELSE
      IF S01CZ_WORKING_LEVEL = 3 THEN
	CLOSE (S01CX3_INTERNAL_FILE_3)
    END
  ELSE
    BEGIN
      S30AA_EOF_ENCOUNTERED := FALSE;
      IF S01CZ_WORKING_LEVEL = 1 THEN
	BEGIN
	  READLN (S01CX1_INTERNAL_FILE_1, S01BB_INPUT_AREA);
	  IF EOF (S01CX1_INTERNAL_FILE_1) THEN
            IF LENGTH (S01BB_INPUT_AREA) = 0 THEN
	      BEGIN
	        CLOSE (S01CX1_INTERNAL_FILE_1);
	        S30AA_EOF_ENCOUNTERED := TRUE
	      END
	END
      ELSE
      IF S01CZ_WORKING_LEVEL = 2 THEN
	BEGIN
	  READLN (S01CX2_INTERNAL_FILE_2, S01BB_INPUT_AREA);
	  IF EOF (S01CX2_INTERNAL_FILE_2) THEN
	    BEGIN
	      CLOSE (S01CX2_INTERNAL_FILE_2);
	      S30AA_EOF_ENCOUNTERED := TRUE
	    END
	END
      ELSE
      IF S01CZ_WORKING_LEVEL = 3 THEN
	BEGIN
	  READLN (S01CX3_INTERNAL_FILE_3, S01BB_INPUT_AREA);
	  IF EOF (S01CX3_INTERNAL_FILE_3) THEN
	    BEGIN
	      CLOSE (S01CX3_INTERNAL_FILE_3);
	      S30AA_EOF_ENCOUNTERED := TRUE
	    END
	END
    END
	
END;




(**  S30_READ_ALTERNATE_FILE  *************************************************
******************************************************************************)


BEGIN

  S30AB_INPUT_OBTAINED := FALSE;

  REPEAT
    BEGIN
      S3010_ACCESS_ALT_FILE;
      IF S30AA_EOF_ENCOUNTERED THEN
	BEGIN
(*        CommandIOMemo.IOHistory.Lines.add
          ('S01BB_INPUT_AREA = ', S01BB_INPUT_AREA);
          READLN;*)
	  (* Switch context to next lower level. *)
	  S01AN_NO_MORE_INPUT_THIS_LINE :=
	      S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
	      S01CB_SAVE_INPUT_AREA_FULLY_SCANNED;
	  S01AW_INPUT_INDEX := S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
	      S01CC_SAVE_INPUT_INDEX;
	  S01BA_LAST_INPUT_INDEX := S01AW_INPUT_INDEX;
	  S01AV_COMMA_COUNT := S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
	      S01CD_SAVE_COMMA_COUNT;
	  S01BB_INPUT_AREA := S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
	      S01CE_SAVE_INPUT_AREA;
	  IF S01CZ_WORKING_LEVEL = 1 THEN
	    BEGIN
	      S01AO_USE_ALTERNATE_INPUT_FILE := FALSE;
	      S01BK_INPUT_IS_FROM_KEYBOARD := TRUE;
  	      IF S01AN_NO_MORE_INPUT_THIS_LINE THEN
		BEGIN
(*		  CommandIOMemo.IOHistory.Lines.add
  		      ('Reverting to keyboard input... >');*)
		  S35_READ_INTERACTIVE_RESPONSE
		END
	    END
	  ELSE
	    BEGIN
	      S01CZ_WORKING_LEVEL := S01CZ_WORKING_LEVEL - 1;
	      S01AG_ALTERNATE_INPUT_FILE_NAME :=
		  S01CA_CURRENT_CONTEXT [S01CZ_WORKING_LEVEL].
		  S01CG_INPUT_FILE_NAME;
	      IF S01AN_NO_MORE_INPUT_THIS_LINE THEN (* from new context... *)
		(* This condition will cause this REPEAT statement to loop,
		   and will result in a read on the new-context file, in an
		   attempt to obtain input. *)
	      ELSE
		S30AB_INPUT_OBTAINED := TRUE
	    END
	END
      ELSE
	BEGIN
	  S30AB_INPUT_OBTAINED := TRUE;
	  S99_INITIALIZE_FOR_NEW_INPUT
	END
    END
  UNTIL
    S30AB_INPUT_OBTAINED
    OR S01BK_INPUT_IS_FROM_KEYBOARD

END;




(**  S35_READ_INTERACTIVE_RESPONSE  *******************************************
******************************************************************************)


PROCEDURE S35_READ_INTERACTIVE_RESPONSE;

BEGIN

  IF CalledFromGUI THEN
    S01BB_INPUT_AREA := ''
  ELSE
    ReadInteractiveResponse;
  (*READLN (S01BB_INPUT_AREA);*)

  S99_INITIALIZE_FOR_NEW_INPUT

END;




(**  S99_INITIALIZE_FOR_NEW_INPUT  ********************************************
******************************************************************************)


PROCEDURE S99_INITIALIZE_FOR_NEW_INPUT;

BEGIN

  IF LENGTH (S01BB_INPUT_AREA) = 0 THEN
    BEGIN
      S01BB_INPUT_AREA := S01BE_SPACE_LINE;
      S01AN_NO_MORE_INPUT_THIS_LINE := TRUE
    END
  ELSE
    BEGIN
      S01BA_LAST_INPUT_INDEX := 1;
      S01AW_INPUT_INDEX := 1;
      S01AV_COMMA_COUNT := 1;
      S20_FIND_NEXT_DATA_ENTITY
    END

END;




(**  S01_PROCESS_REQUEST  *****************************************************
*									      *
*  A single response will be "pulled" from the input line S01BB_INPUT_AREA    *
*  and will be placed left justified, blank-padded in the 80 character string *
*  called S01BC_USER_RESPONSE.						      *
*									      *
*  A second version of S01BC_USER_RESPONSE, called			      *
*  S01BD_USER_RESPONSE_UPPER_CASE, is identical to S01BC_USER_RESPONSE (i.e., *
*  blank filled out to 80 characters) except all lower case characters in the *
*  string are converted to upper case.					      *
*									      *
*  A third version of S01BC_USER_RESPONSE, called			      *
*  S01AM_BLANKS_STRIPPED_RESPONSE, is identical to S01BC_USER_RESPONSE except *
*  that the length of the string S01AM_BLANKS_STRIPPED_RESPONSE is equal to   *
*  the number of non-blank characters in S01BC_USER_RESPONSE, with NO!!!      *
*  trailing blanks.							      *
*									      *
*  A fourth version of S01BC_USER_RESPONSE, called			      *
*  S01AF_BLANKS_STRIPPED_RESPONSE_UC, is identical to			      *
*  S01AM_BLANKS_STRIPPED_RESPONSE except that all lower case characters are   *
*  converted to upper case.						      *
*									      *
******************************************************************************)

BEGIN

  S01BC_USER_RESPONSE := S01BE_SPACE_LINE;
  S01BD_USER_RESPONSE_UPPER_CASE := S01BE_SPACE_LINE;
  S01AY_CHARACTER_COUNT := 0;

  IF S01AO_USE_ALTERNATE_INPUT_FILE THEN
    IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
    ELSE
      BEGIN
	IF KeyboardActivityDetected THEN
	  BEGIN
	    IF S01CZ_WORKING_LEVEL = 1 THEN
	      CLOSE (S01CX1_INTERNAL_FILE_1)
	    ELSE
	    IF S01CZ_WORKING_LEVEL = 2 THEN
	      BEGIN
		CLOSE (S01CX1_INTERNAL_FILE_1);
		CLOSE (S01CX2_INTERNAL_FILE_2)
	      END
	    ELSE
	    IF S01CZ_WORKING_LEVEL = 3 THEN
	      BEGIN
		CLOSE (S01CX1_INTERNAL_FILE_1);
		CLOSE (S01CX2_INTERNAL_FILE_2);
		CLOSE (S01CX3_INTERNAL_FILE_3)
	      END;
	    Z01_INITIALIZE;
	    CommandIOMemo.IOHistory.Lines.add ('');
	    CommandIOMemo.IOHistory.Lines.add
                ('  Batch processing mode interrupted.');
	    CommandIOMemo.IOHistory.Lines.add
                ('  Press RETURN key for next instruction...')
	  END
      END;
  
  IF S01AP_FORCE_END_OF_LINE
      OR S01AQ_FORCE_END_OF_FILE THEN
    BEGIN
      S01AP_FORCE_END_OF_LINE := FALSE;
      S01AN_NO_MORE_INPUT_THIS_LINE := TRUE
    END;
  
  IF S01AO_USE_ALTERNATE_INPUT_FILE THEN
    S22_PREPROCESS_ALTERNATE_INPUT;
  
  IF S01AN_NO_MORE_INPUT_THIS_LINE THEN
    IF S01AV_COMMA_COUNT = 0 THEN
      S25_READ_INPUT_FILE  (* Always executed after upward context switch. *)
    ELSE
      S01AV_COMMA_COUNT := 0  (* This condition occurs only when comma found *)
  ELSE			      (* at end of previous line of input. *)
    S01BA_LAST_INPUT_INDEX := S01AW_INPUT_INDEX;

  IF S01AN_NO_MORE_INPUT_THIS_LINE THEN
  ELSE
    BEGIN
      S05_PROCESS_INPUT_STRING;
      IF S01AN_NO_MORE_INPUT_THIS_LINE THEN
      ELSE
	S20_FIND_NEXT_DATA_ENTITY
    END;
    
  IF S01AN_NO_MORE_INPUT_THIS_LINE
      AND (S01AV_COMMA_COUNT = 0) THEN
    S01AA_EXPERT_MODE_OFF := TRUE
  ELSE
    S01AA_EXPERT_MODE_OFF := FALSE;
  
  IF POS ('                    ', S01BD_USER_RESPONSE_UPPER_CASE) = 1 THEN
    BEGIN
      S01AB_USER_IS_DONE := TRUE;
      S01AC_NULL_RESPONSE_GIVEN := TRUE
    END
  ELSE
    BEGIN
      S01AB_USER_IS_DONE := FALSE;
      S01AC_NULL_RESPONSE_GIVEN := FALSE
    END;

  IF POS ('END                 ', S01BD_USER_RESPONSE_UPPER_CASE) = 1 THEN
    BEGIN
      S01AB_USER_IS_DONE := TRUE;
      S01AD_END_EXECUTION_DESIRED := TRUE
    END;
    
  IF POS ('HELP                ', S01BD_USER_RESPONSE_UPPER_CASE) = 1 THEN
    S01AE_USER_NEEDS_HELP := TRUE
  ELSE
    S01AE_USER_NEEDS_HELP := FALSE;

(******************************************************************************
*******************************************************************************
*									      *
* The following "FOR" statement takes the first 2, 3, 4, 6, and 11 characters *
* from the 80 character string S01BD_USER_RESPONSE_UPPER_CASE, and places     *
* these characters in smaller, more conveniently sized strings.		      *
*									      *
*******************************************************************************
******************************************************************************)

  FOR I := 1 TO 11 DO
    BEGIN
      IF I < 3 THEN
	BEGIN
	  S01AH_LENGTH_2_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AI_LENGTH_3_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AJ_LENGTH_4_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AK_LENGTH_6_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AL_LENGTH_11_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I]
	END
      ELSE
      IF I < 4 THEN
	BEGIN
	  S01AI_LENGTH_3_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AJ_LENGTH_4_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AK_LENGTH_6_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AL_LENGTH_11_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I]
	END
      ELSE
      IF I < 5 THEN
	BEGIN
	  S01AJ_LENGTH_4_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AK_LENGTH_6_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AL_LENGTH_11_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I]
	END
      ELSE
      IF I < 7 THEN
	BEGIN
	  S01AK_LENGTH_6_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AL_LENGTH_11_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I]
	END
      ELSE
	BEGIN
	  S01AL_LENGTH_11_RESPONSE [I] := S01BD_USER_RESPONSE_UPPER_CASE [I]
	END
    END;

  IF POS ('-                   ', S01BD_USER_RESPONSE_UPPER_CASE) = 1 THEN
    S01AU_USER_WANTS_BLANK_ENTRY := TRUE
  ELSE
    S01AU_USER_WANTS_BLANK_ENTRY := FALSE;

(******************************************************************************
*******************************************************************************
*									      *
*  The following statements take the left justified, blank filled user	      *
*  response found in the 80-character string S01BC_USER_RESPONSE, and in the  *
*  80-character string S01BD_USER_RESPONSE_UPPER_CASE,			      *
*  and places the response in strings having a length just sufficient to      *
*  hold the response less trailing blanks.				      *
*									      *
*******************************************************************************
******************************************************************************)

  S01AF_BLANKS_STRIPPED_RESPONSE_UC := '';
  S01AM_BLANKS_STRIPPED_RESPONSE := '';
  IF S01AY_CHARACTER_COUNT > 0 THEN
    BEGIN
      FOR I := 1 TO S01AY_CHARACTER_COUNT DO
	BEGIN
	  S01BF_ONE_CHAR [1] := S01BD_USER_RESPONSE_UPPER_CASE [I];
	  S01AF_BLANKS_STRIPPED_RESPONSE_UC := 
	      CONCAT (S01AF_BLANKS_STRIPPED_RESPONSE_UC, S01BF_ONE_CHAR);
	  S01BF_ONE_CHAR [1] := S01BC_USER_RESPONSE [I];
	  S01AM_BLANKS_STRIPPED_RESPONSE :=
	      CONCAT (S01AM_BLANKS_STRIPPED_RESPONSE, S01BF_ONE_CHAR)
	END
    END;

  RealNumberFound := FALSE;
  LongIntegerFound := FALSE;
  IntegerFound := FALSE;

  IF S01AB_USER_IS_DONE
      OR S01AE_USER_NEEDS_HELP
      OR S01AU_USER_WANTS_BLANK_ENTRY THEN
  ELSE
    BEGIN
      {$R-}
      Val (S01AM_BLANKS_STRIPPED_RESPONSE, RealNumber, ValCode);
      {$R+}
      IF ValCode = 0 THEN
        RealNumberFound := TRUE;
      {$R-}
      Val (S01AM_BLANKS_STRIPPED_RESPONSE, LongIntegerNumber, ValCode);
      {$R+}
      IF ValCode = 0 THEN
        IF Abs (LongIntegerNumber) <= MaxInt THEN
          BEGIN
            IntegerFound := TRUE;
            IntegerNumber := LongIntegerNumber
          END
        ELSE
          LongIntegerFound := TRUE
    END

END;




(**  ResetKeyboardActivity  ***************************************************
******************************************************************************)


PROCEDURE ResetKeyboardActivity;

BEGIN

  KeyboardActivityDetected := FALSE

END;




(**  T99_CHECK_KEYBOARD_ACTIVITY  *********************************************
******************************************************************************)


PROCEDURE T99_CHECK_KEYBOARD_ACTIVITY;

BEGIN

  Application.ProcessMessages

END;




(**  Z01_INITIALIZE  **********************************************************
******************************************************************************)

PROCEDURE Z01_INITIALIZE;

BEGIN

  CalledFromGUI := FALSE;
  S01AA_EXPERT_MODE_OFF := TRUE;
  S01AB_USER_IS_DONE := FALSE;
  S01AC_NULL_RESPONSE_GIVEN := FALSE;
  S01AD_END_EXECUTION_DESIRED := FALSE;
  S01AE_USER_NEEDS_HELP := FALSE;
  S01AN_NO_MORE_INPUT_THIS_LINE := TRUE;
  S01AO_USE_ALTERNATE_INPUT_FILE := FALSE;
  S01BK_INPUT_IS_FROM_KEYBOARD := TRUE;
  S01AP_FORCE_END_OF_LINE := FALSE;
  S01AQ_FORCE_END_OF_FILE := FALSE;
  S01BH_REWIND_FILE_BEFORE_READ := FALSE;
  S01AR_INPUT_DATA_ENCOUNTERED := FALSE;
  S01AS_DATA_ENTITY_OBTAINED := FALSE;
  S01AT_PROCESSING_QUOTED_STRING := FALSE;
  S01AU_USER_WANTS_BLANK_ENTRY := FALSE;
  S01AV_COMMA_COUNT := 0;
  S01CZ_WORKING_LEVEL := 1;
  S01BB_INPUT_AREA := S01BE_SPACE_LINE;
  S01BC_USER_RESPONSE := S01BE_SPACE_LINE;
  S01BD_USER_RESPONSE_UPPER_CASE := S01BE_SPACE_LINE;
  Q970AA_OK_TO_PROCEED := TRUE;
  T99AB_CHARACTERS_WAITING [1] := 0;
  T99AC_PREVIOUS_CHARACTERS_WAITING := 0

END;




(**  MAIN  ********************************************************************
******************************************************************************)


BEGIN

  S01BF_ONE_CHAR := ' ';
  S01BE_SPACE_LINE := '';
  FOR I := 1 TO 8 DO
    S01BE_SPACE_LINE := CONCAT ('          ', S01BE_SPACE_LINE);
  Q970AB_OUTPUT_STRING := '';
  S01AH_LENGTH_2_RESPONSE := '  ';
  S01AI_LENGTH_3_RESPONSE := '   ';
  S01AJ_LENGTH_4_RESPONSE := '    ';
  S01AK_LENGTH_6_RESPONSE := '      ';
  S01AL_LENGTH_11_RESPONSE := '           ';
  Z01_INITIALIZE

END.

