{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_PluginCheck;

interface

const
  PCR_Ok               = 0;
  PCR_NotLibrary       = 1;
  PCR_InitNotExported  = 2;
  PCR_FinalNotExported = 3;

Function PluginCheck(const FilePath: String; Is64bit: Boolean): LongWord;

implementation

uses
  Windows,
  SCS_Telemetry_Condensed;

Function External_PluginCheck(const FilePath: String): LongWord;
begin
{$message 'Implement'}
Result := LongWord(-1);
end;

//------------------------------------------------------------------------------

Function Internal_PluginCheck(const FilePath: String): LongWord;
var
  ErrorMode:  LongWord;
  LibHandle:  HMODULE;
  InitFunc:   scs_telemetry_init_t;
  FinalFunc:  scs_telemetry_shutdown_t;
begin
Result := PCR_Ok;
ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
try
  LibHandle := LoadLibrary(PChar(FilePath));
finally
  SetErrorMode(ErrorMode);
end;
If LibHandle <> 0 then
  begin
    InitFunc := GetProcAddress(LibHandle,'scs_telemetry_init');
    If Assigned(InitFunc) then
      begin
        FinalFunc := GetProcAddress(LibHandle,'scs_telemetry_shutdown');
        If not Assigned(FinalFunc) then
          Result := PCR_FinalNotExported;
      end
    else Result := PCR_InitNotExported;
  end
else Result := PCR_NotLibrary;
end;

//------------------------------------------------------------------------------

Function PluginCheck(const FilePath: String; Is64bit: Boolean): LongWord;
begin
{$IFDEF x64}
{$message 'Implement'}
Result := LongWord(-1);
{$ELSE}
If Is64bit then
  Result := External_PluginCheck(FilePath)
else
  Result := Internal_PluginCheck(FilePath);
{$ENDIF}
end;

end.
