object fKeyBindForm: TfKeyBindForm
  Left = 896
  Top = 596
  BorderStyle = bsNone
  Caption = 'fKeyBindForm'
  ClientHeight = 118
  ClientWidth = 360
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    360
    118)
  PixelsPerInch = 96
  TextHeight = 13
  object bvlBorder: TBevel
    Left = 0
    Top = 0
    Width = 360
    Height = 118
    Align = alClient
    Shape = bsFrame
    Style = bsRaised
  end
  object lblTitle: TLabel
    Left = 8
    Top = 8
    Width = 345
    Height = 25
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblTitle'
    WordWrap = True
  end
  object lblKeys: TLabel
    Left = 8
    Top = 40
    Width = 345
    Height = 17
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblKeys'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Layout = tlCenter
  end
  object lblVirtualKeys: TLabel
    Left = 8
    Top = 64
    Width = 345
    Height = 17
    Alignment = taCenter
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'lblVirtualKeys'
  end
  object btnAccept: TButton
    Left = 8
    Top = 88
    Width = 81
    Height = 21
    Caption = 'Accept'
    TabOrder = 0
    TabStop = False
    OnClick = btnAcceptClick
  end
  object btnCancel: TButton
    Left = 184
    Top = 88
    Width = 81
    Height = 21
    Caption = 'Cancel'
    TabOrder = 2
    TabStop = False
    OnClick = btnCancelClick
  end
  object btnRepeat: TButton
    Left = 272
    Top = 88
    Width = 81
    Height = 21
    Caption = 'Repeat'
    TabOrder = 3
    TabStop = False
    OnClick = btnRepeatClick
  end
  object btnClear: TButton
    Left = 96
    Top = 88
    Width = 81
    Height = 21
    Caption = 'Clear binding'
    TabOrder = 1
    TabStop = False
    OnClick = btnClearClick
  end
end
