package com.foysol.jarvis

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    companion object { private const val TAG = "BootReceiver" }
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED || intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            Log.i(TAG, "Device boot detected. Starting Jarvis Gateway Service.")
            val serviceIntent = Intent(context, GatewayForegroundService::class.java)
            serviceIntent.action = GatewayForegroundService.ACTION_START
            try { context.startForegroundService(serviceIntent) } catch (e: Exception) { Log.e(TAG, "Failed to start Gateway Service on boot", e) }
        }
    }
}
