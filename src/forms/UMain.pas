unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, DB, DBTables, ZAbstractConnection, ZConnection,
  ExtCtrls, ZAbstractTable, ZDataset, ZAbstractRODataset, ZAbstractDataset,
  Vcl.Buttons, Vcl.CheckLst;

type
  TfrmMain = class(TForm)
    gpbProgresso: TGroupBox;
    prbProgresso: TProgressBar;
    GroupBox2: TGroupBox;
    lsbLog: TListBox;
    GroupBox1: TGroupBox;
    pnlBotoes: TPanel;
    btnSelecionarArquivos: TBitBtn;
    btnConverter: TBitBtn;
    OpenDialog: TOpenDialog;
    btnLimparLista: TBitBtn;
    LstFilesConverter: TCheckListBox;
    GroupBox3: TGroupBox;
    edtLocalDestino: TEdit;
    ckeFecharAoConcluir: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnConverterClick(Sender: TObject);
    procedure btnSelecionarArquivosClick(Sender: TObject);
    procedure btnLimparListaClick(Sender: TObject);
  private
    FBancoOriginal: String;
    FParadoxDatabase: TDataBase;
    FParadoxTable: TTable;
    FSqlLiteDatabase: TZConnection;
    FSqlLiteQuery: TZQuery;
    FSqlLiteTable: TZTable;
    FBancoDestino: String;
    FFecharAoConcluir: Boolean;
    FListaArquivos: TStringList;
    function GetBancoDestino: String;
    procedure ConfigureComponentes;
    procedure CriarSqlLiteDataBase;
    procedure MigrarDados;
    function GetNomeTabela: String;
    procedure RemoverArquivo(sFileName: String);
    procedure RegistraLog(sMensagemLog: String);
    procedure AtualizaProgresso(sMensagem: String; Posicao, Fim: Integer);
    procedure SetBancoDestino(const Value: String);
    { Private declarations }
  public
    { Public declarations }
  published
    property BancoOriginal: String read FBancoOriginal write FBancoOriginal;
    property BancoDestino: String read GetBancoDestino write SetBancoDestino;
    property NomeTabela: String read GetNomeTabela;
    property FecharAoConcluir: Boolean read FFecharAoConcluir write FFecharAoConcluir;
    property ListaArquivos: TStringList read FListaArquivos;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

{ TForm1 }

uses StrUtils;

function TfrmMain.GetBancoDestino: String;
begin
  Result := FBancoDestino;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FListaArquivos := TStringList.Create;

  if ParamCount > 2 then
   begin
    if FileExists(ParamStr(1)) then
     begin
      FListaArquivos.LoadFromFile(ParamStr(1));

      for i := 0 to FListaArquivos.Count-1 do
       begin
        LstFilesConverter.Items.Add(FListaArquivos[i]);
        LstFilesConverter.Checked[LstFilesConverter.Items.Count-1] := True;
       end;
     end;

    Self.BancoDestino  := ParamStr(2);

    if (Self.BancoDestino <> '') then
     edtLocalDestino.Text := Self.BancoDestino
    else
     edtLocalDestino.Text := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName)) + 'BancoSqlLiteConvertida.db';

    Self.FecharAoConcluir := (LowerCase(ParamStr(3)) = 'sim') or (LowerCase(ParamStr(3)) = 'true');
    ckeFecharAoConcluir.Checked := Self.FecharAoConcluir;
   end;

  FParadoxDatabase := TDataBase.Create(Self);
  FParadoxTable    := TTable.Create(Self);

  FSqlLiteDatabase := TZConnection.Create(Self);
  FSqlLiteQuery    := TZQuery.Create(Self);
  FSqlLiteTable    := TZTable.Create(Self);
end;

procedure TfrmMain.RemoverArquivo(sFileName: String);
begin
  if FileExists(sFileName) then
   DeleteFile(sFileName);
end;

procedure TfrmMain.RegistraLog(sMensagemLog: String);
begin
  lsbLog.Items.Append(Format('%s - %s', [FormatDateTime('dd hh:mm:ss', Now), sMensagemLog]));
  Application.ProcessMessages;
end;

procedure TfrmMain.btnConverterClick(Sender: TObject);
var
  i: Integer;
begin
  prbProgresso.Position := 0;

  Self.BancoDestino := edtLocalDestino.Text;

  Self.FecharAoConcluir := ckeFecharAoConcluir.Checked;

  for i := 0 to LstFilesConverter.Items.Count-1 do
   begin
    if (LstFilesConverter.Checked[i]) then
     begin
      AtualizaProgresso(ExtractFileName(Trim(LstFilesConverter.Items[i])), i+1, LstFilesConverter.Items.Count);

      Self.BancoOriginal := LstFilesConverter.Items[i];
      ConfigureComponentes;

      Self.CriarSqlLiteDataBase;
      Self.MigrarDados;
      Application.ProcessMessages;
     end;
   end;

  ShowMessage('Conversão Concluída!');

  FSqlLiteTable.Close;
  if Self.FecharAoConcluir then
   Close;
end;

procedure TfrmMain.btnLimparListaClick(Sender: TObject);
begin
  LstFilesConverter.Items.Clear;
end;

procedure TfrmMain.btnSelecionarArquivosClick(Sender: TObject);
var
  i: Integer;
begin
  if OpenDialog.Execute then
   begin
    for i := 0 to OpenDialog.Files.Count-1 do
     begin
      LstFilesConverter.Items.Add(OpenDialog.Files[i]);
      LstFilesConverter.Checked[LstFilesConverter.Items.Count-1] := True;
     end;
   end;
end;

procedure TfrmMain.ConfigureComponentes;
{Configurando Conexão Paradox}
begin
  try
   FParadoxTable.Close;
   FParadoxDatabase.Connected := False;
   RegistraLog('Iniciando a configuração do Paradox');
   FParadoxDatabase.Params.Add(Format('PATH=%s', [IncludeTrailingPathDelimiter(ExtractFileDir(Self.BancoOriginal))]));
   FParadoxDatabase.Params.Add('PARADOX');
   FParadoxDatabase.Params.Add('FALSE');
   FParadoxDatabase.DatabaseName := IncludeTrailingPathDelimiter(ExtractFileDir(Self.BancoOriginal));
   FParadoxDatabase.Connected    := True;
   RegistraLog('Iniciando conexão ao BDE');
   FParadoxTable.DatabaseName    := FParadoxDatabase.DatabaseName;
   FParadoxTable.SessionName     := 'Default';
   FParadoxTable.TableName       := ExtractFileName(Self.BancoOriginal);
   FParadoxTable.Open;
   RegistraLog(Format('Abrindo a tabela do BDE - %s', [FParadoxDatabase.DatabaseName]));

 {Configurando Conexão SqLite}
   if not FSqlLiteDatabase.Connected then
    begin
     RegistraLog('Iniciando Conexão ao Sql Lite');
     FSqlLiteDatabase.Protocol        := 'sqlite-3';
     FSqlLiteDatabase.HostName        := 'localhost';
     FSqlLiteDatabase.LibraryLocation := Format('%ssqlite3.dll', [IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName))]);
     FSqlLiteDatabase.ClientCodePage  := 'WIN-1252';
     FSqlLiteDatabase.Database        := Self.BancoDestino;
     FSqlLiteDatabase.Connect;
     RegistraLog(Format('Abrindo o banco de dados SqlLite - %s', [FSqlLiteDatabase.Database]));

     FSqlLiteQuery.Connection := FSqlLiteDatabase;
     FSqlLiteTable.Connection := FSqlLiteDatabase;
    end;
  except
   On E: Exception do
    begin
     RegistraLog(Format('Falha ao abrir a tabela %s', [ExtractFileName(Self.BancoOriginal)]));
    end;
  end;
end;

procedure TfrmMain.CriarSqlLiteDataBase;
var
  i: Integer;
  sTipoCampo, sCampos: String;
  stlFields: TStringList;
begin
  stlFields := TStringList.Create;
  sCampos   := '';

  try
   if not FParadoxTable.Active then
    Exit;

   try
    RegistraLog(Format('Criando tabela no banco - %s', [Self.NomeTabela]));
    for i := 0 to FParadoxTable.Fields.Count-1 do
    begin
     sTipoCampo := 'Varchar(255)';
 {    case FParadoxTable.Fields[i].DataType of
     ftLargeint, ftAutoInc, ftSmallint, ftInteger, ftWord{ ftBoolean}//: sTipoCampo := 'Integer';
 {     ftFloat, ftCurrency, ftBCD: sTipoCampo := 'Double(15,6)';}
     {ftDate, ftTime, ftDateTime: sTipoCampo := 'DateTime';}
      //else sTipoCampo := 'Varchar(255)';
    // end;  }

     stlFields.Add(Format('%s %s', [FParadoxTable.Fields[i].FieldName, sTipoCampo]));
     RegistraLog(Format('Adicionando novo campo no banco - %s', [FParadoxTable.Fields[i].FieldName]));
    end;

    FSqlLiteQuery.SQL.Clear;

    for i := 0 to stlFields.Count-1 do
     begin
      sCampos := sCampos + stlFields[i];

      if (i < stlFields.Count-1) then
       sCampos := sCampos + ', ';
     end;

    FSqlLiteQuery.SQL.Add(Format('CREATE TABLE %s(%s);', [Self.NomeTabela, sCampos]));
    FSqlLiteQuery.ExecSQL;

    FSqlLiteTable.Close;
    FSqlLiteTable.TableName := Self.NomeTabela;
    FSqlLiteTable.Open;
   except
    On E: Exception do
     begin
      RegistraLog(Format('Falha ao criar a tabela %s . Mensagem de erro: %s . Script Sql: %s', [Self.NomeTabela, E.Message, FSqlLiteQuery.SQL.Text]));
     end;
   end;
  finally
   stlFields.Free;
  end;
end;

procedure TfrmMain.MigrarDados;
var
  i, iQtd: Integer;
begin
  try
   if not FParadoxTable.Active then
    Exit;

   try
    RegistraLog('Iniciando a Migração dos dados do Paradox para o SqlLite');
    RegistraLog(Format('Total de Registros a serem migrados - %d', [FParadoxTable.RecordCount]));
    iQtd := 0;
    FParadoxTable.First;
    while not FParadoxTable.Eof do
     begin
      Inc(iQtd);
      FSqlLiteTable.Append;

      for i := 0 to FParadoxTable.Fields.Count-1 do
      begin
       FSqlLiteTable.FieldByName(FParadoxTable.Fields[i].FieldName).Value := FParadoxTable.Fields[i].Value;
      end;

      FSqlLiteTable.Post;
      FParadoxTable.Next;
     end;

    RegistraLog(Format('Total de Registros a migrados - %d', [iQtd]));
   except
    On E: Exception do
     begin
      RegistraLog(Format('Falha ao migrar os dados da tabela %s . Mensagem de erro: %s .', [Self.NomeTabela, E.Message]));
     end;
   end;
  finally
   FParadoxTable.Close;
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FParadoxDatabase.Connected := False;
  FSqlLiteDatabase.Connected := False;

  if Assigned(FParadoxDatabase) then FParadoxDatabase.Free;
  if Assigned(FParadoxTable) then FParadoxTable.Free;

  if Assigned(FSqlLiteDatabase) then FSqlLiteDatabase.Free;
  if Assigned(FSqlLiteQuery) then FSqlLiteQuery.Free;
  if Assigned(FSqlLiteTable) then FSqlLiteTable.Free;
  if Assigned(FListaArquivos) then FListaArquivos.Free;
end;

function TfrmMain.GetNomeTabela: String;
begin
  Result := StringReplace(lowercase(ExtractFileName(Self.BancoOriginal)), '.db', '', []);
end;

procedure TfrmMain.AtualizaProgresso(sMensagem: String; Posicao, Fim: Integer);
begin
  gpbProgresso.Caption  := Format(' Aguarde convertendo o Database - %s', [sMensagem]);
  prbProgresso.Position := Posicao;
  prbProgresso.Max      := Fim;
  Application.ProcessMessages;
end;

procedure TfrmMain.SetBancoDestino(const Value: String);
begin
  RemoverArquivo(Value);

  FBancoDestino := Value;
end;

end.
