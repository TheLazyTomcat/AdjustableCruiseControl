unit MainForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Spin{$IFNDEF FPC}, XPMan{$ENDIF},
  ACC_Manager;

const
  WM_AFTERSHOW = WM_USER + 100;

type
{$IFDEF FPC}
  TfMainForm = class(TForm)
    shpTitleBackground: TShape;
    lblGameTitle: TLabel;
    lblGameInfo: TLabel;
    imgGameIcon: TImage;
    bvlGameInfo: TBevel;
    grbPreset: TGroupBox;
    btnIncreaseByUnit: TButton;
    btnIncreaseByStep: TButton;
    btnSetTo: TButton;
    seSpeedArbitrary: TFloatSpinEdit;
    lblStep: TLabel;
    seSpeedStep: TFloatSpinEdit;
    btnDecreaseByStep: TButton;
    btnDecreaseByUnit: TButton;
    btnSetCity: TButton;
    seSpeedCity: TFloatSpinEdit;
    btnSetRoads: TButton;
    seSpeedRoads: TFloatSpinEdit;
    grbUser: TGroupBox;
    btnSetUser0: TButton;
    seSpeedUser0: TFloatSpinEdit;
    btnSetUser1: TButton;
    seSpeedUser1: TFloatSpinEdit;
    btnSetUser2: TButton;
    seSpeedUser2: TFloatSpinEdit;
    btnSetUser3: TButton;
    seSpeedUser3: TFloatSpinEdit;
    btnSetUser4: TButton;
    seSpeedUser4: TFloatSpinEdit;
    btnSetUser5: TButton;
    seSpeedUser5: TFloatSpinEdit;
    btnSetUser6: TButton;
    seSpeedUser6: TFloatSpinEdit;
    btnSetUser7: TButton;
    seSpeedUser7: TFloatSpinEdit;
    btnSetUser8: TButton;
    seSpeedUser8: TFloatSpinEdit;
    btnSetUser9: TButton;
    seSpeedUser9: TFloatSpinEdit;
    bvlUserSplit: TBevel;
    grbSpeedLimit: TGroupBox;
    btnSetToLimit: TButton;
    btnKeepOnLimit: TButton;
    lblActionOnZero: TLabel;
    cbActionOnZero: TComboBox;
    seSpeedLimitDefault: TFloatSpinEdit;
    cbShowKeyBindings: TCheckBox;
    lblUnits: TLabel;
    cbUnits: TComboBox;
    btnSettings: TButton;
    btnAbout: TButton;
    sbStatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSpeedsClick(Sender: TObject);
    procedure seSpeedsChange(Sender: TObject);
    procedure cbActionOnZeroChange(Sender: TObject);
    procedure cbShowKeyBindingsClick(Sender: TObject);
    procedure cbUnitsChange(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);    
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
  protected  
    fLoadingUpdate:   Boolean;
    fUpdateFile:      String;
    fSpeedsChanging:  Boolean;
    procedure AfterShow(var {%H-}Msg: TMessage); message WM_AFTERSHOW;
    procedure ShowNoDisturb(var {%H-}Msg: TMessage); message WM_SHOWNODISTURB;
    procedure OnBindStateChange(Sender: TObject);
    procedure OnPluginStateChange(Sender: TObject);
    procedure SpeedsToForm(Sender: TObject);
    procedure KeysToForm;
  public
    procedure SettingsToForm;
    procedure LoadUpdate(const UpdateFile: String);
  end;
{$ELSE}
  TfMainForm = class(TForm)
    shpTitleBackground: TShape;
    lblGameTitle: TLabel;
    lblGameInfo: TLabel;
    imgGameIcon: TImage;
    bvlGameInfo: TBevel;
    grbPreset: TGroupBox;
    btnIncreaseByUnit: TButton;
    btnIncreaseByStep: TButton;
    btnSetTo: TButton;
    seSpeedArbitrary: TSpinEdit;
    lblStep: TLabel;
    seSpeedStep: TSpinEdit;
    btnDecreaseByStep: TButton;
    btnDecreaseByUnit: TButton;
    btnSetCity: TButton;
    seSpeedCity: TSpinEdit;
    btnSetRoads: TButton;
    seSpeedRoads: TSpinEdit;    
    grbUser: TGroupBox;
    btnSetUser0: TButton;
    seSpeedUser0: TSpinEdit;
    btnSetUser1: TButton;
    seSpeedUser1: TSpinEdit;
    btnSetUser2: TButton;
    seSpeedUser2: TSpinEdit;
    btnSetUser3: TButton;
    seSpeedUser3: TSpinEdit;
    btnSetUser4: TButton;
    seSpeedUser4: TSpinEdit;
    btnSetUser5: TButton;
    seSpeedUser5: TSpinEdit;
    btnSetUser6: TButton;
    seSpeedUser6: TSpinEdit;
    btnSetUser7: TButton;
    seSpeedUser7: TSpinEdit;
    btnSetUser8: TButton;
    seSpeedUser8: TSpinEdit;
    btnSetUser9: TButton;
    seSpeedUser9: TSpinEdit;
    bvlUserSplit: TBevel;
    grbSpeedLimit: TGroupBox;
    btnSetToLimit: TButton;
    btnKeepOnLimit: TButton;
    lblActionOnZero: TLabel;    
    cbActionOnZero: TComboBox;
    seSpeedLimitDefault: TSpinEdit;
    cbShowKeyBindings: TCheckBox;    
    lblUnits: TLabel;
    cbUnits: TComboBox;
    btnSettings: TButton;
    btnAbout: TButton;
    oXPManifest: TXPManifest;
    sbStatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSpeedsClick(Sender: TObject);
    procedure seSpeedsChange(Sender: TObject);
    procedure cbActionOnZeroChange(Sender: TObject);
    procedure cbShowKeyBindingsClick(Sender: TObject);
    procedure cbUnitsChange(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fLoadingUpdate:   Boolean;
    fUpdateFile:      String;
    fSpeedsChanging:  Boolean;
    procedure AfterShow(var Msg: TMessage); message WM_AFTERSHOW;
    procedure ShowNoDisturb(var Msg: TMessage); message WM_SHOWNODISTURB;
    procedure OnBindStateChange(Sender: TObject);
    procedure OnPluginStateChange(Sender: TObject);
    procedure SpeedsToForm(Sender: TObject);
    procedure KeysToForm;
  public
    procedure SettingsToForm;
    procedure LoadUpdate(const UpdateFile: String);
  end;
{$ENDIF}

var
  fMainForm: TfMainForm;

implementation

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

uses
  Windows,
  ACC_Settings, ACC_Strings, ACC_Input, ACC_PluginComm,
  AboutForm, SettingsForm, UpdateForm;


procedure TfMainForm.AfterShow(var Msg: TMessage);
begin
If fLoadingUpdate then
  fUpdateForm.LoadUpdateFromFile(Self,fUpdateFile);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.ShowNoDisturb(var Msg: TMessage);
begin
Application.MainForm.Visible := True
end;

//------------------------------------------------------------------------------

procedure TfMainForm.OnBindStateChange(Sender: TObject);
begin
If ACCManager.ProcessBinder.Binded then
  begin
    imgGameIcon.Picture.Assign(ACCManager.GamesDataManager.GameIcons.GetIcon(ACCManager.ProcessBinder.GameData.Icon));
    lblGameTitle.Caption := ACCManager.ProcessBinder.GameData.Title;
    lblGameInfo.Caption := ACCManager.ProcessBinder.GameData.Info;
    sbStatusBar.Panels[0].Text := ACCSTR_UI_STB_GameProcess +
      Format(ACCSTR_UI_STB_ProcessInfo,[ACCManager.ProcessBinder.GameData.Modules[0].FileName,ACCManager.ProcessBinder.GameData.ProcessInfo.ProcessID]);
  end
else
  begin
    imgGameIcon.Picture := nil;
    lblGameTitle.Caption := ACCSTR_UI_GAM_NoGameTitle;
    lblGameInfo.Caption := ACCSTR_UI_GAM_NoGameInfo;
    sbStatusBar.Panels[0].Text := ACCSTR_UI_STB_NoGameProcess;
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.OnPluginStateChange(Sender: TObject);
begin
If ACCManager.PluginOnline then
  begin
    sbStatusBar.Panels[1].Text := ACCSTR_UI_STB_PluginOnline;
    If (ACCManager.PluginFeatures and WMC_PF_Limit) <> 0 then
      grbSpeedLimit.Caption := ACCSTR_UI_LIM_BoxCaptionNormal
    else
      grbSpeedLimit.Caption := ACCSTR_UI_LIM_BoxCaptionUnsupported;
  end
else
  begin
    sbStatusBar.Panels[1].Text := ACCSTR_UI_STB_PluginOffline;
    grbSpeedLimit.Caption := ACCSTR_UI_LIM_BoxCaptionInactive;
  end;
{$IFDEF FPC}
grbSpeedLimit.Invalidate;
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TfMainForm.SpeedsToForm(Sender: TObject);
var
  i:        Integer;
  Coef:     Single;
{$IFDEF FPC}
  SpinEdit: TFloatSpinEdit;
{$ELSE}
  SpinEdit: TSpinEdit;
{$ENDIF}
begin
fSpeedsChanging := True;
try
  Coef := Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient;
  If Coef = 0 then Coef := 1;
{$IFDEF FPC}
  seSpeedArbitrary.Value := Settings.Speeds.Arbitrary / Coef;
  seSpeedStep.Value := Settings.Speeds.Step / Coef;
  seSpeedCity.Value := Settings.Speeds.City / Coef;
  seSpeedRoads.Value := Settings.Speeds.Roads / Coef;
  For i := 0 to 9 do
    begin
      SpinEdit := FindComponent('seSpeedUser' + IntToStr(i)) as TFloatSpinEdit;
      If Assigned(SpinEdit) then SpinEdit.Value := Settings.Speeds.User[i] / Coef;
    end;
  seSpeedLimitDefault.Value := Settings.Speeds.LimitDefault / Coef;  
{$ELSE}
  seSpeedArbitrary.Value := Round(Settings.Speeds.Arbitrary / Coef);
  seSpeedStep.Value := Round(Settings.Speeds.Step / Coef);
  seSpeedCity.Value := Round(Settings.Speeds.City / Coef);
  seSpeedRoads.Value := Round(Settings.Speeds.Roads / Coef);
  For i := 0 to 9 do
    begin
      SpinEdit := FindComponent('seSpeedUser' + IntToStr(i)) as TSpinEdit;
      If Assigned(SpinEdit) then SpinEdit.Value := Round(Settings.Speeds.User[i] / Coef);
    end;
  seSpeedLimitDefault.Value := Round(Settings.Speeds.LimitDefault / Coef);
{$ENDIF}
finally
  fSpeedsChanging := False;
end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.KeysToForm;
var
  i:          Integer;
  UserButton: TButton;

  procedure SetButtonCaption(Button: TButton; const Text: String; const KeysStr: String; NoText: Boolean = False);
  begin
    If (KeysStr <> '') and Settings.ShowKeyBindings then
      begin
        If NoText then
          Button.Caption := Format(ACCSTR_UI_BTN_Keys,[KeysStr])
        else
          Button.Caption := Text + Format(ACCSTR_UI_BTN_Keys,[KeysStr]);
      end
    else Button.Caption := Text;
  end;

begin
SetButtonCaption(btnIncreaseByUnit,ACCSTR_UI_BTN_IncreaseByUnit,TInputManager.GetInputKeyNames(Settings.Inputs.IncreaseByUnit));
SetButtonCaption(btnIncreaseByStep,ACCSTR_UI_BTN_IncreaseByStep,TInputManager.GetInputKeyNames(Settings.Inputs.IncreaseByStep));
btnSetTo.Caption := ACCSTR_UI_BTN_SetToArbitrary;
SetButtonCaption(btnDecreaseByStep,ACCSTR_UI_BTN_DecreaseByStep,TInputManager.GetInputKeyNames(Settings.Inputs.DecreaseByStep));
SetButtonCaption(btnDecreaseByUnit,ACCSTR_UI_BTN_DecreaseByUnit,TInputManager.GetInputKeyNames(Settings.Inputs.DecreaseByUnit));
SetButtonCaption(btnSetCity,ACCSTR_UI_BTN_SetToCity,TInputManager.GetInputKeyNames(Settings.Inputs.CityEngage));
SetButtonCaption(btnSetRoads,ACCSTR_UI_BTN_SetToRoads,TInputManager.GetInputKeyNames(Settings.Inputs.RoadsEngage));
For i := 0 to 9 do
  begin
    UserButton := FindComponent('btnSetUser' + IntToStr(i)) as TButton;
    SetButtonCaption(UserButton,Format(ACCSTR_UI_BTN_SetToUser,[i]),TInputManager.GetInputKeyNames(Settings.Inputs.UserEngage[i]),True);
  end;
SetButtonCaption(btnSetToLimit,ACCSTR_UI_SET_BIND_SetToLimit,TInputManager.GetInputKeyNames(Settings.Inputs.SetToLimit));
SetButtonCaption(btnKeepOnLimit,ACCSTR_UI_SET_BIND_KeepOnLimit,TInputManager.GetInputKeyNames(Settings.Inputs.KeepOnLimit));
end;

//------------------------------------------------------------------------------

procedure TfMainForm.SettingsToForm;
var
  i:  Integer;
begin
SpeedsToForm(nil);
KeysToForm;
cbUnits.Items.BeginUpdate;        
try
  cbUnits.Items.Clear;
  For i := Low(Settings.SpeedUnits) to High(Settings.SpeedUnits) do
    cbUnits.Items.Add(Settings.SpeedUnits[i].Name);
finally
  cbUnits.Items.EndUpdate;
end;
cbUnits.ItemIndex := Settings.UsedSpeedUnit;
cbActionOnZero.ItemIndex := Settings.ZeroLimitAction;
cbShowKeyBindings.Checked := Settings.ShowKeyBindings;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.LoadUpdate(const UpdateFile: String);
begin
fLoadingUpdate := True;
fUpdateFile := UpdateFile;
end;

//==============================================================================

procedure TfMainForm.FormCreate(Sender: TObject);
var
  i:  Integer;
begin
sbStatusBar.DoubleBuffered := True;
fSpeedsChanging := False;
For i := Low(ACCSTR_UI_LIM_ActionsOnZeroLimit) to High(ACCSTR_UI_LIM_ActionsOnZeroLimit) do
  cbActionOnZero.Items.Add(ACCSTR_UI_LIM_ActionsOnZeroLimit[i]);
ACCManager.OnBindStateChange.Add(OnBindStateChange);
ACCManager.OnSpeedChange := SpeedsToForm;
ACCManager.OnPluginStateChange := OnPluginStateChange;
fLoadingUpdate := False;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormShow(Sender: TObject);
begin
SettingsToForm;
OnPluginStateChange(nil);
btnAbout.SetFocus;
SetWindowLong(Application.MainForm.Handle,GWL_EXSTYLE,GetWindowLong(Application.MainForm.Handle,GWL_EXSTYLE) and not WS_EX_NOACTIVATE);
PostMessage(Self.WindowHandle,WM_AFTERSHOW,0,0);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnSpeedsClick(Sender: TObject);
begin
If Sender is TButton then
  ACCManager.ExecuteTrigger(nil,(Sender as TButton).Tag,tcUI);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.seSpeedsChange(Sender: TObject);
var
  Coef:     Single;
{$IFDEF FPC}
  SpinEdit: TFloatSpinEdit;
{$ELSE}
  SpinEdit: TSpinEdit;
{$ENDIF}
begin
If not fSpeedsChanging then
  begin
    Coef := Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient;
    If Coef = 0 then Coef := 1;
  {$IFDEF FPC}
    If Sender is TFloatSpinEdit then
      begin
        SpinEdit := Sender as TFloatSpinEdit;
  {$ELSE}
    If Sender is TSpinEdit then
      begin
        SpinEdit := Sender as TSpinEdit;
  {$ENDIF}
        case SpinEdit.Tag of
            -1: Settings.Speeds.Arbitrary := SpinEdit.Value * Coef;
            -2: Settings.Speeds.Step := SpinEdit.Value * Coef;
            -3: Settings.Speeds.City := SpinEdit.Value * Coef;
            -4: Settings.Speeds.Roads := SpinEdit.Value * Coef;
            -5: Settings.Speeds.LimitDefault := SpinEdit.Value * Coef;
          0..9: Settings.Speeds.User[SpinEdit.Tag] := SpinEdit.Value * Coef;
        end;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.cbActionOnZeroChange(Sender: TObject);
begin
Settings.ZeroLimitAction := cbActionOnZero.ItemIndex;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.cbShowKeyBindingsClick(Sender: TObject);
begin
Settings.ShowKeyBindings := cbShowKeyBindings.Checked;
KeysToForm;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.cbUnitsChange(Sender: TObject);
begin
Settings.UsedSpeedUnit := cbUnits.ItemIndex;
SpeedsToForm(nil);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnSettingsClick(Sender: TObject);
begin
fSettingsForm.ShowModal;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnAboutClick(Sender: TObject);
begin
fAboutForm.ShowModal;
end;

end.
