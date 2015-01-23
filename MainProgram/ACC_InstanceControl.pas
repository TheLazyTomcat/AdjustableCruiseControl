{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_InstanceControl;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Messages, Classes,
  UtilityWindow;

type
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
    fOnRestoreRequired:   TNotifyEvent;
  protected
    procedure MessageHandler(var Msg: TMessage; var Handled: Boolean); virtual;
  public
    constructor Create(UtilityWindow: TUtilityWindow; InstanceName: String);
    destructor Destroy; override;
  published
    property InstanceName: String read fInstanceName;
    property RestoreMessageCode: LongWord read fRestoreMessageCode;
    property FirstInstance: Boolean read fFirstInstance;
    property OnRestoreRequired: TNotifyEvent read fOnRestoreRequired write fOnRestoreRequired;
  end;

implementation

uses
  Windows, ACC_Strings;

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
    If Assigned(fOnRestoreRequired) then fOnRestoreRequired(Self);
    Handled := True;
  end;
end;

{------------------------------------------------------------------------------}
{   TInstanceControl // Public methods                                         }
{------------------------------------------------------------------------------}

constructor TInstanceControl.Create(UtilityWindow: TUtilityWindow; InstanceName: String);
begin
inherited Create;
fUtilityWindow := UtilityWindow;
fUtilityWindow.OnMessage.Add(MessageHandler);
fInstanceName := InstanceName;
fRestoreMessageCode := RegisterWindowMessage(PChar(ACCSTR_IC_MessagePrefix + fInstanceName));
fMapHandle := CreateFileMapping(INVALID_HANDLE_VALUE,nil,PAGE_READWRITE,0,SizeOf(HWND),PChar(ACCSTR_IC_MapPrefix + fInstanceName));
fMapMemory := MapViewOfFile(fMapHandle,FILE_MAP_ALL_ACCESS,0,0,SizeOf(HWND));
fMutexHandle := CreateMutex(nil,False,PChar(ACCSTR_IC_MutexPrefix + fInstanceName));
If GetLastError = ERROR_ALREADY_EXISTS then
  begin
    fFirstInstance := False;
    If WaitForSingleObject(fMutexHandle,1000) in [WAIT_OBJECT_0,WAIT_ABANDONED] then
      try
        SendMessage(HWND(fMapMemory^),fRestoreMessageCode,0,0);
      finally
        ReleaseMutex(fMutexHandle);
      end;
  end
else
  begin
    If WaitForSingleObject(fMutexHandle,5000) in [WAIT_OBJECT_0,WAIT_ABANDONED] then
      try
        HWND(fMapMemory^) := fUtilityWindow.WindowHandle;
      finally
        ReleaseMutex(fMutexHandle);
      end;
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

end.
