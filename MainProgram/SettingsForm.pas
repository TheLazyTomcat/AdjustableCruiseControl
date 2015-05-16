unit SettingsForm;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Spin, Grids,{$IFNDEF FPC}PNGImage,{$ENDIF}
  ACC_Settings;

type

  { TfSettingsForm }

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
    diaImportSettings: TOpenDialog;
    diaExportSettings: TSaveDialog;    
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
    fLocalSettings: TSettings;
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

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

uses
  MainForm, KeyBindForm, SupportedGamesForm, UpdateForm,{$IFNDEF FPC}MsgForm,{$ENDIF}
  ACC_Common, ACC_Strings, ACC_Input, ACC_Manager;


procedure TfSettingsForm.PrepareBindTable;
var
  i:  Integer;
begin
sgBindings.RowCount := InputCount + 1;
sgBindings.ColWidths[0] := 135;
sgBindings.ColWidths[1] := 115;
sgBindings.ColWidths[2] := 80;
sgBindings.Cells[0,0] := ACCSTR_UI_SET_BIND_HEAD_Action;
sgBindings.Cells[1,0] := ACCSTR_UI_SET_BIND_HEAD_Keys;
sgBindings.Cells[2,0] := ACCSTR_UI_SET_BIND_HEAD_VKCodes;
For i := 0 to Pred(InputCount) do
  sgBindings.Cells[0,i + 1] := ACCSTR_UI_SET_BIND_InputText(i);
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.KeysToForm;
var
  i:  Integer;
begin
For i := 0 to Pred(InputCount) do
  begin
    sgBindings.Cells[1,i + 1] := TInputManager.GetInputKeyNames(LocalSettingsManager.Inputs[i]);
    sgBindings.Cells[2,i + 1] := TInputManager.GetInputKeyNames(LocalSettingsManager.Inputs[i],True);
  end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.SettingsToForm;
begin
cbShowSplash.Checked := fLocalSettings.ShowSplashScreen;
cbCloseOnGameEnd.Checked := fLocalSettings.CloseOnGameEnd;
cbMinimizeToTray.Checked := fLocalSettings.MinimizeToTray;
cbMinimizeToTray.OnClick(nil);
cbStartMinimized.Checked := fLocalSettings.StartMinimized;
seProcessScanTImer.Value := fLocalSettings.ProcessBinderScanInterval;
seModuleLoadTimer.Value := fLocalSettings.ModulesLoadTimeout;
KeysToForm;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.FormToSettings;
begin
fLocalSettings.ShowSplashScreen := cbShowSplash.Checked;
fLocalSettings.CloseOnGameEnd := cbCloseOnGameEnd.Checked;
fLocalSettings.MinimizeToTray := cbMinimizeToTray.Checked;
fLocalSettings.StartMinimized := cbStartMinimized.Checked and cbStartMinimized.Enabled;
fLocalSettings.ProcessBinderScanInterval := seProcessScanTImer.Value;
fLocalSettings.ModulesLoadTimeout := seModuleLoadTimer.Value;
end;

//==============================================================================

procedure TfSettingsForm.FormCreate(Sender: TObject);
begin
sgBindings.DoubleBuffered := True;
diaExportSettings.InitialDir := ExtractFileDir(ParamStr(0));
diaImportSettings.InitialDir := ExtractFileDir(ParamStr(0));
PrepareBindTable;
LocalSettingsManager := TSettingsManager.Create(Addr(fLocalSettings));
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.FormDestroy(Sender: TObject);
begin
LocalSettingsManager.Free;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.FormShow(Sender: TObject);
begin
fLocalSettings := ACC_Settings.Settings;
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
{$IFDEF FPC}
Application.MessageBox(ACCSTR_UI_SET_TIH_ProcessScanTimer,'Processes scan interval',MB_ICONINFORMATION);
{$ELSE}
ShowInfoMsg(Self,0,ACCSTR_UI_SET_TIH_ProcessScanTimer,'Processes scan interval','','');
{$ENDIF}
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.imgHint_MLTClick(Sender: TObject);
begin
{$IFDEF FPC}
Application.MessageBox(ACCSTR_UI_SET_TIH_ModuleLoadTimer,'Modules load timeout',MB_ICONINFORMATION);
{$ELSE}
ShowInfoMsg(Self,0,ACCSTR_UI_SET_TIH_ModuleLoadTimer,'Modules load timeout','','');
{$ENDIF}
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
        {$IFDEF FPC}
          Pen.Style := psSolid;
          Pen.Color := sgBindings.FixedColor;
        {$ELSE}
          Pen.Color := BindTable_FixedColorBgr;
        {$ENDIF}
          Brush.Color := BindTable_FixedColorBgr;
          Rectangle(Rect);
          Pen.Color := BindTable_FixedColor;
          Brush.Color := BindTable_FixedColor;
          Rectangle(Rect.Left,Rect.Top,Rect.Right - 1,Rect.Top + ((Rect.Bottom - Rect.Top) div 2));
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
GetCursorPos({%H-}CursorPos);
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
ACC_Settings.Settings := fLocalSettings;
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
{$IFDEF FPC}
If Application.MessageBox(ACCSTR_UI_SET_DEF_LoadDefaultSettings,'Load default settings',MB_ICONWARNING or MB_YESNO) = IDYES then
{$ELSE}
If ShowWarningMsg(Self,1,ACCSTR_UI_SET_DEF_LoadDefaultSettings,'Load default settings','','') then
{$ENDIF}
  begin
    LocalSettingsManager.InitSettings;
    SettingsToForm;
  end;
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnExportSettingsClick(Sender: TObject);
begin
If diaExportSettings.Execute then
  LocalSettingsManager.SaveToIni(diaExportSettings.FileName);
end;

//------------------------------------------------------------------------------

procedure TfSettingsForm.btnImportSettingsClick(Sender: TObject);
begin
If diaImportSettings.Execute then
  begin
    If LocalSettingsManager.LoadFromIni(diaImportSettings.FileName) then
      SettingsToForm
    else
    {$IFDEF FPC}
      Application.MessageBox('Settings import has failed.','Adjustable Cruise Control',MB_ICONERROR);
    {$ELSE}
      ShowErrorMsg('Settings import has failed.');
    {$ENDIF}
  end;
end;

end.
