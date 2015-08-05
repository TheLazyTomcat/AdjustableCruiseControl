program ACC;

{$INCLUDE ..\ACC_Defs.inc}

uses
  Interfaces, // this includes the LCL widgetset
  SysUtils,
  Forms,

  CRC32,
  MD5,
  WinRawInput,
  FloatHex,
  DefRegistry,
  SimpleCompress,
  StringEncryptionUnit,
  MulticastEvent,
  WndAlloc,
  UtilityWindow,
  SimpleTimer,
  BinTextEnc,
  WinFileInfo,
  WinMsgComm,
  WinMsgCommClient,

  SimpleLog,
  ACC_Log,

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
  ACC_PluginComm,

  MainForm,
  AboutForm,
  SettingsForm,
  KeyBindForm,
  SupportedGamesForm,
  UpdateForm;

{$R *.res}

var
  LoadingUpdate: Boolean = False;
  UpdateFile:    String = '';

  procedure CheckStartedForUpdate;
  begin
    If (ParamCount > 0) and FileExists(ParamStr(1)) then
      begin
        UpdateFile := ParamStr(1);
        LoadingUpdate := True;
      end;
  end;

begin
{$IFDEF Debug}
If FileExists(ExtractFilePath(ParamStr(0)) + 'heap.trc') then
  DeleteFile(ExtractFilePath(ParamStr(0)) + 'heap.trc');
SetHeapTraceOutput(ExtractFilePath(ParamStr(0)) + 'heap.trc');
{$ENDIF}
CheckStartedForUpdate;
ACCManager := TACCManager.Create(LoadingUpdate,UpdateFile);
try
  If ACCManager.InstanceControl.FirstInstance then
    begin
      RequireDerivedFormResource := True;
      Application.Initialize;
      Application.Title:='Adjustable Cruise Control';
      Application.CreateForm(TfMainForm, fMainForm);
      If LoadingUpdate then fMainForm.LoadUpdate(UpdateFile);
      Application.CreateForm(TfAboutForm, fAboutForm);
      Application.CreateForm(TfSettingsForm, fSettingsForm);
      Application.CreateForm(TfKeyBindForm, fKeyBindForm);
      Application.CreateForm(TfSupportedGamesForm, fSupportedGamesForm);
      Application.CreateForm(TfUpdateForm, fUpdateForm);
      ACCManager.OnLoadUpdate := fUpdateForm.LoadUpdateFromFile;
      ACCManager.Initialize(Application,LoadingUpdate);
      Application.Run;
      ACCManager.Save;
    end;
finally
  ACCManager.Free;
  UpdateFile := '';
end;
end.

