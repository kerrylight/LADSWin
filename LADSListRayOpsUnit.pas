unit LADSListRayOpsUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, OkCancl1, Mask, Dialogs;

type
  TListRayOpsDlg = class(TOKBottomDlg)
    HelpBtn: TButton;
    RayBriefListing: TRadioButton;
    RayFullListing: TRadioButton;
    SaveRayListOutputToFile: TCheckBox;
    RayListRangeLimit1: TMaskEdit;
    RayListRangeLimit2: TMaskEdit;
    toLabel: TLabel;
    RayRangeLabel: TLabel;
    ProduceRayListHardcopy: TCheckBox;
    Label1: TLabel;
    RayDataListingFileDlg: TSaveDialog;
    ValidationMessage: TMemo;
    PrintRayData: TPrintDialog;
    procedure HelpBtnClick(Sender: TObject);
    procedure EnableBriefListing(Sender: TObject);
    procedure EnableFullListing(Sender: TObject);
    procedure ValidateFirstRayInRange(Sender: TObject);
    procedure ValidateLastRayInRange(Sender: TObject);
    procedure InitializeData(Sender: TObject);
    procedure ValidateData(Sender: TObject; var Action: TCloseAction);
    procedure CancelRayList(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ListRayOpsDlg: TListRayOpsDlg;

implementation

USES LADSData,
     LADSInitUnit,
     LADSListUnit;

  VAR
      UserWantsToCancel  : BOOLEAN;

{$R *.DFM}

procedure TListRayOpsDlg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TListRayOpsDlg.EnableBriefListing(Sender: TObject);
begin
  inherited;
  
  ListFullData := FALSE

end;

procedure TListRayOpsDlg.EnableFullListing(Sender: TObject);
begin
  inherited;

  ListFullData := TRUE

end;

procedure TListRayOpsDlg.ValidateFirstRayInRange(Sender: TObject);

  VAR
      CODE           : INTEGER;
      IntegerNumber  : INTEGER;

begin
  inherited;

  ValidationMessage.Clear;

  IF Length (RayListRangeLimit1.Text) = 0 THEN
    BEGIN
      ValidationMessage.Text := 'No input.  Restoring default ' +
          'value for first ray in list range.';
      RayListRangeLimit1.Text := IntToStr (DefaultRayOrdinal);
      FirstRay := DefaultRayOrdinal
    END
  ELSE
    BEGIN
      VAL (RayListRangeLimit1.Text, IntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (IntegerNumber > 0)
            AND (IntegerNumber <= CZAC_MAX_NUMBER_OF_RAYS) THEN
          FirstRay := IntegerNumber
        ELSE
          BEGIN
            ValidationMessage.Text := 'ERROR: Ray ordinal ' +
                'number must be an integer in the range 1 to ' +
                IntToStr (CZAC_MAX_NUMBER_OF_RAYS) + '.  Please re-enter.';
            RayListRangeLimit1.SetFocus
          END
      ELSE
        BEGIN
          ValidationMessage.Text := 'ERROR: Non-numeric or ' +
              'non-integer value.  Please re-enter.';
          RayListRangeLimit1.SetFocus
        END
    END

end;

procedure TListRayOpsDlg.ValidateLastRayInRange(Sender: TObject);

  VAR
      CODE           : INTEGER;
      IntegerNumber  : INTEGER;

begin
  inherited;

  ValidationMessage.Clear;

  IF Length (RayListRangeLimit2.Text) = 0 THEN
    BEGIN
      ValidationMessage.Text := 'No input.  Restoring default ' +
          'value for last ray in list range.';
      RayListRangeLimit2.Text := IntToStr (CZAC_MAX_NUMBER_OF_RAYS);
      LastRay := CZAC_MAX_NUMBER_OF_RAYS
    END
  ELSE
    BEGIN
      VAL (RayListRangeLimit2.Text, IntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (IntegerNumber > 0)
            AND (IntegerNumber <= CZAC_MAX_NUMBER_OF_RAYS) THEN
          LastRay := IntegerNumber
        ELSE
          BEGIN
            ValidationMessage.Text := 'ERROR: Ray ordinal ' +
                'number must be an integer in the range 1 to ' +
                IntToStr (CZAC_MAX_NUMBER_OF_RAYS) + '.  Please re-enter.';
            RayListRangeLimit2.SetFocus
          END
      ELSE
        BEGIN
          ValidationMessage.Text := 'ERROR: Non-numeric or ' +
              'non-integer value.  Please re-enter.';
          RayListRangeLimit2.SetFocus
        END
    END

end;

procedure TListRayOpsDlg.InitializeData(Sender: TObject);
begin
  inherited;

  RayBriefListing.Checked := FALSE;
  RayFullListing.Checked := FALSE;
  RayListRangeLimit1.Text := '';
  RayListRangeLimit2.Text := '';
  SaveRayListOutputToFile.Checked := FALSE;
  ProduceRayListHardcopy.Checked := FALSE;
  ValidationMessage.Text := '';
  UserWantsToCancel := FALSE

end;

procedure TListRayOpsDlg.ValidateData(Sender: TObject;
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
      IF (NOT RayBriefListing.Checked)
          AND (NOT RayFullListing.Checked) THEN
        BEGIN
          ValidationMessage.Text := 'ERROR: Please select listing type';
          Valid := FALSE;
          Action := caNone
        END;
      IF (Length (RayListRangeLimit1.Text) = 0)
          OR (Length (RayListRangeLimit2.Text) = 0) THEN
        BEGIN
          ValidationMessage.Text := 'ERROR: Ray range value(s) missing';
          Valid := FALSE;
          Action := caNone
        END;
      IF Valid THEN
        BEGIN
          ListfileName := '';
          IF SaveRayListOutputToFile.Checked THEN
            BEGIN
              NeedListFile := TRUE;
              IF RayDataListingFileDlg.Execute THEN
                ListFileName := RayDataListingFileDlg.FileName
              ELSE
                NeedListFile := FALSE
            END
          ELSE
            NeedListFile := FALSE;
          IF ProduceRayListHardcopy.Checked THEN
            BEGIN
              NeedPrintout := TRUE;
              IF PrintRayData.Execute THEN
              ELSE
                NeedPrintout := FALSE
            END
          ELSE
            NeedPrintout := FALSE;
          CommandString := CDAC_LIST_RAYS;
          ListParametersAlreadyAvailable := TRUE;
          ListInputData (NeedListFile, NeedPrintout,
              CommandString, ListfileName);
          ListParametersAlreadyAvailable := FALSE
        END
    END

end;

procedure TListRayOpsDlg.CancelRayList(Sender: TObject);
begin
  inherited;

  UserWantsToCancel := TRUE

end;

end.

