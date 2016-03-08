{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_SplashScreen;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, Forms, Graphics, Classes,
  UtilityWindow, SimpleTimer;

type
{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TSplashForm                                  }
{------------------------------------------------------------------------------}
{==============================================================================}
  TSplashForm = class(TForm)
  protected
    procedure WMNCHitTest(var HitMessage: TWMNCHitTest); message WM_NCHITTEST;
  end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TSplashScreen                                }
{------------------------------------------------------------------------------}
{==============================================================================}

  TLoadCallback = procedure of object;

  TSplashScreen = class(TObject)
  private
    fApplication:         TApplication;
    fApplicationHandle:   HWND;
    fSplashForm:          TSplashForm;
    fAnimationTimer:      TSimpleTimer;
    fSplashBitmap:        TBitmap;
    fSplashPosition:      TPoint;
    fSplashSize:          TSize;
    fSplashBlendFunction: TBlendFunction;
    fAnimationTimeStamp:  TDateTime;
    fOnLoadRequest:       TNotifyEvent;
  protected
    procedure PrepareSplash; virtual;
    Function ProgressFadeIn: Boolean; virtual;
    Function ProgressFadeOut: Boolean; virtual;
    procedure OnAnimationTimer(Sender: TObject); virtual;
    procedure DoLoadRequest; virtual;
  public
    constructor Create(UtilityWindow: TUtilityWindow; Application: TApplication);
    destructor Destroy; override;
    procedure Start; virtual;
    property OnLoadRequest: TNotifyEvent read fOnLoadRequest write fOnLoadRequest;
  end;

implementation

{$R 'Resources\SplashImg.res'}

uses
  SysUtils, DateUtils,{$IFDEF FPC} Controls, InterfaceBase, Win32Extra,{$ENDIF}
  ACC_Common;

const
  // Splash screen constants
  
  AnimState_Start   = 0;
  AnimState_FadeIn  = 1;
  AnimState_Loading = 2;
  AnimState_Waiting = 3;
  AnimState_FadeOut = 4;
  AnimState_Done    = 5;

  FadeInTime  = 500{ms};
  FadeOutTime = 250{ms};
  SplashTime  = 1500{ms};
  LoadTime    = SplashTime - FadeInTime - FadeOutTime;
  
  AnimationTimerInterval = 10{ms};

{==============================================================================}
{------------------------------------------------------------------------------}
{                                 TSplashForm                                  }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TSplashForm // Protected methods                                           }
{------------------------------------------------------------------------------}

procedure TSplashForm.WMNCHitTest(var HitMessage: TWMNCHitTest);
begin
HitMessage.Result := HTCLIENT;
end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                                TSplashScreen                                 }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TSplashScreen // Protected methods                                         }
{------------------------------------------------------------------------------}

procedure TSplashScreen.PrepareSplash;
var
  ResourceStream: TResourceStream;
  MemoryStream:   TMemoryStream;
begin
ResourceStream := TResourceStream.Create(hInstance,'splash_image',RT_RCDATA);
try
  MemoryStream := TMemoryStream.Create;
  try
    MemoryStream.CopyFrom(ResourceStream,0);
    MemoryStream.Position := 0;
    fSplashBitmap.LoadFromStream(MemoryStream);
  finally
    MemoryStream.Free;
  end;
finally
  ResourceStream.Free;
end;
fSplashPosition := Point(0,0);
fSplashSize.cx := fSplashBitmap.Width;
fSplashSize.cy := fSplashBitmap.Height;
fSplashBlendFunction.BlendOp := AC_SRC_OVER;
fSplashBlendFunction.BlendFlags := 0;
fSplashBlendFunction.SourceConstantAlpha := 0;
fSplashBlendFunction.AlphaFormat := AC_SRC_ALPHA;
fSplashForm.BorderStyle := bsNone;
fSplashForm.FormStyle := fsStayOnTop;
fSplashForm.ClientWidth := fSplashBitmap.Width;
fSplashForm.ClientHeight := fSplashBitmap.Height;
fSplashForm.ParentWindow := GetDesktopWindow;
fSplashForm.Position := poScreenCenter;
fSplashForm.Left := fSplashForm.Monitor.Left + (fSplashForm.Monitor.Width - fSplashForm.ClientWidth) div 2;
fSplashForm.Top := fSplashForm.Monitor.Top + (fSplashForm.Monitor.Height - fSplashForm.ClientHeight) div 2;
SetWindowLong(fSplashForm.Handle,GWL_EXSTYLE,GetWindowLong(fSplashForm.Handle,GWL_EXSTYLE) or WS_EX_LAYERED or WS_EX_TOPMOST or WS_EX_TOOLWINDOW);
// remove program from task bar
SetWindowLong(fApplicationHandle,GWL_EXSTYLE,GetWindowLong(fApplicationHandle,GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
end;

//------------------------------------------------------------------------------

Function TSplashScreen.ProgressFadeIn: Boolean;
var
  Temp: Integer;
begin
Temp := Trunc((MilliSecondsBetween(Now,fAnimationTimeStamp) / FadeInTime) * 255);
If Temp < 255 then fSplashBlendFunction.SourceConstantAlpha := Temp
  else fSplashBlendFunction.SourceConstantAlpha := 255;
UpdateLayeredWindow(fSplashForm.Handle,0,nil,@fSplashSize,fSplashBitmap.Canvas.Handle,@fSplashPosition,0,@fSplashBlendFunction,ULW_ALPHA);
Result := fSplashBlendFunction.SourceConstantAlpha >= 255;
end;

//------------------------------------------------------------------------------

Function TSplashScreen.ProgressFadeOut: Boolean;
var
  Temp: Integer;
begin
Temp := 255 - Trunc((MilliSecondsBetween(Now,fAnimationTimeStamp) / FadeOutTime) * 255);
If Temp > 0 then fSplashBlendFunction.SourceConstantAlpha := Temp
  else fSplashBlendFunction.SourceConstantAlpha := 0;
UpdateLayeredWindow(fSplashForm.Handle,0,nil,@fSplashSize,fSplashBitmap.Canvas.Handle,@fSplashPosition,0,@fSplashBlendFunction,ULW_ALPHA);
Result := fSplashBlendFunction.SourceConstantAlpha <= 0;
end;

//------------------------------------------------------------------------------

procedure TSplashScreen.OnAnimationTimer(Sender: TObject);
begin
case fAnimationTimer.Tag of
  AnimState_Start:    begin
                        fApplication.ShowMainForm := False;
                        fAnimationTimer.Tag := AnimState_FadeIn;
                        fAnimationTimer.Enabled := True;
                        fAnimationTimeStamp := Now;
                      end;
{---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   }
  AnimState_FadeIn:   If ProgressFadeIn then
                        fAnimationTimer.Tag := AnimState_Loading;
{---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   }
  AnimState_Loading:  begin
                        fAnimationTimeStamp := Now;
                        DoLoadRequest;
                        fAnimationTimer.Tag := AnimState_Waiting;
                      end;
{---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   }
  AnimState_Waiting:  If MilliSecondsBetween(Now,fAnimationTimeStamp) >= LoadTime then
                        begin
                          fApplication.ShowMainForm := True;
                          SetWindowLong(fApplicationHandle,GWL_EXSTYLE,GetWindowLong(fApplicationHandle,GWL_EXSTYLE) and not WS_EX_TOOLWINDOW);
                          ShowWindow(fApplicationHandle,SW_SHOW);
                          SetForegroundWindow(fApplicationHandle);
                          fApplication.MainForm.Show;
                          fApplication.MainForm.BringToFront;
                          fAnimationTimer.Tag := AnimState_FadeOut;
                          fAnimationTimeStamp := Now;
                        end;
{---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   }
  AnimState_FadeOut:  If ProgressFadeOut then
                        fAnimationTimer.Tag := AnimState_Done;
{---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   }
  AnimState_Done:     begin
                        fAnimationTimer.Enabled := False;
                        fSplashForm.Close;
                      end;
end;
end;

//------------------------------------------------------------------------------

procedure TSplashScreen.DoLoadRequest;
begin
If Assigned(fOnLoadRequest) then fOnLoadRequest(Self);
end;

{------------------------------------------------------------------------------}
{   TSplashScreen // Public methods                                            }
{------------------------------------------------------------------------------}

constructor TSplashScreen.Create(UtilityWindow: TUtilityWindow; Application: TApplication);
begin
inherited Create;
fApplication := Application;
{$IFDEF FPC}
fApplicationHandle := WidgetSet.AppHandle;
{$ELSE}
fApplicationHandle := fApplication.Handle;
{$ENDIF}
fSplashForm := TSplashForm.CreateNew(nil);
fAnimationTimer := TSimpleTimer.Create(UtilityWindow,ACC_TIMER_ID_Splash);
fAnimationTimer.Interval := AnimationTimerInterval;
fAnimationTimer.Tag := AnimState_Start;
fAnimationTimer.OnTimer := OnAnimationTimer;
fSplashBitmap := TBitmap.Create;
PrepareSplash;
end;

//------------------------------------------------------------------------------

destructor TSplashScreen.Destroy;
begin
fSplashBitmap.Free;
fAnimationTimer.Free;
fSplashForm.Free;
inherited;
end;

//------------------------------------------------------------------------------

procedure TSplashScreen.Start;
begin
fSplashForm.Show;
fAnimationTimer.OnTimer(nil);
end;

end.
