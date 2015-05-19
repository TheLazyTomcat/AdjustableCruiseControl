{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_Strings;

interface

{$INCLUDE ACC_Defs.inc}

const
  ACCSTR_ApplicationName      = 'Adjustable Cruise Control';
  ACCSTR_ApplicationNameShort = 'ACC';

  // Instance contol
  ACCSTR_IC_InstanceName  = '4A2B8BA4-821A-4777-8B2E-85E19167D6F5';
  ACCSTR_IC_MessagePrefix = 'ACC_IC_MSG_';
  ACCSTR_IC_MapPrefix     = 'ACC_IC_MMF_';
  ACCSTR_IC_MutexPrefix   = 'ACC_IC_MTX_';

  // Tray icon
  ACCSTR_TI_MessageName    = 'ACC_TI_MSG_BC5A87F7-B0D4-45A1-A516-4A23A3C208B4';
  ACCSTR_TI_DefaultTipText = ACCSTR_ApplicationName;

  // Tray icom popup menu items
  ACCSTR_TI_MI_Restore  = 'Restore';
  ACCSTR_TI_MI_Splitter = '-';
  ACCSTR_TI_MI_Exit     = 'Close the program';

  // User interface - status bar
  ACCSTR_UI_STB_GameProcess   = 'Game process: ';
  ACCSTR_UI_STB_ProcessInfo   = '%s (PID %d)';
  ACCSTR_UI_STB_NoGameProcess = ACCSTR_UI_STB_GameProcess + 'not found';
  ACCSTR_UI_STB_PluginOnline  = 'Plugin online';
  ACCSTR_UI_STB_PluginOffline = 'Plugin offline';

  // User interface - game info
  ACCSTR_UI_GAM_NoGameTitle = '>>> None of the supported games is running <<<';
  ACCSTR_UI_GAM_NoGameInfo  = 'No further informations';

  // User interface - buttons
  ACCSTR_UI_BTN_Keys = ' [%s]';

  ACCSTR_UI_BTN_IncreaseByUnit = 'Increase by unit';
  ACCSTR_UI_BTN_DecreaseByUnit = 'Decrease by unit';
  ACCSTR_UI_BTN_IncreaseByStep = 'Increase by step';
  ACCSTR_UI_BTN_DecreaseByStep = 'Decrease by step';
  ACCSTR_UI_BTN_SetToArbitrary = 'Set to...';

  ACCSTR_UI_BTN_SetToCity  = 'City';
  ACCSTR_UI_BTN_SetToRoads = 'Roads';

  ACCSTR_UI_BTN_SetToUser = 'User %d';

  ACCSTR_UI_BTN_SetToLimit  = 'Set to speed limit';
  ACCSTR_UI_BTN_KeepOnLimit = 'Keep on speed limit';

  ACCSTR_UI_LIM_BoxCaptionNormal      = 'Speed limit';
  ACCSTR_UI_LIM_BoxCaptionInactive    = 'Speed limit (inactive)';
  ACCSTR_UI_LIM_BoxCaptionUnsupported = 'Speed limit (unsupported)';
  ACCSTR_UI_LIM_ActionsOnZeroLimit: Array[0..1] of String = ('Turn CC off','Set CC to speed...');

  // User interface - About
  ACCSTR_UI_CPY_ProgramVersion = 'Version of the program: ';
{$IFDEF FPC}
  ACCSTR_UI_CPY_Author         = #194 + #169 + ' 2013-2015 Franti' + #197 + #161 + 'ek Milt';
{$ELSE}
  ACCSTR_UI_CPY_Author         = '© 2013-2015 František Milt';
{$ENDIF}
  ACCSTR_UI_CPY_Copyright      = 'All rights reserved';

  // User interface - Settings form - Bindings table
  ACCSTR_UI_SET_BIND_HEAD_Action  = 'Action';
  ACCSTR_UI_SET_BIND_HEAD_Keys    = 'Key(s)';
  ACCSTR_UI_SET_BIND_HEAD_VKCodes = 'VK codes';

  ACCSTR_UI_SET_BIND_IncreaseByStep = 'Increase by step';
  ACCSTR_UI_SET_BIND_DecreaseByStep = 'Decrease by step';
  ACCSTR_UI_SET_BIND_IncreaseByUnit = 'Increase by unit';
  ACCSTR_UI_SET_BIND_DecreaseByUnit = 'Decrease by unit';
  ACCSTR_UI_SET_BIND_IncreaseStep = 'Increase step by unit';
  ACCSTR_UI_SET_BIND_DecreaseStep = 'Decrease step by unit';

  ACCSTR_UI_SET_BIND_CityEngage   = 'Set CC to City speed';
  ACCSTR_UI_SET_BIND_CityVehicle  = 'Vehicle -> City speed';
  ACCSTR_UI_SET_BIND_CityCruise   = 'CC -> City speed';
  ACCSTR_UI_SET_BIND_RoadsEngage  = 'Set CC to Roads speed';
  ACCSTR_UI_SET_BIND_RoadsVehicle = 'Vehicle -> Roads speed';
  ACCSTR_UI_SET_BIND_RoadsCruise  = 'CC -> Roads speed';

  ACCSTR_UI_SET_BIND_UserEngage  = 'Set CC to User %d speed';
  ACCSTR_UI_SET_BIND_UserVehicle = 'Vehicle -> User %d speed';
  ACCSTR_UI_SET_BIND_UserCruise  = 'CC -> User %d speed';

  ACCSTR_UI_SET_BIND_SetToLimit  = 'Set to limit';
  ACCSTR_UI_SET_BIND_KeepOnLimit  = 'Keep on limit';

  ACCSTR_UI_SET_BIND_ClearBinding = 'Are you sure you want to clear binding for action "%s"?';

  Function ACCSTR_UI_SET_BIND_InputText(Index: Integer): String;

const
  // User interface - Settings form - timers hints
  ACCSTR_UI_SET_TIH_ProcessScanTimer = 'Interval between scans of running processes (search for a running game).' + sLineBreak +
                                       'Recommended value: 1000ms; Minimum value: 100ms; Maximum value: 10000ms';

  ACCSTR_UI_SET_TIH_ModuleLoadTimer  = 'Time granted to a process to load all its modules before such process is accepted or rejected.' + sLineBreak +
                                       'Recommended value: 5000ms; Minimum value: 1000ms; Maximum value: 30000ms';

  ACCSTR_UI_SET_DEF_LoadDefaultSettings = 'All program settings, including speeds, key bindings or hidden variables, will be se to their default values.' + sLineBreak +
                                          'Are you sure you want to load default settings?';

  // User interface - key binding
  ACCSTR_UI_BIND_SelectKeys      = 'Press key or combination of two keys you want to bind to action "%s"...';
  ACCSTR_UI_BIND_KeysConflict    = 'Selected key or keys combination is already binded to action "%s":';
  ACCSTR_UI_BIND_SelectedKeys    = 'Keys selected for action "%s":';
  ACCSTR_UI_BIND_VirtualKeyCodes = 'Virtual key codes: %s';

  // User interface - supported games
  ACCSTR_UI_SUPG_SupportedList = 'Supported games (%d)';
  ACCSTR_UI_SUPG_VAL_Index     = 'Index';

  ACCSTR_UI_SUPG_ASSOC_Associate = 'Image from which this instance of ACC is started will be associated with file extension UGDB.' + sLineBreak +
                                   'From now on, the program image must stay in the same folder for this association to work properly.' + sLineBreak +
                                   'Are you sure you want to associate UGDB file extension to this program?';

  ACCSTR_UI_SUPG_ASSOC_Deassociate = 'File extension UGDB seems to be already associated.'  + sLineBreak +
                                     'What you want to do with this association?';

implementation

uses
  SysUtils;

Function ACCSTR_UI_SET_BIND_InputText(Index: Integer): String;
begin
case Index of
  0:  Result := ACCSTR_UI_SET_BIND_IncreaseByStep;
  1:  Result := ACCSTR_UI_SET_BIND_DecreaseByStep;
  2:  Result := ACCSTR_UI_SET_BIND_IncreaseByUnit;
  3:  Result := ACCSTR_UI_SET_BIND_DecreaseByUnit;
  4:  Result := ACCSTR_UI_SET_BIND_IncreaseStep;
  5:  Result := ACCSTR_UI_SET_BIND_DecreaseStep;
  6:  Result := ACCSTR_UI_SET_BIND_CityEngage;
  7:  Result := ACCSTR_UI_SET_BIND_CityVehicle;
  8:  Result := ACCSTR_UI_SET_BIND_CityCruise;
  9:  Result := ACCSTR_UI_SET_BIND_RoadsEngage;
  10: Result := ACCSTR_UI_SET_BIND_RoadsVehicle;
  11: Result := ACCSTR_UI_SET_BIND_RoadsCruise;
  12..21: Result := Format(ACCSTR_UI_SET_BIND_UserEngage,[Index - 12]);
  22..31: Result := Format(ACCSTR_UI_SET_BIND_UserVehicle,[Index - 22]);
  32..41: Result := Format(ACCSTR_UI_SET_BIND_UserCruise,[Index - 32]);
  42: Result := ACCSTR_UI_SET_BIND_SetToLimit;
  43: Result := ACCSTR_UI_SET_BIND_KeepOnLimit;
else
  Result := '';
end;
end;

end.
