library ACC_Plugin;

uses
  SysUtils,
  
  CRC32            in '..\..\MainProgram\Libs\CRC32.pas',
  FloatHex         in '..\..\MainProgram\Libs\FloatHex.pas',
  DefRegistry      in '..\..\MainProgram\Libs\DefRegistry.pas',
  MulticastEvent   in '..\..\MainProgram\Libs\MulticastEvent.pas',
  WndAlloc         in '..\..\MainProgram\Libs\WndAlloc.pas',
  UtilityWindow    in '..\..\MainProgram\Libs\UtilityWindow.pas',
  WinMsgComm       in '..\..\MainProgram\Libs\WMC\WinMsgComm.pas',
  WinMsgCommServer in '..\..\MainProgram\Libs\WMC\WinMsgCommServer.pas',

  SCS_Telemetry_Condensed in '..\SCS_Telemetry_Condensed.pas',

  ACC_Settings      in '..\..\MainProgram\ACC_Settings.pas',
  ACC_PluginComm    in '..\..\MainProgram\ACC_PluginComm.pas',
  ACC_PluginManager in '..\ACC_PluginManager.pas';

{$R *.res}

var
  PluginManager: TACCPluginManager = nil;

  //------------------------------------------------------------------------------

Function TelemetryLibraryInit(version: scs_u32_t; params: p_scs_telemetry_init_params_t): scs_result_t; stdcall;
begin
try
  If not Assigned(PluginManager) then
    begin
      If not TACCPluginManager.InstanceAlreadyExists then
        begin
          PluginManager := TACCPluginManager.Create(version,params^);
          Result := SCS_RESULT_ok;
        end
      else Result := SCS_RESULT_generic_error;
    end
  else Result := SCS_RESULT_ok;
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
