{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

Floating point numbers <> HexString conversion routines

©František Milt 2015-04-29

Version 1.3.1

===============================================================================}
unit FloatHex;

{$IFDEF x64}
  {$DEFINE Extended64}
{$ENDIF}

interface

Function SingleToHex(Value: Single): String;
Function HexToSingle(HexString: String): Single;
Function TryHexToSingle(const HexString: String; out Value: Single): Boolean;
Function HexToSingleDef(const HexString: String; const DefaultValue: Single): Single;

//------------------------------------------------------------------------------

Function DoubleToHex(Value: Double): String;
Function HexToDouble(HexString: String): Double;
Function TryHexToDouble(const HexString: String; out Value: Double): Boolean;
Function HexToDoubleDef(const HexString: String; const DefaultValue: Double): Double;

//------------------------------------------------------------------------------

Function ExtendedToHex(Value: Extended): String;
Function HexToExtended(HexString: String): Extended;
Function TryHexToExtended(const HexString: String; out Value: Extended): Boolean;
Function HexToExtendedDef(const HexString: String; const DefaultValue: Extended): Extended;

//------------------------------------------------------------------------------

Function FloatToHex(Value: Single): String; overload;
Function HexToFloat(const HexString: String): Single; overload;
Function TryHexToFloat(const HexString: String; out Value: Single): Boolean; overload;
Function HexToFloatDef(const HexString: String; const DefaultValue: Single): Single; overload;

implementation

uses
  SysUtils;

type
  TOverlay_80b = packed record
    Part_64:  Int64;
    Part_16:  Word;
  end;

procedure RectifyHexString(var Str: String; ReqLength: Integer);

  Function StartsWithHexMark(const Str: String): Boolean;
  begin
  If Length(Str) > 0 then
    Result := Str[1] = '$'
  else
    Result := False;
  end;

begin
If not StartsWithHexMark(Str) then Str := '$' + Str;
Inc(ReqLength);
If Length(Str) < ReqLength then
  Str := Str + StringOfChar('0',ReqLength - Length(Str))
else
  Str := Copy(Str,1,ReqLength);
end;

//------------------------------------------------------------------------------

procedure ConvertExtendedToDouble(ExtendedPtr, DoublePtr: Pointer); register; {$IFNDEF PurePascal}assembler;{$ENDIF}
{$IFDEF PurePascal}
var
  Sign:     Boolean;
  Exponent: Integer;
  Mantissa: Int64;
begin
{$IFDEF Debug}{$MESSAGE Warning 'This code requires inspection.'}{$ENDIF}
Sign := (PByteArray(ExtendedPtr)^[9] and $80) <> 0;
Exponent := (Word(Addr(PByteArray(ExtendedPtr)^[8])^) and $7FFF);
Mantissa := (Int64(ExtendedPtr^) and $7FFFFFFFFFFFFFFF) shr 11;
If (Int64(ExtendedPtr^) and $7FF) > $400 then Inc(Mantissa);
case Exponent of
  $0:     begin
            Int64(DoublePtr^) := Int64(Sign) shr 63;
            Exit;
          end;
  $7FFF:  Exponent := $7FF;
else
  Exponent := Exponent - 16383 + 1023;
end;
case Exponent of
  Low(Integer)..-52:    begin
                          Int64(DoublePtr^) := Int64(Sign) shr 63;
                          Exit;
                        end;
  -51..-1:              Mantissa := Mantissa shr (-Exponent + 1);
  $7FF..High(Integer):  begin
                          Exponent := $7FF;
                          Mantissa := 0;
                        end;
end;
Int64(DoublePtr^) := Int64((Int64(Sign) shl 63) or (Int64(Exponent and $7FF) shl 52) or Mantissa);
end;
{$ELSE}
{$IFDEF FPC}{$ASMMODE intel}{$ENDIF}
asm
{$IFDEF x64}
  FLD   tbyte ptr [RCX]
  FSTP  qword ptr [RDX]
{$ELSE}
  FLD   tbyte ptr [EAX]
  FSTP  qword ptr [EDX]
{$ENDIF}
  FWAIT
end;
{$ENDIF}

//==============================================================================

Function SingleToHex(Value: Single): String;
var
  Overlay:  LongWord absolute Value;
begin
Result := IntToHex(Overlay,8);
end;

//------------------------------------------------------------------------------

Function HexToSingle(HexString: String): Single;
var
  Overlay:  LongWord;
  Num:      Single absolute Overlay;
begin
RectifyHexString(HexString,8);
Overlay := LongWord(StrToInt(HexString));
Result := Num;
end;

//------------------------------------------------------------------------------

Function TryHexToSingle(const HexString: String; out Value: Single): Boolean;
begin
try
  Value := HexToSingle(HexString);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function HexToSingleDef(const HexString: String; const DefaultValue: Single): Single;
begin
If not TryHexToSingle(HexString,Result) then
  Result := DefaultValue;
end;

//==============================================================================

Function DoubleToHex(Value: Double): String;
var
  Overlay:  Int64 absolute Value;
begin
Result := IntToHex(Overlay, 16);
end;

//------------------------------------------------------------------------------

Function HexToDouble(HexString: String): Double;
var
  Overlay:  Int64;
  Num:      Double absolute Overlay;
begin
RectifyHexString(HexString,16);
Overlay := StrToInt64(HexString);
Result := Num;
end;

//------------------------------------------------------------------------------

Function TryHexToDouble(const HexString: String; out Value: Double): Boolean;
begin
try
  Value := HexToDouble(HexString);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function HexToDoubleDef(const HexString: String; const DefaultValue: Double): Double;
begin
If not TryHexToDouble(HexString,Result) then
  Result := DefaultValue;
end;

//==============================================================================

Function ExtendedToHex(Value: Extended): String;
{$IFDEF Extended64}
begin
Result := DoubleToHex(Value);
end;
{$ELSE}
var
  Overlay: TOverlay_80b absolute Value;
begin
Result := IntToHex(Overlay.Part_16,4) + IntToHex(Overlay.Part_64,16);
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function HexToExtended(HexString: String): Extended;
var
  Overlay:  TOverlay_80b;
{$IFNDEF Extended64}
  Num:      Extended absolute Overlay;
{$ENDIF}
begin
RectifyHexString(HexString,20);
Overlay.Part_16 := Word(StrToInt(Copy(HexString,1,5)));
Overlay.Part_64 := StrToInt64('$' + Copy(HexString,6,16));
{$IFDEF Extended64}
ConvertExtendedToDouble(@Overlay,@Result);
{$ELSE}
Result := Num;
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function TryHexToExtended(const HexString: String; out Value: Extended): Boolean;
begin
try
  Value := HexToExtended(HexString);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function HexToExtendedDef(const HexString: String; const DefaultValue: Extended): Extended;
begin
If not TryHexToExtended(HexString,Result) then
  Result := DefaultValue;
end;

//==============================================================================

Function FloatToHex(Value: Single): String;
begin
Result := SingleToHex(Value);
end;

//------------------------------------------------------------------------------

Function HexToFloat(const HexString: String): Single;
begin
Result := HexToSingle(HexString);
end;

//------------------------------------------------------------------------------

Function TryHexToFloat(const HexString: String; out Value: Single): Boolean;
begin
Result := TryHexToSingle(HexString,Value);
end;

//------------------------------------------------------------------------------

Function HexToFloatDef(const HexString: String; const DefaultValue: Single): Single;
begin
Result := HexToSingleDef(HexString,DefaultValue);
end;

end.
