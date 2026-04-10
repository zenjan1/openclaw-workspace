package com.screen.aiassistant;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

/**
 * 百炼 API 服务
 * 调用阿里云百炼 qwen-vl 模型分析屏幕截图
 */
public class BailianApiService {

    private static final String TAG = "BailianApiService";

    private String apiKey;
    private String apiUrl;
    private String model;

    private final OkHttpClient client;
    private final Gson gson;

    public interface ApiCallback {
        void onSuccess(int x, int y);
        void onError(String error);
    }

    public BailianApiService() {
        this.client = new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .readTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .build();
        this.gson = new Gson();
    }

    public void setConfig(String apiKey, String apiUrl, String model) {
        this.apiKey = apiKey;
        this.apiUrl = apiUrl;
        this.model = model;
    }

    /**
     * 将 Bitmap 转换为 Base64 字符串
     */
    public String bitmapToBase64(Bitmap bitmap) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, baos);
        byte[] imageBytes = baos.toByteArray();
        return Base64.encodeToString(imageBytes, Base64.NO_WRAP);
    }

    /**
     * 将 Base64 字符串转换为 Bitmap
     */
    public Bitmap base64ToBitmap(String base64String) {
        try {
            byte[] imageBytes = Base64.decode(base64String, Base64.NO_WRAP);
            return BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.length);
        } catch (Exception e) {
            Log.e(TAG, "Base64 解码失败", e);
            return null;
        }
    }

    /**
     * 发送截图到 AI 分析
     * @param bitmap 屏幕截图
     * @param callback 回调
     */
    public void analyzeScreen(Bitmap bitmap, ApiCallback callback) {
        if (apiKey == null || apiUrl == null) {
            callback.onError("API 配置不完整");
            return;
        }

        String imageBase64 = bitmapToBase64(bitmap);
        Log.d(TAG, "图片 Base64 长度：" + imageBase64.length());

        // 构建请求体
        JsonObject requestBody = createRequestBody(imageBase64);
        String jsonBody = gson.toJson(requestBody);

        Log.d(TAG, "请求体：" + jsonBody);

        // 创建请求
        Request request = new Request.Builder()
                .url(apiUrl)
                .post(RequestBody.create(jsonBody, MediaType.parse("application/json; charset=utf-8")))
                .addHeader("Authorization", "Bearer " + apiKey)
                .addHeader("Content-Type", "application/json")
                .build();

        // 异步发送请求
        client.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                Log.e(TAG, "请求失败", e);
                callback.onError("网络请求失败：" + e.getMessage());
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                try {
                    String responseBody = response.body().string();
                    Log.d(TAG, "响应码：" + response.code());
                    Log.d(TAG, "响应体：" + responseBody);

                    if (response.isSuccessful()) {
                        parseResponse(responseBody, callback);
                    } else {
                        callback.onError("API 错误：" + response.code() + " - " + responseBody);
                    }
                } catch (Exception e) {
                    Log.e(TAG, "解析响应失败", e);
                    callback.onError("解析响应失败：" + e.getMessage());
                }
            }
        });
    }

    /**
     * 构建请求体
     */
    private JsonObject createRequestBody(String imageBase64) {
        JsonObject requestBody = new JsonObject();
        requestBody.addProperty("model", model);

        // 构建 input 对象
        JsonObject input = new JsonObject();
        
        // 构建 messages 数组
        com.google.gson.JsonArray messages = new com.google.gson.JsonArray();
        JsonObject message = new JsonObject();
        message.addProperty("role", "user");
        
        // 构建 content 数组
        com.google.gson.JsonArray content = new com.google.gson.JsonArray();
        
        // 添加文本内容
        JsonObject textItem = new JsonObject();
        textItem.addProperty("type", "text");
        textItem.addProperty("text", "这是一个手机屏幕截图。请分析屏幕内容，找出最值得点击的位置。请以 JSON 格式返回点击坐标，格式为：{\"x\": 数字， \"y\": 数字}。只返回 JSON 坐标，不要有其他文字。");
        content.add(textItem);
        
        // 添加图片内容
        JsonObject imageItem = new JsonObject();
        imageItem.addProperty("type", "image_url");
        JsonObject imageUrl = new JsonObject();
        imageUrl.addProperty("url", "data:image/png;base64," + imageBase64);
        imageItem.add("image_url", imageUrl);
        content.add(imageItem);
        
        message.add("content", content);
        messages.add(message);
        
        input.add("messages", messages);
        requestBody.add("input", input);

        // 添加 parameters
        JsonObject parameters = new JsonObject();
        parameters.addProperty("temperature", 0.1);
        parameters.addProperty("max_tokens", 500);
        requestBody.add("parameters", parameters);

        return requestBody;
    }

    /**
     * 解析响应
     */
    private void parseResponse(String responseBody, ApiCallback callback) {
        try {
            JsonObject json = gson.fromJson(responseBody, JsonObject.class);
            JsonObject output = json.getAsJsonObject("output");
            String text = output.get("text").getAsString();

            Log.d(TAG, "AI 返回文本：" + text);

            // 尝试从文本中提取 JSON 坐标
            int[] coords = parseCoordinates(text);
            if (coords != null && coords.length == 2) {
                Log.d(TAG, "解析坐标成功：x=" + coords[0] + ", y=" + coords[1]);
                callback.onSuccess(coords[0], coords[1]);
            } else {
                callback.onError("无法解析坐标：" + text);
            }
        } catch (Exception e) {
            Log.e(TAG, "解析 JSON 失败", e);
            callback.onError("解析 JSON 失败：" + e.getMessage());
        }
    }

    /**
     * 从 AI 返回的文本中解析坐标
     */
    private int[] parseCoordinates(String text) {
        // 尝试匹配 JSON 格式 {"x": 100, "y": 200}
        String xPattern = "\"x\"\\s*:\\s*(\\d+)";
        String yPattern = "\"y\"\\s*:\\s*(\\d+)";

        java.util.regex.Pattern xRegex = java.util.regex.Pattern.compile(xPattern);
        java.util.regex.Pattern yRegex = java.util.regex.Pattern.compile(yPattern);

        java.util.regex.Matcher xMatcher = xRegex.matcher(text);
        java.util.regex.Matcher yMatcher = yRegex.matcher(text);

        if (xMatcher.find() && yMatcher.find()) {
            int x = Integer.parseInt(xMatcher.group(1));
            int y = Integer.parseInt(yMatcher.group(1));
            return new int[]{x, y};
        }

        // 尝试匹配简单格式 100x200 或 100,200
        String simplePattern = "(\\d+)\\s*[xX,，×]\\s*(\\d+)";
        java.util.regex.Pattern simpleRegex = java.util.regex.Pattern.compile(simplePattern);
        java.util.regex.Matcher simpleMatcher = simpleRegex.matcher(text);

        if (simpleMatcher.find()) {
            int x = Integer.parseInt(simpleMatcher.group(1));
            int y = Integer.parseInt(simpleMatcher.group(2));
            return new int[]{x, y};
        }

        // 尝试匹配纯数字序列
        String numberPattern = "(\\d+)";
        java.util.regex.Pattern numberRegex = java.util.regex.Pattern.compile(numberPattern);
        java.util.regex.Matcher numberMatcher = numberRegex.matcher(text);

        if (numberMatcher.find()) {
            int x = Integer.parseInt(numberMatcher.group(1));
            if (numberMatcher.find()) {
                int y = Integer.parseInt(numberMatcher.group(2));
                return new int[]{x, y};
            }
        }

        return null;
    }
}
