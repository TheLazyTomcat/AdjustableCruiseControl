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

class Function TMemoryOperator.ResolveAddress(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; out Address: Pointer): Boolean;
var
  i:    Integer;
  Temp: LongWord;
begin
Result := False;
try
  Address := BaseAddress;
  If Length(PointerData.Offsets) > 0 then
    Address := {%H-}Pointer(PtrInt(Address) + PointerData.Offsets[0]);
  For i := Succ(Low(PointerData.Offsets)) to High(PointerData.Offsets) do
    begin
      If ReadProcessMemory(ProcessHandle,Address,@Address,SizeOf(Pointer),{%H-}Temp) then
        begin
          If Assigned(Address) and (Temp = SizeOf(Pointer)) then
            Address := {%H-}Pointer(PtrInt(Address) + PointerData.Offsets[i])
          else Exit;
        end
      else Exit;
    end;
  Result := Assigned(Address);
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

class Function TMemoryOperator.WriteValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: LongWord; Value: Pointer): Boolean;
var
  ValueAddress: Pointer;
  Temp:         LongWord;
begin
Result := False;
If ResolveAddress(ProcessHandle,BaseAddress,PointerData,ValueAddress) then
  begin
    If WriteProcessMemory(ProcessHandle,ValueAddress,Value,Size,{%H-}Temp) then
      Result := Temp = Size;
  end;
end;

//------------------------------------------------------------------------------

class Function TMemoryOperator.ReadValue(ProcessHandle: THandle; BaseAddress: Pointer; const PointerData: TPointerData; Size: LongWord; Value: Pointer): Boolean;
var
  ValueAddress: Pointer;
  Temp:         LongWord;
begin
Result := False;
If ResolveAddress(ProcessHandle,BaseAddress,PointerData,ValueAddress) then
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
    raise Exception.Create('TMemoryOperator.PointerDataByIndex: Index (' + IntToStr(Index) + ') out of bounds.');
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
  case PointerData.Flags and ACC_PTR_FLAGS_PointerTypeBitmask of
       0..$FF:  Coefficient := PointerData.Coefficient;
    $100..$164: If not ReadFloat((PointerData.Flags and ACC_PTR_FLAGS_PointerTypeBitmask) - $100,Coefficient) then Exit;
  else
    Exit;
  end;
  Value := Value * Coefficient;
  Result := WriteValue(fGameData.ProcessInfo.ProcessHandle,
                       fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                       PointerData,SizeOf(Single),@Value);
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
  case PointerData.Flags and ACC_PTR_FLAGS_PointerTypeBitmask of
       0..$FF:  Coefficient := PointerData.Coefficient;
    $100..$164: If not ReadFloat((PointerData.Flags and ACC_PTR_FLAGS_PointerTypeBitmask) - $100,Coefficient) then Exit;
  else
    Exit;
  end;
  Result := ReadValue(fGameData.ProcessInfo.ProcessHandle,
                      fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                      PointerData,SizeOf(Single),@Value);
  Value := Value / Coefficient;                    
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteBool(PointerIndex: Integer; Value: Boolean): Boolean;
var
  PointerData:  TPointerData;
begin
PointerData := PointerDataByIndex(PointerIndex);
Result := WriteValue(fGameData.ProcessInfo.ProcessHandle,
                     fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                     PointerData,SizeOf(Value),@Value);
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadBool(PointerIndex: Integer; out Value: Boolean): Boolean;
var
  PointerData:  TPointerData;
begin
PointerData := PointerDataByIndex(PointerIndex);
Result := ReadValue(fGameData.ProcessInfo.ProcessHandle,
                     fGameData.Modules[PointerData.ModuleIndex].RuntimeInfo.BaseAddress,
                     PointerData,SizeOf(Value),@Value);
end;

{------------------------------------------------------------------------------}
{   TMemoryOperator // Public methods                                          }
{------------------------------------------------------------------------------}

constructor TMemoryOperator.Create;
begin
inherited;
fActive := False;
fCanReadVehicleSpeed := False;
end;

//------------------------------------------------------------------------------

procedure TMemoryOperator.Activate(GameData: TGameData);
begin
fGameData := GameData;
fCanReadVehicleSpeed := TGamesDataManager.TruckSpeedSupported(fGameData);
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
  begin
    Result := ReadFloat(PTR_IDX_TruckSpeed,Value);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadCCSpeed(out Value: Single): Boolean;
begin
If fActive then
  begin
    Result := ReadFloat(PTR_IDX_CCSpeed,Value);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.ReadCCStatus(out Value: Boolean): Boolean;
begin
If fActive then
  begin
    Result := ReadBool(PTR_IDX_CCStatus,Value);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteCCSpeed(Value: Single): Boolean;
begin
If fActive then
  begin
    Result := WriteFloat(PTR_IDX_CCSpeed,Value);
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TMemoryOperator.WriteCCStatus(Value: Boolean): Boolean;
begin
If fActive then
  begin
    Result :=  WriteBool(PTR_IDX_CCStatus,Value);
  end
else Result := False;
end;

end.
