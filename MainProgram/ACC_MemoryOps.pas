{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_MemoryOps;

interface

{$INCLUDE ACC_Defs.inc}

uses
  ACC_GamesData;

type
{==============================================================================}
{------------------------------------------------------------------------------}
{                                TMemoryOperator                               }
{------------------------------------------------------------------------------}
{==============================================================================}
  TMemoryOperator = class(TObject)
  private
    fGameData:            TGameData;
    fActive:              Boolean;
    fCanReadVehicleSpeed: Boolean;
  protected
    class Function ResolveAddress(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; out Address: Pointer): Boolean; virtual;
    class Function WriteValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: LongWord; Value: Pointer): Boolean; virtual;
    class Function ReadValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: LongWord; Value: Pointer): Boolean; virtual;
    Function PointerDataByIndex(Index: Integer): TPointerData; virtual;
    Function WriteFloat(PointerIndex: Integer; Value: Single): Boolean; virtual;
    Function ReadFloat(PointerIndex: Integer; out Value: Single): Boolean; virtual;
    Function WriteBool(PointerIndex: Integer; Value: Boolean): Boolean; virtual;
    Function ReadBool(PointerIndex: Integer; out Value: Boolean): Boolean; virtual;
  public
    constructor Create;
    procedure Activate(GameData: TGameData); virtual;
    procedure Deactivate; virtual;
    Function ReadVehicleSpeed(out Value: Single): Boolean; virtual;
    Function ReadCCSpeed(out Value: Single): Boolean; virtual;
    Function ReadCCStatus(out Value: Boolean): Boolean; virtual;
    Function WriteCCSpeed(Value: Single): Boolean; virtual;
    Function WriteCCStatus(Value: Boolean): Boolean; virtual;
    property GameData: TGameData read fGameData;
  published
    property Active: Boolean read fActive;
    property CanReadVehicleSpeed: Boolean read fCanReadVehicleSpeed;
  end;

implementation

uses
  Windows, SysUtils,
  ACC_Common,
  ACC_Log;

const
  PTR_IDX_CCSpeed    = -1;
  PTR_IDX_CCStatus   = -2;
  PTR_IDX_TruckSpeed = -3;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                TMemoryOperator                               }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TMemoryOperator // Protected methods                                       }
{------------------------------------------------------------------------------}

class Function TMemoryOperator.ResolveAddress(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; out Address: Pointer): Boolean;
var
  i:        Integer;
  Temp:     LongWord;
  TempStr:  String;
begin
ACC_Logger.AddLog('TMemoryOperator.ResolveAddress');
ACC_Logger.AddLog('  ' + IntToHex(ProcessHandle,SizeOf(THandle)*2));
ACC_Logger.AddLog('  ' + IntToHex({%H-}PtrUInt(BaseAddress),SizeOf(Pointer)*2));
ACC_Logger.AddLog('  ' + IntToHex(PointerData.Flags,8));
ACC_Logger.AddLog('  ' + IntToHex(PointerData.PtrInfo,8));
ACC_Logger.AddLog('  ' + IntToStr(PointerData.ModuleIndex));
TempStr := '';
For i := Low(PointerData.Offsets) to High(PointerData.Offsets) do
  TempStr := TempStr + IntToHex(PointerData.Offsets[i],16) + ' ';
ACC_Logger.AddLog('  ' + TempStr);
ACC_Logger.AddLog('  ' + FloatToStr(PointerData.Coefficient));

Result := False;
try
  Address := BaseAddress;
  If Length(PointerData.Offsets) > 0 then
    Address := {%H-}Pointer({%H-}PtrUInt(Address) + PointerData.Offsets[0]);
  ACC_Logger.AddLog('  Iterating...');
  For i := Succ(Low(PointerData.Offsets)) to High(PointerData.Offsets) do
    begin
      ACC_Logger.AddLog('  Address: ' + IntToHex({%H-}PtrUInt(Address),SizeOf(Pointer)*2));
      If ReadProcessMemory(ProcessHandle,Address,@Address,SizeOf(Pointer),{%H-}Temp) then
        begin
          ACC_Logger.AddLog('  ' + IntToStr(i) + ': ReadProcessMemory successful');
          ACC_Logger.AddLog('    ' + IntToHex({%H-}PtrUInt(Address),SizeOf(Pointer)*2) + ' (' + IntToStr(Temp) + ')');
          If Assigned(Address) and (Temp = SizeOf(Pointer)) then
            Address := {%H-}Pointer({%H-}PtrUInt(Address) + PointerData.Offsets[i])
          else Exit;
        end
      else
        begin
          ACC_Logger.AddLog('  ' + IntToStr(i) + ': ReadProcessMemory failed 0x' + IntToHex(GetLastError,8));
          Exit;
        end;
    end;
  ACC_Logger.AddLog('  Final address: ' + IntToHex({%H-}PtrUInt(Address),SizeOf(Pointer)*2));
  Result := Assigned(Address);
except
  ACC_Logger.AddLog('  !!! Exception occured !!!');
  Result := False;
end;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.ResolveAddress <<');
end;

//------------------------------------------------------------------------------

class Function TMemoryOperator.WriteValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: LongWord; Value: Pointer): Boolean;
var
  ValueAddress: Pointer;
  Temp:         LongWord;
  i:            Integer;
  TempStr:      String;
begin
ACC_Logger.AddLog('TMemoryOperator.WriteValue');
ACC_Logger.AddLog('  ' + IntToHex(ProcessHandle,SizeOf(THandle)*2));
ACC_Logger.AddLog('  ' + IntToHex({%H-}PtrUInt(BaseAddress),SizeOf(Pointer)*2));
ACC_Logger.AddLog('  ' + IntToHex(PointerData.Flags,8));
ACC_Logger.AddLog('  ' + IntToHex(PointerData.PtrInfo,8));
ACC_Logger.AddLog('  ' + IntToStr(PointerData.ModuleIndex));
TempStr := '';
For i := Low(PointerData.Offsets) to High(PointerData.Offsets) do
  TempStr := TempStr + IntToHex(PointerData.Offsets[i],16) + ' ';
ACC_Logger.AddLog('  ' + TempStr);
ACC_Logger.AddLog('  ' + FloatToStr(PointerData.Coefficient));
ACC_Logger.AddLog('  ' + IntToStr(Size));
ACC_Logger.AddLog('  ' + IntToHex({%H-}PtrUInt(Value),SizeOf(Pointer)*2));

Result := False;
If ResolveAddress(ProcessHandle,BaseAddress,PointerData,ValueAddress) then
  begin
    If WriteProcessMemory(ProcessHandle,ValueAddress,Value,Size,{%H-}Temp) then
      begin
        ACC_Logger.AddLog('  WriteProcessMemory successful (' + IntToStr(Temp) + ')');
        Result := Temp = Size;
      end
    else
      ACC_Logger.AddLog('  WriteProcessMemory failed (' + IntToStr(Temp) + ') 0x' + IntToHex(GetLastError,8));
  end;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.WriteValue <<');
end;

//------------------------------------------------------------------------------

class Function TMemoryOperator.ReadValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: LongWord; Value: Pointer): Boolean;
var
  ValueAddress: Pointer;
  Temp:         LongWord;
  i:            Integer;
  TempStr:      String;
begin
ACC_Logger.AddLog('TMemoryOperator.ReadValue');
ACC_Logger.AddLog('  ' + IntToHex(ProcessHandle,SizeOf(THandle)*2));
ACC_Logger.AddLog('  ' + IntToHex({%H-}PtrUInt(BaseAddress),SizeOf(Pointer)*2));
ACC_Logger.AddLog('  ' + IntToHex(PointerData.Flags,8));
ACC_Logger.AddLog('  ' + IntToHex(PointerData.PtrInfo,8));
ACC_Logger.AddLog('  ' + IntToStr(PointerData.ModuleIndex));
TempStr := '';
For i := Low(PointerData.Offsets) to High(PointerData.Offsets) do
  TempStr := TempStr + IntToHex(PointerData.Offsets[i],16) + ' ';
ACC_Logger.AddLog('  ' + TempStr);
ACC_Logger.AddLog('  ' + FloatToStr(PointerData.Coefficient));
ACC_Logger.AddLog('  ' + IntToStr(Size));
ACC_Logger.AddLog('  ' + IntToHex({%H-}PtrUInt(Value),SizeOf(Pointer)*2));

Result := False;
If ResolveAddress(ProcessHandle,BaseAddress,PointerData,ValueAddress) then
  begin
    If ReadProcessMemory(ProcessHandle,ValueAddress,Value,Size,{%H-}Temp) then
      begin
        ACC_Logger.AddLog('  ReadProcessMemory successful (' + IntToStr(Temp) + ')');
        Result := Temp = Size;
      end
    else
      ACC_Logger.AddLog('  ReadProcessMemory failed (' + IntToStr(Temp) + ') 0x' + IntToHex(GetLastError,8));
  end;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.ReadValue <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.PointerDataByIndex(Index: Integer): TPointerData;
var
  i:        Integer;
  TempStr:  String;
begin
ACC_Logger.AddLog(Format('TMemoryOperator.PointerDataByIndex(%d)',[Index]));
case Index of
  PTR_IDX_CCSpeed:    Result := fGameData.CCSpeed;
  PTR_IDX_CCStatus:   Result := fGameData.CCStatus;
  PTR_IDX_TruckSpeed: Result := fGameData.TruckSpeed;
else
  If (Index >= Low(fGameData.Values)) and (Index <= High(fGameData.Values)) then
    Result := fGameData.Values[Index]
  else
    raise Exception.CreateFmt('TMemoryOperator.PointerDataByIndex: Index (%d) out of bounds.',[Index]);
end;
ACC_Logger.AddLog('  Result:');
ACC_Logger.AddLog('    ' + IntToHex(Result.Flags,8));
ACC_Logger.AddLog('    ' + IntToHex(Result.PtrInfo,8));
ACC_Logger.AddLog('    ' + IntToStr(Result.ModuleIndex));
TempStr := '';
For i := Low(Result.Offsets) to High(Result.Offsets) do
  TempStr := TempStr + IntToHex(Result.Offsets[i],16) + ' ';
ACC_Logger.AddLog('    ' + TempStr);
ACC_Logger.AddLog('    ' + FloatToStr(Result.Coefficient));
ACC_Logger.AddLog('TMemoryOperator.PointerDataByIndex <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteFloat(PointerIndex: Integer; Value: Single): Boolean;
var
  PointerData:  TPointerData;
  Coefficient:  Single;
begin
ACC_Logger.AddLog(Format('TMemoryOperator.WriteFloat(%d,%f)',[PointerIndex,Value]));
Result := False;
try
  PointerData := PointerDataByIndex(PointerIndex);
  case TPtrInfoRec(PointerData.PtrInfo).PtrType of
    PTR_TYPE_Float:
      Coefficient := 1.0;
    PTR_TYPE_FloatCorrected:
      Coefficient := PointerData.Coefficient;
    PTR_TYPE_FloatCorrectedRemote:
      If not ReadFloat(TPtrInfoRec(PointerData.PtrInfo).PtrData,Coefficient) then Exit;
  else
    Exit;
  end;
  Value := Value * Coefficient;
  Result := WriteValue(fGameData.ProcessInfo.ProcessHandle,
                       fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                       PointerData,SizeOf(Single),@Value);
except
  ACC_Logger.AddLog('  !!! Exception occured !!!');
  Result := False;
end;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.WriteFloat <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadFloat(PointerIndex: Integer; out Value: Single): Boolean;
var
  PointerData:  TPointerData;
  Coefficient:  Single;
begin
ACC_Logger.AddLog(Format('TMemoryOperator.ReadFloat(%d)',[PointerIndex]));
Result := False;
try
  PointerData := PointerDataByIndex(PointerIndex);
  case TPtrInfoRec(PointerData.PtrInfo).PtrType of
    PTR_TYPE_Float:
      Coefficient := 1.0;
    PTR_TYPE_FloatCorrected:
      Coefficient := PointerData.Coefficient;
    PTR_TYPE_FloatCorrectedRemote:
      If not ReadFloat(TPtrInfoRec(PointerData.PtrInfo).PtrData,Coefficient) then Exit;
  else
    Exit;
  end;
  Result := ReadValue(fGameData.ProcessInfo.ProcessHandle,
                      fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                      PointerData,SizeOf(Single),@Value);
  Value := Value / Coefficient;
except
  ACC_Logger.AddLog('  !!! Exception occured !!!');
  Result := False;
end;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.ReadFloat <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteBool(PointerIndex: Integer; Value: Boolean): Boolean;
var
  PointerData:  TPointerData;
begin
ACC_Logger.AddLog(Format('TMemoryOperator.WriteBool(%d,',[PointerIndex]) + BoolToStr(Value,True) + ')');
PointerData := PointerDataByIndex(PointerIndex);
Result := WriteValue(fGameData.ProcessInfo.ProcessHandle,
                     fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                     PointerData,SizeOf(Value),@Value);
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.WriteBool <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadBool(PointerIndex: Integer; out Value: Boolean): Boolean;
var
  PointerData:  TPointerData;
begin
ACC_Logger.AddLog(Format('TMemoryOperator.ReadBool(%d)',[PointerIndex]));
PointerData := PointerDataByIndex(PointerIndex);
Result := ReadValue(fGameData.ProcessInfo.ProcessHandle,
                     fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                     PointerData,SizeOf(Value),@Value);
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.ReadBool <<');
end;

{------------------------------------------------------------------------------}
{   TMemoryOperator // Public methods                                          }
{------------------------------------------------------------------------------}

constructor TMemoryOperator.Create;
begin
ACC_Logger.AddLog('TMemoryOperator.Create');
inherited Create;
fActive := False;
fCanReadVehicleSpeed := False;
ACC_Logger.AddLog('TMemoryOperator.Create <<');
end;

//------------------------------------------------------------------------------

procedure TMemoryOperator.Activate(GameData: TGameData);
begin
ACC_Logger.AddLog('TMemoryOperator.Activate...');
ACC_Logger.AddLog('  ' + GUIDToString(GameData.Identifier));
ACC_Logger.AddLog('  ' + GameData.ExtendedTitle);
fGameData := GameData;
ACC_Logger.AddLog('  TGamesDataManager.TruckSpeedSupported(fGameData): ' + IntToStr(Integer(TGamesDataManager.TruckSpeedSupported(fGameData))));
fCanReadVehicleSpeed := TGamesDataManager.TruckSpeedSupported(fGameData) = ssrDirect;
ACC_Logger.AddLog('  fCanReadVehicleSpeed: ' + BoolToStr(fCanReadVehicleSpeed,True));
fActive := TGamesDataManager.IsValid(fGameData);
ACC_Logger.AddLog('  fActive: ' + BoolToStr(fActive,True));
ACC_Logger.AddLog('TMemoryOperator.Activate <<');
end;

//------------------------------------------------------------------------------

procedure TMemoryOperator.Deactivate;
begin
ACC_Logger.AddLog('TMemoryOperator.Deactivate');
fActive := False;
fCanReadVehicleSpeed := False;
ACC_Logger.AddLog('TMemoryOperator.Deactivate <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadVehicleSpeed(out Value: Single): Boolean;
begin
ACC_Logger.AddLog('TMemoryOperator.ReadVehicleSpeed');
ACC_Logger.AddLog('  fActive: ' + BoolToStr(fActive,True));
ACC_Logger.AddLog('  fCanReadVehicleSpeed: ' + BoolToStr(fCanReadVehicleSpeed,True));
If fActive and fCanReadVehicleSpeed then
  Result := ReadFloat(PTR_IDX_TruckSpeed,Value)
else
  Result := False;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True) + ' - ' + FloatToStr(Value));
ACC_Logger.AddLog('TMemoryOperator.ReadVehicleSpeed <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadCCSpeed(out Value: Single): Boolean;
begin
ACC_Logger.AddLog('TMemoryOperator.ReadCCSpeed');
ACC_Logger.AddLog('  fActive: ' + BoolToStr(fActive,True));
If fActive then
   Result := ReadFloat(PTR_IDX_CCSpeed,Value)
else
  Result := False;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True) + ' - ' + FloatToStr(Value));
ACC_Logger.AddLog('TMemoryOperator.ReadCCSpeed <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadCCStatus(out Value: Boolean): Boolean;
begin
ACC_Logger.AddLog('TMemoryOperator.ReadCCSpeed');
ACC_Logger.AddLog('  fActive: ' + BoolToStr(fActive,True));
If fActive then
  Result := ReadBool(PTR_IDX_CCStatus,Value)
else
  Result := False;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True) + ' - ' + BoolToStr(Value,True));
ACC_Logger.AddLog('TMemoryOperator.ReadCCStatus <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteCCSpeed(Value: Single): Boolean;
begin
ACC_Logger.AddLog(Format('TMemoryOperator.WriteCCSpeed(%f)',[Value]));
ACC_Logger.AddLog('  fActive: ' + BoolToStr(fActive,True));
If fActive then
  Result := WriteFloat(PTR_IDX_CCSpeed,Value)
else
  Result := False;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.WriteCCSpeed <<');
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteCCStatus(Value: Boolean): Boolean;
begin
ACC_Logger.AddLog('TMemoryOperator.WriteCCStatus(' + BoolToStr(Value,True) + ')');
ACC_Logger.AddLog('  fActive: ' + BoolToStr(fActive,True));
If fActive then
  Result := WriteBool(PTR_IDX_CCStatus,Value)
else
  Result := False;
ACC_Logger.AddLog('  Result: ' + BoolToStr(Result,True));
ACC_Logger.AddLog('TMemoryOperator.WriteCCStatus <<');
end;

end.
