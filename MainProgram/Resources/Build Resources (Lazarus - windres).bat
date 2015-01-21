start /wait ..\..\Tools\SplashPreprocessor\SplashPreprocessor.exe SplashImage\splash.png
windres -o SplashImg.res    -i SplashImage\SplashImg.rc -I SplashImage
windres -o TrayIcon.res     -i TrayIcon\TrayIcon.rc     -I TrayIcon
windres -o DefGameIcon.res  -i GameIcons\DefGameIcon.rc -I GameIcons
windres -o GamesData.res    -i GamesData.rc           
windres -o ..\Libs\Msg\MsgIcons.res  -i MsgIcons\MsgIcons.rc -I MsgIcons