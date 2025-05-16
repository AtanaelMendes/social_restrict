@file:Suppress("DEPRECATION")

package com.example.flutter_screentime

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
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.flutter_screentime.ForegroundService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.util.*
import android.os.Build;

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
                println("Dispositivo inicializado!")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        println("INIT NATIVE CREATE")
        super.onCreate(savedInstanceState)
        saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
        setupMethodChannel()

        requestLocationPermissions()
        registerBootUpReceiver()
    }

    private fun setupMethodChannel() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            println("CALL ----- METHODS")
            when {
                call.method.equals("addToLockedApps") -> {
                    val args = call.arguments as HashMap<*, *>
                    println("$args ----- ARGS")
                    val greetings = showCustomNotification(args)
                    result.success(greetings)
                }
                call.method.equals("setPasswordInNative") -> {
                    val args = call.arguments
                    val editor: SharedPreferences.Editor = saveAppData!!.edit()
                    editor.putString("password", "$args")
                    editor.apply()
                    result.success("Success")
                }
                call.method.equals("checkOverlayPermission") -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                call.method.equals("stopForeground") -> {
                    stopForegroundService()
                }
                call.method.equals("startForeground") -> {
                    startForegroundService()
                }
                call.method.equals("askOverlayPermission") -> {
                    result.success(checkOverlayPermission())
                }
                call.method.equals("askUsageStatsPermission") -> {
                    if (!isAccessGranted()) {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        startActivity(intent)
                    }
                }
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
        if (ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED ||
            ContextCompat.checkSelfPermission(this, android.Manifest.permission.FOREGROUND_SERVICE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

            ActivityCompat.requestPermissions(this,
                arrayOf(android.Manifest.permission.ACCESS_FINE_LOCATION, android.Manifest.permission.ACCESS_COARSE_LOCATION, android.Manifest.permission.FOREGROUND_SERVICE_LOCATION),
                LOCATION_PERMISSION_REQUEST_CODE)
        } else {
            startForegroundService()
        }
    }

    companion object {
        private const val LOCATION_PERMISSION_REQUEST_CODE = 1
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                startForegroundService()
            } else {
                println("Permissão de localização negada.")
            }
        }
    }

    @SuppressLint("CommitPrefEdits", "LaunchActivityFromNotification")
    private fun showCustomNotification(args: HashMap<*, *>): String {
        lockedAppList = emptyList()
        appInfo = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val arr: ArrayList<Map<String, *>> = args["app_list"] as ArrayList<Map<String, *>>

        for (element in arr) {
            run breaking@{
                for (i in appInfo!!.indices) {
                    if (appInfo!![i].packageName.toString() == element["package_name"].toString()) {
                        val ogList = lockedAppList
                        lockedAppList = ogList + appInfo!![i]
                        return@breaking
                    }
                }
            }
        }

        var packageData: List<String> = emptyList()

        for (element in lockedAppList) {
            val ogList = packageData
            packageData = ogList + element.packageName
        }

        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.remove("app_data")
        editor.putString("app_data", "$packageData")
        editor.apply()

        startForegroundService()

        return "Success"
    }

    private fun setIfServiceClosed(data: String) {
        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.putString("is_stopped", data)
        editor.apply()
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
            val myIntent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION)
            startActivity(myIntent)
        }
        return Settings.canDrawOverlays(this)
    }

    private fun isAccessGranted(): Boolean {
        return try {
            val packageManager = packageManager
            val applicationInfo = packageManager.getApplicationInfo(packageName, 0)
            val appOpsManager: AppOpsManager = getSystemService(APP_OPS_SERVICE) as AppOpsManager
            val mode = appOpsManager.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                applicationInfo.uid, applicationInfo.packageName
            )
            mode == AppOpsManager.MODE_ALLOWED
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "samples.flutter.dev/native").setMethodCallHandler { call, result ->
            if (call.method == "sendValues") {
                _customerId = call.argument<Int>("id")
                _companyId = call.argument<Int>("companyId")

                val prefs = getSharedPreferences("MyPrefs", Context.MODE_PRIVATE)
                val editor = prefs.edit()
                editor.putInt("customerId", _customerId ?: 0)
                editor.putInt("companyId", _companyId ?: 0)
                editor.apply()

                if (_customerId != 0 && _companyId != 0) {
                    val intent = Intent(this, ForegroundService::class.java).apply {
                        putExtra("customerId", _customerId)
                        putExtra("companyId", _companyId)
                    }

                    startService(intent)
                }

                result.success("Received values")
            } else {
                result.notImplemented()
            }
        }
    }
}
