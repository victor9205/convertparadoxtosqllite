object frmMain: TfrmMain
  Left = 459
  Top = 278
  Caption = 'Conversor Paradox para SqlLite'
  ClientHeight = 584
  ClientWidth = 744
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    744
    584)
  PixelsPerInch = 96
  TextHeight = 13
  object gpbProgresso: TGroupBox
    Left = 8
    Top = 325
    Width = 725
    Height = 44
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Aguarde convertendo o Database '
    TabOrder = 4
    DesignSize = (
      725
      44)
    object prbProgresso: TProgressBar
      Left = 10
      Top = 18
      Width = 707
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 376
    Width = 725
    Height = 201
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' Log '
    TabOrder = 5
    DesignSize = (
      725
      201)
    object lsbLog: TListBox
      Left = 8
      Top = 16
      Width = 709
      Height = 176
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 7
    Top = 44
    Width = 725
    Height = 186
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Arquivos a serem convertidos  '
    TabOrder = 1
    DesignSize = (
      725
      186)
    object LstFilesConverter: TCheckListBox
      Left = 10
      Top = 16
      Width = 709
      Height = 161
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 0
    Width = 744
    Height = 41
    Align = alTop
    TabOrder = 0
    object btnSelecionarArquivos: TBitBtn
      Left = 8
      Top = 8
      Width = 137
      Height = 25
      Caption = ' &Selecionar Arquivos '
      Kind = bkAll
      NumGlyphs = 2
      TabOrder = 0
      OnClick = btnSelecionarArquivosClick
    end
    object btnConverter: TBitBtn
      Left = 319
      Top = 8
      Width = 106
      Height = 25
      Caption = ' &Converter '
      Kind = bkYes
      NumGlyphs = 2
      TabOrder = 2
      OnClick = btnConverterClick
    end
    object btnLimparLista: TBitBtn
      Left = 151
      Top = 8
      Width = 162
      Height = 25
      Caption = ' &Limpar Lista de Arquivos '
      Kind = bkYes
      NumGlyphs = 2
      TabOrder = 1
      OnClick = btnLimparListaClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 236
    Width = 725
    Height = 53
    Anchors = [akLeft, akTop, akRight]
    Caption = ' Local Destino '
    TabOrder = 2
    object edtLocalDestino: TEdit
      Left = 10
      Top = 20
      Width = 707
      Height = 21
      TabOrder = 0
      Text = 'BancoSqlLiteConvertida.db'
    end
  end
  object ckeFecharAoConcluir: TCheckBox
    Left = 8
    Top = 296
    Width = 153
    Height = 17
    Caption = ' &Fechar ao concluir'
    TabOrder = 3
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'DB'
    Filter = 'Arquivos Dados Paradox (*.db)|*.db'
    Options = [ofHideReadOnly, ofAllowMultiSelect, ofEnableSizing]
    Title = 'Selecione os arquivos a serem convertidos'
    Left = 71
    Top = 148
  end
end
