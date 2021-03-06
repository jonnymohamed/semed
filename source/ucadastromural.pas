unit UCadastroMural;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, Forms, Controls, Graphics, Dialogs, DbCtrls,
  StdCtrls, ExtCtrls, LCLType, dateutils;

type

  { TfrmCadastroMural }

  TfrmCadastroMural = class(TForm)
    DBMemo1: TDBMemo;
    dsMural: TDatasource;
    BtnSalvar: TImage;
    BtnCancelar: TImage;
    Label1: TLabel;
    labelRestantes: TLabel;
    procedure BtnCancelarClick(Sender: TObject);
    procedure BtnSalvarClick(Sender: TObject);
    procedure DBMemo1Change(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LimparRegistrosAntigos;
    procedure AtualizarMural;
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmCadastroMural: TfrmCadastroMural;
  UltimoRegistro: integer;

implementation

uses
  Umain;

{$R *.lfm}

{ TfrmCadastroMural }

// INICIO ----------------------------------------------------------------------

procedure TfrmCadastroMural.FormShow(Sender: TObject);
begin
  dsMural.DataSet.Refresh;
  dsMural.DataSet.Last;                  // Salva codigo do utimo registro
  UltimoRegistro := dsMural.DataSet.FieldByName('codigo_mural').AsInteger;

  dsMural.DataSet.Insert;
end;

// UTILIDADES ------------------------------------------------------------------

procedure TfrmCadastroMural.AtualizarMural;     // Atualiza Mural
begin
  LimparRegistrosAntigos;  // Apaga registros anteriores a -14 dias

  with FrmMain do
  begin
    dsMural.DataSet.Refresh;
    dsMural.DataSet.Last;

    memoMural.Lines.Clear;        // Limpa MEMO

    while not (dsMural.DataSet.BOF) do  //Enquanto nao for fim dos registros
    begin
      memoMural.Lines.Add('* ' + dsMural.DataSet.FieldByName('data_mural').Value +   // Escreve data e nome
                          ', por ' + dsMural.DataSet.FieldByName('usuario_mural').Value + ':');
      memoMural.Lines.Add(dsMural.DataSet.FieldByName('conteudo_mural').Value);  // Escreve conteudo
      memoMural.Lines.Add('');                                                   // Pula linha

      if not (dsMural.DataSet.BOF) then   // Se nao for ultimo registro, passa para proximo
        dsMural.DataSet.Prior;
    end;
    memoMural.Lines.Add('----- INICIO DOS REGISTROS -----');
    memoMural.SelStart := 0;  // Posiciona cursos na primeira linha para scroll ficar no inicio
  end;
end;

procedure TfrmCadastroMural.LimparRegistrosAntigos;     // Apaga registros anteriores a -14 dias
var
  dataRegistro, data: string;
  tamanhoData: integer;
begin
  FrmMain.dsMural.DataSet.First;
  while not (FrmMain.dsMural.DataSet.EOF) do  //Enquanto nao for fim dos registros
  begin
    dataRegistro := FrmMain.dsMural.DataSet.FieldByName('data_mural').Value;

    tamanhoData := 8; // Tamanho da data para copiar
    if dataRegistro[3] = '/' then    // Caso o dia possua 2 carac.
    begin
      inc(tamanhoData);
      if dataRegistro[6] = '/' then  // Caso o dia e o mes possuam 2 carac.
        inc(tamanhoData);
    end
    else if dataregistro[5] = '/' then  // Caso o mes possua 2 carac.
      inc(tamanhoData);

    data := Copy(dataRegistro, 1, tamanhoData); // Copia apenas data para variavel

    if (StrToDate(data) < IncDay(Date, -14)) then // verifica se data é mais antiga que 14 dias
    begin
      FrmMain.dsMural.DataSet.Delete; // Apaga registro
    end;

    if not (FrmMain.dsMural.DataSet.EOF) then   // Se nao for ultimo registro, passa para proximo
      FrmMain.dsMural.DataSet.Next;
  end;
end;

procedure TfrmCadastroMural.DBMemo1Change(Sender: TObject); // Atualiza marcador de
begin                                                       // caracteres restantes
  labelRestantes.Caption := 'Restantes: ' + IntToStr(200 - Length(DBMemo1.Text));
end;

// BOTOES ----------------------------------------------------------------------

procedure TfrmCadastroMural.BtnCancelarClick(Sender: TObject);  // Cancelar
begin
  Self.Close;
end;

procedure TfrmCadastroMural.BtnSalvarClick(Sender: TObject);    // Salvar
begin
  if (DBMemo1.Text = '') then  // Verifica se campos estão preenchidos
    ShowMessage('Todos os campos são obrigatorios!')
  else
  begin
    if Application.MessageBox('O recado não poderá ser alterado/apagado! Deseja continuar?','Inserir recado', MB_YESNO) = idYES then
    begin
      dsMural.DataSet.FieldByName('usuario_mural').Value := FrmMain.StatusBar.Panels[3].Text;
      dsMural.DataSet.FieldByName('codigo_mural').Value := UltimoRegistro + 1;
      dsMural.DataSet.FieldByName('data_mural').Value := DateToStr(Date) + ' ' + TimeToStr(Time); //Insere data e hora
      dsMural.DataSet.Post;   // Salva
                                                             // Exibe mensagem de aviso
      ShowMessage('Recado salvo com sucesso! O mesmo será automaticamente apagado após 14 dias.');

      AtualizarMural; // Atualiza o MEMO
      self.Close;  // Fecha o form
    end;
  end;
end;

// FIM -------------------------------------------------------------------------

procedure TfrmCadastroMural.FormClose(Sender: TObject);
begin
  dsMural.DataSet.Cancel;
end;

procedure TfrmCadastroMural.FormCreate(Sender: TObject);
begin

end;

end.

