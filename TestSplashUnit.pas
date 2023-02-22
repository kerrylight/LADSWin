unit TestSplashUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls;

type
  TForm2 = class(TForm)
    IntroLogoImage: TImage;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := FALSE;
  Close
end;

procedure TForm2.FormActivate(Sender: TObject);
begin

  Timer1.Enabled := TRUE

end;

end.
