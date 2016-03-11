{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_PluginLauncher;

interface

{$INCLUDE ACC_Defs.inc}

uses
  SCS_Telemetry_Condensed;

type
  TGameLogProc = procedure(Text: String; MsgType: scs_log_type_t = SCS_LOG_TYPE_error) of object;

procedure RunMainProgram_Shell(const FilePath: String; WriteToGameLog: TGameLogProc);
procedure RunMainProgram_TaskScheduler(const FilePath: String; WriteToGameLog: TGameLogProc);

Function DeleteTask: Boolean;

{$IF not Declared(FPC_FULLVERSION)}
const
  FPC_FULLVERSION = Integer(0);
{$IFEND}

implementation

uses
  Windows, SysUtils, ShellAPI, ActiveX,
  WinTaskScheduler
  {$IF Defined(FPC) and not Defined(Unicode)}
  , LazUTF8
  {$IF FPC_FULLVERSION < 20701}
  , LazFileUtils
  {$IFEND}
  {$IFEND};

type
{$MINENUMSIZE 4}
  EXTENDED_NAME_FORMAT = (
    NameUnknown          = 0,
    NameFullyQualifiedDN = 1,
    NameSamCompatible    = 2,
    NameDisplay          = 3,
    NameUniqueId         = 6,
    NameCanonical        = 7,
    NameUserPrincipal    = 8,
    NameCanonicalEx      = 9,
    NameServicePrincipal = 10,
    NameDnsDomain        = 12);

Function GetUserNameExW(NameFormat: EXTENDED_NAME_FORMAT; lpNameBuffer: PWideChar; lpnSize: PULONG): ByteBool; stdcall; external 'secur32.dll';
Function GetUserNameExA(NameFormat: EXTENDED_NAME_FORMAT; lpNameBuffer: PAnsiChar; lpnSize: PULONG): ByteBool; stdcall; external 'secur32.dll';
Function GetUserNameEx(NameFormat: EXTENDED_NAME_FORMAT; lpNameBuffer: PChar; lpnSize: PULONG): ByteBool; stdcall; external 'secur32.dll' name {$IFDEF Unicode} 'GetUserNameExW'{$ELSE} 'GetUserNameExA'{$ENDIF};

//==============================================================================

const
  TaskName:    WideString = 'ACC - Main program launch from plugin';
  TaskComment: WideString = 'You can delete this task.';

//------------------------------------------------------------------------------

Function GetAccountName: WideString;
var
  AccountNameLen: ULONG;
begin
AccountNameLen := 0;
GetUserNameExW(NameSamCompatible,nil,@AccountNameLen);
SetLength(Result,AccountNameLen);
If not GetUserNameExW(NameSamCompatible,PWideChar(Result),@AccountNameLen) then
  raise Exception.CreateFmt('Cannot obtain account name (0x%.8x).',[GetLastError]);
end;

//------------------------------------------------------------------------------

Function DeleteTask: Boolean;
var
  TaskScheduler:  ITaskScheduler;
begin
Result := False;
If Succeeded(CoInitialize(nil)) then
try
  If Succeeded(CoCreateInstance(CLSID_CTaskScheduler,nil,CLSCTX_INPROC_SERVER,IID_ITaskScheduler,TaskScheduler)) then
  try
    Result := Succeeded(TaskScheduler.Delete(LPCWSTR(TaskName)));
  finally
    TaskScheduler := nil; // TaskScheduler.Release
  end;
finally
  CoUninitialize;
end;
end;

//------------------------------------------------------------------------------

Function CreateTask(const MainProgramPath: String): Boolean;
var
  TaskScheduler:    ITaskScheduler;
  Task:             ITask;
  PersistFile:      IPersistFile;
  WorkingDirectory: WideString;
  ApplicationName:  WideString;
begin
Result := False;
If Succeeded(CoInitialize(nil)) then
try
  If Succeeded(CoCreateInstance(CLSID_CTaskScheduler,nil,CLSCTX_INPROC_SERVER,IID_ITaskScheduler,TaskScheduler)) then
  try
    If Succeeded(TaskScheduler.NewWorkItem(LPCWSTR(TaskName),@CLSID_Ctask,@IID_ITask,@Task)) then
      try
      {$IF Defined(FPC) and not Defined(Unicode)}
        WorkingDirectory := UTF8ToUTF16(ExtractFilePath(MainProgramPath));
        ApplicationName := UTF8ToUTF16(MainProgramPath);
      {$ELSE}
        WorkingDirectory := ExtractFilePath(MainProgramPath);
        ApplicationName := MainProgramPath;
      {$IFEND}
        Task.SetWorkingDirectory(LPCWSTR(WorkingDirectory));
        Task.SetApplicationName(LPCWSTR(ApplicationName));
        Task.SetComment(LPCWSTR(TaskComment));
        Task.SetFlags(TASK_FLAG_RUN_ONLY_IF_LOGGED_ON);
        Task.SetAccountInformation(LPCWSTR(GetAccountName),nil);
        If Succeeded(Task.QueryInterface(IID_IPersistFile,PersistFile)) then
        try
          PersistFile.Save(nil,True);
        finally
          PersistFile := nil; // PersistFile.Release
        end;
        Result := True;
      finally
        Task := nil; //Task.Release
      end
    else Result := False;
  finally
    TaskScheduler := nil; // TaskScheduler.Release
  end;
finally
  CoUninitialize;
end;
end;

//------------------------------------------------------------------------------

Function RunTask: Boolean;
var
  TaskScheduler:  ITaskScheduler;
  Task:           ITask;
begin
Result := False;
If Succeeded(CoInitialize(nil)) then
try
  If Succeeded(CoCreateInstance(CLSID_CTaskScheduler,nil,CLSCTX_INPROC_SERVER,IID_ITaskScheduler,TaskScheduler)) then
  try
    If Succeeded(TaskScheduler.Activate(LPCWSTR(TaskName),@IID_ITask,@Task)) then
    try
      Result := Succeeded(Task.Run);
    finally
      Task := nil; // Task.Release
    end;
  finally
    TaskScheduler := nil; // TaskScheduler.Release
  end;
finally
  CoUninitialize;
end;
end;

//==============================================================================

procedure RunMainProgram_Shell(const FilePath: String; WriteToGameLog: TGameLogProc);
{$IFDEF Debug}
var
  ExecResult: Integer;
{$ENDIF}
begin
try
{$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
  If FileExistsUTF8(FilePath) then
{$ELSE}
  If FileExists(FilePath) then
{$IFEND}
    begin
    {$IFDEF Debug}
    {$IF Defined(FPC) and not Defined(Unicode)}
      ExecResult := Integer(ShellExecute(0,'open',PChar(UTF8ToWinCP(FilePath)),nil,nil,SW_SHOWNORMAL));
    {$ELSE}
      ExecResult := Integer(ShellExecute(0,'open',PChar(FilePath),nil,nil,SW_SHOWNORMAL));
    {$IFEND}
      case ExecResult of
        0:                      WriteToGameLog('[ACC] ShellExec: The operating system is out of memory or resources');
      //ERROR_FILE_NOT_FOUND:   WriteToGameLog('[ACC] ShellExec: The specified file was not found');
      //ERROR_PATH_NOT_FOUND:   WriteToGameLog('[ACC] ShellExec: The specified path was not found');
        ERROR_BAD_FORMAT:       WriteToGameLog('[ACC] ShellExec: The .exe file is invalid');
        SE_ERR_ACCESSDENIED:    WriteToGameLog('[ACC] ShellExec: The operating system denied access to the specified file');
        SE_ERR_ASSOCINCOMPLETE: WriteToGameLog('[ACC] ShellExec: The file name association is incomplete or invalid');
        SE_ERR_DDEBUSY:         WriteToGameLog('[ACC] ShellExec: The DDE transaction could not be completed because other DDE transactions were being processed');
        SE_ERR_DDEFAIL:         WriteToGameLog('[ACC] ShellExec: The DDE transaction failed');
        SE_ERR_DDETIMEOUT:      WriteToGameLog('[ACC] ShellExec: The DDE transaction could not be completed because the request timed out');
        SE_ERR_DLLNOTFOUND:     WriteToGameLog('[ACC] ShellExec: The specified DLL was not found');
        SE_ERR_FNF:             WriteToGameLog('[ACC] ShellExec: The specified file was not found');
        SE_ERR_NOASSOC:         WriteToGameLog('[ACC] ShellExec: There is no application associated with the given file name extension');
        SE_ERR_OOM:             WriteToGameLog('[ACC] ShellExec: There was not enough memory to complete the operation');
        SE_ERR_PNF:             WriteToGameLog('[ACC] ShellExec: The specified path was not found');
        SE_ERR_SHARE:           WriteToGameLog('[ACC] ShellExec: A sharing violation occurred');
      else
        If ExecResult > 32 then
          WriteToGameLog('[ACC] ShellExec: Program started',SCS_LOG_TYPE_message)
        else
          WriteToGameLog(Format('[ACC] ShellExec: Unknown error (%d) occured',[ExecResult]));
      end;
    {$ELSE}
    {$IF Defined(FPC) and not Defined(Unicode)}
      ShellExecute(0,'open',PChar(UTF8ToWinCP(FilePath)),nil,nil,SW_SHOWNORMAL);
    {$ELSE}
      ShellExecute(0,'open',PChar(FilePath),nil,nil,SW_SHOWNORMAL);
    {$IFEND}
    {$ENDIF}
    end
  else {$IFDEF Debug}WriteToGameLog('[ACC] ShellExec: File not found.'){$ENDIF};
except
  on E: Exception do
    WriteToGameLog(E.Message);
end;
end;

//------------------------------------------------------------------------------

procedure RunMainProgram_TaskScheduler(const FilePath: String; WriteToGameLog: TGameLogProc);
begin
try
  DeleteTask;
  If not CreateTask(FilePath) then
    {$IFDEF Debug}WriteToGameLog(Format('[ACC] TSCHExec: Cannot create task "%s".',[TaskName])){$ENDIF};
  If not RunTask then
  {$IFDEF Debug}
    WriteToGameLog(Format('[ACC] TSCHExec: Cannot run task "%s".',[TaskName]))
  else
    WriteToGameLog('[ACC] TSCHExec: Program started',SCS_LOG_TYPE_message){$ENDIF};
except
  on E: Exception do
    WriteToGameLog(E.Message);
end;
end;

end.
