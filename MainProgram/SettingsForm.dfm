object fSettingsForm: TfSettingsForm
  Left = 743
  Top = 122
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 536
  ClientWidth = 520
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object bvlVertSplit: TBevel
    Left = 384
    Top = 0
    Width = 9
    Height = 537
    Shape = bsLeftLine
  end
  object gbGeneral: TGroupBox
    Left = 8
    Top = 8
    Width = 369
    Height = 81
    Caption = 'General settings'
    TabOrder = 0
    object cbShowSplash: TCheckBox
      Left = 16
      Top = 24
      Width = 121
      Height = 17
      Caption = 'Show splash screen'
      TabOrder = 0
    end
    object cbMinimizeToTray: TCheckBox
      Left = 16
      Top = 48
      Width = 161
      Height = 17
      Caption = 'Minimize into notification area'
      TabOrder = 2
      OnClick = cbMinimizeToTrayClick
    end
    object cbCloseOnGameEnd: TCheckBox
      Left = 192
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Close on game end'
      TabOrder = 1
    end
    object cbStartMinimized: TCheckBox
      Left = 192
      Top = 48
      Width = 161
      Height = 17
      Caption = 'Start the program minimized'
      TabOrder = 3
    end
  end
  object gbTimers: TGroupBox
    Left = 8
    Top = 184
    Width = 169
    Height = 89
    Caption = 'Timers'
    TabOrder = 2
    object lblProcessScanTimer: TLabel
      Left = 13
      Top = 27
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = 'PSI [ms]:'
    end
    object lblModuleLoadTimer: TLabel
      Left = 10
      Top = 59
      Width = 47
      Height = 13
      Alignment = taRightJustify
      Caption = 'MLT [ms]:'
    end
    object imgHint_PSI: TImage
      Left = 144
      Top = 26
      Width = 16
      Height = 16
      Cursor = crHelp
      Hint = 'Processes scan interval'
      AutoSize = True
      ParentShowHint = False
      Picture.Data = {
        0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000001000
        00001008060000001FF3FF610000000473424954080808087C08648800000009
        704859730000015900000159010D28C8050000001974455874536F6674776172
        65007777772E696E6B73636170652E6F72679BEE3C1A00000178494441547801
        9D533B6EC240141C2310E2067C0A44E33A1212051C0029A241147C2E01A1A489
        2B3A48B844808A02C40D906822A54E8FCD0D528070E6EDDA0E7640B162CDEC7B
        6FEC1D7B779F0DD775717D4DA73059F7C8B24706BC7310BE0D87F8641EC0F00D
        38D1A0DA27C76486BC852F8A23724623F56665E04DDEF0C623A9904C02CDA64A
        B15A01E7B3CEBD71CBD81013DF6040E1850C90CF039D8E2E170BC0B6757E353E
        D1E0D5984C5C93E20719FA6C830BAAD5A812BB1D10D92AAA90E53C888105E099
        FC0F2C31587366830C904E03F53A502A6969B9048E479D47C68D18D814736408
        C522D06A69693E071C47E791D1B96B90A365B7AB1FFFCB60CDC7424B608D9806
        6A09166E6C624C03B589260D7E1D630C037D8CD2CAECC4014D428D542800ED36
        55424EE1706012866E24CFC0E0BDA0951309A05A052A15AAC47E0F082F17161A
        5B869F5666017E8598F4998F532964B2596657903E389D54F78D28CFD8C62E23
        D4BF20894F1AC99EF458973D32DCFF9DBF01176C933DA389BD0E000000004945
        4E44AE426082}
      ShowHint = True
      OnClick = imgHint_PSIClick
    end
    object imgHint_MLT: TImage
      Left = 144
      Top = 58
      Width = 16
      Height = 16
      Cursor = crHelp
      Hint = 'Modules load timeout'
      AutoSize = True
      ParentShowHint = False
      Picture.Data = {
        0A54504E474F626A65637489504E470D0A1A0A0000000D494844520000001000
        00001008060000001FF3FF610000000473424954080808087C08648800000009
        704859730000015900000159010D28C8050000001974455874536F6674776172
        65007777772E696E6B73636170652E6F72679BEE3C1A00000178494441547801
        9D533B6EC240141C2310E2067C0A44E33A1212051C0029A241147C2E01A1A489
        2B3A48B844808A02C40D906822A54E8FCD0D528070E6EDDA0E7640B162CDEC7B
        6FEC1D7B779F0DD775717D4DA73059F7C8B24706BC7310BE0D87F8641EC0F00D
        38D1A0DA27C76486BC852F8A23724623F56665E04DDEF0C623A9904C02CDA64A
        B15A01E7B3CEBD71CBD81013DF6040E1850C90CF039D8E2E170BC0B6757E353E
        D1E0D5984C5C93E20719FA6C830BAAD5A812BB1D10D92AAA90E53C888105E099
        FC0F2C31587366830C904E03F53A502A6969B9048E479D47C68D18D814736408
        C522D06A69693E071C47E791D1B96B90A365B7AB1FFFCB60CDC7424B608D9806
        6A09166E6C624C03B589260D7E1D630C037D8CD2CAECC4014D428D542800ED36
        55424EE1706012866E24CFC0E0BDA0951309A05A052A15AAC47E0F082F17161A
        5B869F5666017E8598F4998F532964B2596657903E389D54F78D28CFD8C62E23
        D4BF20894F1AC99EF458973D32DCFF9DBF01176C933DA389BD0E000000004945
        4E44AE426082}
      ShowHint = True
      OnClick = imgHint_MLTClick
    end
    object seProcessScanTimer: TSpinEdit
      Left = 64
      Top = 24
      Width = 73
      Height = 22
      MaxValue = 10000
      MinValue = 100
      TabOrder = 0
      Value = 100
    end
    object seModuleLoadTimer: TSpinEdit
      Left = 64
      Top = 56
      Width = 73
      Height = 22
      MaxValue = 30000
      MinValue = 1000
      TabOrder = 1
      Value = 1000
    end
  end
  object gbBindings: TGroupBox
    Left = 8
    Top = 280
    Width = 369
    Height = 249
    Caption = 'Key bindings'
    TabOrder = 4
    object lblBindingHint: TLabel
      Left = 8
      Top = 229
      Width = 351
      Height = 13
      Caption = 
        'Double-click on item in the table to select a new key binding fo' +
        'r that item.'
    end
    object sgBindings: TStringGrid
      Left = 8
      Top = 16
      Width = 353
      Height = 207
      ColCount = 3
      DefaultRowHeight = 16
      FixedColor = clGray
      FixedCols = 0
      RowCount = 2
      Options = [goVertLine, goHorzLine, goRowSelect, goThumbTracking]
      ScrollBars = ssVertical
      TabOrder = 0
      OnDblClick = sgBindingsDblClick
      OnDrawCell = sgBindingsDrawCell
    end
  end
  object gbGamesData: TGroupBox
    Left = 184
    Top = 184
    Width = 193
    Height = 89
    Caption = 'Games data (supported games)'
    TabOrder = 3
    object btnSupportedGames: TButton
      Left = 8
      Top = 24
      Width = 177
      Height = 25
      Caption = 'List of supported games...'
      TabOrder = 0
      OnClick = btnSupportedGamesClick
    end
    object btnUpdateGamesData: TButton
      Left = 8
      Top = 56
      Width = 177
      Height = 25
      Caption = 'Update games data...'
      TabOrder = 1
      OnClick = btnUpdateGamesDataClick
    end
  end
  object btnAccept: TButton
    Left = 392
    Top = 8
    Width = 121
    Height = 25
    Caption = 'Accept'
    TabOrder = 5
    OnClick = btnAcceptClick
  end
  object btnApply: TButton
    Left = 392
    Top = 40
    Width = 121
    Height = 25
    Caption = 'Apply'
    TabOrder = 6
    OnClick = btnApplyClick
  end
  object btnCancel: TButton
    Left = 392
    Top = 72
    Width = 121
    Height = 25
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = btnCancelClick
  end
  object btnExportSettings: TButton
    Left = 392
    Top = 472
    Width = 121
    Height = 25
    Caption = 'Export settings...'
    TabOrder = 9
    OnClick = btnExportSettingsClick
  end
  object btnImportSettings: TButton
    Left = 392
    Top = 504
    Width = 121
    Height = 25
    Caption = 'Import settings...'
    TabOrder = 10
    OnClick = btnImportSettingsClick
  end
  object btnDefault: TButton
    Left = 392
    Top = 440
    Width = 121
    Height = 25
    Caption = 'Load default settings'
    TabOrder = 8
    OnClick = btnDefaultClick
  end
  object grbAdvanced: TGroupBox
    Left = 8
    Top = 96
    Width = 369
    Height = 81
    Caption = 'Advanced settings'
    TabOrder = 1
    object cbDiscernKeyboardSides: TCheckBox
      Left = 208
      Top = 24
      Width = 129
      Height = 17
      Caption = 'Discern keyboard sides'
      TabOrder = 1
    end
    object cbSoftKeyComboRecognition: TCheckBox
      Left = 16
      Top = 24
      Width = 177
      Height = 17
      Caption = 'Soft key combination recognition'
      TabOrder = 0
    end
    object cbGameActiveForTrigger: TCheckBox
      Left = 16
      Top = 48
      Width = 273
      Height = 17
      Caption = 'Game window must be active for a trigger to activate'
      TabOrder = 2
    end
  end
  object diaImportSettings: TOpenDialog
    Filter = 'INI files (*.ini)|*.ini'
    Title = 'Importing program settings'
    Left = 424
    Top = 104
  end
  object diaExportSettings: TSaveDialog
    DefaultExt = '.ini'
    Filter = 'INI files (*.ini)|*.ini'
    Title = 'Exporting program settings'
    Left = 392
    Top = 104
  end
end
