{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
program ACC;

{$INCLUDE '..\..\Source\ACC_Defs.inc'}

uses
  SysUtils,
  Forms,
  
  ACC_Common          in '..\..\Source\ACC_Common.pas',
  ACC_Strings         in '..\..\Source\ACC_Strings.pas',
  ACC_InstanceControl in '..\..\Source\ACC_InstanceControl.pas',
  ACC_TrayIcon        in '..\..\Source\ACC_TrayIcon.pas',
  ACC_Settings        in '..\..\Source\ACC_Settings.pas',
  ACC_GamesData       in '..\..\Source\ACC_GamesData.pas',
  ACC_SplashScreen    in '..\..\Source\ACC_SplashScreen.pas',
  ACC_ProcessBinder   in '..\..\Source\ACC_ProcessBinder.pas',
  ACC_MemoryOps       in '..\..\Source\ACC_MemoryOps.pas',
  ACC_Input           in '..\..\Source\ACC_Input.pas',
  ACC_Manager         in '..\..\Source\ACC_Manager.pas',
  ACC_PluginComm      in '..\..\Source\ACC_PluginComm.pas',

  MainForm           in '..\MainForm.pas' {fMainForm},
  AboutForm          in '..\AboutForm.pas' {fAboutForm},
  SettingsForm       in '..\SettingsForm.pas' {fSettingsForm},
  KeyBindForm        in '..\KeyBindForm.pas' {fKeyBindForm},
  SupportedGamesForm in '..\SupportedGamesForm.pas' {fSupportedGamesForm},
  UpdateForm         in '..\UpdateForm.pas' {fUpdateForm};


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
CheckStartedForUpdate;
ACCManager := TACCManager.Create(LoadingUpdate,UpdateFile);
try
  If ACCManager.InstanceControl.FirstInstance then
    begin
      Application.Initialize;
      Application.Title := 'Adjustable Cruise Control';
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
