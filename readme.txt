--------------------------------------------------------------------------------
                       Adjustable Cruise Control - source
--------------------------------------------------------------------------------

Description
----------------------------------------
This project is primarily developed in Delphi 7 Personal, but is also compatible
with Lazarus/FPC - therefore it can be compiled both in Delphi and Lazarus.
It is configured in a way that you should be able to compile it without any 
preparations. It is also possible to compile it into both 32bit and 64bit 
binaries, the source code (including used libraries) is ready for this.
For more informations about the program itself and about its features, please 
refer to ./Documents/readme.txt file.



Libraries and components
----------------------------------------

PNGDelphi

  This library adds support for PNG images to older versions of Delphi, in this
  case into Delphi 7.
  If you have newer versions of Delphi, you won't need this library as it is 
  integral part of the Delphi. In that case, remove or rename CFG files 
  mentioned further, so they are not used during batch compilation.
  After installing it, edit following files and change path that is stored in 
  them so it leads to a place were you have installed this library:

    ./MainProgram/Delphi/dcc32.cfg
    ./Tools/GamesDataConverter/dcc32.cfg
    ./Tools/SplashPreprocessor/dcc32.cfg

  Source for this library is in the file ./MainProgram/Libs/PNGDelphi.zip.



Licensing
----------------------------------------
Everything (source codes, executables/binaries, configurations, etc.), with few 
exceptions mentioned below, is licensed under Mozilla Public License Version 
2.0. You can find full text of this license in file mpl_license.txt or on web 
page https://www.mozilla.org/MPL/2.0/.
Exception being following folders and their entire content:

./Documents

  This folder contains documents (texts, images, ...) used in creation of ACC. 
  Everything in this folder is licensed under the terms of Creative Commons 
  Attribution-ShareAlike 4.0 (CC BY-SA 4.0) license. You can find full legal 
  code in file CC_BY-SA_4.0.txt or on web page
  http://creativecommons.org/licenses/by-sa/4.0/legalcode. Short wersion is 
  available on web page http://creativecommons.org/licenses/by-sa/4.0/.



Repositories
----------------------------------------
You can get actual copies of Telemetry Library on these git repositories:

https://bitbucket.org/ncs-sniper/adjustablecruisecontrol
https://github.com/ncs-sniper/AdjustableCruiseControl



Authors, contacts
----------------------------------------
František Milt, frantisek.milt@gmail.com



Copyright
----------------------------------------
©2013-2015 František Milt, all rights reserved