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
