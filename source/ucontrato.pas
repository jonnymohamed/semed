unit ucontrato;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Ipfilebroker, IpHtml, Forms, Controls, Graphics,
  Dialogs, Buttons, ExtCtrls, LCLIntf, DbCtrls, StdCtrls, EditBtn, Printers,
  Grids, LCLType, Menus, ZDataset;

type

  { TfrmContrato }

  TfrmContrato = class(TForm)
    BtnCancelarContrato: TBitBtn;
    Btnadicionalocal: TBitBtn;
    BtnBuscaContrato: TBitBtn;
    BtnGerarcontrato: TBitBtn;
    btnlimparlocais: TBitBtn;
    BtnSair: TBitBtn;
    cboxtipo: TComboBox;
    DateEditfinal: TDateEdit;
    DateEditinicial: TDateEdit;
    DBEdtAnoseletivo: TDBEdit;
    DBEdtcpftest2: TDBEdit;
    DBEdtcpfteste1: TDBEdit;
    DBEdthorario: TDBEdit;
    DBEdtJornada: TDBEdit;
    DBEdttest2: TDBEdit;
    DBEdtteste1: TDBEdit;
    DBMemoobs: TDBMemo;
    DBMemovacancia: TDBMemo;
    edtcargo: TEdit;
    edtfuncionario: TEdit;
    edtcodigocontrato: TEdit;
    edtlocal: TEdit;
    gbContrato: TGroupBox;
    gbLocalTrabalho: TGroupBox;
    gbInformacoesAdicionais: TGroupBox;
    gbTestemunhas: TGroupBox;
    gbTestemunha1: TGroupBox;
    gbTestemunha2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    lblFuncionario: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblCargo: TLabel;
    lblLocalTrabalho: TLabel;
    MenuItem1: TMenuItem;
    Panel3: TPanel;
    Panelprincipal: TPanel;
    PanelBotoes: TPanel;
    popJornadaSemanal: TPopupMenu;
    rgHorarios: TRadioGroup;
    sbtbuscarcargo: TSpeedButton;
    sbtbuscarpessoa: TSpeedButton;
    sbtlocal: TSpeedButton;
    sbtJornadaSemanal: TSpeedButton;
    StringGrid1: TStringGrid;
    procedure BtnBuscaContratoClick(Sender: TObject);
    procedure BtnCancelarContratoClick(Sender: TObject);
    procedure DBEdtAnoseletivoKeyPress(Sender: TObject; var Key: char);
    procedure DBEdtcargoKeyPress(Sender: TObject; var Key: char);
    procedure DBEdtCodcontratoExit(Sender: TObject);
    procedure BtnadicionalocalClick(Sender: TObject);
    procedure BtnGerarcontratoClick(Sender: TObject);
    procedure btnlimparlocaisClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure DBEdtcpftest2Exit(Sender: TObject);
    procedure DBEdtcpftest2KeyPress(Sender: TObject; var Key: char);
    procedure DBEdtcpfteste1Exit(Sender: TObject);
    procedure DBEdtcpfteste1KeyPress(Sender: TObject; var Key: char);
    procedure DBEdthorarioKeyPress(Sender: TObject; var Key: char);
    procedure DBEdtJornadaKeyPress(Sender: TObject; var Key: char);
    procedure edtcargoEditingDone(Sender: TObject);
    procedure edtcargoExit(Sender: TObject);
    procedure edtcargoKeyPress(Sender: TObject; var Key: char);
    procedure edtcodigocontratoKeyPress(Sender: TObject; var Key: char);
    procedure edtfuncionarioEditingDone(Sender: TObject);
    procedure edtfuncionarioKeyPress(Sender: TObject; var Key: char);
    procedure edtlocalEditingDone(Sender: TObject);
    procedure edtlocalExit(Sender: TObject);
    procedure FormClose(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure rgHorariosClick(Sender: TObject);
    procedure sbtbuscarpessoaClick(Sender: TObject);
    procedure sbtbuscarcargoClick(Sender: TObject);
    procedure sbtJornadaSemanalClick(Sender: TObject);
    procedure sbtlocalClick(Sender: TObject);

  private
    { private declarations }
    function verificarCodigo(var edit1: TEdit; var labelDesc: TLabel; tabela, campoCodigo, campoNome: String): boolean;
  public
    { public declarations }
  end;

const
  local = 'c:\temp\';//local de salvamento do contrato

var
  frmContrato: TfrmContrato;

implementation

uses
  uPesquisaPessoas, ubuscacontrato, UUtilidades, uhtml , UCadastroLocalTrabalho,
  uCadastroCargos, udmcontratos, ufiltragem, dmMain;

var
  linhas: byte;
  horarios: array[1..3] of integer;
  numlocal : array[1..3] of integer;

{$R *.lfm}

{ TfrmContrato }

// INICIO - frmcontratos show ---------------------------------------------------
procedure TfrmContrato.FormShow(Sender: TObject);
var
  x:integer;
begin
  //cria dmcontratos
  Application.CreateForm(TDMcontratos, DMcontratos);

  CreateDir(local);//cria pasta temporaria para o contrato

  //inicializa variaveis para varios locais
  linhas := 1;

  for x := 1 to 3 do
  begin
    numlocal[x] := 0;
    horarios[x]:= 0;
  end;
  //--
end;

// PROCEDURE verificadora de Codigos (preenche também os labels com os nomes ao lado)
function TfrmContrato.verificarCodigo(var edit1: TEdit; var labelDesc: TLabel; tabela,
                                    campoCodigo, campoNome: String): boolean;
var
  query : TZQuery;
begin
  if Length(edit1.Text) <> 0 then
  begin
    try
      query := TZQuery.Create(self);
      query.Connection := DM1.SEMEDconnection;
      query.SQL.Clear;
      query.SQL.Add('SELECT '+campoNome+' FROM '+tabela+' WHERE '+campoCodigo+
                    ' = "'+ edit1.Text +'";');
      query.Open;
      if not (query.IsEmpty) then   // Se nao retornar nenhum valor
      begin
        edit1.Color := clDefault;
        labelDesc.Caption := query.FieldByName(campoNome).Value;
        result := true;
      end
      else
      begin
        edit1.Color := clRed;       // Se retornar valor (codigo é valido)
        edit1.SetFocus;
        labelDesc.Caption := 'Registro não encontrado!';
        result := false;
      end;
    finally
      query.Close;
      query.Free;
    end;
  end;
end;

// MENU lateral ----------------------------------------------------------------

//Botão Buscar Contratos ---
procedure TfrmContrato.BtnBuscaContratoClick(Sender: TObject);
begin
  //cria form de busca de contratos
  Application.CreateForm(Tfrmbuscacontrato, frmbuscacontrato);
  frmbuscacontrato.ShowModal;
  frmbuscacontrato.Free;
end;

//btngerarcontrato click ---
procedure TfrmContrato.BtnGerarcontratoClick(Sender: TObject);
var
  i : integer;
begin
if (Length(edtcargo.text) <> 0) and (Length(DBEdtJornada.text) <> 0) and
    (Length(DateEditfinal.text) <> 0) and (Length(DateEditinicial.text) <> 0) and
    (Length(DBMemovacancia.text) <> 0) and (Length(DBEdtAnoseletivo.text) <> 0) and
    (Length(cboxtipo.text) <> 0) and (Length(DBEdtteste1.text) <> 0) and
    (Length(DBEdttest2.text) <> 0) and (Length(DBEdtcpfteste1.text) <> 0) and
    (Length(DBEdtcpftest2.text) <> 0) and  (StringGrid1.Rows[1].Text <> '') then
begin
  if Application.MessageBox('Tem certeza que os campos estão corretos?','Finalizar', MB_OKCANCEL) = idOK then
  begin
    try
      //adiciona demais campos tabela contrato
      with udmcontratos.dmcontratos.zt_contratos do
      begin
        FieldByName('tipo_contratacao_contrato').value := cboxtipo.Text;
        FieldByName('codigo_contrato').Value  := edtcodigocontrato.text;
        FieldByName('codigo_pessoa').Value  := edtfuncionario.text;
        FieldByName('codigo_cargo').value := edtcargo.text;
        FieldByName('periodo_inicial_contrato').Value := DateEditinicial.Text;
        FieldByName('periodo_final_contrato').Value := DateEditfinal.Text;
        FieldByName('data_contrato').Value := DateToStr(date);
        FieldByName('salario_contrato').Value := DMcontratos.dscargos.DataSet.FieldByName('salario_hora_cargo').value;
      //
        Post; //posta

        DMcontratos.dscontratoslocais.DataSet.Active:=true;
        //salva locais do contrato
        for i := 1 to linhas -1 do
        begin
          with DMcontratos.dscontratoslocais.DataSet do
          begin
            insert;

            FieldByName('codigo_contrato').value := DMcontratos.dscontratos.DataSet.FieldByName('codigo_contrato').value;

            FieldByName('codigo_local_trabalho').value := numlocal[i];

            case horarios[i] of
            1: FieldByName('matutino').value := true;
            2: FieldByName('vespertino').value := true;
            3: FieldByName('noturno').value := true;
            end;

            post;
          end;
        end;
        //
      end;
    finally
      html.editahtml; //chama o preenchimento do html
    end;
  end;
end
else
  ShowMessage('Preencha todos os campos!');
end;

// Botão Cancelar Contrato -----------------------------------------------------

procedure TfrmContrato.BtnCancelarContratoClick(Sender: TObject);
var
  x: integer;
begin
  edtcodigocontrato.Text:='';
  edtcodigocontrato.Enabled := true;
  BtnCancelarContrato.Enabled:=false;
  edtcodigocontrato.SetFocus;

  edtfuncionario.Enabled:=false;
  sbtbuscarpessoa.Enabled:=false;
  edtfuncionario.Text:='';

  BtnBuscaContrato.Enabled:=true;
  BtnGerarcontrato.Enabled:=false;

  gbLocalTrabalho.Enabled := false;
  gbInformacoesAdicionais.Enabled := false;
  gbTestemunhas.Enabled := false;
  gbContrato.Enabled := false;

  edtcargo.Text:='';
  DateEditinicial.Text:='';
  DateEditfinal.Text:='';
  DBEdtJornada.Text:='';
  //Limpa grid ---
  linhas:=1;
  StringGrid1.Clean(0,1,1,3,[gznormal]);
  for x := 1 to 3 do
  begin
    numlocal[x] := 0;
    horarios[x]:= 0;
  end;
  //---

  edtlocal.Text:='';
  DBEdthorario.Text:='';

  DBMemoobs.Text:='';
  DBMemovacancia.Text:='';
  DBEdtAnoseletivo.Text:='';
  cboxtipo.Text:='';

  DBEdtteste1.Text:='';
  DBEdtcpfteste1.Text:='';
  DBEdttest2.Text:='';
  DBEdtcpftest2.Text:='';

  // ---
  DMcontratos.dsContratos.DataSet.Cancel;

  DMcontratos.zt_pessoas.Active:=false;
  DMcontratos.zt_contratos.Active:= false;
  DMcontratos.zt_cargos.Active:=false;
  DMcontratos.zt_cidades.Active:=false;
  DMcontratos.zt_contratos_cargos.Active:=false;
end;

//limpar locais da grid locais -------------------------------------------------
procedure TfrmContrato.btnlimparlocaisClick(Sender: TObject);
var
  x:integer;
begin
  linhas:=1;

  StringGrid1.Clean(0,1,1,3,[gznormal]);

  for x := 1 to 3 do
  begin
    numlocal[x] := 0;
    horarios[x]:= 0;
  end;
end;

//adicionar locais a grid locais -----------------------------------------------
procedure TfrmContrato.BtnadicionalocalClick(Sender: TObject);
begin
  if Length(edtlocal.Text) <> 0 then
  begin
    //adiociona mais locais de trabalho
    StringGrid1.Cells[0,linhas] := DMcontratos.dslocaltrabalho.DataSet.FieldByName('nome_local_trabalho').value;
    StringGrid1.Cells[1,linhas] := DBEdthorario.text;

    numlocal[linhas]:= DMcontratos.dslocaltrabalho.DataSet.FieldByName('codigo_local_trabalho').value;

    inc(linhas);
  end;
end;

//Rghorarios selection ---------------------------------------------------------
procedure TfrmContrato.rgHorariosClick(Sender: TObject);
begin
    case rgHorarios.ItemIndex of
    0:
    begin
      DBedtHorario.DataField:= 'horario_matutino_trabalho';
      horarios[linhas] := 1;
    end;
    1:
    begin
      DBedtHorario.DataField:= 'horario_vespertino_trabalho';
      horarios[linhas] := 2;
    end;
    2:
    begin
      DBedtHorario.DataField:= 'horario_noturno_trabalho';
      horarios[linhas] := 3;
    end;
  end;

end;

//sbtbuscarpessoa ---------------------------------------------------------------
procedure TfrmContrato.sbtbuscarpessoaClick(Sender: TObject);
begin
  //chama a pesquisa de pessoa
  Application.CreateForm(TfrmPesquisaPessoas, frmPesquisaPessoas);
  frmPesquisaPessoas.showmodal;
  frmPesquisaPessoas.free;

  //coloca codigo funcionario em seu respectivo edit
  edtfuncionario.text:= DMcontratos.dspessoa.DataSet.FieldByName('codigo_pessoa').value;

  //filtra dspessoa
  filtragem.filtrads('codigo_pessoa = '''  + edtfuncionario.text+'''', 'dspessoa');
end;

//sbtbuscarcargo ---------------------------------------------------------------
procedure TfrmContrato.sbtbuscarcargoClick(Sender: TObject);
begin
   //chama a pesquisa de cargo
  Application.CreateForm(TfrmCadastroCargos, frmCadastroCargos);
  frmCadastroCargos.SelecionarAtivo := true; // Habilita botão SELECIONAR
  frmCadastroCargos.showmodal;
  frmCadastroCargos.free;

  edtcargo.text := DMcontratos.dsContratos.DataSet.FieldByName('codigo_cargo').AsString;

  //filtra ds cargo
  filtragem.filtrads('codigo_cargo = ''' + edtcargo.text+'''', 'dscargos');

end;

//sbtbuscarlocal ---------------------------------------------------------------
procedure TfrmContrato.sbtlocalClick(Sender: TObject);
begin
  //chama a pesquisa de local
  DMcontratos.dslocaltrabalho.DataSet.Active:=true;

  Application.CreateForm(TfrmCadastroLocalTrabalho, frmCadastroLocalTrabalho);
  frmCadastroLocalTrabalho.SelecionarAtivo := true;
  frmCadastroLocalTrabalho.showmodal;
  frmCadastroLocalTrabalho.free;

  edtlocal.Text := DMcontratos.dslocaltrabalho.DataSet.FieldByName('codigo_local_trabalho').AsString;
end;

//sbtJornadaSemanal ------------------------------------------------------------
procedure TfrmContrato.sbtJornadaSemanalClick(Sender: TObject);
begin
  popJornadaSemanal.PopUp;
end;

//PREVISAO DE ERROS-------------------------------------------------------------

// Ao sair dos campos codigo de algo

procedure TfrmContrato.edtcargoExit(Sender: TObject);               // Cargos
begin
  verificarCodigo(edtcargo, lblCargo, 'tb_cargos', 'codigo_cargo', 'nome_cargo');
end;

procedure TfrmContrato.edtlocalExit(Sender: TObject);               // Locais de Trabalho
begin
  verificarCodigo(edtlocal, lblLocalTrabalho, 'tb_local_trabalho', 'codigo_local_trabalho', 'nome_local_trabalho');
end;

// Verificadores e marcaras
procedure TfrmContrato.DBEdtcpftest2Exit(Sender: TObject);  // CPF testemunha 2
begin
  utilidades.VerifCPF(DBEdtcpftest2);
end;

procedure TfrmContrato.DBEdtcpftest2KeyPress(Sender: TObject; var Key: char);
begin
  utilidades.MascCPF(DBEdtcpftest2, Key)
end;
                                                             // CPF testemunha 1
procedure TfrmContrato.DBEdtcpfteste1Exit(Sender: TObject);
begin
  Utilidades.VerifCPF(DBEdtcpfteste1);
end;

procedure TfrmContrato.DBEdtcpfteste1KeyPress(Sender: TObject; var Key: char);
begin
    utilidades.MascCPF(DBEdtcpfteste1, Key);
end;
                                                            // horario
procedure TfrmContrato.DBEdthorarioKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', #8{backspace}]) then
    Key := #0{nil};
end;

procedure TfrmContrato.DBEdtAnoseletivoKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', #8{backspace}]) then
    Key := #0{nil};
end;

procedure TfrmContrato.DBEdtcargoKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', #8{backspace}]) then
    Key := #0{nil};
end;

procedure TfrmContrato.DBEdtJornadaKeyPress(Sender: TObject; var Key: char);
begin
    if not (Key in ['0'..'9', #8{backspace}]) then
    Key := #0{nil};
end;

procedure TfrmContrato.edtcargoEditingDone(Sender: TObject);
begin
  //filtra ds cargo
  if Length(edtcargo.text) <> 0 then
    filtragem.filtrads('codigo_cargo = ''' + edtcargo.text+'''', 'dscargos');
end;

procedure TfrmContrato.edtcargoKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', #8{backspace}]) then
    Key := #0{nil};
end;

procedure TfrmContrato.edtcodigocontratoKeyPress(Sender: TObject; var Key: char
  );
begin
  if not (Key in ['0'..'9', #8{backspace}]) then
    Key := #0{nil};
end;

procedure TfrmContrato.edtfuncionarioEditingDone(Sender: TObject);
begin
  //libera campos apenas se funcionario nao contratado
  if (Length(edtfuncionario.text) <> 0) and
     (verificarCodigo(edtfuncionario, lblFuncionario, 'tb_pessoas', 'codigo_pessoa', 'nome_pessoa')) then
  begin
    if not DMcontratos.dsContratos.DataSet.Locate('codigo_pessoa', EdtFuncionario.Text,[]) then
    begin
      gbLocalTrabalho.Enabled := true;
      gbInformacoesAdicionais.Enabled := true;
      gbTestemunhas.Enabled := true;
      gbContrato.Enabled := true;

      BtnGerarcontrato.Enabled:=true;

      edtfuncionario.Enabled:=false;
      sbtbuscarpessoa.Enabled:=false;

      DMcontratos.dsContratos.DataSet.Insert;//coloca table em modo de inserçao

      //filtra dspessoa
      filtragem.filtrads('codigo_pessoa = '''+ edtfuncionario.text+'''','dspessoa');


      //ativa tabelas
      DMcontratos.zt_cargos.Active:=true;
      DMcontratos.zt_cidades.Active:=true;
      DMcontratos.zt_contratos_cargos.Active:=true;

      filtragem.filtrads('codigo_cidade = '''+DMcontratos.dspessoa.DataSet.FieldByName('codigo_cidade').AsString +'''', 'dscidades');

      edtcargo.SetFocus;
    end
    else
    begin
      gbLocalTrabalho.Enabled := false;
      gbInformacoesAdicionais.Enabled := false;
      gbTestemunhas.Enabled := false;
      gbContrato.Enabled := false;

      BtnGerarcontrato.Enabled:=false;

      edtfuncionario.Clear;
      ShowMessage('Funcionário número'+edtfuncionario.text+' já contratado!');
    end;
  end;
end;

procedure TfrmContrato.DBEdtCodcontratoExit(Sender: TObject);
begin
  //libera novo comtrato apenas se codigo contrato nao existir
  if Length(edtcodigocontrato.text) <> 0 then
  begin
    //buscar se contrato existe
    DMcontratos.zt_contratos.Active:= true;

    filtragem.filtrads('codigo_contrato = '''+edtcodigocontrato.text+'''', 'dscontratos');

    //liberar novo contrato
    if DMcontratos.dsContratos.DataSet.RecordCount = 0 then
    begin
      edtfuncionario.Enabled:=true;
      sbtbuscarpessoa.Enabled:=true;

      edtcodigocontrato.Enabled := false;
      BtnCancelarContrato.Enabled:=true;
      edtfuncionario.SetFocus;

      BtnBuscaContrato.Enabled:=false;

      DMcontratos.zt_pessoas.Active:=true;
    end
    else
    //não liberar novo contrato
    begin
      ShowMessage('Código '+edtcodigocontrato.text + ' já existente!');
      edtcodigocontrato.clear;
      DMcontratos.zt_contratos.Active:= false;
      DMcontratos.zt_pessoas.Active:= false;
    end;
  end;
end;

procedure TfrmContrato.edtfuncionarioKeyPress(Sender: TObject; var Key: char);
begin
  if not (Key in ['0'..'9', #8{backspace}]) then
    Key := #0{nil};
end;

procedure TfrmContrato.edtlocalEditingDone(Sender: TObject);
begin
  if Length(edtlocal.text) <> 0 then
    filtragem.filtrads('codigo_local_trabalho = '''+ edtlocal.text+'''','dslocaltrabalho');
end;

procedure TfrmContrato.FormClose(Sender: TObject);
begin
  DeleteDirectory('c:\temp\',false);  //deleta pasta temporaria do contrato

  DMcontratos.free;  //fecha datamodule de controtos
end;

// FIM - frmcontrato close ------------------------------------------------------
procedure TfrmContrato.BtnSairClick(Sender: TObject);
begin
  close;
end;

end.

