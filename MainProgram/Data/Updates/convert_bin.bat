@echo off
set ConverterPath=..\..\..\Tools\GamesDataConverter\GamesDataConverter.exe
For %%F in (*.ini) do (
  start %ConverterPath% -i "%%F" -o "%%~nF.ugdb" -of bin
)
rem Special cases (inclusion of an icon): 
start %ConverterPath% -i 2016-02-07-00.ini -o 2016-02-07-00.ugdb -of bin -ic ..\..\Resources\GameIcons\ATS.png
start %ConverterPath% -i 2016-02-07-CU[2.3.2].ini -o 2016-02-07-CU[2.3.2].ugdb -of bin -ic ..\..\Resources\GameIcons\ATS.png