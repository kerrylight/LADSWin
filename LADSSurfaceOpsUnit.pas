unit LADSSurfaceOpsUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, OkCancl1, Mask, Dialogs;

type
  TSurfaceOpsDlg = class(TOKBottomDlg)
    HelpBtn: TButton;
    NewReplaceButton: TRadioButton;
    InsertButton: TRadioButton;
    DeleteButton: TRadioButton;
    CopyButton: TRadioButton;
    MoveButton: TRadioButton;
    SurfaceOrd: TMaskEdit;
    Bevel2: TBevel;
    FirstSurfInRange: TMaskEdit;
    LastSurfInRange: TMaskEdit;
    ToLabel: TLabel;
    DestinationSurface: TMaskEdit;
    DestinationSurfaceLabel: TLabel;
    SurfaceRangeLabel: TLabel;
    SurfaceLabel: TLabel;
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
    procedure NewReplaceButtonClick(Sender: TObject);
    procedure InitializeFormControls(Sender: TObject);
    procedure ReviseButtonClick(Sender: TObject);
    procedure ValidateFormContents(Sender: TObject;
      var Action: TCloseAction);
    procedure InsertButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SurfaceOpsDlg: TSurfaceOpsDlg;

implementation

  USES
      LADSData,
      LADSMainFormUnit,
      LADSLensDataEntry;

{$R *.DFM}

procedure TSurfaceOpsDlg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TSurfaceOpsDlg.DeleteButtonClick(Sender: TObject);
begin

  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.FirstSurfInRange.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := FALSE;
  SurfaceOpsDlg.DestinationSurface.Enabled := FALSE

end;

procedure TSurfaceOpsDlg.CopyButtonClick(Sender: TObject);
begin

  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.FirstSurfInRange.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := TRUE;
  SurfaceOpsDlg.DestinationSurface.Enabled := TRUE

end;

procedure TSurfaceOpsDlg.MoveButtonClick(Sender: TObject);
begin

  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.FirstSurfInRange.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := TRUE;
  SurfaceOpsDlg.DestinationSurface.Enabled := TRUE

end;

procedure TSurfaceOpsDlg.SleepButtonClick(Sender: TObject);
begin
  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.FirstSurfInRange.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := FALSE;
  SurfaceOpsDlg.DestinationSurface.Enabled := FALSE

end;

procedure TSurfaceOpsDlg.WakeButtonClick(Sender: TObject);
begin
  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.FirstSurfInRange.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := FALSE;
  SurfaceOpsDlg.DestinationSurface.Enabled := FALSE

end;

procedure TSurfaceOpsDlg.NewReplaceButtonClick(Sender: TObject);
begin
  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.SurfaceOrd.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := FALSE;
  SurfaceOpsDlg.DestinationSurface.Enabled := FALSE

end;

procedure TSurfaceOpsDlg.InsertButtonClick(Sender: TObject);
begin
  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.SurfaceOrd.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := FALSE;
  SurfaceOpsDlg.DestinationSurface.Enabled := FALSE

end;

procedure TSurfaceOpsDlg.ReviseButtonClick(Sender: TObject);
begin
  inherited;

  SurfaceOpsDlg.Memo1.Text := '';
  SurfaceOpsDlg.FirstSurfInRange.Text := '';
  SurfaceOpsDlg.LastSurfInRange.Text := '';
  SurfaceOpsDlg.DestinationSurface.Text := '';
  SurfaceOpsDlg.SurfaceOrd.Text := '';

  SurfaceOpsDlg.SurfaceOrd.SetFocus;

  SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := FALSE;
  SurfaceOpsDlg.DestinationSurface.Enabled := FALSE

end;

procedure TSurfaceOpsDlg.InitializeFormControls(Sender: TObject);
begin
  inherited;

  IF CalledFromFileNewSurf THEN
    BEGIN
      SurfaceOpsDlg.InsertButton.Enabled := FALSE;
      SurfaceOpsDlg.DeleteButton.Enabled := FALSE;
      SurfaceOpsDlg.CopyButton.Enabled := FALSE;
      SurfaceOpsDlg.MoveButton.Enabled := FALSE;
      SurfaceOpsDlg.ReviseButton.Enabled := FALSE;
      SurfaceOpsDlg.SleepButton.Enabled := FALSE;
      SurfaceOpsDlg.WakeButton.Enabled := FALSE;
      SurfaceOpsDlg.DestinationSurface.Enabled := FALSE;
      SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := FALSE;
      SurfaceOpsDlg.SurfaceRangeLabel.Enabled := FALSE;
      SurfaceOpsDlg.ToLabel.Enabled := FALSE;
      SurfaceOpsDlg.FirstSurfInRange.Enabled := FALSE;
      SurfaceOpsDlg.LastSurfInRange.Enabled := FALSE;
      SurfaceOpsDlg.NewReplaceButton.Checked := TRUE;
      SurfaceOpsDlg.SurfaceOrd.SetFocus
    END
  ELSE
  IF CalledFromMainMenuSurf THEN
    BEGIN
      SurfaceOpsDlg.InsertButton.Enabled := TRUE;
      SurfaceOpsDlg.DeleteButton.Enabled := TRUE;
      SurfaceOpsDlg.CopyButton.Enabled := TRUE;
      SurfaceOpsDlg.MoveButton.Enabled := TRUE;
      SurfaceOpsDlg.ReviseButton.Enabled := TRUE;
      SurfaceOpsDlg.SleepButton.Enabled := TRUE;
      SurfaceOpsDlg.WakeButton.Enabled := TRUE;
      SurfaceOpsDlg.DestinationSurface.Enabled := TRUE;
      SurfaceOpsDlg.DestinationSurfaceLabel.Enabled := TRUE;
      SurfaceOpsDlg.SurfaceRangeLabel.Enabled := TRUE;
      SurfaceOpsDlg.ToLabel.Enabled := TRUE;
      SurfaceOpsDlg.FirstSurfInRange.Enabled := TRUE;
      SurfaceOpsDlg.LastSurfInRange.Enabled := TRUE;
      SurfaceOpsDlg.NewReplaceButton.Enabled := TRUE;
      SurfaceOpsDlg.ReviseButton.Checked := TRUE;
      SurfaceOpsDlg.SurfaceOrd.SetFocus
    END

end;

procedure TSurfaceOpsDlg.ValidateFormContents(Sender: TObject;
  var Action: TCloseAction);

  VAR
      ContinueValidation  : BOOLEAN;

      IntegerNumber       : INTEGER;
      CODE                : INTEGER;
      FirstSurface        : INTEGER;
      LastSurface         : INTEGER;
      DestSurface         : INTEGER;

begin
  inherited;

  ContinueValidation := TRUE;

  SurfaceOpsDlg.Memo1.Clear;

  GetNewSurfaceData := FALSE;

  IF SurfaceOpsDlg.NewReplaceButton.Checked
      OR SurfaceOpsDlg.InsertButton.Checked
      OR SurfaceOpsDlg.ReviseButton.Checked THEN
    BEGIN
      IF Length (SurfaceOpsDlg.SurfaceOrd.Text) = 0 THEN
        BEGIN
          UserGaveUp := TRUE;
          ContinueValidation := FALSE
        END
    END;

  IF SurfaceOpsDlg.DeleteButton.Checked
      OR SurfaceOpsDlg.SleepButton.Checked
      OR SurfaceOpsDlg.WakeButton.Checked THEN
    BEGIN
      IF (Length (SurfaceOpsDlg.FirstSurfInRange.Text) = 0)
          OR (Length (SurfaceOpsDlg.LastSurfInRange.Text) = 0) THEN
        BEGIN
          UserGaveUp := TRUE;
          ContinueValidation := FALSE
        END
    END;

  IF SurfaceOpsDlg.CopyButton.Checked
      OR SurfaceOpsDlg.MoveButton.Checked THEN
    BEGIN
      IF (Length (SurfaceOpsDlg.FirstSurfInRange.Text) = 0)
          OR (Length (SurfaceOpsDlg.LastSurfInRange.Text) = 0)
          OR (Length (SurfaceOpsDlg.DestinationSurface.Text) = 0) THEN
        BEGIN
          UserGaveUp := TRUE;
          ContinueValidation := FALSE
        END
    END;

  IF ContinueValidation THEN
    IF SurfaceOpsDlg.NewReplaceButton.Checked
        OR SurfaceOpsDlg.InsertButton.Checked
        OR SurfaceOpsDlg.ReviseButton.Checked THEN
      BEGIN
        VAL (SurfaceOpsDlg.SurfaceOrd.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
              AND (IntegerNumber > 0) THEN
            BEGIN
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              SurfaceOpsDlg.Memo1.Text := 'Surface number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAB_MAX_NUMBER_OF_SURFACES);
              SurfaceOpsDlg.SurfaceOrd.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            SurfaceOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            SurfaceOpsDlg.SurfaceOrd.SetFocus
          END
      END;

  IF ContinueValidation THEN
    IF SurfaceOpsDlg.DeleteButton.Checked
        OR SurfaceOpsDlg.SleepButton.Checked
        OR SurfaceOpsDlg.WakeButton.Checked
        OR SurfaceOpsDlg.CopyButton.Checked
        OR SurfaceOpsDlg.MoveButton.Checked THEN
      BEGIN
        VAL (SurfaceOpsDlg.FirstSurfInRange.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
              AND (IntegerNumber > 0) THEN
            BEGIN
              FirstSurface := IntegerNumber
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              SurfaceOpsDlg.Memo1.Text := 'Surface number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAB_MAX_NUMBER_OF_SURFACES);
              SurfaceOpsDlg.FirstSurfInRange.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            SurfaceOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            SurfaceOpsDlg.FirstSurfInRange.SetFocus
          END
      END;

  IF ContinueValidation THEN
    IF SurfaceOpsDlg.DeleteButton.Checked
        OR SurfaceOpsDlg.SleepButton.Checked
        OR SurfaceOpsDlg.WakeButton.Checked
        OR SurfaceOpsDlg.CopyButton.Checked
        OR SurfaceOpsDlg.MoveButton.Checked THEN
      BEGIN
        VAL (SurfaceOpsDlg.LastSurfInRange.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
              AND (IntegerNumber > 0) THEN
            BEGIN
              LastSurface := IntegerNumber
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              SurfaceOpsDlg.Memo1.Text := 'Surface number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAB_MAX_NUMBER_OF_SURFACES);
              SurfaceOpsDlg.LastSurfInRange.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            SurfaceOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            SurfaceOpsDlg.LastSurfInRange.SetFocus
          END;
        IF ContinueValidation THEN
          IF (FirstSurface <= LastSurface) THEN
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              SurfaceOpsDlg.Memo1.Text := 'ERROR: Last surface in range must ' +
                  'be greater than first surface in range.  Please ' +
                  're-enter.';
              SurfaceOpsDlg.LastSurfInRange.SetFocus
            END
      END;

  IF ContinueValidation THEN
    IF SurfaceOpsDlg.CopyButton.Checked
        OR SurfaceOpsDlg.MoveButton.Checked THEN
      BEGIN
        VAL (SurfaceOpsDlg.DestinationSurface.Text, IntegerNumber, CODE);
        IF CODE = 0 THEN
          IF (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES)
              AND (IntegerNumber > 0) THEN
            BEGIN
              DestSurface := IntegerNumber
            END
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              SurfaceOpsDlg.Memo1.Text := 'Surface number out of valid ' +
                  'range of 1 --> ' +
                  IntToStr (CZAB_MAX_NUMBER_OF_SURFACES);
              SurfaceOpsDlg.DestinationSurface.SetFocus
            END
        ELSE
          BEGIN
            ContinueValidation := FALSE;
            SurfaceOpsDlg.Memo1.Text := 'Non-numeric value.  Please ' +
                're-enter.';
            SurfaceOpsDlg.DestinationSurface.SetFocus
          END;
        IF ContinueValidation THEN
          IF (DestSurface <= FirstSurface)
              OR (DestSurface > LastSurface) THEN
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              SurfaceOpsDlg.Memo1.Text := 'ERROR: Destination surface must ' +
                  'be less than or equal to the first surface in the range, ' +
                  'or greater than the last surface in the range.  Please ' +
                  're-enter.';
              SurfaceOpsDlg.DestinationSurface.SetFocus
            END
      END;

  IF ContinueValidation THEN
    BEGIN
      SurfaceOrdinal := IntegerNumber;
      IF SurfaceOpsDlg.NewReplaceButton.Checked THEN
        BEGIN
          IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
            BEGIN
            (*SurfaceOpsDlg.Visible := FALSE;
              Q970AB_OUTPUT_STRING := 'Surface ' +
                  IntToStr (SurfaceOrdinal) + ' already in use.  ' +
                  'Replace it?';
              Q970_REQUEST_PERMIT_TO_PROCEED;
              SurfaceOpsDlg.Visible := TRUE;*)
            (*IF Q970AA_OK_TO_PROCEED THEN*)
              IF MessageDlg ('Surface ' + IntToStr (SurfaceOrdinal) +
                  ' already in use.  Replace it?',
                  mtConfirmation, mbYesNoCancel, 0) = mrYes THEN
                BEGIN
                  ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA :=
                      ZEA_SURFACE_DATA_INITIALIZER;
                  Valid := TRUE
                END
              ELSE
                BEGIN
                  ContinueValidation := FALSE;
                  SurfaceOpsDlg.Memo1.Text := 'Choose new surface';
                  SurfaceOpsDlg.SurfaceOrd.Text := '';
                  SurfaceOpsDlg.SurfaceOrd.SetFocus
                END
            END
          ELSE
            BEGIN
              Valid := TRUE;
              GetNewSurfaceData := TRUE
            END
        END
      ELSE
      IF SurfaceOpsDlg.ReviseButton.Checked THEN
        BEGIN
          IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
            Valid := TRUE
          ELSE
            BEGIN
              ContinueValidation := FALSE;
              SurfaceOpsDlg.Memo1.Text := 'ERROR: Surface ' +
                  IntToStr (SurfaceOrdinal) +
                  ' not specified.  Please choose a different surface.';
              SurfaceOpsDlg.SurfaceOrd.Text := '';
              SurfaceOpsDlg.SurfaceOrd.SetFocus
            END
        END
    END;

  IF Valid
      OR UserGaveUp THEN
  ELSE
    Action := caNone

end;

end.

