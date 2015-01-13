program ACC;

{$INCLUDE ..\ACC_Defs.inc}

uses
  Interfaces, // this includes the LCL widgetset
  Forms,

  CRC32,
  MD5,
  WinRawInput,
  FloatHex,
  DefRegistry,
  SimpleCompress,
  StringEncryptionUnit,
  MulticastEvent,
  UtilityWindow,
  SimpleTimer,

  ACC_Common,
  ACC_Strings,
  ACC_InstanceControl,
  ACC_TrayIcon,
  ACC_Settings,
  ACC_GamesData,
  ACC_SplashScreen,
  ACC_ProcessBinder,
  ACC_MemoryOps,
  ACC_Input,
  ACC_Manager,

  MainForm,
  AboutForm,
  SettingsForm,
  KeyBindForm,
  SupportedGamesForm,
  UpdateForm;

{$R *.res}

begin
ACCManager := TACCManager.Create;
try
  If ACCManager.InstanceControl.FirstInstance then
    begin
      RequireDerivedFormResource := True;
      Application.Initialize;
      Application.Title:='Adjustable Cruise Control';
      Application.CreateForm(TfMainForm, fMainForm);
      Application.CreateForm(TfAboutForm, fAboutForm);
      Application.CreateForm(TfSettingsForm, fSettingsForm);
      Application.CreateForm(TfKeyBindForm, fKeyBindForm);
      Application.CreateForm(TfSupportedGamesForm, fSupportedGamesForm);
      Application.CreateForm(TfUpdateForm, fUpdateForm);
      ACCManager.Initialize(Application);
      Application.Run;
      ACCManager.Save;
    end;
finally
  ACCManager.Free;
end;
end.

