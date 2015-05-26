library ACC_Plugin;

{$INCLUDE ..\..\MainProgram\ACC_Defs.inc}

uses
  SysUtils,

  CRC32,
  FloatHex,
  DefRegistry,
  MulticastEvent,
  WndAlloc,
  UtilityWindow,
  WinMsgComm,
  WinMsgCommServer,

  SCS_Telemetry_Condensed,

  ACC_Settings,
  ACC_PluginComm,
  ACC_PluginManager;

{$R *.res}

var
  PluginManager: TACCPluginManager = nil;

  //------------------------------------------------------------------------------

Function TelemetryLibraryInit(version: scs_u32_t; params: p_scs_telemetry_init_params_t): scs_result_t; stdcall;
begin
try
  If not Assigned(PluginManager) then
    PluginManager := TACCPluginManager.Create(version,params^);
  Result := SCS_RESULT_ok;
except
  Result := SCS_RESULT_generic_error;
end;
end;

//------------------------------------------------------------------------------

procedure TelemetryLibraryFinal; stdcall;
begin
FreeAndNil(PluginManager);
end;

//------------------------------------------------------------------------------

exports
  TelemetryLibraryInit name 'scs_telemetry_init',
  TelemetryLibraryFinal name 'scs_telemetry_shutdown';

begin
end.

