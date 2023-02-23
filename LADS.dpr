program LADS;

uses
  Forms,
  LADSEnvironUnit in 'LADSEnvironUnit.pas',
  LADSCommandIOdlgUnit in 'LADSCommandIOdlgUnit.pas' {CommandIOdlg},
  LADSCommandIOMemoUnit in 'LADSCommandIOMemoUnit.pas' {CommandIOMemo},
  LADSHelpMessages in 'LADSHelpMessages.pas',
  LADSq5bUnit in 'LADSq5bUnit.pas',
  LADSq6Unit in 'LADSq6Unit.pas',
  LADSq5cUnit in 'LADSq5cUnit.pas',
  LADSInitUnit in 'LADSInitUnit.pas',
  LADSData in 'LADSData.pas',
  LADSPostProcUnit in 'LADSPostProcUnit.pas',
  LADSOptimizeUnit in 'LADSOptimizeUnit.pas',
  LADSq8Unit in 'LADSq8Unit.pas',
  LADSGlassCompUnit in 'LADSGlassCompUnit.pas',
  LADSGlassVar in 'LADSGlassVar.pas',
  Expertio in 'Expertio.pas',
  OKCANCL1 in 'OKCANCL1.PAS' {OKBottomDlg},
  LADSLensDataEntry in 'LADSLensDataEntry.pas' {LensDataEntryForm},
  HistogramUnit in 'HistogramUnit.pas' {HistogramForm},
  LADSq2Unit in 'LADSq2Unit.pas',
  LADSTraceUnit in 'LADSTraceUnit.pas',
  LADSArchiveUnit in 'LADSArchiveUnit.pas',
  TestSplashUnit in 'TestSplashUnit.pas' {Form2},
  LADSSplashScreenUnit in 'LADSSplashScreenUnit.pas' {LADSSplashScreenForm},
  LADSSurfaceOpsUnit in 'LADSSurfaceOpsUnit.pas' {SurfaceOpsDlg},
  LADSSurfUnit in 'LADSSurfUnit.pas',
  LADSUtilUnit in 'LADSUtilUnit.pas',
  LADSqCPCUnit in 'LADSqCPCUnit.pas',
  LADSRandomUnit in 'LADSRandomUnit.pas',
  LADSRayDataEntry in 'LADSRayDataEntry.pas' {RayDataEntryForm},
  LADSRayOpsUnit in 'LADSRayOpsUnit.pas' {RayOpsDlg},
  LADSRayUnit in 'LADSRayUnit.pas',
  LADSq4Unit in 'LADSq4Unit.pas',
  LADSq5aUnit in 'LADSq5aUnit.pas',
  LADSq7Unit in 'LADSq7Unit.pas',
  LADSq9Unit in 'LADSq9Unit.pas',
  LADSq1Unit in 'LADSq1Unit.pas',
  LADSq3Unit in 'LADSq3Unit.pas',
  LADSListRayOpsUnit in 'LADSListRayOpsUnit.pas' {ListRayOpsDlg},
  LADSListSurfOpsUnit in 'LADSListSurfOpsUnit.pas' {ListSurfaceOpsDlg},
  LADSListUnit in 'LADSListUnit.pas',
  LADSMainFormUnit in 'LADSMainFormUnit.pas' {LADSMainForm},
  LADSGUIvsCommanddlgUnit in 'LADSGUIvsCommanddlgUnit.pas' {GUIvsCommanddlg},
  LADSHelpUnit in 'LADSHelpUnit.pas' {AboutBox},
  LADSFileProcUnit in 'LADSFileProcUnit.pas',
  LADSGlassUnit in 'LADSGlassUnit.pas',
  LADSGraphics in 'LADSGraphics.pas' {GraphicsOutputForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TLADSMainForm, LADSMainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TSurfaceOpsDlg, SurfaceOpsDlg);
  Application.CreateForm(TRayOpsDlg, RayOpsDlg);
  Application.CreateForm(TListSurfaceOpsDlg, ListSurfaceOpsDlg);
  Application.CreateForm(TListRayOpsDlg, ListRayOpsDlg);
  Application.CreateForm(TCommandIOdlg, CommandIOdlg);
  Application.CreateForm(TCommandIOMemo, CommandIOMemo);
  Application.CreateForm(TLADSSplashScreenForm, LADSSplashScreenForm);
  Application.CreateForm(TGUIvsCommanddlg, GUIvsCommanddlg);
  Application.CreateForm(TGraphicsOutputForm, GraphicsOutputForm);
  Application.CreateForm(TLensDataEntryForm, LensDataEntryForm);
  Application.CreateForm(TRayDataEntryForm, RayDataEntryForm);
  Application.CreateForm(TLensDataEntryForm, LensDataEntryForm);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TLADSSplashScreenForm, LADSSplashScreenForm);
  Application.CreateForm(TRayDataEntryForm, RayDataEntryForm);
  Application.CreateForm(TLADSMainForm, LADSMainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TGraphicsOutputForm, GraphicsOutputForm);
  Application.CreateForm(TLensDataEntryForm, LensDataEntryForm);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TLADSSplashScreenForm, LADSSplashScreenForm);
  Application.CreateForm(TRayDataEntryForm, RayDataEntryForm);
  Application.CreateForm(TLADSMainForm, LADSMainForm);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TGraphicsOutputForm, GraphicsOutputForm);
  Application.CreateForm(TLensDataEntryForm, LensDataEntryForm);
  Application.CreateForm(TOKBottomDlg, OKBottomDlg);
  Application.CreateForm(TLensDataEntryForm, LensDataEntryForm);
  Application.CreateForm(THistogramForm, HistogramForm);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TLADSSplashScreenForm, LADSSplashScreenForm);
  Application.CreateForm(TSurfaceOpsDlg, SurfaceOpsDlg);
  Application.CreateForm(TRayDataEntryForm, RayDataEntryForm);
  Application.CreateForm(TRayOpsDlg, RayOpsDlg);
  Application.CreateForm(TListRayOpsDlg, ListRayOpsDlg);
  Application.CreateForm(TListSurfaceOpsDlg, ListSurfaceOpsDlg);
  Application.CreateForm(TLADSMainForm, LADSMainForm);
  Application.CreateForm(TGUIvsCommanddlg, GUIvsCommanddlg);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TGraphicsOutputForm, GraphicsOutputForm);
  Application.Run;
end.
