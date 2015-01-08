{*******************************************************************************

Jednoduch� wrapper pro zpr�vy a dotazy.

� Franti�ek Milt

Naposledy upraveno: 10.11.2010

*******************************************************************************}
unit MsgForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, PngImage;

type                
  TfMsgForm = class(TForm)
    btnYesButton: TBitBtn;
    btnNoButton: TBitBtn;
    imMsgIcon: TImage;
    lblMainText: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnYesButtonClick(Sender: TObject);
    procedure btnNoButtonClick(Sender: TObject);
  private
    { Private declarations }
  protected
    Procedure LoadResIcon(const ResIconName: String);
    Function MsgFormSort(IconName: String; Sender: TForm; BtnsCount: Byte; MsgText, MsgTitle, BtnYesCaption, BtnNoCaption: String; YesSelected: Boolean): Boolean;
  public
    { Public declarations }
  end;

Function ShowMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean; Overload;
Function ShowMsg(MsgText: String): Boolean; Overload;
Function ShowInfoMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean; Overload;
Function ShowInfoMsg(MsgText: String): Boolean; Overload;
Function ShowQuestionMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean; Overload;
Function ShowQuestionMsg(MsgText: String): Boolean; Overload;
Function ShowWarningMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean; Overload;
Function ShowWarningMsg(MsgText: String): Boolean; Overload;
Function ShowErrorMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean; Overload;
Function ShowErrorMsg(MsgText: String): Boolean; Overload;

var
  fMsgForm: TfMsgForm;

implementation

{$R *.dfm}
{$R MsgIcons.res}

const
//*** EN ***
 lYes = 'Yes';
  lNo = 'No';
  lOK = 'OK';

//*** CZ ***
{lYes = 'Ano';
  lNo = 'Ne';
  lOK = 'OK';}

dGS = 8; //v�choz� velikost m��ky

//*** n�zvy ikon v resources ***
rin_info = 'info';
rin_question = 'question';
rin_warning = 'warning';
rin_error = 'error';

var
  ResultState:  Boolean;
  SelectedPos:  Boolean;

//procedura pro na�ten� ikony zpr�vy z resources
Procedure TfMsgForm.LoadResIcon(const ResIconName: String);
var
  PNG:  TPNGObject;
begin
PNG := TPNGObject.Create;
try
  If ResIconName <> '' then
    begin
      PNG.LoadFromResourceName(hInstance,ResIconName);
      imMsgIcon.Picture.Assign(PNG);
      imMsgIcon.Visible := True;
      //nastaven� horizont�ln� pozice ikony
      imMsgIcon.Left := 1 * dGS;
    end
  else
    begin
      imMsgIcon.Visible := False;
      imMsgIcon.Picture := nil;
      imMsgIcon.Height := 0;
      imMsgIcon.Width := 0;
      //nastaven� horizont�ln� pozice ikony
      imMsgIcon.Left := Trunc(0.5 * dGS);
    end;
finally
  PNG.Free;
end
(*
If ResIconName = '' then PNG := nil else
try
  PNG.LoadFromResourceName(hInstance,ResIconName);
except
  PNG := nil;
end;
//(ne)zobrazen� ikony
If Assigned(PNG) then
  begin
    imMsgIcon.Picture.Assign(PNG);
    imMsgIcon.Visible := True;
    //nastaven� horizont�ln� pozice ikony
    imMsgIcon.Left := 1 * dGS;
  end
else
  begin
    imMsgIcon.Visible := False;
    imMsgIcon.Picture := nil;
    imMsgIcon.Height := 0;
    imMsgIcon.Width := 0;
    //nastaven� horizont�ln� pozice ikony
    imMsgIcon.Left := Trunc(0.5 * dGS);
  end;
PNG.Free;
*)
end;

// Procedura pro automatick� srovn�n� objekt� na formul��i
Function TfMsgForm.MsgFormSort(IconName: String; Sender: TForm; BtnsCount: Byte; MsgText, MsgTitle, BtnYesCaption, BtnNoCaption: String; YesSelected: Boolean): Boolean;
var
  SecButton, i:  Integer;
begin
//nastaven� podle po�tu tla��tek
Case BtnsCount of
2:begin
    SecButton := 1;
  end;
else
SecButton := 0;
end;
SelectedPos := YesSelected;
//ur�en� titulku okna
If MsgTitle = '' then
  If Sender = nil then MsgTitle := Application.Title
    else MsgTitle := Sender.Caption;
//nastaven� n�pis� tla��tek
If BtnYesCaption = '' then BtnYesCaption := lYes;
If BtnNoCaption = '' then
  If BtnsCount = 2 then BtnNoCaption := lNo
    else BtnNoCaption := lOK;
//na�ten� ikony a jej� horizont�ln� um�st�n�
LoadResIcon(IconName);
//nastaven� horizon�ln� pozice textu a jeho na�ten�
lblMainText.Caption := MsgText;
lblMainText.Left := imMsgIcon.Left + imMsgIcon.Width + (1 * dGS);
//nastaven� vertik�ln� pozice textu a ikony
If lblMainText.Height > imMsgIcon.Height then
  begin
    lblMainText.Top := Trunc(1.5 * dGS);
    imMsgIcon.Top := lblMainText.Top + ((lblMainText.Height - imMsgIcon.Height) div 2);
  end
else
  begin
    imMsgIcon.Top := 1 * dGS;
    lblMainText.Top := imMsgIcon.Top + ((imMsgIcon.Height - lblMainText.Height) div 2);
  end;
//nastaven� vertik�ln� pozice tla��tek
If lblMainText.Height > imMsgIcon.Height then
  btnYesButton.Top := lblMainText.Top + lblMainText.Height + 2 * dGS
else
  btnYesButton.Top := imMsgIcon.Top + imMsgIcon.Height + (1 * dGS);
btnNoButton.Top := btnYesButton.Top;
//nastaven� ���ky a v��ky okna
ClientWidth := lblMainText.Left + lblMainText.Width + Trunc(1.5 * dGS);
i := (btnNoButton.Width + (1 * dGS)) + (SecButton * (btnYesButton.Width + (1 * dGs))) + (4 * dGs);
If ClientWidth < i then ClientWidth := i;
ClientHeight := btnNoButton.Top + btnNoButton.Height + (1 * dGS);
//nastaven� horizont�ln� pozice tla��tek
If Boolean(SecButton) then
  begin
    i := ClientWidth div 2;
    btnYesButton.Left := i - (btnYesButton.Width + ((1 * dGS) div 2));
    btnNoButton.Left := i + ((1 * dGS) div 2);
  end
else btnNoButton.Left := (ClientWidth - btnNoButton.Width) div 2;
//nastaven� zobrazen� tla��tek a jejich textu
btnNoButton.Enabled := True;
btnNoButton.Visible := True;
btnNobutton.Caption := BtnNoCaption;
btnYesButton.Enabled := Boolean(SecButton);
btnYesButton.Visible := Boolean(SecButton);
btnYesButton.Caption := BtnYesCaption;
//nastaven� pozice okna
If Sender = nil then
  begin
    Position := poScreenCenter;
  end
else
  begin
    Position := poDesigned;
    Left := Sender.Left + ((Sender.Width - Width) div 2);
    Top := Sender.Top + ((Sender.Height - Height) div 2);
    //kontrola pozice aby se okno nezobrazilo mimo plochu
    If Left < 0 then Left := 0;
    If (Left + Width) > Screen.Width then Left := Screen.Width - Width;
    If (Top + Height) > Screen.Height then Top := Screen.Height - Height;
    If Top < 0 then Top := 0;
  end;
//nastaven� titulku okna
Caption := MsgTitle;  
//mod�ln� zobrazit okno
ShowModal;
//p�edat v�sledek
Result := ResultState;
end;

//Zpr�ve bez ikony, 0 = z�klad, 1 = ot�zka
Function ShowMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean; Overload;
begin
Case MsgType of
1:Result := fMsgForm.MsgFormSort('',Sender,2,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
else
  Result := fMsgForm.MsgFormSort('',Sender,1,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
end;
end;

//zjednodu�en� zpr�va
Function ShowMsg(MsgText: String): Boolean; Overload;
begin
Result := ShowMsg(nil,0,MsgText,'','','',False);
end;

//Zpr�va s ikonou (i), 0 = z�klad, 1 = ot�zka
Function ShowInfoMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean;
begin
Case MsgType of
1:Result := fMsgForm.MsgFormSort(rin_info,Sender,2,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
else
  Result := fMsgForm.MsgFormSort(rin_info,Sender,1,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
end;
end;

//zjednodu�en� zpr�va s ikonou (i)
Function ShowInfoMsg(MsgText: String): Boolean; Overload;
begin
Result := ShowInfoMsg(nil,0,MsgText,'','','',False);
end;

//Dotazovac� zpr�va s ikonou (?), 0 = z�klad, 1 = ot�zka
Function ShowQuestionMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean;
begin
Case MsgType of
1:Result := fMsgForm.MsgFormSort(rin_question,Sender,2,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
else
  Result := fMsgForm.MsgFormSort(rin_question,Sender,1,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
end;
end;

//zjednodu�en� zpr�va s ikonou (?)
Function ShowQuestionMsg(MsgText: String): Boolean; Overload;
begin
Result := ShowQuestionMsg(nil,0,MsgText,'','','',False);
end;

//Varovn� zpr�va s ikonou (!), 0 = z�klad, 1 = ot�zka
Function ShowWarningMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean;
begin
Case MsgType of
1:Result := fMsgForm.MsgFormSort(rin_warning,Sender,2,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
else
  Result := fMsgForm.MsgFormSort(rin_warning,Sender,1,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
end;
end;

//zjednodu�en� zpr�va s ikonou (!)
Function ShowWarningMsg(MsgText: String): Boolean; Overload;
begin
Result := ShowWarningMsg(nil,0,MsgText,'','','',False);
end;

//Chybov� zpr�va s ikonou (X), 0 = z�klad, 1 = ot�zka
Function ShowErrorMsg(Sender: TForm; MsgType: Byte; MsgText, MsgTitle, ButtonYesCaption, ButtonNoCaption: String; SelectedPositive: Boolean = False): Boolean;
begin
Case MsgType of
1:Result := fMsgForm.MsgFormSort(rin_error,Sender,2,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
else
  Result := fMsgForm.MsgFormSort(rin_error,Sender,1,MsgText,MsgTitle,ButtonYesCaption,ButtonNoCaption,SelectedPositive);
end;
end;

//zjednodu�en� zpr�va s ikonou (X)
Function ShowErrorMsg(MsgText: String): Boolean; Overload;
begin
Result := ShowErrorMsg(nil,0,MsgText,'','','',False);
end;

//Procedury objekt�
procedure TfMsgForm.FormShow(Sender: TObject);
begin
ResultState := False;
If SelectedPos and (btnYesButton.Visible and btnYesButton.Enabled) then btnYesButton.SetFocus else btnNoButton.SetFocus;
end;

procedure TfMsgForm.btnYesButtonClick(Sender: TObject);
begin
ResultState := True;
Close;
end;

procedure TfMsgForm.btnNoButtonClick(Sender: TObject);
begin
ResultState := False;
Close;
end;

end.
