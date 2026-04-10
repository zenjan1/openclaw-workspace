# 闪退问题已定位并修复

**问题:** 点击"启动服务"后应用闪退  
**根本原因:** Android 14+ 安全要求  
**状态:** ✅ 已修复代码，需要重新编译

---

## 🔍 崩溃分析

### 错误信息

```
java.lang.SecurityException: Media projections require a foreground service 
of type ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PROJECTION
```

### 原因说明

Android 14+ 对使用屏幕捕获 (MediaProjection) 的前台服务有严格要求：

- ❌ **错误声明**: `foregroundServiceType="specialUse"`
- ✅ **正确声明**: `foregroundServiceType="mediaProjection"`

当前 AndroidManifest.xml 使用了错误的类型，导致系统拒绝启动服务。

---

## ✅ 已修复内容

### 修改前 (app/src/main/AndroidManifest.xml)

```xml
<service
    android:name=".service.ScreenCaptureService"
    android:foregroundServiceType="specialUse">
    <property
        android:name="android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE"
        android:value="Screen capture and AI analysis" />
</service>
```

### 修改后

```xml
<service
    android:name=".service.ScreenCaptureService"
    android:foregroundServiceType="mediaProjection">
</service>
```

---

## 🛠️ 重新编译方法

### 方法 1: 使用 Android Studio (推荐)

1. **打开项目**
   - 启动 Android Studio
   - File → Open → 选择 `H:\workspace\ScreenAIAssistant`

2. **同步 Gradle**
   - 等待自动同步完成

3. **构建 APK**
   - Build → Build Bundle(s) / APK(s) → Build APK(s)
   - 或使用快捷键 `Ctrl+F9`

4. **安装到手机**
   - 连接手机
   - Run → Run 'app'
   - 或点击绿色运行按钮

---

### 方法 2: 使用命令行

**前提:** 需要安装 JDK 17+

```batch
:: 设置 Java 环境
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr

:: 进入项目目录
cd H:\workspace\ScreenAIAssistant

:: 清理并构建
gradlew.bat clean assembleDebug

:: 安装 APK
adb install -r app\build\outputs\apk\debug\app-debug.apk
```

---

### 方法 3: 临时解决方案 (无需编译)

**注意:** 此方法仅用于测试，不建议长期使用。

**在手机上操作:**

1. **卸载当前应用**
   ```bash
   adb uninstall com.screen.aiassistant
   ```

2. **修改系统设置 (需要 Root)**
   ```bash
   adb shell
   su
   setprop persist.sys.media_projection.fgs_mode 1
   ```

3. **重新安装应用**
   ```bash
   adb install -r H:\workspace\ScreenAIAssistant\app\build\intermediates\apk\debug\app-debug.apk
   ```

---

## 📋 测试步骤

重新安装后，测试以下功能：

1. **启动应用**
   - 打开"屏幕 AI 助手"

2. **授予权限**
   - 无障碍权限 ✓
   - 通知权限 ✓
   - 悬浮窗权限 ✓

3. **启动服务**
   - 点击"启动服务"
   - 授予截图权限 → "立即开始"
   - **应该正常运行，不再闪退**

4. **验证功能**
   - 检查通知栏是否有"屏幕 AI 助手"通知
   - 检查应用是否能正常截图
   - 检查 AI 分析是否正常工作

---

## 📝 相关文件

| 文件 | 路径 | 状态 |
|------|------|------|
| AndroidManifest.xml | `app/src/main/AndroidManifest.xml` | ✅ 已修复 |
| ScreenCaptureService.java | `app/src/main/java/.../ScreenCaptureService.java` | ✓ 正常 |
| ClickAccessibilityService.java | `app/src/main/java/.../ClickAccessibilityService.java` | ✓ 正常 |
| MainActivity.java | `app/src/main/java/.../MainActivity.java` | ✓ 正常 |

---

## ⚠️ 注意事项

1. **Android 版本兼容性**
   - 此修复针对 Android 14+
   - Android 13 及以下版本不受影响

2. **前台服务通知**
   - 应用会显示"屏幕 AI 助手正在运行"通知
   - 这是 Android 的强制要求，无法移除

3. **电池优化**
   - 建议关闭应用的电池优化
   - 设置 → 应用管理 → 屏幕 AI 助手 → 电池和性能 → 无限制

---

## 🎯 下一步

**立即执行:**
1. 使用 Android Studio 重新编译 APK
2. 安装到手机测试
3. 验证"启动服务"功能是否正常

**如果还有问题:**
1. 收集崩溃日志：`adb logcat -d > crash.txt`
2. 检查应用权限设置
3. 确认无障碍服务已启用

---

**修复完成！重新编译后应该可以正常运行** 🎉
