{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_Log;

interface

{$INCLUDE ACC_Defs.inc}

uses
  SimpleLog;

var
  ACC_Logger: TSimpleLog;

implementation

uses
  SysUtils;

initialization
  ACC_Logger := TSimpleLog.Create;
  ACC_Logger.InternalLog := False;
  ACC_Logger.StreamToFile := True;

finalization
  FreeAndNil(ACC_Logger);

end.
