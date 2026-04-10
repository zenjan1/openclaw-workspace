# AI 自动点击代理 - Androlua 项目

## 功能说明

这个 Androlua 项目创建一个 AI 代理 APK，在安卓手机上循环执行以下操作：
1. 截取当前屏幕
2. 发送截图到 AI（阿里云百炼 qwen-vl-plus）
3. AI 分析屏幕并返回建议点击的坐标
4. 执行点击操作
5. 循环往复

## 文件结构

```
androlua-ai-agent/
├── main.lua          # 主程序代码
├── config.json       # 项目配置
├── icon.png          # 应用图标（可选）
└── README.md         # 说明文档
```

## 使用方法

### 1. 安装 Androlua

- 下载并安装 Androlua+ 应用
- 下载地址：https://github.com/nirenr/androlua/releases

### 2. 导入项目

- 将整个 `androlua-ai-agent` 文件夹复制到手机存储
- 在 Androlua+ 中打开项目文件夹
- 点击 `config.json` 或 `main.lua` 进行编辑

### 3. 配置 API

编辑 `main.lua` 中的 API 配置：

```lua
local API_KEY = "你的 API KEY"
local API_URL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"
local MODEL = "qwen-vl-plus"  -- 支持视觉的模型
```

### 4. 授予权限

首次运行需要授予以下权限：
- **存储权限**：保存截图
- **悬浮窗权限**：显示状态
- **无障碍权限**（可选）：更可靠的点击

### 5. 运行

- 在 Androlua+ 中点击运行按钮
- 点击"启动"按钮开始 AI 代理

## 配置说明

### API 配置

| 参数 | 说明 | 默认值 |
|------|------|--------|
| API_KEY | 阿里云百炼 API 密钥 | 从 settings.json 读取 |
| API_URL | API  endpoint | 百炼标准端点 |
| MODEL | AI 模型 | qwen-vl-plus |
| CHECK_INTERVAL | 循环间隔（毫秒）| 2000 |

### 权限说明

```json
{
    "android.permission.INTERNET": "发送请求到 AI API",
    "android.permission.WRITE_EXTERNAL_STORAGE": "保存截图",
    "android.permission.READ_EXTERNAL_STORAGE": "读取截图",
    "android.permission.SYSTEM_ALERT_WINDOW": "显示悬浮窗状态",
    "android.permission.FOREGROUND_SERVICE": "后台运行服务"
}
```

## 编译为 APK

在 Androlua+ 中：
1. 打开项目
2. 菜单 -> 编译 -> 生成 APK
3. 选择输出路径
4. 生成的 APK 可以独立安装

## 注意事项

1. **ADB 授权**：首次使用 `input tap` 命令可能需要通过 ADB 授权：
   ```bash
   adb shell pm grant com.ai.autoagent android.permission.SYSTEM_ALERT_WINDOW
   ```

2. **无障碍服务**：如果普通点击不工作，可以配置无障碍服务：
   - 设置 -> 无障碍 -> Androlua -> 启用

3. **电池优化**：关闭电池优化以保证后台运行：
   - 设置 -> 应用 -> Androlua -> 电池 -> 不优化

4. **API 费用**：使用阿里云百炼 API 会产生费用，请注意控制调用频率

## 故障排除

### 截图失败
- 确保授予存储权限
- 某些手机可能需要特殊截屏权限

### 点击不生效
- 尝试授予无障碍权限
- 使用 ADB 授权：`adb shell pm grant <包名> <权限>`

### API 调用失败
- 检查网络连接
- 验证 API Key 是否有效
- 检查 API 配额

## 依赖

- Androlua+
- Android 5.0+ (API 21+)
- 阿里云百炼 API 账号

## 参考

- [Androlua GitHub](https://github.com/nirenr/androlua)
- [阿里云百炼文档](https://help.aliyun.com/zh/dashscope/)
