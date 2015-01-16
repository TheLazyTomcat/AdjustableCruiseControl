unit KeyBindForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls,
  StdCtrls,
  ACC_Settings;

type
  TfKeyBindForm = class(TForm)
    bvlBorder: TBevel;
    lblTitle: TLabel;
    lblKeys: TLabel;
    lblVirtualKeys: TLabel;
    btnAccept: TButton;
    btnCancel: TButton;
    btnRepeat: TButton;    
    procedure FormShow(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);    
    procedure btnCancelClick(Sender: TObject);
    procedure btnRepeatClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fActionIndex:   Integer;
    fActionText:    String;
    fInput:         TInput;
    fInputSelected: Boolean;
    procedure OnKeyBind(Sender: TObject; {%H-}VKey: Word);
  public
    procedure Initialize;
    Function StartBinding(ActionIndex: Integer; out Input: TInput): Boolean;
  end;

var
  fKeyBindForm: TfKeyBindForm;

implementation

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

uses
  SettingsForm,
  ACC_Strings, ACC_Input, ACC_Manager;
  

procedure TfKeyBindForm.OnKeyBind(Sender: TObject; VKey: Word);
var
  ConflictIndex:  Integer;
begin
ACCManager.InputManager.OnVirtualKeyRelease := nil;
fInput := ACCManager.InputManager.CurrentInput;
If fSettingsForm.LocalSettingsManager.InputConflict(fInput,fActionIndex,ConflictIndex) then
  begin
    lblKeys.Font.Color := clRed;
    lblVirtualKeys.Font.Color := clRed;
    lblTitle.Caption := Format(ACCSTR_UI_BIND_KeysConflict,[ACCSTR_UI_SET_BIND_InputText(ConflictIndex)]);
  end
else
  begin
    btnAccept.Enabled := True;
    btnAccept.Visible := True;
    lblTitle.Caption := Format(ACCSTR_UI_BIND_SelectedKeys,[fActionText]);
  end;
btnRepeat.Enabled := True;
btnRepeat.Visible := True;
lblKeys.Caption := TInputManager.GetInputKeyNames(fInput);
lblVirtualKeys.Caption := Format(ACCSTR_UI_BIND_VirtualKeyCodes,[TInputManager.GetInputKeyNames(fInput,True)])
end;

//==============================================================================

procedure TfKeyBindForm.Initialize;
begin
lblTitle.Caption := Format(ACCSTR_UI_BIND_SelectKeys,[fActionText]);
lblKeys.Font.Color := clWindowText;
lblKeys.Caption := '';
lblVirtualKeys.Font.Color := clWindowText;
lblVirtualKeys.Caption := '';
btnAccept.Enabled := False;
btnAccept.Visible := False;
btnRepeat.Enabled := False;
btnRepeat.Visible := False;
fInput.PrimaryKey := -1;
fInput.ShiftKey := -1;
fInputSelected := False;
ACCManager.InputManager.OnVirtualKeyRelease := OnKeyBind;
end;

//------------------------------------------------------------------------------

Function TfKeyBindForm.StartBinding(ActionIndex: Integer; out Input: TInput): Boolean;
begin
fActionIndex := ActionIndex;
fActionText := ACCSTR_UI_SET_BIND_InputText(ActionIndex);
ShowModal;
Input := fInput;
Result := (Input.PrimaryKey >= 0) and fInputSelected;
end;

//==============================================================================

procedure TfKeyBindForm.FormShow(Sender: TObject);
begin
Initialize;
ActiveControl := nil;
end;

//------------------------------------------------------------------------------

procedure TfKeyBindForm.btnAcceptClick(Sender: TObject);
begin
fInputSelected := True;
Close;
end;

//------------------------------------------------------------------------------

procedure TfKeyBindForm.btnCancelClick(Sender: TObject);
begin
ACCManager.InputManager.OnVirtualKeyRelease := nil;
fInputSelected := False;
Close;
end;

//------------------------------------------------------------------------------

procedure TfKeyBindForm.btnRepeatClick(Sender: TObject);
begin
Initialize;
end;

end.