UNIT LADSq3Unit;

INTERFACE

PROCEDURE Q052_REQUEST_SURFACE_SEQUENCE;
PROCEDURE Q060_REQUEST_ARCHIVE_COMMAND;

IMPLEMENTATION

  USES SysUtils,
       LADSUtilUnit,
       EXPERTIO,
       LADSData,
       LADSArchiveUnit,
       LADSInitUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;
       
PROCEDURE Q061_REQUEST_ARCHIVE_FILE_NAME; FORWARD;
PROCEDURE Q062_REQUEST_ARCHIVE_DATA_TYPE; FORWARD;


(**  Q051_SET_UP_SEQUENCER_GROUPS  ********************************************
******************************************************************************)

PROCEDURE Q051_SET_UP_SEQUENCER_GROUPS;

  VAR
      Valid                        : BOOLEAN;
      GroupIDEntered               : BOOLEAN;

      GroupIndex                   : INTEGER;
      CODE                         : INTEGER;

      IntegerNumber                : LONGINT;

      TempString                   : STRING;


(**  Q05105_REQUEST_SEQUENCER_ORDINAL_RANGE  **********************************
******************************************************************************)


PROCEDURE Q05105_REQUEST_SEQUENCER_ORDINAL_RANGE;

  VAR
      SequencerStartSlotSpecified  : BOOLEAN;
      Active                       : BOOLEAN;

      StartSlot                    : INTEGER;
      EndSlot                      : INTEGER;

      TempString                   : STRING;

BEGIN

  Valid := FALSE;
  SequencerStartSlotSpecified := FALSE;
  Active := FALSE;

  REPEAT
    BEGIN
      IF SequencerStartSlotSpecified THEN
        CommandIOdlg.Caption := 'ENTER SEQUENCER GROUP ENDING SLOT NUMBER'
      ELSE
        CommandIOdlg.Caption := 'ENTER SEQUENCER GROUP STARTING SLOT NUMBER';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  IF SequencerStartSlotSpecified THEN
            CommandIOMemo.IOHistory.Lines.add
                ('ENTER SEQUENCER GROUP ENDING SLOT NUMBER')
	  ELSE
            CommandIOMemo.IOHistory.Lines.add
                ('ENTER SEQUENCER GROUP STARTING SLOT NUMBER');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, ValidSequencerGroupCommands) > 0 THEN
        BEGIN
          IF S01AH_LENGTH_2_RESPONSE = GroupCancelCommand THEN
            BEGIN
              IF ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
	          ZGX_GROUP_PROCESS_CONTROL_CODE = GroupActive THEN
                BEGIN
                  Valid := TRUE;
                  ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                      ZGV_SEQUENCER_START_SLOT := 0;
                  ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                      ZGW_SEQUENCER_END_SLOT := 0;
                  ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
	              ZGX_GROUP_PROCESS_CONTROL_CODE := GroupInactive
                END
              ELSE
                BEGIN
                  CommandIOMemo.IOHistory.Lines.add ('');
                  CommandIOMemo.IOHistory.Lines.add
                      ('ERROR:  No sequencer group identified.')
                END
            END
        END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpSequencerOrdinalRange
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF SequencerStartSlotSpecified THEN
	      IF ((IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
		  AND (IntegerNumber > 0)
		  AND (IntegerNumber >= StartSlot)) THEN
		BEGIN
                  IF ZBA_SURFACE [ZFA_OPTION.ZGT_SURFACE_SEQUENCER
                      [IntegerNumber]].ZBB_SPECIFIED
                      AND ZBA_SURFACE [ZFA_OPTION.ZGT_SURFACE_SEQUENCER
                      [IntegerNumber]].ZBC_ACTIVE THEN
                    BEGIN
		      EndSlot := IntegerNumber;
		      Valid := TRUE;
                      ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                          ZGV_SEQUENCER_START_SLOT := StartSlot;
                      ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                          ZGW_SEQUENCER_END_SLOT := EndSlot;
                      ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
	                    ZGX_GROUP_PROCESS_CONTROL_CODE := GroupActive
                    END
                  ELSE
                    BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                          ('ERROR:  Surface ' + IntToStr (IntegerNumber) +
                          ' not specified/active.')
                    END
		END
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	    ELSE
	      IF ((IntegerNumber < (CZAB_MAX_NUMBER_OF_SURFACES + 1))
		  AND (IntegerNumber > 0)) THEN
		BEGIN
                  IF ZBA_SURFACE [ZFA_OPTION.ZGT_SURFACE_SEQUENCER
                      [IntegerNumber]].ZBB_SPECIFIED
                      AND ZBA_SURFACE [ZFA_OPTION.ZGT_SURFACE_SEQUENCER
                      [IntegerNumber]].ZBC_ACTIVE THEN
                    BEGIN
	              StartSlot := IntegerNumber;
		      SequencerStartSlotSpecified := TRUE
                    END
                  ELSE
                    BEGIN
                      CommandIOMemo.IOHistory.Lines.add ('');
                      CommandIOMemo.IOHistory.Lines.add
                          ('ERROR:  Surface ' + IntToStr (IntegerNumber) +
                          ' not specified/active.')
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




(**  Q051_SET_UP_SEQUENCER_GROUPS  ********************************************
******************************************************************************)


BEGIN

  GroupIDEntered := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'Enter GroupID#';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Lines.add ('');
          FOR GroupIndex := 1 TO CZBO_MAX_SEQUENCER_GROUPS DO
            IF ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
	        ZGX_GROUP_PROCESS_CONTROL_CODE = GroupActive THEN
              CommandIOMemo.IOHistory.Lines.add ('Group ID = ' +
                  IntToStr (GroupIndex) +
                  ', seq. start slot = ' +
                  IntToStr (ZFA_OPTION.
                      ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                      ZGV_SEQUENCER_START_SLOT) +
                  ' (surf. no. ' +
                  IntToStr (ZFA_OPTION.ZGT_SURFACE_SEQUENCER [ZFA_OPTION.
                      ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                      ZGV_SEQUENCER_START_SLOT]) +
                  '), seq. end slot = ' +
                  IntToStr (ZFA_OPTION.ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                      ZGW_SEQUENCER_END_SLOT) +
                  ' (surf. no. ' +
                  IntToStr (ZFA_OPTION.ZGT_SURFACE_SEQUENCER [ZFA_OPTION.
                      ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                      ZGW_SEQUENCER_END_SLOT]) +
                  ')');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add ('Enter GroupID#');
	  CommandIOMemo.IOHistory.Lines.add ('')
        END;
      S01_PROCESS_REQUEST;
      VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
      IF CODE = 0 THEN
        BEGIN
	  IF (IntegerNumber <= CZBO_MAX_SEQUENCER_GROUPS)
	      AND (IntegerNumber > 0) THEN
            BEGIN
              GroupIndex := IntegerNumber;
              Q05105_REQUEST_SEQUENCER_ORDINAL_RANGE;
              IF Valid THEN
              ELSE
              IF NOT S01AD_END_EXECUTION_DESIRED THEN
                S01AB_USER_IS_DONE := FALSE
            END
          ELSE
            BEGIN
              CommandIOMemo.IOHistory.Lines.add ('');
              CommandIOMemo.IOHistory.Lines.add
                  ('ERROR:  Group ID # must be in the range 1 thru ' +
                  IntToStr (CZBO_MAX_SEQUENCER_GROUPS))
            END
        END
      ELSE
      IF S01AB_USER_IS_DONE THEN
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpSequencerGroupID
      ELSE
        Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    S01AB_USER_IS_DONE

END;




(**  Q052_REQUEST_SURFACE_SEQUENCE  *******************************************
******************************************************************************)


PROCEDURE Q052_REQUEST_SURFACE_SEQUENCE;

  VAR
      GET_SLOT	       : BOOLEAN;
      GroupFound       : BOOLEAN;

      I		       : INTEGER;
      J		       : INTEGER;
      K		       : INTEGER;
      L		       : INTEGER;
      SLOT	       : INTEGER;
      GroupIndex       : INTEGER;
      ROWS_PER_COLUMN  : INTEGER;
      CODE             : INTEGER;

      IntegerNumber    : LONGINT;

      TempString       : STRING;

BEGIN

  GET_SLOT := TRUE;

  TempString := '';

  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'ENTER SURFACE SEQUENCE:  N(ormal R(everse A(uto G(roup nn nn';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
          CommandIOMemo.IOHistory.Clear;
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('Current surface sequencer status:');
	  CommandIOMemo.IOHistory.Lines.add
              ('   grp slt srf  grp slt srf  grp slt srf  grp slt srf' +
              '  grp slt srf');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  ROWS_PER_COLUMN := CZAB_MAX_NUMBER_OF_SURFACES DIV 5;
	  FOR I := 1 TO ROWS_PER_COLUMN DO  (* Cycle through row numbers.*)
	    BEGIN
	      L := I;  (* Initialize L to the current row number. *)
              TempString := '';
	      FOR K := 1 TO 5 DO  (* Cycle through column numbers. *)
		BEGIN
		  IF L <= CZAB_MAX_NUMBER_OF_SURFACES THEN
		    BEGIN
		      J := ZFA_OPTION.ZGT_SURFACE_SEQUENCER [L];
		      IF (J > 0)
			  AND (J <= CZAB_MAX_NUMBER_OF_SURFACES) THEN
			IF ZBA_SURFACE [J].ZBB_SPECIFIED
			    AND ZBA_SURFACE [J].ZBC_ACTIVE THEN
                          BEGIN
                            GroupFound := FALSE;
                            GroupIndex := 0;
                            REPEAT
                              BEGIN
                                GroupIndex := GroupIndex + 1;
                                IF ZFA_OPTION.
                                  ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
	                            ZGX_GROUP_PROCESS_CONTROL_CODE =
                                    GroupActive THEN
                                  IF (L >= ZFA_OPTION.
                                  ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                                      ZGV_SEQUENCER_START_SLOT)
                                      AND (L <=
                                      ZFA_OPTION.
                                  ZGU_SURFACE_SEQUENCER_CONTROL [GroupIndex].
                                      ZGW_SEQUENCER_END_SLOT) THEN
                                    GroupFound := TRUE
                              END;
                            UNTIL GroupFound
                                OR (GroupIndex >
                                  CZBO_MAX_SEQUENCER_GROUPS);
                            IF GroupFound THEN
                              TempString := TempString +
                                  '  ' + IntToStrF (GroupIndex, 3) +
                                  ':' + IntToStrF (L, 3) + ':' +
                                  IntToStrF (J, 3)
                            ELSE
			      TempString := TempString +
                                   '      ' + IntToStrF (L, 3) + ':' +
                                  IntToStrF (J, 3)
                          END
			ELSE
			  TempString := TempString +
                              '      ' + IntToStrF (L, 3) + ':  0'
		      ELSE
			TempString := TempString +
                             '      ' + IntToStrF (L, 3) + ':  0'
		    END;
		  L := L + ROWS_PER_COLUMN
		END;
	      CommandIOMemo.IOHistory.Lines.add (TempString)
	    END;
	  CommandIOMemo.IOHistory.Lines.add ('');
	  TempString := 'Surface sequencer option in effect: ... ';
	  IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	      CZBS_USER_SPECIFIED_SEQUENCE THEN
	    TempString := TempString + 'User-specified'
	  ELSE
	  IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	      CZBP_NORMAL_PROCESSING_SEQUENCE THEN
	    TempString := TempString + 'Normal'
	  ELSE
	  IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	      CZBQ_REVERSE_PROCESSING_SEQUENCE THEN
	    TempString := TempString + 'Reverse'
	  ELSE
	  IF ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE =
	      CZBR_AUTO_SEQUENCING THEN
	    TempString := TempString + 'Auto';
	  IF NOT ZFA_OPTION.ZGS_USE_SURFACE_SEQUENCER THEN
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + ' (disabled)')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add (TempString + '');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER SURFACE SEQUENCE:  N(ormal R(everse A(uto G(roup' +
              ' nn nn');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF S01AB_USER_IS_DONE THEN
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpSurfaceSequencerCommands
      ELSE
      IF POS (S01AH_LENGTH_2_RESPONSE, CFCF_VALID_SEQUENCER_COMMANDS) > 0 THEN
	BEGIN
	  IF (S01AH_LENGTH_2_RESPONSE = CFCG_ENABLE_NORMAL_SEQUENCING)
	      OR (S01AH_LENGTH_2_RESPONSE = CFCI_ENABLE_AUTO_SEQUENCING) THEN
	    BEGIN
	      IF S01AH_LENGTH_2_RESPONSE = CFCG_ENABLE_NORMAL_SEQUENCING THEN
		ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE :=
		    CZBP_NORMAL_PROCESSING_SEQUENCE
	      ELSE
	      IF S01AH_LENGTH_2_RESPONSE = CFCI_ENABLE_AUTO_SEQUENCING THEN
		ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE :=
		    CZBR_AUTO_SEQUENCING;
	      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
		ZFA_OPTION.ZGT_SURFACE_SEQUENCER [I] := 0;
	      J := 0;
	      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
		IF ZBA_SURFACE [I].ZBB_SPECIFIED
		    AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
		  BEGIN
		    J := J + 1;
		    ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := I
		  END
	    END
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CFCH_ENABLE_REVERSE_SEQUENCING THEN
	    BEGIN
	      ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE :=
		  CZBQ_REVERSE_PROCESSING_SEQUENCE;
	      FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
		ZFA_OPTION.ZGT_SURFACE_SEQUENCER [I] := 0;
	      J := 0;
	      FOR I := CZAB_MAX_NUMBER_OF_SURFACES DOWNTO 1 DO
		IF ZBA_SURFACE [I].ZBB_SPECIFIED
		    AND ZBA_SURFACE [I].ZBC_ACTIVE THEN
		  BEGIN
		    J := J + 1;
		    ZFA_OPTION.ZGT_SURFACE_SEQUENCER [J] := I
		  END
	    END
          ELSE
          IF S01AH_LENGTH_2_RESPONSE = SpecifyGroupOfSequenceNumbers THEN
            BEGIN
              Q051_SET_UP_SEQUENCER_GROUPS;
              IF NOT S01AD_END_EXECUTION_DESIRED THEN
                S01AB_USER_IS_DONE := FALSE
            END
	END
      ELSE
	BEGIN
	  VAL (S01AF_BLANKS_STRIPPED_RESPONSE_UC, IntegerNumber, CODE);
	  IF CODE = 0 THEN
	    IF GET_SLOT THEN
	      IF (IntegerNumber > 0)
		  AND (IntegerNumber <=
		    CZAB_MAX_NUMBER_OF_SURFACES) THEN
		BEGIN
		  SLOT := IntegerNumber;
		  GET_SLOT := FALSE
		END
	      ELSE
		Q990_INPUT_ERROR_PROCESSING
	    ELSE
	      IF (IntegerNumber >= 0)
		  AND (IntegerNumber <=
		    CZAB_MAX_NUMBER_OF_SURFACES) THEN
		BEGIN
		  ZFA_OPTION.ZGT_SURFACE_SEQUENCER [SLOT] :=
		      IntegerNumber;
		  ZFA_OPTION.ZGY_SURFACE_SEQUENCER_CONTROL_CODE :=
		      CZBS_USER_SPECIFIED_SEQUENCE;
		  GET_SLOT := TRUE;
		  IF IntegerNumber > 0 THEN
		    IF ZBA_SURFACE [IntegerNumber].ZBB_SPECIFIED
			AND ZBA_SURFACE [IntegerNumber].
			  ZBC_ACTIVE THEN
		    ELSE
		      BEGIN
			CommandIOMemo.IOHistory.Lines.add ('');
			CommandIOMemo.IOHistory.Lines.add
		            ('WARNING:  Surface ' +
			    IntToStr (IntegerNumber) + ' not specified ' +
			    'and/or awake.')
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




(**  Q060_REQUEST_ARCHIVE_COMMAND  ********************************************
******************************************************************************)


PROCEDURE Q060_REQUEST_ARCHIVE_COMMAND;

  VAR
      Valid  : BOOLEAN;
  
BEGIN
  
  Valid	:= FALSE;
  
  AKA_PUT_DATA_IN_TEMPORARY_STORAGE   := FALSE;
  AKB_GET_DATA_FROM_TEMPORARY_STORAGE := FALSE;
  AKC_PUT_DATA_IN_PERMANENT_STORAGE   := FALSE;
  AKD_GET_DATA_FROM_PERMANENT_STORAGE := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER ARCHIVE COMMAND: TS TL PS PL';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER ARCHIVE COMMAND: TS TL PS PL');
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AI_LENGTH_3_RESPONSE, CGAA_VALID_ARCHIVE_COMMANDS) > 0 THEN
	BEGIN
	  Valid := TRUE;
	  IF S01AI_LENGTH_3_RESPONSE = CGAB_TEMP_TO_EXTERNAL_STORAGE THEN
	    AKA_PUT_DATA_IN_TEMPORARY_STORAGE := TRUE
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CGAC_TEMP_TO_INTERNAL_STORAGE THEN
	    AKB_GET_DATA_FROM_TEMPORARY_STORAGE := TRUE
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CGAD_PERM_TO_EXTERNAL_STORAGE THEN
	    AKC_PUT_DATA_IN_PERMANENT_STORAGE := TRUE
	  ELSE
	  IF S01AI_LENGTH_3_RESPONSE = CGAE_PERM_TO_INTERNAL_STORAGE THEN
	    AKD_GET_DATA_FROM_PERMANENT_STORAGE := TRUE;
	  Q062_REQUEST_ARCHIVE_DATA_TYPE;
	  IF Valid THEN
	    Q061_REQUEST_ARCHIVE_FILE_NAME
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpArchiveCommands
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q061_REQUEST_ARCHIVE_FILE_NAME  ******************************************
******************************************************************************)


PROCEDURE Q061_REQUEST_ARCHIVE_FILE_NAME;

  VAR
      Valid  : BOOLEAN;

BEGIN

  Valid := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption := 'ENTER (TYPELESS) ARCHIVE FILE NAME';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER (TYPELESS) ARCHIVE FILE NAME');
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
	HelpArchiveFileName
      ELSE
	BEGIN
	  IF LENGTH (S01AF_BLANKS_STRIPPED_RESPONSE_UC) > 18 THEN
	    Q990_INPUT_ERROR_PROCESSING
	  ELSE
	    BEGIN
	      Valid := TRUE;
	      AKZ_ARCHIVE_FILE_NAME := S01AF_BLANKS_STRIPPED_RESPONSE_UC;
	      IF AKA_PUT_DATA_IN_TEMPORARY_STORAGE
		  OR AKB_GET_DATA_FROM_TEMPORARY_STORAGE THEN
		AKZ_ARCHIVE_FILE_NAME :=
		    CONCAT (AKZ_ARCHIVE_FILE_NAME, '.DAT')
	      ELSE
	      IF AKC_PUT_DATA_IN_PERMANENT_STORAGE
		  OR AKD_GET_DATA_FROM_PERMANENT_STORAGE THEN
		AKZ_ARCHIVE_FILE_NAME :=
		    CONCAT (AKZ_ARCHIVE_FILE_NAME, '.TXT')
	    END
	END
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;




(**  Q062_REQUEST_ARCHIVE_DATA_TYPE  ******************************************
******************************************************************************)


PROCEDURE Q062_REQUEST_ARCHIVE_DATA_TYPE;

  VAR
      Valid       : BOOLEAN;

      TempString  : STRING;

BEGIN

  Valid	:= FALSE;

  AED_TRANSFER_SURFACE_DATA	:= FALSE;
  AEE_TRANSFER_RAY_DATA		:= FALSE;
  AEF_TRANSFER_OPTION_DATA	:= FALSE;
  AEG_TRANSFER_ENVIRONMENT_DATA := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'ENTER (TOGGLE) ARCHIVE DATA TYPE: S(urface R(ay O(ption' +
          ' E(nvironment A(ll';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('Present archive situation:');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('               INTERNAL    EXTERNAL');
	  CommandIOMemo.IOHistory.Lines.add
		('               --------    --------');
	  TempString := '  Surfaces     ';
	  IF AED_TRANSFER_SURFACE_DATA THEN
	    IF AKA_PUT_DATA_IN_TEMPORARY_STORAGE
		OR AKC_PUT_DATA_IN_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '--> --> --> -->')
	    ELSE
	    IF AKB_GET_DATA_FROM_TEMPORARY_STORAGE
		OR AKD_GET_DATA_FROM_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '    <-- <-- <-- <--')
	    ELSE
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------');
	  TempString := '  Rays         ';
	  IF AEE_TRANSFER_RAY_DATA THEN
	    IF AKA_PUT_DATA_IN_TEMPORARY_STORAGE
		OR AKC_PUT_DATA_IN_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '--> --> --> -->')
	    ELSE
	    IF AKB_GET_DATA_FROM_TEMPORARY_STORAGE
		OR AKD_GET_DATA_FROM_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '    <-- <-- <-- <--')
	    ELSE
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------');
	  TempString := '  Options      ';
	  IF AEF_TRANSFER_OPTION_DATA THEN
	    IF AKA_PUT_DATA_IN_TEMPORARY_STORAGE
		OR AKC_PUT_DATA_IN_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '--> --> --> -->')
	    ELSE
	    IF AKB_GET_DATA_FROM_TEMPORARY_STORAGE
		OR AKD_GET_DATA_FROM_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '    <-- <-- <-- <--')
	    ELSE
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------');
	  TempString := '  Environment  ';
	  IF AEG_TRANSFER_ENVIRONMENT_DATA THEN
	    IF AKA_PUT_DATA_IN_TEMPORARY_STORAGE
		OR AKC_PUT_DATA_IN_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '--> --> --> -->')
	    ELSE
	    IF AKB_GET_DATA_FROM_TEMPORARY_STORAGE
		OR AKD_GET_DATA_FROM_PERMANENT_STORAGE THEN
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '    <-- <-- <-- <--')
	    ELSE
	      CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------')
	  ELSE
	    CommandIOMemo.IOHistory.Lines.add
		(TempString + '-------------------');
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER (TOGGLE) ARCHIVE DATA TYPE: S(urface R(ay O(ption' +
	      ' E(nvironment A(ll');
	  CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF POS (S01AH_LENGTH_2_RESPONSE, CHAA_VALID_ARCHIVE_DATA_TYPES) > 0 THEN
	BEGIN
	  IF S01AH_LENGTH_2_RESPONSE = CHAB_ARCHIVE_SURFACE_DATA THEN
	    IF AED_TRANSFER_SURFACE_DATA THEN
	      AED_TRANSFER_SURFACE_DATA := FALSE
	    ELSE
	      AED_TRANSFER_SURFACE_DATA := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CHAC_ARCHIVE_RAY_DATA THEN
	    IF AEE_TRANSFER_RAY_DATA THEN
	      AEE_TRANSFER_RAY_DATA := FALSE
	    ELSE
	      AEE_TRANSFER_RAY_DATA := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CHAD_ARCHIVE_OPTION_DATA THEN
	    IF AEF_TRANSFER_OPTION_DATA THEN
	      AEF_TRANSFER_OPTION_DATA := FALSE
	    ELSE
	      AEF_TRANSFER_OPTION_DATA := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CHAE_ARCHIVE_ENVIRONMENT_DATA THEN
	    IF AEG_TRANSFER_ENVIRONMENT_DATA THEN
	      AEG_TRANSFER_ENVIRONMENT_DATA := FALSE
	    ELSE
	      AEG_TRANSFER_ENVIRONMENT_DATA := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CHAF_ARCHIVE_ALL_DATA THEN
	    BEGIN
	      AED_TRANSFER_SURFACE_DATA	    := TRUE;
	      AEE_TRANSFER_RAY_DATA	    := TRUE;
	      AEF_TRANSFER_OPTION_DATA	    := TRUE;
	      AEG_TRANSFER_ENVIRONMENT_DATA := TRUE
	    END
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	  IF NOT S01AD_END_EXECUTION_DESIRED THEN
	    IF AED_TRANSFER_SURFACE_DATA
		OR AEE_TRANSFER_RAY_DATA
		OR AEF_TRANSFER_OPTION_DATA
		OR AEG_TRANSFER_ENVIRONMENT_DATA THEN
	      BEGIN
		S01AB_USER_IS_DONE := FALSE;
		Valid := TRUE
	      END
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpArchiveDataType
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    Valid
    OR S01AB_USER_IS_DONE

END;



(**  LADSq3Unit  ************************************************************
****************************************************************************)

BEGIN

END.
