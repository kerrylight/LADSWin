unit LADSSplashScreenUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TLADSSplashScreenForm = class(TForm)
    SplashScreenPanel: TPanel;
    SplashScreenImage: TImage;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LADSSplashScreenForm: TLADSSplashScreenForm;

implementation

{$R *.DFM}

procedure TLADSSplashScreenForm.Timer1Timer(Sender: TObject);
begin

  Timer1.Enabled := FALSE;
  Close
  
end;

procedure TLADSSplashScreenForm.FormActivate(Sender: TObject);
begin

  Timer1.Enabled := TRUE
  
end;

end.
