@echo off

pushd .

cd MainProgram\Delphi
dcc32.exe -Q -B ACC.dpr

cd ..\Lazarus
lazbuild -B --bm=Release_win_x86 ACC.lpi
lazbuild -B --bm=Release_win_x64 ACC.lpi
lazbuild -B --bm=Debug_win_x86 ACC.lpi
lazbuild -B --bm=Debug_win_x64 ACC.lpi

popd