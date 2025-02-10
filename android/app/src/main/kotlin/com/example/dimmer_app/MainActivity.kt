package com.example.dimmer_app 

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.net.Uri
import android.os.Build
import android.os.IBinder
import android.provider.Settings
import android.view.Gravity
import android.view.View
import android.view.WindowManager
import android.widget.LinearLayout
import io.flutter.embedding.android.FlutterActivity 
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() { // MainActivity now handles MethodChannel
    private val CHANNEL = "com.example.dimmer_app/OverlayService"
    private var overlayServiceIntent: Intent? = null // Store the Intent
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler { call, result ->
            if (call.method == "startOverlay") {
                startOverlay()
                result.success(null) // Indicate success to Flutter
            } else if (call.method == "stopOverlay") {
                stopOverlay()
                result.success(null) // Indicate success to Flutter
            } else {
                result.notImplemented() // Handle unknown methods
            }
        }
    }


    private fun startOverlay() {
        if (overlayServiceIntent == null) {
            overlayServiceIntent = Intent(this, OverlayService::class.java)
            startForegroundService(overlayServiceIntent) // Use startForegroundService for newer Android
        }
    }

    private fun stopOverlay() {
        if (overlayServiceIntent != null) {
            stopService(overlayServiceIntent)
            overlayServiceIntent = null
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopOverlay() // Stop the service when the activity is destroyed
    }
}