object fMsgForm: TfMsgForm
  Left = 206
  Top = 595
  BorderStyle = bsDialog
  Caption = 'fMsgForm'
  ClientHeight = 110
  ClientWidth = 234
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object imMsgIcon: TImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
    AutoSize = True
    Center = True
  end
  object lblMainText: TLabel
    Left = 48
    Top = 8
    Width = 54
    Height = 13
    Caption = 'lblMainText'
  end
  object btnYesButton: TBitBtn
    Left = 32
    Top = 80
    Width = 75
    Height = 25
    Caption = 'btnYesButton'
    TabOrder = 0
    OnClick = btnYesButtonClick
  end
  object btnNoButton: TBitBtn
    Left = 120
    Top = 80
    Width = 75
    Height = 25
    Caption = 'btnNoButton'
    TabOrder = 1
    OnClick = btnNoButtonClick
  end
end
