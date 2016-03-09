{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_InstanceControl;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, Classes,
  UtilityWindow;

type
  TRestoreMessageEvent = procedure(Sender: TObject; UpdateLoad: Boolean) of object;

{==============================================================================}
{------------------------------------------------------------------------------}
{                               TInstanceControl                               }
{------------------------------------------------------------------------------}
{==============================================================================}
  TInstanceControl = class(TObject)
  private
    fUtilityWindow:       TUtilityWindow;
    fInstanceName:        String;
    fRestoreMessageCode:  LongWord;
    fMapHandle:           THandle;
    fMapMemory:           Pointer;
    fMutexHandle:         THandle;
    fFirstInstance:       Boolean;
    fOnRestoreMessage:    TRestoreMessageEvent;
  protected
    procedure MessageHandler(var Msg: TMessage; var Handled: Boolean); virtual;
    procedure WriteSharedHandle(Handle: HWND); virtual;
    Function ReadSharedHandle: HWND; virtual;
  public
    constructor Create(UtilityWindow: TUtilityWindow; InstanceName: String; LoadingUpdate: Boolean; const UpdateFile: String);
    destructor Destroy; override;
    procedure WriteSharedString(const Str: String); virtual;
    Function ReadSharedString: String; virtual;
  published
    property InstanceName: String read fInstanceName;
    property RestoreMessageCode: LongWord read fRestoreMessageCode;
    property FirstInstance: Boolean read fFirstInstance;
    property OnRestoreMessage: TRestoreMessageEvent read fOnRestoreMessage write fOnRestoreMessage;
  end;

implementation

uses
  AuxTypes,
  ACC_Common, ACC_Strings
  {$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
  , LazUTF8
  {$IFEND};

const
  SharedMemorySize   = 1024;
  SharedStringOffset = 8;  

{==============================================================================}
{------------------------------------------------------------------------------}
{                               TInstanceControl                               }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TInstanceControl // Protected methods                                      }
{------------------------------------------------------------------------------}

procedure TInstanceControl.MessageHandler(var Msg: TMessage; var Handled: Boolean);
begin
If Msg.Msg = fRestoreMessageCode then
  begin
    If Assigned(fOnRestoreMessage) then fOnRestoreMessage(Self,Integer(Msg.WParam) = 1);
    Handled := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TInstanceControl.WriteSharedHandle(Handle: HWND);
begin
If WaitForSingleObject(fMutexHandle,10000) in [WAIT_OBJECT_0,WAIT_ABANDONED] then
  try
    HWND(fMapMemory^) := Handle;
  finally
    ReleaseMutex(fMutexHandle);
  end;
end;

//------------------------------------------------------------------------------

Function TInstanceControl.ReadSharedHandle: HWND;
begin
If WaitForSingleObject(fMutexHandle,10000) in [WAIT_OBJECT_0,WAIT_ABANDONED] then
  try
    Result := HWND(fMapMemory^);
  finally
    ReleaseMutex(fMutexHandle);
  end
else Result := INVALID_HANDLE_VALUE;  
end;

{------------------------------------------------------------------------------}
{   TInstanceControl // Public methods                                         }
{------------------------------------------------------------------------------}

constructor TInstanceControl.Create(UtilityWindow: TUtilityWindow; InstanceName: String; LoadingUpdate: Boolean; const UpdateFile: String);
begin
inherited Create;
fUtilityWindow := UtilityWindow;
fUtilityWindow.OnMessage.Add(MessageHandler);
fInstanceName := InstanceName;
{$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
fRestoreMessageCode := RegisterWindowMessage(PChar(UTF8ToWinCP(ACCSTR_IC_MessagePrefix + fInstanceName)));
fMapHandle := CreateFileMapping(INVALID_HANDLE_VALUE,nil,PAGE_READWRITE,0,SharedMemorySize,PChar(UTF8ToWinCP(ACCSTR_IC_MapPrefix + fInstanceName)));
fMapMemory := MapViewOfFile(fMapHandle,FILE_MAP_ALL_ACCESS,0,0,SharedMemorySize);
fMutexHandle := CreateMutex(nil,False,PChar(UTF8ToWinCP(ACCSTR_IC_MutexPrefix + fInstanceName)));
{$ELSE}
fRestoreMessageCode := RegisterWindowMessage(PChar(ACCSTR_IC_MessagePrefix + fInstanceName));
fMapHandle := CreateFileMapping(INVALID_HANDLE_VALUE,nil,PAGE_READWRITE,0,SharedMemorySize,PChar(ACCSTR_IC_MapPrefix + fInstanceName));
fMapMemory := MapViewOfFile(fMapHandle,FILE_MAP_ALL_ACCESS,0,0,SharedMemorySize);
fMutexHandle := CreateMutex(nil,False,PChar(ACCSTR_IC_MutexPrefix + fInstanceName));
{$IFEND}
If GetLastError = ERROR_ALREADY_EXISTS then
  begin
    fFirstInstance := False;
    If LoadingUpdate then
      begin
        WriteSharedString(UpdateFile);
        PostMessage(ReadSharedHandle,fRestoreMessageCode,1,0)
      end
    else PostMessage(ReadSharedHandle,fRestoreMessageCode,0,0);
  end
else
  begin
    WriteSharedHandle(fUtilityWindow.WindowHandle);
    fFirstInstance := True;
  end;
end;

//------------------------------------------------------------------------------

destructor TInstanceControl.Destroy;
begin
fUtilityWindow.OnMessage.Remove(MessageHandler);
CloseHandle(fMutexHandle);
UnmapViewOfFile(fMapMemory);
CloseHandle(fMapHandle);
inherited;
end;

//------------------------------------------------------------------------------

procedure TInstanceControl.WriteSharedString(const Str: String);
var
  TempStr:  UTF8String;
begin
If WaitForSingleObject(fMutexHandle,10000) in [WAIT_OBJECT_0,WAIT_ABANDONED] then
  try
  {$IFDEF Unicode}
    TempStr := UTF8Encode(Str);
  {$ELSE}
    {$IFDEF FPC}
    TempStr := Str;
    {$ELSE}
    TempStr := AnsiToUTF8(Str);
    {$ENDIF}
  {$ENDIF}
    {%H-}PInteger({%H-}PtrUInt(fMapMemory) + SharedStringOffset)^ := Length(TempStr);
    Move(PUTF8Char(TempStr)^,{%H-}Pointer({%H-}PtrUInt(fMapMemory) + SharedStringOffset + SizeOf(Integer))^,Length(TempStr))
  finally
    ReleaseMutex(fMutexHandle);
  end;
end;

//------------------------------------------------------------------------------

Function TInstanceControl.ReadSharedString: String;
var
  TempStr:  UTF8String;
begin
If WaitForSingleObject(fMutexHandle,10000) in [WAIT_OBJECT_0,WAIT_ABANDONED] then
  try
    SetLength(TempStr,{%H-}PInteger({%H-}PtrUInt(fMapMemory) + SharedStringOffset)^);
    Move({%H-}Pointer({%H-}PtrUInt(fMapMemory) + SharedStringOffset + SizeOf(Integer))^,PUTF8Char(TempStr)^,Length(TempStr));
  {$IFDEF Unicode}
    Result := UTF8Decode(TempStr);
  {$ELSE}
    {$IFDEF FPC}
    Result := TempStr;
    {$ELSE}
    Result := UTF8ToAnsi(TempStr);
    {$ENDIF}
  {$ENDIF}
  finally
    ReleaseMutex(fMutexHandle);
  end;
end;

end.
