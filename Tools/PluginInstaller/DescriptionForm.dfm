object fDescriptionForm: TfDescriptionForm
  Left = 798
  Top = 520
  BorderStyle = bsDialog
  Caption = 'Plugin description'
  ClientHeight = 128
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lbeSelectedFile: TLabeledEdit
    Left = 8
    Top = 24
    Width = 457
    Height = 21
    Color = clBtnFace
    EditLabel.Width = 62
    EditLabel.Height = 13
    EditLabel.Caption = 'Selected file:'
    ReadOnly = True
    TabOrder = 0
  end
  object lbeDescription: TLabeledEdit
    Left = 8
    Top = 64
    Width = 457
    Height = 21
    EditLabel.Width = 57
    EditLabel.Height = 13
    EditLabel.Caption = 'Description:'
    TabOrder = 1
  end
  object btnAccept: TButton
    Left = 312
    Top = 96
    Width = 73
    Height = 25
    Caption = 'Accept'
    TabOrder = 2
    OnClick = btnAcceptClick
  end
  object btnCancel: TButton
    Left = 392
    Top = 96
    Width = 73
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = btnCancelClick
  end
end
