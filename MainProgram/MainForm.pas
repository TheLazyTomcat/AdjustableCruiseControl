unit MainForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, Spin, XPMan;

type
  TfMainForm = class(TForm)
    shpTitleBackground: TShape;
    lblGameTitle: TLabel;
    lblGameInfo: TLabel;
    grbPreset: TGroupBox;
    grbUser: TGroupBox;
    oXPManifest: TXPManifest;
    btnIncreaseByStep: TButton;
    btnDecreaseByStep: TButton;
    seSpeedArbitrary: TSpinEdit;
    seSpeedStep: TSpinEdit;
    lblStep: TLabel;
    seSpeedCity: TSpinEdit;
    seSpeedRoads: TSpinEdit;
    btnSetCity: TButton;
    btnSetRoads: TButton;
    sbStatusBar: TStatusBar;
    seSpeedUser0: TSpinEdit;
    btnSetUser0: TButton;
    seSpeedUser1: TSpinEdit;
    btnSetUser1: TButton;
    seSpeedUser2: TSpinEdit;
    btnSetUser2: TButton;
    seSpeedUser3: TSpinEdit;
    btnSetUser3: TButton;
    seSpeedUser4: TSpinEdit;
    btnSetUser4: TButton;
    btnSetUser5: TButton;
    seSpeedUser5: TSpinEdit;
    seSpeedUser6: TSpinEdit;
    btnSetUser6: TButton;
    btnSetUser7: TButton;
    seSpeedUser7: TSpinEdit;
    seSpeedUser8: TSpinEdit;
    btnSetUser8: TButton;
    btnSetUser9: TButton;
    seSpeedUser9: TSpinEdit;
    bvlUserSplit: TBevel;
    lblUnits: TLabel;
    cbUnits: TComboBox;
    btnAbout: TButton;
    btnSettings: TButton;
    btnIncreaseByUnit: TButton;
    btnDecreaseByUnit: TButton;
    btnSetTo: TButton;
    bvlGameInfo: TBevel;
    imgGameIcon: TImage;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure cbUnitsChange(Sender: TObject);
    procedure seSpeedsChange(Sender: TObject);
    procedure btnSpeedsClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
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

var
  fMainForm: TfMainForm;

implementation

{$R *.dfm}

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

procedure TfMainForm.SpeedsToForm(Sender: TObject);
var
  i:        Integer;
  SpinEdit: TSpinEdit;
  Coef:     Single;
begin
fSpeedsChanging := True;
try
  Coef := Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient;
  If Coef = 0 then Coef := 1;
  seSpeedArbitrary.Value := Round(Settings.Speeds.Arbitrary / Coef);
  seSpeedStep.Value := Round(Settings.Speeds.Step / Coef);
  seSpeedCity.Value := Round(Settings.Speeds.City / Coef);
  seSpeedRoads.Value := Round(Settings.Speeds.Roads / Coef);
  For i := 0 to 9 do
    begin
      SpinEdit := FindComponent('seSpeedUser' + IntToStr(i)) as TSpinEdit;
      If Assigned(SpinEdit) then SpinEdit.Value := Round(Settings.Speeds.User[i] / Coef);
    end;
finally
  fSpeedsChanging := False;
end;
end;

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

procedure TfMainForm.FormShow(Sender: TObject);
begin
SettingsToForm;
end;

procedure TfMainForm.FormCreate(Sender: TObject);
begin
sbStatusBar.DoubleBuffered := True;
fSpeedsChanging := False;
ACCManager.OnBindStateChange.Add(OnBindStateChange);
ACCManager.OnSpeedChange := SpeedsToForm;
end;

procedure TfMainForm.btnAboutClick(Sender: TObject);
begin
fAboutForm.ShowModal;
end;

procedure TfMainForm.seSpeedsChange(Sender: TObject);
var
  Coef:     Single;
  SpinEdit: TSpinEdit;
begin
If not fSpeedsChanging then
  begin
    Coef := Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient;
    If Coef = 0 then Coef := 1;
    If Sender is TSpinEdit then
      begin
        SpinEdit := Sender as TSpinEdit;
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

procedure TfMainForm.btnSpeedsClick(Sender: TObject);
begin
If Sender is TButton then
  ACCManager.ExecuteTrigger(nil,(Sender as TButton).Tag);
end;

procedure TfMainForm.cbUnitsChange(Sender: TObject);
begin
Settings.UsedSpeedUnit := cbUnits.ItemIndex;
SpeedsToForm(nil);
end;

procedure TfMainForm.btnSettingsClick(Sender: TObject);
begin
fSettingsForm.ShowModal;
end;

end.
