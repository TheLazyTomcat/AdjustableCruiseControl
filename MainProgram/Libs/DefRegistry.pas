{===============================================================================

DefRegistry

©František Milt 2012-01-28

Version 1.0

===============================================================================}
unit DefRegistry;

interface

uses
  Registry, DateUtils;

type
  TDefRegistry = class(TRegistry)
  public
    Function ReadCurrencyDef(const Name: String; const DefaultValue: Currency): Currency;
    Function ReadBinaryDataDef(const Name: String; var Buffer; BufSize: Integer; const DefaultBuffer): Integer;
    Function ReadBoolDef(const Name: String; const DefaultValue: Boolean): Boolean;
    Function ReadDateDef(const Name: String; const DefaultValue: TDateTime): TDateTime;
    Function ReadDateTimeDef(const Name: String; const DefaultValue: TDateTime): TDateTime;
    Function ReadFloatDef(const Name: String; const DefaultValue: Double): Double;
    Function ReadIntegerDef(const Name: String; const DefaultValue: Integer): Integer;
    Function ReadStringDef(const Name: String; const DefaultValue: String): String;
    Function ReadTimeDef(const Name: String; const DefaultValue: TDateTime): TDateTime;
  end;

implementation

Function TDefRegistry.ReadCurrencyDef(const Name: String; const DefaultValue: Currency): Currency;
begin
try
  If ValueExists(Name) then 
    Result := ReadCurrency(Name) 
  else 
    Result := DefaultValue;
except
  Result := DefaultValue;
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadBinaryDataDef(const Name: String; var Buffer; BufSize: Integer; const DefaultBuffer): Integer;
begin
try
  If ValueExists(Name) then 
    Result := ReadBinaryData(Name,Buffer,BufSize) 
  else
    begin
      Move(DefaultBuffer,Buffer,BufSize);
      Result := BufSize;
    end;
except
  Result := 0;
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadBoolDef(const Name: String; const DefaultValue: Boolean): Boolean;
begin
try
  If ValueExists(Name) then 
    Result := ReadBool(Name) 
  else 
    Result := DefaultValue;
except
  Result := DefaultValue;
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadDateDef(const Name: String; const DefaultValue: TDateTime): TDateTime;
begin
try
  If ValueExists(Name) then 
    Result := ReadDate(Name) 
  else 
    Result := DateOf(DefaultValue);
except
  Result := DateOf(DefaultValue);
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadDateTimeDef(const Name: String; const DefaultValue: TDateTime): TDateTime;
begin
try
  If ValueExists(Name) then 
    Result := ReadDateTime(Name) 
  else 
    Result := DefaultValue;
except
  Result := DefaultValue;
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadFloatDef(const Name: String; const DefaultValue: Double): Double;
begin
try
  If ValueExists(Name) then 
    Result := ReadFloat(Name) 
  else 
    Result := DefaultValue;
except
  Result := DefaultValue;
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadIntegerDef(const Name: String; const DefaultValue: Integer): Integer;
begin
try
  If ValueExists(Name) then 
    Result := ReadInteger(Name) 
  else 
    Result := DefaultValue;
except
  Result := DefaultValue;
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadStringDef(const Name: String; const DefaultValue: String): String;
begin
try
  If ValueExists(Name) then 
    Result := ReadString(Name) 
  else 
    Result := DefaultValue;
except
  Result := DefaultValue;
end;
end;

//------------------------------------------------------------------------------

Function TDefRegistry.ReadTimeDef(const Name: String; const DefaultValue: TDateTime): TDateTime;
begin
try
  If ValueExists(Name) then 
    Result := ReadTime(Name) 
  else 
    Result := TimeOf(DefaultValue);
except
  Result := TimeOf(DefaultValue);
end;
end;

end.
