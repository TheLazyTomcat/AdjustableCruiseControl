unit ACC_PluginManager;

interface

{$INCLUDE ..\MainProgram\ACC_Defs.inc}

uses
  SCS_Telemetry_Condensed;

{==============================================================================}
{------------------------------------------------------------------------------}
{                              TACCPluginManager                               }
{------------------------------------------------------------------------------}
{==============================================================================}

type
  TACCPluginManager = class(TObject)
  private
    fAPIVersion:      scs_u32_t;
    fAPIParams:       scs_telemetry_init_params_t;
    fGameActive:      Boolean;
    fSpeedRegistered: Boolean;
    fLimitRegistered: Boolean;
    fTruckSpeed:      scs_float_t;
    fSpeedLimit:      scs_float_t;
  protected
    procedure WriteToGameLog(Text: String; MsgType: scs_log_type_t = SCS_LOG_TYPE_error); virtual;
    procedure RunMainProgram; virtual;
    procedure RegisterEvents; virtual;
    procedure RegisterChannels; virtual;
    procedure UnregisterEvents; virtual;
    procedure UnregisterChannels; virtual;
  public
    constructor Create(APIVersion: scs_u32_t; APIParams: scs_telemetry_init_params_t);
    destructor Destroy; override;
  published
  end;

implementation

uses
  Windows, SysUtils, ShellAPI, DefRegistry, ACC_Settings;

{==============================================================================}
{------------------------------------------------------------------------------}
{                              TACCPluginManager                               }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TACCPluginManager // Callbacks                                             }
{------------------------------------------------------------------------------}

// Procedure used as library callback to receive events.
procedure EventReceiver(event: scs_event_t;{%H-}event_info: Pointer; context: scs_context_t); stdcall;
begin
If Assigned(context) then
  case event of
    SCS_TELEMETRY_EVENT_started:  Boolean(context^) := True;
    SCS_TELEMETRY_EVENT_paused:   Boolean(context^) := False;
  end;
end;

//------------------------------------------------------------------------------

// Procedure used as library callback to receive channels.
procedure ChannelReceiver({%H-}name: scs_string_t;{%H-}index: scs_u32_t; value: p_scs_value_t; context: scs_context_t); stdcall;
begin
If Assigned(context) and Assigned(value) then
  If value^._type = SCS_VALUE_TYPE_float then
    scs_float_t(context^) := value^.value_float.value;
end;


{------------------------------------------------------------------------------}
{   TACCPluginManager // Protected methods                                     }
{------------------------------------------------------------------------------}

procedure TACCPluginManager.WriteToGameLog(Text: String; MsgType: scs_log_type_t = SCS_LOG_TYPE_error);
begin
If Assigned(fAPIParams.common.log) then
  fAPIParams.common.log(MsgType,APIString(TelemetryStringEncode(Text)));
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.RunMainProgram;
var
  Registry:   TDefRegistry;
  ExecPath:   String;
  ExecResult: Integer;
begin
Registry := TDefRegistry.Create;
try
  Registry.RootKey := HKEY_CURRENT_USER;
  If Registry.OpenKeyReadOnly(SettingsRegistryKey) then
    begin
      ExecPath := Registry.ReadStringDef(SETN_VAL_REG_ProgramPath,'');
      If FileExists(ExecPath) then
        begin
          ExecResult := Integer(ShellExecute(0,'open',PChar(ExecPath),nil,nil,SW_SHOWNORMAL));
          case ExecResult of
            0:                      WriteToGameLog('[ACC] Exec: The operating system is out of memory or resources.');
          //ERROR_FILE_NOT_FOUND:   WriteToGameLog('[ACC] Exec: The specified file was not found.');
          //ERROR_PATH_NOT_FOUND:   WriteToGameLog('[ACC] Exec: The specified path was not found.');
            ERROR_BAD_FORMAT:       WriteToGameLog('[ACC] Exec: The .exe file is invalid.');
            SE_ERR_ACCESSDENIED:    WriteToGameLog('[ACC] Exec: The operating system denied access to the specified file.');
            SE_ERR_ASSOCINCOMPLETE: WriteToGameLog('[ACC] Exec: The file name association is incomplete or invalid.');
            SE_ERR_DDEBUSY:         WriteToGameLog('[ACC] Exec: The DDE transaction could not be completed because other DDE transactions were being processed.');
            SE_ERR_DDEFAIL:         WriteToGameLog('[ACC] Exec: The DDE transaction failed.');
            SE_ERR_DDETIMEOUT:      WriteToGameLog('[ACC] Exec: The DDE transaction could not be completed because the request timed out.');
            SE_ERR_DLLNOTFOUND:     WriteToGameLog('[ACC] Exec: The specified DLL was not found.');
            SE_ERR_FNF:             WriteToGameLog('[ACC] Exec: The specified file was not found.');
            SE_ERR_NOASSOC:         WriteToGameLog('[ACC] Exec: There is no application associated with the given file name extension.');
            SE_ERR_OOM:             WriteToGameLog('[ACC] Exec: There was not enough memory to complete the operation.');
            SE_ERR_PNF:             WriteToGameLog('[ACC] Exec: The specified path was not found.');
            SE_ERR_SHARE:           WriteToGameLog('[ACC] Exec: A sharing violation occurred.');
          else
            If ExecResult > 32 then WriteToGameLog('[ACC] Exec: Program executed.',SCS_LOG_TYPE_message)
              else WriteToGameLog(Format('[ACC] Exec: Unknown error (%d) occured.',[ExecResult]));
          end;
        end
      else WriteToGameLog('[ACC] Exec: File not found.');
      Registry.CloseKey;
    end
finally
  Registry.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.RegisterEvents;
begin
If Assigned(fAPIParams.register_for_event) then
  begin
    fAPIParams.register_for_event(SCS_TELEMETRY_EVENT_started,EventReceiver,Addr(fGameActive));
    fAPIParams.register_for_event(SCS_TELEMETRY_EVENT_paused,EventReceiver,Addr(fGameActive));
  end;
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.RegisterChannels;
begin
If Assigned(fAPIParams.register_for_channel) then
  begin
    fSpeedRegistered := fAPIParams.register_for_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_speed),SCS_U32_NIL,SCS_VALUE_TYPE_float,SCS_TELEMETRY_CHANNEL_FLAG_none,ChannelReceiver,Addr(fTruckSpeed)) = SCS_RESULT_ok;
    fLimitRegistered := fAPIParams.register_for_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_navigation_speed_limit),SCS_U32_NIL,SCS_VALUE_TYPE_float,SCS_TELEMETRY_CHANNEL_FLAG_none,ChannelReceiver,Addr(fSpeedLimit)) = SCS_RESULT_ok;
  end;
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.UnregisterEvents;
begin
If Assigned(fAPIParams.unregister_from_event) then
  begin
    fAPIParams.unregister_from_event(SCS_TELEMETRY_EVENT_started);
    fAPIParams.unregister_from_event(SCS_TELEMETRY_EVENT_paused);
  end;
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.UnregisterChannels;
begin
If Assigned(fAPIParams.unregister_from_channel) then
  begin
    If fSpeedRegistered then
      fAPIParams.unregister_from_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_speed),SCS_U32_NIL,SCS_VALUE_TYPE_float);
    fSpeedRegistered := False;
    If fLimitRegistered then
      fAPIParams.unregister_from_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_navigation_speed_limit),SCS_U32_NIL,SCS_VALUE_TYPE_float);
    fLimitRegistered := False;
  end;
end;

{------------------------------------------------------------------------------}
{   TACCPluginManager // Public methods                                        }
{------------------------------------------------------------------------------}

constructor TACCPluginManager.Create(APIVersion: scs_u32_t; APIParams: scs_telemetry_init_params_t);
begin
inherited Create;
fAPIVersion := APIVersion;
fAPIParams := APIParams;
fGameActive := False;
RegisterEvents;
RegisterChannels;
// create comm
RunMainProgram;
end;

//------------------------------------------------------------------------------

destructor TACCPluginManager.Destroy;
begin
// destroy comm
UnregisterChannels;
UnregisterEvents;
inherited;
end;

end.

