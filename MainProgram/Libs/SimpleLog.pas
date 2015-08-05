{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

SimpleLog

©František Milt 2015-05-06

Version 1.3.2

===============================================================================}
{$IFNDEF SimpleLog_Include}
unit SimpleLog;
{$ENDIF}

interface

uses
  SysUtils, Classes, Contnrs, SyncObjs;

type
  TLogEvent = procedure(Sender: TObject; LogText: String) of Object;

{==============================================================================}
{    TSimpleLog // Class declaration                                           }
{==============================================================================}
  TSimpleLog = class(TObject)
  private
    fFormatSettings:          TFormatSettings;
    fTimeFormat:              String;
    fTimeSeparator:           String;
    fTimeOfCreation:          TDateTime;
    fBreaker:                 String;
    fHeaderText:              String;
    fIndentNewLines:          Boolean;
    fThreadLocked:            Boolean;
    fInternalLog:             Boolean;
    fWriteToConsole:          Boolean;
    fStreamToFile:            Boolean;
    fConsoleBinded:           Boolean;
    fStreamAppend:            Boolean;
    fStreamFileName:          String;
    fStreamFileAccessRights:  Cardinal;
    fForceTime:               Boolean;
    fForcedTime:              TDateTIme;
    fLogCounter:              Integer;
    fThreadLock:              TCriticalSection;
    fInternalLogObj:          TStringList;
    fExternalLogs:            TObjectList;
    fStreamFile:              TFileStream;
    fConsoleBindMutex:        THandle;
    fOnLog:                   TLogEvent;
    procedure SetWriteToConsole(Value: Boolean);    
    procedure SetStreamToFile(Value: Boolean);
    procedure SetStreamFileName(Value: String);
    Function GetInternalLogCount: Integer;
    Function GetExternalLogsCount: Integer;    
    Function GetExternalLog(Index: Integer): TStrings;
  protected
    Function ReserveConsoleBind: Boolean; virtual;
    Function GetCurrentTime: TDateTime; virtual;
    Function GetDefaultStreamFileName: String; virtual;
    Function GetTimeAsStr(Time: TDateTime; const Format: String = '$'): String; virtual;
    procedure DoIndentNewLines(var Str: String; IndentCount: Integer); virtual;    
    procedure ProtectedAddLog(LogText: String; IndentCount: Integer = 0; LineBreak: Boolean = True); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure ThreadLock; virtual;
    procedure ThreadUnlock; virtual;
    procedure AddLogNoTime(const Text: String); virtual;
    procedure AddLogTime(const Text: String; Time: TDateTime); virtual;
    procedure AddLog(const Text: String); virtual;
    procedure AddEmpty; virtual;
    procedure AddBreaker; virtual;
    procedure AddTimeStamp; virtual;
    procedure AddStartStamp; virtual;
    procedure AddEndStamp; virtual;
    procedure AddAppendStamp; virtual;
    procedure AddHeader; virtual;
    procedure ForceTimeSet(Time: TDateTime); virtual;
    Function InternalLogGetLog(LogIndex: Integer): String; virtual;
    Function InternalLogGetAsText: String; virtual;
    procedure InternalLogClear; virtual;
    Function InternalLogSaveToFile(const FileName: String; Append: Boolean = False): Boolean; virtual;
    Function InternalLogLoadFromFile(const FileName: String; Append: Boolean = False): Boolean; virtual;
    Function BindConsole: Boolean; virtual;
    procedure UnbindConsole; virtual;
    Function ExternalLogAdd(ExternalLog: TStrings): Integer; virtual;
    Function ExternalLogIndexOf(ExternalLog: TStrings): Integer; virtual;
    Function ExternalLogRemove(ExternalLog: TStrings): Integer; virtual;
    procedure ExternalLogDelete(Index: Integer); virtual;
    property FormatSettings: TFormatSettings read fFormatSettings write fFormatSettings;
    property ExternalLogs[Index: Integer]: TStrings read GetExternalLog; default;
  published
    property TimeFormat: String read fTimeFormat write fTimeFormat;
    property TimeSeparator: String read fTimeSeparator write fTimeSeparator;
    property TimeOfCreation: TDateTime read fTimeOfCreation;
    property Breaker: String read fBreaker write fBreaker;
    property HeaderText: String read fHeaderText write fHeaderText;
    property IndentNewLines: Boolean read fIndentNewLines write fIndentNewLines;
    property ThreadLocked: Boolean read fThreadLocked write fThreadLocked;
    property InternalLog: Boolean read fInternalLog write fInternalLog;
    property WriteToConsole: Boolean read fWriteToConsole write SetWriteToConsole;
    property StreamToFile: Boolean read fStreamToFile write SetStreamToFile;
    property ConsoleBinded: Boolean read fConsoleBinded write fConsoleBinded;
    property StreamAppend: Boolean read fStreamAppend write fStreamAppend;
    property StreamFileName: String read fStreamFileName write SetStreamFileName;
    property StreamFileAccessRights: Cardinal read fStreamFileAccessRights write fStreamFileAccessRights;
    property ForceTime: Boolean read fForceTime write fForceTime;
    property ForcedTime: TDateTIme read fForcedTime write fForcedTime;
    property LogCounter: Integer read fLogCounter;
    property InMemoryLogCount: Integer read GetInternalLogCount;
    property ExternalLogsCount: Integer read GetExternalLogsCount;
    property OnLog: TLogEvent read fOnLog write fOnLog;
  end;


{$IFDEF SimpleLog_Include}
var
  LogActive:      Boolean = False;
  LogFileName:    String = '';
{$ENDIF}

implementation

uses
  Windows, StrUtils;

{==============================================================================}
{    TSimpleLog // Console binding                                             }
{==============================================================================}

type
  IOFunc = Function(var F: TTextRec): Integer;

const
  ERR_SUCCESS                 = 0;
  ERR_UNSUPPORTED_MODE        = 10;
  ERR_WRITE_FAILED            = 11;
  ERR_READ_FAILED             = 12;
  ERR_FLUSH_FUNC_NOT_ASSIGNED = 13;

  UDI_OUTFILE = 1;

//------------------------------------------------------------------------------

Function SLCB_Output(var F: TTextRec): Integer;
var
  BytesWritten: LongWord;
  StrBuffer:    String;
begin
If WriteConsole(F.Handle,F.BufPtr,F.BufPos,{%H-}BytesWritten,nil) then
  begin
    SetLength(StrBuffer,F.BufPos);
    Move(F.Buffer,PChar(StrBuffer)^,F.BufPos * SizeOf(Char));
    TSimpleLog(Addr(F.UserData[UDI_OUTFILE])^).ProtectedAddLog(StrBuffer,0,False);
    Result := ERR_SUCCESS;
  end
else Result := ERR_WRITE_FAILED;
F.BufPos := 0;
end;

//------------------------------------------------------------------------------

Function SLCB_Input(var F: TTextRec): Integer;
var
  BytesRead:  LongWord;
  StrBuffer:  String;
begin
If ReadConsole(F.Handle,F.BufPtr,F.BufSize,{%H-}BytesRead,nil) then
  begin
    SetLength(StrBuffer,BytesRead);
    Move(F.Buffer,PChar(StrBuffer)^,BytesRead * SizeOf(Char));
    TSimpleLog(Addr(F.UserData[UDI_OUTFILE])^).ProtectedAddLog(StrBuffer,0,False);
    F.bufend := BytesRead;
    Result := ERR_SUCCESS;
  end
else Result := ERR_READ_FAILED;
F.BufPos := 0;
end;

//------------------------------------------------------------------------------

Function SLCB_Flush(var F: TTextRec): Integer;
begin
case F.Mode of
  fmOutput: begin
              If Assigned(F.InOutFunc) then IOFunc(F.InOutFunc)(F);
              Result := ERR_SUCCESS;
            end;
  fmInput:  begin
              F.BufPos := 0;
              F.BufEnd := 0;
              Result := ERR_SUCCESS;
            end;
else
  Result := ERR_UNSUPPORTED_MODE;
end;
end;

//------------------------------------------------------------------------------

Function SLCB_Open(var F: TTextRec): Integer;
begin
case F.Mode of
  fmOutput: begin
              F.Handle := GetStdHandle(STD_OUTPUT_HANDLE);
              F.InOutFunc := @SLCB_Output;
              Result := ERR_SUCCESS;
            end;
  fmInput:  begin
              F.Handle := GetStdHandle(STD_INPUT_HANDLE);
              F.InOutFunc := @SLCB_Input;
              Result := ERR_SUCCESS;
            end;
else
  Result := ERR_UNSUPPORTED_MODE;
end;
end;

//------------------------------------------------------------------------------

Function SLCB_Close(var F: TTextRec): Integer;
begin
If Assigned(F.FlushFunc) then
  Result := IOFunc(F.FlushFunc)(F)
else
  Result := ERR_FLUSH_FUNC_NOT_ASSIGNED;
F.Mode := fmClosed;
end;

//------------------------------------------------------------------------------

procedure AssignSLCB(var T: Text; LogObject: TSimpleLog);
begin
with TTextRec(T) do
  begin
    Mode := fmClosed;
  {$IFDEF FPC}
    LineEnd := sLineBreak;
  {$ELSE}
    Flags := tfCRLF;
  {$ENDIF}
    BufSize := SizeOf(Buffer);
    BufPos := 0;
    BufEnd := 0;
    BufPtr := @Buffer;
    OpenFunc := @SLCB_Open;
    FlushFunc := @SLCB_Flush;
    CloseFunc := @SLCB_Close;
    TSimpleLog(Addr(UserData[UDI_OUTFILE])^) := LogObject;
    Name := '';
  end;
end;

{==============================================================================}
{    TSimpleLog // Class implementation                                        }
{==============================================================================}

{------------------------------------------------------------------------------}
{    TSimpleLog // Constants                                                   }
{------------------------------------------------------------------------------}

const
  HeaderLines = '================================================================================';
  LineLength  = 80;

  ConsoleBindMutexName = 'SimpleLog_C730A534-B332-4A2C-98B1-CE7100DB5589';

//--- default settings ---
  def_TimeFormat             = 'yyyy-mm-dd hh:nn:ss.zzz';
  def_TimeSeparator          = ' //: ';
  def_Breaker                = '--------------------------------------------------------------------------------';
  def_HeaderText             = 'Created by SimpleLog 1.3, (c)2015 Frantisek Milt';
  def_IndentNewLines         = False;
  def_ThreadLocked           = False;
  def_InternalLog            = True;
  def_WriteToConsole         = False;
  def_StreamToFile           = False;
  def_StreamAppend           = False;
  def_StreamFileAccessRights = fmShareDenyWrite;
  def_ForceTime              = False;


{------------------------------------------------------------------------------}
{    TSimpleLog // Private routines                                            }
{------------------------------------------------------------------------------}

procedure TSimpleLog.SetWriteToConsole(Value: Boolean);
begin
If not fConsoleBinded then fWriteToConsole := Value;
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.SetStreamToFile(Value: Boolean);
begin
If fStreamToFile <> Value then
  If fStreamToFile then
    begin
      FreeAndNil(fStreamFile);
      fStreamToFile := Value;
    end
  else
    begin
      If FileExists(fStreamFileName) then
        fStreamFile := TFileStream.Create(fStreamFileName,fmOpenReadWrite or fStreamFileAccessRights)
      else
        fStreamFile := TFileStream.Create(fStreamFileName,fmCreate or fStreamFileAccessRights);
      If fStreamAppend then fStreamFile.Seek(0,soEnd)
        else fStreamFile.Size := 0;
      fStreamToFile := Value;
    end;
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.SetStreamFileName(Value: String);
begin
If Value = '' then Value := GetDefaultStreamFileName;
If not AnsiSameText(fStreamFileName,Value) then
  begin
    If fStreamToFile then
      begin
        fStreamFileName := Value;
        FreeAndNil(fStreamFile);
        If FileExists(fStreamFileName) then
          fStreamFile := TFileStream.Create(fStreamFileName,fmOpenReadWrite or StreamFileAccessRights)
        else
          fStreamFile := TFileStream.Create(fStreamFileName,fmCreate or StreamFileAccessRights);
        If fStreamAppend then fStreamFile.Seek(0,soEnd)
          else fStreamFile.Size := 0;
      end
    else fStreamFileName := Value;
  end;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.GetInternalLogCount: Integer;
begin
Result := fInternalLogObj.Count;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.GetExternalLogsCount: Integer;
begin
Result := fExternalLogs.Count;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.GetExternalLog(Index: Integer): TStrings;
begin
If (Index >= 0) and (Index < fExternalLogs.Count) then
  Result := TStrings(fExternalLogs[Index])
else
 raise exception.CreateFmt('TSimpleLog.GetExternalLog: Index (%d) out of bounds.',[Index]);
end;

{------------------------------------------------------------------------------}
{    TSimpleLog // Protected routines                                          }
{------------------------------------------------------------------------------}

Function TSimpleLog.ReserveConsoleBind: Boolean;
begin
fConsoleBindMutex := CreateMutex(nil,False,ConsoleBindMutexName);
Result := GetLastError = ERROR_SUCCESS;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.GetCurrentTime: TDateTime;
begin
If ForceTime then Result := ForcedTime
  else Result := Now;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.GetDefaultStreamFileName: String;
begin
Result := ParamStr(0) + '[' + GetTimeAsStr(fTimeOfCreation,'YYYY-MM-DD-HH-NN-SS') + '].log';
end;

//------------------------------------------------------------------------------

Function TSimpleLog.GetTimeAsStr(Time: TDateTime; const Format: String = '$'): String;
begin
If Format <> '$' then DateTimeToString(Result,Format,Time,fFormatSettings)
  else DateTimeToString(Result,fTimeFormat,Time,fFormatSettings);
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.DoIndentNewLines(var Str: String; IndentCount: Integer);
begin
If (IndentCount > 0) and AnsiContainsStr(Str,sLineBreak) then
  Str := AnsiReplaceStr(Str,sLineBreak,sLineBreak + StringOfChar(' ',IndentCount));
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.ProtectedAddLog(LogText: String; IndentCount: Integer = 0; LineBreak: Boolean = True);
var
  i:    Integer;
  Temp: String;
begin
If fIndentNewLines then DoIndentNewLines(LogText,IndentCount);
If fWriteToConsole and System.IsConsole then WriteLn(LogText);
If fInternalLog then fInternalLogObj.Add(LogText);
For i := 0 to Pred(fExternalLogs.Count) do TStrings(fExternalLogs[i]).Add(LogText);
If fStreamToFile then
  begin
    If LineBreak then
      begin
        Temp := LogText + sLineBreak;
        fStreamFile.WriteBuffer(PChar(Temp)^, Length(Temp) * SizeOf(Char));
      end
    else fStreamFile.WriteBuffer(PChar(LogText)^, Length(LogText) * SizeOf(Char));
  end;
Inc(fLogCounter);
If Assigned(fOnLog) then fOnLog(Self,LogText);
end;

{------------------------------------------------------------------------------}
{    TSimpleLog // Public routines                                             }
{------------------------------------------------------------------------------}

constructor TSimpleLog.Create;
begin
inherited Create;
{%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,fFormatSettings);
fTimeFormat := def_TimeFormat;
fTimeSeparator := def_TimeSeparator;
fTimeOfCreation := Now;
fBreaker := def_Breaker;
fHeaderText := def_HeaderText;
fIndentNewLines := def_IndentNewLines;
fThreadLocked := def_ThreadLocked;
fInternalLog := def_InternalLog;
fWriteToConsole := def_WriteToConsole;
fStreamToFile := def_StreamToFile;
fConsoleBinded := False;
fStreamAppend := def_StreamAppend;
fStreamFileName := GetDefaultStreamFileName;
fStreamFileAccessRights := def_StreamFileAccessRights;
fForceTime := def_ForceTime;
fForcedTime := Now;
fLogCounter := 0;
fThreadLock := SyncObjs.TCriticalSection.Create;
fInternalLogObj := TStringList.Create;
fExternalLogs := TObjectList.Create(False);
fConsoleBindMutex := 0;
fStreamFile := nil;
end;

//------------------------------------------------------------------------------

destructor TSimpleLog.Destroy;
begin
If Assigned(fStreamFile) then FreeAndNil(fStreamFile);
fExternalLogs.Free;
fInternalLogObj.Free;
fThreadLock.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.ThreadLock;
begin
fThreadLock.Enter;
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.ThreadUnlock;
begin
fThreadLock.Leave;
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddLogNoTime(const Text: String);
begin
If fThreadLocked then
  begin
    fThreadLock.Enter;
    try
      ProtectedAddLog(Text);
    finally
      fThreadLock.Leave;
    end;
  end
else ProtectedAddLog(Text);
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddLogTime(const Text: String; Time: TDateTime);
var
  TimeStr:  String;
begin
TimeStr := GetTimeAsStr(Time) + fTimeSeparator;
If fThreadLocked then
  begin
    fThreadLock.Enter;
    try
      ProtectedAddLog(TimeStr + Text,Length(TimeStr));
    finally
      fThreadLock.Leave;
    end;
  end
else ProtectedAddLog(TimeStr + Text,Length(TimeStr));
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddLog(const Text: String);
begin
AddLogTime(Text,GetCurrentTime);
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddEmpty;
begin
AddLogNoTime('');
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddBreaker;
begin
AddLogNoTime(fBreaker);
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddTimeStamp;
begin
AddLogNoTime(fBreaker + sLineBreak + 'TimeStamp: ' + GetTimeAsStr(GetCurrentTime) + sLineBreak + fBreaker);
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddStartStamp;
begin
AddLogNoTime(fBreaker + sLineBreak + GetTimeAsStr(GetCurrentTime) + ' - Starting log...' + sLineBreak + fBreaker);
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddEndStamp;
begin
AddLogNoTime(fBreaker + sLineBreak + GetTimeAsStr(GetCurrentTime) + ' - Ending log.' + sLineBreak + fBreaker);
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.AddAppendStamp;
begin
AddLogNoTime(fBreaker + sLineBreak + GetTimeAsStr(GetCurrentTime) + ' - Appending log...' + sLineBreak + fBreaker);
end;
 
//------------------------------------------------------------------------------

procedure TSimpleLog.AddHeader;
var
  TempStrings:  TStringList;
  i:            Integer;
begin
TempStrings := TStringList.Create;
try
  TempStrings.Text := HeaderText;
  For i := 0 to (TempStrings.Count - 1) do
    If Length(TempStrings[i]) < LineLength then
      TempStrings[i] := StringOfChar(' ', (LineLength - Length(TempStrings[i])) div 2) + TempStrings[i];
  AddLogNoTime(HeaderLines + sLineBreak + TempStrings.Text + HeaderLines);
finally
  TempStrings.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.ForceTimeSet(Time: TDateTime);
begin
fForcedTime := Time;
fForceTime := True;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.InternalLogGetLog(LogIndex: Integer): String;
begin
If (LogIndex >= 0) and (LogIndex < fInternalLogObj.Count) then
  Result := fInternalLogObj[LogIndex]
else
  Result := '';
end;

//------------------------------------------------------------------------------

Function TSimpleLog.InternalLogGetAsText: String;
begin
Result := fInternalLogObj.Text;
end;
   
//------------------------------------------------------------------------------

procedure TSimpleLog.InternalLogClear;
begin
fInternalLogObj.Clear;
end;
  
//------------------------------------------------------------------------------

Function TSimpleLog.InternalLogSaveToFile(const FileName: String; Append: Boolean = False): Boolean;
var
  FileStream:   TFileStream;
  StringBuffer: AnsiString;
begin
try
  If FileExists(FileName) then
    FileStream := TFileStream.Create(FileName,fmOpenReadWrite or fmShareDenyWrite)
  else
    FileStream := TFileStream.Create(FileName,fmCreate or fmShareDenyWrite);
  try
    If Append then FileStream.Seek(0,soEnd)
      else FileStream.Size := 0;
    StringBuffer := fInternalLogObj.Text;
    FileStream.WriteBuffer(PAnsiChar(StringBuffer)^,Length(StringBuffer) * SizeOf(AnsiChar));
  finally
    FileStream.Free;
  end;
  Result := True;
except
  Result := False;
end;
end;
    
//------------------------------------------------------------------------------

Function TSimpleLog.InternalLogLoadFromFile(const FileName: String; Append: Boolean = False): Boolean;
var
  FileStream:   TFileStream;
  StringBuffer: AnsiString;
begin
try
  FileStream := TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
  try
    If not Append then fInternalLogObj.Clear;
    FileStream.Position := 0;
    SetLength(StringBuffer,FileStream.Size div SizeOf(AnsiChar));
    FileStream.ReadBuffer(PAnsiChar(StringBuffer)^,Length(StringBuffer) * SizeOf(AnsiChar));
    fInternalLogObj.Text := fInternalLogObj.Text + StringBuffer;
  finally
    FileStream.Free;
  end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.BindConsole: Boolean;
begin
If not fConsoleBinded and System.IsConsole and ReserveConsoleBind then
  begin
    fWriteToConsole := False;
    AssignSLCB(ErrOutput,Self);
    Rewrite(ErrOutput);
    AssignSLCB(Output,Self);
    Rewrite(Output);
    AssignSLCB(Input,Self);
    Reset(Input);
    fConsoleBinded := True;
  end;
Result := fConsoleBinded;
end;

//------------------------------------------------------------------------------

procedure TSimpleLog.UnbindConsole;
begin
If fConsoleBinded then
  begin
    Close(Input);
    Close(Output);
    Close(ErrOutput);
    fConsoleBinded := False;
    CloseHandle(fConsoleBindMutex);
  end;
end;

//------------------------------------------------------------------------------

Function TSimpleLog.ExternalLogAdd(ExternalLog: TStrings): Integer;
begin
Result := fExternalLogs.Add(ExternalLog);
end;
     
//------------------------------------------------------------------------------

Function TSimpleLog.ExternalLogIndexOf(ExternalLog: TStrings): Integer;
begin
Result := fExternalLogs.IndexOf(ExternalLog);
end;
     
//------------------------------------------------------------------------------

Function TSimpleLog.ExternalLogRemove(ExternalLog: TStrings): Integer;
begin
Result := fExternalLogs.IndexOf(ExternalLog);
If Result >= 0 then ExternalLogDelete(Result);
end;
    
//------------------------------------------------------------------------------

procedure TSimpleLog.ExternalLogDelete(Index: Integer);
begin
If (Index >= 0) and (Index < fExternalLogs.Count) then
  fExternalLogs.Delete(Index)
else
 raise exception.CreateFmt('TSimpleLog.ExternalLogDelete: Index (%d) out of bounds.',[Index]);
end;

{$IFNDEF SimpleLog_Include}
{$WARNINGS OFF}
end.
{$ENDIF}
