package com.screen.aiassistant.service;

import android.accessibilityservice.AccessibilityService;
import android.accessibilityservice.GestureDescription;
import android.content.Intent;
import android.graphics.Path;
import android.graphics.Rect;
import android.os.Build;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;

/**
 * 无障碍服务
 * 用于执行自动点击操作
 */
public class ClickAccessibilityService extends AccessibilityService {

    private static final String TAG = "ClickAccessibilityService";

    private static ClickAccessibilityService instance;

    public static ClickAccessibilityService getInstance() {
        return instance;
    }

    public static boolean isRunning() {
        return instance != null && instance.isServiceRunning();
    }

    private boolean serviceRunning = false;

    @Override
    public void onServiceConnected() {
        super.onServiceConnected();
        instance = this;
        serviceRunning = true;
        Log.d(TAG, "无障碍服务已连接");
    }

    @Override
    public void onInterrupt() {
        Log.d(TAG, "无障碍服务被中断");
        serviceRunning = false;
    }

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {
        // 不需要处理事件，只用于执行手势
    }

    public boolean isServiceRunning() {
        return serviceRunning;
    }

    /**
     * 执行点击操作
     * @param x x 坐标
     * @param y y 坐标
     */
    public void performClick(int x, int y) {
        if (!serviceRunning) {
            Log.e(TAG, "服务未运行");
            return;
        }

        Log.d(TAG, "执行点击：" + x + ", " + y);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            // 使用手势 API 执行点击
            Path path = new Path();
            path.moveTo(x, y);
            
            // 添加一个小的移动路径来模拟点击
            path.lineTo(x + 1, y + 1);

            GestureDescription.Builder builder = new GestureDescription.Builder();
            builder.addStroke(new GestureDescription.StrokeDescription(path, 0, 50));

            GestureDescription gestureDescription = builder.build();

            boolean result = dispatchGesture(gestureDescription, null, null);
            Log.d(TAG, "手势执行结果：" + result);
        } else {
            // 旧版本使用 Root 方式
            Log.e(TAG, "设备版本过低，不支持手势 API");
        }
    }

    /**
     * 获取当前屏幕内容信息
     */
    public String getScreenContent() {
        if (!serviceRunning) {
            return "";
        }

        AccessibilityNodeInfo rootNode = getRootInActiveWindow();
        if (rootNode == null) {
            return "";
        }

        StringBuilder content = new StringBuilder();
        buildContent(rootNode, content, 0);
        return content.toString();
    }

    private void buildContent(AccessibilityNodeInfo node, StringBuilder content, int depth) {
        if (node == null || depth > 3) {
            return;
        }

        if (node.getText() != null) {
            content.append(node.getText()).append("\n");
        }

        for (int i = 0; i < node.getChildCount(); i++) {
            AccessibilityNodeInfo child = node.getChild(i);
            buildContent(child, content, depth + 1);
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        instance = null;
        serviceRunning = false;
        Log.d(TAG, "无障碍服务已销毁");
    }
}
