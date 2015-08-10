{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Windows Messages communication library

  Client endpoint class

  ©František Milt 2015-08-10

  Version 1.2

===============================================================================}
unit WinMsgCommClient;

interface

{$INCLUDE '.\WinMsgComm_defs.inc'}

uses
  Windows, Classes, UtilityWindow, WinMsgComm;

{==============================================================================}
{------------------------------------------------------------------------------}
{                              TWinMsgCommClient                               }
{------------------------------------------------------------------------------}
{==============================================================================}
type
  TWinMsgCommClient = class(TWinMsgCommBase)
  private
    fOnServerStatusChange:  TNotifyEvent;
    Function GetServerOnline: Boolean;
    Function GetServerWindow: HWND;
  protected
    Function ProcessMessage(SenderID: TWMCConnectionID; MessageCode, UserCode: Byte; Payload: lParam): lResult; override;
  public
    constructor Create(Window: TUtilityWindow = nil; Synchronous: Boolean = False; const MessageName: String = WMC_MessageName); override;
    destructor Destroy; override;
    Function SendMessage(MessageCode, UserCode: Byte; Payload: lParam; {%H-}RecipientID: TWMCConnectionID = WMC_SendToAll): lResult; override;
    Function PingServer: Boolean;
  published
    property ServerOnline: Boolean read GetServerOnline;
    property ServerWindow: HWND read GetServerWindow;
    property OnServerStatusChange: TNotifyEvent read fOnServerStatusChange write fOnServerStatusChange;
  end;

implementation

uses
  SysUtils;

{==============================================================================}
{------------------------------------------------------------------------------}
{                              TWinMsgCommClient                               }
{------------------------------------------------------------------------------}
{==============================================================================}

{==============================================================================}
{   TWinMsgCommClient - Private methods                                        }
{==============================================================================}

Function TWinMsgCommClient.GetServerOnline: Boolean;
begin
Result := ConnectionCount > 0;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommClient.GetServerWindow: HWND;
begin
If ConnectionCount > 0 then
  Result := Connections[0].WindowHandle
else
  Result := INVALID_HANDLE_VALUE;
end;

{==============================================================================}
{   TWinMsgCommClient - Protected methods                                      }
{==============================================================================}

Function TWinMsgCommClient.ProcessMessage(SenderID: TWMCConnectionID; MessageCode, UserCode: Byte; Payload: lParam): lResult;
var
  Server:     PWMCConnectionInfo;
  AssignedID: lResult;
begin
case MessageCode of
  WMC_QUERYSERVER:    Result := WMC_RESULT_error;
  WMC_SERVERONLINE:   If not ServerOnline then
                        begin
                          New(Server);
                          Server^.ConnectionID := 0;
                          Server^.WindowHandle := HWND(Payload);
                          Server^.Transacting := False;
                          AssignedID := SendMessageTo(HWND(Payload),BuildWParam(ID,WMC_CLIENTONLINE,0),lParam(WindowHandle),True);
                          If (AssignedID > 0) and (AssignedID <= $FFFF) then
                            begin
                              SetID(TWMCConnectionID(AssignedID));
                              AddConnection(Server);
                              If Assigned(fOnServerStatusChange) then fOnServerStatusChange(Self);
                              Result := WMC_RESULT_ok;
                            end
                          else
                            begin
                              Dispose(Server);
                              Result := WMC_RESULT_error;
                            end;
                        end
                      else Result := WMC_RESULT_error;
  WMC_SERVEROFFLINE:  begin
                        while ConnectionCount > 0 do DeleteConnection(0);
                        SetID(0);
                        If Assigned(fOnServerStatusChange) then fOnServerStatusChange(Self);
                        Result := WMC_RESULT_ok;
                      end;
  WMC_CLIENTONLINE:   Result := WMC_RESULT_error;
  WMC_CLIENTOFFLINE:  Result := WMC_RESULT_error;
  WMC_ISSERVER:       Result := WMC_RESULT_error;
  WMC_QUERYPEERS:     Result := WMC_RESULT_error;
  WMC_PEERONLINE:     Result := WMC_RESULT_error;
  WMC_PEEROFFLINE:    Result := WMC_RESULT_error;
else
  Result := inherited ProcessMessage(SenderID,MessageCode,UserCode,Payload);
end;
end;

{==============================================================================}
{   TWinMsgCommClient - Public methods                                         }
{==============================================================================}

constructor TWinMsgCommClient.Create(Window: TUtilityWindow; Synchronous: Boolean; const MessageName: String);
begin
inherited Create(Window,Synchronous,MessageName);
SendMessageTo(HWND_BROADCAST,BuildWParam(ID,WMC_QUERYSERVER,0),lParam(WindowHandle),False);
end;

//------------------------------------------------------------------------------

destructor TWinMsgCommClient.Destroy;
begin
If ServerOnline then
  SendMessageTo(ServerWindow,BuildWParam(ID,WMC_CLIENTOFFLINE,0),lParam(WindowHandle),False);
inherited;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommClient.SendMessage(MessageCode, UserCode: Byte; Payload: lParam; RecipientID: TWMCConnectionID = WMC_SendToAll): lResult;
begin
If ServerOnline then
  Result := SendMessageTo(ServerWindow,BuildWParam(ID,MessageCode,UserCode),Payload)
else
  Result := WMC_RESULT_error;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommClient.PingServer: Boolean;
begin
ClearInvalidConnections;
Result := ServerOnline;
end;

end.
