unit SupportedGamesForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Grids,
  ACC_GamesData;

type
  TfSupportedGames = class(TForm)
    lbGamesList: TListBox;
    lvGameDetails: TListView;
    gbGameDetails: TGroupBox;
    procedure FormCreate(Sender: TObject);    
    procedure FormShow(Sender: TObject);
    procedure lbGamesListClick(Sender: TObject);
    procedure lbGamesListDrawItem(Control: TWinControl; Index: Integer;
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
  fSupportedGames: TfSupportedGames;

implementation

{$R *.dfm}

uses
  CRC32, MD5,
  ACC_Strings, ACC_Manager;

procedure TfSupportedGames.ClearGameDetails;
begin
lvGameDetails.Items.Clear;
end;

//------------------------------------------------------------------------------

procedure TfSupportedGames.FillGameDetails(Index: Integer);
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
  GetLocaleFormatSettings(LOCALE_USER_DEFAULT,FormatSettings);
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
        AddRow(Format(GDIN_GD_Module,[i]) + GDIN_GD_MOD_MD5,MD5ToString(TempGameData.Modules[i].MD5));
    end;
  ListPointerData(GDIN_GD_CCSpeed,TempGameData.CCSpeed);
  ListPointerData(GDIN_GD_CCStatus,TempGameData.CCStatus);
  If TGamesDataManager.TruckSpeedSupported(TempGameData) then
    ListPointerData(GDIN_GD_TruckSpeed,TempGameData.TruckSpeed);
  AddRow(GDIN_GD_Values,IntToStr(Length(TempGameData.Values)));
  For i := Low(TempGameData.Values) to High(TempGameData.Values) do
    ListPointerData(Format(GDIN_GD_Value,[i]),TempGameData.Values[i]);
finally
  lvGameDetails.Items.EndUpdate;
end;
end;

//------------------------------------------------------------------------------

procedure TfSupportedGames.OnBindChange(Sender: TObject);
begin
fGameIsBinded := ACCManager.ProcessBinder.Binded;
fBindedGame := ACCManager.ProcessBinder.GameData.Identifier;
lbGamesList.Repaint;
end;

//==============================================================================

procedure TfSupportedGames.FormCreate(Sender: TObject);
begin
fGameIsBinded := False;
ACCManager.OnBindStateChange.Add(OnBindChange);
end;

//------------------------------------------------------------------------------

procedure TfSupportedGames.FormShow(Sender: TObject);
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
fSupportedGames.Caption := Format(ACCSTR_UI_SUPG_SupportedList,[ACCManager.GamesDataManager.GamesDataCount]);
If lbGamesList.Items.Count > 0 then
  lbGamesList.ItemIndex := 0;
lbGamesList.OnClick(nil);
end;

//------------------------------------------------------------------------------

procedure TfSupportedGames.lbGamesListClick(Sender: TObject);
begin
If lbGamesList.ItemIndex >= 0 then
  FillGameDetails(lbGamesList.ItemIndex)
else
  ClearGameDetails;
end;

//------------------------------------------------------------------------------

procedure TfSupportedGames.lbGamesListDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  clSideBar       = $00EFEFEF;
  clSideBarBinded = clLime;
  clHorSplit      = clSilver;
  DefIconSize     = 32;
  LeftBarWidth    = 6;
var
  TempGameData: TGameData;
begin
TempGameData := ACCManager.GamesDataManager.GameData[Index];
with lbGamesList.Canvas do
  begin
    If odSelected in State then
      begin
        Brush.Color := clSideBar;
        Pen.Color := clSideBar;
        Rectangle(Rect);
      end
    else
      begin
        Brush.Color := clWindow;
        Pen.Color := clWindow;
        Rectangle(Rect);
      end;
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
    Rectangle(Rect.Left,Rect.Top,Rect.Left + LeftBarWidth,Rect.Bottom);
    Brush.Style := bsClear;
    Font := lbGamesList.Font;
    Font.Style := [fsBold];
    TextOut(Rect.Left + LeftBarWidth + DefIconSize + 6,
            Rect.Top + 4,TempGameData.Title);
    Font.Style := [];
    TextOut(Rect.Left + LeftBarWidth + DefIconSize + 6,
            Rect.Bottom - 4 - TextHeight(TempGameData.Info),TempGameData.Info);
    Pen.Color := clHorSplit;
    MoveTo(Rect.Left,Rect.Bottom - 1);
    LineTo(Rect.Right,Rect.Bottom - 1);
    lbGamesList.Canvas.Draw(Rect.Left + LeftBarWidth + 2,
      Rect.Top + (Rect.Bottom - Rect.Top - DefIconSize) div 2,
      ACCManager.GamesDataManager.GameIcons.GetIcon(TempGameData.Icon));
  end;
end;

end.
