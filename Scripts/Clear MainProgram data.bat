@echo off

rd ..\MainProgram\Delphi\Release\win_x86\Data /S /Q 
rd ..\MainProgram\Lazarus\Release\win_x86\Data /S /Q
rd ..\MainProgram\Lazarus\Release\win_x64\Data /S /Q
rd ..\MainProgram\Lazarus\Debug\win_x86\Data /S /Q
del ..\MainProgram\Lazarus\Debug\win_x86\ACC.dbg /S /Q
rd ..\MainProgram\Lazarus\Debug\win_x64\Data /S /Q
del ..\MainProgram\Lazarus\Debug\win_x64\ACC.dbg /S /Q