{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
program RegistryCleaner;

uses
  Forms,
  MainForm in 'MainForm.pas' {fMainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Registry Cleaner';
  Application.CreateForm(TfMainForm, fMainForm);
  Application.Run;
end.
