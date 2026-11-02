package com.sharkship.bonut

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Starts / stops the "call in progress" foreground service (see CallForegroundService).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "convoy/call_service")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> {
                        val intent = Intent(this, CallForegroundService::class.java)
                            .putExtra(CallForegroundService.EXTRA_TITLE, call.argument<String>("title"))
                            .putExtra(CallForegroundService.EXTRA_TEXT, call.argument<String>("text"))
                            .putExtra(CallForegroundService.EXTRA_VIDEO, call.argument<Boolean>("video") ?: false)
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                startForegroundService(intent)
                            } else {
                                startService(intent)
                            }
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("start_failed", e.message, null)
                        }
                    }
                    "stop" -> {
                        stopService(Intent(this, CallForegroundService::class.java))
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
