@echo off
echo ========================================
echo  ScreenAIAssistant - 重新编译 (国内源)
echo ========================================
echo.

set JAVA_HOME=I:\android_studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%

echo JAVA_HOME: %JAVA_HOME%
echo Gradle: 8.13 (腾讯云镜像)
echo.

cd /d H:\workspace\ScreenAIAssistant

echo 清理旧的构建缓存...
call I:\android_studio_sdk\.gradle\wrapper\dists\gradle-8.13-bin\ap7pdhvhnjtc6mxtzz89gkh0c\gradle-8.13\bin\gradle.bat clean --no-daemon

echo.
echo 开始编译...
echo.

call I:\android_studio_sdk\.gradle\wrapper\dists\gradle-8.13-bin\ap7pdhvhnjtc6mxtzz89gkh0c\gradle-8.13\bin\gradle.bat assembleDebug --no-daemon

if %ERRORLEVEL% equ 0 (
    echo.
    echo ========================================
    echo  编译成功!
    echo ========================================
    echo.
    echo APK 位置:
    echo   app\build\outputs\apk\debug\app-debug.apk
    echo.
    
    echo 准备安装到手机...
    echo.
    call I:\android_studio_SDK\platform-tools\adb.exe -s 976d19db install -t -r app\build\outputs\apk\debug\app-debug.apk
    
    if %ERRORLEVEL% equ 0 (
        echo.
        echo ========================================
        echo  安装成功!
        echo ========================================
        echo.
        echo 请在手机上:
        echo 1. 打开应用
        echo 2. 授予所有权限
        echo 3. 启用无障碍服务
        echo 4. 点击"启动服务"测试
        echo.
    ) else (
        echo.
        echo ========================================
        echo  安装失败
        echo ========================================
        echo.
        echo 请检查:
        echo 1. 手机是否已连接
        echo 2. 手机上是否弹出安装提示
        echo 3. 点击"允许安装"
        echo.
    )
) else (
    echo.
    echo ========================================
    echo  编译失败
    echo ========================================
)

echo.
pause
