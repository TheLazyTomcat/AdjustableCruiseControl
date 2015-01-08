{===============================================================================

MD5 Hash Calculation

©František Milt 15.9.2013

Version 1.2.1

===============================================================================}
unit MD5;

interface

uses
  Classes;

type
  TMD5Hash = Record
    PartA:  LongWord;
    PartB:  LongWord;
    PartC:  LongWord;
    PartD:  LongWord;
  end;
  PMD5Hash = ^TMD5Hash;

const
  InitialMD5: TMD5Hash = (
    PartA:  $67452301;
    PartB:  $EFCDAB89;
    PartC:  $98BADCFE;
    PartD:  $10325476);

Function MD5toString(const Hash: TMD5Hash): String;
Function StringToMD5(HashString: String): TMD5Hash;
Function CompareMD5(const Hash1, Hash2: TMD5Hash): Boolean;

Function BufferMD5(const Hash: TMD5Hash; const Buffer; const BuffSize: Integer): TMD5Hash;
Function LastBufferMD5(const Hash: TMD5Hash; const Buffer; const BuffSize: Integer; Size: Int64 = -1): TMD5Hash;
Function StreamMD5(const InputStream: TStream): TMD5Hash;
Function StringMD5(const Text: String): TMD5Hash;
Function FileMD5(const FileName: String): TMD5Hash;

implementation

{.$DEFINE LargeBuffers}
{.$DEFINE UseStringStream}

uses
  Windows, SysUtils, Math;

const
  cFAB             = $80;                             // bin 10000000
  cChunkSize       = 64;                              // 512 bits
{$IFDEF LargeBuffers}
  cChunksPerBuffer = 16384;                           // =>1MiB BufferSize
{$ELSE}
  cChunksPerBuffer = 64;                              // =>4KiB BufferSize
{$ENDIF}
  cBufferSize      = cChunksPerBuffer * cChunkSize;   // size of read buffer

  ShiftCoefs: Array[0..63] of LongWord = (
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21);

  SinusCoefs: Array[0..63] of LongWord = (
    $D76AA478,$E8C7B756,$242070DB,$C1BDCEEE,$F57C0FAF,$4787C62A,$A8304613,$FD469501,
    $698098D8,$8B44F7AF,$FFFF5BB1,$895CD7BE,$6B901122,$FD987193,$A679438E,$49B40821,
    $F61E2562,$C040B340,$265E5A51,$E9B6C7AA,$D62F105D,$02441453,$D8A1E681,$E7D3FBC8,
    $21E1CDE6,$C33707D6,$F4D50D87,$455A14ED,$A9E3E905,$FCEFA3F8,$676F02D9,$8D2A4C8A,
    $FFFA3942,$8771F681,$6D9D6122,$FDE5380C,$A4BEEA44,$4BDECFA9,$F6BB4B60,$BEBFBC70,
    $289B7EC6,$EAA127FA,$D4EF3085,$04881D05,$D9D4D039,$E6DB99E5,$1FA27CF8,$C4AC5665,
    $F4292244,$432AFF97,$AB9423A7,$FC93A039,$655B59C3,$8F0CCC92,$FFEFF47D,$85845DD1,
    $6FA87E4F,$FE2CE6E0,$A3014314,$4E0811A1,$F7537E82,$BD3AF235,$2AD7D2BB,$EB86D391);

  ModuloCoefs: Array[0..63] of LongWord = (
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
    1,  6, 11,  0,  5, 10, 15,  4,  9, 14,  3,  8, 13,  2,  7, 12,
    5,  8, 11, 14,  1,  4,  7, 10, 13,  0,  3,  6,  9, 12, 15,  2,
    0,  7, 14,  5, 12,  3, 10,  1,  8, 15,  6, 13,  4, 11,  2,  9);

//------------------------------------------------------------------------------

Function ChunkHash(Hash: TMD5Hash; const Chunk): TMD5Hash;
var
  i:          Integer;
  Temp:       LongWord;
  FuncResult: LongWord;
  ChunkWords: Array[0..15] of LongWord absolute Chunk;

  Function LeftRotate(Number,Shift: LongWord): LongWord; register
  {$IFDEF PUREPASCAL}
  begin
    Result := (Number shl Shift) or (Number shr (32 - Shift));
  end;
  {$ELSE}
  asm
    mov CL, DL
    rol EAX, CL
  end;
  {$ENDIF}

begin
Result := Hash;
For i := 0 to 63 do
  begin
    Case i of
       0..15: FuncResult := (Hash.PartB and Hash.PartC) or ((not Hash.PartB) and Hash.PartD);
      16..31: FuncResult := (Hash.PartD and Hash.PartB) or (Hash.PartC and (not Hash.PartD));
      32..47: FuncResult := Hash.PartB xor Hash.PartC xor Hash.PartD;
    else
     {48..63:}FuncResult := Hash.PartC xor (Hash.PartB or (not Hash.PartD));
    end;
    Temp := Hash.PartD;
    Hash.PartD := Hash.PartC;
    Hash.PartC := Hash.PartB;
    Hash.PartB := Hash.PartB + LeftRotate(Hash.PartA + FuncResult + SinusCoefs[i] + ChunkWords[ModuloCoefs[i]], ShiftCoefs[i]);
    Hash.PartA := Temp;
  end;
Inc(Result.PartA,Hash.PartA);
Inc(Result.PartB,Hash.PartB);
Inc(Result.PartC,Hash.PartC);
Inc(Result.PartD,Hash.PartD);
end;

//------------------------------------------------------------------------------

Function MD5toString(const Hash: TMD5Hash): String;
var
  HashArray:  Array[0..15] of Byte absolute Hash;
  i:          Integer;
begin
Result := '';
For i := Low(HashArray) to High(HashArray) do
  Result:= Result + (IntToHex(HashArray[i],2));
Result := AnsiLowerCase(Result);
end;

Function StringToMD5(HashString: String): TMD5Hash;
var
  HashArray:  Array[0..15] of Byte absolute Result;
  i:          Integer;
begin
If Length(HashString) < 32 then
  HashString := StringOfChar('0',32 - Length(HashString)) + HashString
else
  If Length(HashString) > 32 then
    HashString := Copy(HashString,Length(HashString) - 31,32);
For i := 0 to 15 do
  HashArray[i] := StrToInt('$' + Copy(HashString,(i * 2) + 1,2));
end;

Function CompareMD5(const Hash1, Hash2: TMD5Hash): Boolean;
begin
Result := (Hash1.PartA = Hash2.PartA) and
          (Hash1.PartB = Hash2.PartB) and
          (Hash1.PartC = Hash2.PartC) and
          (Hash1.PartD = Hash2.PartD);
end;

//------------------------------------------------------------------------------

Function BufferMD5(const Hash: TMD5Hash; const Buffer; const BuffSize: Integer): TMD5Hash;
type
  TChunkBuffer = Array[0..cChunkSize - 1] of Byte;
  PChunkBuffer = ^TChunkBuffer;
var
  i:          Integer;
  ChunkPtr:   PChunkBuffer;
begin
Result := Hash;
ChunkPtr := @Buffer;
For i := 1 to (BuffSize div cChunkSize) do
  begin
    Result := ChunkHash(Result,ChunkPtr^);
    Inc(ChunkPtr);
  end;
end;

Function LastBufferMD5(const Hash: TMD5Hash; const Buffer; const BuffSize: Integer; Size: Int64 = -1): TMD5Hash;
var
  HelpBuffer: Pointer;
  Chunks:     Integer;
begin
If Size < 0 then Size := BuffSize;
If BuffSize <= 0 then Chunks := 1 else
  Chunks := Ceil((BuffSize + SizeOf(Int64) + 1) / cChunkSize);
HelpBuffer := AllocMem(Chunks * cChunkSize);
try
  CopyMemory(HelpBuffer,@Buffer,BuffSize);
  PByteArray(HelpBuffer)^[BuffSize] := cFAB;
  PInt64(@PByteArray(HelpBuffer)[(Chunks * cChunkSize) - SizeOf(Int64)])^ := Size * 8;
  Result := BufferMD5(Hash,HelpBuffer^,Chunks * cChunkSize);
finally
  FreeMem(HelpBuffer,Chunks * cChunkSize);
end;
end;

Function StreamMD5(const InputStream: TStream): TMD5Hash;
var
  Buffer: Pointer;
  Readed: Integer;
begin
If Assigned(InputStream) then
  begin
    GetMem(Buffer,cBufferSize);
    try
      Result := InitialMD5;
      InputStream.Position := 0;
      Repeat
        Readed := InputStream.Read(Buffer^,cBufferSize);
        If Readed < cBufferSize then
          Result := LastBufferMD5(Result,Buffer^,Readed,InputStream.Size)
        else
          Result := BufferMD5(Result,Buffer^,Readed);
      Until Readed < cBufferSize;
      InputStream.Position := 0;
    finally
      FreeMem(Buffer,cBufferSize);
    end;
  end;
end;

Function StringMD5(const Text: String): TMD5Hash;
{$IFDEF UseStringStream}
var
  StringStream: TStringStream;
begin
StringStream := TStringStream.Create(Text);
try
  Result := StreamMD5(StringStream);
finally
  StringStream.Free;
end;
end;
{$ELSE}
begin
Result := LastBufferMD5(InitialMD5,PChar(Text)^,Length(Text) * SizeOf(Char));
end;
{$ENDIF}

Function FileMD5(const FileName: String): TMD5Hash;
var
  FileStream: TFileStream;
begin
FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
try
  Result := StreamMD5(FileStream);
finally
  FileStream.Free;
end;
end;

end.
