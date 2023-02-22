unit LADSRayOpsUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, OkCancl1, Mask, Dialogs;

type
  TRayOpsDlg = class(TOKBottomDlg)
    HelpBtn: TButton;
    NewReplaceButton: TRadioButton;
    InsertButton: TRadioButton;
    DeleteButton: TRadioButton;
    CopyButton: TRadioButton;
    MoveButton: TRadioButton;
    RayOrd: TMaskEdit;
    Bevel2: TBevel;
    FirstRayInRange: TMaskEdit;
    LastRayInRange: TMaskEdit;
    ToLabel: TLabel;
    DestinationRay: TMaskEdit;
    DestinationRayLabel: TLabel;
    RayRangeLabel: TLabel;
    Label4: TLabel;
    ReviseButton: TRadioButton;
    SleepButton: TRadioButton;
    WakeButton: TRadioButton;
    Memo1: TMemo;
    Label1: TLabel;
    procedure HelpBtnClick(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure CopyButtonClick(Sender: TObject);
    procedure MoveButtonClick(Sender: TObject);
    procedure SleepButtonClick(Sender: TObject);
    procedure WakeButtonClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure NewReplaceButtonClick(Sender: TObject);
    procedure InsertButtonClick(Sender: TObject);
    procedure ReviseButtonClick(Sender: TObject);
    procedure ValidateFormContents(Sender: TObject;
      var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RayOpsDlg: TRayOpsDlg;

implementation

  USES
      LADSData,
      LADSInitUnit,
      LADSMainFormUnit;

{$R *.DFM}

procedure TRayOpsDlg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TRayOpsDlg.DeleteButtonClick(Sender: TObject);
begin

  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.FirstRayInRange.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := FALSE;
  RayOpsDlg.DestinationRay.Enabled := FALSE

end;

procedure TRayOpsDlg.CopyButtonClick(Sender: TObject);
begin

  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.FirstRayInRange.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := TRUE;
  RayOpsDlg.DestinationRay.Enabled := TRUE

end;

procedure TRayOpsDlg.MoveButtonClick(Sender: TObject);
begin

  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.FirstRayInRange.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := TRUE;
  RayOpsDlg.DestinationRay.Enabled := TRUE

end;

procedure TRayOpsDlg.SleepButtonClick(Sender: TObject);
begin
  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.FirstRayInRange.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := FALSE;
  RayOpsDlg.DestinationRay.Enabled := FALSE

end;

procedure TRayOpsDlg.WakeButtonClick(Sender: TObject);
begin
  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.FirstRayInRange.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := FALSE;
  RayOpsDlg.DestinationRay.Enabled := FALSE

end;

procedure TRayOpsDlg.NewReplaceButtonClick(Sender: TObject);
begin
  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.RayOrd.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := FALSE;
  RayOpsDlg.DestinationRay.Enabled := FALSE

end;

procedure TRayOpsDlg.InsertButtonClick(Sender: TObject);
begin
  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.RayOrd.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := FALSE;
  RayOpsDlg.DestinationRay.Enabled := FALSE

end;

procedure TRayOpsDlg.ReviseButtonClick(Sender: TObject);
begin
  inherited;

  RayOpsDlg.Memo1.Text := '';
  RayOpsDlg.FirstRayInRange.Text := '';
  RayOpsDlg.LastRayInRange.Text := '';
  RayOpsDlg.DestinationRay.Text := '';
  RayOpsDlg.RayOrd.Text := '';

  RayOpsDlg.RayOrd.SetFocus;

  RayOpsDlg.DestinationRayLabel.Enabled := FALSE;
  RayOpsDlg.DestinationRay.Enabled := FALSE

end;

procedure TRayOpsDlg.FormActivate(Sender: TObject);
begin

  inherited;

  IF CalledFromFileNewRay THEN
    BEGIN
      RayOpsDlg.InsertButton.Enabled := FALSE;
      RayOpsDlg.DeleteButton.Enabled := FALSE;
      RayOpsDlg.CopyButton.Enabled := FALSE;
      RayOpsDlg.MoveButton.Enabled := FALSE;
      RayOpsDlg.ReviseButton.Enabled := FALSE;
      RayOpsDlg.SleepButton.Enabled := FALSE;
      RayOpsDlg.WakeButton.Enabled := FALSE;
      RayOpsDlg.DestinationRay.Enabled := FALSE;
      RayOpsDlg.DestinationRayLabel.Enabled := FALSE;
      RayOpsDlg.RayRangeLabel.Enabled := FALSE;
      RayOpsDlg.ToLabel.Enabled := FALSE;
      RayOpsDlg.FirstRayInRange.Enabled := FALSE;
      RayOpsDlg.LastRayInRange.Enabled := FALSE;
      RayOpsDlg.NewReplaceButton.Checked := TRUE;
      RayOpsDlg.RayOrd.SetFocus
    END
  ELSE
  IF CalledFromMainMenuRay THEN
    BEGIN
      RayOpsDlg.InsertButton.Enabled := TRUE;
      RayOpsDlg.DeleteButton.Enabled := TRUE;
      RayOpsDlg.CopyButton.Enabled := TRUE;
      RayOpsDlg.MoveButton.Enabled := TRUE;
      RayOpsDlg.ReviseButton.Enabled := TRUE;
      RayOpsDlg.SleepButton.Enabled := TRUE;
      RayOpsDlg.WakeButton.Enabled := TRUE;
      RayOpsDlg.DestinationRay.Enabled := TRUE;
      RayOpsDlg.DestinationRayLabel.Enabled := TRUE;
      RayOpsDlg.RayRangeLabel.Enabled := TRUE;
      RayOpsDlg.ToLabel.Enabled := TRUE;
      RayOpsDlg.FirstRayInRange.Enabled := TRUE;
      RayOpsDlg.LastRayInRange.Enabled := TRUE;
      RayOpsDlg.NewReplaceButton.Enabled := TRUE;
      RayOpsDlg.ReviseButton.Checked := TRUE;
      RayOpsDlg.RayOrd.SetFocus
    END

end;

procedure TRayOpsDlg.ValidateFormContents(Sender: TObject;
  var Action: TCloseAction);

  VAR
      ContinueValidation  : BOOLEAN;

      IntegerNumber       : INTEGER;
      CODE                : INTEGER;
      FirstRay        : INTEGER;
      LastRay         : INTEGER;
      DestRay         : INTEGER;

begin
  inherited;

  ContinueValidation := TRUE;

  RayOpsDlg.Memo1.Clear;

  GetNewRayData := FALSE;

  IF RayOpsDlg.NewReplaceButton.Checked
      OR RayOpsDlg.InsertButton.Checked
      OR RayOpsDlg.ReviseButton.Checked THEN
    BEGIN
      IF Length (RayOpsDlg.RayOrd.Text) = 0 THEN
        BEGIN
          UserGaveUp := TRUE;
          ContinueValidation := FALSE
        END
    END;

  IF RayOpsDlg.DeleteButton.Checked
      OR RayOpsDlg.SleepButton.Checked
      OR RayOpsDlg.WakeButton.Checked THEN
    BEGIN
      IF (Length (RayOpsDlg.FirstRayInRange.Text) = 0)
          OR (Length (RayOpsDlg.LastRayInRange.Text) = 0) THEN
        BEGIN
          UserGaveUp := TRUE;
          ContinueValidation := FALSE
        END
    END;

  IF RayOpsDlg.CopyButton.Checked
      OR RayOpsDlg.MoveButton.Checked THEN
    BEGIN
      IF (Length (RayOpsDlg.FirstRayInRange.Text) = 0)
          OR (Length (RayOpsDlg.LastRayInRange.Text) = 0)
          OR (Length (RayOpsDlg.DestinationRay.Text) = 0) THEN
        BEGIN
          UserGaveUp := TRUE;
          ContinueValidation := FALSE
        END
    END;

  IF ContinueValidation THEN
    IF RayOpsDlg.NewReplaceButton.Checked
        OR RayOpsDlg.InsertButton.Checked
        OR RayOpsDlg.ReviseButton.Checked THEN
      BEGIN
        VAL (RayOpsDlg.RayOrd.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAC_MAX_NUMBER_OF_RAYS)
              AND (IntegerNumber > 0) THEN
            BEGIN
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              RayOpsDlg.Memo1.Text := 'Ray number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAC_MAX_NUMBER_OF_RAYS);
              RayOpsDlg.RayOrd.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            RayOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            RayOpsDlg.RayOrd.SetFocus
          END
      END;

  IF ContinueValidation THEN
    IF RayOpsDlg.DeleteButton.Checked
        OR RayOpsDlg.SleepButton.Checked
        OR RayOpsDlg.WakeButton.Checked
        OR RayOpsDlg.CopyButton.Checked
        OR RayOpsDlg.MoveButton.Checked THEN
      BEGIN
        VAL (RayOpsDlg.FirstRayInRange.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAC_MAX_NUMBER_OF_RAYS)
              AND (IntegerNumber > 0) THEN
            BEGIN
              FirstRay := IntegerNumber
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              RayOpsDlg.Memo1.Text := 'Ray number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAC_MAX_NUMBER_OF_RAYS);
              RayOpsDlg.FirstRayInRange.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            RayOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            RayOpsDlg.FirstRayInRange.SetFocus
          END
      END;

  IF ContinueValidation THEN
    IF RayOpsDlg.DeleteButton.Checked
        OR RayOpsDlg.SleepButton.Checked
        OR RayOpsDlg.WakeButton.Checked
        OR RayOpsDlg.CopyButton.Checked
        OR RayOpsDlg.MoveButton.Checked THEN
      BEGIN
        VAL (RayOpsDlg.LastRayInRange.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAC_MAX_NUMBER_OF_RAYS)
              AND (IntegerNumber > 0) THEN
            BEGIN
              LastRay := IntegerNumber
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              RayOpsDlg.Memo1.Text := 'Ray number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAC_MAX_NUMBER_OF_RAYS);
              RayOpsDlg.LastRayInRange.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            RayOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            RayOpsDlg.LastRayInRange.SetFocus
          END;
        IF ContinueValidation THEN
          IF (FirstRay <= LastRay) THEN
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              RayOpsDlg.Memo1.Text := 'ERROR: Last ray in range must ' +
                  'be greater than first ray in range.  Please ' +
                  're-enter.';
              RayOpsDlg.LastRayInRange.SetFocus
            END
      END;

  IF ContinueValidation THEN
    IF RayOpsDlg.CopyButton.Checked
        OR RayOpsDlg.MoveButton.Checked THEN
      BEGIN
        VAL (RayOpsDlg.DestinationRay.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAC_MAX_NUMBER_OF_RAYS)
              AND (IntegerNumber > 0) THEN
            BEGIN
              DestRay := IntegerNumber
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              RayOpsDlg.Memo1.Text := 'Ray number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAC_MAX_NUMBER_OF_RAYS);
              RayOpsDlg.DestinationRay.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            RayOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            RayOpsDlg.DestinationRay.SetFocus
          END;
        IF ContinueValidation THEN
          IF (DestRay <= FirstRay)
              OR (DestRay > LastRay) THEN
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              RayOpsDlg.Memo1.Text := 'ERROR: Destination ray must ' +
                  'be less than or equal to the first ray in the range, ' +
                  'or greater than the last ray in the range.  Please ' +
                  're-enter.';
              RayOpsDlg.DestinationRay.SetFocus
            END
      END;

  IF ContinueValidation THEN
    BEGIN
      RayOrdinal := IntegerNumber;
      IF RayOpsDlg.NewReplaceButton.Checked THEN
        BEGIN
          IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
            BEGIN
              IF MessageDlg ('Ray ' + IntToStr (RayOrdinal) +
                  ' already in use.  Replace it?',
                  mtConfirmation, mbYesNoCancel, 0) = mrYes THEN
                BEGIN
                  Y010_INITIALIZE_A_RAY (RayOrdinal);
                  Valid := TRUE
                END
              ELSE
                BEGIN
                  ContinueValidation := FALSE;
                  RayOpsDlg.Memo1.Text := 'Choose new ray';
                  RayOpsDlg.RayOrd.Text := '';
                  RayOpsDlg.RayOrd.SetFocus
                END
            END
          ELSE
            BEGIN
              Valid := TRUE;
              GetNewRayData := TRUE
            END
        END
      ELSE
      IF RayOpsDlg.ReviseButton.Checked THEN
        BEGIN
          IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
            Valid := TRUE
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              RayOpsDlg.Memo1.Text := 'ERROR: Ray ' +
                  IntToStr (RayOrdinal) +
                  ' not specified.  Please choose a different ray.';
              RayOpsDlg.RayOrd.Text := '';
              RayOpsDlg.RayOrd.SetFocus
            END
        END
    END;

  IF Valid
      OR UserGaveUp THEN
  ELSE
    Action := caNone

end;

end.

