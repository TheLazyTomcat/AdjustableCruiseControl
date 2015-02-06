@echo off

pushd .

cd Tools\GamesDataConverter
dcc32.exe -Q -B GamesDataConverter.dpr

cd ..\RegistryCleaner
dcc32.exe -Q -B RegistryCleaner.dpr

cd ..\SplashPreprocessor
dcc32.exe -Q -B SplashPreprocessor.dpr

popd