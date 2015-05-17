{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  Windows Messages communication library

  Base class

  ©František Milt 2015-05-14

  Version 1.0

===============================================================================}
unit WinMsgComm;

interface

{$INCLUDE '.\WinMsgComm_defs.inc'}

uses
  Windows, Messages, Classes,
  CRC32, UtilityWindow;

const
  WMC_MessageName = 'WMC_MsgName_72084D2C-7D6A-4EEE-A1C3-9FA36397075E';

  WMC_RESULT_ok    = lResult(-1);
  WMC_RESULT_error = lResult(0);

  WMC_SendToAll = 0;

{-------------------------------------------------------------------------------
  sync    whether the message is sent synchronously (+) or not (-)
  ret     returned value (Msg.Result)

  ?       depends on actual settings (Synchronous property), with exception in
          sending 64bit long values (UInt64,Int64,Double) in 32bit mode, then
          they are sent using SendData function, and therefore synchronously
  v/i     returns WMC_RETURN_ok after successful processing (synchronous only)
  n/a     no action / not defined / not allowed / ignored
  ID      ID assigned by a server to the client endpoint 
-------------------------------------------------------------------------------}

{-------------------------------------|-------- payload (lParam) -------|- sync -|- ret -|- sender -}

  WMC_PING           = $00;         // sender HWND                      |   +    |  v/i  |  any

  WMC_QUERYSERVER    = $01;         // client HWND                      |   -    |  n/a  |  client
  WMC_SERVERONLINE   = $02;         // server HWND                      |   -    |  n/a  |  server
  WMC_SERVEROFFLINE  = $03;         // server HWND                      |   -    |  n/a  |  server
  WMC_CLIENTONLINE   = $04;         // client HWND                      |   +    |  ID   |  client
  WMC_CLIENTOFFLINE  = $05;         // client HWND                      |   -    |  n/a  |  client
  WMC_ISSERVER       = $06;         // n/a                              |   +    |  v/i  |  server

  WMC_QUERYPEERS     = $07;         // peer HWND                        |   +    |  n/a  |  peer
  WMC_PEERONLINE     = $08;         // peer HWND                        |   +    |  n/a  |  peer
  WMC_PEEROFFLINE    = $09;         // peer HWND                        |   -    |  n/a  |  peer

  WMC_VALUE_BOOL     = $10;         // boolean value (8bit)             |   ?    |  n/a  |  any
  WMC_VALUE_BYTE     = $11;         // 8bit unsigned integer value      |   ?    |  n/a  |  any
  WMC_VALUE_SHORTINT = $12;         // 8bit signed integer value        |   ?    |  n/a  |  any
  WMC_VALUE_WORD     = $13;         // 16bit unsigned integer value     |   ?    |  n/a  |  any
  WMC_VALUE_SMALLINT = $14;         // 16bit signed integer value       |   ?    |  n/a  |  any
  WMC_VALUE_LONGWORD = $15;         // 32bit unsigned integer value     |   ?    |  n/a  |  any
  WMC_VALUE_LONGINT  = $16;         // 32bit signed integer value       |   ?    |  n/a  |  any
  WMC_VALUE_SINGLE   = $17;         // 32bit float value                |   ?    |  n/a  |  any
  WMC_VALUE_UINT64   = $18;         // 64bit unsigned integer value     |   ?    |  n/a  |  any
  WMC_VALUE_INT64    = $19;         // 64bit signed integer value       |   ?    |  n/a  |  any
  WMC_VALUE_DOUBLE   = $1A;         // 64bit float value                |   ?    |  n/a  |  any

  WMC_TRANSACTION_START      = $20; // size of sent data (TWMCSize)     |   +    |  v/i  |  any
  WMC_TRANSACTION_END_DATA   = $21; // data checksum (TWMCCheckSum)     |   +    |  n/a  |  any
  WMC_TRANSACTION_END_UINT64 = $22; // data checksum (TWMCCheckSum)     |   +    |  n/a  |  any
  WMC_TRANSACTION_END_INT64  = $23; // data checksum (TWMCCheckSum)     |   +    |  n/a  |  any
  WMC_TRANSACTION_END_DOUBLE = $24; // data checksum (TWMCCheckSum)     |   +    |  n/a  |  any
  WMC_TRANSACTION_END_STRING = $25; // data checksum (TWMCCheckSum)     |   +    |  n/a  |  any

  WMC_TRANSACTION_BUFF1 = $30;      // 1 byte of data                   |   +    |  v/i  |  any
  WMC_TRANSACTION_BUFF2 = $31;      // 2 bytes of data                  |   +    |  v/i  |  any
  WMC_TRANSACTION_BUFF3 = $32;      // 3 bytes of data                  |   +    |  v/i  |  any
  WMC_TRANSACTION_BUFF4 = $33;      // 4 bytes of data                  |   +    |  v/i  |  any
  WMC_TRANSACTION_BUFF5 = $34;      // 5 bytes of data                  |   +    |  v/i  |  any
  WMC_TRANSACTION_BUFF6 = $35;      // 6 bytes of data                  |   +    |  v/i  |  any
  WMC_TRANSACTION_BUFF7 = $36;      // 7 bytes of data                  |   +    |  v/i  |  any
  WMC_TRANSACTION_BUFF8 = $37;      // 8 bytes of data                  |   +    |  v/i  |  any

{-------------------------------------|-------- payload (lParam) -------|- sync -|- ret -|- sender -}


type
{$IFDEF x64}
  PtrUInt = UInt64;
{$ELSE}
  PtrUInt = LongWord;
{$ENDIF}

{$IFDEF WMC64}
  TWMCSize     = UInt64;
  TWMCPosition = UInt64;
{$ELSE}
  TWMCSize     = LongWord;
  TWMCPosition = LongWord;
{$ENDIF}

  TWMCCheckSum = TCRC32;

  PUTF8Char = ^AnsiChar;

  TWMCConnectionID = Word;

  TWMCMultiValueType = (mvtBool,mvtByte,mvtShortInt,mvtWord,mvtSmallInt,
                        mvtLongWord,mvtLongInt,mvtUInt64,mvtInt64,mvtSingle,
                        mvtDouble,mvtData,mvtString);

  TWMCMultiValue = record
    UserCode:    Byte;
    StringValue: String;
    case ValueType: TWMCMultiValueType of
      mvtBool:      (BoolValue:     Boolean);
      mvtByte:      (ByteValue:     Byte);
      mvtShortInt:  (ShortIntValue: ShortInt);
      mvtWord:      (WordValue:     Word);
      mvtSmallInt:  (SmallIntValue: SmallInt);
      mvtLongWord:  (LongWordValue: LongWord);
      mvtLongInt:   (LongIntValue:  LongInt);
      mvtUInt64:    (UInt64Value:   UInt64);
      mvtInt64:     (Int64Value:    Int64);      
      mvtSingle:    (SingleValue:   Single);
      mvtDouble:    (DoubleValue:   Double);
      mvtData:      (DataSize:      TWMCSize;
                     DataPtr:       Pointer)
  end;

  TWMCTransactionContext = record
    SenderID: TWMCConnectionID;
    DataSize: TWMCSize;
    DataPtr:  Pointer;
    Position: TWMCPosition;
    CheckSum: TWMCCheckSum;
  end;

  TWMCConnectionInfo = record
    ConnectionID: TWMCConnectionID;
    WindowHandle: HWND;
    Transacting:  Boolean;
    Transaction:  TWMCTransactionContext;
  end;
  PWMCConnectionInfo = ^TWMCConnectionInfo;

  TWMCValueReceivedEvent = procedure(Sender: TObject; SenderID: TWMCConnectionID; Value: TWMCMultiValue) of object;
  TWMCDataReceivedEvent = procedure(Sender: TObject; SenderID: TWMCConnectionID; MessageCode, UserCode: Byte; Payload: lParam) of object;
  TWMCMessageEvent = procedure(var Msg: TMessage; var Handled: Boolean) of object;
  TWMCConnectionEvent = procedure(Sender: TObject; ConnectionInfo: TWMCConnectionInfo; ConnectionIndex: Integer) of object;


{==============================================================================}
{------------------------------------------------------------------------------}
{                               TWinMsgCommBase                                }
{------------------------------------------------------------------------------}
{==============================================================================}
  TWinMsgCommBase = class(TObject)
  private
    fID:              TWMCConnectionID;
    fMessageName:     String;
    fMessageID:       LongWord;
    fSynchronous:     Boolean;
    fOwnsWindow:      Boolean;
    fWindow:          TUtilityWindow;
    fConnections:     TList;   
    fOnValueReceived: TWMCValueReceivedEvent;
    fOnDataReceived:  TWMCDataReceivedEvent;
    fOnMessage:       TWMCMessageEvent;
    Function GetWindowHandle: HWND;
    Function GetConnectionCount: Integer;
    Function GetConnection(Index: Integer): TWMCConnectionInfo;
  protected
    Function GetFreeID: TWMCConnectionID; virtual;
    procedure SetID(NewID: TWMCConnectionID); virtual;
    Function AddConnection(ConnectionInfo: PWMCConnectionInfo): Integer; virtual;
    procedure DeleteConnection(Index: Integer); virtual;
    procedure TransactionStart(var Transaction: TWMCTransactionContext; Size: TWMCSize; SenderID: TWMCConnectionID); virtual;
    Function TransactionAdd(var Transaction: TWMCTransactionContext; Data: lParam; Bytes: Byte): Boolean; virtual;
    Function TransactionEnd(var Transaction: TWMCTransactionContext; CheckSum: TWMCCheckSum; MessageCode, UserCode: Byte): Boolean; virtual;
    procedure MessagesHandler(var Msg: TMessage; var Handled: Boolean); virtual;
    Function ProcessMessage(SenderID: TWMCConnectionID; MessageCode, UserCode: Byte; Payload: lParam): lResult; virtual;
    procedure Process_WM_COPYDATA(const Msg: TMessage); virtual;
    Function SendMessageTo(TargetWindow: HWND; wParam: wParam; lParam: lParam; Synchronous: Boolean): lResult; overload; virtual;
    Function SendMessageTo(TargetWindow: HWND; wParam: wParam; lParam: lParam): lResult; overload; virtual;
    Function SendMessageToAll(wParam: wParam; lParam: lParam; Synchronous: Boolean): lResult; overload; virtual;
    Function SendMessageToAll(wParam: wParam; lParam: lParam): lResult; overload; virtual;
  public
    constructor Create(Window: TUtilityWindow = nil; Synchronous: Boolean = False; const MessageName: String = WMC_MessageName); virtual;
    destructor Destroy; override;
    procedure ProcessMessages(Synchronous: Boolean); overload; virtual;
    procedure ProcessMessages; overload; virtual;
    Function SendMessage(MessageCode, UserCode: Byte; Payload: lParam; RecipientID: TWMCConnectionID = WMC_SendToAll): lResult; virtual; abstract;
    Function SendBool(Value: Boolean; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendByte(Value: Byte; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendShortInt(Value: ShortInt; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendWord(Value: Word; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendSmallInt(Value: SmallInt; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendLongWord(Value: LongWord; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendLongInt(Value: LongInt; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendSingle(Value: Single; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendUInt64(Value: UInt64; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendInt64(Value: Int64; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendDouble(Value: Double; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendData(const Data; Size: TWMCSize; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0; MessageCode: Byte = WMC_TRANSACTION_END_DATA): Boolean; virtual;
    Function SendString(const Value: String; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendInteger(Value: Integer; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function SendFloat(Value: Single; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean; virtual;
    Function ClearInvalidConnections: Integer; virtual;
    Function IndexOfConnection(ConnectionID: TWMCConnectionID): Integer; virtual;
    property Connections[Index: Integer]: TWMCConnectionInfo read GetConnection; default;
  published
    property ID: Word read fID;
    property MessageName: String read fMessageName;
    property MessageID: LongWord read fMessageID;
    property Synchronous: Boolean read fSynchronous write fSynchronous;
    property OwnsWindow: Boolean read fOwnsWindow;
    property Window: TUtilityWindow read fWindow;
    property WindowHandle: HWND read GetWindowHandle;
    property ConnectionCount: Integer read GetConnectionCount;
    property OnValueReceived: TWMCValueReceivedEvent read fOnValueReceived write fOnValueReceived;
    property OnDataReceived: TWMCDataReceivedEvent read fOnDataReceived write fOnDataReceived;
    property OnMessage: TWMCMessageEvent read fOnMessage write fOnMessage;
  end;

{==============================================================================}
{   Auxiliary functions                                                        }
{==============================================================================}

Function BuildWParam(ConnectionID: TWMCConnectionID; MessageCode, UserCode: Byte): wParam;
Function GetConnectionID(wParam: wParam): TWMCConnectionID;
Function GetMessageCode(wParam: wParam): Byte;
Function GetUserCode(wParam: wParam): Byte;  

implementation

uses
  SysUtils;

{==============================================================================}
{   Auxiliary functions                                                        }
{==============================================================================}  

Function BuildWParam(ConnectionID: TWMCConnectionID; MessageCode, UserCode: Byte): wParam;
begin
Result := wParam((ConnectionID shl 16) or (UserCode shl 8) or MessageCode);
end;

//------------------------------------------------------------------------------

Function GetConnectionID(wParam: wParam): TWMCConnectionID;
begin
Result := TWMCConnectionID(wParam shr 16);
end;

//------------------------------------------------------------------------------

Function GetMessageCode(wParam: wParam): Byte;
begin
Result := Byte(wParam);
end;

//------------------------------------------------------------------------------

Function GetUserCode(wParam: wParam): Byte;
begin
Result := Byte(wParam shr 8);
end;

//------------------------------------------------------------------------------

Function CalcCheckSum(OldSum: TWMCCheckSum; Value: lParam; Bytes: Byte): TWMCCheckSum;
begin
Result := BufferCRC32(OldSum,Value,Bytes);
end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                               TWinMsgCommBase                                }
{------------------------------------------------------------------------------}
{==============================================================================}

{==============================================================================}
{   TWinMsgCommBase - Private methods                                          }
{==============================================================================}

Function TWinMsgCommBase.GetWindowHandle: HWND;
begin
Result := fWindow.WindowHandle;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.GetConnectionCount: Integer;
begin
Result := fConnections.Count;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.GetConnection(Index: Integer): TWMCConnectionInfo;
begin
If (Index >= 0) and (Index < fConnections.Count) then
  Result := PWMCConnectionInfo(fConnections[Index])^
else
  raise Exception.CreateFmt('TWinMsgCommBase.GetConnection: Index (%d) out of bounds.',[Index]);
end;

{==============================================================================}
{   TWinMsgCommBase - Protected methods                                        }
{==============================================================================}

Function TWinMsgCommBase.GetFreeID: TWMCConnectionID;

  Function IDUsed(ID: Word): Boolean;
  var
    i:  Integer;
  begin
    Result := False;
    For i := 0 to Pred(fConnections.Count) do
      If PWMCConnectionInfo(fConnections[i])^.ConnectionID = ID then
        begin
          Result := True;
          Exit;
        end;
  end;

begin
Result := 1;
while IDUsed(Result) and (Result < $FFFF) do
  Inc(Result);
end;

//------------------------------------------------------------------------------

procedure TWinMsgCommBase.SetID(NewID: TWMCConnectionID);
begin
fID := NewID;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.AddConnection(ConnectionInfo: PWMCConnectionInfo): Integer;
begin
If IndexOfConnection(ConnectionInfo^.ConnectionID) < 0 then
  Result := fConnections.Add(ConnectionInfo)
else
  Result := -1;
end;

//------------------------------------------------------------------------------

procedure TWinMsgCommBase.DeleteConnection(Index: Integer);
var
  TempConnectionInfo: PWMCConnectionInfo;
begin
If (Index >= 0) and (Index < fConnections.Count) then
  begin
    TempConnectionInfo := PWMCConnectionInfo(fConnections[Index]);
    If TempConnectionInfo^.Transacting then
      FreeMem(TempConnectionInfo^.Transaction.DataPtr,TempConnectionInfo^.Transaction.DataSize);
    Dispose(TempConnectionInfo);
    fConnections.Delete(Index);    
  end;
end;

//------------------------------------------------------------------------------

procedure TWinMsgCommBase.TransactionStart(var Transaction: TWMCTransactionContext; Size: TWMCSize; SenderID: TWMCConnectionID);
begin
Transaction.SenderID := SenderID;
Transaction.DataSize := Size;
Transaction.DataPtr := AllocMem(Size);
Transaction.Position := 0;
Transaction.CheckSum := 0;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.TransactionAdd(var Transaction: TWMCTransactionContext; Data: lParam; Bytes: Byte): Boolean;
begin
If Transaction.Position + Bytes <= Transaction.DataSize then
  begin
    Move(Data,{%H-}Pointer({%H-}PtrUInt(Transaction.DataPtr) + Transaction.Position)^,Bytes);
    Transaction.CheckSum := CalcCheckSum(Transaction.CheckSum,Data,Bytes);
    Inc(Transaction.Position,Bytes);
    Result := True;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.TransactionEnd(var Transaction: TWMCTransactionContext; CheckSum: TWMCCheckSum; MessageCode, UserCode: Byte): Boolean;
var
  TempValue:  TWMCMultiValue;
  TempStr:    UTF8String;
begin
Result := Transaction.CheckSum = CheckSum;
If Result and Assigned(fOnValueReceived) then
  begin
    TempValue.StringValue := '';
    TempValue.UserCode := UserCode;
    case MessageCode of
      WMC_TRANSACTION_END_UINT64:
        begin
          If Transaction.DataSize = 8 then
            begin
              TempValue.ValueType := mvtUInt64;
              Move(Transaction.DataPtr^,TempValue.UInt64Value,Transaction.DataSize);
              fOnValueReceived(Self,Transaction.SenderID,TempValue);
            end
          else Result := False;
        end;
      WMC_TRANSACTION_END_INT64:
        begin
          If Transaction.DataSize = 8 then
            begin
              TempValue.ValueType := mvtInt64;
              Move(Transaction.DataPtr^,TempValue.Int64Value,Transaction.DataSize);
              fOnValueReceived(Self,Transaction.SenderID,TempValue);
            end
          else Result := False;
        end;
      WMC_TRANSACTION_END_DOUBLE:
        begin
          If Transaction.DataSize = 8 then
            begin
              TempValue.ValueType := mvtDouble;
              Move(Transaction.DataPtr^,TempValue.DoubleValue,Transaction.DataSize);
              fOnValueReceived(Self,Transaction.SenderID,TempValue);
            end
          else Result := False;
        end;
      WMC_TRANSACTION_END_STRING:
        begin
          TempValue.ValueType := mvtString;
          SetLength(TempStr,Transaction.DataSize);
          Move(Transaction.DataPtr^,PUTF8Char(TempStr)^,Transaction.DataSize);
        {$IFDEF FPC}
          TempValue.StringValue := TempStr;
        {$ELSE}
        {$IFDEF Unicode}
          TempValue.StringValue := DecodeUTF8(TempStr);
        {$ELSE}
          TempValue.StringValue := UTF8ToAnsi(TempStr);
        {$ENDIF}
        {$ENDIF}
          fOnValueReceived(Self,Transaction.SenderID,TempValue);
        end;
    else
      {WMC_TRANSACTION_END_DATA}
      TempValue.ValueType := mvtData;
      TempValue.DataSize := Transaction.DataSize;
      TempValue.DataPtr := Transaction.DataPtr;
      fOnValueReceived(Self,Transaction.SenderID,TempValue);
    end;
  end;
FreeMem(Transaction.DataPtr,Transaction.DataSize);
Transaction.DataPtr := nil;
end;

//------------------------------------------------------------------------------

procedure TWinMsgCommBase.MessagesHandler(var Msg: TMessage; var Handled: Boolean);
begin
Handled := False;
If Assigned(fOnMessage) then fOnMessage(Msg,Handled);
If not Handled then
  If Msg.Msg = fMessageID then
    begin
      Msg.Result := ProcessMessage(GetConnectionID(Msg.WParam),GetMessageCode(Msg.WParam),GetUserCode(Msg.WParam),Msg.LParam);
      Handled := True;
    end
  else If Msg.Msg = WM_COPYDATA then
    begin
      Process_WM_COPYDATA(Msg);
      Msg.Result := lResult(True);
      Handled := True;
    end;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.ProcessMessage(SenderID: TWMCConnectionID; MessageCode, UserCode: Byte; Payload: lParam): lResult;
var
  Index:  Integer;

  procedure ProcessValue(ValueType: TWMCMultiValueType);
  var
    TempValue:  TWMCMultiValue;
  begin
    Result := WMC_RESULT_ok;
    If Assigned(fOnValueReceived) then
      begin
        TempValue.UserCode := UserCode;
        TempValue.StringValue := '';        
        TempValue.ValueType := ValueType;
        case TempValue.ValueType of
          mvtBool:      TempValue.BoolValue := Boolean(Payload);
          mvtByte:      TempValue.ByteValue := Byte(Payload);
          mvtShortInt:  TempValue.ShortIntValue := ShortInt(Payload);
          mvtWord:      TempValue.WordValue := Word(Payload);
          mvtSmallInt:  TempValue.SmallIntValue := SmallInt(Payload);
          mvtLongWord:  TempValue.LongWordValue := LongWord(Payload);
          mvtLongInt:   TempValue.LongIntValue := LongInt(Payload);
          mvtSingle:    TempValue.SingleValue := PSingle(@Payload)^;
        {$IFDEF WMC64}
          mvtUInt64:    TempValue.UInt64Value := UInt64(Payload);
          mvtInt64:     TempValue.Int64Value := Int64(Payload);
          mvtDouble:    TempValue.DoubleValue := PDouble(@Payload)^;
        {$ENDIF}
        else
          Result := WMC_RESULT_error;
        end;
        fOnValueReceived(Self,SenderID,TempValue);
      end;
  end;

begin
case MessageCode of
  WMC_PING:           Result := WMC_RESULT_ok;
  WMC_VALUE_BOOL:     ProcessValue(mvtBool);
  WMC_VALUE_BYTE:     ProcessValue(mvtByte);
  WMC_VALUE_SHORTINT: ProcessValue(mvtShortInt);
  WMC_VALUE_WORD:     ProcessValue(mvtWord);
  WMC_VALUE_SMALLINT: ProcessValue(mvtSmallInt);
  WMC_VALUE_LONGWORD: ProcessValue(mvtLongWord);
  WMC_VALUE_LONGINT:  ProcessValue(mvtLongInt);
  WMC_VALUE_SINGLE:   ProcessValue(mvtSingle);
{$IFDEF WMC64}
  WMC_VALUE_UINT64:   ProcessValue(mvtUInt64);
  WMC_VALUE_INT64:    ProcessValue(mvtInt64);
  WMC_VALUE_DOUBLE:   ProcessValue(mvtDouble);
{$ENDIF}
  WMC_TRANSACTION_START:  begin
                            Index := IndexOfConnection(SenderID);
                            If (Index >= 0) and not PWMCConnectionInfo(fConnections[Index])^.Transacting then
                              begin
                                TransactionStart(PWMCConnectionInfo(fConnections[Index])^.Transaction,TWMCSize(Payload),SenderID);
                                PWMCConnectionInfo(fConnections[Index])^.Transacting := True;
                                Result := WMC_RESULT_ok;
                              end
                            else Result := WMC_RESULT_error;
                          end;
{$IFDEF WMC64}
  WMC_TRANSACTION_BUFF5,
  WMC_TRANSACTION_BUFF6,
  WMC_TRANSACTION_BUFF7,
  WMC_TRANSACTION_BUFF8,
{$ENDIF}
  WMC_TRANSACTION_BUFF1,
  WMC_TRANSACTION_BUFF2,
  WMC_TRANSACTION_BUFF3,
  WMC_TRANSACTION_BUFF4:  begin
                            Index := IndexOfConnection(SenderID);
                            If (Index >= 0) and PWMCConnectionInfo(fConnections[Index])^.Transacting then
                              begin
                                If not TransactionAdd(PWMCConnectionInfo(fConnections[Index])^.Transaction,Payload,MessageCode - WMC_TRANSACTION_BUFF1 + 1) then
                                  begin
                                    TransactionEnd(PWMCConnectionInfo(fConnections[Index])^.Transaction,not PWMCConnectionInfo(fConnections[Index])^.Transaction.CheckSum,MessageCode,UserCode);
                                    PWMCConnectionInfo(fConnections[Index])^.Transacting := False;
                                    Result := WMC_RESULT_error;
                                  end
                                else Result := WMC_RESULT_ok;
                              end
                            else Result := WMC_RESULT_error;
                          end;
  WMC_TRANSACTION_END_UINT64,
  WMC_TRANSACTION_END_INT64,
  WMC_TRANSACTION_END_DOUBLE,
  WMC_TRANSACTION_END_STRING,
  WMC_TRANSACTION_END_DATA:
                          begin
                            Index := IndexOfConnection(SenderID);
                            If (Index >= 0) and PWMCConnectionInfo(fConnections[Index])^.Transacting then
                              begin
                                If TransactionEnd(PWMCConnectionInfo(fConnections[Index])^.Transaction,TWMCCheckSum(Payload),MessageCode,UserCode) then
                                  Result := WMC_RESULT_ok
                                else
                                  Result := WMC_RESULT_error;
                                PWMCConnectionInfo(fConnections[Index])^.Transacting := False;
                              end
                            else Result := WMC_RESULT_error;
                          end;
else
  If Assigned(fOnDataReceived) then fOnDataReceived(Self,SenderID,MessageCode,UserCode,Payload);
  Result := WMC_RESULT_error;
end;
end;

//------------------------------------------------------------------------------

procedure TWinMsgCommBase.Process_WM_COPYDATA(const Msg: TMessage);
var
  TempValue:  TWMCMultiValue;
  SenderID:   TWMCConnectionID;
  WMCopyData: TCopyDataStruct;
  TempStr:    UTF8String;
begin
If Assigned(fOnValueReceived) then
  begin
    WMCopyData := {%H-}PCopyDataStruct(Msg.LParam)^;
    TempValue.StringValue := '';
    TempValue.UserCode := GetUserCode(wParam(WMCopyData.dwData));
    SenderID := GetConnectionID(wParam(WMCopyData.dwData));
    case GetMessageCode(wParam(WMCopyData.dwData)) of
      WMC_TRANSACTION_END_UINT64:
        If WMCopyData.cbData = 8 then
          begin
            TempValue.ValueType := mvtUInt64;
            Move(WMCopyData.lpData^,TempValue.UInt64Value,WMCopyData.cbData);
            fOnValueReceived(Self,SenderID,TempValue);
          end;
      WMC_TRANSACTION_END_INT64:
        If WMCopyData.cbData = 8 then
          begin
            TempValue.ValueType := mvtInt64;
            Move(WMCopyData.lpData^,TempValue.Int64Value,WMCopyData.cbData);
            fOnValueReceived(Self,SenderID,TempValue);
          end;
      WMC_TRANSACTION_END_DOUBLE:
        If WMCopyData.cbData = 8 then
          begin
            TempValue.ValueType := mvtDouble;
            Move(WMCopyData.lpData^,TempValue.DoubleValue,WMCopyData.cbData);
            fOnValueReceived(Self,SenderID,TempValue);
          end;
      WMC_TRANSACTION_END_STRING:
        begin
          TempValue.ValueType := mvtString;
          SetLength(TempStr,WMCopyData.cbData);
          Move(WMCopyData.lpData^,PUTF8Char(TempStr)^,WMCopyData.cbData);
        {$IFDEF FPC}
          TempValue.StringValue := TempStr;
        {$ELSE}
        {$IFDEF Unicode}
          TempValue.StringValue := DecodeUTF8(TempStr);
        {$ELSE}
          TempValue.StringValue := UTF8ToAnsi(TempStr);
        {$ENDIF}
        {$ENDIF}
          fOnValueReceived(Self,SenderID,TempValue);
        end;
    else
      {WMC_TRANSACTION_END_DATA}
      TempValue.ValueType := mvtData;
      TempValue.DataSize := WMCopyData.cbData;
      TempValue.DataPtr := WMCopyData.lpData;
      fOnValueReceived(Self,SenderID,TempValue);
    end;
  end;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendMessageTo(TargetWindow: HWND; wParam: wParam; lParam: lParam; Synchronous: Boolean): lResult;
begin
If Synchronous then Result := Windows.SendMessage(TargetWindow,MessageID,wParam,lParam)
  else Result := lResult(Windows.PostMessage(TargetWindow,MessageID,wParam,lParam));
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendMessageTo(TargetWindow: HWND; wParam: wParam; lParam: lParam): lResult;
begin
Result := SendMessageTo(TargetWindow,wParam,lParam,fSynchronous);
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendMessageToAll(wParam: wParam; lParam: lParam; Synchronous: Boolean): lResult;
var
  i:  Integer;
begin
If fConnections.Count > 0 then Result := WMC_RESULT_ok
  else Result := WMC_RESULT_error;
For i := 0 to Pred(fConnections.Count) do
  begin
    If SendMessageTo(PWMCConnectionInfo(fConnections[i])^.WindowHandle,wParam,lParam,Synchronous) <> WMC_RESULT_ok then
      Result := WMC_RESULT_error;
  end;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendMessageToAll(wParam: wParam; lParam: lParam): lResult;
begin
Result := SendMessageToAll(wParam,lParam,Synchronous);
end;

{==============================================================================}
{   TWinMsgCommBase - Public methods                                           }
{==============================================================================}

constructor TWinMsgCommBase.Create(Window: TUtilityWindow = nil; Synchronous: Boolean = False; const MessageName: String = WMC_MessageName);
begin
inherited Create;
fID := 0;
fMessageName := MessageName;
fMessageID := RegisterWindowMessage(PChar(MessageName));
fSynchronous := Synchronous;
fOwnsWindow := not Assigned(Window);
If fOwnsWindow then
  fWindow := TUtilityWindow.Create
else
  fWindow := Window;
fWindow.OnMessage.Add(MessagesHandler);
fConnections := TList.Create;
end;

//------------------------------------------------------------------------------

destructor TWinMsgCommBase.Destroy;
var
  i:  Integer;
begin
For i := Pred(fConnections.Count) downto 0 do DeleteConnection(i);
fConnections.Free;
If fOwnsWindow then
  fWindow.Free
else
  fWindow.OnMessage.Remove(MessagesHandler);
inherited;
end;

//------------------------------------------------------------------------------

procedure TWinMsgCommBase.ProcessMessages(Synchronous: Boolean);
begin
fWindow.ProcessMessages(Synchronous);
end;

//------------------------------------------------------------------------------

procedure TWinMsgCommBase.ProcessMessages;
begin
ProcessMessages(Synchronous);
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendBool(Value: Boolean; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_BOOL,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendByte(Value: Byte; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_BYTE,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendShortInt(Value: ShortInt; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_SHORTINT,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendWord(Value: Word; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_WORD,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendSmallInt(Value: SmallInt; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_SMALLINT,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendLongWord(Value: LongWord; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_LONGWORD,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendLongInt(Value: LongInt; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_LONGINT,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendSingle(Value: Single; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendMessage(WMC_VALUE_SINGLE,UserCode,lParam(Addr(Value)^),RecipientID) = WMC_RESULT_ok;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendUInt64(Value: UInt64; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
{$IFDEF WMC64}
Result := SendMessage(WMC_VALUE_UINT64,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
{$ELSE}
Result := SendData(Value,SizeOf(Value),RecipientID,UserCode,WMC_TRANSACTION_END_UINT64);
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendInt64(Value: Int64; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
{$IFDEF WMC64}
Result := SendMessage(WMC_VALUE_INT64,UserCode,lParam(Value),RecipientID) = WMC_RESULT_ok;
{$ELSE}
Result := SendData(Value,SizeOf(Value),RecipientID,UserCode,WMC_TRANSACTION_END_INT64);
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendDouble(Value: Double; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
{$IFDEF WMC64}
Result := SendMessage(WMC_VALUE_DOUBLE,UserCode,lParam(Addr(Value)^),RecipientID) = WMC_RESULT_ok;
{$ELSE}
Result := SendData(Value,SizeOf(Value),RecipientID,UserCode,WMC_TRANSACTION_END_DOUBLE);
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendData(const Data; Size: TWMCSize; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0; MessageCode: Byte = WMC_TRANSACTION_END_DATA): Boolean;
var
  Index:      Integer;
{$IFDEF UseWMCopyData}
  WMCopyData: TCopyDataStruct;
{$ELSE}

  Function SendAsTransaction(TargetWindow: HWND): Boolean;
  const
    BuffSize ={$IFDEF WMC64} 8{$ELSE} 4{$ENDIF};
  var
    Position:     TWMCPosition;
    Buffer:       lParam;
    CheckSum:     TWMCCheckSum;
  begin
    Result := False;
    CheckSum := 0;
    If SendMessageTo(TargetWindow,BuildWParam(fID,WMC_TRANSACTION_START,UserCode),lParam(Size),True) = WMC_RESULT_ok then
      try
        Position := 0;
        while (Position + BuffSize) <= Size do
          begin
            Buffer := 0;
            Move({%H-}Pointer({%H-}PtrUInt(@Data) + Position)^,Buffer,BuffSize);
          {$IFDEF WMC64}
            If SendMessageTo(TargetWindow,BuildWParam(fID,WMC_TRANSACTION_BUFF8,UserCode),Buffer,True) <> WMC_RESULT_ok then Exit;
          {$ELSE}
            If SendMessageTo(TargetWindow,BuildWParam(fID,WMC_TRANSACTION_BUFF4,UserCode),Buffer,True) <> WMC_RESULT_ok then Exit;
          {$ENDIF}
            CheckSum := CalcCheckSum(CheckSum,Buffer,BuffSize);
            Inc(Position,BuffSize);
          end;
        If (Position < Size) and ((Size - Position) < BuffSize) then
          begin
            Buffer := 0;
            Move({%H-}Pointer({%H-}PtrUInt(@Data) + Position)^,Buffer,Size - Position);
            If SendMessageTo(TargetWindow,BuildWParam(fID,WMC_TRANSACTION_BUFF1 + (Size - Position) - 1,UserCode),Buffer,True) <> WMC_RESULT_ok then Exit;
            CheckSum := CalcCheckSum(CheckSum,Buffer,Size - Position);
          end;
        Result := True;
      finally
        SendMessageTo(TargetWindow,BuildWParam(fID,MessageCode,UserCode),lParam(CheckSum),True);
      end;
  end;
  
{$ENDIF}
begin
Result := False;
If Size > 0 then
{$IFDEF UseWMCopyData}
  begin
    WMCopyData.dwData := BuildWParam(fID,MessageCode,UserCode);
    WMCopyData.cbData := Size;
    WMCopyData.lpData := @Data;
    If RecipientID = WMC_SendToAll then
      begin
        Result := fConnections.Count > 0;
        For Index := 0 to Pred(fConnections.Count) do
          If Windows.SendMessage(PWMCConnectionInfo(fConnections[Index])^.WindowHandle,WM_COPYDATA,wParam(WindowHandle),{%H-}lParam(@WMCopyData)) = 0 then
            Result := False;
      end
    else
      begin
        Index := IndexOfConnection(RecipientID);
        If Index >= 0 then
          Result := Windows.SendMessage(PWMCConnectionInfo(fConnections[Index])^.WindowHandle,WM_COPYDATA,wParam(WindowHandle),{%H-}lParam(@WMCopyData)) <> 0;
      end;
  end;
{$ELSE}
  begin
    If RecipientID = WMC_SendToAll then
      begin
        Result := fConnections.Count > 0;
        For Index := 0 to Pred(fConnections.Count) do
          begin
            If not SendAsTransaction(PWMCConnectionInfo(fConnections[Index])^.WindowHandle) then
              Result := False;
          end;
      end
    else
      begin
        Index := IndexOfConnection(RecipientID);
        If Index >= 0 then
            SendAsTransaction(PWMCConnectionInfo(fConnections[Index])^.WindowHandle);
      end;
  end;
{$ENDIF}  
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendString(const Value: String; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
{$IFDEF FPC}
begin
Result := SendData(PUTF8Char(Value)^,Length(Value),RecipientID,UserCode,WMC_TRANSACTION_END_STRING);
end;
{$ELSE}
var
  TempStr: UTF8String;
begin
{$IFDEF Unicode}
TempStr := UTF8Encode(Value);
{$ELSE}
TempStr := AnsiToUTF8(Value);
{$ENDIF}
Result := SendData(PUTF8Char(TempStr)^,Length(TempStr),RecipientID,UserCode,WMC_TRANSACTION_END_STRING);
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendInteger(Value: Integer; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendLongInt(Value,RecipientID,UserCode);
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.SendFloat(Value: Single; RecipientID: TWMCConnectionID = WMC_SendToAll; UserCode: Byte = 0): Boolean;
begin
Result := SendSingle(Value,RecipientID,UserCode);
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.ClearInvalidConnections: Integer;
var
  i:  Integer;
begin
Result := 0;
For i := Pred(fConnections.Count) downto 0 do
  begin
    If SendMessageTo(PWMCConnectionInfo(fConnections[i])^.WindowHandle,BuildWParam(0,WMC_PING,0),lParam(WindowHandle),True) <> WMC_RESULT_ok then
      begin
        Inc(Result);
        DeleteConnection(i);
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TWinMsgCommBase.IndexOfConnection(ConnectionID: TWMCConnectionID): Integer;
begin
For Result := 0 to Pred(fConnections.Count) do
  If PWMCConnectionInfo(fConnections[Result])^.ConnectionID = ConnectionID then Exit;
Result := -1;
end;

end.
