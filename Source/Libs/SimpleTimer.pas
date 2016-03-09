{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{==============================================================================}
{                                                                              }
{   Simple timer                                                               }
{                                                                              }
{   Non visual variant of TTimer component                                     }
{                                                                              }
{   ©František Milt 2015-12-13                                                 }
{                                                                              }
{   Version 1.1.1                                                              }
{                                                                              }
{==============================================================================}
unit SimpleTimer;

{$IF not(defined(WINDOWS) or defined(MSWINDOWS))}
  {$MESSAGE FATAL 'Unsupported operating system.'}
{$IFEND}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, Classes,
  UtilityWindow, AuxTypes;

type
  TSimpleTimer = class(TObject)
  private
    fWindow:      TUtilityWindow;
    fTimerID:     PtrUInt;
    fOwnsWindow:  Boolean;
    fInterval:    UInt32;
    fEnabled:     Boolean;
    fTag:         Integer;
    fOnTimer:     TNotifyEvent;
    Function GetWindowHandle: HWND;
    procedure SetInterval(Value: UInt32);
    procedure SetEnabled(Value: Boolean);
  protected
    procedure SetupTimer;
    procedure MessagesHandler(var Msg: TMessage; var Handled: Boolean);
  public
    constructor Create(Window: TUtilityWindow = nil; TimerID: PtrUInt = 1);
    destructor Destroy; override;
    procedure ProcessMassages;
  published
    property WindowHandle: HWND read GetWindowHandle;
    property Window: TUtilityWindow read fWindow;
    property TimerID: PtrUInt read fTimerID;
    property OwnsWindow: Boolean read fOwnsWindow;
    property Interval: UInt32 read fInterval write SetInterval;
    property Enabled: Boolean read fEnabled write SetEnabled;
    property Tag: Integer read fTag write fTag;
    property OnTimer: TNotifyEvent read fOnTimer write fOnTimer;
  end;

implementation

uses
  SysUtils;

{=== TSimpleTimer // Private methods ==========================================}

Function TSimpleTimer.GetWindowHandle: HWND;
begin
Result := fWindow.WindowHandle;
end;

//------------------------------------------------------------------------------

procedure TSimpleTimer.SetInterval(Value: UInt32);
begin
fInterval := Value;
SetupTimer;
end;

//------------------------------------------------------------------------------

procedure TSimpleTimer.SetEnabled(Value: Boolean);
begin
fEnabled := Value;
SetupTimer;
end;

{=== TSimpleTimer // Protected methods ========================================}

procedure TSimpleTimer.SetupTimer;
begin
KillTimer(WindowHandle,fTimerID);
If (fInterval > 0) and fEnabled then
  If SetTimer(WindowHandle,fTimerID,fInterval,nil) = 0 then
    raise EOutOfResources.Create('Not enough timers available.');
end;

//------------------------------------------------------------------------------

procedure TSimpleTimer.MessagesHandler(var Msg: TMessage; var Handled: Boolean);
begin
If (Msg.Msg = WM_TIMER) and (PtrUInt(Msg.wParam) = fTimerID) then
  begin
    If Assigned(fOnTimer) then fOnTimer(Self);
    Msg.Result := 0;
    Handled := True;
  end
else Handled := False;
end;

{=== TSimpleTimer // Public methods ===========================================}

constructor TSimpleTimer.Create(Window: TUtilityWindow = nil; TimerID: PtrUInt = 1);
begin
inherited Create;
If Assigned(Window) then
  begin
    fWindow := Window;
    fOwnsWindow := False;
  end
else
  begin
    fWindow := TUtilityWindow.Create;
    fOwnsWindow := True;
  end;
fTimerID := TimerID;
fWindow.OnMessage.Add(MessagesHandler);
fInterval := 1000;
fEnabled := False;
end;

//------------------------------------------------------------------------------

destructor TSimpleTimer.Destroy;
begin
fEnabled := False;
SetupTimer;
If fOwnsWindow then fWindow.Free
  else fWindow.OnMessage.Remove(MessagesHandler);
inherited;
end;

//------------------------------------------------------------------------------

procedure TSimpleTimer.ProcessMassages;
begin
fWindow.ProcessMessages(False);
end;

end.
