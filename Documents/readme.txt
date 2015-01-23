================================================================================

                            Adjustable Cruise Control

                                 version 2.2.x

================================================================================

Description
------------------------------
Adjustable Cruise Control (ACC) is an application that allows you to set cruise 
control system speed in supported games to a predefined value by pressing 
selected key or keys combination, effectively expanding cruise control for a new
feature. It is intended only for trucking games developed by SCS Software.



Supported games
------------------------------
Currently, there are two groups of supported games, those supported fully and 
those supported only partially. Differecne between these two groups is that for
partially fupported games, the program cannot obtain actual vehicle speed and
therefore some of the program features will not work for such a game.
You should note that only listed versions are supported. For example, if the ACC
supports only version 1.0 of some game, and you happen to have version 1.1, 
it will not work. Another things also plays its role in distinguishing the game 
versions, for example distribution system or language of the game.
Games and their versions listed bellow are only those supported by this program
"out-of-the-box", the list can be expanded by installing data updates.

Fully supported games:

  18 Wheels of Steel - Haulin 1.0 EN (CD version)
  18 Wheels of Steel - Haulin 1.06 EN (CD version)
  18 Wheels of Steel - American Long Haul 1.0 EN (CD version)
  18 Wheels of Steel - American Long Haul 1.01c EN (CD version)
  18 Wheels of Steel - American Long Haul 1.02c EN (CD version)
  Euro Truck Simulator 1.0 EN (Reloaded crack)
  Euro Truck Simulator 1.2 EN (CD version)
  Euro Truck Simulator 1.3 EN (CD version)
  Euro Truck Simulator 1.0 GE (CD version)
  Euro Truck Simulator Gold 1.1 GE (CD version)
  Euro Truck Simulator 1.2 GE (CD version)
  Euro Truck Simulator 1.3 GE (CD version)
  Euro Truck Simulator 1.0 CZ/SK/HU/RO (CD version)
  Euro Truck Simulator 1.2 CZ/SK/HU/RO (CD version)
  Euro Truck Simulator 1.3 CZ/SK/HU/RO (CD version)
  18 Wheels of Steel - Extreme Trucker 1.0 EN (CD version)
  18 Wheels of Steel - Extreme Trucker 2 1.0 EN (CD version)
  18 Wheels of Steel - Extreme Trucker 2 1.0 EN (DD version)

Partially supported games:

  18 Wheels of Steel - Convoy 1.0 EN (CD verze)
  18 Wheels of Steel - Convoy 1.02 EN (CD verze)
  German Truck Simulator 1.0 GE (CD verze)
  German Truck Simulator 1.02 GE (CD verze)
  German Truck Simulator 1.03 GE (CD verze)
  German Truck Simulator 1.04 GE (CD verze)
  German Truck Simulator Edition Austria 1.31 GE (CD verze)
  German Truck Simulator Edition Austria 1.32 GE (CD verze)
  UK Truck Simulator 1.02 EN (CD verze)
  UK Truck Simulator 1.04 EN (CD verze)
  UK Truck Simulator 1.05 EN (CD verze)
  UK Truck Simulator 1.06 EN (CD verze)
  UK Truck Simulator 1.07 EN (CD verze)
  UK Truck Simulator 1.32 EN (CD verze)
  Euro Truck Simulator 2 1.4.8 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.4.8 Multi (Steam verze)
  Euro Truck Simulator 2 1.4.12 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.4.12 Multi (Steam verze)
  Euro Truck Simulator 2 1.5.2 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.5.2 Multi (Steam verze)
  Euro Truck Simulator 2 1.6 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.6 Multi (Steam verze)
  Euro Truck Simulator 2 1.6.1 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.6.1 Multi (Steam verze)
  Euro Truck Simulator 2 1.7 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.7 Multi (Steam verze)
  Euro Truck Simulator 2 1.7.1 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.7.1 Multi (Steam verze)
  Euro Truck Simulator 2 1.8.2.3 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.8.2.3 Multi (Steam verze)
  Euro Truck Simulator 2 1.9.3 Multi (Steam public beta)
  Euro Truck Simulator 2 1.9.4 Multi (Steam public beta)
  Euro Truck Simulator 2 1.9.5 Multi (Steam public beta)
  Euro Truck Simulator 2 1.9.6 Multi (Steam public beta)
  Euro Truck Simulator 2 1.9.22 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.9.22 Multi (Steam verze)
  Euro Truck Simulator 2 1.10.1 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.10.1 Multi (Steam verze)
  Euro Truck Simulator 2 1.11.1 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.11.1 Multi (Steam verze)
  Euro Truck Simulator 2 1.12.1 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.12.1 Multi (Steam verze)
  Euro Truck Simulator 2 1.13.3 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.13.2 - 1.13.3 Multi (Steam verze)
  Euro Truck Simulator 2 1.13.4 Multi (Steam verze)
  Euro Truck Simulator 2 1.14.2 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.14.2 Multi (Steam verze)
  Euro Truck Simulator 2 1.15.1 Multi (DD & CD verze)
  Euro Truck Simulator 2 1.15.1 Multi (Steam verze)
  
  
  
Parts of the program
------------------------------
ACC can be divided into two parts - the program itself (EXE file) and Starter
Plugin (DLL file).
ACC is currently distributed in three versions or builds (each program and the 
plugin has these three builds):

 - First, found in folder D32, is 32bit version compiled in Delphi. 
 - Second build, located in folder L32, is also 32bit but compiled in Lazarus. 
 - Third is located in folder L64 and it is a 64bit version compiled in Lazarus.
  
All three versions have the same features, but those compiled in Lazarus has 
slightly better user interface - namely you can set speeds more precisely and 
there is no rounding error when changing from one speed unit to another 
(e.g. km/h -> mph). See Installation section below for instruction what version
you should choose. 

NOTE - Starter plugin can be used only in games supporting Telemetry API. 
       At his moment, only in Euro Truck Simulator 2 from version 1.4 up. 



Installation
------------------------------
First select a version/build. If you are running 32bit system, use version 
from folder called L32. If you are running 64bit system, you can use any ACC 
build. But If you want to use ACC in 64bit game, you must use L64 build. 
Use D32 build only when you have problems with Lxx builds. But note that the 
plugin has different rules given by its nature (dynamically loaded library).
Following table should help you decide which build of a program and plugin to 
choose (E = program, P = plugin):

|=======================||=======|=======|=======||=======|=======|=======|
|   OS and Game bits    || D32 E | L32 E | L64 E || D32 P | L32 P | L64 P |
|=======================||=======|=======|=======||=======|=======|=======|
| 32bit OS + 32bit Game ||   *   |   *!  |   -   ||   *   |   *!  |   -   |
|-----------------------||-------|-------|-------||-------|-------|-------| 
| 64bit OS + 32bit Game ||   *   |   *   |   *!  ||   *   |   *!  |   -   |
|-----------------------||-------|-------|-------||-------|-------|-------|    
| 64bit OS + 64bit Game ||   -   |   -   |   *!  ||   -   |   -   |   *!  |
|-----------------------||-------|-------|-------||-------|-------|-------| 

* you can use this build
- you cannot use this build (it will not work)
! you are recommended to use this build

Plugin and program are compatible in all its versions, meaning you can use 
plugin from different build than the program and they will work together.

Installation itself is very easy, just extract ACC.EXE from build you have 
selected to any folder on your hard drive. You should select a folder where you 
have full access rights, because the program needs to write some files to it at 
the first run.
If you want to use Starter Plugin (see "How to use the program" section for 
details about it), you have to do three things. First, make sure the program 
stays in the folder where you have put it. Second, run the program and then 
close it again - it will save its own path to the registry (Starter Plugin will 
use this information). And third, you have to install the plugin itself. There 
are two ways how to do it.

First way (recomended for inexperienced users) is to place the plugin (DLL file)
to a default plugin folder. It is a subfolder named "plugins" located in the 
folder where game main binary is located. Here are some examples so you know 
what to look for (actual paths can differ significantly on your system, 
depending on how or where you have installed the game and what version (32 or 
64 bit) you are using):

  C:\Program Files\Euro Truck Simulator 2\bin\win_x86\plugins
  C:\Steam\SteamApps\common\Euro Truck Simulator 2\bin\win_x86\plugins
  R:\ETS 2\bin\win_x64\plugins
  
If the \plugins subfolder does not exist, create it.

Second way involves manual change in the windows registry, so avoid it if you 
have little experience with registry or leave it on someone who knows the stuff.
Place the plugin file anywhere on your disk (it must stay where you put it, so 
select appropriate folder). Then open registry editor and navigate to key 
"HKEY_LOCAL_MACHINE\SOFTWARE\SCS Software\<GAME_NAME>\Plugins", where 
<GAME_NAME> is the name of game you want to use the plugin in (for example 
"Euro Truck Simulator 2"). If such key does not exist, create it. Create new 
string value (name of the value is irrelevant) in this key and store full path
to the plugin file in the data of this value.



How to use the program
------------------------------
For the program to work, let it run in the background while playing the game.
It does not matter whther you start the program before you start the game or
when the game is already running. 



Program features
------------------------------  


  
Common problems
------------------------------



How the program works
------------------------------



Source code
------------------------------
You can get copy of full source code on either of the following git repository:

https://bitbucket.org/ncs-sniper/adjustablecruisecontrol
https://github.com/ncs-sniper/AdjustableCruiseControl



Licencing
------------------------------
This program is licensed under the terms of Mozilla Public License Version 2.0. 
You can find full text of this license in file license.txt or on web page 
https://www.mozilla.org/MPL/2.0/.



Authors, contacts
------------------------------
František Milt, frantisek.milt@gmail.com



Copyright
------------------------------
©2013-2015 František Milt, all rights reserved