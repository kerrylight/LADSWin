unit LADSCommandIOMemoUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TCommandIOMemo = class(TForm)
    IOHistory: TMemo;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CommandIOMemo: TCommandIOMemo;

implementation

{$R *.DFM}

end.
