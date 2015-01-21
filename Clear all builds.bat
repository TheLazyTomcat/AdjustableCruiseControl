rd MainProgram\Delphi\Release\win_x86\Data /S /Q
del MainProgram\Delphi\Release\win_x86\ACC.exe /S /Q

rd MainProgram\Lazarus\Release\win_x86\Data /S /Q
del MainProgram\Lazarus\Release\win_x86\ACC.exe /S /Q

rd MainProgram\Lazarus\Release\win_x64\Data /S /Q
del MainProgram\Lazarus\Release\win_x64\ACC.exe /S /Q

rd MainProgram\Lazarus\Debug\win_x86\Data /S /Q
del MainProgram\Lazarus\Debug\win_x86\ACC.exe /S /Q
del MainProgram\Lazarus\Debug\win_x86\ACC.dbg /S /Q

rd MainProgram\Lazarus\Debug\win_x64\Data /S /Q
del MainProgram\Lazarus\Debug\win_x64\ACC.exe /S /Q
del MainProgram\Lazarus\Debug\win_x64\ACC.dbg /S /Q

del Plugin\Delphi\Release\win_x86\ACC_Plugin.dll /S /Q
del Plugin\Lazarus\Release\win_x86\ACC_Plugin.dll /S /Q
del Plugin\Lazarus\Release\win_x64\ACC_Plugin.dll /S /Q
del Plugin\Lazarus\Debug\win_x86\ACC_Plugin.dll /S /Q
del Plugin\Lazarus\Debug\win_x86\ACC_Plugin.dbg /S /Q
del Plugin\Lazarus\Debug\win_x64\ACC_Plugin.dll /S /Q
del Plugin\Lazarus\Debug\win_x64\ACC_Plugin.dbg /S /Q