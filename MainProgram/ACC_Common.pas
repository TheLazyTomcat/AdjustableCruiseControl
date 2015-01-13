unit ACC_Common;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Forms;

const
  ACC_VersionShort = $00020002;
  ACC_VersionLong  = $0002000200000000;

  ACC_VersionShortStr = '2.2';
  ACC_VersionLongStr  = '2.2.0';
  ACC_VersionFullStr  = ACC_VersionLongStr
                        {$IFDEF FPC}+ '  L'{$ELSE}+ '  D'{$ENDIF}
                        {$IFDEF x64}+ '64'{$ELSE}+ '32'{$ENDIF}
                        {$IFDEF Debug}+' debug'{$ENDIF};

  ACC_TIMER_ID_Splash = 1;
  ACC_TIMER_ID_Binder = 2;

type
{$IFDEF x64}
  PtrInt  = Int64;
  PtrUInt = UInt64;
{$ELSE}
  PtrInt  = LongInt;
  PtrUInt = LongWord;
{$ENDIF}

Function UTF8ToString(UTF8Str: UTF8String): String;
Function StringToUTF8(Str: String): UTF8String;

procedure CenterFormToForm(Centered,CenterTo: TForm);

implementation

Function UTF8ToString(UTF8Str: UTF8String): String;
begin
{$IFDEF Unicode}
Result := UTF8Decode(UTF8Str);
{$ELSE}
Result := UTF8ToAnsi(UTF8Str);
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function StringToUTF8(Str: String): UTF8String;
begin
{$IFDEF Unicode}
Result := UTF8Encode(Str);
{$ELSE}
Result := AnsiToUTF8(Str);
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

end.
