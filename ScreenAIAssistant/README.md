# 屏幕 AI 助手 - Screen AI Assistant

基于阿里云百炼 API 的 Android 自动点击工具。通过 AI 分析屏幕截图，智能推荐并执行点击操作。

## 功能特性

- **AI 智能分析**: 使用阿里云百炼 qwen-vl 模型分析屏幕内容
- **自动点击**: 通过无障碍服务自动执行点击操作
- **实时截图**: 使用 MediaProjection API 捕获屏幕
- **可视化界面**: Material Design 风格的用户界面
- **可配置 API**: 支持自定义 API Key 和模型参数

## 项目结构

```
ScreenAIAssistant/
├── app/
│   ├── src/main/
│   │   ├── java/com/screen/aiassistant/
│   │   │   ├── MainActivity.java              # 主界面
│   │   │   ├── BailianApiService.java         # 百炼 API 服务
│   │   │   └── service/
│   │   │       ├── ClickAccessibilityService.java  # 无障碍服务
│   │   │       └── ScreenCaptureService.java       # 截图服务
│   │   ├── res/
│   │   │   ├── layout/activity_main.xml       # 主界面布局
│   │   │   ├── values/                        # 资源文件
│   │   │   ├── xml/                           # 无障碍配置
│   │   │   └── drawable/                      # 图标资源
│   │   ├── AndroidManifest.xml
│   │   └── build.gradle.kts
│   └── proguard-rules.pro
├── build.gradle.kts
├── settings.gradle.kts
└── gradle.properties
```

## 构建说明

### 环境要求

- Android Studio Hedgehog (2023.1.1) 或更高版本
- JDK 17
- Android SDK 34
- 最低支持 Android 8.0 (API 26)

### 构建步骤

1. **打开项目**
   - 使用 Android Studio 打开 `ScreenAIAssistant` 文件夹

2. **同步 Gradle**
   - 等待 Gradle 自动同步完成
   - 或点击 "Sync Now" 按钮

3. **配置 API Key**
   - 默认的 API Key 已配置在代码中
   - 可在应用界面的输入框中修改

4. **构建 APK**
   - 点击 Build -> Build Bundle(s) / APK(s) -> Build APK(s)
   - 调试版 APK 位于 `app/build/outputs/apk/debug/app-debug.apk`

5. **安装到设备**
   - 连接 Android 设备
   - 点击 Run 按钮或使用 `adb install` 命令

## 使用说明

### 1. 授予权限

首次运行需要授予以下权限：

1. **无障碍权限**
   - 点击 "授予无障碍权限" 按钮
   - 在设置中找到 "屏幕 AI 助手自动点击"
   - 开启服务

2. **悬浮窗权限**
   - 点击 "授予悬浮窗权限" 按钮
   - 允许应用在其他应用上层显示

3. **截图权限**
   - 点击 "启动服务" 时会自动请求
   - 在系统弹窗中点击 "立即开始"

### 2. 配置 API

在 API 配置卡片中设置：

- **API Key**: 阿里云百炼 API 密钥
- **API URL**: `https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation`
- **模型**: `qwen3.5-plus`（支持图片理解）

### 3. 启动服务

点击 "启动服务" 按钮，应用开始：
1. 截取屏幕
2. 发送截图到 AI 分析
3. 接收 AI 返回的点击坐标
4. 执行点击操作
5. 循环执行

## API 配置

### 阿里云百炼 API

1. 访问 [阿里云百炼控制台](https://dashscope.console.aliyun.com/)
2. 创建 API Key
3. 确保账户有足够的配额

### API 端点

```
POST https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation

Headers:
  Authorization: Bearer {API_KEY}
  Content-Type: application/json

Body:
{
  "model": "qwen3.5-plus",
  "input": {
    "messages": [{
      "role": "user",
      "content": [
        {"type": "text", "text": "提示词"},
        {"type": "image_url", "image_url": {"url": "data:image/png;base64,{BASE64}"}}
      ]
    }]
  },
  "parameters": {
    "temperature": 0.1,
    "max_tokens": 500
  }
}
```

## 注意事项

1. **电量消耗**: 持续截图和 AI 调用会消耗较多电量
2. **网络要求**: 需要稳定的网络连接
3. **API 费用**: 使用百炼 API 会产生费用，请合理控制调用频率
4. **兼容性**: 某些应用可能限制无障碍服务的使用
5. **系统限制**: Android 10+ 可能对后台服务有限制

## 故障排除

### 无法截图
- 确保授予了媒体投影权限
- 重启应用后重试

### 点击不生效
- 检查无障碍服务是否启用
- 重启无障碍服务

### API 调用失败
- 检查网络连接
- 验证 API Key 是否有效
- 检查 API 配额

## 依赖库

- OkHttp 4.12.0 - HTTP 客户端
- Gson 2.10.1 - JSON 解析
- Material Components 2.1.0 - UI 组件
- AndroidX AppCompat 1.6.1 - 兼容性库

## 许可证

MIT License

## 开发者

使用 Android Studio 开发
项目创建日期：2026-03-24
