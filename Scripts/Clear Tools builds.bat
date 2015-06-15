@echo off

del ..\Tools\GamesDataConverter\GamesDataConverter.exe /S /Q
del ..\Tools\RegistryCleaner\RegistryCleaner.exe /S /Q
del ..\Tools\SplashPreprocessor\SplashPreprocessor.exe /S /Q

del ..\Tools\PluginInstaller\PluginInstaller.exe /S /Q  
del ..\Tools\PluginInstaller\ExternalTester\Debug\win_x64\ExternalTester.exe /S /Q
del ..\Tools\PluginInstaller\ExternalTester\Debug\win_x86\ExternalTester.exe /S /Q
del ..\Tools\PluginInstaller\ExternalTester\Release\win_x64\ExternalTester.exe /S /Q
del ..\Tools\PluginInstaller\ExternalTester\Release\win_x86\ExternalTester.exe /S /Q