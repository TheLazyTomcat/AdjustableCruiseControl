{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_Common;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Forms;

const
  ACC_TIMER_ID_Splash = 1;
  ACC_TIMER_ID_Binder = 2;

var
  ACC_VersionShort: LongWord = 0;
  ACC_VersionLong:  Int64    = 0;

  ACC_VersionShortStr: String = '';
  ACC_VersionLongStr:  String = '';
  ACC_BuildStr:        String = '';

Function UTF8ToString(UTF8Str: UTF8String): String;
Function StringToUTF8(Str: String): UTF8String;

procedure CenterFormToForm(Centered,CenterTo: TForm);

implementation

uses
  SysUtils, WinFileInfo;


Function UTF8ToString(UTF8Str: UTF8String): String;
begin
{$IFDEF Unicode}
Result := UTF8Decode(UTF8Str);
{$ELSE}
{$IFDEF FPC}
Result := UTF8Str;
{$ELSE}
Result := UTF8ToAnsi(UTF8Str);
{$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StringToUTF8(Str: String): UTF8String;
begin
{$IFDEF Unicode}
Result := UTF8Encode(Str);
{$ELSE}
{$IFDEF FPC}
Result := Str;
{$ELSE}
Result := AnsiToUTF8(Str);
{$ENDIF}
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure CenterFormToForm(Centered,CenterTo: TForm);
begin
If Assigned(Centered) and Assigned(CenterTo) then
  begin
    Centered.Left := CenterTo.Left + ((CenterTo.Width - Centered.Width) div 2);
    Centered.Top := CenterTo.Top + ((CenterTo.Height - Centered.Height) div 2);
    If Centered.Left < Centered.Monitor.WorkareaRect.Left then Centered.Left := Centered.Monitor.WorkareaRect.Left
      else If (Centered.Left + Centered.Width) > (Centered.Monitor.WorkareaRect.Right - Centered.Monitor.WorkareaRect.Left) then
        Centered.Left := (Centered.Monitor.WorkareaRect.Right - Centered.Monitor.WorkareaRect.Left) - Centered.Width;
    If Centered.Top < Centered.Monitor.WorkareaRect.Top then Centered.Top := Centered.Monitor.WorkareaRect.Top
      else If (Centered.Top + Centered.Height) > (Centered.Monitor.WorkareaRect.Bottom - Centered.Monitor.WorkareaRect.Top) then
        Centered.Top := (Centered.Monitor.WorkareaRect.Bottom - Centered.Monitor.WorkareaRect.Top) - Centered.Height;
  end;
end;

//------------------------------------------------------------------------------

procedure InitVersionInfo;
begin
with TWinFileInfo.Create(WFI_LS_LoadVersionInfo or WFI_LS_LoadFixedFileInfo or WFI_LS_DecodeFixedFileInfo) do
try
  ACC_VersionShort := VersionInfoFixedFileInfo.dwProductVersionMS;
  ACC_VersionLong := VersionInfoFixedFileInfoDecoded.ProductVersionFull;
  ACC_VersionShortStr := IntToStr(VersionInfoFixedFileInfoDecoded.ProductVersionMembers.Major) + '.' +
                         IntToStr(VersionInfoFixedFileInfoDecoded.ProductVersionMembers.Minor);
  ACC_VersionLongStr := ACC_VersionShortStr + '.' + IntToStr(VersionInfoFixedFileInfoDecoded.ProductVersionMembers.Release);
  ACC_BuildStr := {$IFDEF FPC}'L'{$ELSE}'D'{$ENDIF}{$IFDEF x64}+ '64'{$ELSE}+ '32'{$ENDIF} +
                  ' #' + IntToStr(VersionInfoFixedFileInfoDecoded.FileVersionMembers.Build)
                  {$IFDEF Debug}+ ' debug'{$ENDIF};
finally
  Free;
end;
end;

//------------------------------------------------------------------------------

initialization
  InitVersionInfo;

end.
