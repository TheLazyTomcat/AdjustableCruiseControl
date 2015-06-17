program PluginInstaller;

uses
  Forms,
  DefRegistry in '..\..\MainProgram\Libs\DefRegistry.pas',
  WinFileInfo in '..\..\MainProgram\Libs\WinFileInfo.pas',

  SCS_Telemetry_Condensed in '..\..\Plugin\SCS_Telemetry_Condensed.pas',

  ACC_PluginInstaller in 'ACC_PluginInstaller.pas',
  ACC_PluginCheck     in 'ACC_PluginCheck.pas',

  MainForm        in 'MainForm.pas' {fMainForm},
  DescriptionForm in 'DescriptionForm.pas' {fDescriptionForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Plugin Installer';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.CreateForm(TfDescriptionForm, fDescriptionForm);
  Application.Run;
end.
