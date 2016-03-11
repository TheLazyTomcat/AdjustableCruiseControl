{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit LibraryForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls,
  ACC_PluginInstaller;

type
  TfLibraryForm = class(TForm)
    lvPluginsList: TListView;
    btnButton_1: TButton;
    btnButton_2: TButton;
    btnButton_3: TButton;
    dlgSelectPlugin: TOpenDialog;
    procedure btnButton_1Click(Sender: TObject);
    procedure btnButton_2Click(Sender: TObject);
    procedure btnButton_3Click(Sender: TObject);
    procedure lvPluginsListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvPluginsListDblClick(Sender: TObject);
  private
    fPluginInstaller: TACCPluginInstaller;
    fAccepted:        Boolean;
  protected
    procedure FillPluginsList;
  public
    procedure ShowNormal(PluginInstaller: TACCPluginInstaller);
    Function ShowPrompt(PluginInstaller: TACCPluginInstaller; out Index: Integer): Boolean;
  end;

var
  fLibraryForm: TfLibraryForm;

implementation

uses DescriptionForm;

{$R *.dfm}

procedure TfLibraryForm.FillPluginsList;
var
  i:  Integer;
begin
lvPluginsList.Items.BeginUpdate;
try
  lvPluginsList.Clear;
  For i := 0 to Pred(fPluginInstaller.PluginsLibraryCount) do
    with lvPluginsList.Items.Add do
      begin
        Caption := fPluginInstaller.PluginsLibrary[i].Description;
        SubItems.Add(fPluginInstaller.PluginsLibrary[i].FilePath);
      end;
finally
  lvPluginsList.Items.EndUpdate;
end;
end;

//------------------------------------------------------------------------------

procedure TfLibraryForm.ShowNormal(PluginInstaller: TACCPluginInstaller);
begin
Tag := 0;
fPluginInstaller := PluginInstaller;
FillPluginsList;
lvPluginsList.MultiSelect := True;
btnButton_1.Visible := True;
btnButton_1.Caption := 'Add plugin to library';
btnButton_2.Caption := 'Remove selected plugins';
btnButton_3.Caption := 'Remove non-existing files';
ShowModal;
end;

//------------------------------------------------------------------------------

Function TfLibraryForm.ShowPrompt(PluginInstaller: TACCPluginInstaller; out Index: Integer): Boolean;
begin
Tag := 1;
fPluginInstaller := PluginInstaller;
fAccepted := False;
FillPluginsList;
lvPluginsList.MultiSelect := False;
btnButton_1.Visible := False;
btnButton_1.Caption := '';
btnButton_2.Caption := 'Accept';
btnButton_3.Caption := 'Cancel';
ShowModal;
Index := lvPluginsList.ItemIndex;
Result := fAccepted;
end;

//==============================================================================

procedure TfLibraryForm.lvPluginsListDblClick(Sender: TObject);
begin
case Tag of
  0:; // no action
  1:  btnButton_2.OnClick(nil);
end;
end;

//------------------------------------------------------------------------------

procedure TfLibraryForm.lvPluginsListKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
case Tag of
  0: If Key = VK_DELETE then btnButton_2.OnClick(nil);
  1:; // no action
end;
end;

//------------------------------------------------------------------------------

procedure TfLibraryForm.btnButton_1Click(Sender: TObject);
var
  Description:  String;
begin
case Tag of
  0:  If dlgSelectPlugin.Execute then
        If fDescriptionForm.ShowPrompt(fPluginInstaller,dlgSelectPlugin.FileName,Description) then
          begin
            fPluginInstaller.PluginsLibraryAdd(Description,dlgSelectPlugin.FileName);
            FillPluginsList;
          end;
  1:; // no action
end;
end;

//------------------------------------------------------------------------------

procedure TfLibraryForm.btnButton_2Click(Sender: TObject);
var
  i:  Integer;
begin
case Tag of
  0:  If lvPluginsList.SelCount > 0 then
        If MessageDlg(Format('Are you sure you want to remove selected plugins (%d)?',[lvPluginsList.SelCount]),mtConfirmation,[mbYes,mbNo],0) = mrYes then
          begin
            For i := Pred(lvPluginsList.Items.Count) downto 0 do
              If lvPluginsList.Items[i].Selected then
                fPluginInstaller.PluginsLibraryRemove(i);
            FillPluginsList;
          end;
  1:  begin
        If lvPluginsList.ItemIndex >= 0 then
          fAccepted := True
        else
          MessageDlg('No plugin selected.',mtError,[mbOK],0);
        If fAccepted then Close;
      end;
end;
end;

//------------------------------------------------------------------------------

procedure TfLibraryForm.btnButton_3Click(Sender: TObject);
begin
case Tag of
  0:  begin
        If lvPluginsList.Items.Count > 0 then
          If MessageDlg('Are you sure you want to remove all non-existent files?',mtConfirmation,[mbYes,mbNo],0) = mrYes then
            begin
              fPluginInstaller.PluginsLibraryValidate;
              FillPluginsList;
            end;
      end;
  1:  Close;
end;
end;

end.
