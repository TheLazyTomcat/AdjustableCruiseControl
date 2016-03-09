{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
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
