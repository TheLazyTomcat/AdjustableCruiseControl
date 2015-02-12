@echo off

pushd .

cd ..\Plugin\Delphi
dcc32.exe -Q -B ACC_Plugin.dpr

cd ..\Lazarus
lazbuild -B --bm=Release_win_x86 ACC_Plugin.lpi
lazbuild -B --bm=Release_win_x64 ACC_Plugin.lpi
lazbuild -B --bm=Debug_win_x86 ACC_Plugin.lpi
lazbuild -B --bm=Debug_win_x64 ACC_Plugin.lpi

popd