﻿================================================================================

                            Adjustable Cruise Control

                                 version 2.4.0

================================================================================

Index
------------------------------
Content of this document divided into individual parts, with line numbers at
which each part starts.

  Index ...................................................   9
  Description .............................................  34
  Supported games .........................................  43
  Parts of the program .................................... 188
  Installation ............................................ 211
  How to use the program .................................. 280
  How to install an update ................................ 300
  Program features ........................................ 332
  Common problems ......................................... 390
  How the program works ................................... 455
  Changelog ............................................... 487
  Known issues ............................................ 568
  Source code ............................................. 575
  Licensing ............................................... 584
  Authors, contacts ....................................... 592
  Links ................................................... 599
  Copyright ............................................... 605



Description
------------------------------
Adjustable Cruise Control (ACC) is an application that allows you to set cruise
control system speed in supported games to a predefined value by pressing
selected key or keys combination, effectively expanding cruise control for a new
feature. It is intended only for trucking games developed by SCS Software.



Supported games
------------------------------
Currently, there are three groups of supported games. First group contains fully
supported games, second group are games that are fully supported only with
plugin, and third group are games supported only partially. Difference between
fully and partially supported game is, that for partially supported games, the
program cannot obtain actual vehicle speed and therefore some of the program
features will not work for such a game. In fully supported games, vehicle speed
is obtained directly from game memory, while in games supported fully with
plugin, the speed is obtained by a plugin from Telemetry API and send to the
main program. This means that for such funcionality, a plugin must be used and
loaded into game.
You should note that only listed versions are supported. For example, if the ACC
supports only version 1.0 of some game, and you happen to have version 1.1,
it will not work. Another things also plays its role in distinguishing the game
versions, for example distribution system or language of the game.
Games and their versions listed below are only those supported by this program
"out-of-the-box", the list can be expanded by installing data updates.

Fully supported:

  18 Wheels of Steel - Haulin 1.0 EN, CD version
  18 Wheels of Steel - Haulin 1.06 EN, CD version
  18 Wheels of Steel - American Long Haul 1.0 EN, CD version
  18 Wheels of Steel - American Long Haul 1.01c EN, CD version
  18 Wheels of Steel - American Long Haul 1.02c EN, CD version
  Euro Truck Simulator 1.0 EN, Reloaded crack
  Euro Truck Simulator 1.2 EN, CD version
  Euro Truck Simulator 1.3 EN, CD version
  Euro Truck Simulator 1.0 GE, CD version
  Euro Truck Simulator Gold 1.1 GE, CD version
  Euro Truck Simulator 1.2 GE, CD version
  Euro Truck Simulator 1.3 GE, CD version
  Euro Truck Simulator 1.0 CZ/SK/HU/RO, CD version
  Euro Truck Simulator 1.2 CZ/SK/HU/RO, CD version
  Euro Truck Simulator 1.3 CZ/SK/HU/RO, CD version
  18 Wheels of Steel - Extreme Trucker 1.0 EN, CD version
  18 Wheels of Steel - Extreme Trucker 2 1.0 EN, CD version
  18 Wheels of Steel - Extreme Trucker 2 1.0 EN, DD version

Fully supported with plugin:

  Euro Truck Simulator 2 1.4.8 Multi, DD & CD version
  Euro Truck Simulator 2 1.4.8 Multi, Steam version
  Euro Truck Simulator 2 1.4.12 Multi, DD & CD version
  Euro Truck Simulator 2 1.4.12 Multi, Steam version
  Euro Truck Simulator 2 1.5.2 Multi, DD & CD version
  Euro Truck Simulator 2 1.5.2 Multi, Steam version
  Euro Truck Simulator 2 1.6 Multi, DD & CD version
  Euro Truck Simulator 2 1.6 Multi, Steam version
  Euro Truck Simulator 2 1.6.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.6.1 Multi, Steam version
  Euro Truck Simulator 2 1.7 Multi, DD & CD version
  Euro Truck Simulator 2 1.7 Multi, Steam version
  Euro Truck Simulator 2 1.7.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.7.1 Multi, Steam version
  Euro Truck Simulator 2 1.8.2.3 Multi, DD & CD version
  Euro Truck Simulator 2 1.8.2.3 Multi, Steam version
  Euro Truck Simulator 2 1.9.3 Multi, Steam public beta
  Euro Truck Simulator 2 1.9.4 Multi, Steam public beta
  Euro Truck Simulator 2 1.9.5 Multi, Steam public beta
  Euro Truck Simulator 2 1.9.6 Multi, Steam public beta
  Euro Truck Simulator 2 1.9.22 Multi, DD & CD version
  Euro Truck Simulator 2 1.9.22 Multi, Steam version
  Euro Truck Simulator 2 1.10.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.10.1 Multi, Steam version
  Euro Truck Simulator 2 1.11.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.11.1 Multi, Steam version
  Euro Truck Simulator 2 1.12.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.12.1 Multi, Steam version
  Euro Truck Simulator 2 1.13.3 Multi, DD & CD version
  Euro Truck Simulator 2 1.13.2 - 1.13.3 Multi, Steam version
  Euro Truck Simulator 2 1.13.4 Multi, Steam version
  Euro Truck Simulator 2 1.14.2 Multi, DD & CD version
  Euro Truck Simulator 2 1.14.2 Multi, Steam version
  Euro Truck Simulator 2 1.15.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.15.1 Multi, Steam version
  Euro Truck Simulator 2 1.15.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.16.0.3 Multi 64bit, Steam public beta
  Euro Truck Simulator 2 1.16.2 Multi, DD & CD version
  Euro Truck Simulator 2 1.16.2 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.16.2 - 1.16.3.1 Multi, Steam version
  Euro Truck Simulator 2 1.16.2 - 1.16.3.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.17.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.17.1 Multi, Steam version
  Euro Truck Simulator 2 1.17.1 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.17.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.18.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.18.1 Multi, Steam version
  Euro Truck Simulator 2 1.18.1 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.18.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.18.1.3 Multi, DD & CD version
  Euro Truck Simulator 2 1.18.1.3 Multi, Steam version
  Euro Truck Simulator 2 1.18.1.3 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.18.1.3 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.19.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.19.1 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.19.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.19.2.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.19.2.1 Multi, Steam version
  Euro Truck Simulator 2 1.19.2.1 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.19.2.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.20.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.20.1 Multi, Steam version
  Euro Truck Simulator 2 1.20.1 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.20.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.21.1 Multi, DD & CD version
  Euro Truck Simulator 2 1.21.1 Multi, Steam version
  Euro Truck Simulator 2 1.21.1 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.21.1 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.22.2 Multi, DD & CD version
  Euro Truck Simulator 2 1.22.2 Multi, Steam version
  Euro Truck Simulator 2 1.22.2 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.22.2 Multi 64bit, Steam version
  Euro Truck Simulator 2 1.22.2.3 - 1.22.2.4 Multi, DD & CD version
  Euro Truck Simulator 2 1.22.2.3 - 1.22.2.8 Multi, Steam version
  Euro Truck Simulator 2 1.22.2.3 - 1.22.2.4 Multi 64bit, DD & CD version
  Euro Truck Simulator 2 1.22.2.3 - 1.22.2.8 Multi 64bit, Steam version
  American Truck Simulator 1.0.0 Multi, Steam version
  American Truck Simulator 1.1.1 Multi, Steam version
  American Truck Simulator 1.1.1.3 Multi, Steam version

Partially supported:

  18 Wheels of Steel - Convoy 1.0 EN, CD version
  18 Wheels of Steel - Convoy 1.02 EN, CD version
  German Truck Simulator 1.0 GE, CD version
  German Truck Simulator 1.02 GE, CD version
  German Truck Simulator 1.03 GE, CD version
  German Truck Simulator 1.04 GE, CD version
  German Truck Simulator Edition Austria 1.31 GE, CD version
  German Truck Simulator Edition Austria 1.32 GE, CD version
  UK Truck Simulator 1.02 EN, CD version
  UK Truck Simulator 1.04 EN, CD version
  UK Truck Simulator 1.05 EN, CD version
  UK Truck Simulator 1.06 EN, CD version
  UK Truck Simulator 1.07 EN, CD version
  UK Truck Simulator 1.32 EN, CD version
  Trucks & Trailers 1.0 Multi, CD version
  Scania Truck Driving Simulator 1.1 Multi, DD & CD version
  Scania Truck Driving Simulator 1.6.1 Multi, DD & CD version
  Scania Truck Driving Simulator 1.6.1 Multi, Steam version



Parts of the program
------------------------------
ACC can be divided into two parts - the program itself (EXE file) and Plugin
(DLL file).
ACC is currently distributed in three versions or builds (each program and the
plugin has these three builds):

 - First, found in folder D32, is 32bit version compiled in Delphi
 - Second build, located in folder L32, is also 32bit but compiled in Lazarus
 - Third is located in folder L64 and it is a 64bit version compiled in Lazarus

All three versions have the same features, but those compiled in Lazarus has
slightly better user interface - namely you can set speeds more precisely and
there is no rounding error when changing from one speed unit to another
(e.g. km/h -> mph). See Installation section below for instruction on what
version you should choose.

NOTE - Plugin can be used only in games supporting Telemetry API. At this
       moment, Euro Truck Simulator 2 from version 1.4 up and any public version
       of American Truck Simulator.



Installation
------------------------------
First select a version/build. If you are running 32bit system, use version
from folder called L32. If you are running 64bit system, you can use any ACC
build. But If you want to use ACC in 64bit game, you must use L64 build.
Use D32 build only when you have problems with Lxx builds. But note that the
plugin has different rules given by its nature (dynamically loaded library).
Following table should help you decide which build of a program and plugin to
choose:

                        ||=======================||=======================|
                        ||        Program        ||        Plugin         |
|=======================||-------|-------|-------||-------|-------|-------|
|   OS and Game bits    ||  D32  |  L32  |  L64  ||  D32  |  L32  |  L64  |
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

Plugin and program are compatible in all their versions, meaning you can use
plugin from different build than the program and they will work together.

Installation itself is very easy, just extract ACC.EXE from build you have
selected to any folder on your hard drive. You should select a folder where you
have full access rights, because the program needs to write some files to it at
the first run.
If you want to use Plugin, you have to do three things. First, make sure
the program stays in the folder where you have put it. Second, run the program
and then close it again - it will save its own path to the registry (plugin will
use this information). And third, you have to install the plugin itself. There
are three ways how to do it.

First way is to place the plugin (DLL file) to a default plugin folder. It is a
subfolder named "plugins" located in the folder where game main binary is
located. Here are some examples so you know what to look for (actual paths can
differ significantly on your system, depending on how or where you have
installed the game and what version (32 or 64 bit) you are using):

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

Third way, recommended for most inexperienced users, is to use Plugin Installer
tool distributed with the ACC. Technically, it is the same as the second way,
but details are managed by the program, so even user that does not know anything
about Windows registry can use it without wory.
Please refer to readme file provided with Plugin Installer for more details.



How to use the program
------------------------------
For the program to work, let it run in the background while playing the game.
It does not matter whether you start the program before you start the game or
when the game is already running.

If you do not want to run the program manually or via batch every time you start
the game, you can use the plugin - it will automatically execute (start) the
program at the start of the game. Just follow steps described in "Installation"
section.

Key strokes are intercepted using RawInput, therefore the program will catch
them even when minimized or running in the background. A small warning about
keyboard bindings - program does not block binded keys (or combinations) in
game, nor does it check whether some binding is already used in the game. You
should be cautious when assigning keys so you don't assign the same binding
in the program and in the game.



How to install an update
------------------------------
Data updates for ACC are distributed as UGBD files. It is possible to distribute
an update in GDB or INI file, but it is not recommended and you should be
carefull with such files.
To install a game update, follow these steps (steps 2 and 3 can be skipped if
the update is in UGDB file and you have valid file association active):

  - download update file (*.INI,*.GDB or preferably *.UGBD) - latest updates
    should be available on a forum linked further in this document (section
    "Links")
  - start the program, open settings window and click on "Update games data..."
    button
  - in newly opened window, click on "Load update file..." button and then
    select and open the update file you have downloaded
  - if the file loads correctly, a list of update entries will appear on the
    left side
  - select loaded entries you want to add from a listing (you can select only
    some of them) and then click on "Make update" button; you can also
    add/replace newer entries by older ones if you want to, as all marked
    entries from opened file will be forcibly added
  - after the update process is done, a message with how many entries were
    updated/added will appear
  - check in the listing of supported games whether new entries were added
  - the update is finished, you can now delete the update file if you do not
    want to archive it

Updating the program or plugin is even simpler. Just replace the binary file
(EXE, DLL) with a new one and you are done.



Program features
------------------------------
This section will note on features that might not be obvious at the first
glimpse and also describes how to use some of the features.

* You can assign your own key or combination of any two keys to a program
  function (e.g. setting the speed).

* It is possible, by pressing appropriate key or key combination, to store
  current cruise control speed or, if game is fully supported, actual speed of
  the vehicle into a speed preset.

* You can change size of the step used when increasing or decreasing speed by
  pressing appropriate keys.

* You can minimize the program into notification area (Settings -> "Minimize
  into notification area"). This way, it can run in the background without
  bothering you.

* The program can be started minimized ("Minimize into notification area" must
  be on), so it will not disrupt other visible windows and will not acquire
  focus (which some old games might not like).

* It is possible to fully automate starting and closing of the program with use
  of plugin. Install the plugin, in program settings, select "Minimize into
  notification area", "Run the program minimized" and also "Close the program
  on game end". This way, program will be executed by the plugin at start of the
  game, and when the game closes, the program will end itself.

* New feature in version 2.3.0 is system that allows the program to obtain
  actual speed limit in effect on the road you are currently driving on.
  There are two functions that are using it - first is labeled as
  "Set to limit". When you activate this function either by pressing binded key
  or by clicking on button, the program sets cruise control speed to the speed
  limit.
  Second function, when activated, will also sets CC speed to current speed
  limit, but as you are driving, any change in this limit will be projected to
  cruise control system. For example, if you activate this function on a highway
  where there is speed limit of 130 km/h, CC speed will be set to 130 km/h.
  Later, when you drive down to a local road with speed limit of 90 km/h, the
  CC speed will be automatically lowered to a new limit. For best utilization of
  this function, it is recommended to turn on Smart Cruise Control in game
  options (as long as your game and current truck supports it).
  You can also choose what should happen when the speed limit is 0 (for example
  on some german highways). Currently, two options are implemented,
  "Turn CC off" and "Set CC speed to...". First option is clear enough.
  When the second option is selected and local speed limit happens to be 0, CC
  speed will be set to a value you can select right next to a dropbox with
  those options.
  Small warning though - if you are overtaking, the local speed limit is set to
  a negative value after few seconds in opposite direction, which will disable
  this function and turn your cruise control off. Be aware of that, because you
  may not notice it and lose speed required for successful overtaking.
  Also note that those new features work only when plugin is loaded and only
  in ETS2 1.17 and newer.



Common problems
------------------------------
Here are the common problems you can encounter and suggestions how to solve
them. If you have problem with ACC and cannot solve it using this section,
please write to a forum linked in section "Links".
NOTE - Many of the problems can be resolved by running the ACC.exe with
       administrative privileges.

* The program does not start.

    - it is compiled only for Windows OS (XP SP2 and newer), so it won't work on
      Linux, OS X, BSD, Android, or any other operating system
    - look into notification area, it may be running in "tray mode" (there would
      be ACC icon in the notification area)
    - check whether the program is not already running (only one instance of ACC
      can run at a time)
    - try it again

* System asks me if I want to run ACC with administrative privileges.

    - allow it, the program needs those privileges

* There are no supported games listed in the program.

    - ACC needs read AND write privileges to the folder it is located in, make
      sure you (and therefore the program) have them
    - delete "Data" subfolder located in the folder with the program, restart
      the program
    - do not use old GamesData.ini (from previous version of ACC)
    - use data (GamesData.ini, GamesData.gdb or any updates) only from trusted
      sources

* The program cannot find running game.

    - make sure your ACC supports the game and its exact version
    - make sure the game is not installed in a folder with uncommon characters
      in the path (diacritics, cyrillics, arabics, ...), program might have p
      roblem with that
    - check whether you are using right version of the program (see
      "Installation" section)
    - do not use modifications or programs that alters name of the main game
      executable
    - do not use modified main game executable (cracks for example)

* Program finds the game but fails to set the cruise control speed when I press
  the key.

    - try whether you can set the speed from the UI (clicking on appropriate
      button), if yes, try restarting the program
    - do not use programs that are in some way interfering with keyboard input
      (keyloggers, keystroke simulators, programs for key macros, ...)

* Program finds the game but fails to set the cruise control speed even from UI.

    - check your security programs (AV solutions, Anti-Spyware, ...), they can
      block access to foreign process memory (function Read(Write)ProcessMemory)

* There are some weird glitches in the program's UI.

    - restart the program
    - try different build
    - stop taking that LSD/THC/whatever you are using ;)



How the program works
------------------------------
This section does not have ambition to describe all internal workings of the
program (refer to source code for this), it is only general description so you
can have at least some idea on what is going on and why the program needs
administrative rights.

First, how the program finds the running game. A worker thread periodically
searches through running processes and compares them with the list of supported
games (further referred only as the list). File name of every process is
compared to the list and when it is listed, that process is then carefully
checked with all list entries with matching file name (in this phase, process
can be granted a rather long time window allowing it to load all necessary
modules before discarded or accepted). If exact match is found, then such
process is "binded", that is, main thread is notified about it and the worker
thread opens this process and starts waiting on it (for details, refer to
source). When the process ends, the worker thread is released from waiting and
the program starts new search for a running game.

Now how the program actually changes speed in the game. This is very simple, but
it also involves some rather advanced techniques that requires administrative
rights. Every entry in list of supported games contains, among other things,
pointers that can be used fo find particular variable in the memory of a running
game. When the program reads or writes CC speed, it uses this data to find
appropriate variable (memory address) and then operates on it (writes new data
or reads current ones).

And finally, settings of the program is stored in windows registry, key
"HKEY_CURRENT_USER\Software\NcS Soft\Adjustable Cruise Control 2".



Changelog
------------------------------
List of changes between individual versions of ACC.

2.3.3 -> 2.4.0
  - corrected issue where Steam could think the game is running when it was
    already closed as long as the ACC was running (Steam considered ACC to be
    part of the game)
  - removed support for obsolete games data formats
  - corrected handling of files that have non-ascii characters in their path
  - added support for new games and their versions
  - large number of internal corrections and changes


2.3.2 -> 2.3.3
  - added support for new games and their versions
  - updated Plugin Installer tool to support American Truck Simulator
  - list of supported games is now updated when a games data update is installed
  - number of corrections and optimizations


2.3.1 -> 2.3.2
  - corrected bug in system that is keeping CC speed on current limit (unwanted
    shutdown of the system when you drove from road with specified limit to a
    road with limit of 0)
  - corrected critical bug in memory operations that manifested itself when
    64bit build of ACC was used with 32bit game
  - added support for new versions of ETS2
  - added Plugins library feature to the Plugin Installer tool
  - other code changes and corrections


2.3.0 -> 2.3.1
  - added new games data file structures (INI 2.1 and BIN 1.1)
  - main program should not steal focus anymore when started
  - Delphi build now contains and uses extra icon for associated update files
  - version information is now read runtime, it is not stored in the code
    anymore
  - added Plugin Installer tool
  - large number of code corrections and changes


2.2.1 -> 2.3.0
  - added posibility of reading actual vehicle speed by plugin using telemetry
    (hence new "fully supported with plugin" group of games)
  - added feature allowing to set CC speed to current speed limit, or to
    automatically keep CC speed on local speed limit (CC speed is changing with
    this limit); available only in ETS2 1.17 and newer!
  - advanced settings are now available in settings window, and are no longer
    hidden from user
  - added an option to hide key bindings on buttons in main window
  - adden an option to associate UGDB file extension to ACC
  - older game data entries updated to support reading of vehicle speed by a
    plugin
  - added support for new games
  - plugin completely rewritten (so it can access Telemetry API)
  - loading and saving of INI files was rewritten; it is now nuch faster
  - implemeted new game data protocols
  - corrected passing of game data to binder thread after an update
  - added automatic rebind after update
  - corrected file name behavior in Lazarus build (there were problems with
    non-ASCII characters)
  - large number of other code corrections and changes


2.2.0 -> 2.2.1
  - added an option to clear key binding, which disables selected function
  - added soft key combination recognition (binded key is recognized even when
    other keys are pressed at the same time as long as it is not one of binded
    combinations)
  - added automatic update from internal games data at the start of the program
    (it is no longer needed to delete games data from previous installation when
    updating program binary)
  - program can now optionally check whether game is active when a trigger is
    executed and can stop execution when it isn't (on by default)
  - plugin now reports errors into game log
  - added Registry Cleaner tool to the release
  - number of small code corrections



Known issues
------------------------------
This section lists all known issues and bugs that, for some reason, made their
way to the final release.



Source code
------------------------------
You can get copy of full source code on either of the following git repository:

https://bitbucket.org/ncs-sniper/adjustablecruisecontrol
https://github.com/ncs-sniper/AdjustableCruiseControl



Licensing
------------------------------
This program is licensed under the terms of Mozilla Public License Version 2.0.
You can find full text of this license in file license.txt or on web page
https://www.mozilla.org/MPL/2.0/.



Authors, contacts
------------------------------
František Milt, frantisek.milt@gmail.com
Adam Fojtík, adam.fojtik.af@gmail.com



Links
------------------------------
Forum thread: http://forum.scssoft.com/viewtopic.php?f=34&t=40826



Copyright
------------------------------
©2013-2016 František Milt, all rights reserved