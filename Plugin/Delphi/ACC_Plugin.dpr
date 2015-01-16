library ACC_Plugin;

uses
  Windows,
  ShellAPI,
  SysUtils,
  FloatHex in '..\..\MainProgram\Libs\FloatHex.pas',
  DefRegistry in '..\..\MainProgram\Libs\DefRegistry.pas',
  ACC_Settings in '..\..\MainProgram\ACC_Settings.pas',
  SCS_Telemetry_Condensed in '..\SCS_Telemetry_Condensed.pas';

{$R *.res}

Function TelemetryLibraryInit(version: scs_u32_t; params: p_scs_telemetry_init_params_t): scs_result_t; stdcall;
var
  Registry: TDefRegistry;
  ExecPath: String;
begin
Registry := TDefRegistry.Create;
try
  Registry.RootKey := HKEY_CURRENT_USER;
  If Registry.OpenKeyReadOnly(SettingsRegistryKey) then
    begin
      ExecPath := Registry.ReadStringDef(SETN_VAL_REG_ProgramPath,'');
      If FileExists(ExecPath) then
        ShellExecute(0,'open',PChar(ExecPath),nil,nil,SW_SHOWNORMAL);
      Registry.CloseKey;
    end
finally
  Registry.Free;
end;
Result := SCS_RESULT_ok;
end;

//------------------------------------------------------------------------------

procedure TelemetryLibraryFinal; stdcall;
begin
// nothing to do
end;

//------------------------------------------------------------------------------

exports
  TelemetryLibraryInit name 'scs_telemetry_init',
  TelemetryLibraryFinal name 'scs_telemetry_shutdown';

begin
end.
