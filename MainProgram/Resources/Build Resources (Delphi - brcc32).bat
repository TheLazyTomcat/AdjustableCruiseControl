start /wait ..\..\Tools\SplashPreprocessor\SplashPreprocessor.exe SplashImage\splash.png
brcc32 -fo SplashImg.res    SplashImage\SplashImg.rc
brcc32 -fo TrayIcon.res     TrayIcon\TrayIcon.rc
brcc32 -fo DefGameIcon.res  GameIcons\DefGameIcon.rc
brcc32 -fo GamesData.res    GamesData.rc