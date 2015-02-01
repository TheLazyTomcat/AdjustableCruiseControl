{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_Input;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, Classes,
  WinRawInput, UtilityWindow,
  ACC_Settings;

const
  InvalidInput: TInput = (PrimaryKey: -1; ShiftKey: -1);  

type
{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TTriggersList                                }
{------------------------------------------------------------------------------}
{==============================================================================}

  TTriggerListItem = record
    Trigger:  Integer;
    Input:    TInput;
  end;
  PTriggerListItem = ^TTriggerListItem;

  TTriggersList = class(TList)
  private
    Function GetTrigger(Index: Integer): Integer;
  public
    procedure Clear; override;
    Function IndexOfTrigger(Trigger: Integer): Integer; virtual;
    Function IndexOfInput(Input: TInput): Integer; virtual;
    Function AddTrigger(Trigger: Integer; Input: TInput): Integer; virtual;
    procedure DeleteTrigger(Index: Integer); virtual;
    property Triggers[Index: Integer]: Integer read GetTrigger; default;
  end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TInputManager                                }
{------------------------------------------------------------------------------}
{==============================================================================}

  TVirtualKeyEvent = procedure(Sender: TObject; VirtualKey: Word) of object;
  TTriggerEvent = procedure(Sender: TObject; Trigger: Integer) of object;

  TTriggerInvoke = (tiNone,tiOnPress,tiOnRelease);
  TOperationMode = (omProcess,omTrigger,omBinding);

  TOperationModes = set of TOperationMode;

  TInputManager = class(TObject)
  private
    fUtilityWindow:         TUtilityWindow;
    fTriggersList:          TTriggersList;
    fMode:                  TOperationModes;
    fDiscernKeyboardSides:  Boolean;
    fCurrentInput:          TInput;
    fTriggerInvoke:         TTriggerInvoke;
    fOnVirtualKeyPress:     TVirtualKeyEvent;
    fOnVirtualKeyRelease:   TVirtualKeyEvent;
    fOnTrigger:             TTriggerEvent;
  protected
    procedure MessageHandler(var Msg: TMessage; var Handled: Boolean); virtual;
    procedure ProcessRawInput(lParam: lParam; {%H-}wParam: wParam); virtual;
    procedure ProcessKeyboardInput(Input: RawKeyboard); virtual;
    procedure ProcessKeyPress(VKey: Word); virtual;
    procedure ProcessKeyRelease(VKey: Word); virtual;
    Function InvokeTrigger: Integer; virtual;
  public
    class Function GetVirtualKeyName(VirtualKey: Word; NumberForUnknown: Boolean = False): String; virtual;
    class Function GetInputKeyNames(Input: TInput; VKOnly: Boolean = False): String; virtual;
    class Function InputIsValid(Input: TInput): Boolean; virtual;
    constructor Create(UtilityWindow: TUtilityWindow);
    destructor Destroy; override;
    procedure AddTrigger(Trigger: Integer; Input: TInput); virtual;
    property CurrentInput: TInput read fCurrentInput;
  published
    property Mode: TOperationModes read fMode write fMode;
    property DiscernKeyboardSides: Boolean read fDiscernKeyboardSides write fDiscernKeyboardSides;
    property TriggerInvoke: TTriggerInvoke read fTriggerInvoke write fTriggerInvoke;
    property OnVirtualKeyPress: TVirtualKeyEvent read fOnVirtualKeyPress write fOnVirtualKeyPress;
    property OnVirtualKeyRelease: TVirtualKeyEvent read fOnVirtualKeyRelease write fOnVirtualKeyRelease;
    property OnTrigger: TTriggerEvent read fOnTrigger write fOnTrigger;
  end;

implementation

uses
  SysUtils;

const
  MAPVK_VK_TO_VSC    = 0;
  MAPVK_VSC_TO_VK_EX = 3;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TTriggersList                                }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TTriggersList // Private methods                                           }
{------------------------------------------------------------------------------}

Function TTriggersList.GetTrigger(Index: Integer): Integer;
begin
If (Index >= 0) and (Index < Count) then
  Result := PTriggerListItem(Items[Index])^.Trigger
else
  raise Exception.Create('TTriggersList.GetTrigger: Index (' + IntToStr(Index) + ') out of bounds.');
end;

{------------------------------------------------------------------------------}
{   TTriggersList // Public methods                                            }
{------------------------------------------------------------------------------}

procedure TTriggersList.Clear;
var
  i:  Integer;
begin
For i := 0 to Pred(Count) do
  Dispose(PTriggerListItem(Items[i]));
inherited;
end;

//------------------------------------------------------------------------------

Function TTriggersList.IndexOfTrigger(Trigger: Integer): Integer;
begin
For Result := 0 to Pred(Count) do
  If PTriggerListItem(Items[Result])^.Trigger = Trigger then Exit;
Result := -1;
end;

//------------------------------------------------------------------------------

Function TTriggersList.IndexOfInput(Input: TInput): Integer;
var
  TempItemPtr:  PTriggerListItem;
begin
For Result := 0 to Pred(Count) do
  begin
    TempItemPtr := PTriggerListItem(Items[Result]);
    If (TempItemPtr^.Input.PrimaryKey = Input.PrimaryKey) and
       (TempItemPtr^.Input.ShiftKey = Input.ShiftKey) then Exit;
  end;
Result := -1;
end;

//------------------------------------------------------------------------------

Function TTriggersList.AddTrigger(Trigger: Integer; Input: TInput): Integer;
var
  NewItem:  PTriggerListItem;
begin
Result := IndexOfTrigger(Trigger);
If IndexOfInput(Input) < 0 then
  begin
    If Result < 0 then
      begin
        If TInputManager.InputIsValid(Input) then
          begin
            New(NewItem);
            NewItem^.Trigger := Trigger;
            NewItem^.Input := Input;
            Result := Add(NewItem);
            If Result < 0 then Dispose(NewItem);
          end;
      end
    else
      begin
        If TInputManager.InputIsValid(Input) then
          PTriggerListItem(Items[Result])^.Input := Input
        else
          DeleteTrigger(Result);
      end
  end;
end;

//------------------------------------------------------------------------------

procedure TTriggersList.DeleteTrigger(Index: Integer);
begin
If (Index >= 0) and (Index < Count) then
  begin
    Dispose(PTriggerListItem(Items[Index]));
    Delete(Index);
  end
else raise Exception.CreateFmt('TTriggersList.DeleteTrigger: Index (%d) out of bounds.',[Index]);
end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TInputManager                                }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TInputManager // Protected methods                                         }
{------------------------------------------------------------------------------}

procedure TInputManager.MessageHandler(var Msg: TMessage; var Handled: Boolean);
begin
If Msg.Msg = WM_INPUT then
  begin
    If fMode <> [] then ProcessRawInput(Msg.LParam,Msg.WParam);
    Handled := True;
  end;
end;

//------------------------------------------------------------------------------

procedure TInputManager.ProcessRawInput(lParam: lParam; wParam: wParam);
var
  RawInputSize: LongWord;
  RawInput:     PRawInput;
begin
GetRawInputData(HRAWINPUT(lParam),RID_INPUT,nil,@RawInputSize,SizeOf(TRawInputHeader));
If RawInputSize > 0 then
  begin
    RawInput := AllocMem(RawInputSize);
    try
      If GetRawInputData(HRAWINPUT(lParam),RID_INPUT,RawInput,@RawInputSize,SizeOf(TRawInputHeader)) = RawInputSize then
        case RawInput^.header.dwType of
          RIM_TYPEMOUSE:;
          RIM_TYPEKEYBOARD: ProcessKeyboardInput(RawInput^.keyboard);
          RIM_TYPEHID:;
        end;
    finally
      FreeMem(RawInput,RawInputSize);
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure TInputManager.ProcessKeyboardInput(Input: RawKeyboard);
var
  Flag_E0:  Boolean;
  Flag_E1:  Boolean;
begin
// Repair input (because raw input in Windows is bugged and generally weird)
Flag_E0 := (Input.Flags and RI_KEY_E0) <> 0;
Flag_E1 := (Input.Flags and RI_KEY_E1) <> 0;
case Input.VKey of
  VK_SHIFT:   If fDiscernKeyboardSides then
                Input.VKey := MapVirtualKey(Input.MakeCode,MAPVK_VSC_TO_VK_EX);
  VK_CONTROL: If fDiscernKeyboardSides then
                If Flag_E0 then Input.VKey := VK_RCONTROL
                  else Input.VKey := VK_LCONTROL;
  VK_MENU:    If fDiscernKeyboardSides then
                If Flag_E0 then Input.VKey := VK_RMENU
                  else Input.VKey := VK_LMENU;
//VK_RETURN:  If Flag_E0 then Input.VKey := VK_NUMPADENTER; -> Sadly, there is no VK for numpad enter.
  VK_INSERT:  If not Flag_E0 then Input.VKey := VK_NUMPAD0;
  VK_DELETE:  If not Flag_E0 then Input.VKey := VK_DECIMAL;
  VK_HOME:    If not Flag_E0 then Input.VKey := VK_NUMPAD7;
  VK_END:     If not Flag_E0 then Input.VKey := VK_NUMPAD1;
  VK_PRIOR:   If not Flag_E0 then Input.VKey := VK_NUMPAD9;
  VK_NEXT:    If not Flag_E0 then Input.VKey := VK_NUMPAD3;
  VK_CLEAR:   If not Flag_E0 then Input.VKey := VK_NUMPAD5;
  VK_LEFT:    If not Flag_E0 then Input.VKey := VK_NUMPAD4;
  VK_RIGHT:   If not Flag_E0 then Input.VKey := VK_NUMPAD6;
  VK_UP:      If not Flag_E0 then Input.VKey := VK_NUMPAD8;
  VK_DOWN:    If not Flag_E0 then Input.VKey := VK_NUMPAD2;
  VK_NUMLOCK: Input.MakeCode := MapVirtualKey(Input.VKey,MAPVK_VK_TO_VSC) or $100;
  $FF:        Exit;
end;
If Flag_E1 then
  begin
    If Input.VKey = VK_PAUSE then
      Input.MakeCode := $45
    else
      Input.MakeCode := MapVirtualKey(Input.VKey,MAPVK_VK_TO_VSC);
  end;
If (Input.Flags and RI_KEY_BREAK) <> 0 then
  ProcessKeyRelease(Input.VKey)
else
  ProcessKeyPress(Input.VKey);
end;

//------------------------------------------------------------------------------

procedure TInputManager.ProcessKeyPress(VKey: Word);
begin
If fCurrentInput.PrimaryKey <> VKey then
  begin
    fCurrentInput.ShiftKey := fCurrentInput.PrimaryKey;
    fCurrentInput.PrimaryKey := VKey;
  end;
If Assigned(fOnVirtualKeyPress) then fOnVirtualKeyPress(Self,VKey);
If fTriggerInvoke = tiOnPress then InvokeTrigger;
end;

//------------------------------------------------------------------------------

procedure TInputManager.ProcessKeyRelease(VKey: Word);
begin
If Assigned(fOnVirtualKeyRelease) then fOnVirtualKeyRelease(Self,VKey);
If fTriggerInvoke = tiOnRelease then InvokeTrigger;
If fCurrentInput.ShiftKey = VKey then fCurrentInput.ShiftKey := -1;
If fCurrentInput.PrimaryKey = VKey then
  begin
    fCurrentInput.PrimaryKey := fCurrentInput.ShiftKey;
    fCurrentInput.ShiftKey := -1;
  end;
end;

//------------------------------------------------------------------------------

Function TInputManager.InvokeTrigger: Integer;
begin
If omTrigger in fMode then
  begin
    Result := fTriggersList.IndexOfInput(fCurrentInput);
    If Result >= 0 then
      If Assigned(fOnTrigger) then fOnTrigger(Self,fTriggersList[Result]);
  end
else Result := -1;
end;

{------------------------------------------------------------------------------}
{   TInputManager // Public methods                                            }
{------------------------------------------------------------------------------}

class Function TInputManager.GetVirtualKeyName(VirtualKey: Word; NumberForUnknown: Boolean = False): String;
var
  Flag_E0:  Boolean;
  ScanCode: Integer;
begin
case VirtualKey of
  VK_NUMLOCK,VK_RCONTROL,VK_RMENU,VK_LWIN,VK_RWIN,VK_INSERT,VK_DELETE,VK_HOME,
  VK_END,VK_PRIOR,VK_NEXT,VK_LEFT,VK_RIGHT,VK_UP,VK_DOWN,VK_DIVIDE,VK_APPS,
  VK_SNAPSHOT,VK_CLEAR:  Flag_E0 := True;
else
  Flag_E0 := False;
end;
// MapVirtualKey(Ex) is unable to map following VK to SC, have to do it manually
case VirtualKey of
  VK_PAUSE:     ScanCode := $45;
  VK_SNAPSHOT:  ScanCode := $37;
else
  ScanCode := MapVirtualKey(VirtualKey,MAPVK_VK_TO_VSC);
end;
If Flag_E0 then ScanCode := ScanCode or $100;
SetLength(Result,32);
SetLength(Result,GetKeyNameText(ScanCode shl 16,PChar(Result),Length(Result)));
If (Length(Result) <= 0) and NumberForUnknown then
  Result := '0x' + IntToHex(VirtualKey,2);
end;

//------------------------------------------------------------------------------

class Function TInputManager.GetInputKeyNames(Input: TInput; VKOnly: Boolean = False): String;
begin
If InputIsValid(Input) then
  begin
    If Input.ShiftKey >= 0 then
      begin
        If VKOnly then
          Result := '0x' + IntToHex(Byte(Input.ShiftKey),2) + ' + '
        else
          Result := GetVirtualKeyName(Input.ShiftKey,True) + ' + ';
      end
    else Result := '';
    If VKOnly then
      Result := Result + '0x' + IntToHex(Byte(Input.PrimaryKey),2)
    else
      Result := Result + GetVirtualKeyName(Input.PrimaryKey,True);
  end
else Result := '';
end;

//------------------------------------------------------------------------------

class Function TInputManager.InputIsValid(Input: TInput): Boolean;
begin
Result := (Input.PrimaryKey >= 0);
end;

//------------------------------------------------------------------------------

constructor TInputManager.Create(UtilityWindow: TUtilityWindow);
var
  RawInputDevice:  PRawInputDevice;
begin
inherited Create;
fUtilityWindow := UtilityWindow;
fUtilityWindow.OnMessage.Add(MessageHandler);
fTriggersList := TTriggersList.Create;
fMode := [omProcess];
fDiscernKeyboardSides := False;
fCurrentInput.PrimaryKey := -1;
fCurrentInput.ShiftKey := -1;
fTriggerInvoke := tiOnPress;
// Register raw input for keyboard
New(RawInputDevice);
try
  RawInputDevice^.usUsagePage := $01;
  RawInputDevice^.usUsage := $06; // keyboard
  RawInputDevice^.dwFlags := RIDEV_INPUTSINK;
  RawInputDevice^.hwndTarget := fUtilityWindow.WindowHandle;
  If not RegisterRawInputDevices(RawInputDevice,1,SizeOf(TRawInputDevice)) then
    raise Exception.Create('TInputManager.Create: Raw input registration failed.');
finally
  Dispose(RawInputDevice);
end;
end;

//------------------------------------------------------------------------------

destructor TInputManager.Destroy;
begin
fTriggersList.Free;
fUtilityWindow.OnMessage.Remove(MessageHandler);
inherited;
end;

//------------------------------------------------------------------------------

procedure TInputManager.AddTrigger(Trigger: Integer; Input: TInput);
begin
fTriggersList.AddTrigger(Trigger,Input);
end;

end.
