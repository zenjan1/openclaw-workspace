@echo off
set GRADLE_USER_HOME=I:\android_studio_sdk\.gradle
set GRADLE_HOME=I:\android_studio_sdk\.gradle\wrapper\dists\gradle-8.12-bin\7vg77h8jomrdpgh5hmwhreghw\gradle-8.12

cd /d H:\workspace\ScreenAIAssistant

echo ========================================
echo  ScreenAIAssistant - APK Build
echo ========================================
echo.
echo Using Gradle 8.12 from:
echo   %GRADLE_HOME%
echo.

call "%GRADLE_HOME%\bin\gradle.bat" assembleDebug

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo  BUILD SUCCESS!
    echo ========================================
    echo.
    if exist "app\build\outputs\apk\debug\app-debug.apk" (
        echo [OK] APK found!
        echo.
        echo Installing to device 976d19db (Xiaomi 12S Ultra)...
        call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db install -r app\build\outputs\apk\debug\app-debug.apk
        
        if %ERRORLEVEL% equ 0 (
            echo.
            echo [OK] Installation successful!
            echo.
            echo Starting app...
            call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity
        ) else (
            echo.
            echo [ERROR] Installation failed
        )
    ) else (
        echo [WARN] APK not found at expected location
        echo Searching for APK...
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
