package com.screen.aiassistant;

import android.Manifest;
import android.accessibilityservice.AccessibilityServiceInfo;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.view.accessibility.AccessibilityManager;
import android.widget.Toast;

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;

import com.google.android.material.button.MaterialButton;
import com.google.android.material.card.MaterialCardView;
import com.google.android.material.textfield.TextInputEditText;
import com.screen.aiassistant.service.ClickAccessibilityService;
import com.screen.aiassistant.service.ScreenCaptureService;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * 主活动
 * 屏幕 AI 助手的主界面
 */
public class MainActivity extends AppCompatActivity {

    private static final String TAG = "MainActivity";
    private static final String PREFS_NAME = "screen_ai_prefs";

    // UI 组件
    private MaterialButton startStopBtn;
    private MaterialButton accessibilityBtn;
    private MaterialButton overlayBtn;
    private MaterialButton saveConfigBtn;
    private MaterialButton clearLogBtn;
    private TextInputEditText apiKeyInput;
    private TextInputEditText apiUrlInput;
    private TextInputEditText modelInput;
    private com.google.android.material.textview.MaterialTextView statusText;
    private com.google.android.material.textview.MaterialTextView logText;

    // 服务
    private ScreenCaptureService captureService;
    private BailianApiService apiService;

    // 状态
    private boolean isRunning = false;
    private Handler mainHandler;
    private ExecutorService executor;

    // 权限请求
    private ActivityResultLauncher<Intent> mediaProjectionLauncher;
    private ActivityResultLauncher<String> permissionLauncher;

    // 配置
    private String apiKey = "sk-sp-eb075370e39b4f24ac34f979f401f619";
    private String apiUrl = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation";
    private String model = "qwen3.5-plus";

    // 截图服务Intent
    private Intent captureServiceIntent;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mainHandler = new Handler(Looper.getMainLooper());
        executor = Executors.newSingleThreadExecutor();

        initViews();
        loadConfig();
        setupListeners();
        setupPermissionLaunchers();
        
        // 请求通知权限 (Android 13+)
        requestNotificationPermission();

        log("应用已启动");
    }

    private void initViews() {
        startStopBtn = findViewById(R.id.startStopBtn);
        accessibilityBtn = findViewById(R.id.accessibilityBtn);
        overlayBtn = findViewById(R.id.overlayBtn);
        saveConfigBtn = findViewById(R.id.saveConfigBtn);
        clearLogBtn = findViewById(R.id.clearLogBtn);
        apiKeyInput = findViewById(R.id.apiKeyInput);
        apiUrlInput = findViewById(R.id.apiUrlInput);
        modelInput = findViewById(R.id.modelInput);
        statusText = findViewById(R.id.statusText);
        logText = findViewById(R.id.logText);

        // 设置默认值
        apiKeyInput.setText(apiKey);
        apiUrlInput.setText(apiUrl);
        modelInput.setText(model);
    }

    private void loadConfig() {
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        apiKey = prefs.getString("api_key", apiKey);
        apiUrl = prefs.getString("api_url", apiUrl);
        model = prefs.getString("model", model);

        apiKeyInput.setText(apiKey);
        apiUrlInput.setText(apiUrl);
        modelInput.setText(model);
    }

    private void saveConfig() {
        apiKey = apiKeyInput.getText().toString().trim();
        apiUrl = apiUrlInput.getText().toString().trim();
        model = modelInput.getText().toString().trim();

        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE);
        prefs.edit()
            .putString("api_key", apiKey)
            .putString("api_url", apiUrl)
            .putString("model", model)
            .apply();

        log("配置已保存");
        Toast.makeText(this, "配置已保存", Toast.LENGTH_SHORT).show();
    }

    private void setupListeners() {
        // 启动/停止按钮
        startStopBtn.setOnClickListener(v -> {
            if (isRunning) {
                stopService();
            } else {
                startService();
            }
        });

        // 无障碍权限按钮
        accessibilityBtn.setOnClickListener(v -> requestAccessibilityPermission());

        // 悬浮窗权限按钮
        overlayBtn.setOnClickListener(v -> requestOverlayPermission());

        // 保存配置按钮
        saveConfigBtn.setOnClickListener(v -> saveConfig());

        // 清空日志按钮
        clearLogBtn.setOnClickListener(v -> logText.setText("日志将显示在这里...\n"));
    }

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

    private void setupPermissionLaunchers() {
        // MediaProjection 权限
        mediaProjectionLauncher = registerForActivityResult(
                new ActivityResultContracts.StartActivityForResult(),
                result -> {
                    if (result.getResultCode() == RESULT_OK) {
                        Intent serviceIntent = new Intent(this, ScreenCaptureService.class);
                        serviceIntent.putExtra("result_code", result.getResultCode());
                        serviceIntent.putExtra("result_data", result.getData());

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startForegroundService(serviceIntent);
                        } else {
                            startService(serviceIntent);
                        }

                        isRunning = true;
                        updateUI();
                        log("截图服务已启动");
                    } else {
                        log("截图权限被拒绝");
                    }
                }
        );

        // 权限请求
        permissionLauncher = registerForActivityResult(
                new ActivityResultContracts.RequestPermission(),
                isGranted -> {
                    if (isGranted) {
                        log("权限已授予");
                    } else {
                        log("权限被拒绝");
                    }
                }
        );
    }

    private void startService() {
        // 检查权限
        if (!isAccessibilityEnabled()) {
            Toast.makeText(this, "请先授予无障碍权限", Toast.LENGTH_LONG).show();
            requestAccessibilityPermission();
            return;
        }

        if (!isOverlayEnabled()) {
            Toast.makeText(this, "请先授予悬浮窗权限", Toast.LENGTH_LONG).show();
            requestOverlayPermission();
            return;
        }

        // 请求截图权限
        requestMediaProjection();
    }

    private void stopService() {
        isRunning = false;
        stopService(captureServiceIntent);
        updateUI();
        log("服务已停止");
    }

    private void requestMediaProjection() {
        // 使用 MediaProjectionManager 创建截图 Intent
        android.media.projection.MediaProjectionManager projectionManager =
                (android.media.projection.MediaProjectionManager) getSystemService(Context.MEDIA_PROJECTION_SERVICE);
        if (projectionManager != null) {
            mediaProjectionLauncher.launch(projectionManager.createScreenCaptureIntent());
        }
    }

    private void requestAccessibilityPermission() {
        Intent intent = new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS);
        startActivity(intent);
        log("请启用无障碍服务");
    }

    private void requestOverlayPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                    Uri.parse("package:" + getPackageName()));
            startActivity(intent);
            log("请授予悬浮窗权限");
        }
    }

    private boolean isAccessibilityEnabled() {
        AccessibilityManager am = (AccessibilityManager) getSystemService(Context.ACCESSIBILITY_SERVICE);
        List<AccessibilityServiceInfo> enabledServices = am.getEnabledAccessibilityServiceList(
                AccessibilityServiceInfo.FEEDBACK_GENERIC);

        for (AccessibilityServiceInfo service : enabledServices) {
            if (service.getId().contains(getPackageName())) {
                return true;
            }
        }
        return false;
    }

    private boolean isOverlayEnabled() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(this);
        }
        return true;
    }

    private void updateUI() {
        if (isRunning) {
            startStopBtn.setText("停止服务");
            statusText.setText("运行中");
            statusText.setTextColor(ContextCompat.getColor(this, R.color.success));
        } else {
            startStopBtn.setText("启动服务");
            statusText.setText("未启动");
            statusText.setTextColor(ContextCompat.getColor(this, R.color.error));
        }
    }

    private void log(String message) {
        String timestamp = new SimpleDateFormat("HH:mm:ss", Locale.getDefault()).format(new Date());
        String logMessage = "[" + timestamp + "] " + message + "\n";
        mainHandler.post(() -> logText.append(logMessage));
        android.util.Log.d(TAG, message);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (isRunning) {
            stopService();
        }
        executor.shutdown();
    }
}
