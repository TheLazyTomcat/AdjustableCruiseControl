object fUpdateForm: TfUpdateForm
  Left = 611
  Top = 355
  BorderStyle = bsDialog
  Caption = 'Games data update'
  ClientHeight = 368
  ClientWidth = 648
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblIcons: TLabel
    Left = 8
    Top = 304
    Width = 30
    Height = 13
    Caption = 'Icons:'
  end
  object bvlVertSplit: TBevel
    Left = 488
    Top = 0
    Width = 9
    Height = 369
    Shape = bsLeftLine
  end
  object clbUpdateData: TCheckListBox
    Left = 8
    Top = 8
    Width = 473
    Height = 292
    OnClickCheck = clbUpdateDataClickCheck
    ItemHeight = 48
    Style = lbOwnerDrawFixed
    TabOrder = 0
    OnDrawItem = clbUpdateDataDrawItem
  end
  object btnLoadUpdateFile: TButton
    Left = 496
    Top = 8
    Width = 145
    Height = 25
    Caption = 'Load update file...'
    TabOrder = 2
    OnClick = btnLoadUpdateFileClick
  end
  object btnMakeUpdate: TButton
    Left = 496
    Top = 40
    Width = 145
    Height = 25
    Caption = 'Make update'
    TabOrder = 3
    OnClick = btnMakeUpdateClick
  end
  object meIcons: TMemo
    Left = 8
    Top = 320
    Width = 473
    Height = 41
    ReadOnly = True
    TabOrder = 1
  end
  object gbColorLegend: TGroupBox
    Left = 496
    Top = 240
    Width = 145
    Height = 121
    Caption = 'Colors'
    TabOrder = 4
    object lblLegTxt_CurrentVersion: TLabel
      Left = 32
      Top = 74
      Width = 104
      Height = 13
      Caption = 'Current entry version'
    end
    object lblLegTxt_NewEntry: TLabel
      Left = 32
      Top = 26
      Width = 50
      Height = 13
      Caption = 'New entry'
    end
    object shpLegCol_NewEntry: TShape
      Left = 8
      Top = 24
      Width = 17
      Height = 17
      Cursor = crHelp
      Hint = 'Entry is not yet listed between supported games'
      Brush.Color = clBlue
      ParentShowHint = False
      Pen.Color = clSilver
      Pen.Style = psClear
      ShowHint = True
    end
    object shpLegCol_NewVersion: TShape
      Left = 8
      Top = 48
      Width = 17
      Height = 17
      Cursor = crHelp
      Hint = 'Newer version of entry that is already between supported games'
      Brush.Color = clLime
      ParentShowHint = False
      Pen.Color = clSilver
      Pen.Style = psClear
      ShowHint = True
    end
    object lblLegTxt_NewVersion: TLabel
      Left = 32
      Top = 50
      Width = 88
      Height = 13
      Caption = 'New entry version'
    end
    object shpLegCol_OldVersion: TShape
      Left = 8
      Top = 96
      Width = 17
      Height = 17
      Cursor = crHelp
      Hint = 'Newer version of this entry is already between supported games'
      Brush.Color = clRed
      ParentShowHint = False
      Pen.Color = clSilver
      Pen.Style = psClear
      ShowHint = True
    end
    object lblLegTxt_OldVersion: TLabel
      Left = 32
      Top = 98
      Width = 93
      Height = 13
      Caption = 'Older entry version'
    end
    object shpLegCol_CurrentVersion: TShape
      Left = 8
      Top = 72
      Width = 17
      Height = 17
      Cursor = crHelp
      Hint = 
        'Entry with the same identifier and version is already listed bet' +
        'ween supported games'
      Brush.Color = clYellow
      ParentShowHint = False
      Pen.Color = clSilver
      Pen.Style = psClear
      ShowHint = True
    end
  end
  object diaLoadUpdate: TOpenDialog
    Filter = 
      'Supported files (*.ini,*.gdb,*.ugdb)|*.ini;*.gdb;*.ugdb|All file' +
      's|*.*'
    Title = 'Load update file'
    Left = 496
    Top = 72
  end
end
