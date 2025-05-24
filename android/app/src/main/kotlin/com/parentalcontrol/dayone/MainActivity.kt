@file:Suppress("DEPRECATION")

package com.parentalcontrol.dayone

import android.annotation.SuppressLint
import android.app.AppOpsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.provider.Settings
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.*
import android.net.Uri

class MainActivity : FlutterActivity() {
    private val channel = "flutter.native/helper"
    private var appInfo: List<ApplicationInfo>? = null
    private var lockedAppList: List<ApplicationInfo> = emptyList()
    private var saveAppData: SharedPreferences? = null

    private var _customerId: Int? = null
    private var _companyId: Int? = null

    private var isReceiverRegistered = false

    private val bootUpReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (Intent.ACTION_BOOT_COMPLETED == intent.action) {
                Log.d("BootReceiver", "Device bootexxd!")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("MainActivity", "Native code started")
        saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        registerBootUpReceiver()
    }

    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "addToLockedApps" -> result.notImplemented() // Implement as needed
                "setPasswordInNative" -> result.notImplemented() // Implement as needed
                "checkOverlayPermission" -> result.success(Settings.canDrawOverlays(this))
                "stopForeground" -> stopForegroundService()
                "startForeground" -> {
                    logStackTrace()
                    startForegroundService()
                    result.success(null)
                }
                "askOverlayPermission" -> {
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
                    intent.data = Uri.parse("package:$packageName")
                    startActivity(intent)
                    result.success(true)
                }
                "askUsageStatsPermission" -> {
                    val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                    intent.data = Uri.parse("package:$packageName")
                    startActivity(intent)
                    result.success(true)
                }
                "sendValues" -> {
                    _customerId = call.argument("id")
                    _companyId = call.argument("companyId")

                    getSharedPreferences("MyPrefs", Context.MODE_PRIVATE).edit().apply {
                        putInt("customerId", _customerId ?: 0)
                        putInt("companyId", _companyId ?: 0)
                        apply()
                    }

                    if (_customerId != 0 && _companyId != 0) {
                        val intent = Intent(this, ForegroundService::class.java).apply {
                            putExtra("customerId", _customerId)
                            putExtra("companyId", _companyId)
                        }
                        startService(intent)
                    }

                    result.success("Received values")
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun registerBootUpReceiver() {
        val filter = IntentFilter(Intent.ACTION_BOOT_COMPLETED)
        registerReceiver(bootUpReceiver, filter, Context.RECEIVER_EXPORTED)
        isReceiverRegistered = true
    }

    override fun onDestroy() {
        super.onDestroy()
        if (isReceiverRegistered) {
            unregisterReceiver(bootUpReceiver)
            isReceiverRegistered = false
        }
    }

    private fun requestLocationPermissions() {
        val permissions = arrayOf(
            android.Manifest.permission.ACCESS_FINE_LOCATION,
            android.Manifest.permission.ACCESS_COARSE_LOCATION,
            android.Manifest.permission.FOREGROUND_SERVICE_LOCATION
        )

        if (permissions.any {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }) {
            ActivityCompat.requestPermissions(this, permissions, LOCATION_PERMISSION_REQUEST_CODE)
        } else {
            logStackTrace()
            startForegroundService()
        }
    }

    companion object {
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                logStackTrace()
                startForegroundService()
            } else {
                Log.d("Permissions", "Location permission denied.")
            }
        }
    }

    @SuppressLint("CommitPrefEdits", "LaunchActivityFromNotification")
    private fun showCustomNotification(args: HashMap<*, *>): String {
        lockedAppList = emptyList()
        appInfo = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val arr = args["app_list"] as? ArrayList<*> ?: return "Invalid app list"

        for (element in arr) {
            val map = element as? Map<*, *> ?: continue
            val packageName = map["package_name"]?.toString() ?: continue
            appInfo?.firstOrNull { it.packageName == packageName }?.let {
                lockedAppList = lockedAppList + it
            }
        }

        val packageData = lockedAppList.map { it.packageName }

        saveAppData?.edit()?.apply {
            putString("app_data", packageData.toString())
            apply()
        }

        logStackTrace()
        startForegroundService()

        return "Success"
    }

    private fun setIfServiceClosed(data: String) {
        saveAppData?.edit()?.apply {
            putString("is_stopped", data)
            apply()
        }
    }

    private fun startForegroundService() {
        if (Settings.canDrawOverlays(this)) {
            setIfServiceClosed("1")
            ContextCompat.startForegroundService(this, Intent(this, ForegroundService::class.java))
        }
    }

    private fun stopForegroundService() {
        setIfServiceClosed("0")
        stopService(Intent(this, ForegroundService::class.java))
    }

    private fun checkOverlayPermission(): Boolean {
        if (!Settings.canDrawOverlays(this)) {
            startActivity(Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION))
        }
        return Settings.canDrawOverlays(this)
    }

    private fun isAccessGranted(): Boolean {
        return try {
            val appOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            val mode = appOpsManager.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                applicationInfo.uid, applicationInfo.packageName
            )
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: Exception) {
            false
        }
    }

    private fun logStackTrace() {
        val stackTrace = Throwable().stackTrace.joinToString("\n") { "\tat $it" }
        Log.d("ForegroundService", "startForegroundService CHAMANDO\nCaller:\n$stackTrace")
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupMethodChannel(flutterEngine)
    }
}
