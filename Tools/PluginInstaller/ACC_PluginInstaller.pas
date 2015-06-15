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

  TInstalledPlugin = record
    Description:  String;
    FilePath:     String;  
  end;

type
  TACCPluginInstaller = class(TObject)
  private
    fRunningInWoW64:    Boolean;
    fKnownGames:        Array of TGameEntry;
    fSelectedGameIdx:   Integer;
    fInstalledPlugins:  Array of TInstalledPlugin;
    Function GetKnownGameCount: Integer;
    Function GetKnownGames(Index: Integer): TGameEntry;
    Function GetSelectedGame: TGameEntry;
    Function GetInstalledPluginCount: Integer;
    Function GetInstalledPlugins(Index: Integer): TInstalledPlugin;
  protected
    Function KnownGamesCheckIndex(Index: Integer): Boolean;
    procedure CheckWoW64; virtual;
    procedure FillKnownGames; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    Function SelectGame(Index: Integer): Boolean; virtual;
    Function LoadIntalledPlugins: Integer; virtual;
    Function RemoveInstalledPlugin(Index: Integer): Boolean; virtual;
    Function InstallPlugin(const Description, FilePath: String): Boolean; virtual;
    Function IndexOfInstalledPlugin(Str: String; FilePath: Boolean = False): Integer; virtual;
    property KnownGames[Index: Integer]: TGameEntry read GetKnownGames;
    property InstalledPlugins[Index: Integer]: TInstalledPlugin read GetInstalledPlugins;
  published
    property RunningInWoW64: Boolean read fRunningInWoW64;
    property KnownGameCount: Integer read GetKnownGameCount;
    property SelectedGameIdx: Integer read fSelectedGameIdx;
    property SelectedGame: TGameEntry read GetSelectedGame;
    property InstallegPluginCount: Integer read GetInstalledPluginCount;
  end;


implementation

uses
  SysUtils, Classes, Registry, DefRegistry;

const
  KnownGamesList: array[0..1] of TGameEntry = (
    (Valid:           True;
     Title:           'Euro Truck Simulator 2 32bit';
     RegistryRoot:    HKEY_LOCAL_MACHINE;
     RegistryKey:     'Software\SCS Software\Euro Truck Simulator 2\Plugins';
     FullRegistryKey: 'HKEY_LOCAL_MACHINE\Software\SCS Software\Euro Truck Simulator 2\Plugins';
     Is64bit:         False;
     SystemValid:     False),
     
    (Valid:           True;
     Title:           'Euro Truck Simulator 2 64bit';
     RegistryRoot:    HKEY_LOCAL_MACHINE;
     RegistryKey:     'Software\Wow6432Node\SCS Software\Euro Truck Simulator 2\Plugins';
     FullRegistryKey: 'HKEY_LOCAL_MACHINE\Software\Wow6432Node\SCS Software\Euro Truck Simulator 2\Plugins';
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

//==============================================================================

Function TACCPluginInstaller.GetKnownGameCount: Integer;
begin
Result := Length(fKnownGames);
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetKnownGames(Index: Integer): TGameEntry;
begin
If KnownGamesCheckIndex(Index) then
  Result := fKnownGames[Index]
else
  raise Exception.CreateFmt('TACCPluginInstaller.GetKnownGames: Index (%d) out of bounds.',[Index]);
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetSelectedGame: TGameEntry;
begin
If KnownGamesCheckIndex(fSelectedGameIdx) then
  Result := GetKnownGames(fSelectedGameIdx)
else
  Result := EmptyGameEntry;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetInstalledPluginCount: Integer;
begin
Result := Length(fInstalledPlugins);
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.GetInstalledPlugins(Index: Integer): TInstalledPlugin;
begin
If (Index >= Low(fInstalledPlugins)) and (Index <= High(fInstalledPlugins)) then
  Result := fInstalledPlugins[Index]
else
  raise Exception.CreateFmt('TACCPluginInstaller.GetInstalledPlugins: Index (%d) out of bounds.',[Index]);
end;

//==============================================================================

Function TACCPluginInstaller.KnownGamesCheckIndex(Index: Integer): Boolean;
begin
Result := (Index >= Low(fKnownGames)) and (Index <= High(fKnownGames));
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
    IsWoW64Process := GetProcAddress(ModuleHandle,'IsWoW64Process');
    If Assigned(IsWoW64Process) then
      begin
        If IsWow64Process(GetCurrentProcess,@ResultValue) then fRunningInWoW64 := ResultValue
          else raise Exception.CreateFmt('TACCPluginInstaller.CheckWoW64: IsWoW64Process failed with error %x.',[GetLastError]);
      end;
  end
else raise Exception.CreateFmt('TACCPluginInstaller.CheckWoW64: Unable to get handle to module kernel32.dll (%x).',[GetLastError]);
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

//==============================================================================

constructor TACCPluginInstaller.Create;
begin
inherited Create;
CheckWoW64;
FillKnownGames;
fSelectedGameIdx := -1;
end;

//------------------------------------------------------------------------------

destructor TACCPluginInstaller.Destroy;
begin
inherited;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.SelectGame(Index: Integer): Boolean;
begin
fSelectedGameIdx := Index;
Result := KnownGamesCheckIndex(Index);
LoadIntalledPlugins;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.LoadIntalledPlugins: Integer;
var
  Reg:        TDefRegistry;
  TempList:   TStringList;
  i:          Integer;
  ValueInfo:  TRegDataInfo;
begin
SetLength(fInstalledPlugins,0);
If SelectedGame.Valid and SelectedGame.SystemValid then
  begin
    Reg := TDefRegistry.Create;
    try
      Reg.RootKey := SelectedGame.RegistryRoot;
      If Reg.OpenKeyReadOnly(SelectedGame.RegistryKey) then
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

Function TACCPluginInstaller.RemoveInstalledPlugin(Index: Integer): Boolean;
var
  Reg:  TRegistry;
begin
If (Index >= Low(fInstalledPlugins)) and (Index <= High(fInstalledPlugins)) then
  begin
    Reg := TRegistry.Create;
    try
      with InstalledPlugins[Index] do
        begin
          Reg.RootKey := SelectedGame.RegistryRoot;
          If Reg.OpenKey(SelectedGame.RegistryKey,False) then
            begin
              If Reg.ValueExists(Description) then
                Result := Reg.DeleteValue(Description)
              else
                Result := False;
              Reg.CloseKey;
            end
          else Result := False;  
        end;
    finally
      Reg.Free;
    end;
  end  
else Result := False;
end;

//------------------------------------------------------------------------------

Function TACCPluginInstaller.InstallPlugin(const Description, FilePath: String): Boolean;
var
  Reg: TRegistry;
begin
Result := False;
If SelectedGame.Valid and SelectedGame.SystemValid then
  begin
    Reg := TRegistry.Create;
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

Function TACCPluginInstaller.IndexOfInstalledPlugin(Str: String; FilePath: Boolean = False): Integer;
begin
For Result := Low(fInstalledPlugins) to High(fInstalledPlugins) do
  If FilePath then
    begin
      If AnsiSameText(fInstalledPlugins[Result].FilePath,Str) then Exit;
    end
  else
    begin
      If AnsiSameText(fInstalledPlugins[Result].Description,Str) then Exit;
    end;
Result := -1;
end;

end.
