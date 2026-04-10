@echo off
echo ========================================
echo  设置 OpenClaw 环境变量
echo ========================================
echo.
echo 目标位置：H:\workspace
echo.

:: 设置用户环境变量
setx OPENCLAW_HOME "H:\workspace"
echo [用户变量] OPENCLAW_HOME 已设置

:: 设置系统环境变量 (需要管理员权限)
echo.
echo 注意：系统级变量需要管理员权限
echo 如果下面的命令失败，请手动设置：
echo   1. 右键"此电脑" → 属性 → 高级系统设置
echo   2. 环境变量 → 系统变量 → 新建
echo   3. 变量名：OPENCLAW_HOME
echo   4. 变量值：H:\workspace
echo.

:: 验证
echo 当前会话变量:
echo OPENCLAW_HOME=%OPENCLAW_HOME%
echo.
echo 完成！请重启终端或运行:
echo   set OPENCLAW_HOME=H:\workspace
echo ========================================
