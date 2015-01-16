library ACC_Plugin;

{$mode objfpc}{$H+}

uses
  Windows,
  SysUtils,
  FloatHex,
  DefRegistry,
  ACC_Settings,
  SCS_Telemetry_Condensed
  { you can add units after this };

{$R *.res}

Function TelemetryLibraryInit({%H-}version: scs_u32_t;{%H-}params: p_scs_telemetry_init_params_t): scs_result_t; stdcall;
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

