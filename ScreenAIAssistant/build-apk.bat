@echo off
echo ========================================
echo  ScreenAIAssistant - Build APK
echo ========================================
echo.

set JAVA_HOME=I:\android_studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%

echo JAVA_HOME: %JAVA_HOME%
echo.

cd /d H:\workspace\ScreenAIAssistant

echo Starting Gradle build...
echo.

call I:\android_studio_sdk\.gradle\wrapper\dists\gradle-8.13-bin\ap7pdhvhnjtc6mxtzz89gkh0c\gradle-8.13\bin\gradle.bat clean assembleDebug

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo  BUILD SUCCESS!
    echo ========================================
    echo.
    echo APK location:
    echo   app\build\outputs\apk\debug\app-debug.apk
    echo.
) else (
    echo.
    echo ========================================
    echo  BUILD FAILED
    echo ========================================
)

echo.
pause
