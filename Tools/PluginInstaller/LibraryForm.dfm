object fLibraryForm: TfLibraryForm
  Left = 487
  Top = 321
  BorderStyle = bsDialog
  Caption = 'Plugins library'
  ClientHeight = 392
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  DesignSize = (
    784
    392)
  PixelsPerInch = 96
  TextHeight = 13
  object lvPluginsList: TListView
    Left = 8
    Top = 8
    Width = 769
    Height = 345
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Plugin description'
        Width = 210
      end
      item
        Caption = 'Plugin file'
        Width = 535
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvPluginsListDblClick
    OnKeyDown = lvPluginsListKeyDown
  end
  object btnButton_1: TButton
    Left = 328
    Top = 360
    Width = 145
    Height = 25
    Caption = 'btnButton_1'
    TabOrder = 1
    OnClick = btnButton_1Click
  end
  object btnButton_2: TButton
    Left = 480
    Top = 360
    Width = 145
    Height = 25
    Caption = 'btnButton_2'
    TabOrder = 2
    OnClick = btnButton_2Click
  end
  object btnButton_3: TButton
    Left = 632
    Top = 360
    Width = 145
    Height = 25
    Caption = 'btnButton_3'
    TabOrder = 3
    OnClick = btnButton_3Click
  end
  object dlgSelectPlugin: TOpenDialog
    Filter = 'Dynamic-link library (*.dll)|*.dll|All files (*.*)|*.*'
    Title = 'Select plugin'
  end
end
