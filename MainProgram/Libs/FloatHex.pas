{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Floating point numbers <-> HexString conversion routines

  ©František Milt 2015-12-11

  Version 1.4

===============================================================================}
unit FloatHex;

{$IF defined(CPUX86_64) or defined(CPUX64)}
  {$DEFINE x64}
  {$IF not(defined(WINDOWS) or defined(MSWINDOWS))}
    {$DEFINE PurePascal}
  {$IFEND}
{$ELSEIF defined(CPU386)}
  {$DEFINE x86}
{$ELSE}
  {$DEFINE PurePascal}
{$IFEND}

{$IF defined(FPC) and not defined(PurePascal)}
  {$ASMMODE Intel}
{$IFEND}

{$IFDEF ENDIAN_BIG}
  {$MESSAGE FATAL 'Big-endian system not supported'}
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

Function FloatToHex(Value: Double): String; overload;
Function HexToFloat(const HexString: String): Double; overload;
Function TryHexToFloat(const HexString: String; out Value: Double): Boolean; overload;
Function HexToFloatDef(const HexString: String; const DefaultValue: Double): Double; overload;

implementation

{$IF SizeOf(Extended) = 8}
  {$DEFINE Extended64}
{$ELSE}
  {$UNDEF Extended64}
{$IFEND}

uses
  SysUtils, AuxTypes;

type
  // overlay used when working with 10-byte extended precision float
  TExtendedOverlay = packed record
    Part_64:  UInt64;
    Part_16:  UInt16;
  end;

//= Auxiliary functions ========================================================

procedure RectifyHexString(var Str: String; RequiredLength: Integer);

  Function StartsWithHexMark(const Str: String): Boolean;
  begin
  If Length(Str) > 0 then
    Result := Str[1] = '$'
  else
    Result := False;
  end;

begin
If not StartsWithHexMark(Str) then Str := '$' + Str;
Inc(RequiredLength);
If Length(Str) <> RequiredLength then
  begin
    If Length(Str) < RequiredLength then
      Str := Str + StringOfChar('0',RequiredLength - Length(Str))
    else
      Str := Copy(Str,1,RequiredLength);
  end;
end;

//------------------------------------------------------------------------------

procedure ConvertExtendedToDouble(ExtendedPtr, DoublePtr: Pointer); register; {$IFNDEF PurePascal}assembler;
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
{$ELSE PurePascal}
const
  Infinity = UInt64($7FF0000000000000);
  NaN      = UInt64($7FF8000000000000);
var
  Sign:     UInt64;
  Exponent: Int32;
  Mantissa: UInt64;

  Function MantissaShift(Value: UInt64; Shift: Byte): UInt64;
  var
    ShiftedOut: UInt64;
    Threshold:  UInt64;
  begin
    If (Shift > 0) and (Shift <= 64) then
      begin
        Result := Value shr Shift;
        ShiftedOut := Value and (UInt64($FFFFFFFFFFFFFFFF) shr (64 - Shift));
        Threshold := UInt64(1) shl (Shift - 1);
        If (ShiftedOut > Threshold) or ((ShiftedOut = Threshold) and ((Result and 1) <> 0)) then
          Inc(Result)
      end
    else Result := Value;     
  end;

begin
Sign := UInt64({%H-}PUInt8({%H-}PtrUInt(ExtendedPtr) + 9)^ and $80) shl 56;
Exponent := Int32({%H-}PUInt16({%H-}PtrUInt(ExtendedPtr) + 8)^ and $7FFF);
Mantissa := (UInt64(ExtendedPtr^) and UInt64($7FFFFFFFFFFFFFFF));
case Exponent of
          // zero or denormal (denormal cannot be represented as double and is
          // therefore converted to signed zero)
  0:      UInt64(DoublePtr^) := Sign;

          // exponent is too small to be represented in double even as subnormal,
          // return signed zero
  1..
  $3BCB:  UInt64(DoublePtr^) := Sign;

          // subnormal values (resulting exponent in double is 0)
  $3BCC..
  $3C00:  UInt64(DoublePtr^) := Sign or MantissaShift((Mantissa or UInt64($8000000000000000)),$3C01 - Exponent + 11);

          // exponent is too large to be represented in double (resulting
          // exponent would be larger than $7FE), converting to signed infinity
  $43FF..
  $7FFE:  UInt64(DoublePtr^) := Sign or Infinity;

          // special cases (inf, NaN, ...)
  $7FFF:  case UInt64(ExtendedPtr^) shr 62 of
            0,
            1:  raise EInvalidOp.Create('Invalid floating point operand');
            2:  If (UInt64(ExtendedPtr^) and UInt64($3FFFFFFFFFFFFFFF)) = 0 then
                    // signed infinity
                    UInt64(DoublePtr^) := Sign or Infinity
                  else
                    // signaling NaN
                    raise EInvalidOp.Create('Invalid floating point operand');
                // quiet signed NaN with mantissa
            3:  UInt64(DoublePtr^) := Sign or NaN or (Mantissa shr 11);
          else
            // unknown case, return positive NaN
            UInt64(DoublePtr^) := NaN;
          end;
else
  // representable number or unnormal
  If (UInt64(ExtendedPtr^) and UInt64($8000000000000000)) <> 0 then
    begin
      // normalized value
      Exponent := Exponent - 15360; // 15360 = $3FFF - $3FF
      // mantissa shift correction
      Mantissa := MantissaShift(Mantissa,11);
      If (Mantissa and UInt64($0010000000000000)) <> 0 then
        Inc(Exponent);
      UInt64(DoublePtr^) := Sign or (UInt64(Exponent and $7FF) shl 52) or (Mantissa and UInt64($000FFFFFFFFFFFFF));
    end
  else
    // Unnormal, invalid operand
    raise EInvalidOp.Create('Invalid floating point operand');
end;
end;
{$ENDIF PurePascal}

//==============================================================================

Function SingleToHex(Value: Single): String;
var
  Overlay:  UInt32 absolute Value;
begin
Result := IntToHex(Overlay,8);
end;

//------------------------------------------------------------------------------

Function HexToSingle(HexString: String): Single;
var
  Overlay:  UInt32;
  Num:      Single absolute Overlay;
begin
RectifyHexString(HexString,8);
Overlay := UInt32(StrToInt(HexString));
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
  Overlay:  UInt64 absolute Value;
begin
Result := IntToHex(Overlay,16);
end;

//------------------------------------------------------------------------------

Function HexToDouble(HexString: String): Double;
var
  Overlay:  UInt64;
  Num:      Double absolute Overlay;
begin
RectifyHexString(HexString,16);
Overlay := UInt64(StrToInt64(HexString));
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
  Overlay: TExtendedOverlay absolute Value;
begin
Result := IntToHex(Overlay.Part_16,4) + IntToHex(Overlay.Part_64,16);
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function HexToExtended(HexString: String): Extended;
var
  Overlay:  TExtendedOverlay;
{$IFNDEF Extended64}
  Num:      Extended absolute Overlay;
{$ENDIF}
begin
RectifyHexString(HexString,20);
Overlay.Part_16 := UInt16(StrToInt(Copy(HexString,1,5)));
Overlay.Part_64 := UInt64(StrToInt64('$' + Copy(HexString,6,16)));
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

Function FloatToHex(Value: Double): String;
begin
Result := DoubleToHex(Value);
end;

//------------------------------------------------------------------------------

Function HexToFloat(const HexString: String): Double;
begin
Result := HexToDouble(HexString);
end;

//------------------------------------------------------------------------------

Function TryHexToFloat(const HexString: String; out Value: Double): Boolean;
begin
Result := TryHexToDouble(HexString,Value);
end;

//------------------------------------------------------------------------------

Function HexToFloatDef(const HexString: String; const DefaultValue: Double): Double;
begin
Result := HexToDoubleDef(HexString,DefaultValue);
end;

end.
