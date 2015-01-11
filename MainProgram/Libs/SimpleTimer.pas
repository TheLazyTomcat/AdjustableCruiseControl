{==============================================================================}
{                                                                              }
{   Simple timer                                                               }
{                                                                              }
{   Non visual variant of TTimer component.                                    }
{                                                                              }
{   ©František Milt 2015-01-11                                                 }
{                                                                              }
{   Version 1.1                                                                }
{                                                                              }
{==============================================================================}
unit SimpleTimer;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  Windows, Messages, Classes,
  UtilityWindow;

type
  TSimpleTimer = class(TObject)
  private
    fWindow:      TUtilityWindow;
    fTimerID:     Integer;
    fOwnsWindow:  Boolean;
    fInterval:    LongWord;
    fEnabled:     Boolean;
    fTag:         Integer;
    fOnTimer:     TNotifyEvent;
    Function GetWindowHandle: HWND;
    procedure SetInterval(Value: LongWord);
    procedure SetEnabled(Value: Boolean);
  protected
    procedure SetupTimer;
    procedure MessagesHandler(var Msg: TMessage; var Handled: Boolean);
  public
    constructor Create(Window: TUtilityWindow = nil; TimerID: Integer = 1);
    destructor Destroy; override;
    procedure ProcessMassages;
  published
    property WindowHandle: HWND read GetWindowHandle;
    property Window: TUtilityWindow read fWindow;
    property TimerID: Integer read fTimerID;
    property OwnsWindow: Boolean read fOwnsWindow;
    property Interval: LongWord read fInterval write SetInterval;
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

procedure TSimpleTimer.SetInterval(Value: LongWord);
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
    raise EOutOfResources.Create('Not enough timers available');
end;

procedure TSimpleTimer.MessagesHandler(var Msg: TMessage; var Handled: Boolean);
begin
with Msg do
  case Msg of
    WM_TIMER: If wParam = fTimerID then
                begin
                  If Assigned(fOnTimer) then fOnTimer(Self);
                  Result := 0;
                  Handled := True;
                end;
  else
    Handled := False;
  end;
end;

{=== TSimpleTimer // Public methods ===========================================}

constructor TSimpleTimer.Create(Window: TUtilityWindow = nil; TimerID: Integer = 1);
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
