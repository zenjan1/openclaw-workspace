# ScreenAIAssistant 闪退问题修复指南

**问题:** 点击"启动服务"按钮后应用闪退  
**时间:** 2026-03-30 16:15 GMT+8

---

## 🔍 问题分析

### 已发现权限问题

```
POST_NOTIFICATIONS: granted=false
```

Android 13+ 需要手动授予通知权限，但应用代码中缺少运行时权限请求。

### 可能的崩溃原因

1. **通知权限缺失** - Android 13+ 必需
2. **无障碍服务未启用** - 启动服务前必须启用
3. **前台服务启动失败** - 缺少必要的权限或配置

---

## ✅ 解决方案

### 方案 1: 手动授予所有权限 (推荐)

**在手机上操作:**

1. **授予通知权限**
   ```
   设置 → 应用管理 → 屏幕 AI 助手 → 通知管理 → 允许通知
   ```

2. **授予无障碍权限**
   ```
   设置 → 更多设置 → 无障碍 → 已下载的服务 → 屏幕 AI 助手自动点击 → 开启
   ```

3. **授予悬浮窗权限**
   ```
   设置 → 应用管理 → 屏幕 AI 助手 → 显示悬浮窗 → 允许
   ```

4. **重新启动应用**
   ```bash
   adb -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity
   ```

---

### 方案 2: 使用调试脚本

运行调试脚本自动重装应用：

```batch
H:\workspace\ScreenAIAssistant\debug-fix.bat
```

脚本会：
1. 清除应用数据
2. 卸载应用
3. 重新安装
4. 启动应用
5. 显示日志

**然后在手机上手动授予权限**（见方案 1）

---

### 方案 3: 修改代码添加权限请求 (长期修复)

已修改 `MainActivity.java` 添加通知权限请求：

```java
/**
 * 请求通知权限 (Android 13+)
 */
private void requestNotificationPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
                != PackageManager.PERMISSION_GRANTED) {
            permissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS);
            log("请求通知权限...");
        }
    }
}
```

**重新编译需要 JDK 环境**，当前环境缺少 Java。

---

## 📋 完整的权限检查清单

启动服务前，确保已授予以下权限：

| 权限 | 状态 | 授予方式 |
|------|------|----------|
| POST_NOTIFICATIONS | ❌ 未授予 | 设置 → 应用管理 → 通知 |
| 无障碍服务 | ⚠️ 需检查 | 设置 → 无障碍 |
| 悬浮窗 | ⚠️ 需检查 | 设置 → 应用管理 → 悬浮窗 |
| 截图权限 | ⚠️ 运行时请求 | 启动服务时自动弹出 |

---

## 🔧 调试命令

### 检查权限状态
```bash
adb -s 976d19db shell dumpsys package com.screen.aiassistant | Select-String "granted"
```

### 查看崩溃日志
```bash
adb -s 976d19db logcat -d -v time | Select-String -Pattern "FATAL|ERROR" -Context 3
```

### 清除应用数据
```bash
adb -s 976d19db shell pm clear com.screen.aiassistant
```

### 重启应用
```bash
adb -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity
```

---

## 🎯 正确的启动流程

1. **首次启动**
   - 安装应用
   - 打开应用
   - 授予通知权限 (Android 13+)

2. **配置权限**
   - 点击"授予无障碍权限"按钮 → 开启服务
   - 点击"授予悬浮窗权限"按钮 → 允许

3. **启动服务**
   - 点击"启动服务"按钮
   - 授予截图权限 (系统弹窗)
   - 服务开始运行

---

## ⚠️ 注意事项

1. **Android 13+ 必须手动授予通知权限**
2. **无障碍服务必须在启动服务前启用**
3. **MIUI 系统可能需要额外配置**
   - 关闭电池优化
   - 允许后台运行

---

## 📝 下一步

**立即执行:**
1. 在手机上手动授予所有权限（方案 1）
2. 重新启动应用
3. 测试启动服务

**长期修复:**
- 需要安装 JDK 17 重新编译 APK
- 或使用 Android Studio 重新构建

---

**修复后请测试并反馈结果！** 🙏
