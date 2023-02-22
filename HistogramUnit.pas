unit HistogramUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OleCtrls; (* Removed graphsv3 until HistogramUnit is working *)

type
  THistogramForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HistogramForm: THistogramForm;

implementation

{$R *.DFM}

end.
