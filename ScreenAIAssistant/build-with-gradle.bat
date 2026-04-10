@echo off
set JAVA_HOME=
set GRADLE_USER_HOME=I:\android_studio_sdk\.gradle

cd /d H:\workspace\ScreenAIAssistant

echo ========================================
echo  ScreenAIAssistant - APK Build
echo ========================================
echo.
echo Using Gradle from I:\android_studio_sdk\.gradle
echo.

I:\android_studio_sdk\.gradle\wrapper\dists\gradle-8.12-bin\gradle-8.12\bin\gradle.bat assembleDebug

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo  BUILD SUCCESS!
    echo ========================================
    echo.
    if exist "app\build\outputs\apk\debug\app-debug.apk" (
        echo APK found!
        echo.
        echo Installing to device 976d19db...
        I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db install -r app\build\outputs\apk\debug\app-debug.apk
        
        if %ERRORLEVEL% equ 0 (
            echo.
            echo [OK] Installation successful!
            echo.
            echo Starting app...
            I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity
        ) else (
            echo.
            echo [ERROR] Installation failed
        )
    ) else (
        echo APK not found at expected location
        dir app\build\outputs\apk /s 2>nul
    )
) else (
    echo.
    echo ========================================
    echo  BUILD FAILED
    echo ========================================
)

echo.
pause
