object fMainForm: TfMainForm
  Left = 672
  Top = 115
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Adjustable Cruise Control'
  ClientHeight = 371
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010000001002000680400001600000028000000100000002000
    0000010020000000000040040000000000000000000000000000000000000000
    000000000000000000000202020B0202021C0101010100000000000000000000
    000000000000010101020202021D010101080000000000000000000000000000
    00000000000002020209454545A85A5A5AE70303034700000000000000000000
    000000000000151515576C6C6CEA121212980101010500000000000000000000
    0000000000001A1A1A60878787FC6C6C6CDB1D1D1D5F00000000000000000000
    0000000000016D6D6D78565656DC6A6A6AFB0303034E00000000000000000000
    0000010101056E6E6EC33C3C3CD40101011401010104000000000101010F0101
    010D00000000010101050202021A7B7B7BE11C1C1CB100000002000000000000
    000001010114818181EB0C0C0CC70202021300000000040404256A6A6AD43C3C
    3CCB0202021B00000000030303194A4A4AD54A4A4ADF0101010C000000000000
    00000101011A8E8E8EF2707070ED02020231000000001D1D1D52D5D5D5FE8787
    87FB02020237000000003E3E3E45929292F7575757E701010110000000000000
    00000101010D808080DF121212B8000000040000000017171769878787FE2121
    21870101010700000000010101085E5E5EC9444444D000000007000000000000
    0000000000015F5F5F9E4C4C4CF00404045D03030326656565C6474747D70101
    010D000000000303032405050566868686F61111118A00000000000000000000
    0000000000000B0B0B2D808080ED7F7F7FFE141414A2898989ED0A0A0A840101
    010D000000025656569C868686FE5E5E5EE50101012100000000000000000000
    000000000000000000002C2C2C5A7C7C7CF2393939ED0C0C0CBC4E4E4EC61B1B
    1BB11212128D686868EE707070EC0505054B0000000000000000000000000000
    00000000000000000000020202160F0F0FA7727272FF727272FE919191FE7E7E
    7EFE7C7C7CF3454545B402020233000000000000000000000000000000000000
    000000000000242424265B5B5BD6999999FEAEAEAEFF151515CC030303490202
    0244010101220000000400000000000000000000000000000000000000000000
    00000000000017171727828282F6C4C4C4FFA0A0A0FF434343EF0202021D0000
    0000000000000000000000000000000000000000000000000000000000000000
    00000000000016161642B3B3B3FED2D2D2FF939393FF3D3D3DD7020202200000
    0000000000000000000000000000000000000000000000000000000000000000
    0000000000001C1C1C166868689E979797EE5E5E5EF002020238000000010000
    0000000000000000000000000000000000000000000000000000000000000000
    00000000000000000000010101010202021E0B0B0B2F00000002000000000000
    000000000000000000000000000000000000000000000000000000000000E3C7
    FFFFC3C3FFFFC383FFFF8241FFFF8421FFFF8421FFFF8421FFFF8043FFFFC003
    FFFFE007FFFFE00FFFFFC01FFFFFC0FFFFFFC0FFFFFFC0FFFFFFE1FFFFFF}
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    592
    371)
  PixelsPerInch = 96
  TextHeight = 13
  object shpTitleBackground: TShape
    Left = 0
    Top = 0
    Width = 592
    Height = 49
    Anchors = [akLeft, akTop, akRight]
    Pen.Style = psClear
  end
  object lblUnits: TLabel
    Left = 133
    Top = 300
    Width = 28
    Height = 13
    Alignment = taRightJustify
    Caption = 'Units:'
  end
  object bvlGameInfo: TBevel
    Left = 0
    Top = 48
    Width = 585
    Height = 9
    Shape = bsTopLine
    Style = bsRaised
  end
  object imgGameIcon: TImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  object lblGameTitle: TLabel
    Left = 8
    Top = 8
    Width = 576
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblGameTitle'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    ShowAccelChar = False
    Transparent = True
  end
  object lblGameInfo: TLabel
    Left = 8
    Top = 24
    Width = 576
    Height = 13
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblGameInfo'
    ShowAccelChar = False
    Transparent = True
  end
  object grbPreset: TGroupBox
    Left = 8
    Top = 56
    Width = 233
    Height = 235
    Caption = 'Preset speeds'
    TabOrder = 0
    object lblStep: TLabel
      Left = 155
      Top = 86
      Width = 26
      Height = 13
      Alignment = taRightJustify
      Caption = 'Step:'
    end
    object btnIncreaseByStep: TButton
      Tag = 1
      Left = 8
      Top = 49
      Width = 217
      Height = 21
      Caption = 'btnIncreaseByStep'
      TabOrder = 1
      OnClick = btnSpeedsClick
    end
    object btnDecreaseByStep: TButton
      Tag = 2
      Left = 8
      Top = 115
      Width = 217
      Height = 21
      Caption = 'btnDecreaseByStep'
      TabOrder = 5
      OnClick = btnSpeedsClick
    end
    object seSpeedArbitrary: TSpinEdit
      Tag = -1
      Left = 72
      Top = 82
      Width = 49
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = seSpeedsChange
    end
    object seSpeedStep: TSpinEdit
      Tag = -2
      Left = 184
      Top = 82
      Width = 41
      Height = 22
      MaxValue = 99
      MinValue = 0
      TabOrder = 4
      Value = 0
      OnChange = seSpeedsChange
    end
    object seSpeedCity: TSpinEdit
      Tag = -3
      Left = 184
      Top = 178
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 8
      Value = 0
      OnChange = seSpeedsChange
    end
    object seSpeedRoads: TSpinEdit
      Tag = -4
      Left = 184
      Top = 203
      Width = 41
      Height = 22
      MaxValue = 99
      MinValue = 0
      TabOrder = 10
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetCity: TButton
      Tag = 10
      Left = 8
      Top = 178
      Width = 169
      Height = 21
      Caption = 'btnSetCity'
      TabOrder = 7
      OnClick = btnSpeedsClick
    end
    object btnSetRoads: TButton
      Tag = 15
      Left = 8
      Top = 203
      Width = 169
      Height = 21
      Caption = 'btnSetRoads'
      TabOrder = 9
      OnClick = btnSpeedsClick
    end
    object btnIncreaseByUnit: TButton
      Tag = 3
      Left = 8
      Top = 24
      Width = 217
      Height = 21
      Caption = 'btnIncreaseByUnit'
      TabOrder = 0
      OnClick = btnSpeedsClick
    end
    object btnDecreaseByUnit: TButton
      Tag = 4
      Left = 8
      Top = 140
      Width = 217
      Height = 21
      Caption = 'btnDecreaseByUnit'
      TabOrder = 6
      OnClick = btnSpeedsClick
    end
    object btnSetTo: TButton
      Left = 8
      Top = 82
      Width = 57
      Height = 21
      Caption = 'btnSetTo'
      TabOrder = 2
      OnClick = btnSpeedsClick
    end
  end
  object grbUser: TGroupBox
    Left = 248
    Top = 56
    Width = 337
    Height = 193
    Caption = 'User defined speeds'
    TabOrder = 1
    object bvlUserSplit: TBevel
      Left = 168
      Top = 24
      Width = 9
      Height = 153
      Shape = bsLeftLine
    end
    object seSpeedUser0: TSpinEdit
      Left = 120
      Top = 24
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 1
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetUser0: TButton
      Tag = 100
      Left = 8
      Top = 24
      Width = 105
      Height = 21
      Caption = 'btnSetUser0'
      TabOrder = 0
      OnClick = btnSpeedsClick
    end
    object seSpeedUser1: TSpinEdit
      Tag = 1
      Left = 120
      Top = 57
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetUser1: TButton
      Tag = 101
      Left = 8
      Top = 57
      Width = 105
      Height = 21
      Caption = 'btnSetUser1'
      TabOrder = 2
      OnClick = btnSpeedsClick
    end
    object seSpeedUser2: TSpinEdit
      Tag = 2
      Left = 120
      Top = 90
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 5
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetUser2: TButton
      Tag = 102
      Left = 8
      Top = 90
      Width = 105
      Height = 21
      Caption = 'btnSetUser2'
      TabOrder = 4
      OnClick = btnSpeedsClick
    end
    object seSpeedUser3: TSpinEdit
      Tag = 3
      Left = 120
      Top = 123
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 7
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetUser3: TButton
      Tag = 103
      Left = 8
      Top = 123
      Width = 105
      Height = 21
      Caption = 'btnSetUser3'
      TabOrder = 6
      OnClick = btnSpeedsClick
    end
    object seSpeedUser4: TSpinEdit
      Tag = 4
      Left = 120
      Top = 156
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 9
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetUser4: TButton
      Tag = 104
      Left = 8
      Top = 156
      Width = 105
      Height = 21
      Caption = 'btnSetUser4'
      TabOrder = 8
      OnClick = btnSpeedsClick
    end
    object btnSetUser5: TButton
      Tag = 105
      Left = 176
      Top = 24
      Width = 105
      Height = 21
      Caption = 'btnSetUser5'
      TabOrder = 10
      OnClick = btnSpeedsClick
    end
    object seSpeedUser5: TSpinEdit
      Tag = 5
      Left = 288
      Top = 24
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 11
      Value = 0
      OnChange = seSpeedsChange
    end
    object seSpeedUser6: TSpinEdit
      Tag = 6
      Left = 288
      Top = 57
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 13
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetUser6: TButton
      Tag = 106
      Left = 176
      Top = 57
      Width = 105
      Height = 21
      Caption = 'btnSetUser6'
      TabOrder = 12
      OnClick = btnSpeedsClick
    end
    object btnSetUser7: TButton
      Tag = 107
      Left = 176
      Top = 90
      Width = 105
      Height = 21
      Caption = 'btnSetUser7'
      TabOrder = 14
      OnClick = btnSpeedsClick
    end
    object seSpeedUser7: TSpinEdit
      Tag = 7
      Left = 288
      Top = 90
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 15
      Value = 0
      OnChange = seSpeedsChange
    end
    object seSpeedUser8: TSpinEdit
      Tag = 8
      Left = 288
      Top = 123
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 17
      Value = 0
      OnChange = seSpeedsChange
    end
    object btnSetUser8: TButton
      Tag = 108
      Left = 176
      Top = 123
      Width = 105
      Height = 21
      Caption = 'btnSetUser8'
      TabOrder = 16
      OnClick = btnSpeedsClick
    end
    object btnSetUser9: TButton
      Tag = 109
      Left = 176
      Top = 156
      Width = 105
      Height = 21
      Caption = 'btnSetUser9'
      TabOrder = 18
      OnClick = btnSpeedsClick
    end
    object seSpeedUser9: TSpinEdit
      Tag = 9
      Left = 288
      Top = 156
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 19
      Value = 0
      OnChange = seSpeedsChange
    end
  end
  object sbStatusBar: TStatusBar
    Left = 0
    Top = 352
    Width = 592
    Height = 19
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Panels = <
      item
        Text = 'game_process'
        Width = 450
      end
      item
        Text = 'plugin_status'
        Width = 50
      end>
    UseSystemFont = False
  end
  object cbUnits: TComboBox
    Left = 168
    Top = 296
    Width = 73
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    OnChange = cbUnitsChange
  end
  object btnAbout: TButton
    Left = 128
    Top = 322
    Width = 113
    Height = 21
    Caption = 'About...'
    TabOrder = 5
    OnClick = btnAboutClick
  end
  object btnSettings: TButton
    Left = 8
    Top = 322
    Width = 113
    Height = 21
    Caption = 'Settings...'
    TabOrder = 4
    OnClick = btnSettingsClick
  end
  object grbSpeedLimit: TGroupBox
    Left = 248
    Top = 256
    Width = 337
    Height = 89
    Caption = 'Speed limit'
    TabOrder = 2
    object lblActionOnZero: TLabel
      Left = 13
      Top = 59
      Width = 124
      Height = 13
      Alignment = taRightJustify
      Caption = 'Action on speed limit of 0:'
    end
    object btnSetToLimit: TButton
      Tag = 400
      Left = 8
      Top = 24
      Width = 161
      Height = 21
      Caption = 'btnSetToLimit'
      TabOrder = 0
      OnClick = btnSpeedsClick
    end
    object btnKeepOnLimit: TButton
      Tag = 401
      Left = 176
      Top = 24
      Width = 153
      Height = 21
      Caption = 'btnKeepOnLimit'
      TabOrder = 1
      OnClick = btnSpeedsClick
    end
    object cbActionOnZero: TComboBox
      Left = 144
      Top = 56
      Width = 137
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbActionOnZeroChange
    end
    object seSpeedLimitDefault: TSpinEdit
      Tag = -5
      Left = 288
      Top = 56
      Width = 41
      Height = 22
      MaxValue = 999
      MinValue = 0
      TabOrder = 3
      Value = 0
      OnChange = seSpeedsChange
    end
  end
  object oXPManifest: TXPManifest
  end
end
