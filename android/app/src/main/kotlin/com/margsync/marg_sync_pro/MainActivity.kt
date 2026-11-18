package com.margsync.marg_sync_pro

import android.media.AudioManager
import android.media.ToneGenerator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.margsync.marg_sync_pro/beep"
    private var toneGenerator: ToneGenerator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 95)
        } catch (_: Exception) {
            toneGenerator = null
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "playScanBeep" -> {
                        try {
                            toneGenerator?.startTone(ToneGenerator.TONE_PROP_ACK, 150)
                        } catch (_: Exception) {}
                        result.success(true)
                    }
                    "playShutterClick" -> {
                        try {
                            toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP, 70)
                        } catch (_: Exception) {}
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onDestroy() {
        try {
            toneGenerator?.release()
        } catch (_: Exception) {}
        toneGenerator = null
        super.onDestroy()
    }
}
