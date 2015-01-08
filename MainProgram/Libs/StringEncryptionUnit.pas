unit StringEncryptionUnit;

//------------------------------------------------------------------------------
//Pouze provizorní postupy, témìø vše by se dalo napsat lépe a výraznì zrychlit.
//
//             Urèeno pouze pro krátké texty, nikoliv pro data!
//------------------------------------------------------------------------------

interface

uses
  SyncObjs;

const
  EncryptedChar = '@'; //znak uvozující šifrovaný text

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
  NumberOfVersions = 4; //mùže být maximálnì ($FF - VersionBias)
  VersionBias = $83;
  def_BufferLength = 16{B};


var
//--- hlavní matice pro šifrování ----------------------------------------------
  MatrixesPrecalculated:  Boolean;
  EncMatrices: Array [0..1] of String = ('104b43475f2e1e10d81fc74b64e5b09f',
                                         'd80f0471a0e33a5e2d419c5d7ebd2472');
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//
//                         Spoleèné funkce a procedury
//
//------------------------------------------------------------------------------

//kontrolní souèet textu (byte);
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

//úprava textu pøidáním zadané hodnoty
Procedure CharAddition(var InputStr: String; const Additive: Byte);
var
  i:  Integer;
begin
For i := 1 to Length(InputStr) do
  begin
    InputStr[i] := Chr(Byte(Ord(InputStr[i]) + Additive));
  end;
end;

//základní zašifrování textu
Procedure StrEncrypt(var Buffer: String; const Matrix: String; Substract: Boolean);
var
  i:            Integer;
  CacheMatrix:  String;
begin
//vytvoøení hlavní matice (pøedpokládá se že je kratší než buffer, pokud je delší, bere se jen potøebná délka)
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
//                         Hlavní procedury šifrování 
//
//------------------------------------------------------------------------------

//funkce pro získání poètu verzí šifrování
Function GetNumberOfEncryptionVersions: Integer;
begin
Result := NumberOfVersions;
end;

//pøedpoèítání matic pro (de)šifrování
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

//--- procedury zašifrování textu ----------------------------------------------

//funkce šifrující text verze 1
Function Encryption_1(const InputStr: String; const Index: Integer; Substract: Boolean): String;
var
  wMatrix:  String;
  Buffer:   String;
  sPos:     Integer;
  BaseNum:  Byte;
  FirstNum: Byte;
begin
//urèení základního pseudonáhodného èísla
Randomize;
FirstNum := RandomRange(0,High(Byte)+1);
BaseNum := FirstNum;
//vynulování výstupu
Result := '';
//nastavení pozice na zaèátek textu
sPos := 1;
//naètení první matice
EncryptionCritSect.Enter;
wMatrix := EncMatrices[Index];
EncryptionCritSect.Leave;
//úprava první matice podle pseudonáhodného èísla
CharAddition(wMatrix,BaseNum);
//hlavní cyklus zašiforvání textu (opakovat dokud není pozice mimo rozsah)
Repeat
  //naètení bufferu
  Buffer := AnsiMidStr(InputStr,sPos,def_BufferLength);
  //zvýšení pozice
  Inc(sPos,def_BufferLength);
  //zašifrování bufferu podle matice
  StrEncrypt(Buffer,wMatrix,Substract);
  //urèení nového èísla pro úpravu matice podle kontrolního souètu bufferu
  BaseNum := ControlCount(Buffer);
  //zmìna pracovní matice
  CharAddition(wMatrix,BaseNum);
  //pøidání bufferu do výsledku
  Result := Result + Buffer;
Until sPos > Length(InputStr);
//zapsání prvního pseudonáhodného coeficientu
Result :=  Result + Chr(FirstNum);
end;

//zašifrování textu
Function EncryptString(const InputString: String; const Version: Integer): String;
var
  Cache:  String;
  i:      Integer;
begin
//pokud nejsou pøedpoèítány matice, spoèíst je
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
//zapsání potøebných údají
Cache := Chr(Byte(Ord(Cache[1]) + VersionBias + Version)) + Cache;
Cache := Chr(ControlCount(Cache)) + Cache;
Result := EncryptedChar;
//pøevedení na hex
For i := 1 to Length(Cache) do
  Result := Result + LowerCase(IntToHex(Ord(Cache[i]),2));
end;

//--- procedury dešifrování textu ----------------------------------------------

Function Decryption_1(var InputStr: String; const Index: Integer; Substract: Boolean): String;
var
  wMatrix:  String;
  Buffer:   String;
  sPos:     Integer;
  BaseNum:  Byte;
begin
//vynulování výstupu
Result := '';
//nastavení pozice na zaèátek textu
sPos := 1;
//urèení prvního koeficientu pro matici (první znak) a jeho vymazání
BaseNum := Byte(Ord(InputStr[Length(InputStr)]));
Delete(InputStr,Length(InputStr),1);
//naètení první matice
EncryptionCritSect.Enter;
wMatrix := EncMatrices[Index];
EncryptionCritSect.Leave;
//úprava první matice podle prvníhoo koef.
CharAddition(wMatrix,BaseNum);
//hlavní cyklus zašiforvání textu (opakovat dokud není pozice mimo rozsah)
Repeat
  //naètení bufferu
  Buffer := AnsiMidStr(InputStr,sPos,def_BufferLength);
  //zvýšení pozice
  Inc(sPos,def_BufferLength);
  //urèení nového èísla pro úpravu matice podle kontrolního souètu bufferu
  BaseNum := ControlCount(Buffer);
  //dešifrování bufferu podle matice
  StrEncrypt(Buffer,wMatrix,Substract);
  //zmìna pracovní matice
  CharAddition(wMatrix,BaseNum);
  //pøidání bufferu do výsledku
  Result := Result + Buffer;
Until sPos > Length(InputStr);
end;

//dešifrování textu
Function DecryptString(const InputString: String): String;
var
  Cache:  String;
  i,ver:  Integer;
begin
Result := '';
//pokud text nezaèíná uvozujícím znakem -> konec
If InputString[1] <> EncryptedChar then Exit;
//pøevedení hex na chars (zaèínat od pozice 2 protože první je EncryptedChar)
Cache := '';
For i := 1 to (Length(InputString) div 2) do
  Cache := Cache + Chr(StrToInt('$' + AnsiMidStr(InputString,(i*2),2)));
//kontrola souètu, pokud nesouhlasí, konec
i := Ord(Cache[1]);
Delete(Cache,1,1);
If ControlCount(Cache) <> Byte(i) then Exit;
//urèení verze
ver := Ord(Cache[1]) - Ord(Cache[2]) - VersionBias;
If ver < 0 then ver := Byte(ver + $100);
Delete(Cache,1,1);
//pokud nejsou pøedpoèítány matice, spoèíst je
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
