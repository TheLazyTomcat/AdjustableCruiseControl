{.$DEFINE Allow64bitTransfer}
{.$DEFINE UseWMCopyData}

{$IFDEF x64}
  {$IFDEF Allow64bitTransfer}
    {$DEFINE WMC64}
  {$ENDIF}
{$ELSE}
  {$UNDEF WMC64}
{$ENDIF}

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
