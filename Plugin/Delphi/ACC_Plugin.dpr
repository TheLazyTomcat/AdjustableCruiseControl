{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
library ACC_Plugin;

{$INCLUDE ..\..\Source\ACC_Defs.inc} 

uses
  SysUtils,

  SCS_Telemetry_Condensed,

  ACC_Settings      in '..\..\Source\ACC_Settings.pas',
  ACC_PluginComm    in '..\..\Source\ACC_PluginComm.pas',
  ACC_PluginManager in '..\..\Source\ACC_PluginManager.pas';

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
