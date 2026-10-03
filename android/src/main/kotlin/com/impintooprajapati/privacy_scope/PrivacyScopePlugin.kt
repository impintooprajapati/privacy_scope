package com.impintooprajapati.privacy_scope

import android.app.Activity
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PrivacyScopePlugin implementing Android native secure window handling */
class PrivacyScopePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private var channel: MethodChannel? = null
    private var activity: Activity? = null
    private var isSecureRequested: Boolean = false
    private var isFlagSecureApplied: Boolean = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "privacy_scope/methods")
        channel?.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "applyPolicy" -> {
                val screenshot = call.argument<String>("screenshot") ?: "allow"
                val appSwitcher = call.argument<String>("appSwitcher") ?: "allow"

                // On Android, FLAG_SECURE protects both screenshots and recent-task switcher previews
                val shouldBeSecure = screenshot == "block" || appSwitcher == "blur" || appSwitcher == "hide"
                isSecureRequested = shouldBeSecure
                updateWindowFlags()
                result.success(null)
            }
            "isScreenCaptured" -> {
                // On standard Android, FLAG_SECURE handles capture blocking natively
                result.success(false)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun updateWindowFlags() {
        val currentActivity = activity ?: return

        currentActivity.runOnUiThread {
            try {
                val window = currentActivity.window ?: return@runOnUiThread
                if (isSecureRequested) {
                    if (!isFlagSecureApplied) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        isFlagSecureApplied = true
                    }
                } else {
                    if (isFlagSecureApplied) {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        isFlagSecureApplied = false
                    }
                }
            } catch (e: Exception) {
                // Prevent crash if window is detached or unavailable
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        if (isSecureRequested) {
            updateWindowFlags()
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        if (isSecureRequested) {
            updateWindowFlags()
        }
    }

    override fun onDetachedFromActivity() {
        if (isFlagSecureApplied) {
            activity?.window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            isFlagSecureApplied = false
        }
        activity = null
    }
}
