program ExternalTester;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes,
  SCS_Telemetry_Condensed,
  ACC_PluginCheck;

{$R *.res}

begin
If ParamCount > 0 then
  ExitCode := InternalPluginCheck(ParamStr(1));
end.

