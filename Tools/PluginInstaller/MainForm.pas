unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, ExtCtrls, XPMan,
  ACC_PluginInstaller;

type
  TfMainForm = class(TForm)
    lblGame: TLabel;
    cmbGame: TComboBox;
    gbPlugins: TGroupBox;
    lbeRegistryKey: TLabeledEdit;
    lvInstalledPlugins: TListView;
    oXPManifest: TXPManifest;
    btnInstall: TButton;
    btnUninstall: TButton;
    lbl64bitWarning: TLabel;
    dlgSelectPlugin: TOpenDialog;
    btnRefresh: TButton;
    lblInstalledPlugins: TLabel;
    btnInstallFromLibrary: TButton;
    btnPluginsLibrary: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);    
    procedure cmbGameChange(Sender: TObject);
    procedure lvInstalledPluginsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);    
    procedure btnInstallClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnInstallFromLibraryClick(Sender: TObject);
    procedure btnPluginsLibraryClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    PluginInstaller: TACCPluginInstaller;
    procedure FillInstalledPluginsList;
  end;

var
  fMainForm: TfMainForm;

implementation

{$R *.dfm}

uses
  DescriptionForm, LibraryForm;

procedure TfMainForm.FillInstalledPluginsList;
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
dlgSelectPlugin.InitialDir := ExtractFileDir(ParamStr(0));
cmbGame.Items.BeginUpdate;
try
  For i := 0 to Pred(PluginInstaller.KnownGameCount) do
    cmbGame.Items.Add(PluginInstaller.KnownGames[i].Title);
finally
  cmbGame.Items.EndUpdate;
end;
If cmbGame.Items.Count > 0 then cmbGame.ItemIndex := 0
  else cmbGame.ItemIndex := -1;
cmbGame.OnChange(nil);
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

procedure TfMainForm.cmbGameChange(Sender: TObject);
begin
PluginInstaller.SelectGame(cmbGame.ItemIndex);
with PluginInstaller.SelectedGame do
  begin
    lbeRegistryKey.Text := FullRegistryKey;
    lbl64bitWarning.Visible := not SystemValid;
    btnInstall.Enabled := Valid and SystemValid;
    btnInstallFromLibrary.Enabled := Valid and SystemValid;
    btnUninstall.Enabled := Valid and SystemValid;
    btnRefresh.Enabled := Valid and SystemValid;
  end;
FillInstalledPluginsList;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.lvInstalledPluginsKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
If Key = VK_DELETE then btnUninstall.OnClick(nil);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnInstallClick(Sender: TObject);
var
  Description:  String;
begin
Description := '';
If dlgSelectPlugin.Execute then
  If fDescriptionForm.ShowPrompt(PluginInstaller,dlgSelectPlugin.FileName,PluginInstaller.SelectedGame.Is64bit,Description) then
    begin
      PluginInstaller.InstallPlugin(Description,dlgSelectPlugin.FileName);
      PluginInstaller.SelectGame(PluginInstaller.SelectedGameIdx);
      FillInstalledPluginsList;
    end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnInstallFromLibraryClick(Sender: TObject);
var
  Index:        Integer;
  Description:  String;
begin
If PluginInstaller.PluginsLibraryCount > 0 then
  begin
    If fLibraryForm.ShowPrompt(PluginInstaller,Index) then
      begin
        Description := PluginInstaller.PluginsLibrary[Index].Description;
        If fDescriptionForm.ShowPrompt(PluginInstaller,PluginInstaller.PluginsLibrary[Index].FilePath,PluginInstaller.SelectedGame.Is64bit,Description) then
          begin
            PluginInstaller.InstallPlugin(Description,PluginInstaller.PluginsLibrary[Index].FilePath);
            PluginInstaller.SelectGame(PluginInstaller.SelectedGameIdx);
            FillInstalledPluginsList;
          end;
      end;
  end
else MessageDlg('The plugins library is empty, you cannot install anything from there.',mtInformation,[mbOK],0);
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnUninstallClick(Sender: TObject);
begin
If lvInstalledPlugins.ItemIndex >= 0 then
  If MessageDlg('Are you sure you want to uninstall plugin "' + lvInstalledPlugins.Selected.Caption + '"?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
    begin
      PluginInstaller.UninstallPlugin(lvInstalledPlugins.ItemIndex);
      PluginInstaller.SelectGame(PluginInstaller.SelectedGameIdx);
      FillInstalledPluginsList;
    end;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnRefreshClick(Sender: TObject);
begin
PluginInstaller.SelectGame(PluginInstaller.SelectedGameIdx);
FillInstalledPluginsList;
end;

//------------------------------------------------------------------------------

procedure TfMainForm.btnPluginsLibraryClick(Sender: TObject);
begin
fLibraryForm.ShowNormal(PluginInstaller);
end;

end.
