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

implementation

uses
  Windows, SysUtils, Classes, ShellAPI,
  SCS_Telemetry_Condensed;

{$IFNDEF ExternalTester}
  {$IFDEF x64}
    {$R '.\Resources\ExternalTester_32.res'}
  {$ELSE}
    {$R '.\Resources\ExternalTester_64.res'}
  {$ENDIF}
{$ENDIF}  

//------------------------------------------------------------------------------

Function ExtractTester(const ToFile: String): Boolean;
var
  ResStream: TResourceStream;
begin
try
  ResStream := TResourceStream.Create(hInstance,'tester',RT_RCDATA);
  try
    ResStream.SaveToFile(ToFile);
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
ExecFile := ExtractFilePath(ParamStr(0)) + 'external_tester.exe';
ExecParam := '"' + FilePath + '"';
If ExtractTester(ExecFile) then
  begin
    FillChar({%H-}ExecInfo,SizeOf(ExecInfo),0);
    ExecInfo.cbSize := SizeOf(TShellExecuteInfo);
    ExecInfo.fMask := SEE_MASK_NOCLOSEPROCESS;
    ExecInfo.lpFile := PChar(ExecFile);
    ExecInfo.lpParameters := PChar(ExecParam);
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
    If not DeleteFile(ExecFile) then Result := PCR_ET_NotDeleted;
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
If not Is64bit then
{$ELSE}
If Is64bit then
{$ENDIF}
  Result := ExternalPluginCheck(FilePath)
else
  Result := InternalPluginCheck(FilePath);
end;

end.
