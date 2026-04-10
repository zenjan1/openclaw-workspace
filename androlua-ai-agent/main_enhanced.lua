-- AI 代理自动点击器 - 增强版
-- 功能：循环截屏 -> 发送 AI 分析 -> 执行点击

require "import"
import "android.widget.*"
import "android.view.*"
import "android.graphics.*"
import "android.app.*"
import "java.io.*"
import "java.net.*"
import "javax.net.ssl.*"
import "org.json.*"
import "android.accessibilityservice.*"
import "android.view.accessibility.*"

-- ============ 配置区 ============
local CONFIG = {
    API_KEY = "sk-sp-eb075370e39b4f24ac34f979f401f619",
    API_URL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation",
    MODEL = "qwen-vl-plus",
    CHECK_INTERVAL = 2000, -- 每次循环间隔（毫秒）
    SCREENSHOT_PATH = nil, -- 运行时确定
    PROMPT = [[这是一个手机屏幕截图。请分析屏幕内容，判断当前是什么应用或界面，
然后告诉我应该点击哪个位置来实现最有意义的操作（比如关闭广告、点击按钮等）。
请以纯 JSON 格式返回，只包含 x 和 y 两个数字字段，表示点击的像素坐标。
示例：{"x": 500, "y": 300}
注意：只返回 JSON，不要有任何其他文字、解释或标记。]]
}

-- ============ 全局变量 ============
local running = false
local statusText = "未启动"
local logText = ""
local mainThread = nil
local screenHeight = 0
local screenWidth = 0

-- ============ UI 布局 ============
local layout = LinearLayout(activity)
layout.setOrientation(LinearLayout.VERTICAL)
layout.setPadding(30, 30, 30, 30)
layout.setBackgroundColor(0xFF1A1A2E)

-- 标题
local title = TextView(activity)
title.setText("🤖 AI 自动点击代理")
title.setTextSize(22)
title.setTextColor(0xFFFFFFFF)
title.setGravity(Gravity.CENTER)
title.setPadding(0, 20, 0, 30)
layout.addView(title)

-- 状态显示
local statusContainer = LinearLayout(activity)
statusContainer.setOrientation(LinearLayout.HORIZONTAL)
statusContainer.setGravity(Gravity.CENTER)

local statusDot = TextView(activity)
statusDot.setText("●")
statusDot.setTextSize(20)
statusDot.setTextColor(0xFFFF4444)

statusText = TextView(activity)
statusText.setText("  未启动")
statusText.setTextSize(18)
statusText.setTextColor(0xFFFFFFFF)

statusContainer.addView(statusDot)
statusContainer.addView(statusText)
layout.addView(statusContainer)

-- 控制按钮
local buttonLayout = LinearLayout(activity)
buttonLayout.setOrientation(LinearLayout.HORIZONTAL)
buttonLayout.setGravity(Gravity.CENTER)
buttonLayout.setPadding(0, 20, 0, 20)

local startBtn = Button(activity)
startBtn.setText("▶ 启动")
startBtn.setTextSize(16)
startBtn:setBackgroundColor(0xFF4CAF50)
startBtn:setPadding(50, 20, 50, 20)
startBtn:setOnClickListener(View.OnClickListener(function()
    if not running then
        startService()
        startBtn.setText("⏹ 停止")
        startBtn:setBackgroundColor(0xFFF44336)
    else
        stopService()
        startBtn.setText("▶ 启动")
        startBtn:setBackgroundColor(0xFF4CAF50)
    end
end))

local clearBtn = Button(activity)
clearBtn.setText("🗑 清空日志")
clearBtn.setTextSize(16)
clearBtn:setBackgroundColor(0xFF2196F3)
clearBtn:setPadding(50, 20, 50, 20)
clearBtn:setOnClickListener(View.OnClickListener(function()
    logText = "日志:\n"
    updateLog()
end))

buttonLayout.addView(startBtn)
buttonLayout.addView(clearBtn)
layout.addView(buttonLayout)

-- 信息面板
local infoContainer = LinearLayout(activity)
infoContainer.setOrientation(LinearLayout.VERTICAL)
infoContainer:setBackgroundColor(0xFF2D2D44)
infoContainer:setPadding(20, 15, 20, 15)

local infoText = TextView(activity)
infoText.setText("📊 统计信息")
infoText.setTextColor(0xFFE0E0E0)
infoText.setTextSize(14)

local statsText = TextView(activity)
statsText.setText("循环次数：0\n成功点击：0\n失败次数：0")
statsText.setTextColor(0xFFB0B0B0)
statsText.setTextSize(14)
statsText:setPadding(0, 10, 0, 0)

infoContainer.addView(infoText)
infoContainer.addView(statsText)
layout.addView(infoContainer)

-- 日志区域
local logLabel = TextView(activity)
logLabel.setText("\n📝 运行日志:")
logLabel.setTextColor(0xFFE0E0E0)
logLabel.setTextSize(16)
logLabel:setPadding(0, 20, 0, 10)
layout.addView(logLabel)

local logEditText = EditText(activity)
logEditText.setText("日志:\n")
logEditText.setTextSize(12)
logEditText:setBackgroundColor(0xFF16213E)
logEditText:setTextColor(0xFF00E676)
logEditText:setPadding(15, 15, 15, 15)
logEditText:setGravity(Gravity.TOP)
logEditText:setEnabled(false)

local scrollview = ScrollView(activity)
scrollview:setLayoutParams(LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 300))
scrollview:addView(logEditText)
layout.addView(scrollview)

activity.setContentView(layout)

-- ============ 统计信息 ============
local stats = {
    loops = 0,
    success = 0,
    failures = 0
}

function updateStats()
    statsText.setText(string.format(
        "循环次数：%d\n成功点击：%d\n失败次数：%d",
        stats.loops, stats.success, stats.failures
    ))
end

-- ============ 日志函数 ============
function log(msg)
    local time = os.date("%H:%M:%S")
    logText = logText .. "[" .. time .. "] " .. msg .. "\n"

    -- 限制日志长度
    if #logText > 5000 then
        logText = logText:sub(-5000)
    end

    updateLog()
    print("[AI-Agent] " .. msg)
end

function updateLog()
    if logEditText then
        logEditText.setText(logText)
        -- 滚动到底部
        local layout = logEditText.getLayout()
        if layout then
            local scroll = layout.getLineTop(layout.getLineCount) - logEditText:getHeight()
            if scroll > 0 then
                logEditText:scrollTo(0, scroll)
            end
        end
    end
end

-- ============ 权限检查 ============
function checkPermissions()
    local permissions = {
        {"android.permission.READ_EXTERNAL_STORAGE", "存储读取"},
        {"android.permission.WRITE_EXTERNAL_STORAGE", "存储写入"},
        {"android.permission.SYSTEM_ALERT_WINDOW", "悬浮窗"},
    }

    local needRequest = false
    for _, p in ipairs(permissions) do
        if activity.checkSelfPermission(p[1]) ~= PackageManager.PERMISSION_GRANTED then
            needRequest = true
            log("缺少权限：" .. p[2])
        end
    end

    if needRequest then
        local permArray = {}
        for _, p in ipairs(permissions) do
            table.insert(permArray, p[1])
        end
        activity.requestPermissions(permArray, 1)
        log("已请求权限...")
    end

    -- 获取屏幕尺寸
    local dm = activity.getResources().getDisplayMetrics()
    screenWidth = dm.widthPixels
    screenHeight = dm.heightPixels
    log(string.format("屏幕尺寸：%d x %d", screenWidth, screenHeight))
end

-- ============ 截屏函数 ============
function captureScreen()
    log("📸 开始截屏...")

    -- 设置截图路径
    local cacheDir = activity.getCacheDir().getAbsolutePath()
    CONFIG.SCREENSHOT_PATH = cacheDir .. "/screenshot_" .. os.time() .. ".png"

    -- 方法 1: 使用 screencap 命令
    local result = os.execute("screencap -p " .. CONFIG.SCREENSHOT_PATH)

    -- 等待截图完成
    Thread.sleep(300)

    -- 验证截图
    local file = File(CONFIG.SCREENSHOT_PATH)
    if file.exists() and file.length() > 0 then
        log("✅ 截图成功：" .. math.floor(file.length()/1024) .. "KB")
        return CONFIG.SCREENSHOT_PATH
    else
        log("❌ 截图失败")
        return nil
    end
end

-- ============ Base64 转换 ============
function imageToBase64(imagePath)
    log("🔄 转换图片为 Base64...")

    local file = File(imagePath)
    local length = file.length()
    local inputStream = FileInputStream(file)
    local buffer = ByteArray(length)
    inputStream.read(buffer)
    inputStream.close()

    local base64 = android.util.Base64.encodeToString(buffer, android.util.Base64.NO_WRAP)
    log("📦 Base64 长度：" .. #base64)
    return base64
end

-- ============ HTTP 请求 ============
function httpPost(url, headers, body)
    local connection = URL(url):openConnection()
    connection:setRequestMethod("POST")
    connection:setDoOutput(true)
    connection:setConnectTimeout(30000)
    connection:setReadTimeout(60000)

    -- 设置请求头
    for key, value in pairs(headers) do
        connection:setRequestProperty(key, value)
    end

    -- 写入请求体
    local outputStream = connection:getOutputStream()
    outputStream:write(body:getBytes("UTF-8"))
    outputStream:close()

    -- 获取响应
    local responseCode = connection:getResponseCode()
    local inputStream

    if responseCode == 200 then
        inputStream = connection:getInputStream()
    else
        inputStream = connection:getErrorStream()
    end

    local reader = BufferedReader(InputStreamReader(inputStream))
    local response = ""
    local line
    while true do
        line = reader:readLine()
        if line == nil then break end
        response = response .. line
    end
    reader:close()
    inputStream:close()

    return responseCode, response
end

-- ============ AI 分析 ============
function sendToAI(imageBase64)
    log("🤖 发送 AI 分析...")

    -- 构建请求体
    local requestBody = string.format([[
    {
        "model": "%s",
        "input": {
            "messages": [{
                "role": "user",
                "content": [
                    {"type": "text", "text": "%s"},
                    {"type": "image", "image": "data:image/png;base64,%s"}
                ]
            }]
        },
        "parameters": {
            "temperature": 0.1,
            "max_tokens": 256
        }
    }
    ]], CONFIG.MODEL, CONFIG.PROMPT:gsub("\n", "\\n"), imageBase64)

    -- 设置请求头
    local headers = {
        ["Authorization"] = "Bearer " .. CONFIG.API_KEY,
        ["Content-Type"] = "application/json"
    }

    -- 发送请求
    local startTime = os.time()
    local responseCode, response = httpPost(CONFIG.API_URL, headers, requestBody)
    local elapsed = os.time() - startTime

    log("📡 API 响应码：" .. responseCode .. " (耗时：" .. elapsed .. "s)")

    if responseCode == 200 then
        log("📄 AI 响应：" .. response:sub(1, 200) .. "...")

        -- 解析 JSON
        local success, jsonResponse = pcall(function()
            return JSONObject(response)
        end)

        if success then
            local output = jsonResponse:getJSONObject("output")
            local text = output:getString("text")
            log("🎯 AI 建议：" .. text)

            -- 提取坐标（支持多种格式）
            local x, y

            -- 格式 1: {"x": 100, "y": 200}
            x, y = text:match([["x"%s*:%s*(%d+)]])
            if x then
                y = text:match([["y"%s*:%s*(%d+)]])
            end

            -- 格式 2: x: 100, y: 200
            if not x then
                x, y = text:match([["x"%s*:]]), text:match([["y"%s*:]]))
            end

            -- 格式 3: 100x200 或 100,200
            if not x then
                x, y = text:match("(%d+)%s*[xX×]%s*(%d+)")
            end
            if not x then
                x, y = text:match("(%d+)%s*,%s*(%d+)")
            end

            if x and y then
                x, y = tonumber(x), tonumber(y)

                -- 验证坐标范围
                if x > screenWidth then x = screenWidth - 10 end
                if y > screenHeight then y = screenHeight - 10 end

                log("📍 解析坐标：(" .. x .. ", " .. y .. ")")
                return x, y
            else
                log("⚠️ 无法从响应中提取坐标")
            end
        else
            log("❌ JSON 解析失败：" .. tostring(jsonResponse))
        end
    else
        log("❌ API 请求失败：" .. response:sub(1, 200))
    end

    return nil, nil
end

-- ============ 执行点击 ============
function performClick(x, y)
    log("👆 执行点击：(" .. x .. ", " .. y .. ")")

    -- 方法 1: 使用 input 命令
    local cmd = string.format("input tap %d %d", x, y)
    local result = os.execute(cmd)

    if result then
        log("✅ 点击成功")
        stats.success = stats.success + 1
        return true
    else
        -- 方法 2: 使用辅助服务（如果有）
        log("⚠️ input 命令失败，尝试辅助服务...")
        -- 这里可以添加辅助服务点击逻辑
        stats.failures = stats.failures + 1
        return false
    end
end

-- ============ 主循环 ============
function mainLoop()
    running = true
    statusText.setText("  运行中")
    statusDot.setTextColor(0xFF00E676)
    log("🚀 服务已启动")

    while running do
        stats.loops = stats.loops + 1
        updateStats()

        log("🔄 === 第 " .. stats.loops .. " 次循环 ===")

        -- 1. 截屏
        local screenshotPath = captureScreen()
        if screenshotPath then
            -- 2. 转换 Base64
            local base64 = imageToBase64(screenshotPath)

            -- 3. AI 分析
            local x, y = sendToAI(base64)

            -- 4. 执行点击
            if x and y then
                performClick(x, y)
            else
                stats.failures = stats.failures + 1
                updateStats()
            end

            -- 5. 清理截图
            File(screenshotPath):delete()
        else
            stats.failures = stats.failures + 1
            updateStats()
        end

        -- 6. 等待下一次循环
        if running then
            log("⏱ 等待 " .. CONFIG.CHECK_INTERVAL/1000 .. " 秒...")
            Thread.sleep(CONFIG.CHECK_INTERVAL)
        end
    end

    -- 停止
    statusText.setText("  已停止")
    statusDot.setTextColor(0xFFFF4444)
    log("🛑 服务已停止")
end

-- ============ 控制函数 ============
function startService()
    checkPermissions()

    -- 在新线程中运行
    mainThread = Thread(Runnable(function()
        pcall(function()
            mainLoop()
        end)
    end))
    mainThread:start()
end

function stopService()
    if running then
        running = false
        log("⏹ 正在停止服务...")
    end
end

-- ============ 生命周期 ============
function onDestroy()
    stopService()
end

-- ============ 初始化 ============
logText = "📝 日志:\n"
log("📱 AI 自动点击代理已初始化")
log("🔧 配置：模型=" .. CONFIG.MODEL .. ", 间隔=" .. CONFIG.CHECK_INTERVAL/1000 .. "s")
checkPermissions()
updateStats()
