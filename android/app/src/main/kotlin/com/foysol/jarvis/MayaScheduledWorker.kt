package com.foysol.jarvis

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.work.Worker
import androidx.work.WorkerParameters

class MayaScheduledWorker(appContext: Context, params: WorkerParameters) : Worker(appContext, params) {
    override fun doWork(): Result {
        val title = inputData.getString("title")?.take(120) ?: "Maya reminder"
        val body = inputData.getString("body")?.take(1000) ?: "Your scheduled task is ready."
        val channelId = "maya_scheduled_jobs"
        val manager = applicationContext.getSystemService(NotificationManager::class.java)
        manager?.createNotificationChannel(NotificationChannel(channelId, "Maya scheduled jobs", NotificationManager.IMPORTANCE_HIGH).apply { description = "Visible reminders created by Maya" })
        val notification = NotificationCompat.Builder(applicationContext, channelId)
            .setSmallIcon(android.R.drawable.ic_popup_reminder).setContentTitle(title).setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body)).setAutoCancel(true).setPriority(NotificationCompat.PRIORITY_HIGH).build()
        manager?.notify(id.hashCode(), notification)
        return Result.success()
    }
}
