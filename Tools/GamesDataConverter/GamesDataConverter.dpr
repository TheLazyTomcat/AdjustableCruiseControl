{-------------------------------------------------------------------------------

  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

-------------------------------------------------------------------------------}
program GamesDataConverter;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,

  ACC_Common    in '..\..\Source\ACC_Common.pas',
  ACC_GamesData in '..\..\Source\ACC_GamesData.pas';


type
  TProgramParams = record
    InputFile:      String;
    OutputFile:     String;
    OutputFormat:   Integer;
    GameIconFiles:  Array of String;
  end;

const
  FormatStrings: Array[0..6] of String = ('INI','BIN','INI1','INI2','INI2.1','BIN1','BIN1.1');

var
  ProgramParams:  TProgramParams;

//------------------------------------------------------------------------------

  Function ResolveProgramParams: Boolean;
  var
    i,Index: Integer;

    Function GetParamIndex(const ParamString: String; out Idx: Integer): Boolean;
    var
      ii: Integer;
    begin
      Result := False;
      For ii := 0 to ParamCount do
        If AnsiSameText(ParamStr(ii),ParamString) then
          begin
            Idx := ii;
            Result := True;
            Break;
          end;
    end;

    Function ResolveFormat(const FormatString: String): Integer;
    begin
      For Result := Low(FormatStrings) to High(FormatStrings) do
        If AnsiSameText(FormatStrings[Result],FormatString) then Exit;
      Result := -1;
    end;

  begin
    Result := False;
    If GetParamIndex('-i',Index) then
      ProgramParams.InputFile := ExpandFileName(ParamStr(Succ(Index)))
    else Exit;
    If GetParamIndex('-o',Index) then
      ProgramParams.OutputFile := ExpandFileName(ParamStr(Succ(Index)))
    else
      ProgramParams.OutputFile := ProgramParams.InputFile;
    If GetParamIndex('-of',Index) then
      ProgramParams.OutputFormat := ResolveFormat(ParamStr(Succ(Index)))
    else Exit;
    If GetParamIndex('-ic',Index) then
      If Index < ParamCount then
        begin
          SetLength(ProgramParams.GameIconFiles,ParamCount - Index);
          For i := Succ(Index) to ParamCount do
            ProgramParams.GameIconFiles[i - Succ(Index)] := ExpandFileName(ParamStr(i));
        end;
    Result := FileExists(ProgramParams.InputFile) and (ProgramParams.OutputFormat >= 0) and
              DirectoryExists(ExtractFileDir(ProgramParams.OutputFile));
  end;

//------------------------------------------------------------------------------

  Function Convert: Boolean;
  var
    DataManager:  TGamesDataManager;
    IconStream:   TMemoryStream;
    i:            Integer;
  begin
    try
      DataManager := TGamesDataManager.Create;
      try
        DataManager.LoadFrom(ProgramParams.InputFile);
        If Length(ProgramParams.GameIconFiles) > 0 then
          begin
            IconStream := TMemoryStream.Create;
            try
              For i := Low(ProgramParams.GameIconFiles) to High(ProgramParams.GameIconFiles) do
                begin
                  IconStream.Clear;
                  IconStream.LoadFromFile(ProgramParams.GameIconFiles[i]);
                  DataManager.GameIcons.AddItem(ChangeFileExt(ExtractFileName(ProgramParams.GameIconFiles[i]),''),IconStream);
                end;
            finally
              IconStream.Free;
            end;
          end;
        case ProgramParams.OutputFormat of
          2:    Result := DataManager.SaveToIni(ProgramParams.OutputFile,IFS_1_0);
          3:    Result := DataManager.SaveToIni(ProgramParams.OutputFile,IFS_2_0);
          0,4:  Result := DataManager.SaveToIni(ProgramParams.OutputFile,IFS_2_1);
          5:    Result := DataManager.SaveToBin(ProgramParams.OutputFile,BFS_1_0);          
          1,6:  Result := DataManager.SaveToBin(ProgramParams.OutputFile,BFS_1_1);
        else
          Result := False;
        end;
      finally
        DataManager.Free;
      end;
    except
      Result := False;
    end;
  end;

//------------------------------------------------------------------------------

begin
WriteLn('======================================');
WriteLn('=  ACC Tools - Games Data Converter  =');
WriteLn('======================================');
If ResolveProgramParams then
  begin
    If Convert then WriteLn('Conversion successful.')
      else WriteLn('Coversion was not successful.');
  end
else
  begin
    WriteLn;
    WriteLn('Usage:');
    WriteLn;
    WriteLn('GamesDataConverter -i InputFile -of OtuputFileFormat [-o OutputFile] [-ic GameIconFile_1 [GameIconFile_2 ...]]');
    WriteLn;
    WriteLn('OutputFileFormat - can be one of following: INI, BIN, INI2, INI2.1, BIN1,');
    WriteLn('                   BIN1.1');
    WriteLn('                   INI maps to INI2.1; BIN maps to BIN1.1');
    WriteLn('      OutputFile - when not specified, output file has the same name as input');
    WriteLn; WriteLn;
    Write('Press enter to end the program...'); ReadLn;
  end;
end.
