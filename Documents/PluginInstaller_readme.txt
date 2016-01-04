================================================================================

                            Adjustable Cruise Control

                              Plugin Installer tool

================================================================================

Description
------------------------------
Purpose of this program is to ease installation and uninstallation of plugins
for truck games by SCS Software.
Although this program is developed as part of Adjustable Cruise Control project,
it can install ANY plugin, not just those distributed with ACC.

NOTE - The program does not enumerate plugins installed in default plugin
       folder. If you have some plugins installed in there, be carefull what you
       are installing with this program.

WARNING - The program needs administrative privileges in order to work. If your
          operating system asks for those privileges, allow it. This behaviour
          is normal and cannot be evaded.



How to use the program
------------------------------
In order for the installed plugins to work, it is necessary the files stay at
the same place they were when installed. Meaning if you want to install any
plugin using this program, place the plugin file (DLL) in a well selected folder
where it stays the entire time you want to use it in a game. If you move or
delete the plugin file after installation, the game will be unable to load it
and it will not work.

Installation of a plugin can be summarized into following steps:

  - start the Plugin Installer program
  - select a game for which you want the plugin to be installed, note that you
    must distinguish between 32bit and 64bit games
  - click on button "Install plugin...", standard file open dialog will appear,
    in it, select a plugin file for installation, confirm your choice
  - a prompt will pop-up, fill a description of the plugin, this field must be
    filled but you can type pretty much anything in there
  - click on "Accept" button, if some error occurs, you can cancel the
    installation or force it to complete (not recommended)
  - done

NOTE - You can install plugins for a game that is not actually installed on your
       system. But it is not possible to install plugins for a game that cannot
       run on your system (64bit game on a 32bit system).

For plugin uninstallation, select a game from which you want to uninstall a
plugin, then select plugin you want to uninstall and click on "Uninstall plugin"
button. Confirm your choice and you are done. But note that actual plugin file
will NOT be deleted from its location on disk.



How the program works
------------------------------
This program is using a feature where a game enumerates string entries (values)
in specific registry key, and data of those entries are assumed to be paths
to plugins. Such files/plugins are then automatically loaded by the game.
This program has list of games that are supporting this feature with full
game-specific key path for each game. When you install a plugin by this program,
it writes full path to plugin file you selected to appropriate registry key.
When uninstalling, the value is deleted from game-specific registry key.



Licensing
------------------------------
This program is licensed under the terms of Mozilla Public License Version 2.0.
You can find full text of this license on web page
https://www.mozilla.org/MPL/2.0/.



Authors, contacts
------------------------------
František Milt, frantisek.milt@gmail.com



Copyright
------------------------------
©2015-2016 František Milt, all rights reserved