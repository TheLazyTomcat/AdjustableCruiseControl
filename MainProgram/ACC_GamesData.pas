{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_GamesData;

interface

{$INCLUDE ACC_Defs.inc}

uses
  Classes, IniFiles, {$IFNDEF FPC}PNGImage{$ELSE}Graphics{$ENDIF},
  CRC32, MD5, SimpleCompress, FloatHex, StringEncryptionUnit,
  ACC_Common;

const
  // Default files from which the program will try to load games data
  GamesDataFileBin = 'Data\GamesData.gdb';
  GamesDataFileIni = 'Data\GamesData.ini';

  // Identifiers used for saving/loading ini file
  GDIN_MainSection = 'GamesData';
  GDIN_Game        = 'Game.%d';
  GDIN_Icon        = 'Icon.%d';

  GDIN_MS_FileStructure = 'Version';

  GDIN_IC_Name      = 'Name';
  GDIN_IC_DataCount = 'DataCount';
  GDIN_IC_Data      = 'Data[%d]';

  GDIN_GD_Protocol      = 'Protocol';
  GDIN_GD_Identifier    = 'Identifier';
  GDIN_GD_Descriptor    = 'Descriptor';
  GDIN_GD_Version       = 'Version';
  GDIN_GD_Icon          = 'Icon';
  GDIN_GD_Date          = 'Date';
  GDIN_GD_Author        = 'Author';
  GDIN_GD_Title         = 'Title';
  GDIN_GD_Info          = 'Info';
  GDIN_GD_ExtendedTitle = 'ExtendedTitle';
  GDIN_GD_Modules       = 'Modules';
  GDIN_GD_Module        = 'Module[%d]';
  GDIN_GD_CCSpeed       = 'CCSpeed';
  GDIN_GD_CCStatus      = 'CCStatus';
  GDIN_GD_TruckSpeed    = 'TruckSpeed';
  GDIN_GD_Values        = 'Values';
  GDIN_GD_Value         = 'Value[%d]';

  GDIN_GD_MOD_CheckFlags = '.CheckFlags';
  GDIN_GD_MOD_FileName   = '.FileName';
  GDIN_GD_MOD_Size       = '.Size';
  GDIN_GD_MOD_CRC32      = '.CRC32';
  GDIN_GD_MOD_MD5        = '.MD5';

  GDIN_GD_VAL_Flags       = '.Flags';
  GDIN_GD_VAL_PtrInfo     = '.PtrInfo';
  GDIN_GD_VAL_ModuleIndex = '.ModuleIndex';
  GDIN_GD_VAL_Offsets     = '.Offsets';
  GDIN_GD_VAL_Offset      = '.Offset[%d]';
  GDIN_GD_VAL_Coefficient = '.Coefficient';

  GDIN_GD_LEG_Identificator = 'Identificator';
  GDIN_GD_LEG_GameInfo      = 'GameInfo';
  GDIN_GD_LEG_Process       = 'Process';
  GDIN_GD_LEG_Special       = 'Special[%d]';

type
  TProtocolVersion = type LongWord;

  // Structures used to hold games data in the memory
  TModuleRuntimeInfo = record
    FullPath:       String;
    BaseAddress:    Pointer;
    Check:          Boolean;
  end;

  TModuleData = record
    CheckFlags:   LongWord;
    FileName:     String;
    Size:         Int64;
    CRC32:        TCRC32;
    MD5:          TMD5Hash;
    RuntimeInfo:  TModuleRuntimeInfo;
  end;

  TPointerData = record
    Flags:        LongWord;
    PtrInfo:      LongWord;
    ModuleIndex:  Integer;
    Offsets:      Array of Int64;
    Coefficient:  Single;
  end;

  TProcessInfo = record
    ProcessID:      LongWord;
    ProcessHandle:  THandle;
  end;

  TUpdateInfo = record
    Add:        Boolean;
    Valid:      Boolean;
    NewEntry:   Boolean;
    NewVersion: Boolean;
    OldVersion: Boolean;
  end;

  TGameData = record
    Protocol:       TProtocolVersion;
    Identifier:     TGUID;
    Descriptor:     String;
    Version:        LongWord;
    Icon:           String;
    Date:           TDateTime;
    Author:         String;
    Title:          String;
    Info:           String;
    ExtendedTitle:  String;
    Modules:        Array of TModuleData;
    CCSpeed:        TPointerData;
    CCStatus:       TPointerData;
    TruckSpeed:     TPointerData;
    Values:         Array of TPointerData;
    ProcessInfo:    TProcessInfo;
    UpdateInfo:     TUpdateInfo;
  end;
  PGameData = ^TGameData;

  TGamesData = record
    Entries:  Array of TGameData;
    Hidden:   Array of TGameData;
  end;
  PGamesData = ^TGamesData;

  TFileStructure = LongWord;

  TSupportedSpeedReading = (ssrDirect,ssrPlugin,ssrNone);

const
  CF_NONE      = $00000000;
  CF_FILESIZE  = $00000001;
  CF_FILECRC32 = $00000002;
  CF_FILEMD5   = $00000004;

  BFS_1_0 = $00010000;
  BFS_1_1 = $00010001;
  IFS_1_0 = $00010000;
  IFS_2_0 = $00020000;
  IFS_2_1 = $00020001;

  InvalidProtocolVersion = TProtocolVersion(-1);

  PTR_TYPE_Bool                 = 0;
  PTR_TYPE_Float                = 100;
  PTR_TYPE_FloatCorrected       = 101;
  PTR_TYPE_FloatCorrectedRemote = 102;

  PTR_TYPE_Invalid = $FFFF;

  PTR_FLAGS_TelemetryTruckSpeed = $00000001;

type
  TPtrInfoRec = packed record
    PtrType: Word;  
    PtrData: Word;
  end;

{$IFDEF FPC}
  TPNGObject = TPortableNetworkGraphic;
{$ENDIF}

{==============================================================================}
{------------------------------------------------------------------------------}
{                                   TIconList                                  }
{------------------------------------------------------------------------------}
{==============================================================================}
  TIconListItem = record
    Identifier: String;
    Icon:       TPNGObject;
  end;
  PIconListItem = ^TIconListItem;

  TIconList = class(TList)
  private
    fDefaultIcon: Boolean;
    Function GetListItemPtr(Index: Integer): PIconListItem;
    Function GetListItem(Index: Integer): TIconListItem;
    procedure SetListItem(Index: Integer; Value: TIconListItem);
  public
    constructor Create;
    procedure Clear; override;
    procedure Initialize; virtual;
    Function IndexOfItem(Identifier: String): Integer; virtual;
    Function AddItem(Identifier: String; Data: TStream): Integer; virtual;
    Function GetIcon(Identifier: String): TPNGObject; virtual;
    procedure UpdateFrom(UpdateData: TIconList); virtual;
    Function CountNoDefault: Integer; virtual;
    property ListItemsPtr[Index: Integer]: PIconListItem read GetListItemPtr;
    property ListItems[Index: Integer]: TIconListItem read GetListItem write SetListItem; default;
  published
    property DefaultIcon: Boolean read fDefaultIcon write fDefaultIcon;
  end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                               TGamesDataManager                              }
{------------------------------------------------------------------------------}
{==============================================================================}
  TGamesDataManager = class(TObject)
  private
    fGamesData: TGamesData;
    fGameIcons: TIconList;
    Function GetGamesDataCount: Integer;
    Function GetGameDataPtr(Index: Integer): PGameData;
    Function GetGameData(Index: Integer): TGameData;
  protected
    class procedure WriteStringToStream(Stream: TStream; const Str: String); virtual;
    class procedure ReadStringFromStream(Stream: TStream; out Str: String); overload; virtual;
    class Function ReadStringFromStream(Stream: TStream): String; overload; virtual;
    class procedure WriteIntegerToStream(Stream: TStream; Value: Integer); virtual;
    class procedure ReadIntegerFromStream(Stream: TStream; out Value: Integer); overload; virtual;
    class Function ReadIntegerFromStream(Stream: TStream): Integer; overload; virtual;
    class procedure WriteInt64ToStream(Stream: TStream; Value: Int64); virtual;
    class procedure ReadInt64FromStream(Stream: TStream; out Value: Int64); overload; virtual;
    class Function ReadInt64FromStream(Stream: TStream): Int64; overload; virtual;
    class procedure WriteFloatToStream(Stream: TStream; Value: Single); virtual;
    class procedure ReadFloatFromStream(Stream: TStream; out Value: Single); overload; virtual;
    class Function ReadFloatFromStream(Stream: TStream): Single; overload; virtual;
    procedure SaveIcons(Stream: TStream); overload; virtual;
    procedure LoadIcons(Stream: TStream); overload; virtual;
    procedure SaveIcons(Ini: TCustomIniFile); overload; virtual;
    procedure LoadIcons(Ini: TCustomIniFile); overload; virtual;
    procedure SaveEntryToIni_Struct00010000(Ini: TCustomIniFile; Section: String; const GameData: TGameData); virtual;
    procedure SaveEntryToIni_Struct00020000(Ini: TCustomIniFile; Section: String; const GameData: TGameData); virtual;
    procedure SaveEntryToIni_Struct00020001(Ini: TCustomIniFile; Section: String; const GameData: TGameData); virtual;
    procedure SaveEntryToBin_Struct00010000(Stream: TStream; Position: Int64; const GameData: TGameData); virtual;
    procedure SaveEntryToBin_Struct00010001(Stream: TStream; Position: Int64; const GameData: TGameData); virtual;
    procedure PointerTypeCorrection(var Pointer: TPointerData; Bool: Boolean = False); virtual;
    Function LoadEntryFromIni_Struct00010000(Ini: TCustomIniFile; Section: String; out GameData: TGameData): Boolean; virtual;
    Function LoadEntryFromIni_Struct00020000(Ini: TCustomIniFile; Section: String; out GameData: TGameData): Boolean; virtual;
    Function LoadEntryFromIni_Struct00020001(Ini: TCustomIniFile; Section: String; out GameData: TGameData): Boolean; virtual;
    Function LoadEntryFromBin_Struct00010000(Stream: TStream; Position: Int64; out GameData: TGameData): Boolean; virtual;
    Function LoadEntryFromBin_Struct00010001(Stream: TStream; Position: Int64; out GameData: TGameData): Boolean; virtual;
    procedure SortHiddenForSaving; virtual;
    Function SaveToIni_Struct00010000(Ini: TCustomIniFile): Boolean; virtual;
    Function SaveToIni_Struct00020000(Ini: TCustomIniFile): Boolean; virtual;
    Function SaveToIni_Struct00020001(Ini: TCustomIniFile): Boolean; virtual;
    Function SaveToBin_Struct00010000(Stream: TStream): Boolean; virtual;
    Function SaveToBin_Struct00010001(Stream: TStream): Boolean; virtual;
    procedure ProcessEntryByProtocol(const GameData: TGameData); virtual;
    Function LoadFromIni_Struct00010000(Ini: TCustomIniFile): Boolean; virtual;
    Function LoadFromIni_Struct00020000(Ini: TCustomIniFile): Boolean; virtual;
    Function LoadFromIni_Struct00020001(Ini: TCustomIniFile): Boolean; virtual;
    Function LoadFromBin_Struct00010000(Stream: TStream): Boolean; virtual;
    Function LoadFromBin_Struct00010001(Stream: TStream): Boolean; virtual; 
  public
    class Function SupportsBinFileStructure(FileStructure: TFileStructure): Boolean; virtual;
    class Function SupportsIniFileStructure(FileStructure: TFileStructure): Boolean; virtual;
    class Function SupportsProtocolVersion(ProtocolVersion: TProtocolVersion): Boolean; virtual;
    class Function IsValid(GameData: TGameData): Boolean; virtual;
    class Function TruckSpeedSupported(const GameData: TGameData): TSupportedSpeedReading; virtual;
    constructor Create;
    destructor Destroy; override;
    Function IndexOf(Identifier: TGUID): Integer; virtual;
    Function GameListed(Identifier: TGUID): Boolean; virtual;
    procedure Clear; virtual;
    Function SaveToBin(const FileName: String; FileStructure: TFileStructure): Boolean; virtual;
    Function SaveToIni(const FileName: String; FileStructure: TFileStructure): Boolean; virtual;
    Function LoadFromBin(Stream: TStream; out FileStructure: TFileStructure): Boolean; overload; virtual;
    Function LoadFromBin(Stream: TStream): Boolean; overload; virtual;
    Function LoadFromBin(const FileName: String; out FileStructure: TFileStructure): Boolean; overload; virtual;
    Function LoadFromBin(const FileName: String): Boolean; overload; virtual;
    Function LoadFromIni(const FileName: String; out FileStructure: TFileStructure): Boolean; overload; virtual;
    Function LoadFromIni(const FileName: String): Boolean; overload; virtual;
    Function LoadFrom(const FileName: String): Boolean; virtual;
    Function Load: Boolean; virtual;
    Function Save: Boolean; virtual;
    procedure CheckUpdate(OldData: TGamesDataManager); virtual;
    Function UpdateFrom(UpdateData: TGamesDataManager): Integer; virtual;
    Function AddGameData(GameData: TGameData): Integer; virtual;
    Function RemoveGameData(Identifier: TGUID): Integer; virtual;
    procedure DeleteGameData(Index: Integer); virtual;
    Function IsHidden(Identifier: TGUID): Boolean; virtual;
    Function HideGameData(Identifier: TGUID): Integer; virtual;
    Function AddHiddenGameData(GameData: TGameData): Integer; virtual;
    property GamesData: TGamesData read fGamesData;
    property GameDataPtr[Index: Integer]: PGameData read GetGameDataPtr;
    property GameData[Index: Integer]: TGameData read GetGameData; default;
  published
    property GamesDataCount: Integer read GetGamesDataCount;
    property GameIcons: TIconList read fGameIcons;
  end;


implementation

{$R 'Resources\DefGameIcon.res'}

uses
  Windows, SysUtils, DateUtils, StrUtils, Math, BinTextEnc;

const
  InvalidFileStructure = TFileStructure(-1);

  // Supported gamesdata file structures
  SupportedBinFileStructure: Array[0..1] of TFileStructure = (BFS_1_0,BFS_1_1);
  SupportedIniFileStructure: Array[0..2] of TFileStructure = (IFS_1_0,IFS_2_0,IFS_2_1);

  // Supported protocols
  // Note that protocol affects the entire program, not just games data
  PROTOCOL_NORMAL  = 0;
  PROTOCOL_HIDDEN  = 1;
  PROTOCOL_HIDE    = 2;
  PROTOCOL_UPDHIDE = 3;

  SupportedProtocolVersions: Array[0..3] of TProtocolVersion = (
    PROTOCOL_NORMAL,PROTOCOL_HIDDEN,PROTOCOL_HIDE,PROTOCOL_UPDHIDE);

  // Signature of binarz games data file
  ACCBinFileSignature = $64636361;

  DefaultGameIconName    = 'default';
  DefaultGameIconResName = 'GI_' + DefaultGameIconName;

  INI_ICON_DATA_SplitLength = 128;

{$IFDEF FPC}
Function StrToDateDef(const Str: String; const Default: TDateTime; const FormatSettings: TFormatSettings): TDateTime;
begin
If not TryStrToDate(Str,Result,FormatSettings) then
  Result := Default;
end;
{$ENDIF}


{==============================================================================}
{------------------------------------------------------------------------------}
{                                   TIconList                                  }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TIconList // Private methods                                               }
{------------------------------------------------------------------------------}

Function TIconList.GetListItemPtr(Index: Integer): PIconListItem;
begin
If (Index >= 0) and (Index < Count) then
  Result := PIconListItem(Items[Index])
else
  raise Exception.CreateFmt('TIconList.GetListItemPtr: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TIconList.GetListItem(Index: Integer): TIconListItem;
begin
Result := GetListItemPtr(Index)^;
end;

//------------------------------------------------------------------------------

procedure TIconList.SetListItem(Index: Integer; Value: TIconListItem);
begin
GetListItemPtr(Index)^ := Value;
end;

//------------------------------------------------------------------------------

constructor TIconList.Create;
begin
inherited Create;
fDefaultIcon := True;
Initialize;
end;

{------------------------------------------------------------------------------}
{   TIconList // Public methods                                                }
{------------------------------------------------------------------------------}

procedure TIconList.Clear;
var
  i:  Integer;
begin
For i := 0 to Pred(Count) do
  begin
    PIconListItem(Items[i])^.Icon.Free;
    Dispose(PIconListItem(Items[i]));
  end;
inherited;
end;

//------------------------------------------------------------------------------

procedure TIconList.Initialize;
var
  ResourceStream: TResourceStream;
begin
Clear;
If fDefaultIcon then
  begin
    ResourceStream := TResourceStream.Create(hInstance,DefaultGameIconResName,RT_RCDATA);
    try
      AddItem(DefaultGameIconName,ResourceStream);
    finally
      ResourceStream.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

Function TIconList.IndexOfItem(Identifier: String): Integer;
begin
For Result := 0 to Pred(Count) do
  If AnsiSameText(PIconListItem(Items[Result])^.Identifier,Identifier) then Exit;
Result := -1;
end;

//------------------------------------------------------------------------------

Function TIconList.AddItem(Identifier: String; Data: TStream): Integer;
var
  NewItem:  PIconListItem;
begin
Result := IndexOfItem(Identifier);
If Result < 0 then
  begin
    New(NewItem);
    NewItem^.Identifier := Identifier;
    NewItem^.Icon := TPNGObject.Create;
    NewItem^.Icon.LoadFromStream(Data);
    Result := Add(NewItem);
    If Result < 0 then
      begin
        NewItem^.Icon.Free;
        Dispose(NewItem);
      end;
  end
else PIconListItem(Items[Result])^.Icon.LoadFromStream(Data);
end;

//------------------------------------------------------------------------------

Function TIconList.GetIcon(Identifier: String): TPNGObject;
var
  Index:  Integer;
begin
Index := IndexOfItem(Identifier);
If Index >= 0 then
  Result := ListItems[Index].Icon
else
  begin
    If Count > 0 then Result := ListItems[0].Icon
      else raise Exception.Create('TIconList.GetIcon: Game icons list is empty.');
  end;
end;

//------------------------------------------------------------------------------

procedure TIconList.UpdateFrom(UpdateData: TIconList);
var
  i,Index:  Integer;
  NewItem:  PIconListItem;
begin
For i := 0 to Pred(UpdateData.Count) do
  begin
    Index := IndexOfItem(UpdateData[i].Identifier);
    If Index < 0 then
      begin
        New(NewItem);
        NewItem^.Identifier := UpdateData[i].Identifier;
        NewItem^.Icon := TPNGObject.Create;
        NewItem^.Icon.Assign(UpdateData[i].Icon);
        Index := Add(NewItem);
        If Index < 0 then
          begin
            NewItem^.Icon.Free;
            Dispose(NewItem);
          end;
      end
    else PIconListItem(Items[Index])^.Icon.Assign(UpdateData[i].Icon);
  end;
end;

//------------------------------------------------------------------------------

Function TIconList.CountNoDefault: Integer;
var
  i:  Integer;
begin
Result := 0;
For i := 0 to Pred(Count) do
  If not AnsiSameText(PIconListItem(Items[i])^.Identifier,DefaultGameIconName) then
    Inc(Result);
end;


{==============================================================================}
{------------------------------------------------------------------------------}
{                               TGamesDataManager                              }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TGamesDataManager // Private methods                                       }
{------------------------------------------------------------------------------}

Function TGamesDataManager.GetGamesDataCount: Integer;
begin
Result := Length(fGamesData.Entries);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.GetGameDataPtr(Index: Integer): PGameData;
begin
If (Index >= Low(fGamesData.Entries)) and (Index <= High(fGamesData.Entries)) then
  Result := Addr(fGamesData.Entries[Index])
else
  raise Exception.CreateFmt('TGamesDataManager.GetGamesDataPtr: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.GetGameData(Index: Integer): TGameData;
begin
If (Index >= Low(fGamesData.Entries)) and (Index <= High(fGamesData.Entries)) then
  Result := fGamesData.Entries[Index]
else
  raise Exception.CreateFmt('TGamesDataManager.GetGamesData(Index): Index (%d) out of bounds.',[Index]);
end;

{------------------------------------------------------------------------------}
{   TGamesDataManager // Protected methods                                     }
{------------------------------------------------------------------------------}

class procedure TGamesDataManager.WriteStringToStream(Stream: TStream; const Str: String);
var
  TempStr:  UTF8String;
  TempInt:  Integer;
begin
TempStr := StringToUTF8(Str);
TempInt := Length(TempStr);
Stream.WriteBuffer(TempInt,SizeOf(TempInt));
Stream.WriteBuffer(PAnsiChar(TempStr)^,TempInt);
end;

//------------------------------------------------------------------------------

class procedure TGamesDataManager.ReadStringFromStream(Stream: TStream; out Str: String);
var
  TempStr:  UTF8String;
  TempInt:  Integer;
begin
Stream.ReadBuffer({%H-}TempInt,SizeOf(TempInt));
SetLength(TempStr,TempInt);
Stream.ReadBuffer(PAnsiChar(TempStr)^,TempInt);
Str := UTF8ToString(TempStr);
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.ReadStringFromStream(Stream: TStream): String;
begin
ReadStringFromStream(Stream,Result);
end;

//------------------------------------------------------------------------------

class procedure TGamesDataManager.WriteIntegerToStream(Stream: TStream; Value: Integer);
begin
Stream.WriteBuffer(Value,SizeOf(Integer));
end;

//------------------------------------------------------------------------------

class procedure TGamesDataManager.ReadIntegerFromStream(Stream: TStream; out Value: Integer);
begin
Stream.ReadBuffer({%H-}Value,SizeOf(Integer));
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.ReadIntegerFromStream(Stream: TStream): Integer;
begin
ReadIntegerFromStream(Stream,Result);
end;

//------------------------------------------------------------------------------

class procedure TGamesDataManager.WriteInt64ToStream(Stream: TStream; Value: Int64);
begin
Stream.WriteBuffer(Value,SizeOf(Int64));
end;

//------------------------------------------------------------------------------

class procedure TGamesDataManager.ReadInt64FromStream(Stream: TStream; out Value: Int64);
begin
Stream.ReadBuffer({%H-}Value,SizeOf(Int64));
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.ReadInt64FromStream(Stream: TStream): Int64;
begin
ReadInt64FromStream(Stream,Result);
end;

//------------------------------------------------------------------------------

class procedure TGamesDataManager.WriteFloatToStream(Stream: TStream; Value: Single);
begin
Stream.WriteBuffer(Value,SizeOf(Single));
end;

//------------------------------------------------------------------------------

class procedure TGamesDataManager.ReadFloatFromStream(Stream: TStream; out Value: Single);
begin
Stream.ReadBuffer({%H-}Value,SizeOf(Single));
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.ReadFloatFromStream(Stream: TStream): Single;
begin
ReadFloatFromStream(Stream,Result);
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SaveIcons(Stream: TStream);
var
  WorkStream:   TMemoryStream;
  TempIconItem: TIconListItem;
  i:            Integer;
begin
WriteIntegerToStream(Stream,fGameIcons.CountNoDefault);
WorkStream := TMemoryStream.Create;
try
  For i := 0 to Pred(fGameIcons.Count) do
    If not AnsiSameStr(fGameIcons[i].Identifier,DefaultGameIconName) then
      begin
        WorkStream.Clear;      
        TempIconItem := fGameIcons[i];
        TempIconItem.Icon.SaveToStream(WorkStream);
        WriteStringToStream(Stream,TempIconItem.Identifier);
        WriteIntegerToStream(Stream,Integer(WorkStream.Size));
        Stream.CopyFrom(WorkStream,0);
      end;
finally
  WorkStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.LoadIcons(Stream: TStream);
var
  WorkStream:   TMemoryStream;
  Identifier:   String;
  i,ItemsCount: Integer;
  Size:         Integer;
begin
ItemsCount := ReadIntegerFromStream(Stream);
WorkStream := TMemoryStream.Create;
try
  For i := 0 to Pred(ItemsCount) do
    begin
      WorkStream.Clear;
      Identifier := ReadStringFromStream(Stream);
      Size := ReadIntegerFromStream(Stream);
      WorkStream.CopyFrom(Stream,Size);
      WorkStream.Position := 0;
      fGameIcons.AddItem(Identifier,WorkStream);
    end;
finally
  WorkStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SaveIcons(Ini: TCustomIniFile);
var
  Index,i,j:    Integer;
  WorkStream:   TMemoryStream;
  SectionName:  String;
  EncodedStr:   AnsiString;
  DataCount:    Integer;
begin
Index := 0;
WorkStream := TMemoryStream.Create;
try
  For i := 0 to Pred(fGameIcons.Count) do
    If not AnsiSameStr(fGameIcons[i].Identifier,DefaultGameIconName) then
      begin
        WorkStream.Clear;
        SectionName := Format(GDIN_Icon,[Index]);
        If Ini.SectionExists(SectionName) then
          Ini.EraseSection(SectionName);
        fGameIcons[i].Icon.SaveToStream(WorkStream);
        EncodedStr := AnsiEncode_Base85(WorkStream.Memory,WorkStream.Size,False,True,True);
        DataCount := Ceil(Length(EncodedStr) / INI_ICON_DATA_SplitLength);
        Ini.WriteString(SectionName,GDIN_IC_Name,fGameIcons[i].Identifier);
        Ini.WriteInteger(SectionName,GDIN_IC_DataCount,DataCount);
        For j := 0 to Pred(DataCount) do
          Ini.WriteString(SectionName,Format(GDIN_IC_Data,[j]),Copy(EncodedStr,(j * INI_ICON_DATA_SplitLength) + 1,INI_ICON_DATA_SplitLength));
        Inc(Index);
      end;
finally
  WorkStream.Free;
end;
If Ini.SectionExists(Format(GDIN_Icon,[fGameIcons.Count])) then
  Ini.EraseSection(Format(GDIN_Icon,[fGameIcons.Count]));
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.LoadIcons(Ini: TCustomIniFile);
var
  Index,i:      Integer;
  WorkStream:   TMemoryStream;
  SectionName:  String;
  EncodedStr:   AnsiString;
  IconName:     String;
  DataCount:    Integer;
begin
Index := 0;
WorkStream := TMemoryStream.Create;
try
  while Ini.SectionExists(Format(GDIN_Icon,[Index])) do
    begin
      SectionName := Format(GDIN_Icon,[Index]);
      IconName := Ini.ReadString(SectionName,GDIN_IC_Name,'');
      DataCount := Ini.ReadInteger(SectionName,GDIN_IC_DataCount,-1);
      If (IconName <> '') and (DataCount > 0) then
        begin
          EncodedStr := '';
          For i := 0 to Pred(DataCount) do
            EncodedStr := EncodedStr + Ini.ReadString(SectionName,Format(GDIN_IC_Data,[i]),'');
          try
            WorkStream.Clear;
            WorkStream.Size := AnsiDecodedLength_Base85(EncodedStr);
            WorkStream.Size := AnsiDecode_Base85(EncodedStr,WorkStream.Memory,WorkStream.Size,False);
            WorkStream.Position := 0;
            If WorkStream.Size > 0 then
              fGameIcons.AddItem(IconName,WorkStream);
          except
            Inc(Index);
            Continue;
          end;
        end;
      Inc(Index);
    end;
finally
  WorkStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SaveEntryToIni_Struct00010000(Ini: TCustomIniFile; Section: String; const GameData: TGameData);
var
  TempStr:  String;
  i:        Integer;

  procedure AddModuleToStr(var Str: String; Module: TModuleData);
  begin
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Str := Str + '$' + IntToHex(Module.Size,8) + '%';
    Str := Str + '$' + IntToHex(Module.CRC32,8) + '@' + Module.FileName;
  end;

  procedure WritePointer(const ValueName: String; Pointer: TPointerData);
  var
    iTempStr: String;
    ii:       Integer;
  begin
    If Pointer.ModuleIndex >= 0 then
      begin
        If TPtrInfoRec(Pointer.PtrInfo).PtrType = PTR_TYPE_FloatCorrectedRemote then
          ii := (TPtrInfoRec(Pointer.PtrInfo).PtrData + $100) and $1FF
        else
          ii := 0;
        iTempStr := '$' + IntToHex(ii,3) + '@' + '$' + IntToHex(Pointer.ModuleIndex,1) + '+';
        For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
          iTempStr := iTempStr + '$' + IntToHex(Pointer.Offsets[ii],16) + '>';
        iTempStr := iTempStr + SingleToHex(Pointer.Coefficient);
        Ini.WriteString(Section,ValueName,iTempStr);
      end
    else Ini.WriteString(Section,ValueName,'0');
  end;

begin
Ini.WriteString(Section,GDIN_GD_LEG_Identificator,GameData.Descriptor);
Ini.WriteString(Section,GDIN_GD_LEG_GameInfo,GameData.Title + '&&' + GameData.Info);

TempStr := '$0^';
For i := Low(GameData.Modules) to High(GameData.Modules) do
  begin
    AddModuleToStr(TempStr,GameData.Modules[i]);
    If i < High(GameData.Modules) then TempStr := TempStr + '&';
  end;
Ini.WriteString(Section,GDIN_GD_LEG_Process,TempStr);

WritePointer(GDIN_GD_CCStatus,GameData.CCStatus);
WritePointer(GDIN_GD_CCSpeed,GameData.CCSpeed);
WritePointer(GDIN_GD_TruckSpeed,GameData.TruckSpeed);
For i := Low(GameData.Values) to High(GameData.Values) do
  WritePointer(Format(GDIN_GD_LEG_Special,[i]),GameData.Values[i]);
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SaveEntryToIni_Struct00020000(Ini: TCustomIniFile; Section: String; const GameData: TGameData);
var
  FormatSettings: TFormatSettings;
  i:              Integer;
  
  procedure WriteModule(const Prefix: String; Module: TModuleData);
  begin
    Ini.WriteString(Section,Prefix + GDIN_GD_MOD_CheckFlags,'$' + IntToHex(Module.CheckFlags,8));
      Ini.WriteString(Section,Prefix + GDIN_GD_MOD_FileName,Module.FileName);
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Ini.WriteInteger(Section,Prefix + GDIN_GD_MOD_Size,Integer(Module.Size));
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      Ini.WriteString(Section,Prefix + GDIN_GD_MOD_CRC32,'$' + CRC32ToStr(Module.CRC32));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      Ini.WriteString(Section,Prefix + GDIN_GD_MOD_MD5,MD5ToStr(Module.MD5));
  end;

  procedure WritePointer(const Prefix: String; Pointer: TPointerData);
  var
    TempFlags:  LongWord;
    ii:         Integer;
  begin
    TempFlags := Pointer.Flags shl 9;
    If TPtrInfoRec(Pointer.PtrInfo).PtrType = PTR_TYPE_FloatCorrectedRemote then
      TempFlags := TempFlags or LongWord((TPtrInfoRec(Pointer.PtrInfo).PtrData + $100) and $1FF);
    If Pointer.ModuleIndex < 0 then
      begin
        If Pointer.Flags <> 0 then
          Ini.WriteString(Section,Prefix + GDIN_GD_VAL_Flags,'$' + IntToHex(TempFlags,8));
      end
    else
      begin
        Ini.WriteString(Section,Prefix + GDIN_GD_VAL_Flags,'$' + IntToHex(TempFlags,8));
        Ini.WriteInteger(Section,Prefix + GDIN_GD_VAL_ModuleIndex,Pointer.ModuleIndex);
        Ini.WriteInteger(Section,Prefix + GDIN_GD_VAL_Offsets,Length(Pointer.Offsets));
        For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
          Ini.WriteString(Section,Prefix + Format(GDIN_GD_VAL_Offset,[ii]),'$' + IntToHex(Pointer.Offsets[ii],16));
        Ini.WriteString(Section,Prefix + GDIN_GD_VAL_Coefficient,'$' + SingleToHex(Pointer.Coefficient));
      end;
  end;

begin
Ini.WriteInteger(Section,GDIN_GD_Protocol,Integer(GameData.Protocol));
Ini.WriteString(Section,GDIN_GD_Identifier,GUIDToString(GameData.Identifier));
Ini.WriteString(Section,GDIN_GD_Descriptor,GameData.Descriptor);
Ini.WriteInteger(Section,GDIN_GD_Version,Integer(GameData.Version));
Ini.WriteString(Section,GDIN_GD_Icon,GameData.Icon);
{%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,{%H-}FormatSettings);
FormatSettings.DateSeparator := '-';
FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
Ini.WriteString(Section,GDIN_GD_Date,DateToStr(GameData.Date,FormatSettings));
Ini.WriteString(Section,GDIN_GD_Author,GameData.Author);
Ini.WriteString(Section,GDIN_GD_Title,GameData.Title);
Ini.WriteString(Section,GDIN_GD_Info,GameData.Info);
Ini.WriteString(Section,GDIN_GD_ExtendedTitle,GameData.ExtendedTitle);

Ini.WriteInteger(Section,GDIN_GD_Modules,Length(GameData.Modules));
For i := Low(GameData.Modules) to High(GameData.Modules) do
  WriteModule(Format(GDIN_GD_Module,[i]),GameData.Modules[i]);

WritePointer(GDIN_GD_CCSpeed,GameData.CCSpeed);
WritePointer(GDIN_GD_CCStatus,GameData.CCStatus);
WritePointer(GDIN_GD_TruckSpeed,GameData.TruckSpeed);
Ini.WriteInteger(Section,GDIN_GD_Values,Length(GameData.Values));
For i := Low(GameData.Values) to High(GameData.Values) do
  WritePointer(Format(GDIN_GD_Value,[i]),GameData.Values[i]);
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SaveEntryToIni_Struct00020001(Ini: TCustomIniFile; Section: String; const GameData: TGameData);
var
  FormatSettings: TFormatSettings;
  i:              Integer;
  
  procedure WriteModule(const Prefix: String; Module: TModuleData);
  begin
    Ini.WriteString(Section,Prefix + GDIN_GD_MOD_CheckFlags,'$' + IntToHex(Module.CheckFlags,8));
      Ini.WriteString(Section,Prefix + GDIN_GD_MOD_FileName,Module.FileName);
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Ini.WriteInteger(Section,Prefix + GDIN_GD_MOD_Size,Integer(Module.Size));
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      Ini.WriteString(Section,Prefix + GDIN_GD_MOD_CRC32,'$' + CRC32ToStr(Module.CRC32));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      Ini.WriteString(Section,Prefix + GDIN_GD_MOD_MD5,MD5ToStr(Module.MD5));
  end;

  procedure WritePointer(const Prefix: String; Pointer: TPointerData);
  var
    ii: Integer;
  begin
    If Pointer.ModuleIndex < 0 then
      begin
        If Pointer.Flags <> 0 then
          Ini.WriteString(Section,Prefix + GDIN_GD_VAL_Flags,'$' + IntToHex(Pointer.Flags,8));
      end
    else
      begin
        Ini.WriteString(Section,Prefix + GDIN_GD_VAL_Flags,'$' + IntToHex(Pointer.Flags,8));
        Ini.WriteString(Section,Prefix + GDIN_GD_VAL_PtrInfo,'$' + IntToHex(Pointer.PtrInfo,8));
        Ini.WriteInteger(Section,Prefix + GDIN_GD_VAL_ModuleIndex,Pointer.ModuleIndex);
        Ini.WriteInteger(Section,Prefix + GDIN_GD_VAL_Offsets,Length(Pointer.Offsets));
        For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
          Ini.WriteString(Section,Prefix + Format(GDIN_GD_VAL_Offset,[ii]),'$' + IntToHex(Pointer.Offsets[ii],16));
        Ini.WriteString(Section,Prefix + GDIN_GD_VAL_Coefficient,'$' + SingleToHex(Pointer.Coefficient));
      end;
  end;

begin
Ini.WriteInteger(Section,GDIN_GD_Protocol,Integer(GameData.Protocol));
Ini.WriteString(Section,GDIN_GD_Identifier,GUIDToString(GameData.Identifier));
Ini.WriteString(Section,GDIN_GD_Descriptor,GameData.Descriptor);
Ini.WriteInteger(Section,GDIN_GD_Version,Integer(GameData.Version));
Ini.WriteString(Section,GDIN_GD_Icon,GameData.Icon);
{%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,{%H-}FormatSettings);
FormatSettings.DateSeparator := '-';
FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
Ini.WriteString(Section,GDIN_GD_Date,DateToStr(GameData.Date,FormatSettings));
Ini.WriteString(Section,GDIN_GD_Author,GameData.Author);
Ini.WriteString(Section,GDIN_GD_Title,GameData.Title);
Ini.WriteString(Section,GDIN_GD_Info,GameData.Info);
Ini.WriteString(Section,GDIN_GD_ExtendedTitle,GameData.ExtendedTitle);

Ini.WriteInteger(Section,GDIN_GD_Modules,Length(GameData.Modules));
For i := Low(GameData.Modules) to High(GameData.Modules) do
  WriteModule(Format(GDIN_GD_Module,[i]),GameData.Modules[i]);

WritePointer(GDIN_GD_CCSpeed,GameData.CCSpeed);
WritePointer(GDIN_GD_CCStatus,GameData.CCStatus);
WritePointer(GDIN_GD_TruckSpeed,GameData.TruckSpeed);
Ini.WriteInteger(Section,GDIN_GD_Values,Length(GameData.Values));
For i := Low(GameData.Values) to High(GameData.Values) do
  WritePointer(Format(GDIN_GD_Value,[i]),GameData.Values[i]);
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SaveEntryToBin_Struct00010000(Stream: TStream; Position: Int64; const GameData: TGameData);
var
  EntryStream:  TMemoryStream;
  i:            Integer;

  procedure WriteModule(EnStream: TStream; Module: TModuleData);
  begin
    WriteIntegerToStream(EnStream,Integer(Module.CheckFlags));
    WriteStringToStream(EnStream,Module.FileName);
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      WriteInt64ToStream(EnStream,Module.Size);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      EnStream.WriteBuffer(Module.CRC32,SizeOf(TCRC32));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      EnStream.WriteBuffer(Module.MD5,SizeOf(TMD5Hash));
  end;

  procedure WritePointer(EnStream: TStream; Pointer: TPointerData);
  var
    TempFlags:  LongWord;
    ii:         Integer;
  begin
    TempFlags := Pointer.Flags shl 9;
    If TPtrInfoRec(Pointer.PtrInfo).PtrType = PTR_TYPE_FloatCorrectedRemote then
      TempFlags := TempFlags or LongWord((TPtrInfoRec(Pointer.PtrInfo).PtrData + $100) and $1FF);
    WriteIntegerToStream(EnStream,Integer(TempFlags));
    WriteIntegerToStream(EnStream,Pointer.ModuleIndex);
    WriteIntegerToStream(EnStream,Length(Pointer.Offsets));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      WriteInt64ToStream(EnStream,Pointer.Offsets[ii]);
    WriteFloatToStream(EnStream,Pointer.Coefficient);
  end;

begin
Stream.Seek(Position,soBeginning);
EntryStream := TMemoryStream.Create;
try
  WriteIntegerToStream(EntryStream,Integer(GameData.Protocol));
  EntryStream.WriteBuffer(GameData.Identifier,SizeOf(TGUID));
  WriteStringToStream(EntryStream,GameData.Descriptor);
  WriteIntegerToStream(EntryStream,Integer(GameData.Version));
  WriteStringToStream(EntryStream,GameData.Icon);
  WriteInt64ToStream(EntryStream,DateTimeToUnix(GameData.Date));
  WriteStringToStream(EntryStream,GameData.Author);
  WriteStringToStream(EntryStream,GameData.Title);
  WriteStringToStream(EntryStream,GameData.Info);
  WriteStringToStream(EntryStream,GameData.ExtendedTitle);

  WriteIntegerToStream(EntryStream,Length(GameData.Modules));
  For i := Low(GameData.Modules) to High(GameData.Modules) do
    WriteModule(EntryStream,GameData.Modules[i]);

  WritePointer(EntryStream,GameData.CCSpeed);
  WritePointer(EntryStream,GameData.CCStatus);
  WritePointer(EntryStream,GameData.TruckSpeed);
  WriteIntegerToStream(EntryStream,Length(GameData.Values));
  For i := Low(GameData.Values) to High(GameData.Values) do
    WritePointer(EntryStream,GameData.Values[i]);

  ZCompressStream(EntryStream);
  WriteIntegerToStream(Stream,Integer(EntryStream.Size));
  Stream.CopyFrom(EntryStream,0);
finally
  EntryStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SaveEntryToBin_Struct00010001(Stream: TStream; Position: Int64; const GameData: TGameData);
var
  EntryStream:  TMemoryStream;
  i:            Integer;

  procedure WriteModule(EnStream: TStream; Module: TModuleData);
  begin
    WriteIntegerToStream(EnStream,Integer(Module.CheckFlags));
    WriteStringToStream(EnStream,Module.FileName);
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      WriteInt64ToStream(EnStream,Module.Size);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      EnStream.WriteBuffer(Module.CRC32,SizeOf(TCRC32));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      EnStream.WriteBuffer(Module.MD5,SizeOf(TMD5Hash));
  end;

  procedure WritePointer(EnStream: TStream; Pointer: TPointerData);
  var
    ii: Integer;
  begin
    WriteIntegerToStream(EnStream,Integer(Pointer.Flags));
    WriteIntegerToStream(EnStream,Integer(Pointer.PtrInfo));
    WriteIntegerToStream(EnStream,Pointer.ModuleIndex);
    WriteIntegerToStream(EnStream,Length(Pointer.Offsets));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      WriteInt64ToStream(EnStream,Pointer.Offsets[ii]);
    WriteFloatToStream(EnStream,Pointer.Coefficient);
  end;

begin
Stream.Seek(Position,soBeginning);
EntryStream := TMemoryStream.Create;
try
  WriteIntegerToStream(EntryStream,Integer(GameData.Protocol));
  EntryStream.WriteBuffer(GameData.Identifier,SizeOf(TGUID));
  WriteStringToStream(EntryStream,GameData.Descriptor);
  WriteIntegerToStream(EntryStream,Integer(GameData.Version));
  WriteStringToStream(EntryStream,GameData.Icon);
  WriteInt64ToStream(EntryStream,DateTimeToUnix(GameData.Date));
  WriteStringToStream(EntryStream,GameData.Author);
  WriteStringToStream(EntryStream,GameData.Title);
  WriteStringToStream(EntryStream,GameData.Info);
  WriteStringToStream(EntryStream,GameData.ExtendedTitle);

  WriteIntegerToStream(EntryStream,Length(GameData.Modules));
  For i := Low(GameData.Modules) to High(GameData.Modules) do
    WriteModule(EntryStream,GameData.Modules[i]);

  WritePointer(EntryStream,GameData.CCSpeed);
  WritePointer(EntryStream,GameData.CCStatus);
  WritePointer(EntryStream,GameData.TruckSpeed);
  WriteIntegerToStream(EntryStream,Length(GameData.Values));
  For i := Low(GameData.Values) to High(GameData.Values) do
    WritePointer(EntryStream,GameData.Values[i]);

  ZCompressStream(EntryStream);
  WriteIntegerToStream(Stream,Integer(EntryStream.Size));
  Stream.CopyFrom(EntryStream,0);
finally
  EntryStream.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.PointerTypeCorrection(var Pointer: TPointerData; Bool: Boolean = False);
begin
If Bool then
  begin
    TPtrInfoRec(Pointer.PtrInfo).PtrType := PTR_TYPE_Bool;
    TPtrInfoRec(Pointer.PtrInfo).PtrData := 0;
  end
else
  begin
    If TPtrInfoRec(Pointer.PtrInfo).PtrData <> 0 then
      begin
        TPtrInfoRec(Pointer.PtrInfo).PtrType := PTR_TYPE_FloatCorrectedRemote;
        TPtrInfoRec(Pointer.PtrInfo).PtrData := TPtrInfoRec(Pointer.PtrInfo).PtrData - $100;
      end
    else
      begin
        TPtrInfoRec(Pointer.PtrInfo).PtrType := PTR_TYPE_FloatCorrected;
        TPtrInfoRec(Pointer.PtrInfo).PtrData := 0;
      end;
  end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadEntryFromIni_Struct00010000(Ini: TCustomIniFile; Section: String; out GameData: TGameData): Boolean;
var
  i:        Integer;
  TempStr:  String;

  Function Decrypt(const Text: String): String;
  begin
    If Length(Text) > 0 then
      begin
        If Text[1] = StringEncryptionUnit.EncryptedChar then
          Result := StringEncryptionUnit.DecryptString(Text)
        else
          Result := Text;
      end
    else Result := Text;
  end;

  procedure ParseInfo(const Text: String);
  begin
    GameData.Title := AnsiLeftStr(Text,AnsiPos('&&',Text) - 1);
    GameData.Info := AnsiRightStr(Text,Length(Text) - AnsiPos('&&',Text) - 1);
  end;

  Function ParseProcess(Text: String): Boolean;
  var
    ii,Counter: Integer;
    iTempStr:   String;

    Function ParseModule(ModText: String; var Module: TModuleData; MainModule: Boolean): Boolean;
    begin
      If Length(ModText) > 0 then
        try
          Module.CheckFlags := CF_FILECRC32;
          If AnsiContainsStr(ModText,'%') then
            begin
              Module.CheckFlags := Module.CheckFlags or CF_FILESIZE;
              Module.Size := StrToInt(AnsiLeftStr(ModText,AnsiPos('%',ModText) - 1));
              Delete(ModText,1,AnsiPos('%',ModText));
            end
          else Module.Size := 0;
          Module.CRC32 := TCRC32(StrToInt(AnsiLeftStr(ModText,AnsiPos('@',ModText) - 1)));
          Delete(ModText,1,AnsiPos('@',ModText));
          Module.FileName := ExtractFileName(ModText);
          Module.MD5 := StrToMD5('00000000000000000000000000000000');
          Result := (ExtractFilePath(ModText) = '') or not MainModule;
        except
          Result := False;
        end
      else Result := False;
    end;

  begin
    If Length(Text) > 0 then
      try
        Result := False;
        Text := Text + '&';
        Delete(Text,1,AnsiPos('^',Text));
        Counter := 0;
        For ii := 1 to Length(Text) do
          If Text[ii] = '&' then Inc(Counter);
        SetLength(GameData.Modules,Counter);
        For ii := Low(GameData.Modules) to High(GameData.Modules) do
          begin
            iTempStr := AnsiLeftStr(Text,AnsiPos('&',Text) - 1);
            Delete(Text,1,AnsiPos('&',Text));
            If not ParseModule(iTempStr,GameData.Modules[ii],ii = Low(GameData.Modules)) then Exit;
          end;
        Result := True;  
      except
        Result := False;
      end
    else Result := False;
  end;

  Function ParsePointer(Text: String; var Pointer: TPointerData): Boolean;
  var
    ii,Counter:  Integer;
  begin
    If Length(Text) > 0 then
      try
        Result := False;
        Pointer.Flags := 0;
        TPtrInfoRec(Pointer.PtrInfo).PtrData := LongWord(StrToInt(AnsiLeftStr(Text,AnsiPos('@',Text) - 1)) and $1FF);
        Delete(Text,1,AnsiPos('@',Text));
        Pointer.ModuleIndex := StrToInt(AnsiLeftStr(Text,AnsiPos('+',Text) - 1));
        Delete(Text,1,AnsiPos('+',Text));
        Counter := 0;
        For ii := 1 to Length(Text) do
          If Text[ii] = '>' then Inc(Counter);
        SetLength(Pointer.Offsets,Counter);
        For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
          begin
            Pointer.Offsets[ii] := StrToInt(AnsiLeftStr(Text,AnsiPos('>',Text) - 1));
            Delete(Text,1,AnsiPos('>',Text));
          end;
        Pointer.Coefficient := HexToSingleDef(Text,0);
        If Pointer.Coefficient = 0 then Exit;
        Result := True;
      except
        Result := False;
      end
    else Result := False;
  end;

begin
try
  Result := False;
  GameData.Protocol := SupportedProtocolVersions[Low(SupportedProtocolVersions)];
  If CreateGUID(GameData.Identifier) <> S_OK then
    GameData.Identifier := StringToGUID('{00000000-0000-0000-0000-000000000000}');
  GameData.Descriptor := Decrypt(Ini.ReadString(Section,GDIN_GD_LEG_Identificator,''));
  GameData.Version := 0;
  GameData.Icon := DefaultGameIconName;
  GameData.Date := Now;
  GameData.Author := '';
  ParseInfo(Decrypt(Ini.ReadString(Section,GDIN_GD_LEG_GameInfo,'')));
  GameData.ExtendedTitle := GameData.Title;
  If not ParseProcess(Decrypt(Ini.ReadString(Section,GDIN_GD_LEG_Process,''))) then Exit;
  If not ParsePointer(Decrypt(Ini.ReadString(Section,GDIN_GD_CCStatus,'')),GameData.CCStatus) then Exit;
  PointerTypeCorrection(GameData.CCStatus,True);
  If not ParsePointer(Decrypt(Ini.ReadString(Section,GDIN_GD_CCSpeed,'')),GameData.CCSpeed) then Exit;
  PointerTypeCorrection(GameData.CCSpeed);
  TempStr := Decrypt(Ini.ReadString(Section,GDIN_GD_TruckSpeed,''));
  If TempStr <> '0' then
    begin
      If not ParsePointer(TempStr,GameData.TruckSpeed) then Exit;
      PointerTypeCorrection(GameData.TruckSpeed);
    end
  else
    begin
      GameData.TruckSpeed.Flags := 0;
      GameData.TruckSpeed.ModuleIndex := -1;
      SetLength(GameData.TruckSpeed.Offsets,0);
      GameData.TruckSpeed.Coefficient := 0;
    end;
  i := 0;
  while Ini.ValueExists(Section,Format(GDIN_GD_LEG_Special,[i])) do
    begin
      SetLength(GameData.Values,Length(GameData.Values) + 1);
      If not ParsePointer(Decrypt(Ini.ReadString(Section,Format(GDIN_GD_LEG_Special,[i]),'')),GameData.Values[i]) then Exit;
      PointerTypeCorrection(GameData.Values[i]);
      Inc(i);
    end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadEntryFromIni_Struct00020000(Ini: TCustomIniFile; Section: String; out GameData: TGameData): Boolean;
var
  FormatSettings: TFormatSettings;
  i:              Integer;

  procedure ReadModule(const Prefix: String; var Module: TModuleData);
  begin
    Module.CheckFlags := LongWord(Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_CheckFlags,CF_NONE));
    Module.FileName := Ini.ReadString(Section,Prefix + GDIN_GD_MOD_FileName,'');
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Module.Size := Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_Size,0);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      Module.CRC32 := TCRC32(Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_CRC32,0));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      Module.MD5 := StrToMD5(Ini.ReadString(Section,Prefix + GDIN_GD_MOD_MD5,'00000000000000000000000000000000'));
  end;

  procedure ReadPointer(const Prefix: String; var Pointer: TPointerData);
  var
    TempFlags:  LongWord;
    ii:         Integer;
  begin
    TempFlags := LongWord(Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_Flags,CF_NONE));
    Pointer.Flags := TempFlags shr 9;
    TPtrInfoRec(Pointer.PtrInfo).PtrData := TempFlags and $1FF;
    Pointer.ModuleIndex := Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_ModuleIndex,-1);
    SetLength(Pointer.Offsets,Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_Offsets,0));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      Pointer.Offsets[ii] := StrToInt64(Ini.ReadString(Section,Prefix + Format(GDIN_GD_VAL_Offset,[ii]),'0'));
    Pointer.Coefficient := HexToSingle(Ini.ReadString(Section,Prefix + GDIN_GD_VAL_Coefficient,'0'));
  end;

begin
try
  GameData.Protocol := TProtocolVersion(Ini.ReadInteger(Section,GDIN_GD_Protocol,Integer(InvalidProtocolVersion)));
  GameData.Identifier := StringToGUID(Ini.ReadString(Section,GDIN_GD_Identifier,'{00000000-0000-0000-0000-000000000000}'));
  GameData.Descriptor := Ini.ReadString(Section,GDIN_GD_Descriptor,'');
  GameData.Version := LongWord(Ini.ReadInteger(Section,GDIN_GD_Version,0));
  GameData.Icon := Ini.ReadString(Section,GDIN_GD_Icon,DefaultGameIconName);
  {%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,{%H-}FormatSettings);
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  GameData.Date := StrToDateDef(Ini.ReadString(Section,GDIN_GD_Date,''),Now,FormatSettings);
  GameData.Author := Ini.ReadString(Section,GDIN_GD_Author,'');
  GameData.Title := Ini.ReadString(Section,GDIN_GD_Title,'');
  GameData.Info := Ini.ReadString(Section,GDIN_GD_Info,'');
  GameData.ExtendedTitle := Ini.ReadString(Section,GDIN_GD_ExtendedTitle,'');

  SetLength(GameData.Modules,Ini.ReadInteger(Section,GDIN_GD_Modules,0));
  For i := Low(GameData.Modules) to High(GameData.Modules) do
    ReadModule(Format(GDIN_GD_Module,[i]),GameData.Modules[i]);

  ReadPointer(GDIN_GD_CCSpeed,GameData.CCSpeed);
  PointerTypeCorrection(GameData.CCSpeed);
  ReadPointer(GDIN_GD_CCStatus,GameData.CCStatus);
  PointerTypeCorrection(GameData.CCStatus,True);
  ReadPointer(GDIN_GD_TruckSpeed,GameData.TruckSpeed);
  PointerTypeCorrection(GameData.TruckSpeed);
  SetLength(GameData.Values,Ini.ReadInteger(Section,GDIN_GD_Values,0));
  For i := Low(GameData.Values) to High(GameData.Values) do
    begin
      ReadPointer(Format(GDIN_GD_Value,[i]),GameData.Values[i]);
      PointerTypeCorrection(GameData.Values[i]);
    end;

  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadEntryFromIni_Struct00020001(Ini: TCustomIniFile; Section: String; out GameData: TGameData): Boolean;
var
  FormatSettings: TFormatSettings;
  i:              Integer;

  procedure ReadModule(const Prefix: String; var Module: TModuleData);
  begin
    Module.CheckFlags := LongWord(Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_CheckFlags,CF_NONE));
    Module.FileName := Ini.ReadString(Section,Prefix + GDIN_GD_MOD_FileName,'');
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Module.Size := Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_Size,0);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      Module.CRC32 := TCRC32(Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_CRC32,0));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      Module.MD5 := StrToMD5(Ini.ReadString(Section,Prefix + GDIN_GD_MOD_MD5,'00000000000000000000000000000000'));
  end;

  procedure ReadPointer(const Prefix: String; var Pointer: TPointerData);
  var
    ii: Integer;
  begin
    Pointer.Flags := LongWord(Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_Flags,CF_NONE));
    Pointer.PtrInfo := LongWord(Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_PtrInfo,Integer(PTR_TYPE_Invalid)));
    Pointer.ModuleIndex := Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_ModuleIndex,-1);
    SetLength(Pointer.Offsets,Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_Offsets,0));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      Pointer.Offsets[ii] := StrToInt64(Ini.ReadString(Section,Prefix + Format(GDIN_GD_VAL_Offset,[ii]),'0'));
    Pointer.Coefficient := HexToSingle(Ini.ReadString(Section,Prefix + GDIN_GD_VAL_Coefficient,'0'));
  end;

begin
try
  GameData.Protocol := TProtocolVersion(Ini.ReadInteger(Section,GDIN_GD_Protocol,Integer(InvalidProtocolVersion)));
  GameData.Identifier := StringToGUID(Ini.ReadString(Section,GDIN_GD_Identifier,'{00000000-0000-0000-0000-000000000000}'));
  GameData.Descriptor := Ini.ReadString(Section,GDIN_GD_Descriptor,'');
  GameData.Version := LongWord(Ini.ReadInteger(Section,GDIN_GD_Version,0));
  GameData.Icon := Ini.ReadString(Section,GDIN_GD_Icon,DefaultGameIconName);
  {%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,{%H-}FormatSettings);
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  GameData.Date := StrToDateDef(Ini.ReadString(Section,GDIN_GD_Date,''),Now,FormatSettings);
  GameData.Author := Ini.ReadString(Section,GDIN_GD_Author,'');
  GameData.Title := Ini.ReadString(Section,GDIN_GD_Title,'');
  GameData.Info := Ini.ReadString(Section,GDIN_GD_Info,'');
  GameData.ExtendedTitle := Ini.ReadString(Section,GDIN_GD_ExtendedTitle,'');

  SetLength(GameData.Modules,Ini.ReadInteger(Section,GDIN_GD_Modules,0));
  For i := Low(GameData.Modules) to High(GameData.Modules) do
    ReadModule(Format(GDIN_GD_Module,[i]),GameData.Modules[i]);

  ReadPointer(GDIN_GD_CCSpeed,GameData.CCSpeed);
  ReadPointer(GDIN_GD_CCStatus,GameData.CCStatus);
  ReadPointer(GDIN_GD_TruckSpeed,GameData.TruckSpeed);
  SetLength(GameData.Values,Ini.ReadInteger(Section,GDIN_GD_Values,0));
  For i := Low(GameData.Values) to High(GameData.Values) do
    ReadPointer(Format(GDIN_GD_Value,[i]),GameData.Values[i]);

  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadEntryFromBin_Struct00010000(Stream: TStream; Position: Int64; out GameData: TGameData): Boolean;
var
  EntryStream:  TMemoryStream;
  i:            Integer;

  procedure ReadModule(EnStream: TStream; var Module: TModuleData);
  begin
    Module.CheckFlags := LongWord(ReadIntegerFromStream(EnStream));
    Module.FileName := ReadStringFromStream(EnStream);
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Module.Size := ReadInt64FromStream(EnStream);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      EnStream.ReadBuffer(Module.CRC32,SizeOf(TCRC32));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      EnStream.ReadBuffer(Module.MD5,SizeOf(TMD5Hash));
  end;

  procedure ReadPointer(EnStream: TStream; var Pointer: TPointerData);
  var
    TempFlags:  LongWord;
    ii:         Integer;
  begin
    TempFlags := LongWord(ReadIntegerFromStream(EnStream));
    Pointer.Flags := TempFlags shr 9;
    TPtrInfoRec(Pointer.PtrInfo).PtrData := TempFlags and $1FF;
    Pointer.ModuleIndex := ReadIntegerFromStream(EnStream);
    SetLength(Pointer.Offsets,ReadIntegerFromStream(EnStream));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      Pointer.Offsets[ii] := ReadInt64FromStream(EnStream);
    Pointer.Coefficient := ReadFloatFromStream(EnStream);
  end;

begin
try
  EntryStream := TMemoryStream.Create;
  try
    Stream.Seek(Position,soBeginning);
    EntryStream.CopyFrom(Stream,ReadIntegerFromStream(Stream));
    ZDecompressStream(EntryStream);
    EntryStream.Position := 0;

    GameData.Protocol := TProtocolVersion(ReadIntegerFromStream(EntryStream));
    EntryStream.ReadBuffer(GameData.Identifier,SizeOf(TMD5Hash));
    GameData.Descriptor := ReadStringFromStream(EntryStream);
    GameData.Version := LongWord(ReadIntegerFromStream(EntryStream));
    GameData.Icon := ReadStringFromStream(EntryStream);
    GameData.Date := UnixToDateTime(ReadInt64FromStream(EntryStream));
    GameData.Author := ReadStringFromStream(EntryStream);
    GameData.Title := ReadStringFromStream(EntryStream);
    GameData.Info := ReadStringFromStream(EntryStream);
    GameData.ExtendedTitle := ReadStringFromStream(EntryStream);

    SetLength(GameData.Modules,ReadIntegerFromStream(EntryStream));
    For i := Low(GameData.Modules) to High(GameData.Modules) do
      ReadModule(EntryStream,GameData.Modules[i]);

    ReadPointer(EntryStream,GameData.CCSpeed);
    PointerTypeCorrection(GameData.CCSpeed);
    ReadPointer(EntryStream,GameData.CCStatus);
    PointerTypeCorrection(GameData.CCStatus,True);
    ReadPointer(EntryStream,GameData.TruckSpeed);
    PointerTypeCorrection(GameData.TruckSpeed);
    SetLength(GameData.Values,ReadIntegerFromStream(EntryStream));
    For i := Low(GameData.Values) to High(GameData.Values) do
      begin
        ReadPointer(EntryStream,GameData.Values[i]);
        PointerTypeCorrection(GameData.Values[i]);
      end;

    Result := True;
  finally
    EntryStream.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadEntryFromBin_Struct00010001(Stream: TStream; Position: Int64; out GameData: TGameData): Boolean;
var
  EntryStream:  TMemoryStream;
  i:            Integer;

  procedure ReadModule(EnStream: TStream; var Module: TModuleData);
  begin
    Module.CheckFlags := LongWord(ReadIntegerFromStream(EnStream));
    Module.FileName := ReadStringFromStream(EnStream);
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Module.Size := ReadInt64FromStream(EnStream);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      EnStream.ReadBuffer(Module.CRC32,SizeOf(TCRC32));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      EnStream.ReadBuffer(Module.MD5,SizeOf(TMD5Hash));
  end;

  procedure ReadPointer(EnStream: TStream; var Pointer: TPointerData);
  var
    ii: Integer;
  begin
    Pointer.Flags := LongWord(ReadIntegerFromStream(EnStream));
    Pointer.PtrInfo := LongWord(ReadIntegerFromStream(EnStream));
    Pointer.ModuleIndex := ReadIntegerFromStream(EnStream);
    SetLength(Pointer.Offsets,ReadIntegerFromStream(EnStream));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      Pointer.Offsets[ii] := ReadInt64FromStream(EnStream);
    Pointer.Coefficient := ReadFloatFromStream(EnStream);
  end;

begin
try
  EntryStream := TMemoryStream.Create;
  try
    Stream.Seek(Position,soBeginning);
    EntryStream.CopyFrom(Stream,ReadIntegerFromStream(Stream));
    ZDecompressStream(EntryStream);
    EntryStream.Position := 0;

    GameData.Protocol := TProtocolVersion(ReadIntegerFromStream(EntryStream));
    EntryStream.ReadBuffer(GameData.Identifier,SizeOf(TMD5Hash));
    GameData.Descriptor := ReadStringFromStream(EntryStream);
    GameData.Version := LongWord(ReadIntegerFromStream(EntryStream));
    GameData.Icon := ReadStringFromStream(EntryStream);
    GameData.Date := UnixToDateTime(ReadInt64FromStream(EntryStream));
    GameData.Author := ReadStringFromStream(EntryStream);
    GameData.Title := ReadStringFromStream(EntryStream);
    GameData.Info := ReadStringFromStream(EntryStream);
    GameData.ExtendedTitle := ReadStringFromStream(EntryStream);

    SetLength(GameData.Modules,ReadIntegerFromStream(EntryStream));
    For i := Low(GameData.Modules) to High(GameData.Modules) do
      ReadModule(EntryStream,GameData.Modules[i]);

    ReadPointer(EntryStream,GameData.CCSpeed);
    ReadPointer(EntryStream,GameData.CCStatus);
    ReadPointer(EntryStream,GameData.TruckSpeed);
    SetLength(GameData.Values,ReadIntegerFromStream(EntryStream));
    For i := Low(GameData.Values) to High(GameData.Values) do
      ReadPointer(EntryStream,GameData.Values[i]);

    Result := True;
  finally
    EntryStream.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.SortHiddenForSaving;
var
  i,j:  Integer;
  Temp: TGameData;
begin
For i := Pred(High(fGamesData.Hidden)) downto Low(fGamesData.Hidden) do
  For j := Low(fGamesData.Hidden) to i do
    If Integer(fGamesData.Hidden[j].Protocol) > Integer(fGamesData.Hidden[j + 1].Protocol) then
      begin
        Temp := fGamesData.Hidden[j];
        fGamesData.Hidden[j] := fGamesData.Hidden[j + 1];
        fGamesData.Hidden[j + 1] := Temp;
      end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToIni_Struct00010000(Ini: TCustomIniFile): Boolean;
var
  i:  Integer;
begin
try
  For i := Low(fGamesData.Entries) to High(fGamesData.Entries) do
    SaveEntryToIni_Struct00010000(Ini,Format(GDIN_Game,[i]),fGamesData.Entries[i]);
  If Ini.SectionExists(Format(GDIN_Game,[Length(fGamesData.Entries)])) then
    Ini.EraseSection(Format(GDIN_Game,[Length(fGamesData.Entries)]));
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToIni_Struct00020000(Ini: TCustomIniFile): Boolean;
var
  i:  Integer;
begin
try
  For i := Low(fGamesData.Entries) to High(fGamesData.Entries) do
    begin
      If Ini.SectionExists(Format(GDIN_Game,[i])) then
        Ini.EraseSection(Format(GDIN_Game,[i]));
      SaveEntryToIni_Struct00020000(Ini,Format(GDIN_Game,[i]),fGamesData.Entries[i]);
    end;
  SortHiddenForSaving;
  For i := Low(fGamesData.Hidden) to High(fGamesData.Hidden) do
    begin
      If Ini.SectionExists(Format(GDIN_Game,[i + Length(fGamesData.Entries)])) then
        Ini.EraseSection(Format(GDIN_Game,[i + Length(fGamesData.Entries)]));
      SaveEntryToIni_Struct00020000(Ini,Format(GDIN_Game,[i + Length(fGamesData.Entries)]),fGamesData.Hidden[i]);
    end;
  If Ini.SectionExists(Format(GDIN_Game,[Length(fGamesData.Entries) + Length(fGamesData.Hidden)])) then
    Ini.EraseSection(Format(GDIN_Game,[Length(fGamesData.Entries) + Length(fGamesData.Hidden)]));
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToIni_Struct00020001(Ini: TCustomIniFile): Boolean;
var
  i:  Integer;
begin
try
  SaveIcons(Ini);
  For i := Low(fGamesData.Entries) to High(fGamesData.Entries) do
    begin
      If Ini.SectionExists(Format(GDIN_Game,[i])) then
        Ini.EraseSection(Format(GDIN_Game,[i]));
      SaveEntryToIni_Struct00020001(Ini,Format(GDIN_Game,[i]),fGamesData.Entries[i]);
    end;
  SortHiddenForSaving;
  For i := Low(fGamesData.Hidden) to High(fGamesData.Hidden) do
    begin
      If Ini.SectionExists(Format(GDIN_Game,[i + Length(fGamesData.Entries)])) then
        Ini.EraseSection(Format(GDIN_Game,[i + Length(fGamesData.Entries)]));
      SaveEntryToIni_Struct00020001(Ini,Format(GDIN_Game,[i + Length(fGamesData.Entries)]),fGamesData.Hidden[i]);
    end;
  If Ini.SectionExists(Format(GDIN_Game,[Length(fGamesData.Entries) + Length(fGamesData.Hidden)])) then
    Ini.EraseSection(Format(GDIN_Game,[Length(fGamesData.Entries) + Length(fGamesData.Hidden)]));
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToBin_Struct00010000(Stream: TStream): Boolean;
var
  i:          Integer;
begin
try
  SaveIcons(Stream);
  WriteIntegerToStream(Stream,Length(fGamesData.Entries) + Length(fGamesData.Hidden));
  For i := Low(fGamesData.Entries) to High(fGamesData.Entries) do
    SaveEntryToBin_Struct00010000(Stream,Stream.Position,fGamesData.Entries[i]);
  SortHiddenForSaving;  
  For i := Low(fGamesData.Hidden) to High(fGamesData.Hidden) do
    SaveEntryToBin_Struct00010000(Stream,Stream.Position,fGamesData.Hidden[i]);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToBin_Struct00010001(Stream: TStream): Boolean;
var
  i:          Integer;
begin
try
  SaveIcons(Stream);
  WriteIntegerToStream(Stream,Length(fGamesData.Entries) + Length(fGamesData.Hidden));
  For i := Low(fGamesData.Entries) to High(fGamesData.Entries) do
    SaveEntryToBin_Struct00010001(Stream,Stream.Position,fGamesData.Entries[i]);
  SortHiddenForSaving;  
  For i := Low(fGamesData.Hidden) to High(fGamesData.Hidden) do
    SaveEntryToBin_Struct00010001(Stream,Stream.Position,fGamesData.Hidden[i]);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.ProcessEntryByProtocol(const GameData: TGameData);
var
  i:  Integer;
begin
case GameData.Protocol of
  PROTOCOL_NORMAL:  If not IsHidden(GameData.Identifier) then
                      AddGameData(GameData);
  PROTOCOL_HIDDEN:  AddHiddenGameData(GameData);
  PROTOCOL_HIDE:    begin
                      For i := Low(GameData.Modules) to High(GameData.Modules) do
                        HideGameData(StringToGUID(GameData.Modules[i].FileName));
                      AddHiddenGameData(GameData);
                    end;
  PROTOCOL_UPDHIDE: begin
                      For i := Low(GameData.Modules) to High(GameData.Modules) do
                        HideGameData(StringToGUID(GameData.Modules[i].FileName));
                      AddGameData(GameData);
                    end;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromIni_Struct00010000(Ini: TCustomIniFile): Boolean;
var
  Index:        Integer;
  TempGameData: TGameData;
begin
try
  Index := 0;
  while Ini.SectionExists(Format(GDIN_Game,[Index])) do
    begin
      If LoadEntryFromIni_Struct00010000(Ini,Format(GDIN_Game,[Index]),TempGameData) then
        If IsValid(TempGameData) then ProcessEntryByProtocol(TempGameData);
      Inc(Index);
    end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromIni_Struct00020000(Ini: TCustomIniFile): Boolean;
var
  Index:        Integer;
  TempGameData: TGameData;
begin
try
  Index := 0;
  while Ini.SectionExists(Format(GDIN_Game,[Index])) do
    begin
      If LoadEntryFromIni_Struct00020000(Ini,Format(GDIN_Game,[Index]),TempGameData) then
        If IsValid(TempGameData) then ProcessEntryByProtocol(TempGameData);
      Inc(Index);
    end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromIni_Struct00020001(Ini: TCustomIniFile): Boolean;
var
  Index:        Integer;
  TempGameData: TGameData;
begin
try
  LoadIcons(Ini);
  Index := 0;
  while Ini.SectionExists(Format(GDIN_Game,[Index])) do
    begin
      If LoadEntryFromIni_Struct00020001(Ini,Format(GDIN_Game,[Index]),TempGameData) then
        If IsValid(TempGameData) then ProcessEntryByProtocol(TempGameData);
      Inc(Index);
    end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromBin_Struct00010000(Stream: TStream): Boolean;
var
  i:            Integer;
  TempGameData: TGameData;
begin
try
  LoadIcons(Stream);
  For i := 1 to ReadIntegerFromStream(Stream) do
    If LoadEntryFromBin_Struct00010000(Stream,Stream.Position,TempGameData) then
      If IsValid(TempGameData) then ProcessEntryByProtocol(TempGameData);
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromBin_Struct00010001(Stream: TStream): Boolean;
var
  i:            Integer;
  TempGameData: TGameData;
begin
try
  LoadIcons(Stream);
  For i := 1 to ReadIntegerFromStream(Stream) do
    If LoadEntryFromBin_Struct00010001(Stream,Stream.Position,TempGameData) then
      If IsValid(TempGameData) then ProcessEntryByProtocol(TempGameData);
  Result := True;
except
  Result := False;
end;
end;

{------------------------------------------------------------------------------}
{   TGamesDataManager // Public methods                                        }
{------------------------------------------------------------------------------}

class Function TGamesDataManager.SupportsBinFileStructure(FileStructure: TFileStructure): Boolean;
var
  i:  Integer;
begin
Result := False;
For i := Low(SupportedBinFileStructure) to High(SupportedBinFileStructure) do
  If SupportedBinFileStructure[i] = FileStructure then
    begin
      Result := True;
      Break;
    end;
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.SupportsIniFileStructure(FileStructure: TFileStructure): Boolean;
var
  i:  Integer;
begin
Result := False;
For i := Low(SupportedIniFileStructure) to High(SupportedIniFileStructure) do
  If SupportedIniFileStructure[i] = FileStructure then
    begin
      Result := True;
      Break;
    end;
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.SupportsProtocolVersion(ProtocolVersion: TProtocolVersion): Boolean;
var
  i:  Integer;
begin
Result := False;
For i := Low(SupportedProtocolVersions) to High(SupportedProtocolVersions) do
  If SupportedProtocolVersions[i] = ProtocolVersion then
    begin
      Result := True;
      Break;
    end;
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.IsValid(GameData: TGameData): Boolean;
var
  i:  Integer;

  Function CheckModule(Module: TModuleData): Boolean;
  begin
    Result := (Module.CheckFlags <> CF_NONE) and (Module.FileName <> '') and
              (ExtractFilePath(Module.FileName) = '');
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Result := Result and (Module.Size > 0);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      Result := Result and (Module.CRC32 <> 0);
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      Result := Result and not SameMD5(Module.MD5,ZeroMD5);
  end;

  Function CheckPointer(Pointer: TPointerData): Boolean;
  begin
    Result := (Pointer.ModuleIndex >= Low(GameData.Modules)) and
              (Pointer.ModuleIndex <= High(GameData.Modules));
  end;

begin
Result := SupportsProtocolVersion(GameData.Protocol);
case GameData.Protocol of
  PROTOCOL_NORMAL:
      begin
        Result := Result and not IsEqualGUID(GameData.Identifier,StringToGUID('{00000000-0000-0000-0000-000000000000}'));
        Result := Result and (Length(GameData.Modules) > 0);
        For i := Low(GameData.Modules) to High(GameData.Modules) do
          Result := Result and CheckModule(GameData.Modules[i]);
        Result := Result and CheckPointer(GameData.CCSpeed) and CheckPointer(GameData.CCStatus);
        For i := Low(GameData.Values) to High(GameData.Values) do
          Result := Result and CheckPointer(GameData.Values[i]);
      end;
  PROTOCOL_HIDDEN:
      Result := Result and not IsEqualGUID(GameData.Identifier,StringToGUID('{00000000-0000-0000-0000-000000000000}'));
  PROTOCOL_HIDE,
  PROTOCOL_UPDHIDE:
      begin
        Result := Result and not IsEqualGUID(GameData.Identifier,StringToGUID('{00000000-0000-0000-0000-000000000000}'));
        Result := Result and (Length(GameData.Modules) > 0);
        try
          For i := Low(GameData.Modules) to High(GameData.Modules) do
            StringtoGUID(GameData.Modules[i].FileName);
        except
          Result := False;
        end;
      end;
else
  Result := False;
end;
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.TruckSpeedSupported(const GameData: TGameData): TSupportedSpeedReading;
begin
If (GameData.TruckSpeed.ModuleIndex >= Low(GameData.Modules)) and
   (GameData.TruckSpeed.ModuleIndex <= High(GameData.Modules)) then Result := ssrDirect
  else If (GameData.TruckSpeed.Flags and PTR_FLAGS_TelemetryTruckSpeed) <> 0 then Result := ssrPlugin
    else Result := ssrNone;
end;

//------------------------------------------------------------------------------

constructor TGamesDataManager.Create;
begin
inherited;
SetLength(fGamesData.Entries,0);
SetLength(fGamesData.Hidden,0);
fGameIcons := TIconList.Create;
end;

//------------------------------------------------------------------------------

destructor TGamesDataManager.Destroy;
begin
fGameIcons.Free;
inherited;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.IndexOf(Identifier: TGUID): Integer;
begin
For Result := Low(fGamesData.Entries) to High(fGamesData.Entries) do
  If IsEqualGUID(fGamesData.Entries[Result].Identifier,Identifier) then Exit;
Result := -1;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.GameListed(Identifier: TGUID): Boolean;
begin
Result := IndexOf(Identifier) >= 0;
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.Clear;
begin
SetLength(fGamesData.Entries,0);
SetLength(fGamesData.Hidden,0);
fGameIcons.Initialize;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToBin(const FileName: String; FileStructure: TFileStructure): Boolean;
var
  FileStream: TMemoryStream;
begin
If SupportsBinFileStructure(FileStructure) then
  try
    FileStream := TMemoryStream.Create;
    try
      WriteIntegerToStream(FileStream,ACCBinFileSignature);
      WriteIntegerToStream(FileStream,LongWord(FileStructure));
      case FileStructure of
        BFS_1_0:  Result := SaveToBin_Struct00010000(FileStream);
        BFS_1_1:  Result := SaveToBin_Struct00010001(FileStream);
      else
        Result := False;
      end;
      FileStream.Size := FileStream.Position;
      FileStream.SaveToFile(FileName);
    finally
      FileStream.Free;
    end;
  except
    Result := False;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToIni(const FileName: String; FileStructure: TFileStructure): Boolean;
var
  IniFile:  TMemIniFile;
begin
If SupportsIniFileStructure(FileStructure) then
  try
    IniFile := TMemIniFile.Create(FileName);
    try
      IniFile.WriteString(GDIN_MainSection,GDIN_MS_FileStructure,'$' + IntToHex(FileStructure,8));
      case FileStructure of
        IFS_1_0:  Result := SaveToIni_Struct00010000(IniFile);
        IFS_2_0:  Result := SaveToIni_Struct00020000(IniFile);
        IFS_2_1:  Result := SaveToIni_Struct00020001(IniFile);
      else
        Result := False;
      end;
      IniFile.UpdateFile;
    finally
      IniFile.Free;
    end;
  except
    Result := False;
  end
else Result := False;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromBin(Stream: TStream; out FileStructure: TFileStructure): Boolean;
begin
try
  If ReadIntegerFromStream(Stream) <> ACCBinFileSignature then Abort;
  FileStructure := TFileStructure(ReadIntegerFromStream(Stream));
  If SupportsBinFileStructure(FileStructure) then
    begin
      Clear;
      case FileStructure of
        BFS_1_0:  Result := LoadFromBin_Struct00010000(Stream);
        BFS_1_1:  Result := LoadFromBin_Struct00010001(Stream);
      else
        Result := False;
      end;
    end
  else Result := False;
except
  Result := False;
end;
If not Result then Clear;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromBin(Stream: TStream): Boolean;
var
  FileStructure:  TFileStructure;
begin
Result := LoadFromBin(Stream,FileStructure);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromBin(const FileName: String; out FileStructure: TFileStructure): Boolean;
var
  FileStream: TMemoryStream;
begin
try
  FileStream := TMemoryStream.Create;
  try
    FileStream.LoadFromFile(FileName);
    Result := LoadFromBin(FileStream,FileStructure);
  finally
    FileStream.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromBin(const FileName: String): Boolean;
var
  FileStructure:  TFileStructure;
begin
Result := LoadFromBin(FileName,FileStructure);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromIni(const FileName: String; out FileStructure: TFileStructure): Boolean;
var
  IniFile:  TMemIniFile;
begin
try
  IniFile := TMemIniFile.Create(FileName);
  try
    FileStructure := TFileStructure(IniFile.ReadInteger(GDIN_MainSection,GDIN_MS_FileStructure,Integer(InvalidFileStructure)));
    If SupportsIniFileStructure(FileStructure) then
      begin
        Clear;
        case FileStructure of
          IFS_1_0:  Result := LoadFromIni_Struct00010000(IniFile);
          IFS_2_0:  Result := LoadFromIni_Struct00020000(IniFile);
          IFS_2_1:  Result := LoadFromIni_Struct00020001(IniFile);
        else
          Result := False;
        end;
      end
    else Result := False;
  finally
    IniFile.Free;
  end;
except
  Result := False;
end;
If not Result then Clear;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromIni(const FileName: String): Boolean;
var
  FileStructure:  TFileStructure;
begin
Result := LoadFromIni(FileName,FileStructure);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFrom(const FileName: String): Boolean;
var
  FileStream: TFileStream;
begin
try
  FileStream := TFileStream.Create(FileName,fmOpenRead or fmShareDenyWrite);
  try
    If ReadIntegerFromStream(FileStream) = ACCBinFileSignature then
      Result := LoadFromBin(FileName)
    else
      Result := LoadFromIni(FileName);
  finally
    FileStream.Free;
  end;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.Load: Boolean;
begin
If FileExists(ExtractFilePath(ParamStr(0)) + GamesDataFileIni) then
  Result := LoadFromIni(ExtractFilePath(ParamStr(0)) + GamesDataFileIni)
else
  Result := LoadFromBin(ExtractFilePath(ParamStr(0)) + GamesDataFileBin);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.Save: Boolean;
begin
If FileExists(ExtractFilePath(ParamStr(0)) + GamesDataFileIni) then
  Result := SaveToIni(ExtractFilePath(ParamStr(0)) + GamesDataFileIni,IFS_2_0)
else
  Result := SaveToBin(ExtractFilePath(ParamStr(0)) + GamesDataFileBin,BFS_1_0);
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.CheckUpdate(OldData: TGamesDataManager);
var
  i,Index:      Integer;
  GameDataTemp: PGameData;
begin
For i := Pred(GamesDataCount) downto 0 do
  If OldData.IsHidden(GameData[i].Identifier) then
    HideGameData(GameData[i].Identifier);
For i := 0 to Pred(GamesDataCount) do
  begin
    GameDataTemp := GameDataPtr[i];
    GameDataTemp^.UpdateInfo.Valid := IsValid(GameDataTemp^);
    GameDataTemp^.UpdateInfo.NewEntry := False;
    GameDataTemp^.UpdateInfo.NewVersion := False;
    GameDataTemp^.UpdateInfo.OldVersion := False;
    case GameDataTemp^.Protocol of
      PROTOCOL_NORMAL:
        If not OldData.IsHidden(GameDataTemp^.Identifier) then
          begin
            Index := OldData.IndexOf(GameDataTemp^.Identifier);
            If Index >= 0 then
              begin
                GameDataTemp^.UpdateInfo.NewEntry := False;
                GameDataTemp^.UpdateInfo.NewVersion := GameDataTemp^.Version > OldData[Index].Version;
                GameDataTemp^.UpdateInfo.OldVersion := GameDataTemp^.Version < OldData[Index].Version;
              end
            else GameDataTemp^.UpdateInfo.NewEntry := True;
          end;
      PROTOCOL_HIDDEN,
      PROTOCOL_HIDE:
        GameDataTemp^.UpdateInfo.Valid := False;
      PROTOCOL_UPDHIDE:
        begin
          GameDataTemp^.UpdateInfo.NewEntry := False;
          For Index := Low(GameDataTemp^.Modules) to High(GameDataTemp^.Modules) do
            If OldData.IndexOf(StringToGUID(GameDataTemp^.Modules[Index].FileName)) >= 0 then
              begin
                GameDataTemp^.UpdateInfo.NewEntry := True;
                Break;
              end;
        end;
    end;
    GameDataTemp^.UpdateInfo.Add := GameDataTemp^.UpdateInfo.Valid and
                                   (GameDataTemp^.UpdateInfo.NewEntry or
                                    GameDataTemp^.UpdateInfo.NewVersion);
  end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.UpdateFrom(UpdateData: TGamesDataManager): Integer;
var
  i, Index: Integer;
begin
Result := 0;
fGameIcons.UpdateFrom(UpdateData.GameIcons);
If UpdateData.GamesDataCount > 0 then
  For i := 0 to Pred(UpdateData.GamesDataCount) do
    If UpdateData[i].UpdateInfo.Add then
      begin
        case UpdateData[i].Protocol of
          PROTOCOL_NORMAL:
            If not IsHidden(UpdateData[i].Identifier) then
              begin
                Index := IndexOf(UpdateData[i].Identifier);
                If Index >= 0 then fGamesData.Entries[Index] := UpdateData[i]
                  else AddGameData(UpdateData[i]);
                Inc(Result);
              end;
          PROTOCOL_HIDDEN,
          PROTOCOL_HIDE:;   // do nothing
          PROTOCOL_UPDHIDE:
            For Index := Low(UpdateData[i].Modules) to High(UpdateData[i].Modules) do
              If HideGameData(StringToGUID(UpdateData[i].Modules[Index].FileName)) > 0 then
                Inc(Result);
        end;
      end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.AddGameData(GameData: TGameData): Integer;
begin
If IsValid(GameData) and not GameListed(GameData.Identifier) then
  begin
    SetLength(fGamesData.Entries,Length(fGamesData.Entries) + 1);
    fGamesData.Entries[High(fGamesData.Entries)] := GameData;
    Result := High(fGamesData.Entries);
  end
else Result := -1;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.RemoveGameData(Identifier: TGUID): Integer;
begin
Result := IndexOf(Identifier);
If Result >= 0 then DeleteGameData(Result);
end;

//------------------------------------------------------------------------------

procedure TGamesDataManager.DeleteGameData(Index: Integer);
var
  i:  Integer;
begin
If (Index >= Low(fGamesData.Entries)) and (Index <= High(fGamesData.Entries)) then
  begin
    For i := Index to Pred(High(fGamesData.Entries)) do
      fGamesData.Entries[i] := fGamesData.Entries[i + 1];
    SetLength(fGamesData.Entries,Length(fGamesData.Entries) - 1);
  end
else raise Exception.CreateFmt('TGamesDataManager.DeleteGameData: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.IsHidden(Identifier: TGUID): Boolean;
var
  i:  Integer;
begin
Result := False;
For i := Low(fGamesData.Hidden) to High(fGamesData.Hidden) do
  If IsEqualGUID(fGamesData.Hidden[i].Identifier,Identifier) then
    begin
      Result := True;
      Break;
    end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.HideGameData(Identifier: TGUID): Integer;
begin
Result := IndexOf(Identifier);
If (Result >= 0) and not IsHidden(Identifier) then
  begin
    SetLength(fGamesData.Hidden,Length(fGamesData.Hidden) + 1);
    fGamesData.Hidden[High(fGamesData.Hidden)] := fGamesData.Entries[Result];
    case fGamesData.Hidden[High(fGamesData.Hidden)].Protocol of
      PROTOCOL_HIDDEN,
      PROTOCOL_HIDE,
      PROTOCOL_UPDHIDE:;  // do nothing
    else
      fGamesData.Hidden[High(fGamesData.Hidden)].Protocol := PROTOCOL_HIDDEN;
    end;
    DeleteGameData(Result);
  end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.AddHiddenGameData(GameData: TGameData): Integer;
begin
If IsValid(GameData) and not IsHidden(GameData.Identifier) then
  begin
    SetLength(fGamesData.Hidden,Length(fGamesData.Hidden) + 1);
    fGamesData.Hidden[High(fGamesData.Hidden)] := GameData;
    case fGamesData.Hidden[High(fGamesData.Hidden)].Protocol of
      PROTOCOL_HIDDEN,
      PROTOCOL_HIDE,
      PROTOCOL_UPDHIDE:;  // do nothing
    else
      fGamesData.Hidden[High(fGamesData.Hidden)].Protocol := PROTOCOL_HIDDEN;
    end;
    Result := High(fGamesData.Hidden);
  end
else Result := -1;
end;

end.
