object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Form1'
  ClientHeight = 348
  ClientWidth = 624
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object Memo1: TMemo
    Left = 8
    Top = 95
    Width = 608
    Height = 226
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    TabOrder = 0
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 16
    Width = 608
    Height = 73
    ActivePage = TabSheet1
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Text'
      object cbLineBreak: TComboBox
        Left = 103
        Top = 11
        Width = 129
        Height = 23
        ItemIndex = 0
        TabOrder = 0
        Text = 'UNIX[LF]'
        Items.Strings = (
          'UNIX[LF]'
          'Windows[CR&LF]'
          'Mac(CR)')
      end
      object cbStringType: TComboBox
        Left = 7
        Top = 11
        Width = 90
        Height = 23
        ItemIndex = 0
        TabOrder = 1
        Text = 'AnsiString'
        Items.Strings = (
          'AnsiString'
          'WideString'
          'UTF8')
      end
      object btnOpenEdit: TButton
        Left = 238
        Top = 11
        Width = 97
        Height = 25
        Caption = 'Open text edit'
        TabOrder = 2
        OnClick = btnOpenEditClick
      end
      object btnLoadText: TButton
        Left = 341
        Top = 11
        Width = 97
        Height = 25
        Caption = 'Load from file...'
        TabOrder = 3
        OnClick = btnLoadTextClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'File'
      ImageIndex = 1
      object JvFilenameEdit1: TJvFilenameEdit
        Left = 3
        Top = 11
        Width = 594
        Height = 23
        TabOrder = 0
        Text = 'JvFilenameEdit1'
      end
    end
  end
  object Panel1: TPanel
    Left = 329
    Top = 8
    Width = 287
    Height = 28
    BevelEdges = []
    BevelOuter = bvNone
    Caption = 'Panel1'
    ShowCaption = False
    TabOrder = 2
    object Label1: TLabel
      Left = 0
      Top = 1
      Width = 35
      Height = 21
      Caption = 'Runs'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object Edit1: TEdit
      Left = 41
      Top = 1
      Width = 81
      Height = 25
      Alignment = taRightJustify
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = '1'
    end
    object UpDown1: TUpDown
      Left = 122
      Top = 1
      Width = 16
      Height = 25
      Associate = Edit1
      Max = 10000
      Position = 1
      TabOrder = 1
    end
    object btnCalculation: TButton
      Left = 144
      Top = 2
      Width = 80
      Height = 25
      Caption = 'Calculation'
      TabOrder = 2
      OnClick = btnCalculationClick
    end
    object btnReset: TButton
      Left = 230
      Top = 2
      Width = 51
      Height = 25
      Caption = 'Reset'
      TabOrder = 3
      OnClick = btnResetClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 329
    Width = 624
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitLeft = 392
    ExplicitTop = 360
    ExplicitWidth = 0
  end
  object JvThread1: TJvThread
    Exclusive = True
    MaxCount = 0
    RunOnCreate = True
    FreeOnTerminate = True
    OnBegin = JvThread1Begin
    OnExecute = JvThread1Execute
    OnFinishAll = JvThread1FinishAll
    Left = 24
    Top = 112
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Text file types'
        FileMask = '*.txt;*.ini;*.log;'
      end
      item
        DisplayName = 'All file'
        FileMask = '*.*'
      end>
    FileTypeIndex = 0
    Options = []
    Left = 464
    Top = 48
  end
end
