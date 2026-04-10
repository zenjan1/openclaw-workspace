@echo off
echo ========================================
echo  ScreenAIAssistant - 快速配置
echo ========================================
echo.

echo [1/4] 启动应用...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity
timeout /t 2 /nobreak >nul

echo.
echo [2/4] 打开无障碍设置页面...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell am start -a android.settings.ACCESSIBILITY_SETTINGS
timeout /t 2 /nobreak >nul

echo.
echo [3/4] 打开应用管理页面...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:com.screen.aiassistant
timeout /t 2 /nobreak >nul

echo.
echo [4/4] 检查应用状态...
call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db shell pm list packages | findstr screen.ai

echo.
echo ========================================
echo  请在手机上完成以下操作：
echo ========================================
echo.
echo  1. 在无障碍设置页面:
echo     ✓ 找到"屏幕 AI 助手自动点击"
echo     ✓ 开启开关
echo     ✓ 确认允许
echo.
echo  2. 在应用管理页面:
echo     ✓ 点击"权限管理"
echo     ✓ 授予"通知管理"权限
echo     ✓ 授予"显示悬浮窗"权限
echo     ✓ 授予其他所需权限
echo.
echo  3. 返回应用主界面:
echo     ✓ 点击"启动服务"
echo     ✓ 授予截图权限
echo.
echo ========================================
echo.
pause
