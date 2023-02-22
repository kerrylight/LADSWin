unit LADSLensDataEntry;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls;

type
  TLensDataEntryForm = class(TForm)
    RadiusOfCurvatureEdit: TEdit;
    RadiusOfCurvatureLabel: TLabel;
    ConicConstantLabel: TLabel;
    ConicConstantEdit: TEdit;
    RefractiveIndex1Edit: TEdit;
    RefractiveIndex1Label: TLabel;
    RefractiveIndex2Label: TLabel;
    RefractiveIndex2Edit: TEdit;
    SurfaceNumberLabel: TLabel;
    SurfaceNumberEdit: TEdit;
    OuterClearApDiaLabel: TLabel;
    OuterClearApDiaEdit: TEdit;
    ScatteringAngleLabel: TLabel;
    ScatteringAngleEdit: TEdit;
    SurfaceReflectivityLabel: TLabel;
    SurfaceReflectivityEdit: TEdit;
    VertexXCoodinateLabel: TLabel;
    VertexYCoordinateLabel: TLabel;
    VertexYCoordinateEdit: TEdit;
    VertexZCoordinateLabel: TLabel;
    VertexZCoordinateEdit: TEdit;
    VertexYawLabel: TLabel;
    VertexPitchLabel: TLabel;
    VertexRollLabel: TLabel;
    VertexYawEdit: TEdit;
    VertexPitchEdit: TEdit;
    VertexRollEdit: TEdit;
    SurfaceSpecifiedLabel: TLabel;
    SurfaceActiveButton: TBitBtn;
    SurfaceNotSpecifiedImage: TImage;
    OPDReferenceSurfButton: TBitBtn;
    ScatteringSurfButton: TBitBtn;
    SurfaceSpecifiedImage: TImage;
    SurfaceDataValidationMessage: TMemo;
    Label1: TLabel;
    InnerApertureDiameterEdit: TEdit;
    InnerApertureDiameterLabel: TLabel;
    VertexXCoordinateEdit: TEdit;
    OutsideApertureXDimEdit: TEdit;
    OutsideApertureYDimEdit: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    InsideApertureXDimEdit: TEdit;
    InsideApertureYDimEdit: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    ApertureOffsetXEdit: TEdit;
    ApertureOffsetYEdit: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    RadialSectorCenterAzEdit: TEdit;
    RadialSectorAngularWidthEdit: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    SurfaceFormRadioGroup: TRadioGroup;
    OuterApertureRadioGroup: TRadioGroup;
    Label11: TLabel;
    InnerApertureRadioGroup: TRadioGroup;
    SurfaceActivityRadioGroup: TRadioGroup;
    AsphericDeformationConstants: TGroupBox;
    Order4DeformationConstantEdit: TEdit;
    Order6DeformationConstantEdit: TEdit;
    Order8DeformationConstantEdit: TEdit;
    Order10DeformationConstantEdit: TEdit;
    Order12DeformationConstantEdit: TEdit;
    Order14DeformationConstantEdit: TEdit;
    Order16DeformationConstantEdit: TEdit;
    Order18DeformationConstantEdit: TEdit;
    Order20DeformationConstantEdit: TEdit;
    Order22DeformationConstantEdit: TEdit;
    Label13: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    CPCDesignParametersBox: TGroupBox;
    MaxEntranceAngleInAirDegreesEdit: TEdit;
    Label25: TLabel;
    CPCRefractiveIndexEdit: TEdit;
    CPCExitAngleDegreesEdit: TEdit;
    Label27: TLabel;
    RadiusOfCPCExitApertureEdit: TEdit;
    Label28: TLabel;
    SurfaceSymmetryRadioGroup: TRadioGroup;
    PreviousSurfaceButton: TBitBtn;
    NextSurfaceButton: TBitBtn;
    CloseButton: TBitBtn;
    LensletArrayButton: TBitBtn;
    LensletArrayColumnsEdit: TEdit;
    LensletArrayRowsEdit: TEdit;
    LensletArrayColsRowsLabel: TLabel;
    LensDataEntryHelpButton: TBitBtn;
    LensletArrayPitchXEdit: TEdit;
    LensletArrayPitchXLabel: TLabel;
    LensletArrayPitchYEdit: TEdit;
    LensletArrayPitchYLabel: TLabel;
    procedure ToggleSurfaceActiveSwitch(Sender: TObject);
    procedure PrepareNewSurface(Sender: TObject);
    procedure ValidateConicConstant(Sender: TObject);
    procedure ValidateRadiusOfCurvature(Sender: TObject);
    procedure ToggleOPDReferenceSurface(Sender: TObject);
    procedure ToggleScatteringSurface(Sender: TObject);
    procedure ValidateRefractiveIndex1(Sender: TObject);
    procedure ValidateRefractiveIndex2(Sender: TObject);
    procedure ValidateOuterClearApDia(Sender: TObject);
    procedure ValidateInnerClearApDia(Sender: TObject);
    procedure ValidateScatteringAngle(Sender: TObject);
    procedure ValidateSurfaceReflectivity(Sender: TObject);
    procedure ValidateVertexXCoordinate(Sender: TObject);
    procedure ValidateVertexYCoordinate(Sender: TObject);
    procedure ValidateVertexZCoordinate(Sender: TObject);
    procedure ValidateVertexYaw(Sender: TObject);
    procedure ValidateVertexPitch(Sender: TObject);
    procedure ValidateVertexRoll(Sender: TObject);
    procedure SetSurfaceActivity(Sender: TObject);
    procedure SetSurfaceForm(Sender: TObject);
    procedure SetSurfaceSymmetry(Sender: TObject);
    procedure DisplayPreviousSurface(Sender: TObject);
    procedure DisplayNextSurface(Sender: TObject);
    procedure GetSurfaceOrdinal(Sender: TObject);
    procedure CloseSurfDataEntryForm(Sender: TObject);
    procedure ToggleLensletArraySwitch(Sender: TObject);
    procedure ValidateLensletRows(Sender: TObject);
    procedure ValidateLensletColumns(Sender: TObject);
    procedure ValidateOuterApertureXDim(Sender: TObject);
    procedure ValidateOuterApertureYDim(Sender: TObject);
    procedure SelectOuterApertureType(Sender: TObject);
    procedure SelectInnerApertureType(Sender: TObject);
    procedure ValidateInsideApertureXDim(Sender: TObject);
    procedure ValidateInsideApertureYDim(Sender: TObject);
    procedure LensDataEntryHelpButtonClick(Sender: TObject);
    procedure ValidateApertureOffsetX(Sender: TObject);
    procedure ValidateApertureOffsetY(Sender: TObject);
    procedure ValidateCenterAzimuth(Sender: TObject);
    procedure ValidateSectorAngularWidth(Sender: TObject);
    procedure Validate4thOrderDefConst(Sender: TObject);
    procedure Validate6thOrderDefConst(Sender: TObject);
    procedure Validate8thOrderDefConst(Sender: TObject);
    procedure Validate10thOrderDefConst(Sender: TObject);
    procedure Validate12thOrderDefConst(Sender: TObject);
    procedure Validate14thOrderDefConst(Sender: TObject);
    procedure Validate16thOrderDefConst(Sender: TObject);
    procedure Validate18thOrderDefConst(Sender: TObject);
    procedure Validate20thOrderDefConst(Sender: TObject);
    procedure Validate22ndOrderDefConst(Sender: TObject);
    procedure ValidateCPCMaxEntAngle(Sender: TObject);
    procedure ValidateCPCRefractiveIndex(Sender: TObject);
    procedure ValidateCPCExitAngle(Sender: TObject);
    procedure ValidateCPCExitApertureRadius(Sender: TObject);
    procedure ValidateLensletArrayPitchXDim(Sender: TObject);
    procedure ValidateLensletArrayPitchYDim(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LensDataEntryForm: TLensDataEntryForm;

implementation

  Uses Expertio,
       LADSData,
       LADSGlassVar,
       LADSGlassCompUnit,
       LADSHelpMessages,
       LADSCommandIOdlgUnit,
       LADSCommandIOMemoUnit,
       LADSMainFormUnit;

  VAR
      LastFocus  : (lfRadiusOfCurvature,
                    lfConicConstant,
                    lfRefractiveIndex1,
                    lfRefractiveIndex2,
                    lfSurfaceReflectivity,
                    lfScatteringAngle,
                    lfOutsideApertureDia,
                    lfOutsideApertureWidthX,
                    lfOutsideApertureWidthY,
                    lfInsideApertureDia,
                    lfInsideApertureWidthX,
                    lfInsideApertureWidthY,
                    lfLensletArrayColumns,
                    lfLensletArrayRows,
                    lfLensletArrayPitchX,
                    lfLensletArrayPitchY,
                    lfApertureOffsetX,
                    lfApertureOffsetY,
                    lfRadialSectorCenterAz,
                    lfRadialSectorAngularWidth,
                    lfSurfaceVertexXPosition,
                    lfSurfaceVertexYPosition,
                    lfSurfaceVertexZPosition,
                    lfSurfaceVertexYaw,
                    lfSurfaceVertexPitch,
                    lfSurfaceVertexRoll,
                    lfAsphericDeformationConstants,
                    lfCPCMaxEntraceAngle,
                    lfCPCRefractiveIndex,
                    lfCPCExitAngle,
                    lfCPCExitApertureRadius,
                    lfNone);

{$R *.DFM}

PROCEDURE PostAllCurrentSurfaceData;

  VAR
      InsideIsCircular    : BOOLEAN;
      OutsideIsCircular   : BOOLEAN;

BEGIN

  IF SurfaceOrdinal < 2 THEN
    BEGIN
      LensDataEntryForm.PreviousSurfaceButton.Enabled := FALSE;
      LensDataEntryForm.NextSurfaceButton.Enabled := TRUE
    END
  ELSE
  IF SurfaceOrdinal > (CZAB_MAX_NUMBER_OF_SURFACES - 1) THEN
    BEGIN
      LensDataEntryForm.PreviousSurfaceButton.Enabled := TRUE;
      LensDataEntryForm.NextSurfaceButton.Enabled := FALSE
    END
  ELSE
    BEGIN
      LensDataEntryForm.PreviousSurfaceButton.Enabled := TRUE;
      LensDataEntryForm.NextSurfaceButton.Enabled := TRUE
    END;

  LensDataEntryForm.SurfaceNumberEdit.Text :=
      IntToStr (SurfaceOrdinal);

  IF ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
    LensDataEntryForm.SurfaceSpecifiedImage.BringToFront
  ELSE
    LensDataEntryForm.SurfaceNotSpecifiedImage.BringToFront;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE THEN
    LensDataEntryForm.SurfaceActiveButton.Kind := bkYes
  ELSE
    LensDataEntryForm.SurfaceActiveButton.Kind := bkNo;
  LensDataEntryForm.SurfaceActiveButton.Caption := 'Active';
  LensDataEntryForm.ModalResult := mrNone;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBF_OPD_REFERENCE THEN
    LensDataEntryForm.OPDReferenceSurfButton.Kind := bkYes
  ELSE
    LensDataEntryForm.OPDReferenceSurfButton.Kind := bkNo;
  LensDataEntryForm.OPDReferenceSurfButton.Caption := 'OPD ref';
  LensDataEntryForm.ModalResult := mrNone;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL THEN
    LensDataEntryForm.SurfaceSymmetryRadioGroup.ItemIndex := 1
  Else
    LensDataEntryForm.SurfaceSymmetryRadioGroup.ItemIndex := 0;

  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = Conic THEN
    LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex := 0
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HighOrderAsphere THEN
    LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex := 1
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = CPC THEN
    LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex := 2
  ELSE
    LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex := 3;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE THEN
    LensDataEntryForm.SurfaceActivityRadioGroup.ItemIndex := 1
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE THEN
    LensDataEntryForm.SurfaceActivityRadioGroup.ItemIndex := 2
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].ZCI_RAY_TERMINATION_SURFACE THEN
    LensDataEntryForm.SurfaceActivityRadioGroup.ItemIndex := 3
  ELSE
    LensDataEntryForm.SurfaceActivityRadioGroup.ItemIndex := 0;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD THEN
    IF ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR THEN
      LensDataEntryForm.OuterApertureRadioGroup.ItemIndex := 1
    ELSE
    IF ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
      LensDataEntryForm.OuterApertureRadioGroup.ItemIndex := 2
    ELSE
      LensDataEntryForm.OuterApertureRadioGroup.ItemIndex := 0
  ELSE
    LensDataEntryForm.OuterApertureRadioGroup.ItemIndex := -1;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD THEN
    IF ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR
        OR ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
      BEGIN
        LensDataEntryForm.OuterClearApDiaEdit.Text := '';
        LensDataEntryForm.OutsideApertureXDimEdit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].
            ZCP_OUTSIDE_APERTURE_WIDTH_X);
        LensDataEntryForm.OutsideApertureYDimEdit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].
            ZCQ_OUTSIDE_APERTURE_WIDTH_Y)
      END
    ELSE
      BEGIN
        LensDataEntryForm.OuterClearApDiaEdit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA);
        LensDataEntryForm.OutsideApertureXDimEdit.Text := '';
        LensDataEntryForm.OutsideApertureYDimEdit.Text := ''
      END
  ELSE
    BEGIN
      LensDataEntryForm.OuterClearApDiaEdit.Text := '';
      LensDataEntryForm.OutsideApertureXDimEdit.Text := '';
      LensDataEntryForm.OutsideApertureYDimEdit.Text := ''
    END;

  IF ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD THEN
    IF ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR THEN
      LensDataEntryForm.InnerApertureRadioGroup.ItemIndex := 1
    ELSE
    IF ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
      LensDataEntryForm.InnerApertureRadioGroup.ItemIndex := 2
    ELSE
      LensDataEntryForm.InnerApertureRadioGroup.ItemIndex := 0
  ELSE
    LensDataEntryForm.InnerApertureRadioGroup.ItemIndex := -1;

  IF ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD THEN
    IF ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR
        OR ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
      BEGIN
        LensDataEntryForm.InnerApertureDiameterEdit.Text := '';
        LensDataEntryForm.InsideApertureXDimEdit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].
            ZCR_INSIDE_APERTURE_WIDTH_X);
        LensDataEntryForm.InsideApertureYDimEdit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].
            ZCS_INSIDE_APERTURE_WIDTH_Y)
      END
    ELSE
      BEGIN
        LensDataEntryForm.InnerApertureDiameterEdit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBK_INSIDE_APERTURE_DIA);
        LensDataEntryForm.InsideApertureXDimEdit.Text := '';
        LensDataEntryForm.InsideApertureYDimEdit.Text := ''
      END
  ELSE
    BEGIN
      LensDataEntryForm.InnerApertureDiameterEdit.Text := '';
      LensDataEntryForm.InsideApertureXDimEdit.Text := '';
      LensDataEntryForm.InsideApertureYDimEdit.Text := ''
    END;

  LensDataEntryForm.RadiusOfCurvatureEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV);
  IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
    LensDataEntryForm.RadiusOfCurvatureLabel.Caption := 'Flat'
  ELSE
    LensDataEntryForm.RadiusOfCurvatureLabel.Caption := 'Radius';

  LensDataEntryForm.ConicConstantEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT);

  IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1] THEN
    LensDataEntryForm.RefractiveIndex1Edit.Text :=
        ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME
  ELSE
    LensDataEntryForm.RefractiveIndex1Edit.Text :=
        FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
        ZBI_REFRACTIVE_INDEX);

  IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] THEN
    LensDataEntryForm.RefractiveIndex2Edit.Text :=
        ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME
  ELSE
    LensDataEntryForm.RefractiveIndex2Edit.Text :=
        FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
        ZBI_REFRACTIVE_INDEX);

  LensDataEntryForm.SurfaceReflectivityEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY);

  LensDataEntryForm.ScatteringAngleEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians);

  IF ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE THEN
    LensDataEntryForm.ScatteringSurfButton.Kind := bkYes
  ELSE
    LensDataEntryForm.ScatteringSurfButton.Kind := bkNo;
  LensDataEntryForm.ScatteringSurfButton.Caption := 'Scatter';
  LensDataEntryForm.ModalResult := mrNone;

  InsideIsCircular := FALSE;
  IF ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR
    OR ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL THEN
  ELSE
    InsideIsCircular := TRUE;

  OutsideIsCircular := FALSE;
  IF ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR
    OR ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
  ELSE
    OutsideIsCircular := TRUE;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD
      AND ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD THEN
    BEGIN
      IF InsideIsCircular
          AND OutsideIsCircular
          AND NOT ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
        BEGIN
          LensDataEntryForm.ApertureOffsetXEdit.Text := '';
          LensDataEntryForm.ApertureOffsetYEdit.Text := '';
          LensDataEntryForm.RadialSectorCenterAzEdit.Text :=
              FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X);
          LensDataEntryForm.RadialSectorAngularWidthEdit.Text :=
              FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y)
        END
      ELSE
        BEGIN
          LensDataEntryForm.ApertureOffsetXEdit.Text :=
              FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X);
          LensDataEntryForm.ApertureOffsetYEdit.Text :=
              FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y);
          LensDataEntryForm.RadialSectorCenterAzEdit.Text := '';
          LensDataEntryForm.RadialSectorAngularWidthEdit.Text := ''
        END
    END
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD
      OR ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD THEN
    BEGIN
      LensDataEntryForm.ApertureOffsetXEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X);
      LensDataEntryForm.ApertureOffsetYEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y);
      LensDataEntryForm.RadialSectorCenterAzEdit.Text := '';
      LensDataEntryForm.RadialSectorAngularWidthEdit.Text := ''
    END
  ELSE
    BEGIN
      LensDataEntryForm.ApertureOffsetXEdit.Text := '';
      LensDataEntryForm.ApertureOffsetYEdit.Text := '';
      LensDataEntryForm.RadialSectorCenterAzEdit.Text := '';
      LensDataEntryForm.RadialSectorAngularWidthEdit.Text := ''
    END;

  IF ZBA_SURFACE [SurfaceOrdinal].LensletArray THEN
    BEGIN
      LensDataEntryForm.LensletArrayColumnsEdit.Text :=
          IntToStr (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns);
      LensDataEntryForm.LensletArrayRowsEdit.Text :=
          IntToStr (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows);
      LensDataEntryForm.LensletArrayPitchXEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX);
      LensDataEntryForm.LensletArrayPitchYEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY);
      LensDataEntryForm.LensletArrayButton.Kind := bkYes
    END
  ELSE
    BEGIN
      LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
      LensDataEntryForm.LensletArrayRowsEdit.Text := '';
      LensDataEntryForm.LensletArrayPitchXEdit.Text := '';
      LensDataEntryForm.LensletArrayPitchYEdit.Text := '';
      LensDataEntryForm.LensletArrayButton.Kind := bkNo
    END;
  LensDataEntryForm.LensletArrayButton.Caption := 'Array';
  LensDataEntryForm.ModalResult := mrNone;

  LensDataEntryForm.VertexXCoordinateEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X);

  LensDataEntryForm.VertexYCoordinateEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y);

  LensDataEntryForm.VertexZCoordinateEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z);

  LensDataEntryForm.VertexYawEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBW_YAW);

  LensDataEntryForm.VertexPitchEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBU_PITCH);

  LensDataEntryForm.VertexRollEdit.Text :=
      FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBS_ROLL);

  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = Conic THEN
    BEGIN
      LensDataEntryForm.Order4DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order6DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order8DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order10DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order12DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order14DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order16DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order18DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order20DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order22DeformationConstantEdit.Text := '';
      LensDataEntryForm.MaxEntranceAngleInAirDegreesEdit.Text := '';
      LensDataEntryForm.CPCRefractiveIndexEdit.Text := '';
      LensDataEntryForm.CPCExitAngleDegreesEdit.Text := '';
      LensDataEntryForm.RadiusOfCPCExitApertureEdit.Text := ''
    END
  ELSE
  IF ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HighOrderAsphere THEN
    BEGIN
      LensDataEntryForm.Order4DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [1]);
      LensDataEntryForm.Order6DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [2]);
      LensDataEntryForm.Order8DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [3]);
      LensDataEntryForm.Order10DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [4]);
      LensDataEntryForm.Order12DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [5]);
      LensDataEntryForm.Order14DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [6]);
      LensDataEntryForm.Order16DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [7]);
      LensDataEntryForm.Order18DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [8]);
      LensDataEntryForm.Order20DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [9]);
      LensDataEntryForm.Order22DeformationConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [10]);
      LensDataEntryForm.MaxEntranceAngleInAirDegreesEdit.Text := '';
      LensDataEntryForm.CPCRefractiveIndexEdit.Text := '';
      LensDataEntryForm.CPCExitAngleDegreesEdit.Text := '';
      LensDataEntryForm.RadiusOfCPCExitApertureEdit.Text := ''
    END
  ELSE
  IF (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = CPC)
      OR (ZBA_SURFACE [SurfaceOrdinal].SurfaceForm = HybridCPC) THEN
    BEGIN
      LensDataEntryForm.Order4DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order6DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order8DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order10DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order12DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order14DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order16DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order18DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order20DeformationConstantEdit.Text := '';
      LensDataEntryForm.Order22DeformationConstantEdit.Text := '';
      LensDataEntryForm.MaxEntranceAngleInAirDegreesEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          MaxEntranceAngleInAirDeg);
      LensDataEntryForm.CPCRefractiveIndexEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          CPCRefractiveIndex);
      LensDataEntryForm.CPCExitAngleDegreesEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ExitAngleDeg);
      LensDataEntryForm.RadiusOfCPCExitApertureEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          RadiusOfOutputAperture)
    END

END;

procedure TLensDataEntryForm.PrepareNewSurface(Sender: TObject);
begin

  LensDataEntryForm.ActiveControl := RadiusOfCurvatureEdit;
  LastFocus := lfNone;

  IF GetNewSurfaceData THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZDA_ALL_SURFACE_DATA :=
          ZEA_SURFACE_DATA_INITIALIZER;
      ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED := TRUE;
      ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := TRUE;
      ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV := 0.0;
      ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT := TRUE;
      ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
          ZBI_REFRACTIVE_INDEX := 1.0;
      ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
          ZBI_REFRACTIVE_INDEX := 1.0;
      ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns := 1;
      ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows := 1;
      ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z := 0.0
    END;

  PostAllCurrentSurfaceData

end;

procedure TLensDataEntryForm.ToggleSurfaceActiveSwitch(Sender: TObject);
begin

  IF SurfaceActiveButton.Kind = bkYes THEN
    BEGIN
      SurfaceActiveButton.Kind := bkNo;
      ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := FALSE
    END
  ELSE
    BEGIN
      SurfaceActiveButton.Kind := bkYes;
      ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := TRUE
    END;

  SurfaceActiveButton.Caption := 'Active';

  (* Reset modal result from nrNo or mrYes to mrNone *)

  ModalResult := mrNone

end;

procedure TLensDataEntryForm.ToggleOPDReferenceSurface(Sender: TObject);
begin

  IF OPDReferenceSurfButton.Kind = bkYes THEN
    BEGIN
      OPDReferenceSurfButton.Kind := bkNo;
      ZBA_SURFACE [SurfaceOrdinal].ZBF_OPD_REFERENCE := FALSE
    END
  ELSE
    BEGIN
      OPDReferenceSurfButton.Kind := bkYes;
      ZBA_SURFACE [SurfaceOrdinal].ZBF_OPD_REFERENCE := TRUE
    END;

  OPDReferenceSurfButton.Caption := 'OPD ref';

  ModalResult := mrNone


end;

procedure TLensDataEntryForm.ToggleScatteringSurface(Sender: TObject);
begin

  IF ScatteringSurfButton.Kind = bkYes THEN
    BEGIN
      ScatteringSurfButton.Kind := bkNo;
      ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE := FALSE;
      ScatteringAngleEdit.Text := '';
      ScatteringAngleEdit.Enabled := FALSE
    END
  ELSE
    BEGIN
      ScatteringAngleEdit.Enabled := TRUE;
      ScatteringSurfButton.Kind := bkYes;
      ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE := TRUE;
      ScatteringAngleEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians)
    END;

  ScatteringSurfButton.Caption := 'Scatter';

  ModalResult := mrNone

end;

procedure TLensDataEntryForm.ToggleLensletArraySwitch(Sender: TObject);

  VAR
      OK  : BOOLEAN;

begin

  IF LensletArrayButton.Kind = bkYes THEN
    BEGIN
      LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
      LensDataEntryForm.LensletArrayRowsEdit.Text := '';
      LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
      LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
      LensletArrayButton.Kind := bkNo;
      ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE
    END
  ELSE
    BEGIN
      OK := FALSE;
      IF ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD THEN
        BEGIN
          IF ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR
            OR ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL THEN
            IF (ZBA_SURFACE [SurfaceOrdinal].ZCP_OUTSIDE_APERTURE_WIDTH_X > 0.0)
                AND (ZBA_SURFACE [SurfaceOrdinal].
                ZCQ_OUTSIDE_APERTURE_WIDTH_Y > 0.0) THEN
              OK := TRUE
            ELSE
          ELSE
            IF ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA > 0.0 THEN
              OK := TRUE
        END;
      IF OK THEN
        BEGIN
          LensDataEntryForm.LensletArrayColumnsEdit.Enabled := TRUE;
          LensDataEntryForm.LensletArrayRowsEdit.Enabled := TRUE;
          LensDataEntryForm.LensletArrayColumnsEdit.Text :=
              IntToStr (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns);
          LensDataEntryForm.LensletArrayRowsEdit.Text :=
              IntToStr (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows);
          LensDataEntryForm.LensletArrayColumnsEdit.SetFocus;
          LensDataEntryForm.LensletArrayButton.Kind := bkYes;
          ZBA_SURFACE [SurfaceOrdinal].LensletArray := TRUE
        END
      ELSE
        BEGIN
          LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
          LensDataEntryForm.LensletArrayRowsEdit.Text := '';
          LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
          LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
          LensletArrayButton.Kind := bkNo;
          ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE
        END
    END;

  LensletArrayButton.Caption := 'Array';

  ModalResult := mrNone

end;

procedure TLensDataEntryForm.ValidateRadiusOfCurvature(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfRadiusOfCurvature;

  IF Length (RadiusOfCurvatureEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring previous ' +
          'value for radius of curvature.';
      RadiusOfCurvatureEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV);
      IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
        RadiusOfCurvatureLabel.Caption := 'Flat'
      ELSE
        RadiusOfCurvatureLabel.Caption := 'Radius'
    END
  ELSE
    BEGIN
      VAL (RadiusOfCurvatureEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV :=
                RealNumber;
            IF ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT := TRUE;
                RadiusOfCurvatureLabel.Caption := 'Flat'
              END
            ELSE
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT := FALSE;
                RadiusOfCurvatureLabel.Caption := 'Radius'
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Radius of curvature must be' +
                ' greater than or equal to zero.';
            RadiusOfCurvatureEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RadiusOfCurvatureEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateConicConstant(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfConicConstant;

  IF Length (ConicConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring previous ' +
          'value for conic constant.';
      ConicConstantEdit.Text :=
          FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT)
    END
  ELSE
    BEGIN
      VAL (ConicConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        BEGIN
          ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT :=
              RealNumber;
          IF abs (RealNumber) <= 1.0e-12 THEN
            ZBA_SURFACE [SurfaceOrdinal].ZBL_CONIC_CONSTANT := 0.0
        END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          ConicConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateRefractiveIndex1(Sender: TObject);

  VAR
      GRINMaterialAliasFound  : BOOLEAN;
      ActualGRINMatlFound     : BOOLEAN;

      CODE                    : INTEGER;

      RealNumber              : DOUBLE;

      Alias                   : GlassType;
      GRINMaterialName        : GlassType;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfRefractiveIndex1;

  IF Length (RefractiveIndex1Edit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring previous ' +
          'value for glass type/refractive index for side #1 of this ' +
          'material interface.';
      IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1] THEN
        RefractiveIndex1Edit.Text := ZBA_SURFACE [SurfaceOrdinal].
            ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME
      ELSE
        RefractiveIndex1Edit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
            ZBI_REFRACTIVE_INDEX)
    END
  ELSE
    BEGIN
      VAL (RefractiveIndex1Edit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
(*        IF RealNumber >= 1.0 THEN*)
        IF RealNumber > 0.0 THEN
          BEGIN
	    ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
	        ZBI_REFRACTIVE_INDEX := RealNumber;
	    ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1] := FALSE;
	    ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Refractive index must be' +
(*                ' greater than or equal to 1.0.';*)
                ' greater than 0.0.';
            RefractiveIndex1Edit.SetFocus
          END
      ELSE
        IF Length (RefractiveIndex1Edit.Text) <=
            CZAH_MAX_CHARS_IN_GLASS_NAME THEN
          BEGIN
            CalledFromGUI := TRUE;
	    AKJ_SPECIFIED_GLASS_NAME := UpperCase (RefractiveIndex1Edit.Text);
	    AKE_ADD_GLASS_TO_MINI_CATALOG := TRUE;
            Z01_INITIALIZE;
      	    U010_SEARCH_GLASS_CATALOG
	       (AKE_ADD_GLASS_TO_MINI_CATALOG,
	        AKF_GLASS_RECORD_FOUND,
                FoundGradientIndexMaterial,
	        ABE_GLASS_IN_MINI_CATALOG,
                ABC_GLASS_MINI_CAT_PTR);
            CalledFromGUI := FALSE;
            IF NOT AKF_GLASS_RECORD_FOUND THEN
	      BEGIN
                Alias := AKJ_SPECIFIED_GLASS_NAME;
                U016CheckBulkGRINMatlAliases
                    (Alias,
                    GRINMaterialAliasFound,
                    ActualGRINMatlFound,
                    GRINMaterialName);
                IF GRINMaterialAliasFound THEN
                  BEGIN
	            ZBA_SURFACE [SurfaceOrdinal].
	                ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME := Alias;
	            ZBA_SURFACE [SurfaceOrdinal].
	                ZCF_GLASS_NAME_SPECIFIED [1] := TRUE;
	            ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE
                  END
                ELSE
                  BEGIN
	            SurfaceDataValidationMessage.Text :=
                        'ATTENTION: Specified glass name "' +
		        AKJ_SPECIFIED_GLASS_NAME +
		        '" not found in glass catalog.';
                    AKJ_SPECIFIED_GLASS_NAME := '';
                    RefractiveIndex1Edit.SetFocus
                  END
              END
            ELSE
            IF FoundGradientIndexMaterial THEN
              BEGIN
                SurfaceDataValidationMessage.Text :=
                    'ERROR:  Gradient index material ' +
                    AKJ_SPECIFIED_GLASS_NAME + ' must be ' +
                    'referenced indirectly by an alias.  Use' +
                    ' the G(lass command to establish an alias' +
                    ' for this material.';
                AKF_GLASS_RECORD_FOUND := FALSE;
                AKJ_SPECIFIED_GLASS_NAME := '';
                IF ABE_GLASS_IN_MINI_CATALOG THEN
                  BEGIN
                    ABE_GLASS_IN_MINI_CATALOG := FALSE;
                    ABD_GLASS_HIGH_PTR := ABD_GLASS_HIGH_PTR - 1;
                    ABC_GLASS_MINI_CAT_PTR := ABD_GLASS_HIGH_PTR
                  END;
                RefractiveIndex1Edit.SetFocus
              END
            ELSE
              BEGIN
	        ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
                    ZCH_GLASS_NAME := AKJ_SPECIFIED_GLASS_NAME;
	        ZBA_SURFACE [SurfaceOrdinal].
                    ZCF_GLASS_NAME_SPECIFIED [1] := TRUE;
	        ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Glass name must not exceed ' +
                IntToStr (CZAH_MAX_CHARS_IN_GLASS_NAME) +
                ' alphanumeric characters.';
            RefractiveIndex1Edit.SetFocus
          END
    END

end;

procedure TLensDataEntryForm.ValidateRefractiveIndex2(Sender: TObject);

  VAR
      GRINMaterialAliasFound  : BOOLEAN;
      ActualGRINMatlFound     : BOOLEAN;

      CODE                    : INTEGER;

      RealNumber              : DOUBLE;

      Alias                   : GlassType;
      GRINMaterialName        : GlassType;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfRefractiveIndex2;

  IF Length (RefractiveIndex2Edit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring previous ' +
          'value for glass type/refractive index for side #2 of this ' +
          'material interface.';
      IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] THEN
        RefractiveIndex1Edit.Text := ZBA_SURFACE [SurfaceOrdinal].
            ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME
      ELSE
        RefractiveIndex1Edit.Text :=
            FloatToStr (ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
            ZBI_REFRACTIVE_INDEX)
    END
  ELSE
    BEGIN
      VAL (RefractiveIndex2Edit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
(*        IF RealNumber >= 1.0 THEN*)
        IF RealNumber > 0.0 THEN
          BEGIN
	    ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
	        ZBI_REFRACTIVE_INDEX := RealNumber;
	    ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] := FALSE;
	    ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Refractive index must be' +
(*                ' greater than or equal to 1.0.';*)
                ' greater than 0.0.';
            RefractiveIndex2Edit.SetFocus
          END
      ELSE
        IF Length (RefractiveIndex2Edit.Text) <=
            CZAH_MAX_CHARS_IN_GLASS_NAME THEN
          BEGIN
            CalledFromGUI := TRUE;
	    AKJ_SPECIFIED_GLASS_NAME := UpperCase (RefractiveIndex2Edit.Text);
	    AKE_ADD_GLASS_TO_MINI_CATALOG := TRUE;
            Z01_INITIALIZE;
      	    U010_SEARCH_GLASS_CATALOG
	       (AKE_ADD_GLASS_TO_MINI_CATALOG,
	        AKF_GLASS_RECORD_FOUND,
                FoundGradientIndexMaterial,
	        ABE_GLASS_IN_MINI_CATALOG,
                ABC_GLASS_MINI_CAT_PTR);
            CalledFromGUI := FALSE;
            IF NOT AKF_GLASS_RECORD_FOUND THEN
	      BEGIN
                Alias := AKJ_SPECIFIED_GLASS_NAME;
                U016CheckBulkGRINMatlAliases
                    (Alias,
                    GRINMaterialAliasFound,
                    ActualGRINMatlFound,
                    GRINMaterialName);
                IF GRINMaterialAliasFound THEN
                  BEGIN
	            ZBA_SURFACE [SurfaceOrdinal].
	                ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME := Alias;
	            ZBA_SURFACE [SurfaceOrdinal].
	                ZCF_GLASS_NAME_SPECIFIED [2] := TRUE;
	            ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE
                  END
                ELSE
                  BEGIN
	            SurfaceDataValidationMessage.Text :=
                        'ATTENTION: Specified glass name "' +
		        AKJ_SPECIFIED_GLASS_NAME +
		        '" not found in glass catalog.';
                    AKJ_SPECIFIED_GLASS_NAME := '';
                    RefractiveIndex2Edit.SetFocus
                  END
              END
            ELSE
            IF FoundGradientIndexMaterial THEN
              BEGIN
                SurfaceDataValidationMessage.Text :=
                    'ERROR:  Gradient index material ' +
                    AKJ_SPECIFIED_GLASS_NAME + ' must be ' +
                    'referenced indirectly by an alias.  Use' +
                    ' the G(lass command to establish an alias' +
                    ' for this material.';
                AKF_GLASS_RECORD_FOUND := FALSE;
                AKJ_SPECIFIED_GLASS_NAME := '';
                IF ABE_GLASS_IN_MINI_CATALOG THEN
                  BEGIN
                    ABE_GLASS_IN_MINI_CATALOG := FALSE;
                    ABD_GLASS_HIGH_PTR := ABD_GLASS_HIGH_PTR - 1;
                    ABC_GLASS_MINI_CAT_PTR := ABD_GLASS_HIGH_PTR
                  END;
                RefractiveIndex2Edit.SetFocus
              END
            ELSE
              BEGIN
	        ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
                    ZCH_GLASS_NAME := AKJ_SPECIFIED_GLASS_NAME;
	        ZBA_SURFACE [SurfaceOrdinal].
                    ZCF_GLASS_NAME_SPECIFIED [2] := TRUE;
	        ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Glass name must not exceed ' +
                IntToStr (CZAH_MAX_CHARS_IN_GLASS_NAME) +
                ' alphanumeric characters.';
            RefractiveIndex2Edit.SetFocus
          END
    END

end;

procedure TLensDataEntryForm.ValidateOuterClearApDia(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfOutsideApertureDia;

  IF Length (OuterClearApDiaEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'outer clear aperture diameter.';
      LensDataEntryForm.OuterClearApDiaEdit.Text :=
          FloatToStr (DefaultOuterSurfaceDiameter);
      ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA :=
          DefaultOuterSurfaceDiameter;
      LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
      LensDataEntryForm.LensletArrayRowsEdit.Text := '';
      LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
      LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
      LensletArrayButton.Kind := bkNo;
      ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
      LensletArrayButton.Caption := 'Array';
      ModalResult := mrNone
    END
  ELSE
    BEGIN
      VAL (OuterClearApDiaEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA :=
                RealNumber;
            ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := TRUE;
            IF ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].ZBJ_OUTSIDE_APERTURE_DIA := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := FALSE;
                LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
                LensDataEntryForm.LensletArrayRowsEdit.Text := '';
                LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
                LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
                LensletArrayButton.Kind := bkNo;
                ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
                LensletArrayButton.Caption := 'Array';
                ModalResult := mrNone
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Outside aperture diameter ' +
                'must be greater than or equal to zero.';
            OuterClearApDiaEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          OuterClearApDiaEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateOuterApertureXDim(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfOutsideApertureWidthX;

  IF Length (OutsideApertureXDimEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'outer clear aperture X dimension.';
      LensDataEntryForm.OutsideApertureXDimEdit.Text :=
          FloatToStr (DefaultOuterApertureXDimension);
      ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCP_OUTSIDE_APERTURE_WIDTH_X :=
          DefaultOuterApertureXDimension;
      LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
      LensDataEntryForm.LensletArrayRowsEdit.Text := '';
      LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
      LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
      LensletArrayButton.Kind := bkNo;
      ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
      LensletArrayButton.Caption := 'Array';
      ModalResult := mrNone
    END
  ELSE
    BEGIN
      VAL (OutsideApertureXDimEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZCP_OUTSIDE_APERTURE_WIDTH_X :=
                RealNumber;
            ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := TRUE;
            IF ZBA_SURFACE [SurfaceOrdinal].ZCP_OUTSIDE_APERTURE_WIDTH_X <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].
                    ZCP_OUTSIDE_APERTURE_WIDTH_X := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := FALSE
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Outside aperture X ' +
                'dimension must be greater than or equal to zero.';
            OutsideApertureXDimEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          OutsideApertureXDimEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateOuterApertureYDim(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfOutsideApertureWidthY;

  IF Length (OutsideApertureYDimEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'outer clear aperture Y dimension.';
      LensDataEntryForm.OutsideApertureYDimEdit.Text :=
          FloatToStr (DefaultOuterApertureYDimension);
      ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCQ_OUTSIDE_APERTURE_WIDTH_Y :=
          DefaultOuterApertureYDimension;
      LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
      LensDataEntryForm.LensletArrayRowsEdit.Text := '';
      LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
      LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
      LensletArrayButton.Kind := bkNo;
      ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
      LensletArrayButton.Caption := 'Array';
      ModalResult := mrNone
    END
  ELSE
    BEGIN
      VAL (OutsideApertureYDimEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZCQ_OUTSIDE_APERTURE_WIDTH_Y :=
                RealNumber;
            ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := TRUE;
            IF ZBA_SURFACE [SurfaceOrdinal].ZCQ_OUTSIDE_APERTURE_WIDTH_Y <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].
                    ZCQ_OUTSIDE_APERTURE_WIDTH_Y := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZBH_OUTSIDE_DIMENS_SPECD := FALSE
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Outside aperture Y ' +
                'dimension must be greater than or equal to zero.';
            OutsideApertureYDimEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          OutsideApertureYDimEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateInnerClearApDia(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfInsideApertureDia;

  IF Length (InnerApertureDiameterEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'inner aperture diameter.';
      LensDataEntryForm.InnerApertureDiameterEdit.Text :=
          FloatToStr (DefaultInnerApertureDiameter);
      ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZBK_INSIDE_APERTURE_DIA :=
          DefaultInnerApertureDiameter;
      InnerApertureRadioGroup.ItemIndex := -1
    END
  ELSE
    BEGIN
      VAL (InnerApertureDiameterEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZBK_INSIDE_APERTURE_DIA :=
                RealNumber;
            ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := TRUE;
            IF ZBA_SURFACE [SurfaceOrdinal].ZBK_INSIDE_APERTURE_DIA <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].ZBK_INSIDE_APERTURE_DIA := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := FALSE;
                InnerApertureRadioGroup.ItemIndex := -1
              END
            ELSE
              InnerApertureRadioGroup.ItemIndex := 0
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Inside aperture diameter ' +
                'must be greater than or equal to zero.';
            InnerApertureDiameterEdit.SetFocus;
            InnerApertureRadioGroup.ItemIndex := -1
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          InnerApertureDiameterEdit.SetFocus;
          InnerApertureRadioGroup.ItemIndex := -1
        END
    END

end;

procedure TLensDataEntryForm.ValidateLensletColumns(Sender: TObject);

  VAR
      IntegerNumber         : INTEGER;
      CODE                  : INTEGER;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfLensletArrayColumns;

  IF Length (LensletArrayColumnsEdit.Text) = 0 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns :=
          DefaultLensletArrayColumns;
      IF ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows =
          DefaultLensletArrayRows THEN
        BEGIN
          SurfaceDataValidationMessage.Text := 'No input.  Cancelling lenslet' +
              ' array.';
          LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
          LensDataEntryForm.LensletArrayRowsEdit.Text := '';
          LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
          LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
          LensletArrayButton.Kind := bkNo;
          ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
          LensletArrayButton.Caption := 'Array';
          ModalResult := mrNone
        END
      ELSE
        SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
            'lenslet array column count.'
    END
  ELSE
    BEGIN
      VAL (LensletArrayColumnsEdit.Text, IntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (IntegerNumber >= 1) THEN
          IF ((IntegerNumber MOD 2) <> 0) THEN
            BEGIN
              ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns :=
                  IntegerNumber;
              IF (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns = 1)
                  AND (ZBA_SURFACE [SurfaceOrdinal].
                  LensletArrayTotalRows = 1) THEN
                BEGIN
                  SurfaceDataValidationMessage.Text := 'Cancelling ' +
                      'lenslet array.';
                  LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
                  LensDataEntryForm.LensletArrayRowsEdit.Text := '';
                  LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
                  LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
                  LensletArrayButton.Kind := bkNo;
                  ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
                  LensletArrayButton.Caption := 'Array';
                  ModalResult := mrNone
                END
            END
          ELSE
            BEGIN
              SurfaceDataValidationMessage.Text := 'ERROR: Number of columns ' +
                  'in lenslet array must be an odd integer (3, 5, 7, etc.).';
              LensDataEntryForm.LensletArrayColumnsEdit.SetFocus
            END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'ERROR: Number of columns ' +
                'in lenslet array must be greater than or equal to one.';
            LensDataEntryForm.LensletArrayColumnsEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          LensDataEntryForm.LensletArrayColumnsEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateLensletRows(Sender: TObject);

  VAR
      IntegerNumber         : INTEGER;
      CODE                  : INTEGER;

begin


  SurfaceDataValidationMessage.Clear;
  LastFocus := lfLensletArrayRows;

  IF Length (LensletArrayRowsEdit.Text) = 0 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows :=
          DefaultLensletArrayRows;
      IF ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns =
          DefaultLensletArrayColumns THEN
        BEGIN
          SurfaceDataValidationMessage.Text := 'No input.  Cancelling lenslet' +
              ' array.';
          LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
          LensDataEntryForm.LensletArrayRowsEdit.Text := '';
          LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
          LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
          LensletArrayButton.Kind := bkNo;
          ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
          LensletArrayButton.Caption := 'Array';
          ModalResult := mrNone
        END
      ELSE
        SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
            'lenslet array row count.'
    END
  ELSE
    BEGIN
      VAL (LensletArrayRowsEdit.Text, IntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (IntegerNumber >= 1) THEN
          IF ((IntegerNumber MOD 2) <> 0) THEN
            BEGIN
              ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows :=
                  IntegerNumber;
              IF (ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows = 1)
                  AND (ZBA_SURFACE [SurfaceOrdinal].
                  LensletArrayTotalColumns = 1) THEN
                BEGIN
                  SurfaceDataValidationMessage.Text := 'Cancelling ' +
                      'lenslet array.';
                  LensDataEntryForm.LensletArrayColumnsEdit.Text := '';
                  LensDataEntryForm.LensletArrayRowsEdit.Text := '';
                  LensDataEntryForm.LensletArrayColumnsEdit.Enabled := FALSE;
                  LensDataEntryForm.LensletArrayRowsEdit.Enabled := FALSE;
                  LensletArrayButton.Kind := bkNo;
                  ZBA_SURFACE [SurfaceOrdinal].LensletArray := FALSE;
                  LensletArrayButton.Caption := 'Array';
                  ModalResult := mrNone
                END
            END
          ELSE
            BEGIN
              SurfaceDataValidationMessage.Text := 'ERROR: Number of rows ' +
                  'in lenslet array must be an odd integer (3, 5, 7, etc.).';
              LensDataEntryForm.LensletArrayRowsEdit.SetFocus
            END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'ERROR: Number of rows ' +
                'in lenslet array must be greater than or equal to one.';
            LensDataEntryForm.LensletArrayRowsEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          LensDataEntryForm.LensletArrayRowsEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateScatteringAngle(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfScatteringAngle;

  IF Length (ScatteringAngleEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface scattering angle (radians).';
      ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians :=
          DefaultScatteringAngle;
      ScatteringSurfButton.Kind := bkNo;
      ScatteringSurfButton.Caption := 'Scatter';
      ModalResult := mrNone
    END
  ELSE
    BEGIN
      VAL (ScatteringAngleEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians :=
                RealNumber;
            IF ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].ScatteringAngleRadians := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE := FALSE;
                ScatteringSurfButton.Kind := bkNo;
                ScatteringSurfButton.Caption := 'Scatter';
                ModalResult := mrNone
              END
            ELSE
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].ZCC_SCATTERING_SURFACE := TRUE;
                ScatteringSurfButton.Kind := bkYes;
                ScatteringSurfButton.Caption := 'Scatter';
                ModalResult := mrNone
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Scattering angle (radians) ' +
                'must be greater than or equal to zero.';
            ScatteringAngleEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          ScatteringAngleEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateSurfaceReflectivity(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfSurfaceReflectivity;

  IF Length (SurfaceReflectivityEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface reflectivity.';
      ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY :=
          DefaultSurfaceReflectivity;
      SurfaceReflectivityEdit.Text := FloatToStr (DefaultSurfaceReflectivity);
      SurfaceActivityRadioGroup.ItemIndex := 0
    END
  ELSE
    BEGIN
      VAL (SurfaceReflectivityEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber < 0.0) THEN
          BEGIN
            SurfaceDataValidationMessage.Text := 'Surface reflectivity ' +
                'must be greater than or equal to zero and less than or ' +
                'equal to one.';
            SurfaceReflectivityEdit.SetFocus
          END
        ELSE
        IF RealNumber <= 1.0e-12 THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY := 0.0;
            ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE;
            SurfaceActivityRadioGroup.ItemIndex := 0
          END
        ELSE
        IF RealNumber < 1.0 THEN
          ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY := RealNumber
        ELSE
        IF abs (RealNumber - 1.0) < 1.0e-12 THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZCK_SURFACE_REFLECTIVITY := 1.0;
            ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := TRUE;
            SurfaceActivityRadioGroup.ItemIndex := 1
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Surface reflectivity ' +
                'must not be greater than one.';
            SurfaceReflectivityEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          SurfaceReflectivityEdit.SetFocus
        END
    END

end;


procedure TLensDataEntryForm.ValidateVertexXCoordinate(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfSurfaceVertexXPosition;

  IF Length (VertexXCoordinateEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface X coordinate.';
      ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X := DefaultSurfaceXCoordinate
    END
  ELSE
    BEGIN
      VAL (VertexXCoordinateEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZBM_VERTEX_X := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          VertexXCoordinateEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateVertexYCoordinate(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfSurfaceVertexYPosition;

  IF Length (VertexYCoordinateEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface Y coordinate.';
      ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y := DefaultSurfaceYCoordinate
    END
  ELSE
    BEGIN
      VAL (VertexYCoordinateEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZBO_VERTEX_Y := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          VertexYCoordinateEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateVertexZCoordinate(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfSurfaceVertexZPosition;

  IF Length (VertexZCoordinateEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface Z coordinate.';
      ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z := DefaultSurfaceZCoordinate
    END
  ELSE
    BEGIN
      VAL (VertexZCoordinateEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          VertexZCoordinateEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateVertexYaw(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfSurfaceVertexYaw;

  IF Length (VertexYawEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface yaw angle.';
      ZBA_SURFACE [SurfaceOrdinal].ZBW_YAW := DefaultSurfaceYaw
    END
  ELSE
    BEGIN
      VAL (VertexYawEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZBW_YAW := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          VertexYawEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateVertexPitch(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfSurfaceVertexPitch;

  IF Length (VertexPitchEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface pitch angle.';
      ZBA_SURFACE [SurfaceOrdinal].ZBU_PITCH := DefaultSurfacePitch
    END
  ELSE
    BEGIN
      VAL (VertexPitchEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZBU_PITCH := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          VertexPitchEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateVertexRoll(Sender: TObject);

  VAR
      CODE        : INTEGER;

      RealNumber  : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfSurfaceVertexRoll;

  IF Length (VertexRollEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface roll angle.';
      ZBA_SURFACE [SurfaceOrdinal].ZBS_ROLL := DefaultSurfaceRoll
    END
  ELSE
    BEGIN
      VAL (VertexRollEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZBS_ROLL := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          VertexRollEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.SetSurfaceActivity(Sender: TObject);
begin

  ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := FALSE;
  ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE := FALSE;
  ZBA_SURFACE [SurfaceOrdinal].ZCI_RAY_TERMINATION_SURFACE := FALSE;

  IF LensDataEntryForm.SurfaceActivityRadioGroup.ItemIndex = 1 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZBD_REFLECTIVE := TRUE;
      IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1]
          AND ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] THEN
        BEGIN
          IF ZBA_SURFACE [SurfaceOrdinal].
              ZCG_INDEX_OR_GLASS [1].ZCH_GLASS_NAME =
              ZBA_SURFACE [SurfaceOrdinal].
              ZCG_INDEX_OR_GLASS [2].ZCH_GLASS_NAME THEN
          ELSE
            SurfaceDataValidationMessage.Text := 'WARNING: Material type ' +
                'must be consistent across a reflective boundary.'
        END
      ELSE
      IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [1] THEN
      ELSE
      IF ZBA_SURFACE [SurfaceOrdinal].ZCF_GLASS_NAME_SPECIFIED [2] THEN
      ELSE
      IF ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
          ZBI_REFRACTIVE_INDEX = ZBA_SURFACE [SurfaceOrdinal].
          ZCG_INDEX_OR_GLASS [2].ZBI_REFRACTIVE_INDEX THEN
      ELSE
          SurfaceDataValidationMessage.Text := 'WARNING: Material type ' +
              'must be consistent across a reflective boundary.'
    END
  ELSE
  IF LensDataEntryForm.SurfaceActivityRadioGroup.ItemIndex = 2 THEN
    ZBA_SURFACE [SurfaceOrdinal].ZBY_BEAMSPLITTER_SURFACE := TRUE
  ELSE
  IF LensDataEntryForm.SurfaceActivityRadioGroup.ItemIndex = 3 THEN
    ZBA_SURFACE [SurfaceOrdinal].ZCI_RAY_TERMINATION_SURFACE := TRUE

end;

procedure TLensDataEntryForm.SetSurfaceForm(Sender: TObject);
begin

  IF LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex = 0 THEN
    ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := Conic
  ELSE
  IF LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex = 1 THEN
    ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := HighOrderAsphere
  ELSE
  IF LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex = 2 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := CPC
    END
  ELSE
  IF LensDataEntryForm.SurfaceFormRadioGroup.ItemIndex = 3 THEN
    ZBA_SURFACE [SurfaceOrdinal].SurfaceForm := HybridCPC;

  PostAllCurrentSurfaceData

end;

procedure TLensDataEntryForm.SetSurfaceSymmetry(Sender: TObject);
begin

  IF LensDataEntryForm.SurfaceSymmetryRadioGroup.ItemIndex = 0 THEN
    ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := FALSE
  ELSE
  IF LensDataEntryForm.SurfaceSymmetryRadioGroup.ItemIndex = 1 THEN
    ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := TRUE
  ELSE
  IF LensDataEntryForm.SurfaceSymmetryRadioGroup.ItemIndex = 2 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZBE_CYLINDRICAL := FALSE;
      LensDataEntryForm.SurfaceSymmetryRadioGroup.ItemIndex := 0;
      SurfaceDataValidationMessage.Text := 'Toroidal surfaces not presently ' +
          'supported.  Reverting to regular surface.';
    END

end;

procedure TLensDataEntryForm.DisplayPreviousSurface(Sender: TObject);
begin

  Dec (SurfaceOrdinal);

  PostAllCurrentSurfaceData

end;

procedure TLensDataEntryForm.DisplayNextSurface(Sender: TObject);
begin

  Inc (SurfaceOrdinal);

  IF NOT ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED THEN
    BEGIN
      LensDataEntryForm.Visible := FALSE;
      Q970AB_OUTPUT_STRING := 'Surface ' +
          IntToStr (SurfaceOrdinal) + ' not specified.  ' +
          'Do you wish to define it?';
      Q970_REQUEST_PERMIT_TO_PROCEED;
      LensDataEntryForm.Visible := TRUE;
      IF Q970AA_OK_TO_PROCEED THEN
        BEGIN
          ZBA_SURFACE [SurfaceOrdinal].ZBB_SPECIFIED := TRUE;
          ZBA_SURFACE [SurfaceOrdinal].ZBC_ACTIVE := TRUE;
          ZBA_SURFACE [SurfaceOrdinal].ZBG_RADIUS_OF_CURV := 0.0;
          ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT := TRUE;
          ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [1].
              ZBI_REFRACTIVE_INDEX := 1.0;
          ZBA_SURFACE [SurfaceOrdinal].ZCG_INDEX_OR_GLASS [2].
              ZBI_REFRACTIVE_INDEX := 1.0;
          ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalColumns := 1;
          ZBA_SURFACE [SurfaceOrdinal].LensletArrayTotalRows := 1;
          ZBA_SURFACE [SurfaceOrdinal].ZBQ_VERTEX_Z := 0.0;
        END
    END;

  PostAllCurrentSurfaceData

end;

procedure TLensDataEntryForm.GetSurfaceOrdinal(Sender: TObject);

  VAR
      CODE           : INTEGER;
      IntegerNumber  : INTEGER;

begin

  SurfaceDataValidationMessage.Clear;

  IF Length (SurfaceNumberEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'surface ordinal number.';
      SurfaceOrdinal := DefaultSurfaceOrdinal;
      PostAllCurrentSurfaceData
    END
  ELSE
    BEGIN
      VAL (SurfaceNumberEdit.Text, IntegerNumber, CODE);
      IF CODE = 0 THEN
        IF (IntegerNumber > 0)
            AND (IntegerNumber <= CZAB_MAX_NUMBER_OF_SURFACES) THEN
          BEGIN
            SurfaceOrdinal := IntegerNumber;
            PostAllCurrentSurfaceData
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'ERROR: Surface ordinal ' +
                'number must be an integer in the range 1 to ' +
                IntToStr (CZAB_MAX_NUMBER_OF_SURFACES) + '.  Please re-enter.';
            SurfaceNumberEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'ERROR: Non-numeric or ' +
              'non-integer value.  Please re-enter.';
          SurfaceNumberEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.CloseSurfDataEntryForm(Sender: TObject);
begin

  ModalResult := mrCancel

end;

procedure TLensDataEntryForm.SelectOuterApertureType(Sender: TObject);
begin

  IF LensDataEntryForm.OuterApertureRadioGroup.ItemIndex = 0 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL := FALSE;
      LensDataEntryForm.OuterClearApDiaEdit.SetFocus
    END
  ELSE
  IF LensDataEntryForm.OuterApertureRadioGroup.ItemIndex = 1 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR := TRUE;
      ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL := FALSE;
      LensDataEntryForm.OutsideApertureXDimEdit.SetFocus
    END
  ELSE
  IF LensDataEntryForm.OuterApertureRadioGroup.ItemIndex = 2 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZCL_OUTSIDE_APERTURE_IS_SQR := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCN_OUTSIDE_APERTURE_ELLIPTICAL := TRUE;
      LensDataEntryForm.OutsideApertureXDimEdit.SetFocus
    END

end;

procedure TLensDataEntryForm.SelectInnerApertureType(Sender: TObject);
begin

  IF LensDataEntryForm.InnerApertureRadioGroup.ItemIndex = 0 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL := FALSE;
      LensDataEntryForm.InnerApertureDiameterEdit.SetFocus
    END
  ELSE
  IF LensDataEntryForm.OuterApertureRadioGroup.ItemIndex = 1 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR := TRUE;
      ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL := FALSE;
      LensDataEntryForm.InsideApertureXDimEdit.SetFocus
    END
  ELSE
  IF LensDataEntryForm.OuterApertureRadioGroup.ItemIndex = 2 THEN
    BEGIN
      ZBA_SURFACE [SurfaceOrdinal].ZCM_INSIDE_APERTURE_IS_SQR := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCO_INSIDE_APERTURE_ELLIPTICAL := TRUE;
      LensDataEntryForm.InsideApertureXDimEdit.SetFocus
    END

end;

procedure TLensDataEntryForm.ValidateInsideApertureXDim(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfInsideApertureWidthX;

  IF Length (InsideApertureXDimEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'inside aperture X dimension.';
      LensDataEntryForm.InsideApertureXDimEdit.Text :=
          FloatToStr (DefaultInnerApertureXDimension);
      ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCR_INSIDE_APERTURE_WIDTH_X :=
          DefaultInnerApertureXDimension
    END
  ELSE
    BEGIN
      VAL (InsideApertureXDimEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZCR_INSIDE_APERTURE_WIDTH_X :=
                RealNumber;
            ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := TRUE;
            IF ZBA_SURFACE [SurfaceOrdinal].ZCR_INSIDE_APERTURE_WIDTH_X <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].
                    ZCR_INSIDE_APERTURE_WIDTH_X := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := FALSE
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Inside aperture X ' +
                'dimension must be greater than or equal to zero.';
            InsideApertureXDimEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          InsideApertureXDimEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateInsideApertureYDim(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfInsideApertureWidthY;

  IF Length (InsideApertureYDimEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'inside aperture Y dimension.';
      LensDataEntryForm.InsideApertureYDimEdit.Text :=
          FloatToStr (DefaultInnerApertureYDimension);
      ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := FALSE;
      ZBA_SURFACE [SurfaceOrdinal].ZCS_INSIDE_APERTURE_WIDTH_Y :=
          DefaultInnerApertureYDimension
    END
  ELSE
    BEGIN
      VAL (InsideApertureYDimEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0) THEN
          BEGIN
            ZBA_SURFACE [SurfaceOrdinal].ZCS_INSIDE_APERTURE_WIDTH_Y :=
                RealNumber;
            ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := TRUE;
            IF ZBA_SURFACE [SurfaceOrdinal].ZCS_INSIDE_APERTURE_WIDTH_Y <=
                1.0e-12 THEN
              BEGIN
                ZBA_SURFACE [SurfaceOrdinal].
                    ZCS_INSIDE_APERTURE_WIDTH_Y := 0.0;
                ZBA_SURFACE [SurfaceOrdinal].ZCT_INSIDE_DIMENS_SPECD := FALSE
              END
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Inside aperture Y ' +
                'dimension must be greater than or equal to zero.';
            InsideApertureYDimEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          InsideApertureYDimEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateApertureOffsetX(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfApertureOffsetX;

  IF NOT ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'Rectangular or elliptical ' +
          'apertures permitted only on flat surfaces.';
      ApertureOffsetXEdit.Text := '';
      RadialSectorCenterAzEdit.SetFocus
    END
  ELSE
  IF Length (ApertureOffsetXEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'aperture X offset.';
      LensDataEntryForm.ApertureOffsetXEdit.Text :=
          FloatToStr (DefaultApertureXOffset);
      ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X :=
          DefaultApertureXOffset
    END
  ELSE
    BEGIN
      VAL (ApertureOffsetXEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          ApertureOffsetXEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateApertureOffsetY(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfApertureOffsetY;

  IF NOT ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'Rectangular or elliptical ' +
          'apertures permitted only on flat surfaces.';
      ApertureOffsetYEdit.Text := '';
      RadialSectorAngularWidthEdit.SetFocus
    END
  ELSE
  IF Length (ApertureOffsetYEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'aperture Y offset.';
      LensDataEntryForm.ApertureOffsetYEdit.Text :=
          FloatToStr (DefaultApertureYOffset);
      ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y :=
          DefaultApertureYOffset
    END
  ELSE
    BEGIN
      VAL (ApertureOffsetYEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          ApertureOffsetYEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateCenterAzimuth(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfRadialSectorCenterAz;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'Radial sector ' +
          'apertures permitted only on curved surfaces.';
      RadialSectorCenterAzEdit.Text := '';
      ApertureOffsetXEdit.SetFocus
    END
  ELSE
  IF Length (RadialSectorCenterAzEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'radial sector center azimuth angle.';
      LensDataEntryForm.RadialSectorCenterAzEdit.Text :=
          FloatToStr (DefaultRadialSectorCenterAzimuth);
      ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X :=
          DefaultRadialSectorCenterAzimuth
    END
  ELSE
    BEGIN
      VAL (RadialSectorCenterAzEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF abs (RealNumber) < 360.0 THEN
          BEGIN
            IF abs (RealNumber) < 1.0E-12 THEN
              RealNumber := 0.0;
            ZBA_SURFACE [SurfaceOrdinal].ZCV_APERTURE_POSITION_X := RealNumber
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Radial sector center ' +
                'azimuth angle must be greater than -360 degrees, ' +
                'and less than 360 degrees.  Please re-enter.';
            RadialSectorCenterAzEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RadialSectorCenterAzEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateSectorAngularWidth(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfRadialSectorAngularWidth;

  IF ZBA_SURFACE [SurfaceOrdinal].ZBZ_SURFACE_IS_FLAT THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'Radial sector ' +
          'apertures permitted only on curved surfaces.';
      RadialSectorAngularWidthEdit.Text := '';
      ApertureOffsetYEdit.SetFocus
    END
  ELSE
  IF Length (RadialSectorAngularWidthEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'radial sector angular width.';
      LensDataEntryForm.RadialSectorAngularWidthEdit.Text :=
          FloatToStr (DefaultRadialSectorAngularWidth);
      ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y :=
          DefaultRadialSectorAngularWidth
    END
  ELSE
    BEGIN
      VAL (RadialSectorAngularWidthEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 0.0)
            AND (RealNumber < 360.0) THEN
          BEGIN
            IF abs (RealNumber) < 1.0E-12 THEN
              RealNumber := 0.0;
            ZBA_SURFACE [SurfaceOrdinal].ZCW_APERTURE_POSITION_Y := RealNumber
          END
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'Radial sector angular ' +
                'width must be greater than or equal to zero, ' +
                'and less than 360 degrees.  Please re-enter.';
            RadialSectorAngularWidthEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RadialSectorAngularWidthEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate4thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order4DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order4DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [1]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order4DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [1]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order4DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate6thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order6DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order6DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [2]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order6DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [2]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order6DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate8thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order8DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order8DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [3]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order8DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [3]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order8DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate10thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order10DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order10DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [4]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order10DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [4]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order10DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate12thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order12DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order12DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [5]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order12DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [5]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order12DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate14thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order14DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order14DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [6]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order14DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [6]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order14DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate16thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order16DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order16DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [7]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order16DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [7]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order16DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate18thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order18DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order18DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [8]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order18DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [8]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order18DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate20thOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order20DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order20DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [9]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order20DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [9]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order20DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.Validate22ndOrderDefConst(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfAsphericDeformationConstants;

  IF Length (Order22DeformationConstantEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'deformation constant.';
      LensDataEntryForm.Order22DeformationConstantEdit.Text :=
          FloatToStr (DefaultDeformationConstant);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ZCA_DEFORMATION_CONSTANT [10]:= DefaultDeformationConstant
    END
  ELSE
    BEGIN
      VAL (Order22DeformationConstantEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
            ZCA_DEFORMATION_CONSTANT [10]:= RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          Order22DeformationConstantEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateCPCMaxEntAngle(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfCPCMaxEntraceAngle;

  IF Length (MaxEntranceAngleInAirDegreesEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default CPC ' +
          'maximum entrance angle in air.';
      LensDataEntryForm.MaxEntranceAngleInAirDegreesEdit.Text :=
          FloatToStr (DefaultCPCMaxEntraceAngle);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          MaxEntranceAngleInAirDeg := DefaultCPCMaxEntraceAngle
    END
  ELSE
    BEGIN
      VAL (MaxEntranceAngleInAirDegreesEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber > 0.0)
            AND (RealNumber < 90.0) THEN
          ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              MaxEntranceAngleInAirDeg := RealNumber
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'CPC maximum entrance angle ' +
                'in air must be greater than zero ' +
                'and less than 90 degrees.  Please re-enter.';
            MaxEntranceAngleInAirDegreesEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          MaxEntranceAngleInAirDegreesEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateCPCRefractiveIndex(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfCPCRefractiveIndex;

  IF Length (CPCRefractiveIndexEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default CPC ' +
          'refractive index.';
      LensDataEntryForm.CPCRefractiveIndexEdit.Text :=
          FloatToStr (DefaultCPCRefractiveIndex);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          CPCRefractiveIndex := DefaultCPCRefractiveIndex
    END
  ELSE
    BEGIN
      VAL (CPCRefractiveIndexEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber >= 1.0) THEN
          ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              CPCRefractiveIndex := RealNumber
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'CPC refractive index ' +
                'must be greater than or equal to one.  Please re-enter.';
            CPCRefractiveIndexEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          CPCRefractiveIndexEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateCPCExitAngle(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfCPCExitAngle;

  IF Length (CPCExitAngleDegreesEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default CPC ' +
          'exit angle.';
      LensDataEntryForm.CPCExitAngleDegreesEdit.Text :=
          FloatToStr (DefaultCPCExitAngle);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          ExitAngleDeg := DefaultCPCExitAngle
    END
  ELSE
    BEGIN
      VAL (CPCExitAngleDegreesEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber > 0.0)
            AND (RealNumber < 90.0) THEN
          ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              ExitAngleDeg := RealNumber
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'CPC exit angle must be ' +
                'greater than zero and less than 90 degrees.  Please re-enter.';
            CPCExitAngleDegreesEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          CPCExitAngleDegreesEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateCPCExitApertureRadius(
  Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfCPCExitApertureRadius;

  IF Length (RadiusOfCPCExitApertureEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default CPC ' +
          'exit aperture radius.';
      LensDataEntryForm.RadiusOfCPCExitApertureEdit.Text :=
          FloatToStr (DefaultCPCExitApertureRadius);
      ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
          RadiusOfOutputAperture := DefaultCPCExitApertureRadius
    END
  ELSE
    BEGIN
      VAL (RadiusOfCPCExitApertureEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        IF (RealNumber > 0.0) THEN
          ZBA_SURFACE [SurfaceOrdinal].SurfaceShapeParameters.
              RadiusOfOutputAperture := RealNumber
        ELSE
          BEGIN
            SurfaceDataValidationMessage.Text := 'CPC exit aperture radius ' +
                'must be greater than zero.  Please re-enter.';
            RadiusOfCPCExitApertureEdit.SetFocus
          END
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          RadiusOfCPCExitApertureEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.LensDataEntryHelpButtonClick(Sender: TObject);
begin

  CommandIOMemo.IOHistory.Clear;
  CommandIOMemo.BringToFront;

  IF LastFocus = lfRadiusOfCurvature THEN
    BEGIN
      HelpRadiusOfCurvature;
      RadiusOfCurvatureEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfConicConstant THEN
    BEGIN
      HelpConicConstant;
      ConicConstantEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfRefractiveIndex1 THEN
    BEGIN
      HelpIndexOfRefraction;
      RefractiveIndex1Edit.SetFocus
    END
  ELSE
  IF LastFocus = lfRefractiveIndex2 THEN
    BEGIN
      HelpIndexOfRefraction;
      RefractiveIndex2Edit.SetFocus
    END
  ELSE
  IF LastFocus = lfSurfaceReflectivity THEN
    BEGIN
      HelpSurfaceReflectivity;
      SurfaceReflectivityEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfScatteringAngle THEN
    BEGIN
      HelpScatteringAngle;
      ScatteringAngleEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfOutsideApertureDia THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      OuterClearApDiaEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfOutsideApertureWidthX THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      OutsideApertureXDimEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfOutsideApertureWidthY THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      OutsideApertureYDimEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfInsideApertureDia THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      InnerApertureDiameterEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfInsideApertureWidthX THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      InsideApertureXDimEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfInsideApertureWidthY THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      InsideApertureYDimEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfLensletArrayColumns THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('No help available');
      LensletArrayColumnsEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfLensletArrayRows THEN
    BEGIN
      CommandIOMemo.IOHistory.Lines.add ('No help available');
      LensletArrayRowsEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfApertureOffsetX THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      ApertureOffsetXEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfApertureOffsetY THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      ApertureOffsetYEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfRadialSectorCenterAz THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      RadialSectorCenterAzEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfRadialSectorAngularWidth THEN
    BEGIN
      HelpInsideAndOutsideApertures;
      RadialSectorAngularWidthEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfSurfaceVertexXPosition THEN
    BEGIN
      HelpSurfacePosition;
      VertexXCoordinateEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfSurfaceVertexYPosition THEN
    BEGIN
      HelpSurfacePosition;
      VertexYCoordinateEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfSurfaceVertexZPosition THEN
    BEGIN
      HelpSurfacePosition;
      VertexZCoordinateEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfSurfaceVertexYaw THEN
    BEGIN
      HelpSurfaceOrientation;
      VertexYawEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfSurfaceVertexPitch THEN
    BEGIN
      HelpSurfaceOrientation;
      VertexPitchEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfSurfaceVertexRoll THEN
    BEGIN
      HelpSurfaceOrientation;
      VertexRollEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfAsphericDeformationConstants THEN
    BEGIN
      HelpAsphericDeformationConstants;
      Order4DeformationConstantEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfCPCMaxEntraceAngle THEN
    BEGIN
      HelpCPCDesignParameters;
      MaxEntranceAngleInAirDegreesEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfCPCRefractiveIndex THEN
    BEGIN
      HelpCPCDesignParameters;
      CPCRefractiveIndexEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfCPCExitAngle THEN
    BEGIN
      HelpCPCDesignParameters;
      CPCExitAngleDegreesEdit.SetFocus
    END
  ELSE
  IF LastFocus = lfCPCExitApertureRadius THEN
    BEGIN
      HelpCPCDesignParameters;
      RadiusOfCPCExitApertureEdit.SetFocus
    END
  ELSE
    CommandIOMemo.IOHistory.Lines.add ('No help available')

end;

procedure TLensDataEntryForm.ValidateLensletArrayPitchXDim(Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfLensletArrayPitchX;

  IF Length (LensletArrayPitchXEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'lenslet array pitch.';
      LensDataEntryForm.LensletArrayPitchXEdit.Text :=
          FloatToStr (DefaultLensletArrayPitchX);
      ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX :=
          DefaultLensletArrayPitchX
    END
  ELSE
    BEGIN
      VAL (LensletArrayPitchXEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchX := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          LensletArrayPitchXEdit.SetFocus
        END
    END

end;

procedure TLensDataEntryForm.ValidateLensletArrayPitchYDim(
  Sender: TObject);

  VAR
      CODE           : INTEGER;

      RealNumber     : DOUBLE;

begin

  SurfaceDataValidationMessage.Clear;
  LastFocus := lfLensletArrayPitchY;

  IF Length (LensletArrayPitchYEdit.Text) = 0 THEN
    BEGIN
      SurfaceDataValidationMessage.Text := 'No input.  Restoring default ' +
          'lenslet array pitch.';
      LensDataEntryForm.LensletArrayPitchYEdit.Text :=
          FloatToStr (DefaultLensletArrayPitchY);
      ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY :=
          DefaultLensletArrayPitchY
    END
  ELSE
    BEGIN
      VAL (LensletArrayPitchYEdit.Text, RealNumber, CODE);
      IF CODE = 0 THEN
        ZBA_SURFACE [SurfaceOrdinal].LensletArrayPitchY := RealNumber
      ELSE
        BEGIN
          SurfaceDataValidationMessage.Text := 'Non-numeric value.  Please ' +
              're-enter.';
          LensletArrayPitchYEdit.SetFocus
        END
    END

end;

end.
