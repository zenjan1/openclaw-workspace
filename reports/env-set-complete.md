# OpenClaw 环境变量设置完成

**设置时间:** 2026-03-30 15:45 GMT+8

---

## ✅ 已执行操作

### 1. 用户环境变量已设置
```
OPENCLAW_HOME = H:\workspace
```

### 2. 设置方式
- 通过 `setx` 命令写入注册表
- 用户级别环境变量（当前用户有效）

---

## 🔄 下一步：重启终端

环境变量设置后**需要重启终端/PowerShell** 才能生效。

### 验证方法

**重启终端后运行:**
```powershell
echo $env:OPENCLAW_HOME
```

**或:**
```cmd
echo %OPENCLAW_HOME%
```

**应该输出:**
```
H:\workspace
```

---

## ✅ 完整验证

重启终端后运行:
```bash
# 检查环境变量
echo $env:OPENCLAW_HOME

# 检查 OpenClaw 状态
openclaw status

# 验证工作区
cd $env:OPENCLAW_HOME\workspace
dir
```

---

## 📁 路径总结

| 项目 | 路径 |
|------|------|
| OpenClaw 主目录 | `H:\workspace` |
| 工作区 | `H:\workspace\workspace` |
| 配置文件 | `H:\workspace\openclaw.json` |
| 技能目录 | `H:\workspace\workspace\skills` |

---

## ⚠️ 注意事项

1. **当前会话不生效**: 设置的环境变量需要新终端才能看到
2. **永久生效**: 设置已写入注册表，永久有效
3. **系统范围**: 只影响当前用户，不影响其他用户

---

## 🗑️ 可选：删除旧文件

确认新位置工作正常后，可以删除:
```
C:\Users\a\.openclaw\
```

**建议保留 1-2 天作为备份!**

---

**设置完成！请重启终端验证** 🎉
