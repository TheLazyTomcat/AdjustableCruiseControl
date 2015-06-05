{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_Manager;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Classes, Forms,
  MulticastEvent, UtilityWindow, WinMsgComm, WinMsgCommClient,
  ACC_InstanceControl, ACC_Settings, ACC_GamesData, ACC_TrayIcon,
  ACC_SplashScreen, ACC_ProcessBinder, ACC_MemoryOps, ACC_Input;

type
  TLoadUpdateEvent = procedure(Sender: TObject; const UpdateFile: String) of object;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TACCManager                                  }
{------------------------------------------------------------------------------}
{==============================================================================}
  TACCManager = class(TObject)
  private
    fPluginFeatures:      LongWord;
    fKeepCCSpeedOnLimit:  Boolean;
    fOnBindStateChange:   TMulticastNotifyEvent;
    fApplication:         TApplication;
    fUtilityWindow:       TUtilityWindow;
    fInstanceControl:     TInstanceControl;
    fSettingsManager:     TSettingsManager;
    fSplashScreen:        TSplashScreen;
    fGamesDataManager:    TGamesDataManager;
    fProcessBinder:       TProcessBinder;
    fMemoryOperator:      TMemoryOperator;
    fInputManager:        TInputManager;
    fTrayIcon:            TTrayIcon;
    fWMCClient:           TWinMsgCommClient;
    fOnSpeedChange:       TNotifyEvent;
    fOnPluginStateChange: TNotifyEvent;
    fOnLoadUpdate:        TLoadUpdateEvent;
    Function GetPluginState: Boolean;
  protected
    procedure Application_OnMinimize(Sender: TObject); virtual;
    procedure InstaceControl_OnRestoreMessage(Sender: TObject; Parameter: Integer); virtual;
    procedure ProcessBinder_OnStateChange(Sender: TObject); virtual;
    procedure ProcessBinder_OnGameUnbind(Sender: TObject); virtual;
    procedure WMCClient_OnValueRecived(Sender: TObject; {%H-}SenderID: TWMCConnectionID; Value: TWMCMultiValue); virtual;
    procedure DoPluginStateChange(Sender: TObject); virtual;
  public
    constructor Create(LoadingUpdate: Boolean; const UpdateFile: String = '');
    destructor Destroy; override;
    procedure Initialize(Application: TApplication; LoadingUpdate: Boolean); virtual;
    procedure BuildInputTriggers; virtual;
    procedure ExtractGamesData; virtual;
    procedure UpdateFromInternalGamesData; virtual;
    procedure Load; virtual;
    procedure Save; virtual;
    procedure SetCCSpeed(NewSpeed: Single; DeactivateLimitSending: Boolean = True); virtual;
    procedure IncreaseCCSpeed(Increment: Single); virtual;
    Function GameActive: Boolean; virtual;
    procedure ExecuteTrigger(Sender: TObject; Trigger: Integer; Caller: TTriggerCaller); virtual;
  published
    property PluginFeatures: LongWord read fPluginFeatures;
    property OnBindStateChange: TMulticastNotifyEvent read fOnBindStateChange;  
    property InstanceControl: TInstanceControl read fInstanceControl;
    property SettingsManager: TSettingsManager read fSettingsManager;
    property GamesDataManager: TGamesDataManager read fGamesDataManager;
    property TrayIcon: TTrayIcon read fTrayIcon;
    property ProcessBinder: TProcessBinder read fProcessBinder;
    property MemoryOperator: TMemoryOperator read fMemoryOperator;
    property InputManager: TInputManager read fInputManager;
    property PluginOnline: Boolean read GetPluginState;
    property OnSpeedChange: TNotifyEvent read fOnSpeedChange write fOnSpeedChange;
    property OnPluginStateChange: TNotifyEvent read fOnPluginStateChange write fOnPluginStateChange;
    property OnLoadUpdate: TLoadUpdateEvent read fOnLoadUpdate write fOnLoadUpdate;
  end;

var
  ACCManager: TACCMAnager;  

implementation

uses
  Windows, SysUtils,{$IFDEF FPC}InterfaceBase,{$ENDIF}
  ACC_Strings, ACC_PluginComm;

{$R 'Resources\GamesData.res'}

const
  GamesDataResName = 'GamesData';

  ACC_TRIGGER_ArbitraryEngage = 0;

  ACC_TRIGGER_IncreaseByStep = 1;
  ACC_TRIGGER_DecreaseByStep = 2;
  ACC_TRIGGER_IncreaseByUnit = 3;
  ACC_TRIGGER_DecreaseByUnit = 4;
  ACC_TRIGGER_IncreaseStep   = 5;
  ACC_TRIGGER_DecreaseStep   = 6;

  ACC_TRIGGER_CityEngage  = 10;
  ACC_TRIGGER_CityVehicle = 11;
  ACC_TRIGGER_CityCruise  = 12;

  ACC_TRIGGER_RoadsEngage  = 15;
  ACC_TRIGGER_RoadsVehicle = 16;
  ACC_TRIGGER_RoadsCruise  = 17;

  ACC_TRIGGER_UserEngage_0 = 100;
  ACC_TRIGGER_UserEngage_9 = ACC_TRIGGER_UserEngage_0 + 9;

  ACC_TRIGGER_UserVehicle_0 = 200;
  ACC_TRIGGER_UserVehicle_9 = ACC_TRIGGER_UserVehicle_0 + 9;

  ACC_TRIGGER_UserCruise_0 = 300;
  ACC_TRIGGER_UserCruise_9 = ACC_TRIGGER_UserCruise_0 + 9;

  ACC_TRIGGER_SetToLimit  = 400;
  ACC_TRIGGER_KeepOnLimit = 401;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TACCManager                                  }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TACCManager // Private methods                                             }
{------------------------------------------------------------------------------}

Function TACCManager.GetPluginState: Boolean;
begin
Result := fWMCClient.ServerOnline;
end;

{------------------------------------------------------------------------------}
{   TACCManager // Protected methods                                           }
{------------------------------------------------------------------------------}

procedure TACCManager.Application_OnMinimize(Sender: TObject);
begin
If Settings.MinimizeToTray then
  begin
    TrayIcon.ShowTrayIcon;
    {$IFDEF FPC}
    ShowWindow(WidgetSet.AppHandle,SW_HIDE);
    {$ELSE}
    ShowWindow(fApplication.Handle,SW_HIDE);
    {$ENDIF}
  end;
end;

//------------------------------------------------------------------------------

procedure TACCManager.InstaceControl_OnRestoreMessage(Sender: TObject; Parameter: Integer);
var
  TempStr:  String;

  procedure DoRestore;
  begin
    If fTrayIcon.Visible then
      begin
        fApplication.Restore;
        fApplication.MainForm.Show;
        SetForegroundWindow(fApplication.MainForm.Handle);
        fTrayIcon.HideTrayIcon;
      end
    else
      begin
        fApplication.Restore;
        {$IFDEF FPC}
        SetForegroundWindow(WidgetSet.AppHandle);
        {$ELSE}
        SetForegroundWindow(fApplication.Handle);
        {$ENDIF}
      end;
  end;
  
begin
If Parameter = 1 then
  begin
    DoRestore;
    TempStr := fInstanceControl.ReadSharedString;
    If Assigned(fOnLoadUpdate) and FileExists(TempStr) then fOnLoadUpdate(Self,TempStr);
  end
else DoRestore;
end;

//------------------------------------------------------------------------------

procedure TACCManager.ProcessBinder_OnStateChange(Sender: TObject);
begin
If ProcessBinder.Binded then
  begin
    TrayIcon.SetTipText(ACCSTR_TI_DefaultTipText + sLineBreak + ProcessBinder.GameData.ExtendedTitle);
    fMemoryOperator.Activate(ProcessBinder.GameData);
    fInputManager.Mode := fInputManager.Mode + [omTrigger];
  end
else
  begin
    fKeepCCSpeedOnLimit := False;  
    TrayIcon.SetTipText(ACCSTR_TI_DefaultTipText);
    fMemoryOperator.Deactivate;
    fInputManager.Mode := fInputManager.Mode - [omTrigger];
  end;
fOnBindStateChange.Call(Self);
end;

//------------------------------------------------------------------------------

procedure TACCManager.ProcessBinder_OnGameUnbind(Sender: TObject);
begin
If Settings.CloseOnGameEnd then
  fApplication.MainForm.Close;
end;

//------------------------------------------------------------------------------

procedure TACCManager.WMCClient_OnValueRecived(Sender: TObject; SenderID: TWMCConnectionID; Value: TWMCMultiValue);
begin
case Value.UserCode of
  WMC_CODE_SetCCSpeed:  If Value.ValueType = mvtSingle then
                          SetCCSpeed(Value.SingleValue);
  WMC_CODE_SpeedHome:   If Value.ValueType = mvtSingle then
                          begin
                            Settings.Speeds.City := Value.SingleValue;
                            If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
                          end;
  WMC_CODE_SpeedRoads:  If Value.ValueType = mvtSingle then
                          begin
                            Settings.Speeds.Roads := Value.SingleValue;
                            If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
                          end;
  WMC_CODE_SpeedUser0..
  WMC_CODE_SpeedUser9:  If Value.ValueType = mvtSingle then
                          begin
                            Settings.Speeds.User[Value.UserCode - WMC_CODE_SpeedUser0] := Value.SingleValue;
                            If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
                          end;
  WMC_CODE_SetToLimit:  If Value.ValueType = mvtSingle then
                          begin
                            If Value.SingleValue = 0 then
                              case Settings.ZeroLimitAction of
                                0:  SetCCSpeed(0);
                                1:  SetCCSpeed(Settings.Speeds.LimitDefault);
                              end
                            else If Value.SingleValue > 0 then SetCCSpeed(Value.SingleValue)
                              else SetCCSpeed(0);
                          end;
  WMC_CODE_LimitStart:  If Value.ValueType = mvtSingle then
                          begin
                            fKeepCCSpeedOnLimit := True;
                            If Value.SingleValue = 0 then
                              case Settings.ZeroLimitAction of
                                0:  SetCCSpeed(0);
                                1:  SetCCSpeed(Settings.Speeds.LimitDefault,False);
                              end
                            else If Value.SingleValue > 0 then SetCCSpeed(Value.SingleValue,False)
                              else SetCCSpeed(0);
                          end;
  WMC_CODE_LimitStop:   fKeepCCSpeedOnLimit := False;
  WMC_CODE_SpeedLimit:  If (Value.ValueType = mvtSingle) and fKeepCCSpeedOnLimit then
                          begin
                            If Value.SingleValue = 0 then
                              case Settings.ZeroLimitAction of
                                0:  SetCCSpeed(0);
                                1:  SetCCSpeed(Settings.Speeds.LimitDefault,False);
                              end
                            else If Value.SingleValue > 0 then SetCCSpeed(Value.SingleValue,False)
                              else SetCCSpeed(0);
                          end
                        else fWMCClient.SendInteger(0,SenderID,WMC_CODE_LimitStop);
  WMC_CODE_Features:    If Value.ValueType = mvtLongWord then
                          begin
                            fPluginFeatures := Value.LongWordValue;
                            If Assigned(fOnPluginStateChange) then fOnPluginStateChange(Self);
                          end;
end;
end;

//------------------------------------------------------------------------------

procedure TACCManager.DoPluginStateChange(Sender: TObject);
begin
If not fWMCClient.ServerOnline then fKeepCCSpeedOnLimit := False;
If Assigned(fOnPluginStateChange) then fOnPluginStateChange(Self);
If fWMCClient.ServerOnline then fWMCClient.SendInteger(0,0,WMC_CODE_Features);
end;

{------------------------------------------------------------------------------}
{   TACCManager // Public methods                                              }
{------------------------------------------------------------------------------}

constructor TACCManager.Create(LoadingUpdate: Boolean; const UpdateFile: String = '');
begin
inherited Create;
fPluginFeatures := 0;
fKeepCCSpeedOnLimit := False;
fOnBindStateChange := TMulticastNotifyEvent.Create(Self);
fUtilityWindow := TUtilityWindow.Create;
fInstanceControl := TInstanceControl.Create(fUtilityWindow,ACCSTR_IC_InstanceName,LoadingUpdate,UpdateFile);
fSettingsManager := TSettingsManager.Create(Addr(ACC_Settings.Settings));
fSplashScreen := nil;
fGamesDataManager := TGamesDataManager.Create;
fProcessBinder := TProcessBinder.Create(fUtilityWindow);
fMemoryOperator := TMemoryOperator.Create;
fWMCClient := TWinMsgCommClient.Create(fUtilityWindow,False,WMC_MessageName);
fWMCClient.OnServerStatusChange := DoPluginStateChange;
fWMCClient.OnValueReceived := WMCClient_OnValueRecived;
fWMCClient.SendInteger(0,0,WMC_CODE_Features);
fInputManager := TInputManager.Create(fUtilityWindow);
end;

//------------------------------------------------------------------------------

destructor TACCManager.Destroy;
begin
fSplashScreen.Free;
fInputManager.Free;
fWMCClient.Free;
fInstanceControl.OnRestoreMessage := nil;
fTrayIcon.Free;
fMemoryOperator.Free;
fProcessBinder.Free;
fGamesDataManager.Free;
fSettingsManager.Free;
fInstanceControl.Free;
fUtilityWindow.Free;
fOnBindStateChange.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TACCManager.Initialize(Application: TApplication; LoadingUpdate: Boolean);
begin
fApplication := Application;
fApplication.OnMinimize := Application_OnMinimize;
SettingsManager.PreloadSettings;
fTrayIcon := TTrayIcon.Create(fUtilityWindow,fApplication);
fInstanceControl.OnRestoreMessage := InstaceControl_OnRestoreMessage;
If Settings.StartMinimized and not LoadingUpdate then
  begin
    fApplication.ShowMainForm := False;
    Load;
    TrayIcon.ShowTrayIcon;
  end
else
  begin
    If Settings.ShowSplashScreen then
      fSplashScreen := TSplashScreen.Create(fUtilityWindow,fApplication,Load)
    else
      Load;
  end;
end;

//------------------------------------------------------------------------------

procedure TACCManager.BuildInputTriggers;
var
  i:  Integer;
begin
fInputManager.AddTrigger(ACC_TRIGGER_IncreaseByStep,Settings.Inputs.IncreaseByStep);
fInputManager.AddTrigger(ACC_TRIGGER_DecreaseByStep,Settings.Inputs.DecreaseByStep);
fInputManager.AddTrigger(ACC_TRIGGER_IncreaseByUnit,Settings.Inputs.IncreaseByUnit);
fInputManager.AddTrigger(ACC_TRIGGER_DecreaseByUnit,Settings.Inputs.DecreaseByUnit);
fInputManager.AddTrigger(ACC_TRIGGER_IncreaseStep,Settings.Inputs.IncreaseStep);
fInputManager.AddTrigger(ACC_TRIGGER_DecreaseStep,Settings.Inputs.DecreaseStep);
fInputManager.AddTrigger(ACC_TRIGGER_CityEngage,Settings.Inputs.CityEngage);
fInputManager.AddTrigger(ACC_TRIGGER_CityVehicle,Settings.Inputs.CityVehicle);
fInputManager.AddTrigger(ACC_TRIGGER_CityCruise,Settings.Inputs.CityCruise);
fInputManager.AddTrigger(ACC_TRIGGER_RoadsEngage,Settings.Inputs.RoadsEngage);
fInputManager.AddTrigger(ACC_TRIGGER_RoadsVehicle,Settings.Inputs.RoadsVehicle);
fInputManager.AddTrigger(ACC_TRIGGER_RoadsCruise,Settings.Inputs.RoadsCruise);
For i := Low(Settings.Inputs.UserEngage) to High(Settings.Inputs.UserEngage) do
  fInputManager.AddTrigger(ACC_TRIGGER_UserEngage_0 + i,Settings.Inputs.UserEngage[i]);
For i := Low(Settings.Inputs.UserVehicle) to High(Settings.Inputs.UserVehicle) do
  fInputManager.AddTrigger(ACC_TRIGGER_UserVehicle_0 + i,Settings.Inputs.UserVehicle[i]);
For i := Low(Settings.Inputs.UserCruise) to High(Settings.Inputs.UserCruise) do
  fInputManager.AddTrigger(ACC_TRIGGER_UserCruise_0 + i,Settings.Inputs.UserCruise[i]);
fInputManager.AddTrigger(ACC_TRIGGER_SetToLimit,Settings.Inputs.SetToLimit);
fInputManager.AddTrigger(ACC_TRIGGER_KeepOnLimit,Settings.Inputs.KeepOnLimit);
end;

//------------------------------------------------------------------------------

procedure TACCManager.ExtractGamesData;
var
  ResourceStream: TResourceStream;
  FileName:       String;
begin
ResourceStream := TResourceStream.Create(hInstance,GamesDataResName,RT_RCDATA);
try
  FileName := ExtractFilePath(ParamStr(0)) + GamesDataFileBin;
  If DirectoryExists(ExtractFileDir(FileName)) or CreateDir(ExtractFileDir(FileName)) then
    ResourceStream.SaveToFile(FileName);
finally
  ResourceStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TACCManager.UpdateFromInternalGamesData;
var
  ResourceStream:     TResourceStream;
  UpdateDataManager:  TGamesDataManager;
  i:                  Integer;
begin
ResourceStream := TResourceStream.Create(hInstance,GamesDataResName,RT_RCDATA);
try
  UpdateDataManager := TGamesDataManager.Create;
  try
    UpdateDataManager.LoadFromBin(ResourceStream);
    UpdateDataManager.CheckUpdate(fGamesDataManager);
    For i := 0 to Pred(UpdateDataManager.GamesDataCount) do
      If UpdateDataManager[i].UpdateInfo.Add then
        begin
          fGamesDataManager.UpdateFrom(UpdateDataManager);
          fGamesDataManager.Save;
          Break;
        end;
  finally
    UpdateDataManager.Free;
  end;
finally
  ResourceStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TACCManager.Load;
begin
If not SettingsManager.LoadFromRegistry then
  SettingsManager.InitSettings;
If not GamesDataManager.Load then
  begin
    ExtractGamesData;
    GamesDataManager.Load;
  end
else UpdateFromInternalGamesData;
fProcessBinder.SetGamesData(GamesDataManager.GamesData);
fProcessBinder.OnStateChange := ProcessBinder_OnStateChange;
fProcessBinder.OnGameUnbind := ProcessBinder_OnGameUnbind;
fProcessBinder.Start;
fInputManager.DiscernKeyboardSides := Settings.DiscernKeyboardSides;
fInputManager.SoftKeyComboRecognition := Settings.SoftKeyComboRecognition;
fInputManager.OnTrigger := ExecuteTrigger;
BuildInputTriggers;
end;

//------------------------------------------------------------------------------

procedure TACCManager.Save;
begin
ACCManager.SettingsManager.SaveToRegistry;
end;

//------------------------------------------------------------------------------

procedure TACCManager.SetCCSpeed(NewSpeed: Single; DeactivateLimitSending: Boolean = True);
begin
If DeactivateLimitSending or (NewSpeed <= 0) then
  begin
    fWMCClient.SendInteger(0,0,WMC_CODE_LimitStop);
    fKeepCCSpeedOnLimit := False;
  end;
If fMemoryOperator.Active then
  begin
    If NewSpeed > 0 then
      begin
        If fMemoryOperator.WriteCCSpeed(NewSpeed) then
          fMemoryOperator.WriteCCStatus(True);
      end
    else fMemoryOperator.WriteCCStatus(False);
  end;
end;

//------------------------------------------------------------------------------

procedure TACCManager.IncreaseCCSpeed(Increment: Single);
var
  CurrentSpeed: Single;
  CCStatus:     Boolean;
begin
fWMCClient.SendInteger(0,0,WMC_CODE_LimitStop);
fKeepCCSpeedOnLimit := False;
If fMemoryOperator.Active and (Increment <> 0) then
  If fMemoryOperator.ReadCCStatus(CCStatus) then
    begin
      If CCStatus then
        begin
          If fMemoryOperator.ReadCCSpeed(CurrentSpeed) then
            If fMemoryOperator.WriteCCSpeed(CurrentSpeed + Increment) then
              fMemoryOperator.WriteCCStatus(True);
        end
      else
        begin
          case fGamesDataManager.TruckSpeedSupported(fMemoryOperator.GameData) of
            ssrDirect:  If fMemoryOperator.ReadVehicleSpeed(CurrentSpeed) then
                          If fMemoryOperator.WriteCCSpeed(CurrentSpeed + Increment) then
                            fMemoryOperator.WriteCCStatus(True);
            ssrPlugin:  fWMCClient.SendSingle(Increment,0,WMC_CODE_SpeedInc);
          end;
        end;
    end;
end;

//------------------------------------------------------------------------------

Function TACCManager.GameActive: Boolean;
var
  WindowPID:  LongWord;
begin
If fProcessBinder.Binded then
  begin
    GetWindowThreadProcessID(GetForegroundWindow,{%H-}WindowPID);
    Result := WindowPID = fProcessBinder.GameData.ProcessInfo.ProcessID;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TACCManager.ExecuteTrigger(Sender: TObject; Trigger: Integer; Caller: TTriggerCaller);
var
  TempSpeed:  Single;
  TempState:  Boolean;
begin
If (Caller <> tcInput) or (GameActive or not Settings.GameActiveForTrigger) then
  case Trigger of
    ACC_TRIGGER_ArbitraryEngage:  //--------------------------------------------
      SetCCSpeed(Settings.Speeds.Arbitrary);
    ACC_TRIGGER_IncreaseByStep:   //--------------------------------------------
      IncreaseCCSpeed(Settings.Speeds.Step);
    ACC_TRIGGER_DecreaseByStep:   //--------------------------------------------
      IncreaseCCSpeed(-Settings.Speeds.Step);
    ACC_TRIGGER_IncreaseByUnit:   //--------------------------------------------
      IncreaseCCSpeed(Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient);
    ACC_TRIGGER_DecreaseByUnit:   //--------------------------------------------
      IncreaseCCSpeed(-Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient);
    ACC_TRIGGER_IncreaseStep:     //--------------------------------------------
      begin
        Settings.Speeds.Step := Settings.Speeds.Step + Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient;
        If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
      end;
    ACC_TRIGGER_DecreaseStep:     //--------------------------------------------
      begin
        Settings.Speeds.Step := Settings.Speeds.Step - Settings.SpeedUnits[Settings.UsedSpeedUnit].Coefficient;
        If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
      end;
    ACC_TRIGGER_CityEngage:       //--------------------------------------------
      SetCCSpeed(Settings.Speeds.City);
    ACC_TRIGGER_CityVehicle:      //--------------------------------------------
      case fGamesDataManager.TruckSpeedSupported(fMemoryOperator.GameData) of
        ssrDirect:  If fMemoryOperator.ReadVehicleSpeed(TempSpeed) then
                      begin
                        Settings.Speeds.City := TempSpeed;
                        If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
                      end;
        ssrPlugin:  fWMCClient.SendInteger(0,0,WMC_CODE_SpeedHome);
      end;
    ACC_TRIGGER_CityCruise:       //--------------------------------------------
      If fMemoryOperator.ReadCCSpeed(TempSpeed) then
        begin
          Settings.Speeds.City := TempSpeed;
          If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
        end;
    ACC_TRIGGER_RoadsEngage:      //--------------------------------------------
      SetCCSpeed(Settings.Speeds.Roads);
    ACC_TRIGGER_RoadsVehicle:     //--------------------------------------------
      case fGamesDataManager.TruckSpeedSupported(fMemoryOperator.GameData) of
        ssrDirect:  If fMemoryOperator.ReadVehicleSpeed(TempSpeed) then
                      begin
                        Settings.Speeds.Roads := TempSpeed;
                        If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
                      end;
        ssrPlugin:  fWMCClient.SendInteger(0,0,WMC_CODE_SpeedRoads);
      end;
    ACC_TRIGGER_RoadsCruise:      //--------------------------------------------
      If fMemoryOperator.ReadCCSpeed(TempSpeed) then
        begin
          Settings.Speeds.Roads := TempSpeed;
          If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
        end;
    ACC_TRIGGER_UserEngage_0..    //--------------------------------------------
    ACC_TRIGGER_UserEngage_9:
      SetCCSpeed(Settings.Speeds.User[Trigger - ACC_TRIGGER_UserEngage_0]);
    ACC_TRIGGER_UserVehicle_0..   //--------------------------------------------
    ACC_TRIGGER_UserVehicle_9:
      case fGamesDataManager.TruckSpeedSupported(fMemoryOperator.GameData) of
        ssrDirect:  If fMemoryOperator.ReadVehicleSpeed(TempSpeed) then
                      begin
                        Settings.Speeds.User[Trigger - ACC_TRIGGER_UserVehicle_0] := TempSpeed;
                        If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
                      end;
        ssrPlugin:  fWMCClient.SendInteger(0,0,WMC_CODE_SpeedUser0 + (Trigger - ACC_TRIGGER_UserVehicle_0));
      end;
    ACC_TRIGGER_UserCruise_0..    //--------------------------------------------
    ACC_TRIGGER_UserCruise_9:
      If fMemoryOperator.ReadCCStatus(TempState) then
        If TempState and fMemoryOperator.ReadCCSpeed(TempSpeed) then
          begin
            Settings.Speeds.User[Trigger - ACC_TRIGGER_UserCruise_0] := TempSpeed;
            If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
          end;
    ACC_TRIGGER_SetToLimit:       //--------------------------------------------
       fWMCClient.SendInteger(0,0,WMC_CODE_SetToLimit);
    ACC_TRIGGER_KeepOnLimit:      //--------------------------------------------
      begin
        If fKeepCCSpeedOnLimit then
          begin
            fKeepCCSpeedOnLimit := False;
            fWMCClient.SendInteger(0,0,WMC_CODE_LimitStop);
            SetCCSpeed(0);
          end
        else fWMCClient.SendInteger(0,0,WMC_CODE_LimitStart);
      end;
  end;
end;

end.
