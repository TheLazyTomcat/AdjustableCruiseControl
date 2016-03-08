{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_MemoryOps;

interface

{$INCLUDE ACC_Defs.inc}

uses
  AuxTypes,
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
    class Function ResolveAddress(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; out Address: Pointer; {%H-}Ptr64: Boolean): Boolean; virtual;
    class Function WriteValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: PtrUInt; Value: Pointer; Ptr64: Boolean): Boolean; virtual;
    class Function ReadValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: PtrUInt; Value: Pointer; Ptr64: Boolean): Boolean; virtual;
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
  ACC_Common;

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

class Function TMemoryOperator.ResolveAddress(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; out Address: Pointer; Ptr64: Boolean): Boolean;
var
  i:        Integer;
  Temp:     PtrUInt;
  PtrSize:  PtrUInt;
begin
Result := False;
{$IFDEF x64}
If Ptr64 then PtrSize := 8
  else PtrSize := 4;
{$ELSE}
PtrSize := 4;
{$ENDIF}
try
  Address := BaseAddress;
  If Length(PointerData.Offsets) > 0 then
    Address := {%H-}Pointer({%H-}PtrUInt(Address) + PointerData.Offsets[0]);
  For i := Succ(Low(PointerData.Offsets)) to High(PointerData.Offsets) do
    begin
    {$IFDEF x64}
      If not Ptr64 then Address := {%H-}Pointer({%H-}PtrUInt(Address) and $FFFFFFFF);
    {$ENDIF}
      If ReadProcessMemory(ProcessHandle,Address,@Address,PtrSize,{%H-}Temp) then
        begin
          If Assigned(Address) and (Temp = PtrSize) then
            Address := {%H-}Pointer({%H-}PtrUInt(Address) + PointerData.Offsets[i])
          else Exit;
        end
      else Exit;
    end;
{$IFDEF x64}
  If not Ptr64 then Address := {%H-}Pointer({%H-}PtrUInt(Address) and $FFFFFFFF);
{$ENDIF}
  Result := Assigned(Address);
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

class Function TMemoryOperator.WriteValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: PtrUInt; Value: Pointer; Ptr64: Boolean): Boolean;
var
  ValueAddress: Pointer;
  Temp:         PtrUInt;
begin
Result := False;
If ResolveAddress(ProcessHandle,BaseAddress,PointerData,ValueAddress,Ptr64) then
  begin
    If WriteProcessMemory(ProcessHandle,ValueAddress,Value,Size,{%H-}Temp) then
      Result := Temp = Size;
  end;
end;

//------------------------------------------------------------------------------

class Function TMemoryOperator.ReadValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: PtrUInt; Value: Pointer; Ptr64: Boolean): Boolean;
var
  ValueAddress: Pointer;
  Temp:         PtrUInt;
begin
Result := False;
If ResolveAddress(ProcessHandle,BaseAddress,PointerData,ValueAddress,Ptr64) then
  begin
    If ReadProcessMemory(ProcessHandle,ValueAddress,Value,Size,{%H-}Temp) then
      Result := Temp = Size;
  end;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.PointerDataByIndex(Index: Integer): TPointerData;
begin
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
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteFloat(PointerIndex: Integer; Value: Single): Boolean;
var
  PointerData:  TPointerData;
  Coefficient:  Single;
begin
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
                       PointerData,SizeOf(Single),@Value,fGameData.ProcessInfo.Is64bitProcess);
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadFloat(PointerIndex: Integer; out Value: Single): Boolean;
var
  PointerData:  TPointerData;
  Coefficient:  Single;
begin
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
                      PointerData,SizeOf(Single),@Value,fGameData.ProcessInfo.Is64bitProcess);
  Value := Value / Coefficient;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteBool(PointerIndex: Integer; Value: Boolean): Boolean;
var
  PointerData:  TPointerData;
  TempValue:    ByteBool;
begin
PointerData := PointerDataByIndex(PointerIndex);
TempValue := Value;
Result := WriteValue(fGameData.ProcessInfo.ProcessHandle,
                     fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                     PointerData,SizeOf(TempValue),@TempValue,fGameData.ProcessInfo.Is64bitProcess);
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadBool(PointerIndex: Integer; out Value: Boolean): Boolean;
var
  PointerData:  TPointerData;
  TempValue:    ByteBool;
begin
PointerData := PointerDataByIndex(PointerIndex);
Result := ReadValue(fGameData.ProcessInfo.ProcessHandle,
                    fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                    PointerData,SizeOf(TempValue),@TempValue,fGameData.ProcessInfo.Is64bitProcess);
Value := TempValue;
end;

{------------------------------------------------------------------------------}
{   TMemoryOperator // Public methods                                          }
{------------------------------------------------------------------------------}

constructor TMemoryOperator.Create;
begin
inherited Create;
fActive := False;
fCanReadVehicleSpeed := False;
end;

//------------------------------------------------------------------------------

procedure TMemoryOperator.Activate(GameData: TGameData);
begin
fGameData := GameData;
fCanReadVehicleSpeed := TGamesDataManager.TruckSpeedSupported(fGameData) = ssrDirect;
fActive := TGamesDataManager.IsValid(fGameData);
end;

//------------------------------------------------------------------------------

procedure TMemoryOperator.Deactivate;
begin
fActive := False;
fCanReadVehicleSpeed := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadVehicleSpeed(out Value: Single): Boolean;
begin
If fActive and fCanReadVehicleSpeed then
  Result := ReadFloat(PTR_IDX_TruckSpeed,Value)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadCCSpeed(out Value: Single): Boolean;
begin
If fActive then
  Result := ReadFloat(PTR_IDX_CCSpeed,Value)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadCCStatus(out Value: Boolean): Boolean;
begin
If fActive then
  Result := ReadBool(PTR_IDX_CCStatus,Value)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteCCSpeed(Value: Single): Boolean;
begin
If fActive then
  Result := WriteFloat(PTR_IDX_CCSpeed,Value)
else
  Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteCCStatus(Value: Boolean): Boolean;
begin
If fActive then
  Result :=  WriteBool(PTR_IDX_CCStatus,Value)
else
  Result := False;
end;

end.
