unit SettingsForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, pngimage, ExtCtrls, Spin, Grids,
  ACC_Settings;

type
  TfSettingsForm = class(TForm)
    gbGeneral: TGroupBox;
    cbShowSplash: TCheckBox;
    cbCloseOnGameEnd: TCheckBox;
    cbMinimizeToTray: TCheckBox;
    cbStartMinimized: TCheckBox;
    gbTimers: TGroupBox;
    lblProcessScanTimer: TLabel;
    seProcessScanTimer: TSpinEdit;
    imgHint_PSI: TImage;
    lblModuleLoadTimer: TLabel;
    seModuleLoadTimer: TSpinEdit;
    imgHint_MLT: TImage;
    gbGamesData: TGroupBox;
    btnSupportedGames: TButton;
    btnUpdateGamesData: TButton;
    gbBindings: TGroupBox;
    sgBindings: TStringGrid;
    lblBindingHint: TLabel;
    bvlVertSplit: TBevel;
    btnAccept: TButton;
    btnApply: TButton;
    btnCancel: TButton;
    btnDefault: TButton;    
    btnExportSettings: TButton;
    btnImportSettings: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbMinimizeToTrayClick(Sender: TObject);
    procedure imgHint_PSIClick(Sender: TObject);
    procedure imgHint_MLTClick(Sender: TObject);
    procedure btnSupportedGamesClick(Sender: TObject);    
    procedure sgBindingsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgBindingsDblClick(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);    
    procedure btnExportSettingsClick(Sender: TObject);
    procedure btnImportSettingsClick(Sender: TObject);
    procedure btnUpdateGamesDataClick(Sender: TObject);
  private
    { Private declarations }
  protected
    LocalSettings:  TSettings;
    procedure PrepareBindTable;
    procedure KeysToForm;
  public
    LocalSettingsManager: TSettingsManager;   
    procedure SettingsToForm;
    procedure FormToSettings;
  end;

var
  fSettingsForm: TfSettingsForm;

implementation

{$R *.dfm}

uses
  MainForm, KeyBindForm, SupportedGamesForm, MsgForm,
  ACC_Common, ACC_Strings, ACC_Input, ACC_Manager, UpdateForm;


procedure TfSettingsForm.PrepareBindTable;
var
  i:  Integer;
begin
sgBindings.ColWidths[0] := 135;
sgBindings.ColWidths[1] := 115;
sgBindings.ColWidths[2] := 80;
sgBindings.Cells[0,0] := ACCSTR_UI_SET_BIND_HEAD_Action;
sgBindings.Cells[1,0] := ACCSTR_UI_SET_BIND_HEAD_Keys;
sgBindings.Cells[2,0] := ACCSTR_UI_SET_BIND_HEAD_VKCodes;
For i := 0 to 12 do
  sgBindings.Cells[0,i + 1] := ACCSTR_UI_SET_BIND_InputText(i);
For i := 0 to 9 do
  begin
    sgBindings.Cells[0,13 + i] := Format(ACCSTR_UI_SET_BIND_UserEngage,[i]);
    sgBindings.Cells[0,23 + i] := Format(ACCSTR_UI_SET_BIND_UserVehicle,[i]);
    sgBindings.Cells[0,33 + i] := Format(ACCSTR_UI_SET_BIND_UserCruise,[i]);
  end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.KeysToForm;
var
  i:  Integer;
begin
For i := 0 to 41 do
  begin
    sgBindings.Cells[1,i + 1] := TInputManager.GetInputKeyNames(LocalSettingsManager.Inputs[i]);
    sgBindings.Cells[2,i + 1] := TInputManager.GetInputKeyNames(LocalSettingsManager.Inputs[i],True);
  end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.SettingsToForm;
begin
cbShowSplash.Checked := LocalSettings.ShowSplashScreen;
cbCloseOnGameEnd.Checked := LocalSettings.CloseOnGameEnd;
cbMinimizeToTray.Checked := LocalSettings.MinimizeToTray;
cbMinimizeToTray.OnClick(nil);
cbStartMinimized.Checked := LocalSettings.StartMinimized;
seProcessScanTImer.Value := LocalSettings.ProcessBinderScanInterval;
seModuleLoadTimer.Value := LocalSettings.ModulesLoadTimeout;
KeysToForm;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.FormToSettings;
begin
LocalSettings.ShowSplashScreen := cbShowSplash.Checked;
LocalSettings.CloseOnGameEnd := cbCloseOnGameEnd.Checked;
LocalSettings.MinimizeToTray := cbMinimizeToTray.Checked;
LocalSettings.StartMinimized := cbStartMinimized.Checked and cbStartMinimized.Enabled;
LocalSettings.ProcessBinderScanInterval := seProcessScanTImer.Value;
LocalSettings.ModulesLoadTimeout := seModuleLoadTimer.Value;
end;

//==============================================================================

procedure TfSettingsForm.FormCreate(Sender: TObject);
begin
sgBindings.DoubleBuffered := True;
PrepareBindTable;
LocalSettingsManager := TSettingsManager.Create(Addr(LocalSettings));
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.FormDestroy(Sender: TObject);
begin
LocalSettingsManager.Free;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.FormShow(Sender: TObject);
begin
LocalSettings := ACC_Settings.Settings;
SettingsToForm;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.cbMinimizeToTrayClick(Sender: TObject);
begin
cbStartMinimized.Enabled := cbMinimizeToTray.Checked;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.imgHint_PSIClick(Sender: TObject);
begin
ShowInfoMsg(Self,0,ACCSTR_UI_SET_TIH_ProcessScanTimer,'Processes scan interval','','');
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.imgHint_MLTClick(Sender: TObject);
begin
ShowInfoMsg(Self,0,ACCSTR_UI_SET_TIH_ModuleLoadTimer,'Modules load timeout','','');
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnSupportedGamesClick(Sender: TObject);
begin
fSupportedGamesForm.ShowModal;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnUpdateGamesDataClick(Sender: TObject);
begin
fUpdateForm.ShowModal;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.sgBindingsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
const
  BindTable_FixedColorBgr    = $00EEEEEE;
  BindTable_FixedColor       = $00FEFEFE;
  BindTable_SelectedColorBgr = $00FFD0D0;
  BindTable_SelectedColor    = $00FFE5E5;
begin
If Sender is TStringGrid then
  with (Sender as TStringGrid).Canvas do
    begin
      If gdFixed in State then
        begin
          Pen.Color := BindTable_FixedColorBgr;
          Brush.Color := BindTable_FixedColorBgr;
          Rectangle(Rect);
          Pen.Color := BindTable_FixedColor;
          Brush.Color := BindTable_FixedColor;
          Rectangle(Rect.Left,Rect.Top,Rect.Right,Rect.Top + ((Rect.Bottom - Rect.Top) div 2));
        end
      else
        begin
          If gdSelected in State then
            begin
              Pen.Color := BindTable_SelectedColorBgr;
              Brush.Color := BindTable_SelectedColorBgr;
              Rectangle(Rect);
              Pen.Color := BindTable_SelectedColor;
              Brush.Color := BindTable_SelectedColor;
              Rectangle(Rect.Left,Rect.Top,Rect.Right,Rect.Top + ((Rect.Bottom - Rect.Top) div 2));
            end
          else
            begin
              Pen.Color := (Sender as TStringGrid).Color;
              Brush.Color := (Sender as TStringGrid).Color;
              Rectangle(Rect);
            end;
        end;
      Font.Color := (Sender as TStringGrid).Font.Color;
      Brush.Style := bsClear;
      TextOut(Rect.Left + ((Rect.Right - Rect.Left) - TextWidth((Sender as TStringGrid).Cells[ACol,ARow])) div 2,
              Rect.Top + ((Rect.Bottom - Rect.Top) - TextHeight((Sender as TStringGrid).Cells[ACol,ARow])) div 2,
              (Sender as TStringGrid).Cells[ACol,ARow]);
    end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.sgBindingsDblClick(Sender: TObject);
var
  CursorPos:  TPoint;
  Input:      TInput;
begin
GetCursorPos(CursorPos);
If sgBindings.ScreenToClient(CursorPos).Y > sgBindings.RowHeights[0] then
  begin
    CenterFormToForm(fKeyBindForm,Self);
    If fKeyBindForm.StartBinding(sgBindings.Row - 1,Input) then
      begin
        LocalSettingsManager.Inputs[sgBindings.Row - 1] := Input;
        KeysToForm;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnAcceptClick(Sender: TObject);
begin
btnApply.OnClick(nil);
Close;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnApplyClick(Sender: TObject);
begin
FormToSettings;
LocalSettingsManager.ValidateSettings;
ACC_Settings.Settings := LocalSettings;
fMainForm.SettingsToForm;
ACCManager.ProcessBinder.UpdateTimerInterval;
ACCManager.BuildInputTriggers;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnCancelClick(Sender: TObject);
begin
Close;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnDefaultClick(Sender: TObject);
begin
If ShowWarningMsg(Self,1, ACCSTR_UI_SET_DEF_LoadDefaultSettings,'Load default settings','','') then
  begin
    LocalSettingsManager.InitSettings;
    SettingsToForm;
  end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnExportSettingsClick(Sender: TObject);
var
  FileName: String;
begin
If PromptForFileName(FileName,'INI files (*.ini)|*.ini','.ini','Exporting program settings',ExtractFileDir(ParamStr(0)),True) then
  begin
    LocalSettingsManager.SaveToIni(FileName);
  end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnImportSettingsClick(Sender: TObject);
var
  FileName: String;
begin
If PromptForFileName(FileName,'INI files (*.ini)|*.ini','.ini','Importing program settings',ExtractFileDir(ParamStr(0)),False) then
  begin
    If LocalSettingsManager.LoadFromIni(FileName) then
      SettingsToForm
    else
      ShowErrorMsg('Settings import has failed.');
  end;
end;

end.
