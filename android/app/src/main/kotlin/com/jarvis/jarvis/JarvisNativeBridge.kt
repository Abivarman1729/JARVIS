package com.jarvis.jarvis

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.BatteryManager
import android.os.Build
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor

class JarvisNativeBridge(
    private val activity: Activity,
) : MethodChannel.MethodCallHandler {
    private val executor: Executor = ContextCompat.getMainExecutor(activity)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "deviceInfo" -> result.success(
                mapOf(
                    "manufacturer" to Build.MANUFACTURER,
                    "model" to Build.MODEL,
                    "androidVersion" to Build.VERSION.RELEASE,
                    "sdkInt" to Build.VERSION.SDK_INT,
                ),
            )
            "batteryInfo" -> {
                val battery = activity.getSystemService(BatteryManager::class.java)
                val level = battery?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                if (level == null || level < 0) {
                    result.error("unavailable", "Battery information is unavailable.", null)
                } else {
                    result.success(mapOf("percentage" to level))
                }
            }
            "openUrl" -> openUrl(call, result)
            "authenticate" -> authenticate(result)
            else -> result.notImplemented()
        }
    }

    private fun openUrl(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url")
        if (url.isNullOrBlank()) {
            result.error("invalid_argument", "A URL is required.", null)
            return
        }
        val uri = runCatching { Uri.parse(url) }.getOrNull()
        if (uri == null || uri.scheme !in setOf("https", "http")) {
            result.error("unsafe_url", "Only HTTP and HTTPS URLs are supported.", null)
            return
        }
        val intent = Intent(Intent.ACTION_VIEW, uri)
        if (intent.resolveActivity(activity.packageManager) == null) {
            result.success(false)
            return
        }
        activity.startActivity(intent)
        result.success(true)
    }

    private fun authenticate(result: MethodChannel.Result) {
        val manager = BiometricManager.from(activity)
        val authenticators = BiometricManager.Authenticators.BIOMETRIC_STRONG or
            BiometricManager.Authenticators.DEVICE_CREDENTIAL
        if (manager.canAuthenticate(authenticators) != BiometricManager.BIOMETRIC_SUCCESS) {
            result.error("unavailable", "No device authentication method is available.", null)
            return
        }
        val prompt = BiometricPrompt(
            activity as androidx.fragment.app.FragmentActivity,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(
                    authenticationResult: BiometricPrompt.AuthenticationResult,
                ) {
                    result.success(true)
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    result.success(false)
                }
            },
        )
        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Authenticate JARVIS")
            .setSubtitle("Authentication is required for this action.")
            .setAllowedAuthenticators(authenticators)
            .build()
        prompt.authenticate(promptInfo)
    }
}
