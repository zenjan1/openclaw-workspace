@echo off
echo ========================================
echo  ScreenAIAssistant - 无障碍服务测试
echo ========================================
echo.

echo 当前无障碍服务状态:
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell settings get secure enabled_accessibility_services

echo.
echo ========================================
echo  请在手机上操作:
echo ========================================
echo.
echo  1. 打开 设置 → 更多设置 → 无障碍 → 已下载的服务
echo.
echo  2. 找到"屏幕 AI 助手自动点击"
echo.
echo  3. 关闭开关，等待 3 秒
echo.
echo  4. 重新开启开关
echo.
echo  5. 返回应用，点击"启动服务"
echo.
echo ========================================
echo.
pause

echo 检查服务状态...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell dumpsys accessibility | findstr "screen.aiassistant"

echo.
echo 应用进程:
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell ps | findstr screen.ai

echo.
pause
