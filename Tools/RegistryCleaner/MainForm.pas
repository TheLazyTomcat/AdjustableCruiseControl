unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, Registry, Menus, XPMan;

type
  TfMainForm = class(TForm)
    leBaseKey: TLabeledEdit;
    btnBackupBaseKey: TButton;
    btnDeleteBaseKey: TButton;
    lvKeys: TListView;
    mListViewMenu: TPopupMenu;
    lvmDeleteSelected: TMenuItem;
    lvmBackupSelected: TMenuItem;
    N1: TMenuItem;
    lvmRefresh: TMenuItem;
    XPManifest1: TXPManifest;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnBackupBaseKeyClick(Sender: TObject);
    procedure btnDeleteBaseKeyClick(Sender: TObject);
    procedure mListViewMenuPopup(Sender: TObject);
    procedure lvmDeleteSelectedClick(Sender: TObject);
    procedure lvmBackupSelectedClick(Sender: TObject);
    procedure lvmRefreshClick(Sender: TObject);    
  private
    { Private declarations }
  protected
    fRegistry: TRegistry;
    procedure ListSubkeys;
  public
    { Public declarations }
  end;

var
  fMainForm: TfMainForm;

implementation

{$R *.dfm}

uses
  ShellAPI;

type
  TKnowProgram = record
    ProgramName:  String;
    Subkey:       String;
  end;

const
  KnownPrograms: Array[0..10] of TKnowProgram = (
    (ProgramName: '18WoS ALH Mouse Steering';               Subkey: '18WoS ALH Mouse Steering'),
    (ProgramName: 'Adjustable Cruise Control up to 2.1.3';  Subkey: 'Adjustable Cruise Control'),
    (ProgramName: 'Adjustable Cruise Control from 2.2.0';   Subkey: 'Adjustable Cruise Control 2'),
    (ProgramName: 'Adjustable Cruise Control 3 (dev)';      Subkey: 'Adjustable Cruise Control 3'),
    (ProgramName: 'Agenda ETS';                             Subkey: 'Agenda ETS'),
    (ProgramName: 'ETS AutoCargo';                          Subkey: 'ETS AutoCargo'),
    (ProgramName: 'ETS Main Menu Background Changer';       Subkey: 'ETS MMBC'),
    (ProgramName: 'Minecraft Server Restarter';             Subkey: 'MCSR'),
    (ProgramName: 'SCS Extractor GUI';                      Subkey: 'SCS Extractor GUI'),
    (ProgramName: 'SvìtSim Background Creator';             Subkey: 'SSBC'),
    (ProgramName: 'Minecraft Slime Spawn Chunk Test (dev)'; Subkey: 'SSCT'));

  REG_Root      = HKEY_CURRENT_USER;
  REG_RootName  = 'HKEY_CURRENT_USER';
  REG_BaseKey   = '\Software\NcS Soft';
  REG_Delimiter = '\';    

//==============================================================================

Function GetProgramName(const SubKey: String): String;
var
  i:  Integer;
begin
For i := Low(KnownPrograms) to High(KnownPrograms) do
  If AnsiSameText(SubKey,KnownPrograms[i].Subkey) then
    begin
      Result := KnownPrograms[i].ProgramName;
      Exit;
    end;
Result := '*Unknown';
end;

//------------------------------------------------------------------------------

procedure ExportRegistryKey(const FileName,KeyName: String);
begin
ShellExecute(0,'open','regedit.exe',PChar('/e "' + FileName + '" "' + KeyName + '"'),nil,SW_SHOWNORMAL);
end;

//==============================================================================

procedure TfMainForm.ListSubkeys;
var
  Subkeys:  TStringList;
  i:        Integer;
begin
fRegistry.OpenKey(REG_BaseKey,False);
leBaseKey.Text := REG_RootName + REG_BaseKey;
lvKeys.Items.BeginUpdate;
try
  lvKeys.Clear;
  Subkeys := TStringList.Create;
  try
    fRegistry.GetKeyNames(SubKeys);
    For i := 0 to Pred(Subkeys.Count) do
      begin
        with lvKeys.Items.Add do
          begin
            Caption := GetProgramName(SubKeys[i]);
            SubItems.Add(SubKeys[i]);
          end;
      end;
  finally
    Subkeys.Free;
  end;
finally
  lvKeys.Items.EndUpdate;
end;
end;

//==============================================================================

procedure TfMainForm.FormCreate(Sender: TObject);
begin
fRegistry := TRegistry.Create;
ListSubkeys;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
fRegistry.Free;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormResize(Sender: TObject);
begin
lvKeys.Columns[0].Width := Trunc(lvKeys.Width * 0.5);
lvKeys.Columns[1].Width := lvKeys.Width - lvKeys.Columns[0].Width - 25;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnBackupBaseKeyClick(Sender: TObject);
var
  FileName: String;
begin
If PromptForFileName(FileName,'REG files (*.reg)|*.reg','.reg','Save registry key',ParamStr(0),True) then
  ExportRegistryKey(FileName,REG_RootName + REG_BaseKey);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnDeleteBaseKeyClick(Sender: TObject);
begin
fRegistry.DeleteKey(REG_BaseKey);
ListSubkeys;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.mListViewMenuPopup(Sender: TObject);
begin
lvmDeleteSelected.Enabled := lvKeys.ItemIndex >= 0;
lvmBackupSelected.Enabled := lvmDeleteSelected.Enabled;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.lvmDeleteSelectedClick(Sender: TObject);
begin
fRegistry.DeleteKey(lvKeys.Items[lvKeys.ItemIndex].SubItems[0]);
ListSubkeys;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.lvmBackupSelectedClick(Sender: TObject);
var
  FileName: String;
begin
If PromptForFileName(FileName,'REG files (*.reg)|*.reg','.reg','Save registry key',ParamStr(0),True) then
  ExportRegistryKey(FileName,REG_RootName + REG_BaseKey + REG_Delimiter + lvKeys.Items[lvKeys.ItemIndex].SubItems[0]);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.lvmRefreshClick(Sender: TObject);
begin
ListSubkeys;
end;

end.
