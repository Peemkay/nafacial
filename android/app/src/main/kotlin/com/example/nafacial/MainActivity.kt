package com.example.nafacial

import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.nafacial/shortcuts"
    private val BUTTON_CHANNEL = "com.example.nafacial/buttons"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Start the button listener service
        startButtonListenerService()

        // Configure method channels
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialRoute") {
                val route = getRouteFromIntent(intent)
                result.success(route)
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BUTTON_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startButtonService" -> {
                    startButtonListenerService()
                    result.success(true)
                }
                "stopButtonService" -> {
                    stopButtonListenerService()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startButtonListenerService() {
        val serviceIntent = Intent(this, ButtonListenerService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopButtonListenerService() {
        val serviceIntent = Intent(this, ButtonListenerService::class.java)
        stopService(serviceIntent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val route = getRouteFromIntent(intent)
        if (route != null) {
            flutterEngine?.let {
                MethodChannel(it.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("navigateTo", route)
            }
        }
    }

    private fun getRouteFromIntent(intent: Intent): String? {
        return intent.getStringExtra("route")
    }
