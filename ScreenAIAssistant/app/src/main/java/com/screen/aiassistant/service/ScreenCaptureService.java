package com.screen.aiassistant.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.PixelFormat;
import android.hardware.display.DisplayManager;
import android.hardware.display.VirtualDisplay;
import android.media.Image;
import android.media.ImageReader;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.os.Build;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.WindowManager;

import androidx.core.app.NotificationCompat;

import com.screen.aiassistant.MainActivity;
import com.screen.aiassistant.R;

/**
 * 屏幕截图服务
 * 使用 MediaProjection API 捕获屏幕内容
 */
public class ScreenCaptureService extends Service {

    private static final String TAG = "ScreenCaptureService";
    private static final String CHANNEL_ID = "screen_ai_assistant_channel";
    private static final int NOTIFICATION_ID = 1001;

    private MediaProjection mediaProjection;
    private VirtualDisplay virtualDisplay;
    private ImageReader imageReader;
    private int screenWidth;
    private int screenHeight;
    private int screenDensity;

    private Handler mainHandler;
    private ScreenCaptureCallback callback;

    private boolean isRunning = false;

    public interface ScreenCaptureCallback {
        void onScreenCaptured(Bitmap bitmap);
        void onError(String error);
    }

    public void setCallback(ScreenCaptureCallback callback) {
        this.callback = callback;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        mainHandler = new Handler(Looper.getMainLooper());
        initDisplayMetrics();
        createNotificationChannel();
    }

    private void initDisplayMetrics() {
        WindowManager wm = (WindowManager) getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics metrics = new DisplayMetrics();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            DisplayManager dm = (DisplayManager) getSystemService(Context.DISPLAY_SERVICE);
            if (dm != null) {
                android.view.Display display = dm.getDisplay(0);
                if (display != null) {
                    display.getRealMetrics(metrics);
                }
            }
        } else {
            wm.getDefaultDisplay().getRealMetrics(metrics);
        }
        screenWidth = metrics.widthPixels;
        screenHeight = metrics.heightPixels;
        screenDensity = metrics.densityDpi;
        Log.d(TAG, "屏幕尺寸：" + screenWidth + "x" + screenHeight + ", 密度：" + screenDensity);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "服务启动");

        // Android 14+ 要求：必须先启动前台服务，再执行其他操作
        startForeground(NOTIFICATION_ID, createNotification());

        // 获取 MediaProjection
        int resultCode = intent.getIntExtra("result_code", -1);
        Intent resultData = intent.getParcelableExtra("result_data");

        if (resultCode == android.app.Activity.RESULT_OK && resultData != null) {
            MediaProjectionManager projectionManager =
                    (MediaProjectionManager) getSystemService(Context.MEDIA_PROJECTION_SERVICE);
            if (projectionManager != null) {
                mediaProjection = projectionManager.getMediaProjection(resultCode, resultData);
                initImageReader();
                isRunning = true;
                Log.d(TAG, "MediaProjection 初始化成功");
            } else {
                Log.e(TAG, "无法获取 MediaProjectionManager");
                if (callback != null) {
                    callback.onError("无法获取 MediaProjectionManager");
                }
                stopSelf();
            }
        } else {
            Log.e(TAG, "MediaProjection 权限被拒绝");
            if (callback != null) {
                callback.onError("MediaProjection 权限被拒绝");
            }
            stopSelf();
        }

        return START_STICKY;
    }

    private void initImageReader() {
        // 创建 ImageReader 用于接收屏幕图像
        imageReader = ImageReader.newInstance(screenWidth, screenHeight, PixelFormat.RGBA_8888, 2);

        if (mediaProjection != null) {
            virtualDisplay = mediaProjection.createVirtualDisplay(
                    "ScreenCapture",
                    screenWidth,
                    screenHeight,
                    screenDensity,
                    DisplayManager.VIRTUAL_DISPLAY_FLAG_AUTO_MIRROR,
                    imageReader.getSurface(),
                    null,
                    null
            );
            Log.d(TAG, "VirtualDisplay 已创建");
        }
    }

    /**
     * 捕获屏幕截图
     */
    public Bitmap captureScreen() {
        if (imageReader == null) {
            Log.e(TAG, "ImageReader 未初始化");
            return null;
        }

        try {
            Image image = imageReader.acquireLatestImage();
            if (image == null) {
                Log.d(TAG, "暂无新图像");
                return null;
            }

            Image.Plane[] planes = image.getPlanes();
            if (planes.length == 0) {
                image.close();
                return null;
            }

            // 从 Image 中提取数据创建 Bitmap
            Bitmap bitmap = Bitmap.createBitmap(screenWidth, screenHeight, Bitmap.Config.ARGB_8888);
            bitmap.copyPixelsFromBuffer(planes[0].getBuffer());
            image.close();

            Log.d(TAG, "截图成功：" + screenWidth + "x" + screenHeight);
            return bitmap;
        } catch (Exception e) {
            Log.e(TAG, "截图失败", e);
            if (callback != null) {
                mainHandler.post(() -> callback.onError("截图失败：" + e.getMessage()));
            }
            return null;
        }
    }

    private Notification createNotification() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(
                this, 0, notificationIntent,
                PendingIntent.FLAG_IMMUTABLE
        );

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle(getString(R.string.notification_title))
                .setContentText(getString(R.string.notification_text))
                .setSmallIcon(android.R.drawable.ic_menu_camera)
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel channel = new NotificationChannel(
                    CHANNEL_ID,
                    getString(R.string.notification_channel_name),
                    NotificationManager.IMPORTANCE_LOW
            );
            channel.setDescription(getString(R.string.notification_channel_description));
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(channel);
            }
        }
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        isRunning = false;

        if (virtualDisplay != null) {
            virtualDisplay.release();
        }
        if (imageReader != null) {
            imageReader.close();
        }
        if (mediaProjection != null) {
            mediaProjection.stop();
        }

        Log.d(TAG, "服务已销毁");
    }

    public boolean isRunning() {
        return isRunning;
    }

    public int getScreenWidth() {
        return screenWidth;
    }

    public int getScreenHeight() {
        return screenHeight;
    }
}
