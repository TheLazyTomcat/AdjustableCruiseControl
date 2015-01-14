unit MainForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Spin{$IFNDEF FPC}, XPMan{$ENDIF};

type

  { TfMainForm }
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
    lblUnits: TLabel;
    cbUnits: TComboBox;
    btnSettings: TButton;
    btnAbout: TButton;
    sbStatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSpeedsClick(Sender: TObject);
    procedure seSpeedsChange(Sender: TObject);
    procedure cbUnitsChange(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);    
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fSpeedsChanging:  Boolean;
    procedure OnBindStateChange(Sender: TObject);
    procedure SpeedsToForm(Sender: TObject);
    procedure KeysToForm;
  public
    procedure SettingsToForm;
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
    lblUnits: TLabel;
    cbUnits: TComboBox;
    btnSettings: TButton;
    btnAbout: TButton;
    sbStatusBar: TStatusBar;
    oXPManifest: TXPManifest;  
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSpeedsClick(Sender: TObject);
    procedure seSpeedsChange(Sender: TObject);
    procedure cbUnitsChange(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);    
    procedure btnAboutClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fSpeedsChanging:  Boolean;
    procedure OnBindStateChange(Sender: TObject);
    procedure SpeedsToForm(Sender: TObject);
    procedure KeysToForm;
  public
    procedure SettingsToForm;
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
  ACC_Manager, ACC_Settings, ACC_Strings, ACC_Input,
  AboutForm, SettingsForm;

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
{$ENDIF}
finally
  fSpeedsChanging := False;
end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.KeysToForm;
var
  i:      Integer;
  Button: TButton;
begin
btnIncreaseByUnit.Caption := Format(ACCSTR_UI_BTN_IncreaseByUnit,[TInputManager.GetInputKeyNames(Settings.Inputs.IncreaseByUnit)]);
btnIncreaseByStep.Caption := Format(ACCSTR_UI_BTN_IncreaseByStep,[TInputManager.GetInputKeyNames(Settings.Inputs.IncreaseByStep)]);
btnSetTo.Caption := ACCSTR_UI_BTN_SetToArbitrary;
btnDecreaseByStep.Caption := Format(ACCSTR_UI_BTN_DecreaseByStep,[TInputManager.GetInputKeyNames(Settings.Inputs.DecreaseByStep)]);
btnDecreaseByUnit.Caption := Format(ACCSTR_UI_BTN_DecreaseByUnit,[TInputManager.GetInputKeyNames(Settings.Inputs.DecreaseByUnit)]);
btnSetCity.Caption := Format(ACCSTR_UI_BTN_SetToCity,[TInputManager.GetInputKeyNames(Settings.Inputs.CityEngage)]);
btnSetRoads.Caption := Format(ACCSTR_UI_BTN_SetToRoads,[TInputManager.GetInputKeyNames(Settings.Inputs.RoadsEngage)]);
For i := 0 to 9 do
  begin
    Button := FindComponent('btnSetUser' + IntToStr(i)) as TButton;
    Button.Caption := Format(ACCSTR_UI_BTN_SetToUser,[TInputManager.GetInputKeyNames(Settings.Inputs.UserEngage[i])]);
  end;
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
end;

//==============================================================================

procedure TfMainForm.FormCreate(Sender: TObject);
begin
sbStatusBar.DoubleBuffered := True;
fSpeedsChanging := False;
ACCManager.OnBindStateChange.Add(OnBindStateChange);
ACCManager.OnSpeedChange := SpeedsToForm;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormShow(Sender: TObject);
begin
SettingsToForm;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnSpeedsClick(Sender: TObject);
begin
If Sender is TButton then
  ACCManager.ExecuteTrigger(nil,(Sender as TButton).Tag);
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
          0..9: Settings.Speeds.User[SpinEdit.Tag] := SpinEdit.Value * Coef;
        end;
      end;
  end;
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
