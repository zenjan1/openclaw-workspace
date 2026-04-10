@echo off
echo ========================================
echo  ScreenAIAssistant - 安装并测试
echo ========================================
echo.

echo [1/4] 安装 APK...
echo      请在手机上点击"允许安装"
echo.
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db install -t -r H:\workspace\ScreenAIAssistant\app\build\outputs\apk\debug\app-debug.apk

if %ERRORLEVEL% neq 0 (
    echo.
    echo [错误] 安装失败！
    echo       请检查手机是否已连接，并在手机上允许安装
    echo.
    pause
    exit /b 1
)

echo.
echo [2/4] 启动应用...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity

timeout /t 3 /nobreak >nul

echo.
echo [3/4] 检查应用状态...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell pm list packages | findstr screen.ai

echo.
echo [4/4] 查看进程...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell ps | findstr screen.ai

echo.
echo ========================================
echo  请在手机上完成以下操作:
echo ========================================
echo.
echo  1. 授予所有权限 (通知、无障碍、悬浮窗)
echo  2. 在无障碍设置中启用"屏幕 AI 助手自动点击"
echo  3. 返回应用，点击"启动服务"
echo  4. 授予截图权限
echo.
echo  如果不再闪退，说明修复成功！
echo ========================================
echo.

echo 开始监控日志 (按 Ctrl+C 停止)...
echo.
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db logcat -v time | findstr "ScreenAI|screen.aiassistant|FATAL|ERROR"

pause
