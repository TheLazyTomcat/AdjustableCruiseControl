unit UpdateForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, CheckLst, ExtCtrls,
  ACC_GamesData;

type
  TfUpdateForm = class(TForm)
    clbUpdateData: TCheckListBox;
    lblIcons: TLabel;
    meIcons: TMemo;
    bvlVertSplit: TBevel;
    btnLoadUpdateFile: TButton;
    btnMakeUpdate: TButton;
    diaLoadUpdate: TOpenDialog;    
    gbColorLegend: TGroupBox;
    shpLegCol_NewEntry: TShape;    
    lblLegTxt_NewEntry: TLabel;
    shpLegCol_NewVersion: TShape;
    lblLegTxt_NewVersion: TLabel;
    shpLegCol_CurrentVersion: TShape;
    lblLegTxt_CurrentVersion: TLabel;
    shpLegCol_OldVersion: TShape;
    lblLegTxt_OldVersion: TLabel;
    btnAssociateFile: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure clbUpdateDataClickCheck(Sender: TObject);    
    procedure clbUpdateDataDrawItem({%H-}Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure btnLoadUpdateFileClick(Sender: TObject);
    procedure btnMakeUpdateClick(Sender: TObject);
    procedure btnAssociateFileClick(Sender: TObject);
  private
    { Private declarations }
  protected
    fDontClearOnShow: Boolean;
    fUpdateDataManager: TGamesDataManager;
    procedure FillList;
  public
    { Public declarations }
    procedure LoadUpdateFromFile(Sender: TObject; const UpdateFile: String);
  end;

var
  fUpdateForm: TfUpdateForm;

implementation

{$R Resources\UpdateIcon.res}

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

uses
  ShlObj, {$IFNDEF FPC}MsgForm,{$ELSE}LCLType,{$ENDIF} Registry,
  ACC_Common, ACC_Strings, ACC_Manager;

{$IFDEF FPC}
const
  clbCheckAreaWidth = 16;
{$ENDIF}

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

//------------------------------------------------------------------------------

procedure TfUpdateForm.LoadUpdateFromFile(Sender: TObject; const UpdateFile: String);
begin
If fUpdateDataManager.LoadFrom(UpdateFile) then
  begin
    fUpdateDataManager.CheckUpdate(ACCManager.GamesDataManager);
    FillList;
    If not Visible then
      begin
        fDontClearOnShow := True;
        try
          ShowModal;
        finally
          fDontClearOnShow := False;
        end;
      end;
  end
else
  begin
    FillList;  
  {$IFDEF FPC}
    Application.MessageBox('Failed to load selected file.','Games Data Update',MB_ICONERROR);
  {$ELSE}
    ShowErrorMsg(Application.MainForm,0,'Failed to load selected file.','Games Data Update','','');
  {$ENDIF}
  end;
end;

//==============================================================================

procedure TfUpdateForm.FormCreate(Sender: TObject);
begin
fDontClearOnShow := False;
clbUpdateData.DoubleBuffered := True;
diaLoadUpdate.InitialDir := ExtractFileDir(ParamStr(0));
fUpdateDataManager := TGamesDataManager.Create;
fUpdateDataManager.GameIcons.DefaultIcon := False;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.FormShow(Sender: TObject);
begin
If not fDontClearOnShow then
  begin
    fUpdateDataManager.Clear;
    FillList;
  end;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.FormDestroy(Sender: TObject);
begin
fUpdateDataManager.Free;
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.clbUpdateDataClickCheck(Sender: TObject);
{$IFDEF FPC}
var
  CursorPos:  TPoint;
begin
GetCursorPos({%H-}CursorPos);
If (clbUpdateData.ScreenToClient(CursorPos).x > clbCheckAreaWidth) and
   (clbUpdateData.ScreenToClient(CursorPos).x <= clbUpdateData.ItemHeight) then
   clbUpdateData.Checked[clbUpdateData.ItemIndex] := not clbUpdateData.Checked[clbUpdateData.ItemIndex];
{$ELSE}
begin
{$ENDIF}
fUpdateDataManager.GameDataPtr[clbUpdateData.ItemIndex]^.UpdateInfo.Add := clbUpdateData.Checked[clbUpdateData.ItemIndex]; 
end;

//------------------------------------------------------------------------------

var
  WorkBitmap: TBitmap;

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
{$IFDEF FPC}
  BoxSize          = 12;
{$ENDIF}
var
  TempGameData: TGameData;
  TempStr:      String;
  WorkRect:     TRect;
{$IFDEF FPC}
  CheckRect:    TRect;
  BoxRect:      TRect;
{$ENDIF}
begin
TempGameData := fUpdateDataManager.GameData[Index];
WorkRect := Classes.Rect(0,0,Rect.Right - Rect.Left,Rect.Bottom - Rect.Top);
If WorkBitmap.Width <> WorkRect.Right then
  WorkBitmap.Width := WorkRect.Right;
If WorkBitmap.Height <> WorkRect.Bottom then
  WorkBitmap.Height := WorkRect.Bottom;
with WorkBitmap.Canvas do
  begin
  {$IFDEF FPC}
    CheckRect := Classes.Rect(WorkRect.Left,WorkRect.Top,WorkRect.Left + clbCheckAreaWidth,WorkRect.Bottom);
    WorkRect.Left := WorkRect.Left + clbCheckAreaWidth;
    Brush.Color := clbUpdateData.Color;
    Pen.Color := clbUpdateData.Color;
    Rectangle(CheckRect);
    BoxRect.Left := CheckRect.Left + (CheckRect.Right - CheckRect.Left - BoxSize) div 2;
    BoxRect.Top := CheckRect.Top + (CheckRect.Bottom - CheckRect.Top - BoxSize) div 2;
    BoxRect.Right := BoxRect.Left + BoxSize;
    BoxRect.Bottom := BoxRect.Top + BoxSize;
    Brush.Color := $00F3F3F3;
    Pen.Color := clGray;
    Rectangle(BoxRect);
    If clbUpdateData.Checked[Index] then
      begin
        Brush.Color := clLime;
        Pen.Color := clLime;
        Rectangle(BoxRect.Left + 3,BoxRect.Top + 3,BoxRect.Right - 3,BoxRect.Bottom - 3);
      end;
  {$ENDIF}
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
    Rectangle(WorkRect);
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
    Rectangle(WorkRect.Right - StateBarWidth,WorkRect.Top,WorkRect.Right,WorkRect.Bottom);
    Brush.Style := bsClear;
    Font := clbUpdateData.Font;
    Font.Style := [fsBold];
    TextOut(WorkRect.Left + 4,WorkRect.Top + 2,TempGameData.Title);
    Font.Style := [];
    TextOut(WorkRect.Left + 4,WorkRect.Top + ((WorkRect.Bottom - WorkRect.Top) - TextHeight(TempGameData.Info)) div 2,TempGameData.Info);
    Font.Color := clGray;
    Font.Name := 'Courier New';
    TempStr := GUIDToString(TempGameData.Identifier) + ' - version ' + IntToStr(TempGameData.Version);
    TextOut(WorkRect.Left + 4,WorkRect.Bottom - 2 - TextHeight(TempStr),TempStr);
  {$IFDEF FPC}
    Pen.Color := clHorSplit;
    MoveTo(0,WorkRect.Bottom - 1);
    LineTo(WorkRect.Right - StateBarWidth,WorkRect.Bottom - 1);
    WorkRect.Left := WorkRect.Left - clbCheckAreaWidth;
  {$ENDIF}
  end;
clbUpdateData.Canvas.Draw(Rect.Left,Rect.Top,WorkBitmap);
{$IFNDEF FPC}
clbUpdateData.Canvas.Pen.Color := clHorSplit;
clbUpdateData.Canvas.MoveTo(0,Rect.Bottom - 1);
clbUpdateData.Canvas.LineTo(Rect.Right - StateBarWidth,Rect.Bottom - 1);
{$ENDIF}  
If odFocused in State then clbUpdateData.Canvas.DrawFocusRect(Rect);
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.btnLoadUpdateFileClick(Sender: TObject);
var
  i:  Integer;
begin
If diaLoadUpdate.Execute then
  begin
    {$IFDEF FPC}
    If fUpdateDataManager.LoadFrom(UTF8ToString(diaLoadUpdate.FileName)) then
    {$ELSE}
    If fUpdateDataManager.LoadFrom(diaLoadUpdate.FileName) then
    {$ENDIF}
      begin
        fUpdateDataManager.CheckUpdate(ACCManager.GamesDataManager);
        FillList;
        For i := 0 to Pred(fUpdateDataManager.GamesDataCount) do
          If fUpdateDataManager[i].UpdateInfo.Add then
            begin
              clbUpdateData.TopIndex := i;
              Break;
            end;
      end
    else
      begin
        FillList;
      {$IFDEF FPC}
        Application.MessageBox('Failed to load selected file.','Adjustable Cruise Control',MB_ICONERROR);
      {$ELSE}
        ShowErrorMsg('Failed to load selected file.');
      {$ENDIF}
      end;
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
  {$IFDEF FPC}
    Application.MessageBox(PChar(IntToStr(AddCount) + ' change(s) was made in the list of supported games.'),'Adjustable Cruise Control',MB_ICONINFORMATION);
  {$ELSE}
    ShowInfoMsg(IntToStr(AddCount) + ' change(s) was made in the list of supported games.');
  {$ENDIF}
    ACCManager.ProcessBinder.SetGamesData(ACCManager.GamesDataManager.GamesData);
    ACCManager.ProcessBinder.Rebind;
    ACCManager.GamesDataManager.Save;
    fUpdateDataManager.CheckUpdate(ACCManager.GamesDataManager);
    FillList;
  end
else
{$IFDEF FPC}
  Application.MessageBox('No change was made.','Adjustable Cruise Control',MB_ICONINFORMATION);
{$ELSE}
  ShowInfoMsg('No change was made.');
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TfUpdateForm.btnAssociateFileClick(Sender: TObject);

  Function FileAssociated: Boolean;
  var
    Reg: TRegistry;
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Result := Reg.KeyExists('Software\Classes\.ugdb');
    finally
      Reg.Free;
    end;
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  procedure AssociateFile;
  var
    Reg: TRegistry;
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.OpenKey('Software\Classes\.ugdb', True);
      Reg.WriteString('','ACCUpdateFile');
      Reg.CloseKey;
      Reg.OpenKey('Software\Classes\ACCUpdateFile', True);
      Reg.WriteString('','Binary update file for Adjustable Cruise Control 2');
      Reg.CloseKey;
      Reg.OpenKey('Software\Classes\ACCUpdateFile\DefaultIcon', True);
      Reg.WriteString('',ParamStr(0) + ',1');
      Reg.CloseKey;
      Reg.OpenKey('Software\Classes\ACCUpdateFile\shell\open\command', True);
      Reg.WriteString('',ParamStr(0) + ' "%1"') ;
      Reg.CloseKey;
    finally
      Reg.Free;
    end;
    SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_IDLIST,nil,nil);
  end;

  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  procedure DeassociateFile;
  var
    Reg: TRegistry;
  begin
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      Reg.DeleteKey('Software\Classes\.ugdb');
      Reg.DeleteKey('Software\Classes\ACCUpdateFile');
    finally
      Reg.Free;
    end;
    SHChangeNotify(SHCNE_ASSOCCHANGED,SHCNF_IDLIST,nil,nil);
  end;

begin
If FileAssociated then
  begin
  {$IFDEF FPC}
    If QuestionDlg('File association',ACCSTR_UI_SUPG_ASSOC_Deassociate,mtConfirmation,[$100,'Remove',$101,'Reassociate'],'') = $100 then
  {$ELSE}
    If ShowQuestionMsg(Self,1,ACCSTR_UI_SUPG_ASSOC_Deassociate,'File association','Remove','Reassociate') then
  {$ENDIF}    
      DeassociateFile
    else
      AssociateFile;
  end
else
  begin
  {$IFDEF FPC}
    If Application.MessageBox(ACCSTR_UI_SUPG_ASSOC_Associate,'File association',MB_ICONQUESTION or MB_YESNO) = IDYES then
  {$ELSE}
    If ShowQuestionMsg(Self,1,ACCSTR_UI_SUPG_ASSOC_Associate,'File association','','') then
  {$ENDIF}
      AssociateFile;
  end;
end;

//------------------------------------------------------------------------------

initialization
  WorkBitmap := TBitmap.Create;

finalization
  WorkBitmap.Free;

end.
