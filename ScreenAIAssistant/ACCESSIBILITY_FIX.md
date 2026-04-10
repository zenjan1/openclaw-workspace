# 无障碍服务故障修复指南

**问题:** 无障碍服务出现故障  
**时间:** 2026-03-30 16:20 GMT+8  
**设备:** 小米 12S Ultra (Android 15)

---

## 🔍 问题诊断

### 当前状态

```
✓ 应用已安装：com.screen.aiassistant
✗ 无障碍服务未启用
✗ 应用权限未授予
```

### 根本原因

应用之前崩溃后被系统自动卸载或清除，需要重新安装和配置。

---

## ✅ 解决方案

### 方法 1: 快速配置脚本 (推荐)

**在电脑上运行:**
```batch
H:\workspace\ScreenAIAssistant\quick-setup.bat
```

脚本会自动：
1. 启动应用
2. 打开无障碍设置页面
3. 打开应用权限页面
4. 显示配置说明

---

### 方法 2: 手动配置

#### 步骤 1: 启动应用

```bash
adb -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity
```

或在手机上点击应用图标。

---

#### 步骤 2: 启用无障碍服务

**路径:** 设置 → 更多设置 → 无障碍 → 已下载的服务

1. 找到 **"屏幕 AI 助手自动点击"**
2. 点击开关 → **开启**
3. 系统会弹出警告 → **确定**
4. 确认服务状态为 **"已开启"**

**或使用 ADB 命令:**
```bash
# 打开无障碍设置页面
adb -s 976d19db shell am start -a android.settings.ACCESSIBILITY_SETTINGS
```

---

#### 步骤 3: 授予应用权限

**路径:** 设置 → 应用管理 → 屏幕 AI 助手 → 权限管理

授予以下权限：

| 权限 | 重要性 | 说明 |
|------|--------|------|
| **通知管理** | ⭐⭐⭐ | Android 13+ 必需 |
| **显示悬浮窗** | ⭐⭐⭐ | 必需 |
| **无障碍** | ⭐⭐⭐ | 通过无障碍设置授予 |
| **截图** | ⭐⭐⭐ | 启动服务时授予 |
| **存储** | ⭐⭐ | 可选 |

**或使用 ADB 命令:**
```bash
# 打开应用信息页面
adb -s 976d19db shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:com.screen.aiassistant
```

---

#### 步骤 4: 启动服务

1. 返回应用主界面
2. 点击 **"授予无障碍权限"** 按钮 → 确认已开启
3. 点击 **"授予悬浮窗权限"** 按钮 → 允许
4. 点击 **"启动服务"** 按钮
5. 系统弹出截图权限请求 → 点击 **"立即开始"**

---

## 🔧 验证配置

### 检查无障碍服务状态

```bash
adb -s 976d19db shell settings get secure enabled_accessibility_services
```

**应该包含:**
```
com.screen.aiassistant/.service.ClickAccessibilityService
```

### 检查应用权限

```bash
adb -s 976d19db shell dumpsys package com.screen.aiassistant | Select-String "granted"
```

**应该看到:**
```
android.permission.POST_NOTIFICATIONS: granted=true
android.permission.SYSTEM_ALERT_WINDOW: granted=true
android.permission.FOREGROUND_SERVICE: granted=true
```

### 检查应用进程

```bash
adb -s 976d19db shell ps | Select-String "screen.ai"
```

**应该看到应用进程在运行。**

---

## ⚠️ 常见问题

### 问题 1: 找不到无障碍服务

**原因:** 应用未正确安装

**解决:**
```bash
adb -s 976d19db uninstall com.screen.aiassistant
adb -s 976d19db install -t -r H:\workspace\ScreenAIAssistant\app\build\intermediates\apk\debug\app-debug.apk
```

---

### 问题 2: 服务开启后自动关闭

**原因:** MIUI 系统限制

**解决:**
1. 设置 → 应用管理 → 屏幕 AI 助手
2. 电池和性能 → 无限制
3. 自启动管理 → 允许自启动
4. 锁定应用（多任务界面下拉锁定）

---

### 问题 3: 点击"启动服务"无响应

**原因:** 缺少通知权限

**解决:**
1. 设置 → 应用管理 → 屏幕 AI 助手
2. 通知管理 → 允许通知
3. 重新启动应用

---

### 问题 4: 截图权限无法授予

**原因:** 系统限制或前台服务未正确配置

**解决:**
1. 确保已授予通知权限
2. 确保无障碍服务已开启
3. 重启应用后重试

---

## 📋 完整配置清单

启动服务前，确保完成以下所有步骤：

- [ ] 应用已安装
- [ ] 应用已启动
- [ ] 通知权限已授予
- [ ] 悬浮窗权限已授予
- [ ] 无障碍服务已开启
- [ ] 电池优化已关闭
- [ ] 自启动已允许

---

## 🎯 快速命令参考

```bash
# 安装应用
adb -s 976d19db install -t -r app-debug.apk

# 启动应用
adb -s 976d19db shell am start -n com.screen.aiassistant/.MainActivity

# 打开无障碍设置
adb -s 976d19db shell am start -a android.settings.ACCESSIBILITY_SETTINGS

# 打开应用信息
adb -s 976d19db shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:com.screen.aiassistant

# 检查服务状态
adb -s 976d19db shell settings get secure enabled_accessibility_services

# 查看日志
adb -s 976d19db logcat -v time | Select-String "ScreenAI"

# 卸载应用
adb -s 976d19db uninstall com.screen.aiassistant
```

---

## 📞 需要帮助？

如果以上方法都无法解决问题，请提供：

1. 手机型号和 Android 版本
2. 完整的日志输出
3. 已尝试的步骤

**日志获取:**
```bash
adb -s 976d19db logcat -d -v time > crash-log.txt
```

---

**祝配置顺利！** 🎉
