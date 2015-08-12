{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
unit ACC_PluginInstaller;

interface

uses
  Windows;

type
  TGameEntry = record
    Valid:            Boolean;
    Title:            String;
    RegistryRoot:     HKEY;
    RegistryKey:      String;
    FullRegistryKey:  String;
    Is64bit:          Boolean;
    SystemValid:      Boolean;
  end;

  TPluginData = record
    Description:  String;
    FilePath:     String;  
  end;

{==============================================================================}
{------------------------------------------------------------------------------}
{                              TACCPluginInstaller                             }
{------------------------------------------------------------------------------}
{==============================================================================}
  TACCPluginInstaller = class(TObject)
  private
    fRunningInWoW64:    Boolean;
    fKnownGames:        Array of TGameEntry;
    fSelectedGameIdx:   Integer;
    fInstalledPlugins:  Array of TPluginData;
    fPluginsLibrary:    Array of TPluginData;
    Function GetKnownGameCount: Integer;
    Function GetKnownGames(Index: Integer): TGameEntry;
    Function GetInstalledPluginCount: Integer;
    Function GetInstalledPlugins(Index: Integer): TPluginData;
    Function GetPluginsLibraryCount: Integer;
    Function GetPluginsLibraryItem(Index: Integer): TPluginData;
  protected
    Function GetRegistryViewFlag: LongWord; virtual;
    Function GetSelectedGame: TGameEntry; virtual;
    procedure CheckWoW64; virtual;
    procedure FillKnownGames; virtual;
    Function LoadInstalledPlugins: Integer; virtual;
    procedure LoadPluginsLibrary; virtual;
    procedure SavePluginsLibrary; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    Function SelectGame(Index: Integer): Boolean; virtual;
    Function InstalledPluginsIndexOfDescription(const Description: String): Integer; virtual;
    Function InstalledPluginsIndexOfFilePath(const FilePath: String): Integer; virtual;
    Function InstallPlugin(const Description, FilePath: String): Boolean; virtual;
    Function UninstallPlugin(Index: Integer): Boolean; virtual;
    Function PluginsLibraryIndexOfDescription(const Description: String): Integer; virtual;
    Function PluginsLibraryIndexOfFilePath(const FilePath: String): Integer; virtual;
    Function PluginsLibraryAdd(const Description, FilePath: String): Integer; virtual;
    Function PluginsLibraryRemove(Index: Integer): Boolean; virtual;
    procedure PluginsLibraryValidate; virtual;
    property KnownGames[Index: Integer]: TGameEntry read GetKnownGames;
    property InstalledPlugins[Index: Integer]: TPluginData read GetInstalledPlugins;
    property PluginsLibrary[Index: Integer]: TPluginData read GetPluginsLibraryItem;
  published
    property RunningInWoW64: Boolean read fRunningInWoW64;
    property KnownGameCount: Integer read GetKnownGameCount;
    property SelectedGameIdx: Integer read fSelectedGameIdx;
    property SelectedGame: TGameEntry read GetSelectedGame;
    property InstallegPluginCount: Integer read GetInstalledPluginCount;
    property PluginsLibraryCount: Integer read GetPluginsLibraryCount;
  end;

implementation

uses
  SysUtils, Classes, Registry, DefRegistry;

const
  PluginsLibraryRegKey = 'Software\NcS Soft\PluginInstaller\Library';

  KnownGamesList: array[0..1] of TGameEntry = (
    (Valid:           True;
     Title:           'Euro Truck Simulator 2 - 32bit';
     RegistryRoot:    HKEY_LOCAL_MACHINE;
     RegistryKey:     'Software\SCS Software\Euro Truck Simulator 2\Plugins';
     FullRegistryKey: 'HKEY_LOCAL_MACHINE\Software\SCS Software\Euro Truck Simulator 2\Plugins';
     Is64bit:         False;
     SystemValid:     False),
     
    (Valid:           True;
     Title:           'Euro Truck Simulator 2 - 64bit';
     RegistryRoot:    HKEY_LOCAL_MACHINE;
     RegistryKey:     'Software\SCS Software\Euro Truck Simulator 2\Plugins';
     FullRegistryKey: 'HKEY_LOCAL_MACHINE\Software\SCS Software\Euro Truck Simulator 2\Plugins';
     Is64bit:         True;
     SystemValid:     False));

  EmptyGameEntry: TGameEntry = (
    Valid:            False;
    Title:            '';
    RegistryRoot:     0;
    RegistryKey:      '';
    FullRegistryKey:  '';
    Is64bit:          False;
    SystemValid:      True);

{==============================================================================}
{------------------------------------------------------------------------------}
{                              TACCPluginInstaller                             }
{------------------------------------------------------------------------------}
{==============================================================================}

{------------------------------------------------------------------------------}
{   TACCPluginInstaller - private methods                                      }
{------------------------------------------------------------------------------}

Function TACCPluginInstaller.GetKnownGameCount: Integer;
begin
Result := Length(fKnownGames);
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetKnownGames(Index: Integer): TGameEntry;
begin
If (Index >= Low(fKnownGames)) and (Index <= High(fKnownGames)) then
  Result := fKnownGames[Index]
else
  raise Exception.CreateFmt('TACCPluginInstaller.GetKnownGames: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetInstalledPluginCount: Integer;
begin
Result := Length(fInstalledPlugins);
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetInstalledPlugins(Index: Integer): TPluginData;
begin
If (Index >= Low(fInstalledPlugins)) and (Index <= High(fInstalledPlugins)) then
  Result := fInstalledPlugins[Index]
else
  raise Exception.CreateFmt('TACCPluginInstaller.GeTPluginDatas: Index (%d) out of bounds.',[Index]);
end;
 
//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetPluginsLibraryCount: Integer;
begin
Result := Length(fPluginsLibrary);
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetPluginsLibraryItem(Index: Integer): TPluginData;
begin
If (Index >= Low(fPluginsLibrary)) and (Index <= High(fPluginsLibrary)) then
  Result := fPluginsLibrary[Index]
else
  raise Exception.CreateFmt('TACCPluginInstaller.GetPluginsLibraryItem: Index (%d) out of bounds.',[Index]);
end;

{------------------------------------------------------------------------------}
{   TACCPluginInstaller - protected methods                                    }
{------------------------------------------------------------------------------}

Function TACCPluginInstaller.GetRegistryViewFlag: LongWord;
const
  KEY_WOW64_64KEY = $0100;
  KEY_WOW64_32KEY = $0200;
begin
{$IFDEF x64}
If SelectedGame.Is64bit then Result := KEY_WOW64_64KEY
  else Result := KEY_WOW64_32KEY;
{$ELSE}
If fRunningInWoW64 then
  begin
    If SelectedGame.Is64bit then Result := KEY_WOW64_64KEY
      else Result := KEY_WOW64_32KEY;
  end
else Result := 0;
{$ENDIF}
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetSelectedGame: TGameEntry;
begin
If (fSelectedGameIdx >= Low(fKnownGames)) and (fSelectedGameIdx <= High(fKnownGames)) then
  Result := GetKnownGames(fSelectedGameIdx)
else
  Result := EmptyGameEntry;
end;

//------------------------------------------------------------------------------

procedure TACCPluginInstaller.CheckWoW64;
{$IFDEF x64}
begin
fRunningInWoW64 := True;
end;
{$ELSE}
type
  TIsWoW64Process = Function (hProcess: THandle; Wow64Process: PBOOL): BOOL; stdcall;
var
  ModuleHandle:   THandle;
  IsWow64Process: TIsWoW64Process;
  ResultValue:    BOOL;
begin
fRunningInWoW64 := False;
ModuleHandle := GetModuleHandle('kernel32.dll');
If ModuleHandle <> 0 then
  begin
    IsWoW64Process := GetProcAddress(ModuleHandle,'IsWow64Process');
    If Assigned(IsWoW64Process) then
      If IsWow64Process(GetCurrentProcess,@ResultValue) then fRunningInWoW64 := ResultValue;
  end;
end;
{$ENDIF}

//------------------------------------------------------------------------------

procedure TACCPluginInstaller.FillKnownGames;
var
  i:  Integer;
begin
SetLength(fKnownGames,Length(KnownGamesList));
For i := Low(fKnownGames) to High(fKnownGames) do
  begin
    fKnownGames[i] := KnownGamesList[i];
    fKnownGames[i].SystemValid := not fKnownGames[i].Is64bit or fRunningInWoW64;
  end;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.LoadInstalledPlugins: Integer;
var
  Reg:        TDefRegistry;
  TempList:   TStringList;
  i:          Integer;
  ValueInfo:  TRegDataInfo;
begin
SetLength(fInstalledPlugins,0);
If SelectedGame.Valid and SelectedGame.SystemValid then
  begin
    Reg := TDefRegistry.Create(KEY_ALL_ACCESS or GetRegistryViewFlag);
    try
      Reg.RootKey := SelectedGame.RegistryRoot;
      If Reg.OpenKey(SelectedGame.RegistryKey,False) then
        begin
          TempList := TStringList.Create;
          try
            Reg.GetValueNames(TempList);
            For i := 0 to Pred(TempList.Count) do
              If Reg.GetDataInfo(TempList[i],ValueInfo) then
                If ValueInfo.RegData = rdString then
                  begin
                    SetLength(fInstalledPlugins,Length(fInstalledPlugins) + 1);
                    fInstalledPlugins[High(fInstalledPlugins)].Description := TempList[i];
                    fInstalledPlugins[High(fInstalledPlugins)].FilePath := Reg.ReadStringDef(TempList[i],'')
                  end;
          finally
            TempList.Free;
          end;
          Reg.CloseKey;
        end;
    finally
      Reg.Free;
    end;
  end;
Result := Length(fInstalledPlugins);
end;

//------------------------------------------------------------------------------

procedure TACCPluginInstaller.LoadPluginsLibrary;
var
  Reg:        TDefRegistry;
  TempList:   TStringList;
  i:          Integer;
  ValueInfo:  TRegDataInfo;
begin
SetLength(fPluginsLibrary,0);
Reg := TDefRegistry.Create;
try
  Reg.RootKey := HKEY_CURRENT_USER;
  If Reg.OpenKeyReadOnly(PluginsLibraryRegKey) then
    begin
      TempList := TStringList.Create;
      try
        Reg.GetValueNames(TempList);
        For i := 0 to Pred(TempList.Count) do
          If Reg.GetDataInfo(TempList[i],ValueInfo) then
            If ValueInfo.RegData = rdString then
              begin
                SetLength(fPluginsLibrary,Length(fPluginsLibrary) + 1);
                fPluginsLibrary[High(fPluginsLibrary)].Description := TempList[i];
                fPluginsLibrary[High(fPluginsLibrary)].FilePath := Reg.ReadStringDef(TempList[i],'')
              end;
      finally
        TempList.Free;
      end;
      Reg.CloseKey;
    end;
finally
  Reg.Free;
end;
end;

//------------------------------------------------------------------------------

procedure TACCPluginInstaller.SavePluginsLibrary;
var
  Reg:      TRegistry;
  TempList: TStringList;
  i:        Integer;
begin
Reg := TRegistry.Create;
try
  Reg.RootKey := HKEY_CURRENT_USER;
  If Reg.OpenKey(PluginsLibraryRegKey,True) then
    begin
      TempList := TStringList.Create;
      try
        Reg.GetValueNames(TempList);
        For i := 0 to Pred(TempList.Count) do
          Reg.DeleteValue(TempList[i]);
      finally
        TempList.Free;
      end;
      For i := Low(fPluginsLibrary) to High(fPluginsLibrary) do
        Reg.WriteString(fPluginsLibrary[i].Description,fPluginsLibrary[i].FilePath);
      Reg.CloseKey;
    end;
finally
  Reg.Free;
end;
end;

{------------------------------------------------------------------------------}
{   TACCPluginInstaller - public methods                                       }
{------------------------------------------------------------------------------}

constructor TACCPluginInstaller.Create;
begin
inherited Create;
CheckWoW64;
FillKnownGames;
LoadPluginsLibrary;
fSelectedGameIdx := -1;
end;

//------------------------------------------------------------------------------

destructor TACCPluginInstaller.Destroy;
begin
SavePluginsLibrary;
inherited;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.SelectGame(Index: Integer): Boolean;
begin
fSelectedGameIdx := Index;
LoadInstalledPlugins;
Result := (Index >= Low(fKnownGames)) and (Index <= High(fKnownGames));
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.InstalledPluginsIndexOfDescription(const Description: String): Integer;
begin
For Result := Low(fInstalledPlugins) to High(fInstalledPlugins) do
  If AnsiSameText(fInstalledPlugins[Result].Description,Description) then Exit;
Result := -1;
end;


//------------------------------------------------------------------------------

Function TACCPluginInstaller.InstalledPluginsIndexOfFilePath(const FilePath: String): Integer;
begin
For Result := Low(fInstalledPlugins) to High(fInstalledPlugins) do
  If AnsiSameText(fInstalledPlugins[Result].FilePath,FilePath) then Exit;
Result := -1;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.InstallPlugin(const Description, FilePath: String): Boolean;
var
  Reg: TRegistry;
begin
Result := False;
If SelectedGame.Valid and SelectedGame.SystemValid then
  begin
    Reg := TRegistry.Create(KEY_ALL_ACCESS or GetRegistryViewFlag);
    try
      Reg.RootKey := SelectedGame.RegistryRoot;
      If Reg.OpenKey(SelectedGame.RegistryKey,True) then
        begin
          Reg.WriteString(Description,FilePath);
          Reg.CloseKey;
          Result := True;
        end;
    finally
      Reg.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.UninstallPlugin(Index: Integer): Boolean;
var
  Reg:  TRegistry;
begin
If (Index >= Low(fInstalledPlugins)) and (Index <= High(fInstalledPlugins)) then
  begin
    Reg := TRegistry.Create(KEY_ALL_ACCESS or GetRegistryViewFlag);
    try
      Reg.RootKey := SelectedGame.RegistryRoot;
      If Reg.OpenKey(SelectedGame.RegistryKey,False) then
        begin
          If Reg.ValueExists(InstalledPlugins[Index].Description) then
            Result := Reg.DeleteValue(InstalledPlugins[Index].Description)
          else
            Result := False;
          Reg.CloseKey;
        end
      else Result := False;
    finally
      Reg.Free;
    end;
  end  
else Result := False;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.PluginsLibraryIndexOfDescription(const Description: String): Integer;
begin
For Result := Low(fPluginsLibrary) to High(fPluginsLibrary) do
  If AnsiSameText(fPluginsLibrary[Result].Description,Description) then Exit;
Result := -1;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.PluginsLibraryIndexOfFilePath(const FilePath: String): Integer;
begin
For Result := Low(fPluginsLibrary) to High(fPluginsLibrary) do
  If AnsiSameText(fPluginsLibrary[Result].FilePath,FilePath) then Exit;
Result := -1;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.PluginsLibraryAdd(const Description, FilePath: String): Integer;
begin
Result := PluginsLibraryIndexOfDescription(Description);
If Result >= 0 then
  fPluginsLibrary[Result].FilePath := FilePath
else
  begin
    SetLength(fPluginsLibrary,Length(fPluginsLibrary) + 1);
    Result := High(fPluginsLibrary);
    fPluginsLibrary[Result].Description := Description;
    fPluginsLibrary[Result].FilePath := FilePath;
  end;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.PluginsLibraryRemove(Index: Integer): Boolean;
var
  i:  Integer;
begin
If (Index >= Low(fPluginsLibrary)) and (Index <= High(fPluginsLibrary)) then
  begin
    For i := Index to Pred(High(fPluginsLibrary)) do
      fPluginsLibrary[i] := fPluginsLibrary[i + 1];
    SetLength(fPluginsLibrary,Length(fPluginsLibrary) - 1);
    Result := True;   
  end
else Result := False;
end;

//------------------------------------------------------------------------------

procedure TACCPluginInstaller.PluginsLibraryValidate;
var
  i:  Integer;
begin
For i := High(fPluginsLibrary) downto Low(fPluginsLibrary) do
  If not FileExists(fPluginsLibrary[i].FilePath) then PluginsLibraryRemove(i);
end;

end.
