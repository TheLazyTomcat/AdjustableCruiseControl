program ExternalTester;

{$mode objfpc}{$H+}

uses
  ACC_PluginCheck
  {$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
  , LazUTF8
  {$IFEND};

{$R *.res}

begin
If ParamCount > 0 then
{$IF Defined(FPC) and not Defined(Unicode) and (FPC_FULLVERSION < 20701)}
  ExitCode := InternalPluginCheck(SysToUTF8(ParamStr(1)));
{$ELSE}
  ExitCode := InternalPluginCheck(ParamStr(1));
{$IFEND}
end.

