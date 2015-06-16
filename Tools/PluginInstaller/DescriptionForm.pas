unit DescriptionForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  ACC_PluginInstaller;

type
  TfDescriptionForm = class(TForm)
    lbeSelectedFile: TLabeledEdit;
    lbeDescription: TLabeledEdit;
    cbPerformChecks: TCheckBox;    
    btnAccept: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnAcceptClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Installed:        Boolean;
    FilePath:         String;
    Is64bit:          Boolean;
    PluginInstaller:  TACCPluginInstaller;
  end;

var
  fDescriptionForm: TfDescriptionForm;

Function ShowDescriptionPrompt(PluginInstaller: TACCPluginInstaller; const FilePath: String; Is64bit: Boolean): Boolean;

implementation

{$R *.dfm}

uses
  WinFileInfo, ACC_PluginCheck;

Function ShowDescriptionPrompt(PluginInstaller: TACCPluginInstaller; const FilePath: String; Is64bit: Boolean): Boolean;
var
  Index:  Integer;
begin
fDescriptionForm.Installed := False;
fDescriptionForm.FilePath := FilePath;
fDescriptionForm.Is64bit := Is64bit;
fDescriptionForm.PluginInstaller := PluginInstaller;
fDescriptionForm.lbeSelectedFile.Text := FilePath;
fDescriptionForm.lbeDescription.Text := '';
with TWinFileInfo.Create(FilePath,WFI_LS_LoadVersionInfo or WFI_LS_ParseVersionInfo) do
  begin
    If VersionInfoPresent then
      If VersionInfoStringTableCount > 0 then
        begin
          Index := IndexOfStringInVersionInfoStringTable(0,'FileDescription');
          If Index >= 0 then
            fDescriptionForm.lbeDescription.Text := VersionInfoStrings[0,Index].Value;
        end;
    Free;
  end;
fDescriptionForm.cbPerformChecks.Checked := True;
fDescriptionForm.ShowModal;
Result := fDescriptionForm.Installed;
end;

//==============================================================================

procedure TfDescriptionForm.FormShow(Sender: TObject);
begin
lbeDescription.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TfDescriptionForm.btnAcceptClick(Sender: TObject);
var
  Install:    Boolean;
  CanClose:   Boolean;
  ErrorCode:  LongWord;
begin
If lbeDescription.Text <> '' then
  begin
    If PluginInstaller.IndexOfInstalledPlugin(FilePath,True) < 0 then
      begin
        Install := True;
        CanClose := True;
        If PluginInstaller.IndexOfInstalledPlugin(lbeDescription.Text) >= 0 then
          begin
            Install := MessageDlg('Plugin with this description is already installed.' + sLineBreak +
                                  'Replace installed plugin with selected file?',mtWarning,[mbYes,mbNo],0) = mrYes;
            CanClose := Install;                      
          end;
        If Install and cbPerformChecks.Checked then
          begin
            ErrorCode := PluginCheck(FilePath,Is64bit);
            case ErrorCode of
              PCR_Ok:               Install := True;
              PCR_NotLibrary:       Install := MessageDlg(Format('Selected file does not seem to be a plugin.' + sLineBreak +
                                                          'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
              PCR_InitNotExported:  Install := MessageDlg(Format('Selected plugin is not exporting function "scs_telemetry_init".' + sLineBreak +
                                                          'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
              PCR_FinalNotExported: Install := MessageDlg(Format('Selected plugin is not exporting function "scs_telemetry_shutdown".' + sLineBreak +
                                                          'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
            else
              Install := MessageDlg(Format('An error (%.8x) occured while checking the file.' + sLineBreak +
                                    'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
            end;
          end;
        If Install then
          Installed := PluginInstaller.InstallPlugin(lbeDescription.Text,FilePath);
        If CanClose then Close;
      end
    else
      begin
        MessageDlg('Selected file is already installed.',mtError,[mbOK],0);
        Close;
      end;
  end
else
  begin
    MessageDlg('Plugin description cannot be empty.',mtError,[mbOK],0);
    lbeDescription.SetFocus;
  end;
end;
 
//------------------------------------------------------------------------------

procedure TfDescriptionForm.btnCancelClick(Sender: TObject);
begin
Close;
end;

end.
