unit KeyBindForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
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
    ActionIndex:    Integer;
    ActionText:     String;
    Input:          TInput;
    InputSelected:  Boolean;
    procedure OnKeyBind(Sender: TObject; VKey: Word);
  public
    procedure Initialize;
    Function StartBinding(ActionIndex: Integer; out Input: TInput): Boolean;
  end;

var
  fKeyBindForm: TfKeyBindForm;

implementation

{$R *.dfm}

uses
  SettingsForm,
  ACC_Strings, ACC_Input, ACC_Manager;
  

procedure TfKeyBindForm.OnKeyBind(Sender: TObject; VKey: Word);
var
  ConflictIndex:  Integer;
begin
ACCManager.InputManager.OnVirtualKeyRelease := nil;
Input := ACCManager.InputManager.CurrentInput; 
If fSettingsForm.LocalSettingsManager.InputConflict(Input,ActionIndex,ConflictIndex) then
  begin
    lblKeys.Font.Color := clRed;
    lblVirtualKeys.Font.Color := clRed;
    lblTitle.Caption := Format(ACCSTR_UI_BIND_KeysConflict,[ACCSTR_UI_SET_BIND_InputText(ConflictIndex)]);
  end
else
  begin
    btnAccept.Enabled := True;
    btnAccept.Visible := True;
    lblTitle.Caption := Format(ACCSTR_UI_BIND_SelectedKeys,[ActionText]);
  end;
btnRepeat.Enabled := True;
btnRepeat.Visible := True;
lblKeys.Caption := TInputManager.GetInputKeyNames(Input);
lblVirtualKeys.Caption := Format(ACCSTR_UI_BIND_VirtualKeyCodes,[TInputManager.GetInputKeyNames(Input,True)])
end;

//==============================================================================

procedure TfKeyBindForm.Initialize;
begin
lblTitle.Caption := Format(ACCSTR_UI_BIND_SelectKeys,[ActionText]);
lblKeys.Font.Color := clWindowText;
lblKeys.Caption := '';
lblVirtualKeys.Font.Color := clWindowText;
lblVirtualKeys.Caption := '';
btnAccept.Enabled := False;
btnAccept.Visible := False;
btnRepeat.Enabled := False;
btnRepeat.Visible := False;
Input.PrimaryKey := -1;
Input.ShiftKey := -1;
InputSelected := False;
ACCManager.InputManager.OnVirtualKeyRelease := OnKeyBind;
end;

//------------------------------------------------------------------------------

Function TfKeyBindForm.StartBinding(ActionIndex: Integer; out Input: TInput): Boolean;
begin
Self.ActionIndex := ActionIndex;
Self.ActionText := ACCSTR_UI_SET_BIND_InputText(ActionIndex);
ShowModal;
Input := Self.Input;
Result := (Input.PrimaryKey >= 0) and InputSelected;
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
InputSelected := True;
Close;
end;

//------------------------------------------------------------------------------

procedure TfKeyBindForm.btnCancelClick(Sender: TObject);
begin
ACCManager.InputManager.OnVirtualKeyRelease := nil;
InputSelected := False;
Close;
end;

//------------------------------------------------------------------------------

procedure TfKeyBindForm.btnRepeatClick(Sender: TObject);
begin
Initialize;
end;

end.
