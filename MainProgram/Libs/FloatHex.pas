{===============================================================================

Floating point numbers <> HexString conversion routines

©František Milt 2015-01-14

Version 1.2.3

===============================================================================}
unit FloatHex;

{$IFDEF x64}
  {$DEFINE Extended64}
{$ENDIF}

interface

Function SingleToHex(Value: Single): String;
Function HexToSingle(const HexString: String): Single;
Function HexToSingleDef(const HexString: String; const DefaultValue: Single): Single;
Function TryHexToSingle(const HexString: String; out Value: Single): Boolean;

Function DoubleToHex(Value: Double): String;
Function HexToDouble(const HexString: String): Double;
Function HexToDoubleDef(const HexString: String; const DefaultValue: Double): Double;
Function TryHexToDouble(const HexString: String; out Value: Double): Boolean;

Function ExtendedToHex(Value: Extended): String;
Function HexToExtended(const HexString: String): Extended;
Function HexToExtendedDef(const HexString: String; const DefaultValue: Extended): Extended;
Function TryHexToExtended(const HexString: String; out Value: Extended): Boolean;

//------------------------------------------------------------------------------

Function FloatToHex(Value: Single): String; overload;
Function FloatToHex(Value: Double): String; overload;
{$IFNDEF Extended64}
Function FloatToHex(Value: Extended): String; overload;
{$ENDIF}

Function HexToFloat(const HexString: String): Double; overload;

Function HexToFloatDef(const HexString: String; const DefaultValue: Single): Single; overload;
Function HexToFloatDef(const HexString: String; const DefaultValue: Double): Double; overload;
{$IFNDEF Extended64}
Function HexToFloatDef(const HexString: String; const DefaultValue: Extended): Extended; overload;
{$ENDIF}

Function TryHexToFloat(const HexString: String; out Value: Single): Boolean; overload;
Function TryHexToFloat(const HexString: String; out Value: Double): Boolean; overload;
{$IFNDEF Extended64}
Function TryHexToFloat(const HexString: String; out Value: Extended): Boolean; overload;
{$ENDIF}

implementation

uses
  SysUtils;

{$IFNDEF Extended64}
type
  TOverlay_80b = packed record
    Part_16:  Word;
    Part_64:  Int64;
  end;
{$ENDIF}

const
  cHexMark = '$';

Function StartsWithHexMark(const Str: String): Boolean;
begin
If Length(Str) > 0 then
  Result := Str[1] = cHexMark
else
  Result := False;
end;

//==============================================================================

Function SingleToHex(Value: Single): String;
var
  Overlay:  LongWord absolute Value;
begin
Result := IntToHex(Overlay, 8);
end;

//------------------------------------------------------------------------------

Function HexToSingle(const HexString: String): Single;
var
  Num:      Single;
  Overlay:  LongWord absolute Num;
begin
If StartsWithHexMark(HexString) then Overlay := StrToInt(HexString)
  else Overlay := StrToInt(cHexMark + HexString);
Result := Num;
end;

//------------------------------------------------------------------------------

Function HexToSingleDef(const HexString: String; const DefaultValue: Single): Single;
begin
try
  Result := HexToSingle(HexString);
except
  Result := DefaultValue;
end;
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

//==============================================================================

Function DoubleToHex(Value: Double): String;
var
  Overlay:  Int64 absolute Value;
begin
Result := IntToHex(Overlay, 16);
end;

//------------------------------------------------------------------------------

Function HexToDouble(const HexString: String): Double;
var
  Num:      Double;
  Overlay:  Int64 absolute Num;
begin
If StartsWithHexMark(HexString) then Overlay := StrToInt64(HexString)
  else Overlay := StrToInt64(cHexMark + HexString);
Result := Num;
end;

//------------------------------------------------------------------------------

Function HexToDoubleDef(const HexString: String; const DefaultValue: Double): Double;
begin
try
  Result := HexToDouble(HexString);
except
  Result := DefaultValue;
end;
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
Result := IntToHex(Overlay.Part_64,16) + IntToHex(Overlay.Part_16,4);
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function HexToExtended(const HexString: String): Extended;
{$IFDEF Extended64}
begin
Result := HexToDouble(HexString);
end;
{$ELSE}
var
  Num:      Extended;
  Overlay:  TOverlay_80b absolute Num;
begin
If StartsWithHexMark(HexString) then
  begin
    Overlay.Part_64 := StrToInt64(Copy(HexString,1,17));
    Overlay.Part_16 := StrToInt('$' + Copy(HexString,18,4));
  end
else
  begin
    Overlay.Part_64 := StrToInt64('$' + Copy(HexString,1,16));
    Overlay.Part_16 := StrToInt('$' + Copy(HexString,17,4));
  end;
Result := Num;
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function HexToExtendedDef(const HexString: String; const DefaultValue: Extended): Extended;
begin
try
  Result := HexToExtended(HexString);
except
  Result := DefaultValue;
end;
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

//******************************************************************************
//******************************************************************************

Function FloatToHex(Value: Single): String;
begin
Result := SingleToHex(Value);
end;

//------------------------------------------------------------------------------

Function FloatToHex(Value: Double): String;
begin
Result := DoubleToHex(Value);
end;

//------------------------------------------------------------------------------

{$IFNDEF Extended64}
Function FloatToHex(Value: Extended): String;
begin
Result := ExtendedToHex(Value);
end;
{$ENDIF}

//==============================================================================

Function HexToFloat(const HexString: String): Double;
begin
Result := HexToDouble(HexString);
end;    

//==============================================================================

Function HexToFloatDef(const HexString: String; const DefaultValue: Single): Single;
begin
Result := HexToSingleDef(HexString,DefaultValue);
end;

//------------------------------------------------------------------------------

Function HexToFloatDef(const HexString: String; const DefaultValue: Double): Double;
begin
Result := HexToDoubleDef(HexString,DefaultValue);
end;

//------------------------------------------------------------------------------

{$IFNDEF Extended64}
Function HexToFloatDef(const HexString: String; const DefaultValue: Extended): Extended;
begin
Result := HexToExtendedDef(HexString,DefaultValue);
end;
{$ENDIF}

//==============================================================================

Function TryHexToFloat(const HexString: String; out Value: Single): Boolean;
begin
Result := TryHexToSingle(HexString,Value);
end;

//------------------------------------------------------------------------------

Function TryHexToFloat(const HexString: String; out Value: Double): Boolean;
begin
Result := TryHexToDouble(HexString,Value);
end;

//------------------------------------------------------------------------------

{$IFNDEF Extended64}
Function TryHexToFloat(const HexString: String; out Value: Extended): Boolean;
begin
Result := TryHexToExtended(HexString,Value);
end;
{$ENDIF}

end.
