{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit AboutForm;

interface

{$INCLUDE '..\Source\ACC_Defs.inc'}

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls,
  ExtCtrls {$IFNDEF FPC}, PNGImage{$ENDIF};

type
  TfAboutForm = class(TForm)
    shpBackground: TShape;
    imgLogo: TImage;
    lblTitle: TLabel;
    lblTitleShadow: TLabel;
    lblProgramVersion: TLabel;
    lblAuthor: TLabel;
    lblCopyright: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fAboutForm: TfAboutForm;

implementation

{$IFDEF FPC}
  {$R *.lfm}
{$ELSE}
  {$R *.dfm}
{$ENDIF}

uses
  ACC_Common, ACC_Strings;

procedure TfAboutForm.FormCreate(Sender: TObject);
begin
lblTitle.Caption := ACCSTR_ApplicationName;
lblTitleShadow.Caption := ACCSTR_ApplicationName;
lblProgramVersion.Caption := ACCSTR_UI_CPY_ProgramVersion + ACC_VersionLongStr + '  ' + ACC_BuildStr;
lblAuthor.Caption := ACCSTR_UI_CPY_Author;
lblCopyright.Caption := ACCSTR_UI_CPY_Copyright;
end;

end.
