UNIT LADSq5aUnit;

INTERFACE

PROCEDURE Q080_REQUEST_GLASS_CATALOG_COMMAND;

IMPLEMENTATION

  USES EXPERTIO,
       LADSInitUnit,
       LADSGlassVar,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit;


(**  Q080_REQUEST_GLASS_CATALOG_COMMAND	 **************************************
******************************************************************************)


PROCEDURE Q080_REQUEST_GLASS_CATALOG_COMMAND;

BEGIN
  
  GlassCommandIsValid	       := FALSE;

  AKW_LIST_GLASS_DATA	       := FALSE;
  AKX_COMPUTE_REFRACTIVE_INDEX := FALSE;
  SetupGRINMaterialAlias       := FALSE;

  REPEAT
    BEGIN
      CommandIOdlg.Caption :=
          'ENTER GLASS CATALOG COMMAND:  L(istGlass I(ndex S(etUpAlias';
      IF S01AA_EXPERT_MODE_OFF
          AND S01BK_INPUT_IS_FROM_KEYBOARD THEN
	BEGIN
	  CommandIOMemo.IOHistory.Lines.add ('');
	  CommandIOMemo.IOHistory.Lines.add
		('ENTER GLASS CATALOG COMMAND:  L(istGlass I(ndex S(etUpAlias');
          CommandIOMemo.IOHistory.Lines.add ('')
	END;
      S01_PROCESS_REQUEST;
      IF S01BK_INPUT_IS_FROM_KEYBOARD THEN
          CommandIOMemo.IOHistory.Lines.add
          (S01AM_BLANKS_STRIPPED_RESPONSE);
      IF (POS (S01AH_LENGTH_2_RESPONSE,
	  CJAA_VALID_GLASS_CAT_COMMANDS) > 0) THEN
	BEGIN
	  GlassCommandIsValid := TRUE;
	  IF S01AH_LENGTH_2_RESPONSE = CJAB_LIST_CAT_DATA_FOR_GLASS THEN
	    AKW_LIST_GLASS_DATA := TRUE
	  ELSE
	  IF S01AH_LENGTH_2_RESPONSE = CJAF_COMPUTE_REFRACTIVE_INDEX THEN
	    AKX_COMPUTE_REFRACTIVE_INDEX := TRUE
          ELSE
          IF S01AH_LENGTH_2_RESPONSE = SetupGRINMatlAlias THEN
            SetupGRINMaterialAlias := TRUE
	END
      ELSE
      IF S01AB_USER_IS_DONE THEN
	BEGIN
	END
      ELSE
      IF S01AE_USER_NEEDS_HELP THEN
	HelpGlassCatalogCommand
      ELSE
	Q990_INPUT_ERROR_PROCESSING
    END
  UNTIL
    GlassCommandIsValid
    OR S01AB_USER_IS_DONE

END;




(**  LADSq5aUnit  ***********************************************************
****************************************************************************)

BEGIN

END.
