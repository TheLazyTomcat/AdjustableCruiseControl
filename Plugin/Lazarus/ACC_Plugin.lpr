library ACC_Plugin;

{$mode objfpc}{$H+}

uses
  Windows,
  ShellAPI,
  SysUtils,
  FloatHex,
  DefRegistry,
  ACC_Settings,
  SCS_Telemetry_Condensed
  { you can add units after this };

{$R *.res}

Function TelemetryLibraryInit({%H-}version: scs_u32_t;{%H-}params: p_scs_telemetry_init_params_t): scs_result_t; stdcall;
var
  Registry:   TDefRegistry;
  ExecPath:   String;
  ExecResult: Integer;

  procedure WriteToLog(const ErrorText: String; MsgType: scs_log_type_t = SCS_LOG_TYPE_error);
  begin
    params^.common.log(MsgType,PUTF8Char(ErrorText));
  end;

begin
Registry := TDefRegistry.Create;
try
  Registry.RootKey := HKEY_CURRENT_USER;
  If Registry.OpenKeyReadOnly(SettingsRegistryKey) then
    begin
      ExecPath := Registry.ReadStringDef(SETN_VAL_REG_ProgramPath,'');
      If FileExists(ExecPath) then
        begin
          ExecResult := ShellExecute(0,'open',PChar(ExecPath),nil,nil,SW_SHOWNORMAL);
          case ExecResult of
            0:                      WriteToLog('[ACC] Exec: The operating system is out of memory or resources.');
          //ERROR_FILE_NOT_FOUND:   WriteToLog('[ACC] Exec: The specified file was not found.');
          //ERROR_PATH_NOT_FOUND:   WriteToLog('[ACC] Exec: The specified path was not found.');
            ERROR_BAD_FORMAT:       WriteToLog('[ACC] Exec: The .exe file is invalid.');
            SE_ERR_ACCESSDENIED:    WriteToLog('[ACC] Exec: The operating system denied access to the specified file.');
            SE_ERR_ASSOCINCOMPLETE: WriteToLog('[ACC] Exec: The file name association is incomplete or invalid.');
            SE_ERR_DDEBUSY:         WriteToLog('[ACC] Exec: The DDE transaction could not be completed because other DDE transactions were being processed.');
            SE_ERR_DDEFAIL:         WriteToLog('[ACC] Exec: The DDE transaction failed.');
            SE_ERR_DDETIMEOUT:      WriteToLog('[ACC] Exec: The DDE transaction could not be completed because the request timed out.');
            SE_ERR_DLLNOTFOUND:     WriteToLog('[ACC] Exec: The specified DLL was not found.');
            SE_ERR_FNF:             WriteToLog('[ACC] Exec: The specified file was not found.');
            SE_ERR_NOASSOC:         WriteToLog('[ACC] Exec: There is no application associated with the given file name extension.');
            SE_ERR_OOM:             WriteToLog('[ACC] Exec: There was not enough memory to complete the operation.');
            SE_ERR_PNF:             WriteToLog('[ACC] Exec: The specified path was not found.');
            SE_ERR_SHARE:           WriteToLog('[ACC] Exec: A sharing violation occurred.');
          else
            If ExecResult > 32 then WriteToLog('[ACC] Exec: Program executed.',SCS_LOG_TYPE_message)
              else WriteToLog(Format('[ACC] Exec: Unknown error (%d) occured.',[ExecResult]));
          end;
        end
      else WriteToLog('[ACC] Exec: File not found.');
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

