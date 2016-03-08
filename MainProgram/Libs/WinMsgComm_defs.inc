(*
  When defined, 64bit primitives are sent using one message (otherwise they are
  sent using SendData method) and 64bit buffers can be used in transactions.

  Has meaning anly for Win64 since it requires 64bit long lParam.

  Using this option can cause errors when cross-sending between 64bit and 32bit
  applications.

  Off by default.
*)
{.$DEFINE Allow64bitTransfer}

(*
  When defined, all data will be sent (method SendData) using WM_COPYDATA
  message instead of transaction system.

  Note that any endpoint can receive and process WM_COPYDATA message even when
  this symbol is not defined.

  WARNING - This message can be blocked in newer Windows OS.

  Off by default.
*)
{.$DEFINE UseWMCopyData}

{$IF defined(CPU64) or defined(CPU64BITS)}
  {$DEFINE 64bit}
  {$IFDEF Allow64bitTransfer}
    {$DEFINE WMC64}
  {$ENDIF}
{$ELSEIF defined(CPU16)}
  {$MESSAGE FATAL 'Unsupported CPU.'}
{$ELSE}
  {$DEFINE 32bit}
{$IFEND}

{$IF not(defined(WINDOWS) or defined(MSWINDOWS))}
  {$MESSAGE FATAL 'Unsupported operating system.'}
{$IFEND}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
