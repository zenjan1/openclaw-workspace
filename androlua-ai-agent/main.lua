-- AI 代理自动点击器
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

-- 配置
local API_KEY = "sk-sp-eb075370e39b4f24ac34f979f401f619"
local API_URL = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"
local MODEL = "qwen-vl-plus"
local CHECK_INTERVAL = 2000 -- 每次循环间隔（毫秒）

-- 全局变量
local running = false
local statusText = "未启动"

-- 主界面
local layout = LinearLayout(activity)
layout.setOrientation(LinearLayout.VERTICAL)
layout.setPadding(50, 50, 50, 50)

local title = TextView(activity)
title.setText("AI 自动点击代理")
title.setTextSize(24)
title.setGravity(Gravity.CENTER)
layout.addView(title)

statusText = TextView(activity)
statusText.setText("状态：未启动")
statusText.setTextSize(18)
statusText.setPadding(0, 30, 0, 30)
layout.addView(statusText)

local startBtn = Button(activity)
startBtn.setText("启动")
startBtn.setTextSize(18)
startBtn:setOnClickListener(View.OnClickListener(function()
    if not running then
        startService()
        startBtn.setText("停止")
    else
        stopService()
        startBtn.setText("启动")
    end
end))
layout.addView(startBtn)

local logText = TextView(activity)
logText.setText("日志:\n")
logText.setTextSize(14)
logText.setPadding(0, 30, 0, 0)
layout.addView(logText)

local scrollView = ScrollView(activity)
scrollView.addView(layout)
activity.setContentView(scrollView)

-- 日志函数
function log(msg)
    local time = os.date("%H:%M:%S")
    logText.setText(logText.getText() .. "[" .. time .. "] " .. msg .. "\n")
    print(msg)
end

-- 检查并请求权限
function checkPermissions()
    local permissions = {
        "android.permission.READ_EXTERNAL_STORAGE",
        "android.permission.WRITE_EXTERNAL_STORAGE",
        "android.permission.SYSTEM_ALERT_WINDOW",
    }

    for _, permission in ipairs(permissions) do
        if activity.checkSelfPermission(permission) ~= PackageManager.PERMISSION_GRANTED then
            activity.requestPermissions({permission}, 1)
            log("请求权限：" .. permission)
        end
    end
end

-- 截屏函数
function captureScreen()
    log("开始截屏...")
    local path = activity.getExternalFilesDir(nil).getAbsolutePath() .. "/screenshot.png"

    -- 使用媒体投影截屏
    local mediaProjection = activity.getSystemService(Context.MEDIA_PROJECTION_SERVICE)

    -- 创建截图意图
    local intent = mediaProjection.createScreenCaptureIntent()
    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    activity.startActivity(intent)

    -- 备用方法：使用 shell 命令截屏
    os.execute("screencap -p " .. path)

    -- 等待截图完成
    Thread.sleep(500)

    local file = File(path)
    if file.exists() then
        log("截图成功：" .. path)
        return path
    else
        log("截图失败")
        return nil
    end
end

-- 将图片转换为 Base64
function imageToBase64(imagePath)
    log("转换图片为 Base64...")
    local file = File(imagePath)
    local length = file.length()
    local inputStream = FileInputStream(file)
    local buffer = ByteArray(length)
    inputStream.read(buffer)
    inputStream.close()

    local base64 = android.util.Base64.encodeToString(buffer, android.util.Base64.NO_WRAP)
    log("Base64 长度：" .. #base64)
    return base64
end

-- 发送图片到 AI 分析
function sendToAI(imageBase64)
    log("发送图片到 AI 分析...")

    -- 构建请求
    local prompt = "这是一个手机屏幕截图。请分析屏幕内容，并告诉我应该点击哪个位置来实现最有意义的操作。" ..
                   "请以 JSON 格式返回，包含两个字段：x 和 y，表示点击的坐标。" ..
                   "例如：{\"x\": 500, \"y\": 300}" ..
                   "只返回 JSON，不要有其他文字。"

    local requestBody = {
        model = MODEL,
        input = {
            messages = {
                {
                    role = "user",
                    content = {
                        {type = "text", text = prompt},
                        {type = "image", image = "data:image/png;base64," .. imageBase64}
                    }
                }
            }
        },
        parameters = {
            temperature = 0.1,
            max_tokens = 200
        }
    }

    -- 发送 HTTP 请求
    local url = URL(API_URL)
    local connection = url.openConnection()
    connection.setRequestMethod("POST")
    connection.setRequestProperty("Authorization", "Bearer " .. API_KEY)
    connection.setRequestProperty("Content-Type", "application/json")
    connection.setDoOutput(true)
    connection.setConnectTimeout(30000)
    connection.setReadTimeout(30000)

    -- 写入请求体
    local outputStream = connection.getOutputStream()
    local jsonString = JSON.encode(requestBody)
    outputStream.write(jsonString.getBytes("UTF-8"))
    outputStream.close()

    -- 读取响应
    local responseCode = connection.getResponseCode()
    log("API 响应码：" .. responseCode)

    if responseCode == 200 then
        local inputStream = connection.getInputStream()
        local reader = BufferedReader(InputStreamReader(inputStream))
        local response = ""
        local line
        while true do
            line = reader.readLine()
            if line == nil then break end
            response = response .. line
        end
        reader.close()
        inputStream.close()

        log("AI 响应：" .. response)

        -- 解析响应
        local jsonResponse = JSONObject(response)
        local output = jsonResponse.getJSONObject("output")
        local text = output.getString("text")

        -- 提取坐标
        local x, y = text:match('"x"%s*:%s*(%d+)')
        local y = text:match('"y"%s*:%s*(%d+)')

        if x and y then
            return tonumber(x), tonumber(y)
        else
            -- 尝试其他格式
            x, y = text:match("(%d+)%s*[xXx×]%s*(%d+)")
            if x and y then
                return tonumber(x), tonumber(y)
            end
        end
    else
        local errorStream = connection.getErrorStream()
        if errorStream then
            local errorReader = BufferedReader(InputStreamReader(errorStream))
            local errorLine
            while true do
                errorLine = errorReader.readLine()
                if errorLine == nil then break end
                log("错误：" .. errorLine)
            end
            errorReader.close()
        end
    end

    return nil, nil
end

-- 执行点击
function performClick(x, y)
    log("执行点击：" .. x .. ", " .. y)

    -- 使用 input 命令执行点击
    local cmd = string.format("input tap %d %d", x, y)
    os.execute(cmd)

    log("点击已执行")
end

-- 主循环
function mainLoop()
    running = true
    statusText.setText("状态：运行中")
    log("服务已启动")

    while running do
        -- 截屏
        local screenshotPath = captureScreen()
        if screenshotPath then
            -- 转换图片
            local base64 = imageToBase64(screenshotPath)

            -- 发送 AI 分析
            local x, y = sendToAI(base64)

            -- 执行点击
            if x and y then
                performClick(x, y)
            else
                log("未能解析 AI 返回的坐标")
            end

            -- 清理截图
            File(screenshotPath):delete()
        end

        -- 等待下一次循环
        Thread.sleep(CHECK_INTERVAL)
    end

    statusText.setText("状态：已停止")
    log("服务已停止")
end

-- 启动服务
function startService()
    checkPermissions()

    -- 在新线程中运行主循环
    local thread = Thread(Runnable(mainLoop))
    thread.start()
end

-- 停止服务
function stopService()
    running = false
end

-- 请求无障碍服务（可选，用于更可靠的点击）
function requestAccessibility()
    log("请求无障碍服务...")
    -- 这里可以添加无障碍服务配置
end

-- 初始化
checkPermissions()
log("AI 代理已初始化")
