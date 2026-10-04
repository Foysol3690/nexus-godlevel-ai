package com.foysol.jarvis

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.ContactsContract
import android.speech.tts.TextToSpeech
import android.telephony.TelephonyManager
import java.util.Locale

class MayaCallReceiver : BroadcastReceiver(), TextToSpeech.OnInitListener {
    private var tts: TextToSpeech? = null
    private var announcement: String = "Incoming call"
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) return
        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
        if (state != TelephonyManager.EXTRA_STATE_RINGING) return
        val number = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
        val name = if (number.isNullOrBlank()) null else contactName(context, number)
        announcement = if (!name.isNullOrBlank()) "Incoming call from $name" else "Incoming call"
        tts = TextToSpeech(context.applicationContext, this)
    }
    private fun contactName(context: Context, number: String): String? {
        return try {
            val uri = android.net.Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, android.net.Uri.encode(number))
            context.contentResolver.query(uri, arrayOf(ContactsContract.PhoneLookup.DISPLAY_NAME), null, null, null)?.use { cursor ->
                if (cursor.moveToFirst()) cursor.getString(0) else null
            }
        } catch (_: Exception) { null }
    }
    override fun onInit(status: Int) {
        val engine = tts ?: return
        if (status == TextToSpeech.SUCCESS) {
            engine.language = Locale("en", "IN")
            engine.speak(announcement, TextToSpeech.QUEUE_FLUSH, null, "maya_incoming_call")
        }
    }
}
