unit LADSMainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus;

type
  TLADSMainForm = class(TForm)
    MainMenu1: TMainMenu;
    LADSMainMenuFile: TMenuItem;
    LADSMainMenuFileNew: TMenuItem;
    LADSMainMenuFileNewSurface: TMenuItem;
    LADSMainMenuFileNewRay: TMenuItem;
    LADSMainMenuFileOpen: TMenuItem;
    N2: TMenuItem;
    LADSMainMenuFileInitialize: TMenuItem;
    LADSMainMenuEdit: TMenuItem;
    LADSMainMenuEditGlass: TMenuItem;
    LADSMainMenuTrace: TMenuItem;
    LADSMainMenuHelp: TMenuItem;
    N3: TMenuItem;
    About1: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    N4: TMenuItem;
    LADSMainMenuFileExit: TMenuItem;
    HelpTopics1: TMenuItem;
    LADSMainMenuFilePrint: TMenuItem;
    LADSMainMenuFileSave: TMenuItem;
    PrintDialog1: TPrintDialog;
    LADSMainMenuOptions: TMenuItem;
    LADSMainMenuSurface: TMenuItem;
    LADSMainMenuRay: TMenuItem;
    LADSMainMenuEnvironment: TMenuItem;
    TraceOptions1: TMenuItem;
    Optimization2: TMenuItem;
    LADSMainMenuList: TMenuItem;
    ListSurface: TMenuItem;
    ListRay: TMenuItem;
    N1: TMenuItem;
    GUIKeyboard1: TMenuItem;
    procedure Button1Click(Sender: TObject);
    procedure LADSMainMenuFileOpenClick(Sender: TObject);
    procedure LADSMainMenuFileExitClick(Sender: TObject);
    procedure LADSMainMenuFileSaveClick(Sender: TObject);
    procedure LADSMainMenuFilePrintClick(Sender: TObject);
    procedure LADSMainMenuFileInitializeClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure LADSMainMenuSurfaceClick(Sender: TObject);
    procedure LADSMainMenuRayClick(Sender: TObject);
    procedure ListSurfaceClick(Sender: TObject);
    procedure ListRayClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure LADSMainMenuFileNewSurfaceClick(Sender: TObject);
    procedure LADSMainMenuFileNewRayClick(Sender: TObject);
    procedure GUIKeyboard1Click(Sender: TObject);
    procedure LADSMainMenuTraceClick(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LADSMainForm: TLADSMainForm;

  StartUp                 : BOOLEAN;
  CalledFromFileNewSurf   : BOOLEAN;
  GetNewSurfaceData       : BOOLEAN;
  GetNewRayData           : BOOLEAN;
  CalledFromMainMenuSurf  : BOOLEAN;
  CalledFromFileNewRay    : BOOLEAN;
  CalledFromMainMenuRay   : BOOLEAN;
  UserGaveUp              : BOOLEAN;
  Valid                   : BOOLEAN;

implementation

uses LADSHelpUnit,
     LADSSurfaceOpsUnit,
     LADSRayOpsUnit,
     LADSData,
     LADSTraceUnit,
     LADSListUnit,
     LADSListSurfOpsUnit,
     LADSListRayOpsUnit,
     ExpertIO,
     LADSInitUnit,
     LADSArchiveUnit,
     LADSq1Unit,
     LADSq3Unit,
     LADSSplashScreenUnit,
     LADSGUIvsCommanddlgUnit,
     LADSCommandIOMemoUnit,
     LADSLensDataEntry, LADSRayDataEntry;

{$R *.DFM}

procedure TLADSMainForm.Button1Click(Sender: TObject);
begin

  Application.Terminate

end;

(**  A01_PROCESS_COMMAND  *****************************************************
******************************************************************************)


PROCEDURE A01_PROCESS_COMMAND;

BEGIN

  IF ABB_EXECUTE_TRACE THEN
    F01_EXECUTE_TRACE
  ELSE
  IF ABZ_ARCHIVE_DATA THEN
    BEGIN
      Q060_REQUEST_ARCHIVE_COMMAND;
      IF NOT S01AB_USER_IS_DONE THEN
	G01_ARCHIVE_DATA
    END;

  IF NOT S01AD_END_EXECUTION_DESIRED THEN
    Q010_REQUEST_COMMAND

END;




procedure TLADSMainForm.LADSMainMenuFileOpenClick(Sender: TObject);

  VAR
      FileExtension  : STRING;

begin

  IF OpenDialog1.Execute THEN
    BEGIN
      Z01_INITIALIZE;
      AKZ_ARCHIVE_FILE_NAME := OpenDialog1.FileName;
      FileExtension := ExtractFileExt (AKZ_ARCHIVE_FILE_NAME);
      AED_TRANSFER_SURFACE_DATA           := TRUE;
      AEE_TRANSFER_RAY_DATA	          := TRUE;
      AEF_TRANSFER_OPTION_DATA            := TRUE;
      AEG_TRANSFER_ENVIRONMENT_DATA       := TRUE;
      AKA_PUT_DATA_IN_TEMPORARY_STORAGE   := FALSE;
      AKB_GET_DATA_FROM_TEMPORARY_STORAGE := FALSE;
      AKC_PUT_DATA_IN_PERMANENT_STORAGE   := FALSE;
      AKD_GET_DATA_FROM_PERMANENT_STORAGE := FALSE;
      IF (FileExtension = '.dat')
          OR (FileExtension = '.DAT')
          OR (FileExtension = '.daT')
          OR (FileExtension = '.dAt')
          OR (FileExtension = '.dAT')
          OR (FileExtension = '.Dat')
          OR (FileExtension = '.DaT')
          OR (FileExtension = '.DAt') THEN
        BEGIN
          AKB_GET_DATA_FROM_TEMPORARY_STORAGE := TRUE;
          G01_ARCHIVE_DATA
        END
      ELSE
        BEGIN
          AKD_GET_DATA_FROM_PERMANENT_STORAGE := TRUE;
          G01_ARCHIVE_DATA;
          CalledFromGUI := TRUE;
          WHILE S01AO_USE_ALTERNATE_INPUT_FILE DO
            A01_PROCESS_COMMAND;
          CalledFromGUI := FALSE
        END
    END
  ELSE
    CommandIOMemo.IOHistory.Lines.add ('No file name given')

end;

procedure TLADSMainForm.LADSMainMenuFileExitClick(Sender: TObject);
begin

  Application.Terminate

end;

procedure TLADSMainForm.LADSMainMenuFileSaveClick(Sender: TObject);

  VAR
      FileExtension  : STRING;

begin

  IF SaveDialog1.Execute THEN
    BEGIN
      AKZ_ARCHIVE_FILE_NAME := SaveDialog1.FileName;
      FileExtension := ExtractFileExt (AKZ_ARCHIVE_FILE_NAME);
      AED_TRANSFER_SURFACE_DATA           := TRUE;
      AEE_TRANSFER_RAY_DATA	          := TRUE;
      AEF_TRANSFER_OPTION_DATA            := TRUE;
      AEG_TRANSFER_ENVIRONMENT_DATA       := TRUE;
      AKA_PUT_DATA_IN_TEMPORARY_STORAGE   := FALSE;
      AKB_GET_DATA_FROM_TEMPORARY_STORAGE := FALSE;
      AKC_PUT_DATA_IN_PERMANENT_STORAGE   := FALSE;
      AKD_GET_DATA_FROM_PERMANENT_STORAGE := FALSE;
      IF (FileExtension = '.dat')
          OR (FileExtension = '.DAT') THEN
        BEGIN
          AKA_PUT_DATA_IN_TEMPORARY_STORAGE := TRUE;
          G01_ARCHIVE_DATA
        END
      ELSE
        BEGIN
          AKC_PUT_DATA_IN_PERMANENT_STORAGE := TRUE;
          G01_ARCHIVE_DATA
        END
    END
  ELSE
    CommandIOMemo.IOHistory.Lines.add ('No file name given')


end;

procedure TLADSMainForm.LADSMainMenuFilePrintClick(Sender: TObject);

  VAR
      FoundASurface         : BOOLEAN;
      FoundARay             : BOOLEAN;
      NeedListFile          : BOOLEAN;
      NeedPrintout          : BOOLEAN;

      I                     : INTEGER;

      ListFileName          : STRING;
      CommandString         : STRING;

begin

  FoundASurface                  := FALSE;
  FoundARay                      := FALSE;
  NeedListFile                   := FALSE;
  NeedPrintout                   := TRUE;
  ListFullData                   := FALSE;
  ListParametersAlreadyAvailable := TRUE;
  ListSurfacesAndRays            := FALSE;

  FirstSurface                   := 1;
  LastSurface                    := 1;
  FirstRay                       := 1;
  LastRay                        := 1;

  ListFileName                   := '';
  CommandString                  := '';

  FOR I := 1 TO CZAB_MAX_NUMBER_OF_SURFACES DO
    BEGIN
      IF ZBA_SURFACE [I].ZBB_SPECIFIED THEN
        BEGIN
          FoundASurface := TRUE;
          LastSurface := I
        END
    END;

  FOR I := 1 TO CZAC_MAX_NUMBER_OF_RAYS DO
    BEGIN
      IF ZNA_RAY [I].ZNB_SPECIFIED THEN
        BEGIN
          FoundARay := TRUE;
          LastRay := I
        END
    END;

  IF FoundASurface
      OR FoundARay THEN
    BEGIN
      IF PrintDialog1.Execute THEN
        BEGIN
          IF FoundASurface
              AND FoundARay THEN
            ListSurfacesAndRays := TRUE
          ELSE
          IF FoundASurface THEN
            CommandString := CDAB_LIST_SURFACES
          ELSE
            CommandString := CDAC_LIST_RAYS;
          ListInputData (NeedListFile, NeedPrintout,
              CommandString, ListfileName);
        END
      ELSE
        ShowMessage ('Printer not available.')
    END
  ELSE
    ShowMessage ('No data available to print.');

  ListParametersAlreadyAvailable := FALSE;
  ListSurfacesAndRays := FALSE

end;

procedure TLADSMainForm.LADSMainMenuFileInitializeClick(Sender: TObject);
begin

  IF MessageDlg ('You are about to reset all data to default values.' +
      Chr (10) + '  Do you wish to proceed with initialization?',
      mtConfirmation, mbYesNoCancel, 0) = mrYes THEN
    Y005_INITIALIZE_LADS

end;

procedure TLADSMainForm.About1Click(Sender: TObject);
begin

  AboutBox.ShowModal

end;

procedure TLADSMainForm.LADSMainMenuSurfaceClick(Sender: TObject);
begin

  CalledFromMainMenuSurf := TRUE;

  UserGaveUp := FALSE;
  Valid := FALSE;

  SurfaceOpsDlg.ShowModal;

  IF Valid THEN
    LensDataEntryForm.ShowModal;

  CalledFromMainMenuSurf := FALSE

end;

procedure TLADSMainForm.LADSMainMenuRayClick(Sender: TObject);
begin

  CalledFromMainMenuRay := TRUE;

  UserGaveUp := FALSE;
  Valid := FALSE;

  RayOpsDlg.ShowModal;

  IF Valid THEN
    RayDataEntryForm.ShowModal;

  CalledFromMainMenuRay := FALSE

end;

procedure TLADSMainForm.ListSurfaceClick(Sender: TObject);
begin

  ListSurfaceOpsDlg.ShowModal

end;

procedure TLADSMainForm.ListRayClick(Sender: TObject);
begin

  ListRayOpsDlg.ShowModal

end;

procedure TLADSMainForm.FormActivate(Sender: TObject);
begin

  IF StartUp THEN
    BEGIN
      StartUp := FALSE;
      LADSSplashScreenForm.Show;
      Y005_INITIALIZE_LADS
    END

end;

procedure TLADSMainForm.LADSMainMenuFileNewSurfaceClick(Sender: TObject);
begin

  CalledFromFileNewSurf := TRUE;

  UserGaveUp := FALSE;
  Valid := FALSE;

  SurfaceOpsDlg.ShowModal;

  IF Valid THEN
    LensDataEntryForm.ShowModal;

  CalledFromFileNewSurf := FALSE

end;

procedure TLADSMainForm.LADSMainMenuFileNewRayClick(Sender: TObject);
begin

  CalledFromFileNewRay := TRUE;

  UserGaveUp := FALSE;
  Valid := FALSE;

  RayOpsDlg.ShowModal;

  IF Valid THEN
    RayDataEntryForm.ShowModal;

  CalledFromFileNewRay := FALSE

end;

procedure TLADSMainForm.GUIKeyboard1Click(Sender: TObject);
begin

  GUIvsCommanddlg.ShowModal;

  IF GUIvsCommanddlg.GUISelectButton.Checked THEN
    BEGIN
      GUIvsCommanddlg.Close
    END
  ELSE
  IF GUIvsCommanddlg.KeyboardSelectButton.Checked THEN
    BEGIN
      GUIvsCommanddlg.Close;
      (*LADSMainForm.SetFocus;*)
      Z01_INITIALIZE;
      S01AO_USE_ALTERNATE_INPUT_FILE := TRUE;
      S01AG_ALTERNATE_INPUT_FILE_NAME := 'LADSCMND.TXT';
      Q010_REQUEST_COMMAND;
      WHILE NOT S01AD_END_EXECUTION_DESIRED DO
        A01_PROCESS_COMMAND
      (*LADSMainForm.SetFocus*)
    END
  ELSE
    BEGIN
    END

end;

procedure TLADSMainForm.LADSMainMenuTraceClick(Sender: TObject);
begin

  F01_EXECUTE_TRACE

end;

procedure TLADSMainForm.FormClick(Sender: TObject);
begin

  KeyboardActivityDetected := TRUE

end;

procedure TLADSMainForm.FormKeyPress(Sender: TObject; var Key: Char);
begin

  KeyboardActivityDetected := TRUE

end;

initialization

  StartUp := TRUE;
  CalledFromFileNewSurf := FALSE;
  CalledFromMainMenuSurf := FALSE;
  GetNewSurfaceData := FALSE;
  GetNewRayData := FALSE;
  CalledFromMainMenuRay := FALSE;
  CalledFromFileNewRay := FALSE;
  UserGaveUp := FALSE;
  Valid := FALSE

end.
