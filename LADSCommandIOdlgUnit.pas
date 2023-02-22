unit LADSCommandIOdlgUnit;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls;

type
  TCommandIOdlg = class(TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    CommandIOText: TEdit;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CommandIOdlg: TCommandIOdlg;

procedure ReadInteractiveResponse;

implementation

uses ExpertIO;

{$R *.DFM}

procedure ReadInteractiveResponse;
begin

  CommandIOdlg.ShowModal;
  CommandIOdlg.Caption := '';

end;

procedure TCommandIOdlg.OKBtnClick(Sender: TObject);
begin

  S01BB_INPUT_AREA := CommandIOdlg.CommandIOText.Text;
  CommandIOText.Clear;
  CommandIOText.SetFocus

end;

end.
