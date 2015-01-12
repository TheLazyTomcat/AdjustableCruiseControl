unit ACC_ProcessBinder;

interface

{$INCLUDE ACC_Defs.inc}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

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

  TStateChangeEvent = procedure(Sender: TObject; NewState: TBinderState) of object;

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
  protected
    procedure sync_StateChange; virtual;
    procedure SwapProcessLists; virtual;
    Function SearchForRunningGame: Boolean; virtual;
    Function CheckModulesAndBind: Boolean; virtual;
    procedure Execute; override;
  public
    constructor Create(GamesDataPtr: PGamesData; GamesDataSync: TMultiReadExclusiveWriteSynchronizer; ControlEvent: THandle);
    destructor Destroy; override;
    property GameData: TGameData read fGameData;
  published
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
    fGamesData:     TGamesData;
    fControlEvent:  THandle;
    fBinderThread:  TBinderThread;
    fGameData:      TGameData;
    fOnStateChange: TNotifyEvent;
    fOnGameUnbind:  TNotifyEvent;
  protected
    procedure OnTimer(Sender: TObject); virtual;
    procedure OnThreadStateChange(Sender: TObject; NewState: TBinderState); virtual;
  public
    constructor Create(UtilityWindow: TUtilityWindow);
    destructor Destroy; override;
    procedure SetGamesData(GamesData: TGamesData); virtual;
    procedure Start; virtual;
    procedure UpdateTimerInterval; virtual;
    property GameData: TGameData read fGameData;
  published
    property Binded: Boolean read fBinded;
    property OnStateChange: TNotifyEvent read fOnStateChange write fOnStateChange;
    property OnGameUnbind: TNotifyEvent read fOnGameUnbind write fOnGameUnbind;
  end;

implementation

uses
  {$IFNDEF FPC}PSApi,{$ENDIF}
  CRC32, MD5,
  ACC_Common;

Function GetFileSize(const FilePath: String): Int64;
var
  SearchResult: TSearchRec;
begin
If FindFirst(FilePath,faAnyFile,SearchResult) = 0 then
  begin
    {$WARN SYMBOL_PLATFORM OFF}
    Int64Rec(Result).Hi := SearchResult.FindData.nFileSizeHigh;
    Int64Rec(Result).Lo := SearchResult.FindData.nFileSizeLow;
    {$WARN SYMBOL_PLATFORM ON}
    FindClose(SearchResult);
    end
  else Result := 0;
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
  raise Exception.Create('TProcessList.GetItemPtr: Index (' + IntToStr(Index) + ') out of bounds.');
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
  raise Exception.Create('TProcessList.SetItem: Index (' + IntToStr(Index) + ') out of bounds.');
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
  TempListItem: TProcessListItem;
begin
For Result := 0 to Pred(fRealCount) do
  begin
    TempListItem := ListItems[Result];
    If (ProcessID = TempListItem.ProcessID) and AnsiSameText(ExecName,TempListItem.ExecName) then Exit
  end;
Result := -1;
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
NewListItem^.ExecName := Process.szExeFile;
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
SnapshotHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS,0);
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

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TBinderThread                                }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TBinderThread // Protected methods                                         }
{------------------------------------------------------------------------------}

procedure TBinderThread.sync_StateChange;
begin
If Assigned(fOnStateChange) then fOnStateChange(Self,fState);
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
      For Result := Low(fGamesDataPtr^) to High(fGamesDataPtr^) do
        If Length(fGamesDataPtr^[Result].Modules) > 0 then
          If AnsiSameText(ProcessName,fGamesDataPtr^[Result].Modules[0].FileName) then Exit;
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
            FileName := ModuleEntry.szModule;
            RuntimeInfo.FullPath := ModuleEntry.szExePath;
            RuntimeInfo.BaseAddress := ModuleEntry.modBaseAddr;
          end;
      until not Module32Next(SnapshotHandle,ModuleEntry);
    CloseHandle(SnapshotHandle);
  end;
try
  fGamesDataSync.BeginRead;
  try
    For i := Low(fGamesDataPtr^) to High(fGamesDataPtr^) do
      If (Length(fGamesDataPtr^[i].Modules) > 0) and (Length(ProcessModules) > 0) then
        If AnsiSameText(fGamesDataPtr^[i].Modules[0].FileName,ProcessModules[0].FileName) then
          begin
            If CheckGame(fGamesDataPtr^[i],ProcessModules) then
              begin
                fGameData := fGamesDataPtr^[i];
                  fGameData.ProcessInfo.ProcessID := fPossibleGameProcess.ProcessID;
                fWaitObjects.GameProcess := OpenProcess(PROCESS_VM_READ or PROCESS_VM_WRITE or PROCESS_VM_OPERATION or $00100000{SYNCHRONIZE},False,fGameData.ProcessInfo.ProcessID);
                fGameData.ProcessInfo.ProcessHandle := fWaitObjects.GameProcess;
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

procedure TBinderThread.Execute;
begin
while not Terminated do
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

procedure TProcessBinder.OnThreadStateChange(Sender: TObject; NewState: TBinderState);
var
  CallUnbindEvent:  Boolean;
begin
case NewState of
  bsSearching:      begin
                      fControlTimer.Interval := Settings.ProcessBinderScanInterval;
                      fControlTimer.Tag := 0;
                      CallUnbindEvent := fBinded;
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
fControlEvent := CreateEvent(nil,False,False,nil);
fBinderThread := TBinderThread.Create(Addr(fGamesData),fGamesDataSync,fControlEvent);
fBinderThread.OnStateChange := OnThreadStateChange;
end;

//------------------------------------------------------------------------------

destructor TProcessBinder.Destroy;
begin
fControlTimer.Enabled := False;
fBinderThread.Terminate;
SetEvent(fControlEvent);
fBinderThread.WaitFor;
fBinderThread.Free;
CloseHandle(fControlEvent);
fGamesDataSync.Free;
fControlTimer.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TProcessBinder.SetGamesData(GamesData: TGamesData);
begin
fGamesDataSync.BeginWrite;
try
  fGamesData := GamesData;
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

end.
