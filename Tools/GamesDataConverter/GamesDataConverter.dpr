program GamesDataConverter;

{$APPTYPE CONSOLE}

uses
  FastMM4,
  SysUtils,
  Classes,
  
  CRC32                in '..\..\MainProgram\Libs\CRC32.pas',
  MD5                  in '..\..\MainProgram\Libs\MD5.pas',
  FloatHex             in '..\..\MainProgram\Libs\FloatHex.pas',
  DefRegistry          in '..\..\MainProgram\Libs\DefRegistry.pas',
  SimpleCompress       in '..\..\MainProgram\Libs\SimpleCompress.pas',
  StringEncryptionUnit in '..\..\MainProgram\Libs\StringEncryptionUnit.pas',

  ACC_Common    in '..\..\MainProgram\ACC_Common.pas',
  ACC_GamesData in '..\..\MainProgram\ACC_GamesData.pas';


type
  TProgramParams = record
    InputFile:      String;
    InputFormat:    Integer;
    OutputFile:     String;
    OutputFormat:   Integer;
    GameIconFiles:  Array of String;
  end;

const
  FormatStrings: Array[0..4] of String = ('INI','BIN','INI1','INI2','BIN1');

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
    If GetParamIndex('-if',Index) then
      ProgramParams.InputFormat := ResolveFormat(ParamStr(Succ(Index)))
    else Exit;
    If GetParamIndex('-o',Index) then
      ProgramParams.OutputFile := ExpandFileName(ParamStr(Succ(Index)))
    else
      ProgramParams.OutputFile := ProgramParams.OutputFile;
    If GetParamIndex('-of',Index) then
      ProgramParams.OutputFormat := ResolveFormat(ParamStr(Succ(Index)))
    else Exit;
    If GetParamIndex('-ic',Index) then
      If Index < ParamCount then
        begin
          SetLength(ProgramParams.GameIconFiles,ParamCount - Index);
          For i := Succ(Index) to ParamCount do
            ProgramParams.GameIconFiles[i] := ExpandFileName(ParamStr(i));
        end;
    Result := FileExists(ProgramParams.InputFile) and (ProgramParams.InputFormat >= 0) and
              (ProgramParams.OutputFormat >= 0) and DirectoryExists(ExtractFileDir(ProgramParams.OutputFile));
  end;

//------------------------------------------------------------------------------

  Function Convert: Boolean;
  var
    DataManager:  TGamesDataManager;
    IconStream:   TMemoryStream;
    i:            Integer;
  begin
    try
      Result := False;
      DataManager := TGamesDataManager.Create;
      try
        case ProgramParams.InputFormat of
          0,2,3:  If not DataManager.LoadFromIni(ProgramParams.InputFile) then Exit;
          1,4:    If not DataManager.LoadFromBin(ProgramParams.InputFile) then Exit;
        else
          Exit;
        end;
        If Length(ProgramParams.GameIconFiles) > 0 then
          begin
            IconStream := TMemoryStream.Create;
            try
              For i := Low(ProgramParams.GameIconFiles) to High(ProgramParams.GameIconFiles) do
                begin
                  IconStream.LoadFromFile(ProgramParams.GameIconFiles[i]);
                  DataManager.GameIcons.AddItem(ChangeFileExt(ExtractFileName(ProgramParams.GameIconFiles[i]),''),IconStream);
                end;
            finally
              IconStream.Free;
            end;
          end;
        case ProgramParams.OutputFormat of
          0,3:  Result := DataManager.SaveToIni(ProgramParams.OutputFile,IFS_2_0);
          2:    Result := DataManager.SaveToIni(ProgramParams.OutputFile,IFS_1_0);
          1,4:  Result := DataManager.SaveToBin(ProgramParams.OutputFile,BFS_1_0);
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
    WriteLn('GamesDataConverter -i InputFile -if InpuFileFormat [-o OutputFile] -of OtuputFileFormat [-ic GameIconFile_1 [GameIconFile_2 ..]]');
    WriteLn;
    WriteLn(' InputFileFormat - can be one of following: INI, BIN');
    WriteLn('OutputFileFormat - can be one of following: INI, BIN, INI1, INI2, BIN1');
    WriteLn('                   INI maps to INI2; BIN maps to BIN1');
    WriteLn('      OutputFile - when not specified, output file has the same name as input');
    WriteLn; WriteLn;
    Write('Press enter to end the program...'); ReadLn;
  end;
end.
