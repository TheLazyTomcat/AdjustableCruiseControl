{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_TrayIcon;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, Graphics, Forms, Menus,
  UtilityWindow;

type
  TNotifyIconData = record
    cbSize:             DWORD;
    hWnd:               HWND;
    uID:                UINT;
    uFlags:             UINT;
    uCallbackMessage:   UINT;
    hIcon:              HICON;
    szTip:              Array[0..127] of Char;
    dwState:            DWORD;
    dwStateMask:        DWORD;
    szInfo:             Array[0..255] of Char;
    case Integer of
      0: (uTimeout:     DWORD);
      1: (uVersion:     DWORD;
          szInfoTitle:  Array[0..63] of Char;
          dwInfoFlags:  DWORD;
         {guidItem:     TGUID;}
         {hBalloonIcon: HICON});
  end;
  PNotifyIconData = ^TNotifyIconData;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                  TTrayIcon                                   }
{------------------------------------------------------------------------------}
{==============================================================================}
  TTrayIcon = class(TObject)
  private
    fUtilityWindow:   TUtilityWindow;
    fApplication:     TApplication;
    fPopupMenu:       TPopupMenu;
    fMessageID:       LongWord;
    fIcon:            TIcon;
    fIconData:        TNotifyIconData;
    fVisible:         Boolean;
  protected
    procedure LoadIconFromResources; virtual;
    procedure MessageHandler(var Msg: TMessage; var Handled: Boolean); virtual;
    procedure PopupMenu_Restore(Sender: TObject); virtual;
    procedure PopupMenu_Exit(Sender: TObject); virtual;
    procedure BuildPopupMenu; virtual;
  public
    constructor Create(UtilityWindow: TUtilityWindow; Application: TApplication);
    destructor Destroy; override;
    procedure UpdateTrayIcon; virtual;
    procedure SetTipText(IconTipText: String); virtual;
    procedure ShowTrayIcon; virtual;
    procedure HideTrayIcon; virtual;
  published
    property Visible: Boolean read fVisible;
  end;

implementation

{$R 'Resources\TrayIcon.res'}

uses
  SysUtils, Classes, ShellAPI, ACC_Strings;

{$IFDEF FPC}
Function Shell_NotifyIcon(dwMessage: DWORD; lpdata: PNotifyIconData): BOOL;
begin
Result := ShellAPI.Shell_NotifyIconA(dwMessage,PNOTIFYICONDATAA(lpData));
end;
{$ENDIF}

{==============================================================================}
{------------------------------------------------------------------------------}
{                                  TTrayIcon                                   }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TTrayIcon // Protected methods                                             }
{------------------------------------------------------------------------------}
  
procedure TTrayIcon.LoadIconFromResources;
var
  ResStream:  TResourceStream;
begin
ResStream := TResourceStream.Create(hInstance,'tray_icon',RT_RCDATA);
try
  fIcon.LoadFromStream(ResStream);
finally
  ResStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.MessageHandler(var Msg: TMessage; var Handled: Boolean);
var
  PopupPoint: TPoint;
begin
Handled := False;
If Msg.Msg = fMessageID then
  case Msg.LParam of
    WM_RBUTTONDOWN: begin
                      SetForegroundWindow(fApplication.MainForm.Handle);
                      GetCursorPos({%H-}PopupPoint);
                      fPopupMenu.Popup(PopupPoint.X,PopupPoint.Y);
                      Handled := True;
                    end;
    WM_LBUTTONDOWN: begin
                      Application.Restore;
                      fApplication.MainForm.Show;
                      SetForegroundWindow(fApplication.MainForm.Handle);
                      HideTrayIcon;
                      Handled := True;
                    end;
  end
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.PopupMenu_Restore(Sender: TObject);
begin
fApplication.Restore;
fApplication.MainForm.Show;
SetForegroundWindow(fApplication.MainForm.Handle);
HideTrayIcon;
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.PopupMenu_Exit(Sender: TObject);
begin
fApplication.MainForm.Close;
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.BuildPopupMenu;

  Function CreateMenuItem(const Caption: String; Handler: TNotifyEvent): TMenuItem;
  begin
    Result := TMenuItem.Create(fPopupMenu);
    Result.Caption := Caption;
    Result.OnClick := Handler;
  end;

begin
fPopupMenu := TPopupMenu.Create(nil);
fPopupMenu.Items.Add(CreateMenuItem(ACCSTR_TI_MI_Restore,PopupMenu_Restore));
fPopupMenu.Items.Add(CreateMenuItem(ACCSTR_TI_MI_Splitter,nil));
fPopupMenu.Items.Add(CreateMenuItem(ACCSTR_TI_MI_Exit,PopupMenu_Exit));
end;

{------------------------------------------------------------------------------}
{   TTrayIcon // Public methods                                                }
{------------------------------------------------------------------------------}

constructor TTrayIcon.Create(UtilityWindow: TUtilityWindow; Application: TApplication);
begin
inherited Create;
fUtilityWindow := UtilityWindow;
fUtilityWindow.OnMessage.Add(MessageHandler);
fApplication := Application;
BuildPopupMenu;
fMessageID := RegisterWindowMessage(PChar(ACCSTR_TI_MessageName));
fIcon := TIcon.Create;
LoadIconFromResources;
with fIconData do
  begin
    cbSize := SizeOf(fIconData);
    hWnd := fUtilityWindow.WindowHandle;
    uID := 0;
    uFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    uCallbackMessage := fMessageID;
    hicon := fIcon.Handle;
    fIconData.szTip := '';
  end;
fVisible := False;
end;

//------------------------------------------------------------------------------

destructor TTrayIcon.Destroy;
begin
HideTrayIcon;
fIcon.Free;
fPopupMenu.Free;
fUtilityWindow.OnMessage.Remove(MessageHandler);
inherited;
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.UpdateTrayIcon;
begin
Shell_NotifyIcon(NIM_MODIFY,@fIconData);
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.SetTipText(IconTipText: String);
begin
StrPLCopy(PChar(@fIconData.szTip),IconTipText,SizeOf(fIconData.szTip) - 1);
UpdateTrayIcon;
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.ShowTrayIcon;
begin
Shell_NotifyIcon(NIM_ADD,@fIconData);
fVisible := True;
end;

//------------------------------------------------------------------------------

procedure TTrayIcon.HideTrayIcon;
begin
Shell_NotifyIcon(NIM_DELETE,@fIconData);
fVisible := False;
end;

end.

