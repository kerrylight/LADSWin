unit LADSGraphics;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TGraphicsOutputForm = class(TForm)
    procedure FormPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  GraphicsOutputForm: TGraphicsOutputForm;

implementation

uses Expertio,
     LADSData;

{$R *.DFM}

procedure TGraphicsOutputForm.FormPaint(Sender: TObject);
begin

  GraphicsOutputForm.Canvas.Draw (0, 0, LADSBitmap)

end;

procedure TGraphicsOutputForm.FormKeyPress(Sender: TObject; var Key: Char);
begin

  KeyboardActivityDetected := TRUE

end;

procedure TGraphicsOutputForm.FormClick(Sender: TObject);
begin

  KeyboardActivityDetected := TRUE
  
end;

end.
