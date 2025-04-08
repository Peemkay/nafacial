package com.example.nafacial

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class ButtonListenerService : Service() {
    private val TAG = "ButtonListenerService"
    private val NOTIFICATION_ID = 1001
    private val CHANNEL_ID = "nafacial_button_listener_channel"
    
    private var volumeButtonReceiver: VolumeButtonReceiver? = null
    private var lastVolumeDownTime: Long = 0
    private var volumeDownCount: Int = 0
    private val DOUBLE_PRESS_TIME = 500 // ms
    private val TRIPLE_PRESS_TIME = 1000 // ms
    
    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "Service created")
        createNotificationChannel()
        startForeground(NOTIFICATION_ID, createNotification())
        registerVolumeButtonReceiver()
    }
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "Service started")
        return START_STICKY
    }
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        unregisterVolumeButtonReceiver()
        Log.d(TAG, "Service destroyed")
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "NAFacial Button Listener"
            val descriptionText = "Listens for button presses to launch camera"
            val importance = NotificationManager.IMPORTANCE_LOW
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
            }
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    
    private fun createNotification(): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("NAFacial Camera Access")
            .setContentText("Press volume down button twice quickly to launch camera")
            .setSmallIcon(R.drawable.ic_camera)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
    
    private fun registerVolumeButtonReceiver() {
        volumeButtonReceiver = VolumeButtonReceiver()
        val filter = IntentFilter().apply {
            addAction("android.media.VOLUME_CHANGED_ACTION")
        }
        registerReceiver(volumeButtonReceiver, filter)
    }
    
    private fun unregisterVolumeButtonReceiver() {
        volumeButtonReceiver?.let {
            unregisterReceiver(it)
            volumeButtonReceiver = null
        }
    }
    
    inner class VolumeButtonReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent?.action == "android.media.VOLUME_CHANGED_ACTION") {
                val extras = intent.extras
                if (extras != null) {
                    val reason = extras.getInt("android.media.EXTRA_VOLUME_STREAM_TYPE", -1)
                    
                    // Check if it's a volume down press
                    if (reason == 3) { // STREAM_MUSIC
                        val currentTime = System.currentTimeMillis()
                        
                        if (currentTime - lastVolumeDownTime < DOUBLE_PRESS_TIME) {
                            volumeDownCount++
                            
                            // Double press detected
                            if (volumeDownCount == 2) {
                                launchCamera()
                                volumeDownCount = 0
                            }
                        } else {
                            // Reset counter if too much time has passed
                            volumeDownCount = 1
                        }
                        
                        lastVolumeDownTime = currentTime
                    }
                }
            }
        }
    }
    
    private fun launchCamera() {
        Log.d(TAG, "Launching camera")
        val intent = Intent(this, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra("route", "live_recognition")
        }
        startActivity(intent)
    }
}
