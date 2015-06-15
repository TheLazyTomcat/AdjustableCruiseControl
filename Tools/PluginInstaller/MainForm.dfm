object fMainForm: TfMainForm
  Left = 607
  Top = 113
  Width = 672
  Height = 402
  Caption = 'Plugin Installer'
  Color = clBtnFace
  Constraints.MinHeight = 368
  Constraints.MinWidth = 664
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    664
    368)
  PixelsPerInch = 96
  TextHeight = 13
  object lbGame: TLabel
    Left = 8
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Game:'
  end
  object cbGame: TComboBox
    Left = 8
    Top = 24
    Width = 649
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 13
    ParentFont = False
    TabOrder = 0
    OnChange = cbGameChange
  end
  object gbPlugins: TGroupBox
    Left = 8
    Top = 56
    Width = 649
    Height = 305
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Plugins'
    TabOrder = 1
    DesignSize = (
      649
      305)
    object lbl64bitWarning: TLabel
      Left = 8
      Top = 280
      Width = 170
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Operating system is not 64bit.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Visible = False
    end
    object lblInstalledPlugins: TLabel
      Left = 8
      Top = 72
      Width = 81
      Height = 13
      Caption = 'Installed plugins:'
    end
    object lbeRegistryKey: TLabeledEdit
      Left = 8
      Top = 40
      Width = 633
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = clBtnFace
      EditLabel.Width = 64
      EditLabel.Height = 13
      EditLabel.Caption = 'Registry key:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
    object lvInstalledPlugins: TListView
      Left = 8
      Top = 88
      Width = 633
      Height = 177
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Plugin description'
          Width = 150
        end
        item
          Caption = 'Plugin file'
          Width = 460
        end>
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnKeyDown = lvInstalledPluginsKeyDown
    end
    object btnAdd: TButton
      Left = 216
      Top = 272
      Width = 137
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Install plugin...'
      TabOrder = 2
      OnClick = btnAddClick
    end
    object btnRemove: TButton
      Left = 360
      Top = 272
      Width = 137
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Uninstall selected plugin'
      TabOrder = 3
      OnClick = btnRemoveClick
    end
    object btnRefresh: TButton
      Left = 504
      Top = 272
      Width = 137
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Refresh list of plugins'
      TabOrder = 4
      OnClick = btnRefreshClick
    end
  end
  object oXPManifest: TXPManifest
    Left = 632
  end
  object dlgAddPlugin: TOpenDialog
    Filter = 'Dynamic-link library (*.dll)|*.dll|All files (*.*)|*.*'
    Title = 'Select plugin'
    Left = 600
  end
end
