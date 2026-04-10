@echo off
echo ========================================
echo  ScreenAIAssistant - 调试模式
echo ========================================
echo.

echo 步骤 1: 清除应用数据
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell pm clear com.screen.aiassistant
echo.

echo 步骤 2: 卸载应用
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db uninstall com.screen.aiassistant
echo.

echo 步骤 3: 重新安装
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db install -t -r H:\workspace\ScreenAIAssistant\app\build\intermediates\apk\debug\app-debug.apk
echo.

echo 步骤 4: 启动应用
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity
echo.

echo ========================================
echo  请在手机上手动授予以下权限：
echo  1. 通知权限 (设置 → 应用管理 → 屏幕 AI 助手 → 通知管理)
echo  2. 无障碍权限 (设置 → 更多设置 → 无障碍)
echo  3. 悬浮窗权限 (设置 → 应用管理 → 屏幕 AI 助手 → 显示悬浮窗)
echo ========================================
echo.
echo 按任意键继续查看日志...
pause

echo.
echo 开始监控日志 (按 Ctrl+C 停止):
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db logcat -v time

pause
