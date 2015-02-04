{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_Settings;

interface

{$INCLUDE ACC_Defs.inc}

const
  // Registry key path used for program settings storing
  SettingsRegistryKey = '\Software\NcS Soft\Adjustable Cruise Control 2';
  
//------------------------------------------------------------------------------  
  
  // Names of individual settings values and groups
  SETN_GRP_General    = 'General';
  SETN_GRP_Timers     = 'Timers';
  SETN_GRP_SpeedUnits = 'SpeedUnits';
  SETN_GRP_Speeds     = 'Speeds';
  SETN_GRP_Inputs     = 'Inputs';

  SETN_VAL_ProgramPath             = 'ProgramPath';
  SETN_VAL_ShowSplashScreen        = 'ShowSplashScreen';
  SETN_VAL_MinimizeToTray          = 'MinimizeToTray';
  SETN_VAL_StartMinimized          = 'StartMinimized';
  SETN_VAL_CloseOnGameEnd          = 'CloseOnGameEnd';
  SETN_VAL_DiscernKeyboardSides    = 'DiscernKeyboardSides';
  SETN_VAL_SoftKeyComboRecognition = 'SoftKeyComboRecognition';  
  SETN_VAL_UsedSpeedUnit           = 'UsedSpeedUnit';

  SETN_VAL_TMR_ProcessBinderScanInterval = 'ProcessBinderScanInterval';
  SETN_VAL_TMR_ModulesLoadTimeout        = 'ModulesLoadTimeout';

  SETN_VAL_SPU_Count       = 'SpeedUnits';
  SETN_VAL_SPU_Name        = 'SpeedUnit[%d].Name';
  SETN_VAL_SPU_Coefficient = 'SpeedUnit[%d].Coefficient';

  SETN_VAL_SPD_Step      = 'Step';
  SETN_VAL_SPD_City      = 'City';
  SETN_VAL_SPD_Roads     = 'Roads';
  SETN_VAL_SPD_Arbitrary = 'Arbitrary';
  SETN_VAL_SPD_User      = 'User[%d]';

  SETN_VAL_INP_IncreaseByStep = 'IncreaseByStep';
  SETN_VAL_INP_DecreaseByStep = 'DecreaseByStep';
  SETN_VAL_INP_IncreaseByUnit = 'IncreaseByUnit';
  SETN_VAL_INP_DecreaseByUnit = 'DecreaseByUnit';
  SETN_VAL_INP_IncreaseStep   = 'IncreaseStep';
  SETN_VAL_INP_DecreaseStep   = 'DecreaseStep';
  SETN_VAL_INP_CityEngage     = 'CityEngage';
  SETN_VAL_INP_CityVehicle    = 'CityVehicle';
  SETN_VAL_INP_CityCruise     = 'CityCruise';
  SETN_VAL_INP_RoadsEngage    = 'RoadsEngage';
  SETN_VAL_INP_RoadsVehicle   = 'RoadsVehicle';
  SETN_VAL_INP_RoadsCruise    = 'RoadsCruise';
  SETN_VAL_INP_UserEngage     = 'UserEngage[%d]';
  SETN_VAL_INP_UserVehicle    = 'UserVehicle[%d]';
  SETN_VAL_INP_UserCruise     = 'UserCruise[%d]';

  SETN_VAL_REG_ProgramPath             = SETN_GRP_General + '.' + SETN_VAL_ProgramPath;
  SETN_VAL_REG_ShowSplashScreen        = SETN_GRP_General + '.' + SETN_VAL_ShowSplashScreen;
  SETN_VAL_REG_MinimizeToTray          = SETN_GRP_General + '.' + SETN_VAL_MinimizeToTray;
  SETN_VAL_REG_StartMinimized          = SETN_GRP_General + '.' + SETN_VAL_StartMinimized;
  SETN_VAL_REG_CloseOnGameEnd          = SETN_GRP_General + '.' + SETN_VAL_CloseOnGameEnd;
  SETN_VAL_REG_DiscernKeyboardSides    = SETN_GRP_General + '.' + SETN_VAL_DiscernKeyboardSides;
  SETN_VAL_REG_SoftKeyComboRecognition = SETN_GRP_General + '.' + SETN_VAL_SoftKeyComboRecognition;
  SETN_VAL_REG_UsedSpeedUnit           = SETN_GRP_General + '.' + SETN_VAL_UsedSpeedUnit;

  SETN_VAL_TMR_REG_ProcessBinderScanInterval = SETN_GRP_Timers + '.' + SETN_VAL_TMR_ProcessBinderScanInterval;
  SETN_VAL_TMR_REG_ModulesLoadTimeout        = SETN_GRP_Timers + '.' + SETN_VAL_TMR_ModulesLoadTimeout;

  SETN_VAL_REG_SPU_Count       = SETN_GRP_SpeedUnits + '.' + SETN_VAL_SPU_Count;
  SETN_VAL_REG_SPU_Name        = SETN_GRP_SpeedUnits + '.' + SETN_VAL_SPU_Name;
  SETN_VAL_REG_SPU_Coefficient = SETN_GRP_SpeedUnits + '.' + SETN_VAL_SPU_Coefficient;

  SETN_VAL_REG_SPD_Step      = SETN_GRP_Speeds + '.' + SETN_VAL_SPD_Step;
  SETN_VAL_REG_SPD_City      = SETN_GRP_Speeds + '.' + SETN_VAL_SPD_City;
  SETN_VAL_REG_SPD_Roads     = SETN_GRP_Speeds + '.' + SETN_VAL_SPD_Roads;
  SETN_VAL_REG_SPD_Arbitrary = SETN_GRP_Speeds + '.' + SETN_VAL_SPD_Arbitrary;
  SETN_VAL_REG_SPD_User      = SETN_GRP_Speeds + '.' + SETN_VAL_SPD_User;

  SETN_VAL_REG_INP_IncreaseByStep = SETN_GRP_Inputs + '.' + SETN_VAL_INP_IncreaseByStep;
  SETN_VAL_REG_INP_DecreaseByStep = SETN_GRP_Inputs + '.' + SETN_VAL_INP_DecreaseByStep;
  SETN_VAL_REG_INP_IncreaseByUnit = SETN_GRP_Inputs + '.' + SETN_VAL_INP_IncreaseByUnit;
  SETN_VAL_REG_INP_DecreaseByUnit = SETN_GRP_Inputs + '.' + SETN_VAL_INP_DecreaseByUnit;
  SETN_VAL_REG_INP_IncreaseStep   = SETN_GRP_Inputs + '.' + SETN_VAL_INP_IncreaseStep;
  SETN_VAL_REG_INP_DecreaseStep   = SETN_GRP_Inputs + '.' + SETN_VAL_INP_DecreaseStep;
  SETN_VAL_REG_INP_CityEngage     = SETN_GRP_Inputs + '.' + SETN_VAL_INP_CityEngage;
  SETN_VAL_REG_INP_CityVehicle    = SETN_GRP_Inputs + '.' + SETN_VAL_INP_CityVehicle;
  SETN_VAL_REG_INP_CityCruise     = SETN_GRP_Inputs + '.' + SETN_VAL_INP_CityCruise;
  SETN_VAL_REG_INP_RoadsEngage    = SETN_GRP_Inputs + '.' + SETN_VAL_INP_RoadsEngage;
  SETN_VAL_REG_INP_RoadsVehicle   = SETN_GRP_Inputs + '.' + SETN_VAL_INP_RoadsVehicle;
  SETN_VAL_REG_INP_RoadsCruise    = SETN_GRP_Inputs + '.' + SETN_VAL_INP_RoadsCruise;
  SETN_VAL_REG_INP_UserEngage     = SETN_GRP_Inputs + '.' + SETN_VAL_INP_UserEngage;
  SETN_VAL_REG_INP_UserVehicle    = SETN_GRP_Inputs + '.' + SETN_VAL_INP_UserVehicle;
  SETN_VAL_REG_INP_UserCruise     = SETN_GRP_Inputs + '.' + SETN_VAL_INP_UserCruise;

  SETN_SUF_PrimaryKey = '.PrimaryKey';
  SETN_SUF_ShiftKey   = '.ShiftKey';
  
//------------------------------------------------------------------------------  

type
  // Structures used to hold program settings
  TSpeedUnit = record
    Name:         String;
    Coefficient:  Single;
  end;

  TSpeeds = record
    Step:       Single;
    City:       Single;
    Roads:      Single;
    User:       Array[0..9] of Single;
    Arbitrary:  Single;
  end;

  TInput = record
    PrimaryKey: Integer;
    ShiftKey:   Integer;
  end;

  TInputs = record
    IncreaseByStep: TInput;
    DecreaseByStep: TInput;
    IncreaseByUnit: TInput;
    DecreaseByUnit: TInput;
    IncreaseStep:   TInput;
    DecreaseStep:   TInput;
    CityEngage:     TInput;
    CityVehicle:    TInput;
    CityCruise:     TInput;
    RoadsEngage:    TInput;
    RoadsVehicle:   TInput;
    RoadsCruise:    TInput;
    UserEngage:     Array[0..9] of TInput;
    UserVehicle:    Array[0..9] of TInput;
    UserCruise:     Array[0..9] of TInput;
  end;

  TSettings = record
    ProgramPath:                String;
    ShowSplashScreen:           Boolean;
    MinimizeToTray:             Boolean;
    StartMinimized:             Boolean;
    CloseOnGameEnd:             Boolean;
    DiscernKeyboardSides:       Boolean;
    SoftKeyComboRecognition:    Boolean;
    UsedSpeedUnit:              Integer;    
    ProcessBinderScanInterval:  Integer;
    ModulesLoadTimeout:         Integer;
    SpeedUnits:                 Array of TSpeedUnit;
    Speeds:                     TSpeeds;
    Inputs:                     TInputs;
  end;
  PSettings = ^TSettings;

{==============================================================================}
{------------------------------------------------------------------------------}
{                               TSettingsManager                               }
{------------------------------------------------------------------------------}
{==============================================================================}
  TSettingsManager = class(TObject)
  private
    fSettings: PSettings;
    Function GetInput(Index: Integer): TInput;
    procedure SetInput(Index: Integer; Value: TInput);
  public
    constructor Create(SettingsVariable: PSettings);
    procedure ValidateSettings;
    procedure InitSettings;
    procedure PreloadSettings;
    Function LoadFromRegistry: Boolean;
    Function SaveToRegistry: Boolean;
    Function LoadFromIni(const FileName: String): Boolean;
    Function SaveToIni(const FileName: String): Boolean;
    Function InputConflict(Input: TInput; InputIndex: Integer; out ConflictingInputIndex: Integer): Boolean; virtual;
    property Inputs[Index: Integer]: TInput read GetInput write SetInput;
  end;

var
  // Variable used to hold settings for the program
  // Why it is not part of settings manager is for a longer discussion.
  Settings: TSettings;

implementation

uses
  Windows, SysUtils, IniFiles,
  DefRegistry, FloatHex;  

const
  // Default program settings
  def_Settings: TSettings = (
    ProgramPath:                '';
    ShowSplashScreen:           True;
    MinimizeToTray:             True;
    StartMinimized:             False;
    CloseOnGameEnd:             False;
    DiscernKeyboardSides:       False;
    SoftKeyComboRecognition:    True;
    UsedSpeedUnit:              0;
    ProcessBinderScanInterval:  1000;
    ModulesLoadTimeout:         5000;
    SpeedUnits:                 nil;
    Speeds:(
      Step:       5.0;
      City:       50.0;
      Roads:      80.0;
      User:       (0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0);
      Arbitrary:  0.0);
    Inputs:(
      IncreaseByStep: (PrimaryKey: VK_PRIOR; ShiftKey: -1);
      DecreaseByStep: (PrimaryKey: VK_NEXT;  ShiftKey: -1);
      IncreaseByUnit: (PrimaryKey: VK_PRIOR; ShiftKey: VK_SHIFT);
      DecreaseByUnit: (PrimaryKey: VK_NEXT;  ShiftKey: VK_SHIFT);
      IncreaseStep:   (PrimaryKey: VK_PRIOR; ShiftKey: VK_CONTROL);
      DecreaseStep:   (PrimaryKey: VK_NEXT;  ShiftKey: VK_CONTROL);
      CityEngage:     (PrimaryKey: VK_HOME;  ShiftKey: -1);
      CityVehicle:    (PrimaryKey: VK_HOME;  ShiftKey: VK_SHIFT);
      CityCruise:     (PrimaryKey: VK_HOME;  ShiftKey: VK_CONTROL);
      RoadsEngage:    (PrimaryKey: VK_END;   ShiftKey: -1);
      RoadsVehicle:   (PrimaryKey: VK_END;   ShiftKey: VK_SHIFT);
      RoadsCruise:    (PrimaryKey: VK_END;   ShiftKey: VK_CONTROL);
      UserEngage:     ((PrimaryKey: VK_NUMPAD0; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD1; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD2; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD3; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD4; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD5; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD6; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD7; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD8; ShiftKey: -1),
                       (PrimaryKey: VK_NUMPAD9; ShiftKey: -1));
      UserVehicle:    ((PrimaryKey: VK_NUMPAD0; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD1; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD2; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD3; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD4; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD5; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD6; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD7; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD8; ShiftKey: VK_SHIFT),
                       (PrimaryKey: VK_NUMPAD9; ShiftKey: VK_SHIFT));
      UserCruise:     ((PrimaryKey: VK_NUMPAD0; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD1; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD2; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD3; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD4; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD5; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD6; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD7; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD8; ShiftKey: VK_CONTROL),
                       (PrimaryKey: VK_NUMPAD9; ShiftKey: VK_CONTROL))));

  def_SpeedUnits: Array[0..2] of TSpeedUnit = (
    (Name: 'km/h'; Coefficient: 1.0),
    (Name: 'mph';  Coefficient: 1.609344),
    (Name: 'm/s';  Coefficient: 3.6));

{==============================================================================}
{------------------------------------------------------------------------------}
{                               TSettingsManager                               }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TSettingsManager // Private methods                                        }
{------------------------------------------------------------------------------}

Function TSettingsManager.GetInput(Index: Integer): TInput;
begin
case Index of
  0:  Result := fSettings^.Inputs.IncreaseByStep;
  1:  Result := fSettings^.Inputs.DecreaseByStep;
  2:  Result := fSettings^.Inputs.IncreaseByUnit;
  3:  Result := fSettings^.Inputs.DecreaseByUnit;
  4:  Result := fSettings^.Inputs.IncreaseStep;
  5:  Result := fSettings^.Inputs.DecreaseStep;
  6:  Result := fSettings^.Inputs.CityEngage;
  7:  Result := fSettings^.Inputs.CityVehicle;
  8:  Result := fSettings^.Inputs.CityCruise;
  9:  Result := fSettings^.Inputs.RoadsEngage;
  10: Result := fSettings^.Inputs.RoadsVehicle;
  11: Result := fSettings^.Inputs.RoadsCruise;
  12..21: Result := fSettings^.Inputs.UserEngage[Index - 12];
  22..31: Result := fSettings^.Inputs.UserVehicle[Index - 22];
  32..41: Result := fSettings^.Inputs.UserCruise[Index - 32];
else
  Result.PrimaryKey := -1;
  Result.ShiftKey := -1;
end;
end;

//------------------------------------------------------------------------------

procedure TSettingsManager.SetInput(Index: Integer; Value: TInput);
begin
case Index of
  0:  fSettings^.Inputs.IncreaseByStep := Value;
  1:  fSettings^.Inputs.DecreaseByStep := Value;
  2:  fSettings^.Inputs.IncreaseByUnit := Value;
  3:  fSettings^.Inputs.DecreaseByUnit := Value;
  4:  fSettings^.Inputs.IncreaseStep := Value;
  5:  fSettings^.Inputs.DecreaseStep := Value;
  6:  fSettings^.Inputs.CityEngage := Value;
  7:  fSettings^.Inputs.CityVehicle := Value;
  8:  fSettings^.Inputs.CityCruise := Value;
  9:  fSettings^.Inputs.RoadsEngage := Value;
  10: fSettings^.Inputs.RoadsVehicle := Value;
  11: fSettings^.Inputs.RoadsCruise := Value;
  12..21: fSettings^.Inputs.UserEngage[Index - 12] := Value;
  22..31: fSettings^.Inputs.UserVehicle[Index - 22] := Value;
  32..41: fSettings^.Inputs.UserCruise[Index - 32] := Value;
end;
end;

//------------------------------------------------------------------------------

{------------------------------------------------------------------------------}
{   TSettingsManager // Public methods                                         }
{------------------------------------------------------------------------------}

constructor TSettingsManager.Create(SettingsVariable: PSettings);
begin
inherited Create;
If Assigned(SettingsVariable) then fSettings := SettingsVariable
  else raise Exception.Create('TSettingsManager.Create: Settings variable is not assigned.');
end;

//------------------------------------------------------------------------------

procedure TSettingsManager.ValidateSettings;
begin
If not fSettings^.MinimizeToTray then fSettings^.StartMinimized := False;
If (fSettings^.UsedSpeedUnit < Low(fSettings^.SpeedUnits)) or
   (fSettings^.UsedSpeedUnit > High(fSettings^.SpeedUnits)) then
   fSettings^.UsedSpeedUnit := Low(fSettings^.SpeedUnits);
end;

//------------------------------------------------------------------------------

procedure TSettingsManager.InitSettings;
var
  i:  Integer;
begin
fSettings^ := def_Settings;
fSettings^.ProgramPath := ParamStr(0);
SetLength(fSettings^.SpeedUnits,Length(def_SpeedUnits));
For i := Low(def_SpeedUnits) to High(def_SpeedUnits) do
  fSettings^.SpeedUnits[i] := def_SpeedUnits[i];
end;

//------------------------------------------------------------------------------

procedure TSettingsManager.PreloadSettings;
var
  Registry: TDefRegistry;
begin
try
  Registry := TDefRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    If Registry.OpenKeyReadOnly(SettingsRegistryKey) then
      begin
        fSettings^.ShowSplashScreen := Registry.ReadBoolDef(SETN_VAL_REG_ShowSplashScreen,def_Settings.ShowSplashScreen);
        fSettings^.MinimizeToTray := Registry.ReadBoolDef(SETN_VAL_REG_MinimizeToTray,def_Settings.MinimizeToTray);
        fSettings^.StartMinimized := Registry.ReadBoolDef(SETN_VAL_REG_StartMinimized,def_Settings.StartMinimized);
        ValidateSettings;
      end
    else InitSettings;
  finally
    Registry.Free;
  end;
except
  InitSettings;
end;
end;

//------------------------------------------------------------------------------

Function TSettingsManager.LoadFromRegistry: Boolean;
var
  Registry: TDefRegistry;
  i:        Integer;

  Function ReadInput(Reg: TDefRegistry; const ValueName: String; Default: TInput): TInput;
  begin
    Result.PrimaryKey := Reg.ReadIntegerDef(ValueName + SETN_SUF_PrimaryKey,Default.PrimaryKey);
    Result.ShiftKey := Reg.ReadIntegerDef(ValueName + SETN_SUF_ShiftKey,Default.ShiftKey);
  end;

begin
try
  Registry := TDefRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    If Registry.OpenKeyReadOnly(SettingsRegistryKey) then
      begin
        fSettings^.ProgramPath := ParamStr(0);
        fSettings^.ShowSplashScreen := Registry.ReadBoolDef(SETN_VAL_REG_ShowSplashScreen,def_Settings.ShowSplashScreen);
        fSettings^.MinimizeToTray := Registry.ReadBoolDef(SETN_VAL_REG_MinimizeToTray,def_Settings.MinimizeToTray);
        fSettings^.StartMinimized := Registry.ReadBoolDef(SETN_VAL_REG_StartMinimized,def_Settings.StartMinimized);
        fSettings^.CloseOnGameEnd := Registry.ReadBoolDef(SETN_VAL_REG_CloseOnGameEnd,def_Settings.CloseOnGameEnd);
        fSettings^.DiscernKeyboardSides := Registry.ReadBoolDef(SETN_VAL_REG_DiscernKeyboardSides,def_Settings.DiscernKeyboardSides);
        fSettings^.SoftKeyComboRecognition := Registry.ReadBoolDef(SETN_VAL_REG_SoftKeyComboRecognition,def_Settings.SoftKeyComboRecognition);
        fSettings^.UsedSpeedUnit := Registry.ReadIntegerDef(SETN_VAL_REG_UsedSpeedUnit,def_Settings.UsedSpeedUnit);

        fSettings^.ProcessBinderScanInterval := Registry.ReadIntegerDef(SETN_VAL_TMR_REG_ProcessBinderScanInterval,def_Settings.ProcessBinderScanInterval);
        fSettings^.ModulesLoadTimeout := Registry.ReadIntegerDef(SETN_VAL_TMR_REG_ModulesLoadTimeout,def_Settings.ModulesLoadTimeout);

        SetLength(fSettings^.SpeedUnits,Registry.ReadIntegerDef(SETN_VAL_REG_SPU_Count,Length(def_SpeedUnits)));
        For i := Low(fSettings^.SpeedUnits) to High(fSettings^.SpeedUnits) do
          begin
            fSettings^.SpeedUnits[i].Name := Registry.ReadStringDef(Format(SETN_VAL_REG_SPU_Name,[i]),def_SpeedUnits[i].Name);
            fSettings^.SpeedUnits[i].Coefficient := Registry.ReadFloatDef(Format(SETN_VAL_REG_SPU_Coefficient,[i]),def_SpeedUnits[i].Coefficient);
          end;

        fSettings^.Speeds.Step := Registry.ReadFloatDef(SETN_VAL_REG_SPD_Step,def_Settings.Speeds.Step);
        fSettings^.Speeds.City := Registry.ReadFloatDef(SETN_VAL_REG_SPD_City,def_Settings.Speeds.City);
        fSettings^.Speeds.Roads := Registry.ReadFloatDef(SETN_VAL_REG_SPD_Roads,def_Settings.Speeds.Roads);
        fSettings^.Speeds.Arbitrary := Registry.ReadFloatDef(SETN_VAL_REG_SPD_Arbitrary,def_Settings.Speeds.Arbitrary);
        For i := Low(fSettings^.Speeds.User) to High(fSettings^.Speeds.User) do
          fSettings^.Speeds.User[i] := Registry.ReadFloatDef(Format(SETN_VAL_REG_SPD_User,[i]),def_Settings.Speeds.User[i]);

        fSettings^.Inputs.IncreaseByStep := ReadInput(Registry,SETN_VAL_REG_INP_IncreaseByStep,def_Settings.Inputs.IncreaseByStep);
        fSettings^.Inputs.DecreaseByStep := ReadInput(Registry,SETN_VAL_REG_INP_DecreaseByStep,def_Settings.Inputs.DecreaseByStep);
        fSettings^.Inputs.IncreaseByUnit := ReadInput(Registry,SETN_VAL_REG_INP_IncreaseByUnit,def_Settings.Inputs.IncreaseByUnit);
        fSettings^.Inputs.DecreaseByUnit := ReadInput(Registry,SETN_VAL_REG_INP_DecreaseByUnit,def_Settings.Inputs.DecreaseByUnit);
        fSettings^.Inputs.IncreaseStep := ReadInput(Registry,SETN_VAL_REG_INP_IncreaseStep,def_Settings.Inputs.IncreaseStep);
        fSettings^.Inputs.DecreaseStep := ReadInput(Registry,SETN_VAL_REG_INP_DecreaseStep,def_Settings.Inputs.DecreaseStep);
        fSettings^.Inputs.CityEngage := ReadInput(Registry,SETN_VAL_REG_INP_CityEngage,def_Settings.Inputs.CityEngage);
        fSettings^.Inputs.CityVehicle := ReadInput(Registry,SETN_VAL_REG_INP_CityVehicle,def_Settings.Inputs.CityVehicle);
        fSettings^.Inputs.CityCruise := ReadInput(Registry,SETN_VAL_REG_INP_CityCruise,def_Settings.Inputs.CityCruise);
        fSettings^.Inputs.RoadsEngage := ReadInput(Registry,SETN_VAL_REG_INP_RoadsEngage,def_Settings.Inputs.RoadsEngage);
        fSettings^.Inputs.RoadsVehicle := ReadInput(Registry,SETN_VAL_REG_INP_RoadsVehicle,def_Settings.Inputs.RoadsVehicle);
        fSettings^.Inputs.RoadsCruise := ReadInput(Registry,SETN_VAL_REG_INP_RoadsCruise,def_Settings.Inputs.RoadsCruise);
        For i := Low(fSettings^.Inputs.UserEngage) to High(fSettings^.Inputs.UserEngage) do
          fSettings^.Inputs.UserEngage[i] := ReadInput(Registry,Format(SETN_VAL_REG_INP_UserEngage,[i]),def_Settings.Inputs.UserEngage[i]);
        For i := Low(fSettings^.Inputs.UserVehicle) to High(fSettings^.Inputs.UserVehicle) do
          fSettings^.Inputs.UserVehicle[i] := ReadInput(Registry,Format(SETN_VAL_REG_INP_UserVehicle,[i]),def_Settings.Inputs.UserVehicle[i]);
        For i := Low(fSettings^.Inputs.UserCruise) to High(fSettings^.Inputs.UserCruise) do
          fSettings^.Inputs.UserCruise[i] := ReadInput(Registry,Format(SETN_VAL_REG_INP_UserCruise,[i]),def_Settings.Inputs.UserCruise[i]);

        Registry.CloseKey;
        ValidateSettings;
        Result := True;
      end
    else Result := False;
  finally
    Registry.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TSettingsManager.SaveToRegistry: Boolean;
var
  Registry: TDefRegistry;
  i:        Integer;

  procedure WriteInput(Reg: TDefRegistry; const ValueName: String; Input: TInput);
  begin
    Reg.WriteInteger(ValueName + SETN_SUF_PrimaryKey,Input.PrimaryKey);
    Reg.WriteInteger(ValueName + SETN_SUF_ShiftKey,Input.ShiftKey);
  end;

begin
try
  Registry := TDefRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    If Registry.OpenKey(SettingsRegistryKey,True) then
      begin
        ValidateSettings;
        
        Registry.WriteString(SETN_VAL_REG_ProgramPath,fSettings^.ProgramPath);
        Registry.WriteBool(SETN_VAL_REG_ShowSplashScreen,fSettings^.ShowSplashScreen);
        Registry.WriteBool(SETN_VAL_REG_MinimizeToTray,fSettings^.MinimizeToTray);
        Registry.WriteBool(SETN_VAL_REG_StartMinimized,fSettings^.StartMinimized);
        Registry.WriteBool(SETN_VAL_REG_CloseOnGameEnd,fSettings^.CloseOnGameEnd);
        Registry.WriteBool(SETN_VAL_REG_DiscernKeyboardSides,fSettings^.DiscernKeyboardSides);
        Registry.WriteBool(SETN_VAL_REG_SoftKeyComboRecognition,fSettings^.SoftKeyComboRecognition);
        Registry.WriteInteger(SETN_VAL_REG_UsedSpeedUnit,fSettings^.UsedSpeedUnit);

        Registry.WriteInteger(SETN_VAL_TMR_REG_ProcessBinderScanInterval,fSettings^.ProcessBinderScanInterval);
        Registry.WriteInteger(SETN_VAL_TMR_REG_ModulesLoadTimeout,fSettings^.ModulesLoadTimeout);

        Registry.WriteInteger(SETN_VAL_REG_SPU_Count,Length(fSettings^.SpeedUnits));
        For i := Low(fSettings^.SpeedUnits) to High(fSettings^.SpeedUnits) do
          begin
            Registry.WriteString(Format(SETN_VAL_REG_SPU_Name,[i]),fSettings^.SpeedUnits[i].Name);
            Registry.WriteFloat(Format(SETN_VAL_REG_SPU_Coefficient,[i]),fSettings^.SpeedUnits[i].Coefficient);
          end;

        Registry.WriteFloat(SETN_VAL_REG_SPD_Step,fSettings^.Speeds.Step);
        Registry.WriteFloat(SETN_VAL_REG_SPD_City,fSettings^.Speeds.City);
        Registry.WriteFloat(SETN_VAL_REG_SPD_Roads,fSettings^.Speeds.Roads);
        Registry.WriteFloat(SETN_VAL_REG_SPD_Arbitrary,fSettings^.Speeds.Arbitrary);
        For i := Low(fSettings^.Speeds.User) to High(fSettings^.Speeds.User) do
          Registry.WriteFloat(Format(SETN_VAL_REG_SPD_User,[i]),fSettings^.Speeds.User[i]);

        WriteInput(Registry,SETN_VAL_REG_INP_IncreaseByStep,fSettings^.Inputs.IncreaseByStep);
        WriteInput(Registry,SETN_VAL_REG_INP_DecreaseByStep,fSettings^.Inputs.DecreaseByStep);
        WriteInput(Registry,SETN_VAL_REG_INP_IncreaseByUnit,fSettings^.Inputs.IncreaseByUnit);
        WriteInput(Registry,SETN_VAL_REG_INP_DecreaseByUnit,fSettings^.Inputs.DecreaseByUnit);
        WriteInput(Registry,SETN_VAL_REG_INP_IncreaseStep,fSettings^.Inputs.IncreaseStep);
        WriteInput(Registry,SETN_VAL_REG_INP_DecreaseStep,fSettings^.Inputs.DecreaseStep);
        WriteInput(Registry,SETN_VAL_REG_INP_CityEngage,fSettings^.Inputs.CityEngage);
        WriteInput(Registry,SETN_VAL_REG_INP_CityVehicle,fSettings^.Inputs.CityVehicle);
        WriteInput(Registry,SETN_VAL_REG_INP_CityCruise,fSettings^.Inputs.CityCruise);
        WriteInput(Registry,SETN_VAL_REG_INP_RoadsEngage,fSettings^.Inputs.RoadsEngage);
        WriteInput(Registry,SETN_VAL_REG_INP_RoadsVehicle,fSettings^.Inputs.RoadsVehicle);
        WriteInput(Registry,SETN_VAL_REG_INP_RoadsCruise,fSettings^.Inputs.RoadsCruise);
        For i := Low(fSettings^.Inputs.UserEngage) to High(fSettings^.Inputs.UserEngage) do
          WriteInput(Registry,Format(SETN_VAL_REG_INP_UserEngage,[i]),fSettings^.Inputs.UserEngage[i]);
        For i := Low(fSettings^.Inputs.UserVehicle) to High(fSettings^.Inputs.UserVehicle) do
          WriteInput(Registry,Format(SETN_VAL_REG_INP_UserVehicle,[i]),fSettings^.Inputs.UserVehicle[i]);
        For i := Low(fSettings^.Inputs.UserCruise) to High(fSettings^.Inputs.UserCruise) do
          WriteInput(Registry,Format(SETN_VAL_REG_INP_UserCruise,[i]),fSettings^.Inputs.UserCruise[i]);

        Registry.CloseKey;
        Result := True;
      end
    else Result := False;
  finally
    Registry.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TSettingsManager.LoadFromIni(const FileName: String): Boolean;
var
  IniFile:  TIniFile;
  i:        Integer;

  Function ReadInput(Ini: TIniFile; const Section, ValueName: String; Default: TInput): TInput;
  begin
    Result.PrimaryKey := Ini.ReadInteger(Section,ValueName + SETN_SUF_PrimaryKey,Default.PrimaryKey);
    Result.ShiftKey := Ini.ReadInteger(Section,ValueName + SETN_SUF_ShiftKey,Default.ShiftKey);
  end;

begin
try
  IniFile := TIniFile.Create(FileName);
  try
    fSettings^.ProgramPath := ParamStr(0);
    fSettings^.ShowSplashScreen := IniFile.ReadBool(SETN_GRP_General,SETN_VAL_ShowSplashScreen,def_Settings.ShowSplashScreen);
    fSettings^.MinimizeToTray := IniFile.ReadBool(SETN_GRP_General,SETN_VAL_MinimizetoTray,def_Settings.MinimizeToTray);
    fSettings^.StartMinimized := IniFile.ReadBool(SETN_GRP_General,SETN_VAL_StartMinimized,def_Settings.StartMinimized);
    fSettings^.CloseOnGameEnd := IniFile.ReadBool(SETN_GRP_General,SETN_VAL_CloseOnGameEnd,def_Settings.CloseOnGameEnd);
    fSettings^.DiscernKeyboardSides := IniFile.ReadBool(SETN_GRP_General,SETN_VAL_DiscernKeyboardSides,def_Settings.DiscernKeyboardSides);
    fSettings^.SoftKeyComboRecognition := IniFile.ReadBool(SETN_GRP_General,SETN_VAL_SoftKeyComboRecognition,def_Settings.SoftKeyComboRecognition);
    fSettings^.UsedSpeedUnit := IniFile.ReadInteger(SETN_GRP_General,SETN_VAL_UsedSpeedUnit,def_Settings.UsedSpeedUnit);

    fSettings^.ProcessBinderScanInterval := IniFile.ReadInteger(SETN_GRP_Timers,SETN_VAL_TMR_ProcessBinderScanInterval,def_Settings.ProcessBinderScanInterval);
    fSettings^.ModulesLoadTimeout := IniFile.ReadInteger(SETN_GRP_Timers,SETN_VAL_TMR_ModulesLoadTimeout,def_Settings.ModulesLoadTimeout);

    SetLength(fSettings^.SpeedUnits,IniFile.ReadInteger(SETN_GRP_SpeedUnits,SETN_VAL_SPU_Count,Length(def_SpeedUnits)));
    For i := Low(fSettings^.SpeedUnits) to High(fSettings^.SpeedUnits) do
      begin
        fSettings^.SpeedUnits[i].Name := IniFile.ReadString(SETN_GRP_SpeedUnits,Format(SETN_VAL_SPU_Name,[i]),def_SpeedUnits[i].Name);
        fSettings^.SpeedUnits[i].Coefficient := HexToSingle(IniFile.ReadString(SETN_GRP_SpeedUnits,Format(SETN_VAL_SPU_Coefficient,[i]),SingleToHex(def_SpeedUnits[i].Coefficient)));
      end;

    fSettings^.Speeds.Step := HexToSingle(IniFile.ReadString(SETN_GRP_Speeds,SETN_VAL_SPD_Step,SingleToHex(def_Settings.Speeds.Step)));
    fSettings^.Speeds.City := HexToSingle(IniFile.ReadString(SETN_GRP_Speeds,SETN_VAL_SPD_City,SingleToHex(def_Settings.Speeds.City)));
    fSettings^.Speeds.Roads := HexToSingle(IniFile.ReadString(SETN_GRP_Speeds,SETN_VAL_SPD_Roads,SingleToHex(def_Settings.Speeds.Roads)));
    fSettings^.Speeds.Arbitrary := HexToSingle(IniFile.ReadString(SETN_GRP_Speeds,SETN_VAL_SPD_Arbitrary,SingleToHex(def_Settings.Speeds.Arbitrary)));
    For i := Low(fSettings^.Speeds.User) to High(fSettings^.Speeds.User) do
      fSettings^.Speeds.User[i] := HexToSingle(IniFile.ReadString(SETN_GRP_Speeds,Format(SETN_VAL_SPD_User,[i]),SingleToHex(def_Settings.Speeds.User[i])));

    fSettings^.Inputs.IncreaseByStep := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_IncreaseByStep,def_Settings.Inputs.IncreaseByStep);
    fSettings^.Inputs.IncreaseByUnit := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_IncreaseByUnit,def_Settings.Inputs.IncreaseByUnit);
    fSettings^.Inputs.IncreaseStep := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_IncreaseStep,def_Settings.Inputs.IncreaseStep);
    fSettings^.Inputs.DecreaseByStep := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_DecreaseByStep,def_Settings.Inputs.DecreaseByStep);
    fSettings^.Inputs.DecreaseByUnit := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_DecreaseByUnit,def_Settings.Inputs.DecreaseByUnit);
    fSettings^.Inputs.DecreaseStep := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_DecreaseStep,def_Settings.Inputs.DecreaseStep);
    fSettings^.Inputs.CityEngage := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_CityEngage,def_Settings.Inputs.CityEngage);
    fSettings^.Inputs.CityVehicle := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_CityVehicle,def_Settings.Inputs.CityVehicle);
    fSettings^.Inputs.CityCruise := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_CityCruise,def_Settings.Inputs.CityCruise);
    fSettings^.Inputs.RoadsEngage := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_RoadsEngage,def_Settings.Inputs.RoadsEngage);
    fSettings^.Inputs.RoadsVehicle := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_RoadsVehicle,def_Settings.Inputs.RoadsVehicle);
    fSettings^.Inputs.RoadsCruise := ReadInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_RoadsCruise,def_Settings.Inputs.RoadsCruise);
    For i := Low(fSettings^.Inputs.UserEngage) to High(fSettings^.Inputs.UserEngage) do
      fSettings^.Inputs.UserEngage[i] := ReadInput(IniFile,SETN_GRP_Inputs,Format(SETN_VAL_INP_UserEngage,[i]),def_Settings.Inputs.UserEngage[i]);
    For i := Low(fSettings^.Inputs.UserVehicle) to High(fSettings^.Inputs.UserVehicle) do
      fSettings^.Inputs.UserVehicle[i] := ReadInput(IniFile,SETN_GRP_Inputs,Format(SETN_VAL_INP_UserVehicle,[i]),def_Settings.Inputs.UserVehicle[i]);
    For i := Low(fSettings^.Inputs.UserCruise) to High(fSettings^.Inputs.UserCruise) do
      fSettings^.Inputs.UserCruise[i] := ReadInput(IniFile,SETN_GRP_Inputs,Format(SETN_VAL_INP_UserCruise,[i]),def_Settings.Inputs.UserCruise[i]);

    ValidateSettings;
    Result := True;
  finally
    IniFile.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TSettingsManager.SaveToIni(const FileName: String): Boolean;
var
  IniFile:  TIniFile;
  i:        Integer;

  procedure WriteInput(Ini: TIniFile; const Section, ValueName: String; Input: TInput);
  begin
    Ini.WriteInteger(Section,ValueName + SETN_SUF_PrimaryKey,Input.PrimaryKey);
    Ini.WriteInteger(Section,ValueName + SETN_SUF_ShiftKey,Input.ShiftKey);
  end;

begin
try
  IniFile := TIniFile.Create(FileName);
  try
    ValidateSettings;

    IniFile.WriteString(SETN_GRP_General,SETN_VAL_ProgramPath,fSettings^.ProgramPath);
    IniFile.WriteBool(SETN_GRP_General,SETN_VAL_ShowSplashScreen,fSettings^.ShowSplashScreen);
    IniFile.WriteBool(SETN_GRP_General,SETN_VAL_MinimizeToTray,fSettings^.MinimizeToTray);
    IniFile.WriteBool(SETN_GRP_General,SETN_VAL_StartMinimized,fSettings^.StartMinimized);
    IniFile.WriteBool(SETN_GRP_General,SETN_VAL_CloseOnGameEnd,fSettings^.CloseOnGameEnd);
    IniFile.WriteBool(SETN_GRP_General,SETN_VAL_DiscernKeyboardSides,fSettings^.DiscernKeyboardSides);
    IniFile.WriteBool(SETN_GRP_General,SETN_VAL_SoftKeyComboRecognition,fSettings^.SoftKeyComboRecognition);
    IniFile.WriteInteger(SETN_GRP_General,SETN_VAL_UsedSpeedUnit,fSettings^.UsedSpeedUnit);

    IniFile.WriteInteger(SETN_GRP_Timers,SETN_VAL_TMR_ProcessBinderScanInterval,fSettings^.ProcessBinderScanInterval);
    IniFile.WriteInteger(SETN_GRP_Timers,SETN_VAL_TMR_ModulesLoadTimeout,fSettings^.ModulesLoadTimeout);

    IniFile.WriteInteger(SETN_GRP_SpeedUnits,SETN_VAL_SPU_Count,Length(fSettings^.SpeedUnits));
    For i := Low(fSettings^.SpeedUnits) to High(fSettings^.SpeedUnits) do
      begin
        IniFile.WriteString(SETN_GRP_SpeedUnits,Format(SETN_VAL_SPU_Name,[i]),fSettings^.SpeedUnits[i].Name);
        IniFile.WriteString(SETN_GRP_SpeedUnits,Format(SETN_VAL_SPU_Coefficient,[i]),SingleToHex(fSettings^.SpeedUnits[i].Coefficient));
      end;

    IniFile.WriteString(SETN_GRP_Speeds,SETN_VAL_SPD_Step,SingleToHex(fSettings^.Speeds.Step));
    IniFile.WriteString(SETN_GRP_Speeds,SETN_VAL_SPD_City,SingleToHex(fSettings^.Speeds.City));
    IniFile.WriteString(SETN_GRP_Speeds,SETN_VAL_SPD_Roads,SingleToHex(fSettings^.Speeds.Roads));
    IniFile.WriteString(SETN_GRP_Speeds,SETN_VAL_SPD_Arbitrary,SingleToHex(fSettings^.Speeds.Arbitrary));
    For i := Low(fSettings^.Speeds.User) to High(fSettings^.Speeds.User) do
      IniFile.WriteString(SETN_GRP_Speeds,Format(SETN_VAL_SPD_User,[i]),SingleToHex(fSettings^.Speeds.User[i]));

    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_IncreaseByStep,fSettings^.Inputs.IncreaseByStep);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_IncreaseByUnit,fSettings^.Inputs.IncreaseByUnit);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_IncreaseStep,fSettings^.Inputs.IncreaseStep);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_DecreaseByStep,fSettings^.Inputs.DecreaseByStep);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_DecreaseByUnit,fSettings^.Inputs.DecreaseByUnit);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_DecreaseStep,fSettings^.Inputs.DecreaseStep);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_CityEngage,fSettings^.Inputs.CityEngage);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_CityVehicle,fSettings^.Inputs.CityVehicle);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_CityCruise,fSettings^.Inputs.CityCruise);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_RoadsEngage,fSettings^.Inputs.RoadsEngage);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_RoadsVehicle,fSettings^.Inputs.RoadsVehicle);
    WriteInput(IniFile,SETN_GRP_Inputs,SETN_VAL_INP_RoadsCruise,fSettings^.Inputs.RoadsCruise);
    For i := Low(fSettings^.Inputs.UserEngage) to High(fSettings^.Inputs.UserEngage) do
      WriteInput(IniFile,SETN_GRP_Inputs,Format(SETN_VAL_INP_UserEngage,[i]),fSettings^.Inputs.UserEngage[i]);
    For i := Low(fSettings^.Inputs.UserVehicle) to High(fSettings^.Inputs.UserVehicle) do
      WriteInput(IniFile,SETN_GRP_Inputs,Format(SETN_VAL_INP_UserVehicle,[i]),fSettings^.Inputs.UserVehicle[i]);
    For i := Low(fSettings^.Inputs.UserCruise) to High(fSettings^.Inputs.UserCruise) do
      WriteInput(IniFile,SETN_GRP_Inputs,Format(SETN_VAL_INP_UserCruise,[i]),fSettings^.Inputs.UserCruise[i]);

    Result := True;
  finally
    IniFile.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TSettingsManager.InputConflict(Input: TInput; InputIndex: Integer; out ConflictingInputIndex: Integer): Boolean;
var
  i:          Integer;
  TempInput:  TInput;
begin
ConflictingInputIndex := -1;
For i := 0 to 41 do
  begin
    TempInput := GetInput(i);
    If (TempInput.PrimaryKey = Input.PrimaryKey) and (TempInput.ShiftKey = Input.ShiftKey) then
      begin
        ConflictingInputIndex := i;
        Break;
      end;
  end;
Result := (ConflictingInputIndex >= 0) and (ConflictingInputIndex <> InputIndex);
end;

end.
