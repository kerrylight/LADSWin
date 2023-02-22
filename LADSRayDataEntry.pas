unit LADSRayDataEntry;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type
  TRayDataEntryForm = class(TForm)
    RayNumberEdit: TEdit;
    RayOrdinalLabel: TLabel;
    RaySpecifiedImage: TImage;
    RayNotSpecifiedImage: TImage;
    RaySpecifiedLabel: TLabel;
    RayBundleHeadDiaEdit: TEdit;
    RayBundleTailXCoordEdit: TEdit;
    RayBundleTailXCoordLabel: TLabel;
    RayBundleHeadDiaLabel: TLabel;
    RayBundleTailYCoordEdit: TEdit;
    RayBundleTailYCoordLabel: TLabel;
    RayBundleTailZCoordEdit: TEdit;
    RayBundleTailZCoordLabel: TLabel;
    RayBundleHeadXCoordEdit: TEdit;
    RayBundleHeadXCoordLabel: TLabel;
    RayBundleHeadYCoordEdit: TEdit;
    RayBundleHeadYCoordLabel: TLabel;
    RayBundleHeadZCoordEdit: TEdit;
    RayBundleHeadZCoordLabel: TLabel;
    RayWavelengthEdit: TEdit;
    RayWavelengthLabel: TLabel;
    IncidentMediumIndexEdit: TEdit;
    IncidentMediumIndexLabel: TLabel;
    RayBundleTypeRadioGroup: TRadioGroup;
    RayActiveButton: TBitBtn;
    NumOfRaysInFanOrBundleEdit: TEdit;
    NumOfRaysInFanOrBundleLabel: TLabel;
    GaussianBundleParamsGrpBox: TGroupBox;
    HeadSigmaXEdit: TEdit;
    HeadSigmaXLabel: TLabel;
    HeadSigmaYEdit: TEdit;
    HeadSigmaYLabel: TLabel;
    TailSigmaXEdit: TEdit;
    TailSigmaXLabel: TLabel;
    TailSigmaYEdit: TEdit;
    TailSigmaYLabel: TLabel;
    AstigmaticDistanceEdit: TEdit;
    AstigmaticDistanceLabel: TLabel;
    HeadXIsGaussianCheckBox: TCheckBox;
    HeadYIsGaussianCheckBox: TCheckBox;
    TailXIsGaussianCheckBox: TCheckBox;
    TailYIsGaussianCheckBox: TCheckBox;
    RayDataValidationMessage: TMemo;
    RayDataValidationMessageLabel: TLabel;
    PreviousRayButton: TBitBtn;
    NextRayButton: TBitBtn;
    RayDataEntryCloseButton: TBitBtn;
    RingCountEdit: TEdit;
    RingCountLabel: TLabel;
    RayDataEntryHelpButton: TBitBtn;
    procedure PreviousRayButtonClick(Sender: TObject);
    procedure RayDataEntryCloseButtonClick(Sender: TObject);
    procedure NextRayButtonClick(Sender: TObject);
    procedure PrepareNewRay(Sender: TObject);
    procedure ProcessBundleTypeClick(Sender: TObject);
    procedure ValidateNumberOfRays(Sender: TObject);
    procedure ValidateBundleHeadDia(Sender: TObject);
    procedure ValidateTailXCoord(Sender: TObject);
    procedure ValidateTailYCoord(Sender: TObject);
    procedure ValidateTailZCoord(Sender: TObject);
    procedure ValidateHeadXCoord(Sender: TObject);
    procedure ValidateHeadYCoord(Sender: TObject);
    procedure ValidateHeadZCoord(Sender: TObject);
    procedure ValidateRayWavelength(Sender: TObject);
    procedure ValidateIncidentMediumIndex(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  RayDataEntryForm: TRayDataEntryForm;

implementation

  uses
      LADSData,
      LADSMainFormUnit;

{$R *.DFM}

PROCEDURE PostAllCurrentRayData;

  VAR
      I  : LONGINT;

BEGIN

  IF RayOrdinal < 2 THEN
    BEGIN
      RayDataEntryForm.PreviousRayButton.Enabled := FALSE;
      RayDataEntryForm.NextRayButton.Enabled := TRUE
    END
  ELSE
  IF RayOrdinal > (CZAC_MAX_NUMBER_OF_RAYS - 1) THEN
    BEGIN
      RayDataEntryForm.PreviousRayButton.Enabled := TRUE;
      RayDataEntryForm.NextRayButton.Enabled := FALSE
    END
  ELSE
    BEGIN
      RayDataEntryForm.PreviousRayButton.Enabled := TRUE;
      RayDataEntryForm.NextRayButton.Enabled := TRUE
    END;

  RayDataEntryForm.RayNumberEdit.Text :=
      IntToStr (RayOrdinal);

  IF ZNA_RAY [RayOrdinal].ZNB_SPECIFIED THEN
    RayDataEntryForm.RaySpecifiedImage.BringToFront
  ELSE
    RayDataEntryForm.RayNotSpecifiedImage.BringToFront;

  IF ZNA_RAY [RayOrdinal].ZNC_ACTIVE THEN
    RayDataEntryForm.RayActiveButton.Kind := bkYes
  ELSE
    RayDataEntryForm.RayActiveButton.Kind := bkNo;
  RayDataEntryForm.RayActiveButton.Caption := 'Active';
  RayDataEntryForm.ModalResult := mrNone;

  IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS THEN
    BEGIN
      RayDataEntryForm.GaussianBundleParamsGrpBox.Enabled := TRUE;
      RayDataEntryForm.HeadSigmaXEdit.Text :=
          FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_HEAD);
      IF ZNA_RAY [RayOrdinal].HEAD_X_IS_GAUSSIAN THEN
        RayDataEntryForm.HeadXIsGaussianCheckBox.Checked := TRUE
      ELSE
        RayDataEntryForm.HeadXIsGaussianCheckBox.Checked := FALSE;
      RayDataEntryForm.HeadSigmaYEdit.Text :=
          FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_Y_HEAD);
      IF ZNA_RAY [RayOrdinal].HEAD_Y_IS_GAUSSIAN THEN
        RayDataEntryForm.HeadYIsGaussianCheckBox.Checked := TRUE
      ELSE
        RayDataEntryForm.HeadYIsGaussianCheckBox.Checked := FALSE;
      RayDataEntryForm.TailSigmaXEdit.Text :=
          FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL);
      IF ZNA_RAY [RayOrdinal].TAIL_X_IS_GAUSSIAN THEN
        RayDataEntryForm.TailXIsGaussianCheckBox.Checked := TRUE
      ELSE
        RayDataEntryForm.TailXIsGaussianCheckBox.Checked := FALSE;
      RayDataEntryForm.TailSigmaYEdit.Text :=
          FloatToStr (ZNA_RAY [RayOrdinal].SIGMA_X_TAIL);
      IF ZNA_RAY [RayOrdinal].TAIL_Y_IS_GAUSSIAN THEN
        RayDataEntryForm.TailYIsGaussianCheckBox.Checked := TRUE
      ELSE
        RayDataEntryForm.TailYIsGaussianCheckBox.Checked := FALSE;
      RayDataEntryForm.AstigmaticDistanceEdit.Text :=
          FloatToStr (ZNA_RAY [RayOrdinal].Astigmatism)
    END
  ELSE
    BEGIN
      RayDataEntryForm.GaussianBundleParamsGrpBox.Enabled := FALSE;
      RayDataEntryForm.HeadSigmaXEdit.Text := '';
      RayDataEntryForm.HeadSigmaYEdit.Text := '';
      RayDataEntryForm.TailSigmaXEdit.Text := '';
      RayDataEntryForm.TailSigmaYEdit.Text := '';
      RayDataEntryForm.AstigmaticDistanceEdit.Text := '';
      RayDataEntryForm.HeadXIsGaussianCheckBox.Checked := FALSE;
      RayDataEntryForm.HeadYIsGaussianCheckBox.Checked := FALSE;
      RayDataEntryForm.TailXIsGaussianCheckBox.Checked := FALSE;
      RayDataEntryForm.TailYIsGaussianCheckBox.Checked := FALSE
    END;

  IF ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 0
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 1
  ELSE
  IF ZNA_RAY [RayOrdinal].TraceLinearXFan THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 2
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 3
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 4
  ELSE
  IF ZNA_RAY [RayOrdinal].TraceSquareGrid THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 5
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 6
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 7
  ELSE
  IF ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 8
  ELSE
  IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 9
  ELSE
  IF ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 10
  ELSE
  IF ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS THEN
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 11
  ELSE
    RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex := 12;

  IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
    BEGIN
      RayDataEntryForm.RayBundleHeadDiaLabel.Caption := 'Cone half angle (deg)';
      RayDataEntryForm.RayBundleHeadDiaEdit.Text :=
          FloatToStr (ZNA_RAY [RayOrdinal].MaxZenithDistance)
    END
  ELSE
    BEGIN
      RayDataEntryForm.RayBundleHeadDiaLabel.Caption :=
          'Ray bundle head diameter';
      RayDataEntryForm.RayBundleHeadDiaEdit.Text :=
          FloatToStr (ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER)
    END;

  IF ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE THEN
    BEGIN
      RayDataEntryForm.RingCountEdit.Text :=
          IntToStr (ZNA_RAY [RayOrdinal].NumberOfRings);
      RayDataEntryForm.RingCountEdit.Enabled := TRUE;
      RayDataEntryForm.RingCountLabel.Enabled := TRUE;
      RayDataEntryForm.NumOfRaysInFanOrBundleEdit.Enabled := FALSE;
      FOR I := 1 TO ZNA_RAY [RayOrdinal].NumberOfRings DO
        ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle :=
            ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle + I * 6
    END
  ELSE
    BEGIN
      RayDataEntryForm.RingCountEdit.Text := '';
      RayDataEntryForm.RingCountEdit.Enabled := FALSE;
      RayDataEntryForm.RingCountLabel.Enabled := FALSE;
      RayDataEntryForm.NumOfRaysInFanOrBundleEdit.Enabled := TRUE
    END;

  RayDataEntryForm.NumOfRaysInFanOrBundleEdit.Text :=
      IntToStr (ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle);

  RayDataEntryForm.RayBundleTailXCoordEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE);

  RayDataEntryForm.RayBundleTailYCoordEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE);

  RayDataEntryForm.RayBundleTailZCoordEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE);

  RayDataEntryForm.RayBundleHeadXCoordEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE);

  RayDataEntryForm.RayBundleHeadYCoordEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE);

  RayDataEntryForm.RayBundleHeadZCoordEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE);

  RayDataEntryForm.RayWavelengthEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH);

  RayDataEntryForm.IncidentMediumIndexEdit.Text :=
      FloatToStr (ZNA_RAY [RayOrdinal].ZNK_INCIDENT_MEDIUM_INDEX)

END;

procedure TRayDataEntryForm.PreviousRayButtonClick(Sender: TObject);
begin

  dec (RayOrdinal);

  PostAllCurrentRayData

end;

procedure TRayDataEntryForm.RayDataEntryCloseButtonClick(Sender: TObject);
begin

  ModalResult := mrCancel
  
end;

procedure TRayDataEntryForm.NextRayButtonClick(Sender: TObject);
begin

  inc (RayOrdinal);

  PostAllCurrentRayData

end;

procedure TRayDataEntryForm.PrepareNewRay(Sender: TObject);
begin

  RayDataEntryForm.ActiveControl := NumOfRaysInFanOrBundleEdit;

  IF GetNewRayData THEN
    BEGIN
      ZNA_RAY [RayOrdinal].ZPA_ALL_RAY_DATA := ZQA_RAY_DATA_INITIALIZER;
      ZNA_RAY [RayOrdinal].ZNB_SPECIFIED := TRUE;
      ZNA_RAY [RayOrdinal].ZNC_ACTIVE := TRUE;
      ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE := DefaultRayCoordinate;
      ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE := DefaultRayCoordinate;
      ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE := DefaultRayTailZCoordinate;
      ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE := DefaultRayCoordinate;
      ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE := DefaultRayCoordinate;
      ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE := DefaultRayHeadZCoordinate;
      ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH := DefaultRayWavelength;
      ZNA_RAY [RayOrdinal].ZNK_INCIDENT_MEDIUM_INDEX :=
          DefaultIncidentMediumIndex;
      ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER :=
          CZBC_DEFAULT_BUNDLE_HEAD_DIA
    END;

  PostAllCurrentRayData

end;

procedure TRayDataEntryForm.ProcessBundleTypeClick(Sender: TObject);
begin

  ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN := FALSE;
  ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN := FALSE;
  ZNA_RAY [RayOrdinal].TraceLinearXFan := FALSE;
  ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN := FALSE;
  ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN := FALSE;
  ZNA_RAY [RayOrdinal].TraceSquareGrid := FALSE;
  ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE := FALSE;
  ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE := FALSE;
  ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS := FALSE;
  ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS := FALSE;
  ZNA_RAY [RayOrdinal].TraceOrangeSliceRays := FALSE;
  ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS := FALSE;
  ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS := FALSE;

  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 0 THEN
      ZNA_RAY [RayOrdinal].ZFC_TRACE_SYMMETRIC_FAN := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 1 THEN
    ZNA_RAY [RayOrdinal].ZFD_TRACE_ASYMMETRIC_FAN := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 2 THEN
    ZNA_RAY [RayOrdinal].TraceLinearXFan := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 3 THEN
    ZNA_RAY [RayOrdinal].ZFB_TRACE_LINEAR_Y_FAN := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 4 THEN
    ZNA_RAY [RayOrdinal].ZFQ_TRACE_3FAN := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 5 THEN
    ZNA_RAY [RayOrdinal].TraceSquareGrid := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 6 THEN
    ZNA_RAY [RayOrdinal].ZFE_TRACE_HEXAPOLAR_BUNDLE := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 7 THEN
    ZNA_RAY [RayOrdinal].ZFF_TRACE_ISOMETRIC_BUNDLE := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 8 THEN
    ZNA_RAY [RayOrdinal].ZFG_TRACE_RANDOM_RAYS := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 9 THEN
    ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 10 THEN
    ZNA_RAY [RayOrdinal].TRACE_LAMBERTIAN_RAYS := TRUE
  ELSE
  IF RayDataEntryForm.RayBundleTypeRadioGroup.ItemIndex = 11 THEN
    ZNA_RAY [RayOrdinal].TRACE_GAUSSIAN_RAYS := TRUE;

  PostAllCurrentRayData

end;

procedure TRayDataEntryForm.ValidateNumberOfRays(Sender: TObject);

  VAR
      CODE               : INTEGER;

      LongIntegerNumber  : LONGINT;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.NumOfRaysInFanOrBundleEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default number of rays.';
      ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle := DefaultNumberOfRays
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.NumOfRaysInFanOrBundleEdit.Text,
          LongIntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (LongIntegerNumber > 0) THEN
          BEGIN
            ZNA_RAY [RayOrdinal].NumberOfRaysInFanOrBundle :=
                LongIntegerNumber
          END
        ELSE
          BEGIN
            RayDataValidationMessage.Text := 'Number of rays in bundle ' +
                'must be greater than zero.';
            RayDataEntryForm.NumOfRaysInFanOrBundleEdit.SetFocus
          END
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.NumOfRaysInFanOrBundleEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateBundleHeadDia(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayBundleHeadDiaEdit.Text) = 0 THEN
    BEGIN
      IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
        BEGIN
          RayDataEntryForm.RayDataValidationMessage.Text :=
              'No input.  Restoring default cone half-angle.';
          ZNA_RAY [RayOrdinal].MaxZenithDistance :=
              DefaultMaxZenithDistance
        END
      ELSE
        BEGIN
          RayDataEntryForm.RayDataValidationMessage.Text :=
              'No input.  Restoring default bundle head diameter.';
          ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER :=
              CZBC_DEFAULT_BUNDLE_HEAD_DIA
        END
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayBundleHeadDiaEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber > 0) THEN
          BEGIN
            IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
              ZNA_RAY [RayOrdinal].MaxZenithDistance := RealNumber
            ELSE
              ZNA_RAY [RayOrdinal].ZFR_BUNDLE_HEAD_DIAMETER := RealNumber
          END
        ELSE
          BEGIN
            IF ZNA_RAY [RayOrdinal].ZGG_TRACE_SOLID_ANGLE_RAYS THEN
              RayDataValidationMessage.Text := 'Bundle cone half-angle ' +
                'must be greater than zero.'
            ELSE
              RayDataValidationMessage.Text := 'Diameter of ray bundle head ' +
                'must be greater than zero.';
            RayDataEntryForm.RayBundleHeadDiaEdit.SetFocus
          END
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayBundleHeadDiaEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateTailXCoord(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayBundleTailXCoordEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray tail X coordinate.';
      ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE := DefaultRayCoordinate
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayBundleTailXCoordEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        ZNA_RAY [RayOrdinal].ZND_TAIL_X_COORDINATE := RealNumber
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayBundleTailXCoordEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateTailYCoord(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayBundleTailYCoordEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray tail Y coordinate.';
      ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE :=
          DefaultRayCoordinate
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayBundleTailYCoordEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        ZNA_RAY [RayOrdinal].ZNE_TAIL_Y_COORDINATE := RealNumber
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayBundleTailYCoordEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateTailZCoord(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayBundleTailZCoordEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray tail Z coordinate.';
      ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE :=
          DefaultRayTailZCoordinate
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayBundleTailZCoordEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        ZNA_RAY [RayOrdinal].ZNF_TAIL_Z_COORDINATE := RealNumber
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayBundleTailZCoordEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateHeadXCoord(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayBundleHeadXCoordEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray head X coordinate.';
      ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE :=
          DefaultRayCoordinate
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayBundleHeadXCoordEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        ZNA_RAY [RayOrdinal].ZNG_HEAD_X_COORDINATE := RealNumber
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayBundleHeadXCoordEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateHeadYCoord(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayBundleHeadYCoordEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray head Y coordinate.';
      ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE :=
          DefaultRayCoordinate
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayBundleHeadYCoordEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        ZNA_RAY [RayOrdinal].ZNH_HEAD_Y_COORDINATE := RealNumber
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayBundleHeadYCoordEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateHeadZCoord(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayBundleHeadZCoordEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray head Z coordinate.';
      ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE := DefaultRayHeadZCoordinate
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayBundleHeadZCoordEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        ZNA_RAY [RayOrdinal].ZNI_HEAD_Z_COORDINATE := RealNumber
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayBundleHeadZCoordEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateRayWavelength(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayWavelengthEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray wavelength.';
      ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH := DefaultRayWavelength
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayWavelengthEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber > 0.0) THEN
          ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH := RealNumber
        ELSE
          BEGIN
            RayDataValidationMessage.Text := 'Ray wavelength ' +
                'must be greater than zero.';
            RayDataEntryForm.RayWavelengthEdit.SetFocus
          END
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayWavelengthEdit.SetFocus
        END
    END

end;

procedure TRayDataEntryForm.ValidateIncidentMediumIndex(Sender: TObject);

  VAR
      CODE               : INTEGER;

      RealNumber         : DOUBLE;

begin

  RayDataValidationMessage.Clear;

  IF Length (RayDataEntryForm.RayWavelengthEdit.Text) = 0 THEN
    BEGIN
      RayDataEntryForm.RayDataValidationMessage.Text :=
          'No input.  Restoring default ray wavelength.';
      ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH := DefaultRayWavelength
    END
  ELSE
    BEGIN
      VAL (RayDataEntryForm.RayWavelengthEdit.Text,
          RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 1.0) THEN
          ZNA_RAY [RayOrdinal].ZNJ_WAVELENGTH := RealNumber
        ELSE
          BEGIN
            RayDataValidationMessage.Text := 'Incident medium refractive ' +
                'index must be greater than or equal to one.';
            RayDataEntryForm.RayWavelengthEdit.SetFocus
          END
      ELSE
        BEGIN
          RayDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RayDataEntryForm.RayWavelengthEdit.SetFocus
        END
    END

end;

end.
