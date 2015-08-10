{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_PluginManager;

interface

{$INCLUDE ..\MainProgram\ACC_Defs.inc}

uses
  WinMsgComm, WinMsgCommServer,
  SCS_Telemetry_Condensed;

const
  PluginInstanceMutexName = 'ACC_IC_PLG_MTX_87F19E40-4CCB-4827-8039-47FB4B757AFF';

{==============================================================================}
{------------------------------------------------------------------------------}
{                              TACCPluginManager                               }
{------------------------------------------------------------------------------}
{==============================================================================}

type
  TACCPluginManager = class(TObject)
  private
    fInstanceMutex:   THandle;
    fAPIVersion:      scs_u32_t;
    fAPIParams:       scs_telemetry_init_params_t;
    fGameActive:      Boolean;
    fSpeedRegistered: Boolean;
    fCrConRegistered: Boolean;
    fLimitRegistered: Boolean;
    fTruckSpeed:      scs_float_t;
    fSpeedLimit:      scs_float_t;
    fFeatures:        LongWord;
    fLimitSending:    Boolean;
    fWMCServer:       TWinMsgCommServer;
  protected
    procedure WriteToGameLog(Text: String; MsgType: scs_log_type_t = SCS_LOG_TYPE_error); virtual;
    procedure RunMainProgram; virtual;
    procedure RegisterEvents; virtual;
    procedure RegisterChannels; virtual;
    procedure UnregisterEvents; virtual;
    procedure UnregisterChannels; virtual;
    procedure CheckFeatures; virtual;
    procedure WMCServer_OnValueRecived(Sender: TObject; SenderID: TWMCConnectionID; Value: TWMCMultiValue); virtual;
  public
    class Function InstanceAlreadyExists: Boolean; virtual;
    constructor Create(APIVersion: scs_u32_t; APIParams: scs_telemetry_init_params_t);
    destructor Destroy; override;
    procedure SetValue(Name: TelemetryString; {%H-}Index: scs_u32_t; Value: scs_value_t); virtual;
  end;

implementation

uses
  Windows, SysUtils, ShellAPI, Math, DefRegistry, WinFileInfo,
  ACC_Settings, ACC_PluginComm;

var
  ACC_PLG_VersionStr: String = '';
  ACC_PLG_BuildStr:   String = '';

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
procedure ChannelReceiver(name: scs_string_t; index: scs_u32_t; value: p_scs_value_t; context: scs_context_t); stdcall;
begin
If Assigned(context) and Assigned(value) then
  TACCPluginManager(context).SetValue(APIStringToTelemetryString(name),index,value^);
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
{$IFDEF Debug}
  ExecResult: Integer;
{$ENDIF}
begin
Registry := TDefRegistry.Create;
try
  Registry.RootKey := HKEY_CURRENT_USER;
  If Registry.OpenKeyReadOnly(SettingsRegistryKey) then
    begin
      ExecPath := Registry.ReadStringDef(SETN_VAL_REG_ProgramPath,'');
      If FileExists(ExecPath) then
        begin
        {$IFDEF Debug}
          ExecResult := Integer(ShellExecute(0,'open',PChar(ExecPath),nil,nil,SW_SHOWNORMAL));
          case ExecResult of
            0:                      WriteToGameLog('[ACC] Exec: The operating system is out of memory or resources');
          //ERROR_FILE_NOT_FOUND:   WriteToGameLog('[ACC] Exec: The specified file was not found');
          //ERROR_PATH_NOT_FOUND:   WriteToGameLog('[ACC] Exec: The specified path was not found');
            ERROR_BAD_FORMAT:       WriteToGameLog('[ACC] Exec: The .exe file is invalid');
            SE_ERR_ACCESSDENIED:    WriteToGameLog('[ACC] Exec: The operating system denied access to the specified file');
            SE_ERR_ASSOCINCOMPLETE: WriteToGameLog('[ACC] Exec: The file name association is incomplete or invalid');
            SE_ERR_DDEBUSY:         WriteToGameLog('[ACC] Exec: The DDE transaction could not be completed because other DDE transactions were being processed');
            SE_ERR_DDEFAIL:         WriteToGameLog('[ACC] Exec: The DDE transaction failed');
            SE_ERR_DDETIMEOUT:      WriteToGameLog('[ACC] Exec: The DDE transaction could not be completed because the request timed out');
            SE_ERR_DLLNOTFOUND:     WriteToGameLog('[ACC] Exec: The specified DLL was not found');
            SE_ERR_FNF:             WriteToGameLog('[ACC] Exec: The specified file was not found');
            SE_ERR_NOASSOC:         WriteToGameLog('[ACC] Exec: There is no application associated with the given file name extension');
            SE_ERR_OOM:             WriteToGameLog('[ACC] Exec: There was not enough memory to complete the operation');
            SE_ERR_PNF:             WriteToGameLog('[ACC] Exec: The specified path was not found');
            SE_ERR_SHARE:           WriteToGameLog('[ACC] Exec: A sharing violation occurred');
          else
            If ExecResult > 32 then WriteToGameLog('[ACC] Exec: Program started',SCS_LOG_TYPE_message)
              else WriteToGameLog(Format('[ACC] Exec: Unknown error (%d) occured',[ExecResult]));
          end;
        {$ELSE}
          ShellExecute(0,'open',PChar(ExecPath),nil,nil,SW_SHOWNORMAL);
        {$ENDIF}
        end
      else {$IFDEF Debug}WriteToGameLog('[ACC] Exec: File not found.'){$ENDIF};
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
    fSpeedRegistered := fAPIParams.register_for_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_speed),SCS_U32_NIL,SCS_VALUE_TYPE_float,SCS_TELEMETRY_CHANNEL_FLAG_none,ChannelReceiver,Self) = SCS_RESULT_ok;
    fCrConRegistered := fAPIParams.register_for_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_cruise_control),SCS_U32_NIL,SCS_VALUE_TYPE_float,SCS_TELEMETRY_CHANNEL_FLAG_none,ChannelReceiver,Self) = SCS_RESULT_ok;
    fLimitRegistered := fAPIParams.register_for_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_navigation_speed_limit),SCS_U32_NIL,SCS_VALUE_TYPE_float,SCS_TELEMETRY_CHANNEL_FLAG_none,ChannelReceiver,Self) = SCS_RESULT_ok;
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
    If fCrConRegistered then
      fAPIParams.unregister_from_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_cruise_control),SCS_U32_NIL,SCS_VALUE_TYPE_float);
    fCrConRegistered := False;
    If fLimitRegistered then
      fAPIParams.unregister_from_channel(APIString(SCS_TELEMETRY_TRUCK_CHANNEL_navigation_speed_limit),SCS_U32_NIL,SCS_VALUE_TYPE_float);
    fLimitRegistered := False;
  end;
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.CheckFeatures;
begin
fFeatures := 0;
If fSpeedRegistered then fFeatures := fFeatures or WMC_PF_Speed;
If fLimitRegistered and fCrConRegistered then fFeatures := fFeatures or WMC_PF_Limit;
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.WMCServer_OnValueRecived(Sender: TObject; SenderID: TWMCConnectionID; Value: TWMCMultiValue);
begin
case Value.UserCode of
  WMC_CODE_SpeedInc:    If fSpeedRegistered and (Value.ValueType = mvtSingle) then
                          fWMCServer.SendSingle((fTruckSpeed * 3.6) + Value.SingleValue,SenderID,WMC_CODE_SetCCSpeed);
  WMC_CODE_SpeedHome:   If fSpeedRegistered then
                          fWMCServer.SendSingle((fTruckSpeed * 3.6),SenderID,Value.UserCode);
  WMC_CODE_SpeedRoads:  If fSpeedRegistered then
                          fWMCServer.SendSingle((fTruckSpeed * 3.6),SenderID,Value.UserCode);
  WMC_CODE_SpeedUser0..
  WMC_CODE_SpeedUser9:  If fSpeedRegistered then
                          fWMCServer.SendSingle((fTruckSpeed * 3.6),SenderID,Value.UserCode);
  WMC_CODE_SetToLimit:  If fLimitRegistered then
                          fWMCServer.SendSingle((fSpeedLimit * 3.6),SenderID,WMC_CODE_SetToLimit);
  WMC_CODE_LimitStart:  If fLimitRegistered then
                          begin
                            fLimitSending := True;
                            fWMCServer.SendSingle(fSpeedLimit * 3.6,SenderID,WMC_CODE_LimitStart);
                          end;
  WMC_CODE_LimitStop:   begin
                          fLimitSending := False;
                          fWMCServer.SendInteger(0,0,WMC_CODE_LimitStop);
                        end;
  WMC_CODE_Features:    fWMCServer.SendLongWord(fFeatures,SenderID,WMC_CODE_Features);
end
end;

{------------------------------------------------------------------------------}
{   TACCPluginManager // Public methods                                        }
{------------------------------------------------------------------------------}

class Function TACCPluginManager.InstanceAlreadyExists: Boolean;
var
  Mutex:  THandle;
begin
Mutex := CreateMutex(nil,False,PluginInstanceMutexName);
Result := GetLastError = ERROR_ALREADY_EXISTS;
CloseHandle(Mutex);
end;

//------------------------------------------------------------------------------

constructor TACCPluginManager.Create(APIVersion: scs_u32_t; APIParams: scs_telemetry_init_params_t);
begin
inherited Create;
fInstanceMutex := CreateMutex(nil,False,PluginInstanceMutexName);
If GetLastError = ERROR_ALREADY_EXISTS then
  raise Exception.Create('TACCPluginManager.Create: At least one instance is already created.');
fAPIVersion := APIVersion;
fAPIParams := APIParams;
fGameActive := False;
RegisterEvents;
RegisterChannels;
CheckFeatures;
WriteToGameLog('[ACC] Plugin loaded (' + ACC_PLG_VersionStr + '  ' + ACC_PLG_BuildStr + ')',SCS_LOG_TYPE_message);
{$IFDEF Debug}
WriteToGameLog('[ACC] Features 0x' + IntToHex(fFeatures,8),SCS_LOG_TYPE_message);
{$ENDIF}
fLimitSending := False;
fWMCServer := TWinMsgCommServer.Create(nil,False,WMC_MessageName);
fWMCServer.OnValueReceived := WMCServer_OnValueRecived;
RunMainProgram;
end;

//------------------------------------------------------------------------------

destructor TACCPluginManager.Destroy;
begin
fWMCServer.Free;
UnregisterChannels;
UnregisterEvents;
CloseHandle(fInstanceMutex);
inherited;
end;

//------------------------------------------------------------------------------

procedure TACCPluginManager.SetValue(Name: TelemetryString; Index: scs_u32_t; Value: scs_value_t);
begin
If (Name = SCS_TELEMETRY_TRUCK_CHANNEL_speed) and (Value._type = SCS_VALUE_TYPE_float) then
  fTruckSpeed := Value.value_float.value
else If (Name = SCS_TELEMETRY_TRUCK_CHANNEL_cruise_control) and (Value._type = SCS_VALUE_TYPE_float) then
  begin
    If fLimitSending then
      If (Value.value_float.value <= 0) or ((fSpeedLimit <> 0) and not SameValue(Value.value_float.value,fSpeedLimit,0.25)) then
        begin
          fLimitSending := False;
          fWMCServer.SendInteger(0,0,WMC_CODE_LimitStop);
        end;
  end
else If (Name = SCS_TELEMETRY_TRUCK_CHANNEL_navigation_speed_limit) and (Value._type = SCS_VALUE_TYPE_float) then
  begin
    fSpeedLimit := Value.value_float.value;
    If fLimitSending then
      fWMCServer.SendSingle(fSpeedLimit * 3.6,0,WMC_CODE_SpeedLimit)
  end;
end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                          Version info initialization                         }
{------------------------------------------------------------------------------}
{==============================================================================}

procedure InitVersionInfo;
begin
with TWinFileInfo.Create(WFI_LS_LoadVersionInfo or WFI_LS_LoadFixedFileInfo or WFI_LS_DecodeFixedFileInfo) do
  begin
    ACC_PLG_VersionStr := IntToStr(VersionInfoFixedFileInfoDecoded.ProductVersionMembers.Major) + '.' +
                          IntToStr(VersionInfoFixedFileInfoDecoded.ProductVersionMembers.Minor) + '.' +
                          IntToStr(VersionInfoFixedFileInfoDecoded.ProductVersionMembers.Release);
    ACC_PLG_BuildStr := {$IFDEF FPC}'L'{$ELSE}'D'{$ENDIF}{$IFDEF x64}+ '64'{$ELSE}+ '32'{$ENDIF} +
                        ' #' + IntToStr(VersionInfoFixedFileInfoDecoded.FileVersionMembers.Build)
                        {$IFDEF Debug}+ ' debug'{$ENDIF};
    Free;
  end;
end;

//------------------------------------------------------------------------------

initialization
  InitVersionInfo;

end.

