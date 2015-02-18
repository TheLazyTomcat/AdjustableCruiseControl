@echo off

if exist ..\Release rd ..\Release /s /q

mkdir ..\Release
mkdir ..\Release\D32
mkdir ..\Release\L32
mkdir ..\Release\L64
mkdir ..\Release\Tools

copy ..\Documents\release_readme.txt ..\Release\readme.txt
copy ..\Documents\release_license.txt ..\Release\license.txt
copy ..\Documents\RegistryCleaner_readme.txt ..\Release\Tools\RegistryCleaner_readme.txt

copy ..\MainProgram\Delphi\Release\win_x86\ACC.exe ..\Release\D32\ACC.exe
copy ..\Plugin\Delphi\Release\win_x86\ACC_Plugin.dll ..\Release\D32\ACC_Plugin.dll

copy ..\MainProgram\Lazarus\Release\win_x86\ACC.exe ..\Release\L32\ACC.exe
copy ..\Plugin\Lazarus\Release\win_x86\ACC_Plugin.dll ..\Release\L32\ACC_Plugin.dll

copy ..\MainProgram\Lazarus\Release\win_x64\ACC.exe ..\Release\L64\ACC.exe
copy ..\Plugin\Lazarus\Release\win_x64\ACC_Plugin.dll ..\Release\L64\ACC_Plugin.dll

copy ..\Tools\RegistryCleaner\RegistryCleaner.exe ..\Release\Tools\RegistryCleaner.exe