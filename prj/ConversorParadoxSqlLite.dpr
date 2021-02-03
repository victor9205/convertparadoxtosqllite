program ConversorParadoxSqlLite;

uses
  Forms,
  UMain in '..\Src\forms\UMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
