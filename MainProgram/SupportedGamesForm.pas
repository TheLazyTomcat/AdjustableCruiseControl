unit SupportedGamesForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, Grids,
  ACC_GamesData;

type
  TfSupportedGamesForm = class(TForm)
    lbGamesList: TListBox;
    lvGameDetails: TListView;
    gbGameDetails: TGroupBox;
    procedure FormCreate(Sender: TObject);    
    procedure FormShow(Sender: TObject);
    procedure lbGamesListClick(Sender: TObject);
    procedure lbGamesListDrawItem({%H-}Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
  private
    { Private declarations }
  protected
    fGameIsBinded:  Boolean;
    fBindedGame:    TGUID;
    procedure ClearGameDetails;
    procedure FillGameDetails(Index: Integer);
    procedure OnBindChange(Sender: TObject);
  public
    { Public declarations }
  end;

var
  fSupportedGamesForm: TfSupportedGamesForm;

implementation

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

uses
  {$IFDEF FPC}LCLType,{$ENDIF}
  CRC32, MD5,
  ACC_Strings, ACC_Manager;

procedure TfSupportedGamesForm.ClearGameDetails;
begin
lvGameDetails.Items.Clear;
end;

//------------------------------------------------------------------------------

procedure TfSupportedGamesForm.FillGameDetails(Index: Integer);
var
  TempGameData:   TGameData;
  FormatSettings: TFormatSettings;
  i:              Integer;

  procedure AddRow(const Value, DataText: String);
  begin
    with lvGameDetails.Items.Add do
      begin
        Caption := Value;
        SubItems.Add(DataText);
      end;
  end;

  procedure ListPointerData(const ValuePrefix: String; Data: TPointerData);
  var
    ii: Integer;
  begin
    AddRow(ValuePrefix + GDIN_GD_VAL_Flags,IntToHex(Data.Flags,8));
    AddRow(ValuePrefix + GDIN_GD_VAL_ModuleIndex,IntToStr(Data.ModuleIndex));
    AddRow(ValuePrefix + GDIN_GD_VAL_Offsets,IntToStr(Length(Data.Offsets)));
    For ii := Low(Data.Offsets) to High(Data.Offsets) do
      AddRow(Format(ValuePrefix + GDIN_GD_VAL_Offset,[ii]),IntToHex(Data.Offsets[ii],16));
    AddRow(ValuePrefix + GDIN_GD_VAL_Coefficient,FloatToStr(Data.Coefficient,FormatSettings));
  end;

begin
lvGameDetails.Items.BeginUpdate;
try
  lvGameDetails.Items.Clear;
  TempGameData := ACCManager.GamesDataManager.GameData[Index];
  {%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,{%H-}FormatSettings);
  FormatSettings.DecimalSeparator := '.';
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  AddRow(ACCSTR_UI_SUPG_VAL_Index,IntToStr(Index));
  AddRow(GDIN_GD_Protocol,IntToStr(TempGameData.Protocol));
  AddRow(GDIN_GD_Identifier,GUIDToString(TempGameData.Identifier));
  AddRow(GDIN_GD_Descriptor,TempGameData.Descriptor);
  AddRow(GDIN_GD_Version,IntToStr(TempGameData.Version));
  AddRow(GDIN_GD_Icon,TempGameData.Icon);
  AddRow(GDIN_GD_Date,DateToStr(TempGameData.Date,FormatSettings));
  AddRow(GDIN_GD_Author,TempGameData.Author);
  AddRow(GDIN_GD_Title,TempGameData.Title);
  AddRow(GDIN_GD_Info,TempGameData.Info);
  AddRow(GDIN_GD_ExtendedTitle,TempGameData.ExtendedTitle);
  AddRow(GDIN_GD_Modules,IntToStr(Length(TempGameData.Modules)));
  For i := Low(TempGameData.Modules) to High(TempGameData.Modules) do
    begin
      AddRow(Format(GDIN_GD_Module,[i]) + GDIN_GD_MOD_CheckFlags,IntToHex(TempGameData.Modules[i].CheckFlags,8));
      AddRow(Format(GDIN_GD_Module,[i]) + GDIN_GD_MOD_FileName,TempGameData.Modules[i].FileName);
      If (TempGameData.Modules[i].CheckFlags and CF_FILESIZE) <> 0 then
        AddRow(Format(GDIN_GD_Module,[i]) + GDIN_GD_MOD_Size,IntToStr(TempGameData.Modules[i].Size));
      If (TempGameData.Modules[i].CheckFlags and CF_FILECRC32) <> 0 then
        AddRow(Format(GDIN_GD_Module,[i]) + GDIN_GD_MOD_CRC32,CRC32ToStr(TempGameData.Modules[i].CRC32));
      If (TempGameData.Modules[i].CheckFlags and CF_FILEMD5) <> 0 then
        AddRow(Format(GDIN_GD_Module,[i]) + GDIN_GD_MOD_MD5,MD5ToStr(TempGameData.Modules[i].MD5));
    end;
  ListPointerData(GDIN_GD_CCSpeed,TempGameData.CCSpeed);
  ListPointerData(GDIN_GD_CCStatus,TempGameData.CCStatus);
  If TGamesDataManager.TruckSpeedSupported(TempGameData) <> ssrNone then
    ListPointerData(GDIN_GD_TruckSpeed,TempGameData.TruckSpeed);
  AddRow(GDIN_GD_Values,IntToStr(Length(TempGameData.Values)));
  For i := Low(TempGameData.Values) to High(TempGameData.Values) do
    ListPointerData(Format(GDIN_GD_Value,[i]),TempGameData.Values[i]);
finally
  lvGameDetails.Items.EndUpdate;
end;
end;

//------------------------------------------------------------------------------

procedure TfSupportedGamesForm.OnBindChange(Sender: TObject);
begin
fGameIsBinded := ACCManager.ProcessBinder.Binded;
fBindedGame := ACCManager.ProcessBinder.GameData.Identifier;
lbGamesList.Invalidate;
end;

//==============================================================================

procedure TfSupportedGamesForm.FormCreate(Sender: TObject);
begin
lbGamesList.DoubleBuffered := True;
lvGameDetails.DoubleBuffered := True;
fGameIsBinded := False;
ACCManager.OnBindStateChange.Add(OnBindChange);
end;

//------------------------------------------------------------------------------

procedure TfSupportedGamesForm.FormShow(Sender: TObject);
var
  i:  Integer;
begin
ClearGameDetails;
lbGamesList.Items.BeginUpdate;
try
  lbGamesList.Items.Clear;
  For i := 0 to Pred(ACCManager.GamesDataManager.GamesDataCount) do
    lbGamesList.Items.Add(ACCManager.GamesDataManager.GameData[i].ExtendedTitle);
finally
  lbGamesList.Items.EndUpdate;
end;
fSupportedGamesForm.Caption := Format(ACCSTR_UI_SUPG_SupportedList,[ACCManager.GamesDataManager.GamesDataCount]);
If lbGamesList.Items.Count > 0 then
  lbGamesList.ItemIndex := 0;
lbGamesList.OnClick(nil);
end;

//------------------------------------------------------------------------------

procedure TfSupportedGamesForm.lbGamesListClick(Sender: TObject);
begin
If lbGamesList.ItemIndex >= 0 then
  FillGameDetails(lbGamesList.ItemIndex)
else
  ClearGameDetails;
end;

//------------------------------------------------------------------------------

procedure TfSupportedGamesForm.lbGamesListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  clSideBar       = $00EFEFEF;
  clSideBarBinded = clLime;
  clHorSplit      = clSilver;
  DefIconSize     = 32;
  LeftBarWidth    = 6;
var
  TempGameData: TGameData;
  WorkBitmap:   TBitmap; // maybe use blobal object?
  WorkRect:     TRect;
begin
TempGameData := ACCManager.GamesDataManager.GameData[Index];
WorkBitmap := TBitmap.Create;
try
  WorkBitmap.Width := Rect.Right - Rect.Left;
  WorkBitmap.Height := Rect.Bottom - Rect.Top;
  WorkRect := Classes.Rect(0,0,WorkBitmap.Width,WorkBitmap.Height);
  with WorkBitmap.Canvas do
    begin
      If (odSelected in State) then
        begin
          Brush.Color := clSideBar;
          Pen.Color := clSideBar;
        end
      else
        begin
          Brush.Color := lbGamesList.Color;
          Pen.Color := lbGamesList.Color;
        end;
      Rectangle(WorkRect);
      If fGameIsBinded and IsEqualGUID(fBindedGame,TempGameData.Identifier) then
        begin
          Brush.Color := clSideBarBinded;
          Pen.Color := clSideBarBinded;
        end
      else
        begin
          Brush.Color := clSideBar;
          Pen.Color := clSideBar;
        end;
      Rectangle(WorkRect.Left,WorkRect.Top,WorkRect.Left + LeftBarWidth,WorkRect.Bottom);
      Brush.Style := bsClear;
      Font := lbGamesList.Font;
      Font.Style := [fsBold];
      TextOut(WorkRect.Left + LeftBarWidth + DefIconSize + 6,
              WorkRect.Top + 4,TempGameData.Title);
      Font.Style := [];
      TextOut(WorkRect.Left + LeftBarWidth + DefIconSize + 6,
              WorkRect.Bottom - 4 - TextHeight(TempGameData.Info),TempGameData.Info);
      Pen.Color := clHorSplit;
      MoveTo(WorkRect.Left,WorkRect.Bottom - 1);
      LineTo(WorkRect.Right,WorkRect.Bottom - 1);
      Draw(WorkRect.Left + LeftBarWidth + 2,WorkRect.Top + (WorkRect.Bottom - WorkRect.Top - DefIconSize) div 2,
           ACCManager.GamesDataManager.GameIcons.GetIcon(TempGameData.Icon));
    end;
  lbGamesList.Canvas.Draw(Rect.Left,Rect.Top,WorkBitmap);
  If (odFocused in State) then lbGamesList.Canvas.DrawFocusRect(Rect);
finally
  WorkBitmap.Free;
end;
end;

end.
