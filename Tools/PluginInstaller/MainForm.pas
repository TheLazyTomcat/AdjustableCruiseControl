unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, XPMan,
  ACC_PluginInstaller;

type
  TfMainForm = class(TForm)
    lbGame: TLabel;
    cbGame: TComboBox;
    gbPlugins: TGroupBox;
    lbeRegistryKey: TLabeledEdit;
    lvInstalledPlugins: TListView;
    oXPManifest: TXPManifest;
    btnAdd: TButton;
    btnRemove: TButton;
    lbl64bitWarning: TLabel;
    dlgAddPlugin: TOpenDialog;
    btnRefresh: TButton;
    lblInstalledPlugins: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);    
    procedure cbGameChange(Sender: TObject);
    procedure lvInstalledPluginsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);    
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    PluginInstaller: TACCPluginInstaller;
    procedure LoadIntalledPlugins;
  end;

var
  fMainForm: TfMainForm;

implementation

{$R *.dfm}

uses
  DescriptionForm;

procedure TfMainForm.LoadIntalledPlugins;
var
  I:  Integer;
begin
lvInstalledPlugins.Items.BeginUpdate;
try
  lvInstalledPlugins.Clear;
  For i := 0 to Pred(PluginInstaller.InstallegPluginCount) do
    with lvInstalledPlugins.Items.Add do
      begin
        Caption := PluginInstaller.InstalledPlugins[i].Description;
        SubItems.Add(PluginInstaller.InstalledPlugins[i].FilePath);
      end;
finally
  lvInstalledPlugins.Items.EndUpdate;
end;
end;

//==============================================================================

procedure TfMainForm.FormCreate(Sender: TObject);
var
  i:  Integer;
begin
PluginInstaller := TACCPluginInstaller.Create;
dlgAddPlugin.InitialDir := ExtractFileDir(ParamStr(0));
cbGame.Items.BeginUpdate;
try
  For i := 0 to Pred(PluginInstaller.KnownGameCount) do
    cbGame.Items.Add(PluginInstaller.KnownGames[i].Title);
finally
  cbGame.Items.EndUpdate;
end;
If cbGame.Items.Count > 0 then cbGame.ItemIndex := 0
  else cbGame.ItemIndex := -1;
cbGame.OnChange(nil);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormDestroy(Sender: TObject);
begin
PluginInstaller.Free;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.FormResize(Sender: TObject);
begin
lvInstalledPlugins.Columns[0].Width := Trunc(lvInstalledPlugins.Width * 0.25);
lvInstalledPlugins.Columns[1].Width := Trunc(lvInstalledPlugins.Width * 0.75) - 25;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.cbGameChange(Sender: TObject);
begin
PluginInstaller.SelectGame(cbGame.ItemIndex);
with PluginInstaller.SelectedGame do
  begin
    lbeRegistryKey.Text := FullRegistryKey;
    lbl64bitWarning.Visible := not SystemValid;
    btnAdd.Enabled := Valid and SystemValid;
    btnRemove.Enabled := Valid and SystemValid;
    btnRefresh.Enabled := Valid and SystemValid;
  end;
LoadIntalledPlugins;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.lvInstalledPluginsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
If Key = VK_DELETE then btnRemove.OnClick(nil);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnAddClick(Sender: TObject);
begin
If dlgAddPlugin.Execute then
  If ShowDescriptionPrompt(PluginInstaller,dlgAddPlugin.FileName,PluginInstaller.SelectedGame.Is64bit) then
    begin
      PluginInstaller.LoadIntalledPlugins;
      LoadIntalledPlugins;
    end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnRemoveClick(Sender: TObject);
begin
If lvInstalledPlugins.ItemIndex >= 0 then
  If MessageDlg('Are you sure you want to uninstall plugin "' + lvInstalledPlugins.Selected.Caption + '"?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
    begin
      PluginInstaller.RemoveInstalledPlugin(lvInstalledPlugins.ItemIndex);
      PluginInstaller.LoadIntalledPlugins;
      LoadIntalledPlugins;
    end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnRefreshClick(Sender: TObject);
begin
PluginInstaller.LoadIntalledPlugins;
LoadIntalledPlugins;
end;

end.
