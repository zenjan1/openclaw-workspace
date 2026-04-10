# AI 自动点击代理 - 任务列表

## 已完成

- [x] 创建项目目录结构
- [x] 编写主程序代码 (main.lua)
- [x] 创建配置文件 (config.json)
- [x] 编写增强版代码 (main_enhanced.lua)
- [x] 创建 README 文档

## 项目文件

```
H:/workspace/androlua-ai-agent/
├── main.lua              # 基础版主程序
├── main_enhanced.lua     # 增强版主程序（推荐）
├── config.json           # Androlua 项目配置
└── README.md             # 使用说明文档
```

## 快速开始

### 1. 复制文件到手机
将整个 `androlua-ai-agent` 文件夹复制到手机存储

### 2. 在 Androlua+ 中打开
- 安装 Androlua+ 应用
- 打开并导入项目文件夹
- 选择 `main_enhanced.lua` 运行

### 3. 授予权限
首次运行需要授予：
- 存储权限
- 悬浮窗权限
- 可选：无障碍权限（更可靠的点击）

### 4. 启动服务
- 点击"启动"按钮
- 观察日志输出
- AI 会自动分析屏幕并执行点击

## API 配置

当前配置（来自 settings.json）:
- **API Key**: `sk-sp-eb075370e39b4f24ac34f979f401f619`
- **API URL**: `https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation`
- **模型**: `qwen-vl-plus` (支持视觉)

## 工作原理

```
┌─────────────┐
│   开始循环   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  截取屏幕    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 转 Base64   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 发送 AI 分析  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 解析坐标    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ 执行点击    │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  等待 2 秒    │
└──────┬──────┘
       │
       └───────→ 回到开始
```

## 注意事项

1. **ADB 授权**（可选）：如果点击不生效
   ```bash
   adb shell pm grant com.ai.autoagent android.permission.SYSTEM_ALERT_WINDOW
   ```

2. **无障碍服务**（推荐）：更可靠的点击
   - 设置 → 无障碍 → Androlua → 启用

3. **电池优化**：关闭以保证后台运行
   - 设置 → 应用 → Androlua → 电池 → 不优化

## 参考资料

- [Androlua GitHub](https://github.com/nirenr/androlua)
- [阿里云百炼文档](https://help.aliyun.com/zh/dashscope/)
- [Qwen-VL 模型文档](https://help.aliyun.com/zh/dashscope/developer-reference/use-qwen-vl)

---
*最后更新：2026-03-20*
