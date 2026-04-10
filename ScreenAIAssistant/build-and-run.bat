@echo off
set JAVA_HOME=I:\android_studio_sdk\jbr
set GRADLE_USER_HOME=H:\workspace\ScreenAIAssistant\.gradle

cd /d H:\workspace\ScreenAIAssistant

echo ========================================
echo  ScreenAIAssistant - APK Build
echo ========================================
echo.
echo Java: %JAVA_HOME%
echo Gradle: %GRADLE_USER_HOME%
echo.

if exist "%JAVA_HOME%\bin\java.exe" (
    echo [OK] Java found
) else (
    echo [ERROR] Java not found at %JAVA_HOME%
    pause
    exit /b 1
)

echo.
echo Starting Gradle build...
echo.

call gradle assembleDebug

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo  BUILD SUCCESS!
    echo ========================================
    echo.
    echo APK location:
    echo   app\build\outputs\apk\debug\app-debug.apk
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
    echo.
    echo ========================================
    echo  BUILD FAILED
    echo ========================================
)

echo.
pause
