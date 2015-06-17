@echo off

pushd .

cd ..\Tools\GamesDataConverter
dcc32.exe -Q -B GamesDataConverter.dpr

cd ..\RegistryCleaner
dcc32.exe -Q -B RegistryCleaner.dpr

cd ..\SplashPreprocessor
dcc32.exe -Q -B SplashPreprocessor.dpr

cd ..\PluginInstaller\ExternalTester
lazbuild -B --bm=Release_win_x86 ExternalTester.lpi
lazbuild -B --bm=Release_win_x64 ExternalTester.lpi
lazbuild -B --bm=Debug_win_x86 ExternalTester.lpi
lazbuild -B --bm=Debug_win_x64 ExternalTester.lpi

cd ..\Resources
call "Build Resources.bat"

cd ..\
dcc32.exe -Q -B PluginInstaller.dpr

popd