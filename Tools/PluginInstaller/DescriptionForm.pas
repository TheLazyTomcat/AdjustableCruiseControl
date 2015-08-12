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
    procedure lbeDescriptionKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  protected
    fPluginInstaller: TACCPluginInstaller;
    fFilePath:        String;
    fIs64bit:         Boolean;
    fAccepted:        Boolean;
  public
    { Public declarations }
    Function ShowPrompt(PluginInstaller: TACCPluginInstaller; const FilePath: String; Is64bit: Boolean; var Description: String): Boolean; overload;
    Function ShowPrompt(PluginInstaller: TACCPluginInstaller; const FilePath: String; out Description: String): Boolean; overload;
  end;

var
  fDescriptionForm: TfDescriptionForm;

implementation

{$R *.dfm}

uses
  WinFileInfo, ACC_PluginCheck;

Function TfDescriptionForm.ShowPrompt(PluginInstaller: TACCPluginInstaller; const FilePath: String; Is64bit: Boolean; var Description: String): Boolean;
var
  Index:  Integer;
begin
Tag := 0;
fAccepted:= False;
fPluginInstaller := PluginInstaller;
fFilePath := FilePath;
fIs64bit := Is64bit;
fAccepted:= False;
lbeSelectedFile.Text := FilePath;
lbeDescription.Text := '';
If Description <> '' then
  lbeDescription.Text := Description
else
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
cbPerformChecks.Visible := True;  
cbPerformChecks.Checked := True;
ShowModal;
Result := fAccepted;
Description := lbeDescription.Text;
end;

//------------------------------------------------------------------------------

Function TfDescriptionForm.ShowPrompt(PluginInstaller: TACCPluginInstaller; const FilePath: String; out Description: String): Boolean;
var
  Index:  Integer;
begin
Tag := 1;
fPluginInstaller := PluginInstaller;
fFilePath := FilePath;
fAccepted := False;
lbeSelectedFile.Text := FilePath;
lbeDescription.Text := '';
with TWinFileInfo.Create(FilePath,WFI_LS_LoadVersionInfo or WFI_LS_ParseVersionInfo) do
  begin
    If VersionInfoPresent then
      If VersionInfoStringTableCount > 0 then
        begin
          Index := IndexOfStringInVersionInfoStringTable(0,'FileDescription');
          If Index >= 0 then
            lbeDescription.Text := VersionInfoStrings[0,Index].Value;
        end;
    Free;
  end;
cbPerformChecks.Visible := False;
ShowModal;
Result := fAccepted;
Description := lbeDescription.Text;
end;

//==============================================================================

procedure TfDescriptionForm.FormShow(Sender: TObject);
begin
lbeDescription.SetFocus;
end;

//------------------------------------------------------------------------------

procedure TfDescriptionForm.lbeDescriptionKeyPress(Sender: TObject;
  var Key: Char);
begin
If Key = #13 then
  begin
    btnAccept.OnClick(nil);
    Key := #0;
  end;
end;

//------------------------------------------------------------------------------

procedure TfDescriptionForm.btnAcceptClick(Sender: TObject);
var
  ErrorCode:  LongWord;
begin
If lbeDescription.Text <> '' then
  case Tag of
    0:  begin
          If fPluginInstaller.InstalledPluginsIndexOfFilePath(fFilePath) < 0 then
            begin
              If fPluginInstaller.InstalledPluginsIndexOfDescription(lbeDescription.Text) >= 0 then
                begin
                  fAccepted := MessageDlg('Plugin with this description is already installed.' + sLineBreak +
                                          'Replace installed plugin with selected file?',mtWarning,[mbYes,mbNo],0) = mrYes;
                  If not fAccepted then lbeDescription.SetFocus;
                end
              else fAccepted := True;
              If fAccepted and cbPerformChecks.Checked then
                begin
                  ErrorCode := PluginCheck(fFilePath,fIs64bit);
                  case ErrorCode of
                    PCR_Ok:               fAccepted := True;
                    PCR_NotLibrary:       fAccepted := MessageDlg(Format('Selected file does not seem to be a plugin.' + sLineBreak +
                                                                  'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
                    PCR_InitNotExported:  fAccepted := MessageDlg(Format('Selected plugin is not exporting function "scs_telemetry_init".' + sLineBreak +
                                                                  'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
                    PCR_FinalNotExported: fAccepted := MessageDlg(Format('Selected plugin is not exporting function "scs_telemetry_shutdown".' + sLineBreak +
                                                                  'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
                  else
                    fAccepted := MessageDlg(Format('An error (%.8x) occured while checking the file.' + sLineBreak +
                                            'Do you want to install it anyway?',[ErrorCode]),mtError,[mbYes,mbNo],0) = mrYes;
                  end;
                end;
            end
          else MessageDlg('Selected file is already installed.',mtError,[mbOK],0);
          If fAccepted then Close;
        end;
//   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---   ---
    1:  begin
          If fPluginInstaller.PluginsLibraryIndexOfFilePath(fFilePath) < 0 then
            begin
              If fPluginInstaller.PluginsLibraryIndexOfDescription(lbeDescription.Text) >= 0 then
                begin
                  fAccepted := MessageDlg('Plugin with this description is already in the library.' + sLineBreak +
                                          'Do you want to replace it?',mtWarning,[mbYes,mbNo],0) = mrYes;
                  If not fAccepted then lbeDescription.SetFocus;                        
                end
              else fAccepted := True;
            end
          else MessageDlg('Selected file is already in the library',mtError,[mbOK],0);
          If fAccepted then Close;
        end
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
