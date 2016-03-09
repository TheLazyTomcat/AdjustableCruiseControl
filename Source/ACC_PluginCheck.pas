{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_PluginCheck;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

const
  PCR_Ok               = 0;
  PCR_NotLibrary       = 1;
  PCR_InitNotExported  = 2;
  PCR_FinalNotExported = 3;
  PCR_ET_NotExtracted  = 4;
  PCR_ET_NotStarted    = 5;
  PCR_ET_WaitFailed    = 6;
  PCR_ET_NoExitCode    = 7;
  PCR_ET_NotDeleted    = 8;

Function ExternalPluginCheck(const FilePath: String): LongWord;
Function InternalPluginCheck(const FilePath: String): LongWord;

Function PluginCheck(const FilePath: String; Is64bit: Boolean): LongWord;

{$IF not Declared(FPC_FULLVERSION)}
const
  FPC_FULLVERSION = Integer(0);
{$IFEND}

implementation

uses
  Windows, SysUtils, Classes, ShellAPI,
  SCS_Telemetry_Condensed
  {$IF Defined(FPC) and not Defined(Unicode)}
  , LazUTF8
  {$IF FPC_FULLVERSION < 20701}
  , LazFileUtils
  {$IFEND}
  {$IFEND};

{$IFNDEF ExternalTester}
  {$IFDEF x64}
    {$R '.\Resources\ExternalTester_32.res'}
  {$ELSE}
    {$R '.\Resources\ExternalTester_64.res'}
  {$ENDIF}
{$ENDIF}

var
  DeferredDelete: String = '';

//------------------------------------------------------------------------------

Function ExtractTester(const ToFile: String): Boolean;
var
  ResStream: TResourceStream;
begin
try
  ResStream := TResourceStream.Create(hInstance,'tester',RT_RCDATA);
  try
  {$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
    ResStream.SaveToFile(UTF8ToSys(ToFile));
  {$ELSE}
    ResStream.SaveToFile(ToFile);
  {$IFEND}
    Result := True;
  finally
    ResStream.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function ExternalPluginCheck(const FilePath: String): LongWord;
var
  ExecFile:   String;
  ExecParam:  String;
  ExecInfo:   TShellExecuteInfo;
begin
Result := PCR_Ok;
{$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
ExecFile := ExtractFilePath(SysToUTF8(ParamStr(0))) + 'external_tester.exe';
{$ELSE}
ExecFile := ExtractFilePath(ParamStr(0)) + 'external_tester.exe';
{$IFEND}
ExecParam := '"' + FilePath + '"';
If ExtractTester(ExecFile) then
  begin
    FillChar({%H-}ExecInfo,SizeOf(ExecInfo),0);
    ExecInfo.cbSize := SizeOf(TShellExecuteInfo);
    ExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
  {$IF Defined(FPC) and not Defined(Unicode)}
    ExecInfo.lpFile := PChar(UTF8ToWinCP(ExecFile));
    ExecInfo.lpParameters := PChar(UTF8ToWinCP(ExecParam));
  {$ELSE}
    ExecInfo.lpFile := PChar(ExecFile);
    ExecInfo.lpParameters := PChar(ExecParam);
  {$IFEND}
    ExecInfo.nShow := SW_HIDE;
  {$IFDEF FPC}
    If ShellExecuteEx(LPShellExecuteInfoA(@ExecInfo)) then
  {$ELSE}
    If ShellExecuteEx(@ExecInfo) then
  {$ENDIF}
      begin
        If ExecInfo.hProcess <> 0 then
          begin
            If WaitForSingleObject(ExecInfo.hProcess,5000) = WAIT_OBJECT_0 then
              begin
                If not GetExitCodeProcess(ExecInfo.hProcess,Result) then
                  Result := PCR_ET_NoExitCode;
              end
            else Result := PCR_ET_WaitFailed;
            CloseHandle(ExecInfo.hProcess); 
          end;
      end
    else Result := PCR_ET_NotStarted;
  {$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
    If DeleteFileUTF8(ExecFile) then
  {$ELSE}
    If DeleteFile(ExecFile) then
  {$IFEND}
      DeferredDelete := ''
    else
      begin
        Result := PCR_ET_NotDeleted;
        DeferredDelete := ExecFile;
      end;
  end
else Result := PCR_ET_NotExtracted;
end;

//------------------------------------------------------------------------------

Function InternalPluginCheck(const FilePath: String): LongWord;
var
  ErrorMode:  LongWord;
  LibHandle:  HMODULE;
  InitFunc:   scs_telemetry_init_t;
  FinalFunc:  scs_telemetry_shutdown_t;
begin
Result := PCR_Ok;
ErrorMode := SetErrorMode(SEM_FAILCRITICALERRORS);
try
{$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
  LibHandle := LoadLibrary(PChar(UTF8ToWinCP(FilePath)));
{$ELSE}
  LibHandle := LoadLibrary(PChar(FilePath));
{$IFEND}
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
    FreeLibrary(LibHandle);
  end
else Result := PCR_NotLibrary;
end;

//------------------------------------------------------------------------------

Function PluginCheck(const FilePath: String; Is64bit: Boolean): LongWord;
begin
{$IFDEF x64}
If not Is64bit then
{$ELSE}
If Is64bit then
{$ENDIF}
  Result := ExternalPluginCheck(FilePath)
else
  Result := InternalPluginCheck(FilePath);
end;
 
//------------------------------------------------------------------------------

initialization

finalization
  If DeferredDelete <> '' then
  {$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
    DeleteFileUTF8(DeferredDelete);
  {$ELSE}
    DeleteFile(DeferredDelete);
  {$IFEND}

end.
