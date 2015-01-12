unit UpdateForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst,
  ACC_GamesData, ExtCtrls;

type
  TfUpdateForm = class(TForm)
    clbUpdateData: TCheckListBox;
    lblIcons: TLabel;
    meIcons: TMemo;
    bvlVertSplit: TBevel;
    btnLoadUpdateFile: TButton;
    btnMakeUpdate: TButton;
    gbColorLegend: TGroupBox;
    shpLegCol_NewEntry: TShape;    
    lblLegTxt_NewEntry: TLabel;
    shpLegCol_NewVersion: TShape;
    lblLegTxt_NewVersion: TLabel;
    shpLegCol_CurrentVersion: TShape;
    lblLegTxt_CurrentVersion: TLabel;
    shpLegCol_OldVersion: TShape;
    lblLegTxt_OldVersion: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure clbUpdateDataClickCheck(Sender: TObject);    
    procedure clbUpdateDataDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnLoadUpdateFileClick(Sender: TObject);
    procedure btnMakeUpdateClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fUpdateDataManager: TGamesDataManager;
    procedure FillList;
  public
    { Public declarations }
  end;

var
  fUpdateForm: TfUpdateForm;

implementation

{$R *.dfm}

uses
  MsgForm,
  ACC_Manager;

procedure TfUpdateForm.FillList;
var
  i:        Integer;
  TempStr:  String;
begin
clbUpdateData.Items.BeginUpdate;
try
  clbUpdateData.Items.Clear;
  For i := 0 to Pred(fUpdateDataManager.GamesDataCount) do
    begin
      clbUpdateData.Items.Add(fUpdateDataManager[i].ExtendedTitle);
      clbUpdateData.Checked[i] := fUpdateDataManager[i].UpdateInfo.Add;
    end;
  TempStr := '';
  For i := 0 to Pred(fUpdateDataManager.GameIcons.Count) do
    begin
      TempStr := TempStr + fUpdateDataManager.GameIcons[i].Identifier;
      If i < Pred(fUpdateDataManager.GameIcons.Count) then TempStr := TempStr + ', ';
    end;
  meIcons.Lines.Text := TempStr;
finally
  clbUpdateData.Items.EndUpdate;
end;
end;

//==============================================================================

procedure TfUpdateForm.FormCreate(Sender: TObject);
begin
fUpdateDataManager := TGamesDataManager.Create;
fUpdateDataManager.GameIcons.DefaultIcon := False;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.FormShow(Sender: TObject);
begin
fUpdateDataManager.Clear;
FillList;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.FormDestroy(Sender: TObject);
begin
fUpdateDataManager.Free;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.clbUpdateDataClickCheck(Sender: TObject);
begin
fUpdateDataManager.GameDataPtr[clbUpdateData.ItemIndex]^.UpdateInfo.Add := clbUpdateData.Checked[clbUpdateData.ItemIndex]; 
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.clbUpdateDataDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  clNewEntry       = clBlue;
  clNewVersion     = clLime;
  clCurrentVersion = clYellow;
  clOldVersion     = clRed;
  clSelected       = $00E0E0E0;
  clHorSplit       = clSilver;
  StateBarWidth    = 10;
var
  TempGameData: TGameData;
  TempStr:      String;
begin
TempGameData := fUpdateDataManager.GameData[Index];
with clbUpdateData.Canvas do
  begin
    If odSelected in State then
      begin
        Brush.Color := clSelected;
        Pen.Color := clSelected;
      end
    else
      begin
        Brush.Color := clbUpdateData.Color;
        Pen.Color := clbUpdateData.Color;
      end;
    Rectangle(Rect);
    If TempGameData.UpdateInfo.NewEntry then
      begin
        Brush.Color := clNewEntry;
        Pen.Color := clNewEntry;
      end
    else If TempGameData.UpdateInfo.NewVersion then
      begin
        Brush.Color := clNewVersion;
        Pen.Color := clNewVersion;
      end
    else If TempGameData.UpdateInfo.OldVersion then
      begin
        Brush.Color := clOldVersion;
        Pen.Color := clOldVersion;
      end
    else
      begin
        Brush.Color := clCurrentVersion;
        Pen.Color := clCurrentVersion;
      end;
    Rectangle(Rect.Right - StateBarWidth,Rect.Top,Rect.Right,Rect.Bottom);
    Brush.Style := bsClear;
    Font := clbUpdateData.Font;
    Font.Style := [fsBold];
    TextOut(Rect.Left + 4,Rect.Top + 2,TempGameData.Title);
    Font.Style := [];
    TextOut(Rect.Left + 4,Rect.Top + ((Rect.Bottom - Rect.Top) - TextHeight(TempGameData.Info)) div 2,TempGameData.Info);
    Font.Color := clGray;
    Font.Name := 'Courier New';
    TempStr := GUIDToString(TempGameData.Identifier) + ' - version ' + IntToStr(TempGameData.Version);
    TextOut(Rect.Left + 4,Rect.Bottom - 2 - TextHeight(TempStr),TempStr);
    Pen.Color := clHorSplit;
    MoveTo(0,Rect.Bottom - 1);
    LineTo(Rect.Right - StateBarWidth,Rect.Bottom - 1);
  end;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.btnLoadUpdateFileClick(Sender: TObject);
var
  FileName: String;
begin
If PromptForFileName(FileName,'Supported files (*.ini,*.gdb,*.ugdb)|*.ini;*.gdb;*.ugdb|All files|*.*','','Load update file',ExtractFileDir(ParamStr(0)),False) then
  begin
    If fUpdateDataManager.LoadFrom(FileName) then
      begin
        fUpdateDataManager.CheckUpdate(ACCManager.GamesDataManager);
        FillList;
      end
    else ShowErrorMsg('Failed to load selected file.');
  end;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.btnMakeUpdateClick(Sender: TObject);
var
  AddCount: Integer;
begin
AddCount := ACCManager.GamesDataManager.UpdateFrom(fUpdateDataManager);
If AddCount > 0 then
  begin
    ShowInfoMsg(IntToStr(AddCount) + ' entries were added to the list of supported games.');
    ACCManager.ProcessBinder.SetGamesData(ACCManager.GamesDataManager.GamesData);
    ACCManager.GamesDataManager.Save;
    fUpdateDataManager.CheckUpdate(ACCManager.GamesDataManager);
    FillList;
  end
else ShowInfoMsg('No entry added.');
end;

end.
