unit LADSGUIvsCommanddlgUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, OkCancl1;

type
  TGUIvsCommanddlg = class(TOKBottomDlg)
    HelpBtn: TButton;
    GUISelectButton: TRadioButton;
    KeyboardSelectButton: TRadioButton;
    procedure HelpBtnClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GUIvsCommanddlg: TGUIvsCommanddlg;

implementation

{$R *.DFM}

procedure TGUIvsCommanddlg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TGUIvsCommanddlg.FormActivate(Sender: TObject);
begin
  inherited;

  KeyboardSelectButton.Checked := TRUE
  
end;

end.
 
