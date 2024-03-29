{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_ProcessBinder;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, SysUtils, Classes, {$IFDEF FPC}jwaTlHelp32{$ELSE}TlHelp32{$ENDIF},
  UtilityWindow, SimpleTimer,
  ACC_GamesData, ACC_Settings;

type
{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TProcessList                                 }
{------------------------------------------------------------------------------}
{==============================================================================}

  TProcessListItem = record
    ExecName:   String;
    ProcessID:  DWORD;
    New:        Boolean;
  end;
  PProcessListItem = ^TProcessListItem;

  TProcessList = class(TList)
  private
    fRealCount: Integer;
    Function GetListItemPtr(Index: Integer): PProcessListItem;
    Function GetListItem(Index: Integer): TProcessListItem;
    procedure SetListItem(Index: Integer; Value: TProcessListItem);
  public
    constructor Create;
    destructor Destroy; override;
    Function IndexOf(const ExecName: String; ProcessID: DWORD): Integer; virtual;
    Function AddProcess(Process: TProcessEntry32): Integer; virtual;
    procedure Fill; virtual;
    procedure Compare(ProcessList: TProcessList); virtual;
    procedure Invalidate; virtual;
    property ListItemsPtr[Index: Integer]: PProcessListItem read GetListItemPtr;
    property ListItems[Index: Integer]: TProcessListItem read GetListItem write SetListItem; default;
  published
    property RealCount: Integer read fRealCount;
  end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TBinderThread                                }
{------------------------------------------------------------------------------}
{==============================================================================}
  TBinderState = (bsSearching, bsModulesWaiting, bsBinded);

  TStateChangeEvent = procedure(Sender: TObject; NewState: TBinderState; Rebinding: Boolean) of object;

  TWaitObjects = packed record
    GameProcess:  THandle;
    ControlEvent: THandle;
  end;

  TBinderThread = class(TThread)
  private
    fGamesDataPtr:        PGamesData;
    fGamesDataSync:       TMultiReadExclusiveWriteSynchronizer;
    fState:               TBinderState;
    fGameData:            TGameData;
    fOldProcessList:      TProcessList;
    fCurrentProcessList:  TProcessList;
    fPossibleGameProcess: TProcessListItem;
    fWaitObjects:         TWaitObjects;
    fOnStateChange:       TStateChangeEvent;
    fRebind:              LongBool;
    fRebinding:           Boolean;
    procedure SetRebind(Value: LongBool);
  protected
    procedure sync_StateChange; virtual;
    procedure SwapProcessLists; virtual;
    Function SearchForRunningGame: Boolean; virtual;
    Function CheckModulesAndBind: Boolean; virtual;
    procedure DoRebind; virtual;    
    procedure Execute; override;
  public
    constructor Create(GamesDataPtr: PGamesData; GamesDataSync: TMultiReadExclusiveWriteSynchronizer; ControlEvent: THandle);
    destructor Destroy; override;
    property GameData: TGameData read fGameData;
  published
    property Rebind: LongBool write SetRebind;
    property OnStateChange: TStateChangeEvent read fOnStateChange write fOnStateChange;
  end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                TProcessBinder                                }
{------------------------------------------------------------------------------}
{==============================================================================}
  TProcessBinder = class(TObject)
  private
    fBinded:        Boolean;
    fControlTimer:  TSimpleTimer;
    fGamesDataSync: TMultiReadExclusiveWriteSynchronizer;
    fGamesDataPtr:  PGamesData;
    fControlEvent:  THandle;
    fBinderThread:  TBinderThread;
    fGameData:      TGameData;
    fOnStateChange: TNotifyEvent;
    fOnGameUnbind:  TNotifyEvent;
  protected
    procedure OnTimer(Sender: TObject); virtual;
    procedure OnThreadStateChange(Sender: TObject; NewState: TBinderState; Rebinding: Boolean); virtual;
  public
    constructor Create(UtilityWindow: TUtilityWindow);
    destructor Destroy; override;
    procedure SetGamesData(GamesData: TGamesData); virtual;
    procedure Start; virtual;
    procedure UpdateTimerInterval; virtual;
    procedure Rebind; virtual;
    property GameData: TGameData read fGameData;
  published
    property Binded: Boolean read fBinded;
    property OnStateChange: TNotifyEvent read fOnStateChange write fOnStateChange;
    property OnGameUnbind: TNotifyEvent read fOnGameUnbind write fOnGameUnbind;
  end;

{$IF not Declared(FPC_FULLVERSION)}
const
  FPC_FULLVERSION = Integer(0);
{$IFEND}

implementation

uses
  {$IFNDEF FPC}PSApi,{$ENDIF}
  CRC32, MD5,
  ACC_Common
{$IF Defined(FPC) and not Defined(Unicode)}
  , LazUTF8
  {$IF FPC_FULLVERSION < 20701}
  , LazFileUtils
  {$IFEND}
{$IFEND};

Function GetFileSize(const FilePath: String): Int64;
var
  SearchResult: TSearchRec;
begin
{$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
If FindFirstUTF8(FilePath,faAnyFile,SearchResult) = 0 then
{$ELSE}
If FindFirst(FilePath,faAnyFile,SearchResult) = 0 then
{$IFEND}
  begin
    {$WARN SYMBOL_PLATFORM OFF}
    Int64Rec(Result).Hi := SearchResult.FindData.nFileSizeHigh;
    Int64Rec(Result).Lo := SearchResult.FindData.nFileSizeLow;
    {$WARN SYMBOL_PLATFORM ON}
  {$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
    FindCloseUTF8(SearchResult);
  {$ELSE}
    FindClose(SearchResult);
  {$IFEND}
    end
  else Result := 0;
end;

//------------------------------------------------------------------------------

type
  TIsWoW64Process = Function(hProcess: THandle; Wow64Process: PBOOL): BOOL; stdcall;

var
  IsWow64Process: TIsWoW64Process = nil;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   

procedure Is64bitProcessInit;
var
  ModuleHandle: THandle;
begin
ModuleHandle := GetModuleHandle('kernel32.dll');
If ModuleHandle <> 0 then
  IsWoW64Process := GetProcAddress(ModuleHandle,'IsWow64Process')
else
  raise Exception.CreateFmt('Is64bitProcessInit: Unable to get handle to module kernel32.dll (%.8x).',[GetLastError]);
end;

//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---

Function Is64bitProcess({%H-}ProcessHandle: THandle): Boolean;
var
  ResultValue:  BOOL;
begin
If Assigned(IsWoW64Process) then
  begin
    If IsWow64Process(ProcessHandle,@ResultValue) then
      Result := not ResultValue
    else
      raise Exception.CreateFmt('Is64bitProcess: IsWow64Process failed with error %.8x.',[GetLastError]);
  end
else Result := False;
end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TProcessList                                 }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TProcessList // Private methods                                            }
{------------------------------------------------------------------------------}

Function TProcessList.GetListItemPtr(Index: Integer): PProcessListItem;
begin
If (Index >= 0) and (Index < fRealCount) then
  Result := Items[Index]
else
  raise Exception.CreateFmt('TProcessList.GetItemPtr: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TProcessList.GetListItem(Index: Integer): TProcessListItem;
begin
Result := GetListItemPtr(Index)^;
end;

//------------------------------------------------------------------------------

procedure TProcessList.SetListItem(Index: Integer; Value: TProcessListItem);
begin
If (Index >= 0) and (Index < fRealCount) then
  PProcessListItem(Items[Index])^ := Value
else
  raise Exception.CreateFmt('TProcessList.SetItem: Index (%d) out of bounds.',[Index]);
end;

{------------------------------------------------------------------------------}
{   TProcessList // Public methods                                             }
{------------------------------------------------------------------------------}

constructor TProcessList.Create;
begin
inherited;
fRealCount := 0;
end;

//------------------------------------------------------------------------------

destructor TProcessList.Destroy;
var
  i:  Integer;
begin
For i := 0 to Pred(Count) do
  Dispose(PProcessListItem(Items[i]));
inherited;
end;

//------------------------------------------------------------------------------

Function TProcessList.IndexOf(const ExecName: String; ProcessID: DWORD): Integer;
var
  i:            Integer;
  TempListItem: TProcessListItem;
begin
Result := -1;
For i := 0 to Pred(fRealCount) do
  begin
    TempListItem := ListItems[i];
    If (ProcessID = TempListItem.ProcessID) and AnsiSameText(ExecName,TempListItem.ExecName) then
      begin
        Result := i;
        Break;
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TProcessList.AddProcess(Process: TProcessEntry32): Integer;
var
  NewListItem:  PProcessListItem;
begin
If fRealCount >= Count then
  begin
    New(NewListItem);
    Result := Add(NewListItem);
  end
else
  begin
    NewListItem := PProcessListItem(Items[fRealCount]);
    Result := fRealCount;
  end;
{$IF Defined(FPC) and not Defined(Unicode)}
NewListItem^.ExecName := WinCPToUTF8(Process.szExeFile);
{$ELSE}
NewListItem^.ExecName := Process.szExeFile;
{$IFEND}
NewListItem^.ProcessID := Process.th32ProcessID;
Inc(fRealCount);
end;

//------------------------------------------------------------------------------

procedure TProcessList.Fill;
var
  SnapshotHandle: THandle;
  ProcessEntry:   TProcessEntry32;
begin
fRealCount := 0;
ProcessEntry.dwSize := SizeOf(ProcessEntry);
SnapshotHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS{$IFDEF x64} or TH32CS_SNAPMODULE32{$ENDIF},0);
If SnapshotHandle <> INVALID_HANDLE_VALUE then
  begin
    If Process32First(SnapshotHandle,ProcessEntry) then
      repeat
        AddProcess(ProcessEntry);
      until not Process32Next(SnapshotHandle,ProcessEntry);
    CloseHandle(SnapshotHandle);
  end;
end;

//------------------------------------------------------------------------------

procedure TProcessList.Compare(ProcessList: TProcessList);
var
  i:                Integer;
  TempListItemPtr:  PProcessListItem;
begin
For i := 0 to Pred(fRealCount) do
  begin
    TempListItemPtr := ListItemsPtr[i];
    TempListItemPtr^.New := ProcessList.IndexOf(TempListItemPtr^.ExecName,TempListItemPtr^.ProcessID) < 0;
  end;
end;

//------------------------------------------------------------------------------

procedure TProcessList.Invalidate;
begin
fRealCount := 0;
end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TBinderThread                                }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TBinderThread // Private methods                                           }
{------------------------------------------------------------------------------}

procedure TBinderThread.SetRebind(Value: LongBool);
begin
InterlockedExchange(Integer(fRebind),Integer(Value));
end;

{------------------------------------------------------------------------------}
{   TBinderThread // Protected methods                                         }
{------------------------------------------------------------------------------}

procedure TBinderThread.sync_StateChange;
begin
If Assigned(fOnStateChange) then fOnStateChange(Self,fState,fRebinding);
end;

//------------------------------------------------------------------------------

procedure TBinderThread.SwapProcessLists;
var
  TempList: TProcessList;
begin
TempList := fOldProcessList;
fOldProcessList := fCurrentProcessList;
fCurrentProcessList := TempList;
end;

//------------------------------------------------------------------------------

Function TBinderThread.SearchForRunningGame: Boolean;
var
  i:                    Integer;
  TempProcessListItem:  TProcessListItem;

  Function IndexOfProcessNameInGamesData(const ProcessName: String): Integer;
  begin
    fGamesDataSync.BeginRead;
    try
      For Result := Low(fGamesDataPtr^.Entries) to High(fGamesDataPtr^.Entries) do
        If Length(fGamesDataPtr^.Entries[Result].Modules) > 0 then
          If AnsiSameText(ProcessName,fGamesDataPtr^.Entries[Result].Modules[0].FileName) then Exit;
      Result := -1;
    finally
      fGamesDataSync.EndRead;
    end;
  end;

begin
Result := False;
For i := 0 to Pred(fCurrentProcessList.RealCount) do
  begin
    TempProcessListItem := fCurrentProcessList.ListItems[i];
    If TempProcessListItem.New then
      begin
        Result := IndexOfProcessNameInGamesData(TempProcessListItem.ExecName) >= 0;
        If Result then
          begin
            fPossibleGameProcess := TempProcessListItem;
            Break;
          end;
      end;
  end;
If Result then
  begin
    If CheckModulesAndBind then fState := bsBinded
      else fState := bsModulesWaiting;
  end;
end;

//------------------------------------------------------------------------------

Function TBinderThread.CheckModulesAndBind: Boolean;
type
  TProcessModules = Array of TModuleData;
var
  SnapshotHandle: THandle;
  ModuleEntry:    ModuleEntry32;
  ProcessModules: TProcessModules;
  i:              Integer;

  Function CheckGame(var GameData: TGameData; var Modules: TProcessModules): Boolean;
  var
    j,k:  Integer;
  begin
    try
      For j := Low(GameData.Modules) to High(GameData.Modules) do
        begin
          GameData.Modules[j].RuntimeInfo.Check := False;
          For k := Low(Modules) to High(Modules) do
            If AnsiSameText(GameData.Modules[j].FileName,Modules[k].FileName) then
              begin
                GameData.Modules[j].RuntimeInfo.Check := True;
                If (GameData.Modules[j].CheckFlags and CF_FILESIZE) <> 0 then
                  begin
                    If (Modules[k].CheckFlags and CF_FILESIZE) = 0 then
                      Modules[k].Size := GetFileSize(Modules[k].RuntimeInfo.FullPath);
                    Modules[k].CheckFlags := Modules[k].CheckFlags or CF_FILESIZE;
                    GameData.Modules[j].RuntimeInfo.Check := GameData.Modules[j].RuntimeInfo.Check
                                                             and (Modules[k].Size = GameData.Modules[j].Size);
                  end;
                If (GameData.Modules[j].CheckFlags and CF_FILECRC32) <> 0 then
                  begin
                    If (Modules[k].CheckFlags and CF_FILECRC32) = 0 then
                      Modules[k].CRC32 := FileCRC32(Modules[k].RuntimeInfo.FullPath);
                    Modules[k].CheckFlags := Modules[k].CheckFlags or CF_FILECRC32;
                    GameData.Modules[j].RuntimeInfo.Check := GameData.Modules[j].RuntimeInfo.Check
                                                             and (Modules[k].CRC32 = GameData.Modules[j].CRC32);
                  end;
                If (GameData.Modules[j].CheckFlags and CF_FILEMD5) <> 0 then
                  begin
                    If (Modules[k].CheckFlags and CF_FILEMD5) = 0 then
                      Modules[k].MD5 := FileMD5(Modules[k].RuntimeInfo.FullPath);
                    Modules[k].CheckFlags := Modules[k].CheckFlags or CF_FILEMD5;
                    GameData.Modules[j].RuntimeInfo.Check := GameData.Modules[j].RuntimeInfo.Check
                                                             and SameMD5(Modules[k].MD5,GameData.Modules[j].MD5);
                end;
                If GameData.Modules[j].RuntimeInfo.Check then
                  begin
                    GameData.Modules[j].RuntimeInfo.FullPath := Modules[k].RuntimeInfo.FullPath;
                    GameData.Modules[j].RuntimeInfo.BaseAddress := Modules[k].RuntimeInfo.BaseAddress;
                  end;
                Break{k};
              end;
          If not GameData.Modules[j].RuntimeInfo.Check then Break{j};
        end;
      Result := True;
      For j := Low(GameData.Modules) to High(GameData.Modules) do
        Result := Result and GameData.Modules[j].RuntimeInfo.Check;
    except
      Result := False;
    end;
  end;

begin
Result := False;
SetLength(ProcessModules,0);
ModuleEntry.dwSize := SizeOf(ModuleEntry);
SnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE,fPossibleGameProcess.ProcessID);
If SnapshotHandle <> INVALID_HANDLE_VALUE then
  begin
    If Module32First(SnapshotHandle,ModuleEntry) then
      repeat
        SetLength(ProcessModules,Length(ProcessModules) + 1);
        with ProcessModules[High(ProcessModules)] do
          begin
            CheckFlags := CF_NONE;
          {$IF Defined(FPC) and not Defined(Unicode)}
            FileName := WinCPToUTF8(ModuleEntry.szModule);
            RuntimeInfo.FullPath := WinCPToUTF8(ModuleEntry.szExePath);
          {$ELSE}
            FileName := ModuleEntry.szModule;
            RuntimeInfo.FullPath := ModuleEntry.szExePath;
          {$IFEND}
            RuntimeInfo.BaseAddress := ModuleEntry.modBaseAddr;
          end;
      until not Module32Next(SnapshotHandle,ModuleEntry);
    CloseHandle(SnapshotHandle);
  end;
try
  fGamesDataSync.BeginRead;
  try
    For i := Low(fGamesDataPtr^.Entries) to High(fGamesDataPtr^.Entries) do
      If (Length(fGamesDataPtr^.Entries[i].Modules) > 0) and (Length(ProcessModules) > 0) then
        If AnsiSameText(fGamesDataPtr^.Entries[i].Modules[0].FileName,ProcessModules[0].FileName) then
          begin
            If CheckGame(fGamesDataPtr^.Entries[i],ProcessModules) then
              begin
                fGameData := fGamesDataPtr^.Entries[i];
                  fGameData.ProcessInfo.ProcessID := fPossibleGameProcess.ProcessID;
                fWaitObjects.GameProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ or
                                                        PROCESS_VM_WRITE or PROCESS_VM_OPERATION or $00100000{SYNCHRONIZE},
                                                        False,fGameData.ProcessInfo.ProcessID);
                fGameData.ProcessInfo.ProcessHandle := fWaitObjects.GameProcess;
                fGameData.ProcessInfo.Is64bitProcess := Is64bitProcess(fWaitObjects.GameProcess);
                Result := fWaitObjects.GameProcess <> 0;
                Break{i};
              end
            else Result := False;
          end;
  finally
    fGamesDataSync.EndRead;
  end;
except
  Result := False;
end;  
end;

//------------------------------------------------------------------------------

procedure TBinderThread.DoRebind;
begin
case fState of
  bsBinded:
    begin
      fState := bsSearching;
      fRebinding := True;
      try
        Synchronize(sync_StateChange);
      finally
        fRebinding := False;
      end;
      CloseHandle(fWaitObjects.GameProcess);
      fWaitObjects.GameProcess := INVALID_HANDLE_VALUE;
    end;
  bsModulesWaiting:
    fState := bsSearching;
end;
fCurrentProcessList.Invalidate;
SetEvent(fWaitObjects.ControlEvent);
end;

//------------------------------------------------------------------------------

procedure TBinderThread.Execute;
begin
while not Terminated do
  begin
    If InterlockedExchange(Integer(fRebind),0) <> 0 then DoRebind;
    case fState of
      bsSearching:      begin
                          WaitForSingleObject(fWaitObjects.ControlEvent,10000);
                          If not Terminated then
                            begin
                              SwapProcessLists;
                              fCurrentProcessList.Fill;
                              fCurrentProcessList.Compare(fOldProcessList);
                              If SearchForRunningGame then
                                Synchronize(sync_StateChange);
                            end;
                        end;
      bsModulesWaiting: begin
                          WaitForSingleObject(fWaitObjects.ControlEvent,30000);
                          If not Terminated then
                            begin
                              If CheckModulesAndBind then fState := bsBinded
                                else fState := bsSearching;
                              Synchronize(sync_StateChange);
                            end;
                        end;
      bsBinded:         If WaitForMultipleObjects(2,Addr(fWaitObjects),False,10000) = WAIT_OBJECT_0 then
                          begin
                            If not Terminated then
                              begin
                                fState := bsSearching;
                                Synchronize(sync_StateChange);
                              end;
                            CloseHandle(fWaitObjects.GameProcess);
                            fWaitObjects.GameProcess := INVALID_HANDLE_VALUE;
                            fCurrentProcessList.Invalidate;
                        end;
    end;
  end;
end;

{------------------------------------------------------------------------------}
{   TBinderThread // Public methods                                            }
{------------------------------------------------------------------------------}

constructor TBinderThread.Create(GamesDataPtr: PGamesData; GamesDataSync: TMultiReadExclusiveWriteSynchronizer; ControlEvent: THandle);
begin
inherited Create(True);
FreeOnTerminate := False;
fGamesDataPtr := GamesDataPtr;
fGamesDataSync := GamesDataSync;
fState := bsSearching;
fWaitObjects.ControlEvent := ControlEvent;
fWaitObjects.GameProcess := INVALID_HANDLE_VALUE;
fOldProcessList := TProcessList.Create;
fCurrentProcessList := TProcessList.Create;
fRebind := False;
fRebinding := False;
end;

//------------------------------------------------------------------------------

destructor TBinderThread.Destroy;
begin
fOldProcessList.Free;
fCurrentProcessList.Free;
inherited;
end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                TProcessBinder                                }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TProcessBinder// Protected methods                                         }
{------------------------------------------------------------------------------}

procedure TProcessBinder.OnTimer(Sender: TObject);
begin
SetEvent(fControlEvent);
end;

//------------------------------------------------------------------------------

procedure TProcessBinder.OnThreadStateChange(Sender: TObject; NewState: TBinderState; Rebinding: Boolean);
var
  CallUnbindEvent:  Boolean;
begin
case NewState of
  bsSearching:      begin
                      fControlTimer.Interval := Settings.ProcessBinderScanInterval;
                      fControlTimer.Tag := 0;
                      CallUnbindEvent := fBinded and not Rebinding;
                      fBinded := False;
                      If Assigned(fOnStateChange) then fOnStateChange(Self);
                      If CallUnbindEvent and Assigned(fOnGameUnbind) then fOnGameUnbind(Self);
                    end;
  bsModulesWaiting: begin
                      fControlTimer.Interval := Settings.ModulesLoadTimeout;
                      fControlTimer.Tag := 1;
                      fBinded := False;
                    end;
  bsBinded:         begin
                      fControlTimer.Interval := Settings.ProcessBinderScanInterval;
                      fControlTimer.Tag := 0;
                      fGameData := fBinderThread.GameData;
                      fBinded := True;                      
                      If Assigned(fOnStateChange) then fOnStateChange(Self);
                    end; 
end;
end;

{------------------------------------------------------------------------------}
{   TProcessBinder// Public methods                                            }
{------------------------------------------------------------------------------}

constructor TProcessBinder.Create(UtilityWindow: TUtilityWindow);
begin
inherited Create;
fBinded := False;
fControlTimer := TSimpleTimer.Create(UtilityWindow,ACC_TIMER_ID_Binder);
fControlTimer.Tag := 0;
fControlTimer.OnTimer := OnTimer;
fGamesDataSync := TMultiReadExclusiveWriteSynchronizer.Create;
New(fGamesDataPtr);
fControlEvent := CreateEvent(nil,False,False,nil);
fBinderThread := TBinderThread.Create(fGamesDataPtr,fGamesDataSync,fControlEvent);
fBinderThread.OnStateChange := OnThreadStateChange;
end;

//------------------------------------------------------------------------------

destructor TProcessBinder.Destroy;
begin
fControlTimer.Enabled := False;
fBinderThread.Terminate;
SetEvent(fControlEvent);
{$IFDEF FPC}
fBinderThread.Start;
{$ELSE}
fBinderThread.Resume;
{$ENDIF}
fBinderThread.WaitFor;
fBinderThread.Free;
CloseHandle(fControlEvent);
Dispose(fGamesDataPtr);
fGamesDataSync.Free;
fControlTimer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TProcessBinder.SetGamesData(GamesData: TGamesData);
begin
fGamesDataSync.BeginWrite;
try
  fGamesDataPtr^ := GamesData;
finally
  fGamesDataSync.EndWrite;
end;
end;

//------------------------------------------------------------------------------

procedure TProcessBinder.Start;
begin
If Assigned(fOnStateChange) then fOnStateChange(Self);
fControlTimer.Interval := Settings.ProcessBinderScanInterval;
fControlTimer.Enabled := True;
fControlTimer.OnTimer(nil);
{$IFDEF FPC}
fBinderThread.Start;
{$ELSE}
fBinderThread.Resume;
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TProcessBinder.UpdateTimerInterval;
var
  Interval: LongWord;
begin
case fControlTimer.Tag of
  0:  Interval := Settings.ProcessBinderScanInterval;
  1:  Interval := Settings.ModulesLoadTimeout;
else
  Interval := fControlTimer.Interval;
end;
If fControlTimer.Interval <> Interval then
  fControlTimer.Interval := Interval;
end;

//------------------------------------------------------------------------------

procedure TProcessBinder.Rebind;
begin
fBinderThread.Rebind := True;
SetEvent(fControlEvent);
end;

//==============================================================================

initialization
  Is64bitProcessInit;

end.
