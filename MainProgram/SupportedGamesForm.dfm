object fSupportedGamesForm: TfSupportedGamesForm
  Left = 246
  Top = 284
  BorderStyle = bsDialog
  Caption = 'Supported games'
  ClientHeight = 440
  ClientWidth = 1024
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbGamesList: TListBox
    Left = 8
    Top = 8
    Width = 449
    Height = 422
    Style = lbOwnerDrawFixed
    ItemHeight = 38
    TabOrder = 0
    OnClick = lbGamesListClick
    OnDrawItem = lbGamesListDrawItem
  end
  object gbGameDetails: TGroupBox
    Left = 464
    Top = 8
    Width = 553
    Height = 425
    Caption = 'Details about selected game entry'
    TabOrder = 1
    object lvGameDetails: TListView
      Left = 8
      Top = 17
      Width = 537
      Height = 400
      Columns = <
        item
          Caption = 'Value'
          Width = 170
        end
        item
          Caption = 'Data'
          Width = 345
        end>
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      GridLines = True
      ReadOnly = True
      RowSelect = True
      ParentFont = False
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
end
