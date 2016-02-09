program PluginInstaller;

uses
  Forms,
  SCS_Telemetry_Condensed in '..\..\Plugin\SCS_Telemetry_Condensed.pas',
  ACC_PluginInstaller in 'ACC_PluginInstaller.pas',
  ACC_PluginCheck in 'ACC_PluginCheck.pas',
  MainForm in 'MainForm.pas' {fMainForm},
  DescriptionForm in 'DescriptionForm.pas' {fDescriptionForm},
  LibraryForm in 'LibraryForm.pas' {fLibraryForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Plugin Installer';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.CreateForm(TfDescriptionForm, fDescriptionForm);
  Application.CreateForm(TfLibraryForm, fLibraryForm);
  Application.Run;
end.
