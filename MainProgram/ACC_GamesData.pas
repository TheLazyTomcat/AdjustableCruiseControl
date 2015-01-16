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

  GDIN_MS_FileStructure = 'Version';

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
    ModuleIndex:  Integer;
    Offsets:      Array of PtrInt;
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

  TGamesData = Array of TGameData;
  PGamesData = ^TGamesData;

  TFileStructure = LongWord;

const
  CF_NONE      = $00000000;
  CF_FILESIZE  = $00000001;
  CF_FILECRC32 = $00000002;
  CF_FILEMD5   = $00000004;

  BFS_1_0 = $00010000;
  IFS_1_0 = $00010000;
  IFS_2_0 = $00020000;

  cInvalidProtocolVersion = TProtocolVersion(-1);

  ACC_PTR_FLAGS_PointerTypeBitmask = $1FF;

type
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
    procedure SaveIcons(Stream: TStream); virtual;
    procedure LoadIcons(Stream: TStream); virtual;
    Function SaveToIni_Struct00010000(Ini: TIniFile): Boolean; virtual;
    Function LoadItemFromIni_Struct00010000(Ini: TIniFile; Section: String; out GameData: TGameData): Boolean;
    Function LoadFromIni_Struct00010000(Ini: TIniFile): Boolean; virtual;
    Function SaveToBin_Struct00010000(Stream: TStream): Boolean; virtual;
    Function SaveToIni_Struct00020000(Ini: TIniFile): Boolean; virtual;
    Function LoadItemFromBin_Struct00010000(Stream: TStream; Position: Int64; out GameData: TGameData): Boolean;
    Function LoadItemFromIni_Struct00020000(Ini: TIniFile; Section: String; out GameData: TGameData): Boolean;
    Function LoadFromBin_Struct00010000(Stream: TStream): Boolean; virtual;
    Function LoadFromIni_Struct00020000(Ini: TIniFile): Boolean; virtual;
  public
    class Function SupportsBinFileStructure(FileStructure: TFileStructure): Boolean; virtual;
    class Function SupportsIniFileStructure(FileStructure: TFileStructure): Boolean; virtual;
    class Function IsValid(GameData: TGameData): Boolean; virtual;    
    class Function TruckSpeedSupported(const GameData: TGameData): Boolean; virtual;
    constructor Create;
    destructor Destroy; override;
    Function IndexOf(Identifier: TGUID): Integer; virtual;
    Function GameListed(Identifier: TGUID): Boolean; virtual;
    procedure Clear; virtual;
    Function SaveToBin(const FileName: String; FileStructure: TFileStructure): Boolean; virtual;
    Function SaveToIni(const FileName: String; FileStructure: TFileStructure): Boolean; virtual;
    Function LoadFromBin(const FileName: String; out FileStructure: TFileStructure): Boolean; overload; virtual;
    Function LoadFromBin(const FileName: String): Boolean; overload; virtual;
    Function LoadFromIni(const FileName: String; out FileStructure: TFileStructure): Boolean; overload; virtual;
    Function LoadFromIni(const FileName: String): Boolean; overload; virtual;
    Function LoadFrom(const FileName: String): Boolean; virtual;
    Function Load: Boolean; virtual;
    Function Save: Boolean; virtual;
    procedure CheckUpdate(OldData: TGamesDataManager); virtual;
    Function UpdateFrom(UpdateData: TGamesDataManager): Integer; virtual;
    property GameDataPtr[Index: Integer]: PGameData read GetGameDataPtr;
    property GameData[Index: Integer]: TGameData read GetGameData; default;
  published
    property GamesDataCount: Integer read GetGamesDataCount;
    property GamesData: TGamesData read fGamesData;
    property GameIcons: TIconList read fGameIcons;
  end;


implementation

{$R 'Resources\DefGameIcon.res'}

uses
  Windows, SysUtils, DateUtils, StrUtils;

const
  InvalidFileStructure = TFileStructure(-1);

  // Supported gamesdata file structures
  SupportedBinFileStructure: Array[0..0] of TFileStructure = (BFS_1_0);
  SupportedIniFileStructure: Array[0..1] of TFileStructure = (IFS_1_0,IFS_2_0);

  // Signature of binarz games data file
  ACCBinFileSignature = $64636361;

  DefaultGameIconName    = 'default';
  DefaultGameIconResName = 'GI_' + DefaultGameIconName;

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
  raise Exception.Create('TIconList.GetListItemPtr: Index (' + IntToStr(Index) + ') out of bounds.');
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
Result := Length(fGamesData);
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.GetGameDataPtr(Index: Integer): PGameData;
begin
If (Index >= Low(fGamesData)) and (Index <= High(fGamesData)) then
  Result := Addr(fGamesData[Index])
else
  raise Exception.Create('TGamesDataManager.GetGamesDataPtr: Index (' + IntToStr(Index) + ') out of bounds.');
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.GetGameData(Index: Integer): TGameData;
begin
If (Index >= Low(fGamesData)) and (Index <= High(fGamesData)) then
  Result := fGamesData[Index]
else
  raise Exception.Create('TGamesDataManager.GetGamesData(Index): Index (' + IntToStr(Index) + ') out of bounds.');
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
        WriteIntegerToStream(Stream,WorkStream.Size);
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

Function TGamesDataManager.SaveToIni_Struct00010000(Ini: TIniFile): Boolean;
var
  CurrentSection: String;
  TempStr:        String;
  i,j:            Integer;

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
        iTempStr := '$' + IntToHex(Pointer.Flags and ACC_PTR_FLAGS_PointerTypeBitmask,3) + '@' +
                    '$' + IntToHex(Pointer.ModuleIndex,1) + '+';
        For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
          iTempStr := iTempStr + '$' + IntToHex(Pointer.Offsets[ii],SizeOf(PtrInt) * 2) + '>';
        iTempStr := iTempStr + SingleToHex(Pointer.Coefficient);
        Ini.WriteString(CurrentSection,ValueName,iTempStr);
      end
    else Ini.WriteString(CurrentSection,ValueName,'0');
  end;

begin
try
  For i := Low(fGamesData) to High(fGamesData) do
    begin
      CurrentSection := Format(GDIN_Game,[i]);
      Ini.WriteString(CurrentSection,GDIN_GD_LEG_Identificator,fGamesData[i].Descriptor);
      Ini.WriteString(CurrentSection,GDIN_GD_LEG_GameInfo,fGamesData[i].Title + '&&' + fGamesData[i].Info);

      TempStr := '$0^';
      For j := Low(fGamesData[i].Modules) to High(fGamesData[i].Modules) do
        begin
          AddModuleToStr(TempStr,fGamesData[i].Modules[j]);
          If j < High(fGamesData[i].Modules) then TempStr := TempStr + '&';
        end;
      Ini.WriteString(CurrentSection,GDIN_GD_LEG_Process,TempStr);

      WritePointer(GDIN_GD_CCStatus,fGamesData[i].CCStatus);
      WritePointer(GDIN_GD_CCSpeed,fGamesData[i].CCSpeed);
      WritePointer(GDIN_GD_TruckSpeed,fGamesData[i].TruckSpeed);
      For j := Low(fGamesData[i].Values) to High(fGamesData[i].Values) do
        WritePointer(Format(GDIN_GD_LEG_Special,[j]),fGamesData[i].Values[j]);
    end;
  Result := True;  
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadItemFromIni_Struct00010000(Ini: TIniFile; Section: String; out GameData: TGameData): Boolean;
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
          Module.CRC32 := StrToInt(AnsiLeftStr(ModText,AnsiPos('@',ModText) - 1));
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
        Pointer.Flags := StrToInt(AnsiLeftStr(Text,AnsiPos('@',Text) - 1)) and ACC_PTR_FLAGS_PointerTypeBitmask;
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
  GameData.Protocol := 0;
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
  If not ParsePointer(Decrypt(Ini.ReadString(Section,GDIN_GD_CCSpeed,'')),GameData.CCSpeed) then Exit;
  TempStr := Decrypt(Ini.ReadString(Section,GDIN_GD_TruckSpeed,''));
  If TempStr <> '0' then
    begin
      If not ParsePointer(TempStr,GameData.TruckSpeed) then Exit;
    end
  else
    begin
      GameData.TruckSpeed.Flags := 0;
      GameData.TruckSpeed.ModuleIndex := -1;
      SetLength(GameData.TruckSpeed.Offsets,0);
      GameData.TruckSpeed.Coefficient := 0;
    end;
  i := 0;
  SetLength(GameData.Values,0);
  while Ini.ValueExists(Section,Format(GDIN_GD_LEG_Special,[i])) do
    begin
      SetLength(GameData.Values,Length(GameData.Values) + 1);
      If not ParsePointer(Decrypt(Ini.ReadString(Section,Format(GDIN_GD_LEG_Special,[i]),'')),GameData.Values[i]) then Exit;
      Inc(i);
    end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromIni_Struct00010000(Ini: TIniFile): Boolean;
var
  Index:        Integer;
  TempGameData: TGameData;
begin
try
  Index := 0;
  while Ini.SectionExists(Format(GDIN_Game,[Index])) do
    begin
      If LoadItemFromIni_Struct00010000(Ini,Format(GDIN_Game,[Index]),TempGameData) then
        If IsValid(TempGameData) then
          begin
            SetLength(fGamesData,Length(fGamesData) + 1);
            fGamesData[High(fGamesData)] := TempGameData;
          end;
      Inc(Index);
    end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.SaveToBin_Struct00010000(Stream: TStream): Boolean;
var
  EntryStream:  TMemoryStream;
  i,j:          Integer;

  procedure WriteModule(EnStream: TStream; Module: TModuleData);
  begin
    WriteIntegerToStream(EnStream,Module.CheckFlags);
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
    WriteIntegerToStream(EnStream,Pointer.Flags);
    WriteIntegerToStream(EnStream,Pointer.ModuleIndex);
    WriteIntegerToStream(EnStream,Length(Pointer.Offsets));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      WriteInt64ToStream(EnStream,Pointer.Offsets[ii]);
    WriteFloatToStream(EnStream,Pointer.Coefficient);
  end;

begin
try
  EntryStream := TMemoryStream.Create;
  try
    SaveIcons(Stream);
    WriteIntegerToStream(Stream,Length(fGamesData));
    For i := Low(fGamesData) to High(fGamesData) do
      begin
        EntryStream.Clear;

        WriteIntegerToStream(EntryStream,fGamesData[i].Protocol);
        EntryStream.WriteBuffer(fGamesData[i].Identifier,SizeOf(TGUID));
        WriteStringToStream(EntryStream,fGamesData[i].Descriptor);
        WriteIntegerToStream(EntryStream,fGamesData[i].Version);
        WriteStringToStream(EntryStream,fGamesData[i].Icon);
        WriteInt64ToStream(EntryStream,DateTimeToUnix(fGamesData[i].Date));
        WriteStringToStream(EntryStream,fGamesData[i].Author);
        WriteStringToStream(EntryStream,fGamesData[i].Title);
        WriteStringToStream(EntryStream,fGamesData[i].Info);
        WriteStringToStream(EntryStream,fGamesData[i].ExtendedTitle);

        WriteIntegerToStream(EntryStream,Length(fGamesData[i].Modules));
        For j := Low(fGamesData[i].Modules) to High(fGamesData[i].Modules) do
          WriteModule(EntryStream,fGamesData[i].Modules[j]);

        WritePointer(EntryStream,fGamesData[i].CCSpeed);
        WritePointer(EntryStream,fGamesData[i].CCStatus);
        WritePointer(EntryStream,fGamesData[i].TruckSpeed);
        WriteIntegerToStream(EntryStream,Length(fGamesData[i].Values));
        For j := Low(fGamesData[i].Values) to High(fGamesData[i].Values) do
          WritePointer(EntryStream,fGamesData[i].Values[j]);

        ZCompressStream(EntryStream);
        WriteIntegerToStream(Stream,EntryStream.Size);
        Stream.CopyFrom(EntryStream,0);
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

Function TGamesDataManager.SaveToIni_Struct00020000(Ini: TIniFile): Boolean;
var
  CurrentSection: String;
  FormatSettings: TFormatSettings;
  i,j:            Integer;

  procedure WriteModule(const Prefix: String; Module: TModuleData);
  begin
    Ini.WriteString(CurrentSection,Prefix + GDIN_GD_MOD_CheckFlags,'$' + IntToHex(Module.CheckFlags,8));
      Ini.WriteString(CurrentSection,Prefix + GDIN_GD_MOD_FileName,Module.FileName);
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Ini.WriteInteger(CurrentSection,Prefix + GDIN_GD_MOD_Size,Module.Size);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      Ini.WriteString(CurrentSection,Prefix + GDIN_GD_MOD_CRC32,'$' + IntToHex(Module.CRC32,8));
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      Ini.WriteString(CurrentSection,Prefix + GDIN_GD_MOD_MD5,MD5ToStr(Module.MD5));
  end;

  procedure WritePointer(const Prefix: String; Pointer: TPointerData);
  var
    ii: Integer;
  begin
    If Pointer.ModuleIndex >= 0 then
      begin
        Ini.WriteString(CurrentSection,Prefix + GDIN_GD_VAL_Flags,'$' + IntToHex(Pointer.Flags,8));
        Ini.WriteInteger(CurrentSection,Prefix + GDIN_GD_VAL_ModuleIndex,Pointer.ModuleIndex);
        Ini.WriteInteger(CurrentSection,Prefix + GDIN_GD_VAL_Offsets,Length(Pointer.Offsets));
        For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
          Ini.WriteString(CurrentSection,Prefix + Format(GDIN_GD_VAL_Offset,[ii]),'$' +
                                         IntToHex(Pointer.Offsets[ii],SizeOf(PtrInt) * 2));
        Ini.WriteString(CurrentSection,Prefix + GDIN_GD_VAL_Coefficient,'$' + SingleToHex(Pointer.Coefficient));
      end;
  end;

begin
try
  For i := Low(fGamesData) to High(fGamesData) do
    begin
      CurrentSection := Format(GDIN_Game,[i]);
      Ini.WriteInteger(CurrentSection,GDIN_GD_Protocol,fGamesData[i].Protocol);
      Ini.WriteString(CurrentSection,GDIN_GD_Identifier,GUIDToString(fGamesData[i].Identifier));
      Ini.WriteString(CurrentSection,GDIN_GD_Descriptor,fGamesData[i].Descriptor);
      Ini.WriteInteger(CurrentSection,GDIN_GD_Version,fGamesData[i].Version);
      Ini.WriteString(CurrentSection,GDIN_GD_Icon,fGamesData[i].Icon);
      {%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,{%H-}FormatSettings);
      FormatSettings.DateSeparator := '-';
      FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
      Ini.WriteString(CurrentSection,GDIN_GD_Date,DateToStr(fGamesData[i].Date,FormatSettings));
      Ini.WriteString(CurrentSection,GDIN_GD_Author,fGamesData[i].Author);
      Ini.WriteString(CurrentSection,GDIN_GD_Title,fGamesData[i].Title);
      Ini.WriteString(CurrentSection,GDIN_GD_Info,fGamesData[i].Info);
      Ini.WriteString(CurrentSection,GDIN_GD_ExtendedTitle,fGamesData[i].ExtendedTitle);

      Ini.WriteInteger(CurrentSection,GDIN_GD_Modules,Length(fGamesData[i].Modules));
      For j := Low(fGamesData[i].Modules) to High(fGamesData[i].Modules) do
        WriteModule(Format(GDIN_GD_Module,[j]),fGamesData[i].Modules[j]);

      WritePointer(GDIN_GD_CCSpeed,fGamesData[i].CCSpeed);
      WritePointer(GDIN_GD_CCStatus,fGamesData[i].CCStatus);
      WritePointer(GDIN_GD_TruckSpeed,fGamesData[i].TruckSpeed);
      Ini.WriteInteger(CurrentSection,GDIN_GD_Values,Length(fGamesData[i].Values));
      For j := Low(fGamesData[i].Values) to High(fGamesData[i].Values) do
        WritePointer(Format(GDIN_GD_Value,[j]),fGamesData[i].Values[j]);
    end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadItemFromBin_Struct00010000(Stream: TStream; Position: Int64; out GameData: TGameData): Boolean;
var
  EntryStream:  TMemoryStream;
  i:            Integer;

  procedure ReadModule(EnStream: TStream; var Module: TModuleData);
  begin
    Module.CheckFlags := ReadIntegerFromStream(EnStream);
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
    Pointer.Flags := ReadIntegerFromStream(EnStream);
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

    GameData.Protocol := ReadIntegerFromStream(EntryStream);
    EntryStream.ReadBuffer(GameData.Identifier,SizeOf(TMD5Hash));
    GameData.Descriptor := ReadStringFromStream(EntryStream);
    GameData.Version := ReadIntegerFromStream(EntryStream);
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

Function TGamesDataManager.LoadItemFromIni_Struct00020000(Ini: TIniFile; Section: String; out GameData: TGameData): Boolean;
var
  FormatSettings: TFormatSettings;
  i:              Integer;

  procedure ReadModule(const Prefix: String; var Module: TModuleData);
  begin
    Module.CheckFlags := Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_CheckFlags,CF_NONE);
    Module.FileName := Ini.ReadString(Section,Prefix + GDIN_GD_MOD_FileName,'');
    If (Module.CheckFlags and CF_FILESIZE) <> 0 then
      Module.Size := Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_Size,0);
    If (Module.CheckFlags and CF_FILECRC32) <> 0 then
      Module.CRC32 := Ini.ReadInteger(Section,Prefix + GDIN_GD_MOD_CRC32,0);
    If (Module.CheckFlags and CF_FILEMD5) <> 0 then
      Module.MD5 := StrToMD5(Ini.ReadString(Section,Prefix + GDIN_GD_MOD_MD5,'00000000000000000000000000000000'));
  end;

  procedure ReadPointer(const Prefix: String; var Pointer: TPointerData);
  var
    ii: Integer;
  begin
    Pointer.Flags := Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_Flags,CF_NONE);
    Pointer.ModuleIndex := Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_ModuleIndex,-1);
    SetLength(Pointer.Offsets,Ini.ReadInteger(Section,Prefix + GDIN_GD_VAL_Offsets,0));
    For ii := Low(Pointer.Offsets) to High(Pointer.Offsets) do
      Pointer.Offsets[ii] := Ini.ReadInteger(Section,Prefix + Format(GDIN_GD_VAL_Offset,[ii]),0);
    Pointer.Coefficient := HexToSingle(Ini.ReadString(Section,Prefix + GDIN_GD_VAL_Coefficient,'0'));
  end;

begin
try
  GameData.Protocol := Ini.ReadInteger(Section,GDIN_GD_Protocol,Integer(cInvalidProtocolVersion));
  GameData.Identifier := StringToGUID(Ini.ReadString(Section,GDIN_GD_Identifier,'{00000000-0000-0000-0000-000000000000}'));
  GameData.Descriptor := Ini.ReadString(Section,GDIN_GD_Descriptor,'');
  GameData.Version := Ini.ReadInteger(Section,GDIN_GD_Version,0);
  GameData.Icon := Ini.ReadString(Section,GDIN_GD_Icon,DefaultGameIconName);
  {%H-}GetLocaleFormatSettings(LOCALE_USER_DEFAULT,{%H-}FormatSettings);
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
  StrToDate('2015',FormatSettings);
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

Function TGamesDataManager.LoadFromBin_Struct00010000(Stream: TStream): Boolean;
var
  i:            Integer;
  TempGameData: TGameData;
begin
try
  LoadIcons(Stream);
  For i := 1 to ReadIntegerFromStream(Stream) do
    If LoadItemFromBin_Struct00010000(Stream,Stream.Position,TempGameData) then
      If IsValid(TempGameData) then
        begin
          SetLength(fGamesData,Length(fGamesData) + 1);
          fGamesData[High(fGamesData)] := TempGameData
        end;
  Result := True;
except
  Result := False;
end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.LoadFromIni_Struct00020000(Ini: TIniFile): Boolean;
var
  Index:        Integer;
  TempGameData: TGameData;
begin
try
  Index := 0;
  while Ini.SectionExists(Format(GDIN_Game,[Index])) do
    begin
      If LoadItemFromIni_Struct00020000(Ini,Format(GDIN_Game,[Index]),TempGameData) then
        If IsValid(TempGameData) then
          begin
            SetLength(fGamesData,Length(fGamesData) + 1);
            fGamesData[High(fGamesData)] := TempGameData;
          end;
      Inc(Index);
    end;
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

class Function TGamesDataManager.IsValid(GameData: TGameData): Boolean;
var
  i:  Integer;

  Function CheckModule(Module: TModuleData; MainModule: Boolean): Boolean;
  begin
    Result := (Module.CheckFlags <> CF_NONE) and (Module.FileName <> '') and
              ((ExtractFilePath(Module.FileName) = '') or not MainModule);
  end;

  Function CheckPointer(Pointer: TPointerData): Boolean;
  begin
    Result := (Pointer.ModuleIndex >= Low(GameData.Modules)) and
              (Pointer.ModuleIndex <= High(GameData.Modules));
  end;

begin
Result := GameData.Protocol <> cInvalidProtocolVersion;
Result := Result and not IsEqualGUID(GameData.Identifier,StringToGUID('{00000000-0000-0000-0000-000000000000}'));
Result := Result and (Length(GameData.Modules) > 0);
For i := Low(GameData.Modules) to High(GameData.Modules) do
  Result := Result and CheckModule(GameData.Modules[i],i = Low(GameData.Modules));
Result := Result and CheckPointer(GameData.CCSpeed) and CheckPointer(GameData.CCStatus);
For i := Low(GameData.Values) to High(GameData.Values) do
  Result := Result and CheckPointer(GameData.Values[i]);
end;

//------------------------------------------------------------------------------

class Function TGamesDataManager.TruckSpeedSupported(const GameData: TGameData): Boolean;
begin
Result := (GameData.TruckSpeed.ModuleIndex >= Low(GameData.Modules)) and
          (GameData.TruckSpeed.ModuleIndex <= High(GameData.Modules));
end;

//------------------------------------------------------------------------------

constructor TGamesDataManager.Create;
begin
inherited;
SetLength(fGamesData,0);
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
For Result := Low(fGamesData) to High(fGamesData) do
  If IsEqualGUID(fGamesData[Result].Identifier,Identifier) then Exit;
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
SetLength(fGamesData,0);
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
      WriteIntegerToStream(FileStream,FileStructure);
      case FileStructure of
        BFS_1_0:  Result := SaveToBin_Struct00010000(FileStream);
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
  IniFile:  TIniFile;
begin
If SupportsIniFileStructure(FileStructure) then
  try
    IniFile := TIniFile.Create(FileName);
    try
      IniFile.WriteString(GDIN_MainSection,GDIN_MS_FileStructure,'$' + IntToHex(FileStructure,8));
      case FileStructure of
        IFS_1_0:  Result := SaveToIni_Struct00010000(IniFile);
        IFS_2_0:  Result := SaveToIni_Struct00020000(IniFile);
      else
        Result := False;
      end;
    finally
      IniFile.Free;
    end;
  except
    Result := False;
  end
else Result := False;
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
    If ReadIntegerFromStream(FileStream) <> ACCBinFileSignature then Abort;
    FileStructure := ReadIntegerFromStream(FileStream);
    If SupportsBinFileStructure(FileStructure) then
      begin
        Clear;
        case FileStructure of
          BFS_1_0:  Result := LoadFromBin_Struct00010000(FileStream);
        else
          Result := False;
        end;
      end
    else Result := False;
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
  IniFile:  TIniFile;
begin
try
  IniFile := TIniFile.Create(FileName);
  try
    FileStructure := TFileStructure(IniFile.ReadInteger(GDIN_MainSection,GDIN_MS_FileStructure,Integer(InvalidFileStructure)));
    If SupportsIniFileStructure(FileStructure) then
      begin
        Clear;
        case FileStructure of
          IFS_1_0:  Result := LoadFromIni_Struct00010000(IniFile);
          IFS_2_0:  Result := LoadFromIni_Struct00020000(IniFile);
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
  i, Index:     Integer;
  GameDataTemp: PGameData;
begin
For i := 0 to Pred(GamesDataCount) do
  begin
    GameDataTemp := GameDataPtr[i];
    GameDataTemp^.UpdateInfo.Valid := IsValid(GameDataTemp^);
    Index := OldData.IndexOf(GameDataTemp^.Identifier);
    If Index >= 0 then
      begin
        GameDataTemp^.UpdateInfo.NewEntry := False;
        GameDataTemp^.UpdateInfo.NewVersion := GameDataTemp^.Version > OldData[Index].Version;
        GameDataTemp^.UpdateInfo.OldVersion := GameDataTemp^.Version < OldData[Index].Version;
      end
    else GameDataTemp^.UpdateInfo.NewEntry := True;
    GameDataTemp^.UpdateInfo.Add := GameDataTemp^.UpdateInfo.Valid and
                                   (GameDataTemp^.UpdateInfo.NewEntry or
                                    GameDataTemp^.UpdateInfo.NewVersion);
  end;
end;

//------------------------------------------------------------------------------

Function TGamesDataManager.UpdateFrom(UpdateData: TGamesDataManager): Integer;
var
  i,Index:  Integer;
begin
Result := 0;
fGameIcons.UpdateFrom(UpdateData.GameIcons);
If UpdateData.GamesDataCount > 0 then
  For i := 0 to Pred(UpdateData.GamesDataCount) do
    If UpdateData[i].UpdateInfo.Add then
      begin
        Index := IndexOf(UpdateData[i].Identifier);
        If Index >= 0 then
          fGamesData[Index] := UpdateData[i]
        else
          begin
            SetLength(fGamesData,Length(fGamesData) + 1);
            fGamesData[High(fGamesData)] := UpdateData[i];
          end;
        Inc(Result);
      end;
end;

end.