program PluginInstaller;

uses
  Forms,
  MainForm in 'MainForm.pas' {fMainForm},
  ACC_PluginInstaller in 'ACC_PluginInstaller.pas',
  DefRegistry in '..\..\MainProgram\Libs\DefRegistry.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Plugin Installer';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.Run;
end.
