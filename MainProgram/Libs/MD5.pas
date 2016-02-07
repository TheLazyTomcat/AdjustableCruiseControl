{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
{===============================================================================

  MD5 Hash Calculation

  ©František Milt 2015-12-13

  Version 1.5.4

===============================================================================}
unit MD5;

{$DEFINE LargeBuffer}

{$IF defined(CPUX86_64) or defined(CPUX64)}
  {$DEFINE x64}
  {$IF not(defined(WINDOWS) or defined(MSWINDOWS))}
    {$DEFINE PurePascal}
  {$IFEND}
{$ELSEIF defined(CPU386)}
  {$DEFINE x86}
{$ELSE}
  {$DEFINE PurePascal}
{$IFEND}

{$IF defined(FPC) and not defined(PurePascal)}
  {$ASMMODE Intel}
{$IFEND}

{$IFDEF ENDIAN_BIG}
  {$MESSAGE FATAL 'Big-endian system not supported'}
{$ENDIF}

{$IFOPT Q+}
  {$DEFINE OverflowCheck}
{$ENDIF}

interface

uses
  Classes, AuxTypes;

type
  TMD5Hash = record
    PartA:  UInt32;
    PartB:  UInt32;
    PartC:  UInt32;
    PartD:  UInt32;
  end;
  PMD5Hash = ^TMD5Hash;

const
  InitialMD5: TMD5Hash = (
    PartA:  $67452301;
    PartB:  $EFCDAB89;
    PartC:  $98BADCFE;
    PartD:  $10325476);
    
  ZeroMD5: TMD5Hash = (PartA: 0; PartB: 0; PartC: 0; PartD: 0);

Function MD5toStr(Hash: TMD5Hash): String;
Function StrToMD5(Str: String): TMD5Hash;
Function TryStrToMD5(const Str: String; out Hash: TMD5Hash): Boolean;
Function StrToMD5Def(const Str: String; Default: TMD5Hash): TMD5Hash;
Function SameMD5(A,B: TMD5Hash): Boolean;

procedure BufferMD5(var Hash: TMD5Hash; const Buffer; Size: TMemSize); overload;
Function LastBufferMD5(Hash: TMD5Hash; const Buffer; Size: TMemSize; MessageLength: UInt64): TMD5Hash; overload;
Function LastBufferMD5(Hash: TMD5Hash; const Buffer; Size: TMemSize): TMD5Hash; overload;

Function BufferMD5(const Buffer; Size: TMemSize): TMD5Hash; overload;

Function AnsiStringMD5(const Str: AnsiString): TMD5Hash;
Function WideStringMD5(const Str: WideString): TMD5Hash;
Function StringMD5(const Str: String): TMD5Hash;

Function StreamMD5(Stream: TStream; Count: Int64 = -1): TMD5Hash;
Function FileMD5(const FileName: String): TMD5Hash;

//------------------------------------------------------------------------------

type
  TMD5Context = type Pointer;

Function MD5_Init: TMD5Context;
procedure MD5_Update(Context: TMD5Context; const Buffer; Size: TMemSize);
Function MD5_Final(var Context: TMD5Context; const Buffer; Size: TMemSize): TMD5Hash; overload;
Function MD5_Final(var Context: TMD5Context): TMD5Hash; overload;
Function MD5_Hash(const Buffer; Size: TMemSize): TMD5Hash;


implementation

uses
  SysUtils, Math;

const
  ChunkSize       = 64;                           // 512 bits
{$IFDEF LargeBuffer}
  ChunksPerBuffer = 16384;                        // => 1MiB BufferSize
{$ELSE}
  ChunksPerBuffer = 64;                           // => 4KiB BufferSize
{$ENDIF}
  BufferSize      = ChunksPerBuffer * ChunkSize;  // size of read buffer

  ShiftCoefs: array[0..63] of UInt8 = (
    7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21);

  SinusCoefs: array[0..63] of UInt32 = (
    $D76AA478,$E8C7B756,$242070DB,$C1BDCEEE,$F57C0FAF,$4787C62A,$A8304613,$FD469501,
    $698098D8,$8B44F7AF,$FFFF5BB1,$895CD7BE,$6B901122,$FD987193,$A679438E,$49B40821,
    $F61E2562,$C040B340,$265E5A51,$E9B6C7AA,$D62F105D,$02441453,$D8A1E681,$E7D3FBC8,
    $21E1CDE6,$C33707D6,$F4D50D87,$455A14ED,$A9E3E905,$FCEFA3F8,$676F02D9,$8D2A4C8A,
    $FFFA3942,$8771F681,$6D9D6122,$FDE5380C,$A4BEEA44,$4BDECFA9,$F6BB4B60,$BEBFBC70,
    $289B7EC6,$EAA127FA,$D4EF3085,$04881D05,$D9D4D039,$E6DB99E5,$1FA27CF8,$C4AC5665,
    $F4292244,$432AFF97,$AB9423A7,$FC93A039,$655B59C3,$8F0CCC92,$FFEFF47D,$85845DD1,
    $6FA87E4F,$FE2CE6E0,$A3014314,$4E0811A1,$F7537E82,$BD3AF235,$2AD7D2BB,$EB86D391);

  ModuloCoefs: array[0..63] of UInt8 = (
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
    1,  6, 11,  0,  5, 10, 15,  4,  9, 14,  3,  8, 13,  2,  7, 12,
    5,  8, 11, 14,  1,  4,  7, 10, 13,  0,  3,  6,  9, 12, 15,  2,
    0,  7, 14,  5, 12,  3, 10,  1,  8, 15,  6, 13,  4, 11,  2,  9);

type
  TChunkBuffer = array[0..ChunkSize - 1] of UInt8;
  PChunkBuffer = ^TChunkBuffer;

  TMD5Context_Internal = record
    MessageHash:    TMD5Hash;
    MessageLength:  UInt64;
    TransferSize:   UInt32;
    TransferBuffer: TChunkBuffer;
  end;
  PMD5Context_Internal = ^TMD5Context_Internal;

//==============================================================================

Function LeftRotate(Value: UInt32; Shift: Byte): UInt32; register; {$IFNDEF PurePascal}assembler;
asm
{$IFDEF x64}
    MOV   EAX,  ECX
{$ENDIF}
    MOV   CL,   DL
    ROL   EAX,  CL
end;
{$ELSE}
begin
Shift := Shift and $1F;
Result := UInt32((Value shl Shift) or (Value shr (32 - Shift)));
end;
{$ENDIF}

//------------------------------------------------------------------------------

Function ChunkHash(Hash: TMD5Hash; const Chunk): TMD5Hash;
var
  i:          Integer;
  Temp:       UInt32;
  FuncResult: UInt32;
  ChunkWords: array[0..15] of UInt32 absolute Chunk;
begin
Result := Hash;
For i := 0 to 63 do
  begin
    case i of
       0..15: FuncResult := (Hash.PartB and Hash.PartC) or ((not Hash.PartB) and Hash.PartD);
      16..31: FuncResult := (Hash.PartD and Hash.PartB) or (Hash.PartC and (not Hash.PartD));
      32..47: FuncResult := Hash.PartB xor Hash.PartC xor Hash.PartD;
    else
     {48..63:}FuncResult := Hash.PartC xor (Hash.PartB or (not Hash.PartD));
    end;
    Temp := Hash.PartD;
    Hash.PartD := Hash.PartC;
    Hash.PartC := Hash.PartB;
    {$IFDEF OverflowCheck}{$Q-}{$ENDIF}
    Hash.PartB := UInt32(Hash.PartB + LeftRotate(UInt32(Hash.PartA + FuncResult + SinusCoefs[i] + ChunkWords[ModuloCoefs[i]]), ShiftCoefs[i]));
    {$IFDEF OverflowCheck}{$Q+}{$ENDIF}
    Hash.PartA := Temp;
  end;
{$IFDEF OverflowCheck}{$Q-}{$ENDIF}
Result.PartA := UInt32(Result.PartA + Hash.PartA);
Result.PartB := UInt32(Result.PartB + Hash.PartB);
Result.PartC := UInt32(Result.PartC + Hash.PartC);
Result.PartD := UInt32(Result.PartD + Hash.PartD);
{$IFDEF OverflowCheck}{$Q+}{$ENDIF}
end;

//==============================================================================

Function MD5toStr(Hash: TMD5Hash): String;
var
  HashArray:  array[0..15] of UInt8 absolute Hash;
  i:          Integer;
begin
Result := StringOfChar('0',32);
For i := Low(HashArray) to High(HashArray) do
  begin
    Result[(i * 2) + 2] := IntToHex(HashArray[i] and $0F,1)[1];
    Result[(i * 2) + 1] := IntToHex(HashArray[i] shr 4,1)[1];
  end;
end;

//------------------------------------------------------------------------------

Function StrToMD5(Str: String): TMD5Hash;
var
  HashArray:  array[0..15] of UInt8 absolute Result;
  i:          Integer;
begin
If Length(Str) < 32 then
  Str := StringOfChar('0',32 - Length(Str)) + Str
else
  If Length(Str) > 32 then
    Str := Copy(Str,Length(Str) - 31,32);
For i := 0 to 15 do
  HashArray[i] := StrToInt('$' + Copy(Str,(i * 2) + 1,2));
end;

//------------------------------------------------------------------------------

Function TryStrToMD5(const Str: String; out Hash: TMD5Hash): Boolean;
begin
try
  Hash := StrToMD5(Str);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function StrToMD5Def(const Str: String; Default: TMD5Hash): TMD5Hash;
begin
If not TryStrToMD5(Str,Result) then
  Result := Default;
end;

//------------------------------------------------------------------------------

Function SameMD5(A,B: TMD5Hash): Boolean;
begin
Result := (A.PartA = B.PartA) and (A.PartB = B.PartB) and
          (A.PartC = B.PartC) and (A.PartD = B.PartD);
end;

//==============================================================================

procedure BufferMD5(var Hash: TMD5Hash; const Buffer; Size: TMemSize);
var
  i:    TMemSize;
  Buff: PChunkBuffer;
begin
If Size > 0 then
  begin
    If (Size mod ChunkSize) = 0 then
      begin
        Buff := @Buffer;
        For i := 0 to Pred(Size div ChunkSize) do
          begin
            Hash := ChunkHash(Hash,Buff^);
            Inc(Buff);
          end;
      end
    else raise Exception.CreateFmt('BufferMD5: Buffer size is not divisible by %d.',[ChunkSize]);
  end;
end;

//------------------------------------------------------------------------------

Function LastBufferMD5(Hash: TMD5Hash; const Buffer; Size: TMemSize; MessageLength: UInt64): TMD5Hash;
var
  FullChunks:     TMemSize;
  LastChunkSize:  TMemSize;
  HelpChunks:     TMemSize;
  HelpChunksBuff: Pointer;
begin
Result := Hash;
FullChunks := Size div ChunkSize;
If FullChunks > 0 then BufferMD5(Result,Buffer,FullChunks * ChunkSize);
LastChunkSize := Size - (UInt64(FullChunks) * ChunkSize);
HelpChunks := Ceil((LastChunkSize + SizeOf(UInt64) + 1) / ChunkSize);
HelpChunksBuff := AllocMem(HelpChunks * ChunkSize);
try
  Move({%H-}Pointer({%H-}PtrUInt(@Buffer) + (FullChunks * ChunkSize))^,HelpChunksBuff^,LastChunkSize);
  {%H-}PUInt8({%H-}PtrUInt(HelpChunksBuff) + LastChunkSize)^ := $80;
  {%H-}PUInt64({%H-}PtrUInt(HelpChunksBuff) + (UInt64(HelpChunks) * ChunkSize) - SizeOf(UInt64))^ := MessageLength;
  BufferMD5(Result,HelpChunksBuff^,HelpChunks * ChunkSize);
finally
  FreeMem(HelpChunksBuff,HelpChunks * ChunkSize);
end;
end;

//------------------------------------------------------------------------------

Function LastBufferMD5(Hash: TMD5Hash; const Buffer; Size: TMemSize): TMD5Hash;
begin
Result := LastBufferMD5(Hash,Buffer,Size,UInt64(Size) shl 3);
end;

//==============================================================================

Function BufferMD5(const Buffer; Size: TMemSize): TMD5Hash;
begin
Result := LastBufferMD5(InitialMD5,Buffer,Size);
end;

//==============================================================================

Function AnsiStringMD5(const Str: AnsiString): TMD5Hash;
begin
Result := BufferMD5(PAnsiChar(Str)^,Length(Str) * SizeOf(AnsiChar));
end;

//------------------------------------------------------------------------------

Function WideStringMD5(const Str: WideString): TMD5Hash;
begin
Result := BufferMD5(PWideChar(Str)^,Length(Str) * SizeOf(WideChar));
end;

//------------------------------------------------------------------------------

Function StringMD5(const Str: String): TMD5Hash;
begin
Result := BufferMD5(PChar(Str)^,Length(Str) * SizeOf(Char));
end;

//==============================================================================

Function StreamMD5(Stream: TStream; Count: Int64 = -1): TMD5Hash;
var
  Buffer:         Pointer;
  BytesRead:      Integer;
  MessageLength:  UInt64;
begin
If Assigned(Stream) then
  begin
    If Count = 0 then
      Count := Stream.Size - Stream.Position;
    If Count < 0 then
      begin
        Stream.Position := 0;
        Count := Stream.Size;
      end;
    MessageLength := UInt64(Count shl 3);
    GetMem(Buffer,BufferSize);
    try
      Result := InitialMD5;
      repeat
        BytesRead := Stream.Read(Buffer^,Min(BufferSize,Count));
        If BytesRead < BufferSize then
          Result := LastBufferMD5(Result,Buffer^,BytesRead,MessageLength)
        else
          BufferMD5(Result,Buffer^,BytesRead);
        Dec(Count,BytesRead);
      until BytesRead < BufferSize;
    finally
      FreeMem(Buffer,BufferSize);
    end;
  end
else raise Exception.Create('StreamMD5: Stream is not assigned.');
end;

//------------------------------------------------------------------------------

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

//==============================================================================

Function MD5_Init: TMD5Context;
begin
Result := AllocMem(SizeOf(TMD5Context_Internal));
with PMD5Context_Internal(Result)^ do
  begin
    MessageHash := InitialMD5;
    MessageLength := 0;
    TransferSize := 0;
  end;
end;

//------------------------------------------------------------------------------

procedure MD5_Update(Context: TMD5Context; const Buffer; Size: TMemSize);
var
  FullChunks:     TMemSize;
  RemainingSize:  TMemSize;
begin
with PMD5Context_Internal(Context)^ do
  begin
    If TransferSize > 0 then
      begin
        If Size >= (ChunkSize - TransferSize) then
          begin
            Inc(MessageLength,(ChunkSize - TransferSize) shl 3);
            Move(Buffer,TransferBuffer[TransferSize],ChunkSize - TransferSize);
            BufferMD5(MessageHash,TransferBuffer,ChunkSize);
            RemainingSize := Size - (ChunkSize - TransferSize);
            TransferSize := 0;
            MD5_Update(Context,{%H-}Pointer({%H-}PtrUInt(@Buffer) + (Size - RemainingSize))^,RemainingSize);
          end
        else
          begin
            Inc(MessageLength,Size shl 3);
            Move(Buffer,TransferBuffer[TransferSize],Size);
            Inc(TransferSize,Size);
          end;  
      end
    else
      begin
        Inc(MessageLength,Size shl 3);
        FullChunks := Size div ChunkSize;
        BufferMD5(MessageHash,Buffer,FullChunks * ChunkSize);
        If TMemSize(FullChunks * ChunkSize) < Size then
          begin
            TransferSize := Size - (UInt64(FullChunks) * ChunkSize);
            Move({%H-}Pointer({%H-}PtrUInt(@Buffer) + (Size - TransferSize))^,TransferBuffer,TransferSize);
          end;
      end;
  end;
end;

//------------------------------------------------------------------------------

Function MD5_Final(var Context: TMD5Context; const Buffer; Size: TMemSize): TMD5Hash;
begin
MD5_Update(Context,Buffer,Size);
Result := MD5_Final(Context);
end;

//------------------------------------------------------------------------------

Function MD5_Final(var Context: TMD5Context): TMD5Hash;
begin
with PMD5Context_Internal(Context)^ do
  Result := LastBufferMD5(MessageHash,TransferBuffer,TransferSize,MessageLength);
FreeMem(Context,SizeOf(TMD5Context_Internal));
Context := nil;
end;

//------------------------------------------------------------------------------

Function MD5_Hash(const Buffer; Size: TMemSize): TMD5Hash;
begin
Result := LastBufferMD5(InitialMD5,Buffer,Size);
end;

end.
