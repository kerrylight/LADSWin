unit LADSListSurfOpsUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, OkCancl1, Mask, Dialogs;

type
  TListSurfaceOpsDlg = class(TOKBottomDlg)
    HelpBtn: TButton;
    SurfaceBriefListing: TRadioButton;
    SurfaceFullListing: TRadioButton;
    SaveSurfListOutputToFile: TCheckBox;
    ProduceSurfListHardcopy: TCheckBox;
    SurfListRangeLimit1: TMaskEdit;
    SurfListRangeLimit2: TMaskEdit;
    toLabel: TLabel;
    SurfaceRangeLabel: TLabel;
    ValidationMessage: TMemo;
    Label1: TLabel;
    SurfaceDataListingFileDlg: TSaveDialog;
    PrintSurfaceData: TPrintDialog;
    procedure HelpBtnClick(Sender: TObject);
    procedure EnableBriefListing(Sender: TObject);
    procedure EnableFullListing(Sender: TObject);
    procedure ValidateFirstSurfInRange(Sender: TObject);
    procedure ValidateLastSurfInRange(Sender: TObject);
    procedure InitializeData(Sender: TObject);
    procedure ValidateData(Sender: TObject; var Action: TCloseAction);
    procedure CancelSurfaceList(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ListSurfaceOpsDlg: TListSurfaceOpsDlg;

implementation

USES LADSData,
     LADSInitUnit,
     LADSListUnit;

  VAR
      UserWantsToCancel  : BOOLEAN;

{$R *.DFM}

procedure TListSurfaceOpsDlg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TListSurfaceOpsDlg.EnableBriefListing(Sender: TObject);
begin
  inherited;

  ListFullData := FALSE

end;

procedure TListSurfaceOpsDlg.EnableFullListing(Sender: TObject);
begin
  inherited;

  ListFullData := TRUE

end;

procedure TListSurfaceOpsDlg.ValidateFirstSurfInRange(Sender: TObject);

  VAR
      CODE           : INTEGER;
      IntegerNumber  : INTEGER;

begin
  inherited;

  ValidationMessage.Clear;

  IF Length (SurfListRangeLimit1.Text) = 0 THEN
    BEGIN
      ValidationMessage.Text := 'No input.  Restoring default ' +
          'value for first surface in list range.';
      SurfListRangeLimit1.Text := IntToStr (DefaultSurfaceOrdinal);
      FirstSurface := DefaultSurfaceOrdinal
    END
  ELSE
    BEGIN
      VAL (SurfListRangeLimit1.Text, IntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (IntegerNumber > 0)
            AND (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES) THEN
          FirstSurface := IntegerNumber
        ELSE
          BEGIN
            ValidationMessage.Text := 'ERROR: Surface ordinal ' +
                'number must be an integer in the range 1 to ' +
                IntToStr (CZAB_MAX_NUMBER_OF_SURFACES) + '.  Please re-enter.';
            SurfListRangeLimit1.SetFocus
          END
      ELSE
        BEGIN
          ValidationMessage.Text := 'ERROR: Non-numeric or ' +
              'non-integer value.  Please re-enter.';
          SurfListRangeLimit1.SetFocus
        END
    END

end;

procedure TListSurfaceOpsDlg.ValidateLastSurfInRange(Sender: TObject);

  VAR
      CODE           : INTEGER;
      IntegerNumber  : INTEGER;

begin
  inherited;

  ValidationMessage.Clear;

  IF Length (SurfListRangeLimit2.Text) = 0 THEN
    BEGIN
      ValidationMessage.Text := 'No input.  Restoring default ' +
          'value for last surface in list range.';
      SurfListRangeLimit2.Text := IntToStr (CZAB_MAX_NUMBER_OF_SURFACES);
      LastSurface := CZAB_MAX_NUMBER_OF_SURFACES
    END
  ELSE
    BEGIN
      VAL (SurfListRangeLimit2.Text, IntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (IntegerNumber > 0)
            AND (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES) THEN
          LastSurface := IntegerNumber
        ELSE
          BEGIN
            ValidationMessage.Text := 'ERROR: Surface ordinal ' +
                'number must be an integer in the range 1 to ' +
                IntToStr (CZAB_MAX_NUMBER_OF_SURFACES) + '.  Please re-enter.';
            SurfListRangeLimit2.SetFocus
          END
      ELSE
        BEGIN
          ValidationMessage.Text := 'ERROR: Non-numeric or ' +
              'non-integer value.  Please re-enter.';
          SurfListRangeLimit2.SetFocus
        END
    END

end;

procedure TListSurfaceOpsDlg.InitializeData(Sender: TObject);
begin
  inherited;

  SurfaceBriefListing.Checked := FALSE;
  SurfaceFullListing.Checked := FALSE;
  SurfListRangeLimit1.Text := '';
  SurfListRangeLimit2.Text := '';
  SaveSurfListOutputToFile.Checked := FALSE;
  ProduceSurfListHardcopy.Checked := FALSE;
  ValidationMessage.Text := '';
  UserWantsToCancel := FALSE

end;

procedure TListSurfaceOpsDlg.ValidateData(Sender: TObject;
  var Action: TCloseAction);

  VAR
      Valid           : BOOLEAN;
      NeedListFile    : BOOLEAN;
      NeedPrintout    : BOOLEAN;
      CommandString   : STRING;
      ListfileName    : STRING;

begin
  inherited;

  IF UserWantsToCancel THEN
  ELSE
    BEGIN
      Valid := TRUE;
      IF (NOT SurfaceBriefListing.Checked)
          AND (NOT SurfaceFullListing.Checked) THEN
        BEGIN
          ValidationMessage.Text := 'ERROR: Please select listing type';
          Valid := FALSE;
          Action := caNone
        END;
      IF (Length (SurfListRangeLimit1.Text) = 0)
          OR (Length (SurfListRangeLimit2.Text) = 0) THEN
        BEGIN
          ValidationMessage.Text := 'ERROR: Surface range value(s) missing';
          Valid := FALSE;
          Action := caNone
        END;
      IF Valid THEN
        BEGIN
          ListfileName := '';
          IF SaveSurfListOutputToFile.Checked THEN
            BEGIN
              NeedListFile := TRUE;
              IF SurfaceDataListingFileDlg.Execute THEN
                ListFileName := SurfaceDataListingFileDlg.FileName
              ELSE
                NeedListFile := FALSE
            END
          ELSE
            NeedListFile := FALSE;
          IF ProduceSurfListHardcopy.Checked THEN
            BEGIN
              NeedPrintout := TRUE;
              IF PrintSurfaceData.Execute THEN
              ELSE
                NeedPrintout := FALSE
            END
          ELSE
            NeedPrintout := FALSE;
          CommandString := CDAB_LIST_SURFACES;
          ListParametersAlreadyAvailable := TRUE;
          ListInputData (NeedListFile, NeedPrintout,
              CommandString, ListfileName);
          ListParametersAlreadyAvailable := FALSE
        END
    END

end;

procedure TListSurfaceOpsDlg.CancelSurfaceList(Sender: TObject);
begin
  inherited;

  UserWantsToCancel := TRUE

end;

end.

