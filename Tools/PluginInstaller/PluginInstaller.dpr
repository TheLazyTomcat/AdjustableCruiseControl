program PluginInstaller;

uses
  Forms,

  ACC_PluginInstaller in '..\..\Source\ACC_PluginInstaller.pas',
  ACC_PluginCheck     in '..\..\Source\ACC_PluginCheck.pas',

  MainForm        in 'MainForm.pas' {fMainForm},
  DescriptionForm in 'DescriptionForm.pas' {fDescriptionForm},
  LibraryForm     in 'LibraryForm.pas' {fLibraryForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Plugin Installer';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.CreateForm(TfDescriptionForm, fDescriptionForm);
  Application.CreateForm(TfLibraryForm, fLibraryForm);
  Application.Run;
end.
