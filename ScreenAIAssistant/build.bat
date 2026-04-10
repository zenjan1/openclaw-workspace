@echo off
set JAVA_HOME=I:\android_studio_sdk\jbr
set PATH=%JAVA_HOME%\bin;%PATH%
set GRADLE_USER_HOME=H:\workspace\ScreenAIAssistant\.gradle

cd /d H:\workspace\ScreenAIAssistant

echo Building APK...
echo.

gradle.bat assembleDebug

echo.
echo Build completed!
pause
