unit StringEncryptionUnit;

//------------------------------------------------------------------------------
//Pouze provizorn� postupy, t�m�� v�e by se dalo napsat l�pe a v�razn� zrychlit.
//
//             Ur�eno pouze pro kr�tk� texty, nikoliv pro data!
//------------------------------------------------------------------------------

interface

uses
  SyncObjs;

const
  EncryptedChar = '@'; //znak uvozuj�c� �ifrovan� text

Procedure PrecalculateEncryptionMatrixes;

Function EncryptString(const InputString: String; const Version: Integer): String;
Function DecryptString(const InputString: String): String;

Function GetNumberOfEncryptionVersions: Integer;

var
  EncryptionCritSect: TCriticalSection;

implementation

uses
  SysUtils, StrUtils, Math;

const
  NumberOfVersions = 4; //m��e b�t maxim�ln� ($FF - VersionBias)
  VersionBias = $83;
  def_BufferLength = 16{B};


var
//--- hlavn� matice pro �ifrov�n� ----------------------------------------------
  MatrixesPrecalculated:  Boolean;
  EncMatrices: Array [0..1] of String = ('104b43475f2e1e10d81fc74b64e5b09f',
                                         'd80f0471a0e33a5e2d419c5d7ebd2472');
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
//                         Spole�n� funkce a procedury
//
//------------------------------------------------------------------------------

//kontroln� sou�et textu (byte);
Function ControlCount(const InputStr: String): Byte;
var
  i:  Integer;
begin
Result := 0;
For i := 1 to Length(InputStr) do
  begin
    Result := Byte(Result + Ord(InputStr[i]));
  end;
end;

//�prava textu p�id�n�m zadan� hodnoty
Procedure CharAddition(var InputStr: String; const Additive: Byte);
var
  i:  Integer;
begin
For i := 1 to Length(InputStr) do
  begin
    InputStr[i] := Chr(Byte(Ord(InputStr[i]) + Additive));
  end;
end;

//z�kladn� za�ifrov�n� textu
Procedure StrEncrypt(var Buffer: String; const Matrix: String; Substract: Boolean);
var
  i:            Integer;
  CacheMatrix:  String;
begin
//vytvo�en� hlavn� matice (p�edpokl�d� se �e je krat�� ne� buffer, pokud je del��, bere se jen pot�ebn� d�lka)
While Length(CacheMatrix) < Length(Buffer) do
  begin
    CacheMatrix := CacheMatrix + Matrix;
  end;
For i := 1 to Length(Buffer) do
  begin
    If Substract then
      begin
        Buffer[i] := Chr(Byte(Ord(Buffer[i]) - Ord(CacheMatrix[i]) + $100));
      end
    else
      begin
        Buffer[i] := Chr(Byte(Ord(Buffer[i]) + Ord(CacheMatrix[i])));
      end;
  end;
end;

//------------------------------------------------------------------------------
//
//                         Hlavn� procedury �ifrov�n� 
//
//------------------------------------------------------------------------------

//funkce pro z�sk�n� po�tu verz� �ifrov�n�
Function GetNumberOfEncryptionVersions: Integer;
begin
Result := NumberOfVersions;
end;

//p�edpo��t�n� matic pro (de)�ifrov�n�
Procedure PrecalculateEncryptionMatrixes;
var
  i,j:    Integer;
  Cache:  String;
begin
EncryptionCritSect.Enter;
For i := Low(EncMatrices) to High(EncMatrices) do
  begin
    Cache := EncMatrices[i];
    EncMatrices[i] := '';
    For j := 1 to (Length(Cache) div 2) do
      begin
        EncMatrices[i] := EncMatrices[i] + Char(StrToInt('$' + AnsiMidStr(Cache,(j*2)-1,2)));
      end;
  end;
MatrixesPrecalculated := True;
EncryptionCritSect.Leave;
end;

//--- procedury za�ifrov�n� textu ----------------------------------------------

//funkce �ifruj�c� text verze 1
Function Encryption_1(const InputStr: String; const Index: Integer; Substract: Boolean): String;
var
  wMatrix:  String;
  Buffer:   String;
  sPos:     Integer;
  BaseNum:  Byte;
  FirstNum: Byte;
begin
//ur�en� z�kladn�ho pseudon�hodn�ho ��sla
Randomize;
FirstNum := RandomRange(0,High(Byte)+1);
BaseNum := FirstNum;
//vynulov�n� v�stupu
Result := '';
//nastaven� pozice na za��tek textu
sPos := 1;
//na�ten� prvn� matice
EncryptionCritSect.Enter;
wMatrix := EncMatrices[Index];
EncryptionCritSect.Leave;
//�prava prvn� matice podle pseudon�hodn�ho ��sla
CharAddition(wMatrix,BaseNum);
//hlavn� cyklus za�iforv�n� textu (opakovat dokud nen� pozice mimo rozsah)
Repeat
  //na�ten� bufferu
  Buffer := AnsiMidStr(InputStr,sPos,def_BufferLength);
  //zv��en� pozice
  Inc(sPos,def_BufferLength);
  //za�ifrov�n� bufferu podle matice
  StrEncrypt(Buffer,wMatrix,Substract);
  //ur�en� nov�ho ��sla pro �pravu matice podle kontroln�ho sou�tu bufferu
  BaseNum := ControlCount(Buffer);
  //zm�na pracovn� matice
  CharAddition(wMatrix,BaseNum);
  //p�id�n� bufferu do v�sledku
  Result := Result + Buffer;
Until sPos > Length(InputStr);
//zaps�n� prvn�ho pseudon�hodn�ho coeficientu
Result :=  Result + Chr(FirstNum);
end;

//za�ifrov�n� textu
Function EncryptString(const InputString: String; const Version: Integer): String;
var
  Cache:  String;
  i:      Integer;
begin
//pokud nejsou p�edpo��t�ny matice, spo��st je
EncryptionCritSect.Enter;
If not MatrixesPrecalculated then PrecalculateEncryptionMatrixes;
EncryptionCritSect.Leave;
//operace podle verze
Case Version of
  0:begin
      Cache := Encryption_1(InputString,0,False);
    end;
  1:begin
      Cache := Encryption_1(InputString,0,True);
    end;
  2:begin
      Cache := Encryption_1(InputString,1,False);
    end;
  3:begin
      Cache := Encryption_1(InputString,1,True);
    end;
else
  Result := InputString;
  Exit;
end;
//zaps�n� pot�ebn�ch �daj�
Cache := Chr(Byte(Ord(Cache[1]) + VersionBias + Version)) + Cache;
Cache := Chr(ControlCount(Cache)) + Cache;
Result := EncryptedChar;
//p�eveden� na hex
For i := 1 to Length(Cache) do
  Result := Result + LowerCase(IntToHex(Ord(Cache[i]),2));
end;

//--- procedury de�ifrov�n� textu ----------------------------------------------

Function Decryption_1(var InputStr: String; const Index: Integer; Substract: Boolean): String;
var
  wMatrix:  String;
  Buffer:   String;
  sPos:     Integer;
  BaseNum:  Byte;
begin
//vynulov�n� v�stupu
Result := '';
//nastaven� pozice na za��tek textu
sPos := 1;
//ur�en� prvn�ho koeficientu pro matici (prvn� znak) a jeho vymaz�n�
BaseNum := Byte(Ord(InputStr[Length(InputStr)]));
Delete(InputStr,Length(InputStr),1);
//na�ten� prvn� matice
EncryptionCritSect.Enter;
wMatrix := EncMatrices[Index];
EncryptionCritSect.Leave;
//�prava prvn� matice podle prvn�hoo koef.
CharAddition(wMatrix,BaseNum);
//hlavn� cyklus za�iforv�n� textu (opakovat dokud nen� pozice mimo rozsah)
Repeat
  //na�ten� bufferu
  Buffer := AnsiMidStr(InputStr,sPos,def_BufferLength);
  //zv��en� pozice
  Inc(sPos,def_BufferLength);
  //ur�en� nov�ho ��sla pro �pravu matice podle kontroln�ho sou�tu bufferu
  BaseNum := ControlCount(Buffer);
  //de�ifrov�n� bufferu podle matice
  StrEncrypt(Buffer,wMatrix,Substract);
  //zm�na pracovn� matice
  CharAddition(wMatrix,BaseNum);
  //p�id�n� bufferu do v�sledku
  Result := Result + Buffer;
Until sPos > Length(InputStr);
end;

//de�ifrov�n� textu
Function DecryptString(const InputString: String): String;
var
  Cache:  String;
  i,ver:  Integer;
begin
Result := '';
//pokud text neza��n� uvozuj�c�m znakem -> konec
If InputString[1] <> EncryptedChar then Exit;
//p�eveden� hex na chars (za��nat od pozice 2 proto�e prvn� je EncryptedChar)
Cache := '';
For i := 1 to (Length(InputString) div 2) do
  Cache := Cache + Chr(StrToInt('$' + AnsiMidStr(InputString,(i*2),2)));
//kontrola sou�tu, pokud nesouhlas�, konec
i := Ord(Cache[1]);
Delete(Cache,1,1);
If ControlCount(Cache) <> Byte(i) then Exit;
//ur�en� verze
ver := Ord(Cache[1]) - Ord(Cache[2]) - VersionBias;
If ver < 0 then ver := Byte(ver + $100);
Delete(Cache,1,1);
//pokud nejsou p�edpo��t�ny matice, spo��st je
EncryptionCritSect.Enter;
If not MatrixesPrecalculated then PrecalculateEncryptionMatrixes;
EncryptionCritSect.Leave;
//operace podle verze
Case ver of
  0:begin
      Result := Decryption_1(Cache,0,True);
    end;
  1:begin
      Result := Decryption_1(Cache,0,False);
    end;
  2:begin
      Result := Decryption_1(Cache,1,True);
    end;
  3:begin
      Result := Decryption_1(Cache,1,False);
    end
else
  Result := InputString;
end;
end;

initialization
  EncryptionCritSect := TCriticalSection.Create;
  MatrixesPrecalculated := False;

finalization
  EncryptionCritSect.Free;

end.
