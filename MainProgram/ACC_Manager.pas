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
  MulticastEvent, UtilityWindow,
  ACC_InstanceControl, ACC_Settings, ACC_GamesData, ACC_TrayIcon,
  ACC_SplashScreen, ACC_ProcessBinder, ACC_MemoryOps, ACC_Input;

type
{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TACCManager                                  }
{------------------------------------------------------------------------------}
{==============================================================================}
  TACCManager = class(TObject)
  private
    fOnBindStateChange: TMulticastNotifyEvent;  
    fApplication:       TApplication;
    fUtilityWindow:     TUtilityWindow;
    fInstanceControl:   TInstanceControl;
    fSettingsManager:   TSettingsManager;
    fSplashScreen:      TSplashScreen;
    fGamesDataManager:  TGamesDataManager;
    fProcessBinder:     TProcessBinder;
    fMemoryOperator:    TMemoryOperator;
    fInputManager:      TInputManager;
    fTrayIcon:          TTrayIcon;
    fOnSpeedChange:     TNotifyEvent;
  protected
    procedure Application_OnMinimize(Sender: TObject); virtual;
    procedure ProcessBinder_OnStateChange(Sender: TObject); virtual;
    procedure ProcessBinder_OnGameUnbind(Sender: TObject); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Initialize(Application: TApplication); virtual;
    procedure BuildInputTriggers; virtual;
    procedure ExtractGamesData; virtual;
    procedure UpdateFromInternalGamesData; virtual;
    procedure Load; virtual;
    procedure Save; virtual;
    procedure SetCCSpeed(NewSpeed: Single); virtual;
    procedure IncreaseCCSpeed(Increment: Single); virtual;
    Function GameActive: Boolean; virtual;
    procedure ExecuteTrigger(Sender: TObject; Trigger: Integer; Caller: TTriggerCaller); virtual;
  published
    property OnBindStateChange: TMulticastNotifyEvent read fOnBindStateChange;  
    property InstanceControl: TInstanceControl read fInstanceControl;
    property SettingsManager: TSettingsManager read fSettingsManager;
    property GamesDataManager: TGamesDataManager read fGamesDataManager;
    property TrayIcon: TTrayIcon read fTrayIcon;
    property ProcessBinder: TProcessBinder read fProcessBinder;
    property MemoryOperator: TMemoryOperator read fMemoryOperator;
    property InputManager: TInputManager read fInputManager;
    property OnSpeedChange: TNotifyEvent read fOnSpeedChange write fOnSpeedChange;
  end;

var
  ACCManager: TACCMAnager;  

implementation

uses
  Windows, SysUtils,{$IFDEF FPC}InterfaceBase,{$ENDIF}
  ACC_Strings;

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

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TACCManager                                  }
{------------------------------------------------------------------------------}
{==============================================================================}

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

{------------------------------------------------------------------------------}
{   TACCManager // Public methods                                              }
{------------------------------------------------------------------------------}

constructor TACCManager.Create;
begin
inherited Create;
fOnBindStateChange := TMulticastNotifyEvent.Create(Self);
fUtilityWindow := TUtilityWindow.Create;
fInstanceControl := TInstanceControl.Create(fUtilityWindow,ACCSTR_IC_InstanceName);
fSettingsManager := TSettingsManager.Create(Addr(ACC_Settings.Settings));
fSplashScreen := nil;
fGamesDataManager := TGamesDataManager.Create;
fProcessBinder := TProcessBinder.Create(fUtilityWindow);
fProcessBinder.OnStateChange := ProcessBinder_OnStateChange;
fProcessBinder.OnGameUnbind := ProcessBinder_OnGameUnbind;
fMemoryOperator := TMemoryOperator.Create;
fInputManager := TInputManager.Create(fUtilityWindow);
fInputManager.DiscernKeyboardSides := Settings.DiscernKeyboardSides;
fInputManager.SoftKeyComboRecognition := Settings.SoftKeyComboRecognition;
fInputManager.OnTrigger := ExecuteTrigger;
end;

//------------------------------------------------------------------------------

destructor TACCManager.Destroy;
begin
fSplashScreen.Free;
fInputManager.Free;
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

procedure TACCManager.Initialize(Application: TApplication);
begin
fApplication := Application;
fApplication.OnMinimize := Application_OnMinimize;
SettingsManager.PreloadSettings;
fTrayIcon := TTrayIcon.Create(fUtilityWindow,fApplication);
If Settings.StartMinimized then
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
fProcessBinder.Start;
BuildInputTriggers;
end;

//------------------------------------------------------------------------------

procedure TACCManager.Save;
begin
ACCManager.SettingsManager.SaveToRegistry;
end;

//------------------------------------------------------------------------------

procedure TACCManager.SetCCSpeed(NewSpeed: Single);
begin
If fMemoryOperator.Active and (NewSpeed > 0) then
  begin
    If fMemoryOperator.WriteCCSpeed(NewSpeed) then
      fMemoryOperator.WriteCCStatus(True);
  end;
end;

//------------------------------------------------------------------------------

procedure TACCManager.IncreaseCCSpeed(Increment: Single);
var
  CurrentSpeed: Single;
  CCStatus:     Boolean;
begin
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
          If MemoryOperator.ReadVehicleSpeed(CurrentSpeed) then
            If fMemoryOperator.WriteCCSpeed(CurrentSpeed + Increment) then
              fMemoryOperator.WriteCCStatus(True);
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
      If fMemoryOperator.ReadVehicleSpeed(TempSpeed) then
        begin
          Settings.Speeds.City := TempSpeed;
          If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
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
      If fMemoryOperator.ReadVehicleSpeed(TempSpeed) then
        begin
          Settings.Speeds.Roads := TempSpeed;
          If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
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
      If fMemoryOperator.ReadVehicleSpeed(TempSpeed) then
        begin
          Settings.Speeds.User[Trigger - ACC_TRIGGER_UserVehicle_0] := TempSpeed;
          If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
        end;
    ACC_TRIGGER_UserCruise_0..    //--------------------------------------------
    ACC_TRIGGER_UserCruise_9:
      If fMemoryOperator.ReadCCStatus(TempState) then
        If TempState and fMemoryOperator.ReadCCSpeed(TempSpeed) then
          begin
            Settings.Speeds.User[Trigger - ACC_TRIGGER_UserCruise_0] := TempSpeed;
            If Assigned(fOnSpeedChange) then fOnSpeedChange(Self);
          end;
  end;
end;

end.
