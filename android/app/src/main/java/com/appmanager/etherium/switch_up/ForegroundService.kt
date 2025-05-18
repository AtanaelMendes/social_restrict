package com.parentalcontrol.dayone

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.*
import android.content.Context
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Binder
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.view.View
import androidx.core.app.NotificationCompat
import java.util.*
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory


// import java.util.Calendar
// import com.google.android.gms.location.FusedLocationProviderClient
// import com.google.android.gms.location.LocationServices
// import com.google.firebase.database.FirebaseDatabase
// import android.content.Intent

class ForegroundService : Service() {
    private var appInfo: List<ApplicationInfo>? = null
    private var lockedAppList: List<ApplicationInfo> = emptyList()
    private var unLockedAppList: List<ApplicationInfo> = emptyList()
    private var saveAppData: SharedPreferences? = null
    private val binder = LocalBinder()
    // private lateinit var fusedLocationClient: FusedLocationProviderClient

    private var _customerId: Int? = null
    private var _companyId: Int? = null

    inner class LocalBinder : Binder() {
        fun getService(): ForegroundService = this@ForegroundService
    }

    override fun onBind(intent: Intent): IBinder? {
        throw UnsupportedOperationException("")
        return binder
    }
    var timer: Timer = Timer()
    var isTimerStarted = false
    var timerReload: Long = 500
    var currentAppActivityList = arrayListOf<String>()
    private var mHomeWatcher = HomeWatcher(this)

    override fun onCreate() {
        super.onCreate()
        saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val channelId = "AppLock-10"
        val channel =
                NotificationChannel(
                        channelId,
                        "Channel human readable title",
                        NotificationManager.IMPORTANCE_DEFAULT
                )
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager)
                .createNotificationChannel(channel)
        val notification =
                NotificationCompat.Builder(this, channelId)
                        .setContentTitle("")
                        .setContentText("")
                        .build()
        startForeground(1, notification)
        startMyOwnForeground()
       // apllyPassword()
        startTimeApps()

        val intent = Intent(this, ForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

   private fun apllyPassword(code: String?) {
        val saveAppData = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val editor: SharedPreferences.Editor = saveAppData.edit()

        if (!code.isNullOrEmpty()) {
                editor.putString("password", code)
        } else {
                println("Código não pode ser nulo ou vazio")
        }
        
        editor.apply()
        println("Senha aplicada: $code")
    }

    private fun unblockBlockApps(args: HashMap<*, *>): String {
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

        return "Success unblock apps**********"
    }

    private fun unblockApps(args: HashMap<*, *>): List<ApplicationInfo> {
        val arr: ArrayList<Map<String, *>>? = args["app_list"] as ArrayList<Map<String, *>>

        // val arr = args["app_list"] as? ArrayList<*> ?: emptyList<Any>()
        val newLockedAppList = lockedAppList.toMutableList()

        for (element in arr ?: emptyList()) {
            val map = element as? Map<String, *>
            if (map != null) {
                println("Dayone Trying to remove: ${map["package_name"].toString()}")
                newLockedAppList.removeAll {
                    val shouldRemove = it.packageName.toString() == map["package_name"].toString()
                    if (shouldRemove) {
                        println("Dayone Match found, removing: ${it.packageName}")
                    }
                    shouldRemove
                }
            }
        }
        lockedAppList = newLockedAppList

        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.remove("app_data")
        editor.putString("app_data", lockedAppList.joinToString { it.packageName })
        editor.apply()

        println("Dayone App desbloqueado Atualizada------FFFFFFF: ${lockedAppList}")
        return lockedAppList
    }

    private fun blockApps(args: HashMap<*, *>): List<ApplicationInfo> {
        // lockedAppList = emptyList()
        println("Dayone App bloqueado------DENTRO DA FUNCAO: ${lockedAppList}")
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

        val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.remove("app_data")
        editor.putString("app_data", lockedAppList.joinToString { it.packageName })
        editor.apply()

        println("Dayone App bloqueado------DENTRO DA FUNCAO: ${lockedAppList}")
        return lockedAppList
    }

    private fun startTimeApps() {
        val handler = Handler()
        // val delay = 5 * 60 * 1000
        val delay = 60 * 1000
        var execute = 0

        val periodicRunnable =
                object : Runnable {
                    override fun run() {
                        execute++
                        val baseDelay = delay * execute
                        println("Dayone -- ${execute} MINUTO -- Executadoooo APPTime--")

                        val retrofit =
                                Retrofit.Builder()
                                        //.baseUrl("http://66.94.104.117:3003/api/")
                                        .baseUrl("https://www.rhbrasil.com.br/app/api/")
                                        //.baseUrl("https://app-api.rhbrasil.com.br/api/")
                                       
                                        .addConverterFactory(NullOnEmptyConverterFactory())
                                        .addConverterFactory(GsonConverterFactory.create())
                                        .build()

                        var blockListSuccess: List<Block>? = null
                        println("Dayone blockListSuccess: ${blockListSuccess}")
                        var lockedAppList: List<ApplicationInfo>? = null
                        var lockedAppPackageNames: Set<String>? = null
                        var matchingBlocks: List<Block>? = null
                        var matchingIds: List<Int>? = null

                        var unBlockListSuccess: List<UnBlock>? = null
                        var unLockedAppList: List<ApplicationInfo>? = null
                        var unLockedAppPackageNames: Set<String>? = null
                        var matchingUnBlocks: List<UnBlock>? = null
                        var matchingUnBlocksIds: List<Int>? = null

                        val api = retrofit.create(RHBrasilApi::class.java)
                        val prefs = getSharedPreferences("MyPrefs", Context.MODE_PRIVATE)
                        val _newCustomerId = prefs.getInt("customerId", 0)
                        val _newCompanyId = prefs.getInt("companyId", 0)

                        println("Dayone _newCompanyId: ${_newCustomerId}")
                        println("Dayone _newCompanyId: ${_newCompanyId}")

                        val call =
                                api.getAllOrders(
                                        "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoicmgtYnJhc2lsIiwiZW52IjoibG9jYWwiLCJpYXQiOjE3MDUxNTk3MzMsImV4cCI6MTAwMDAxNzA1MTU5NzMzfQ.TvnxFXLdz0dM9hIOGtmjhakIi2yLSMnhWb9QvNhiZZQ",
                                        _newCustomerId,
                                        _newCompanyId
                                )
                        call.enqueue(
                                object : Callback<Order> {
                                    override fun onResponse(
                                            call: Call<Order>,
                                            response: retrofit2.Response<Order>
                                    ) {
                                        if (response.isSuccessful) {
                                            val order = response.body()
                                            val appsList: List<Apps> = order?.apps ?: listOf()
                                            val appsListTime: List<String> =
                                                    appsList.map { it.bundle }
                                            val bundleIdAppsListTime: List<Int> =
                                                    appsList.map { it.appId }

                                            println(
                                                    "******* Inicio Print dos apps monitoramento tempo *******"
                                            )
                                            println("Dayone AppsList: ${appsList}")
                                            println("Dayone AppsListTime: ${appsListTime}")
                                            println(
                                                    "Dayone BundleIdAppsListTime: ${bundleIdAppsListTime}"
                                            )
                                            println(
                                                    "******* Fim Print dos apps monitoramento tempo *******"
                                            )
                                            // Get para pegar a lista dos apps bloqueados
                                            val appsListSuccess: List<Apps>? = order?.apps
                                            println("Dayone AppsListSuccess*********: ${appsListSuccess}")

                                            println(
                                                    "******* Inicio Print dos apps bloqueados *******"
                                            )
                                            println("Dayone Order: ${order}")
                                            println("Dayone ID: ${order?.id}")
                                            println("Dayone Block: ${order?.block}")
                                            println("Dayone UnBlock: ${order?.unBlock}")
                                            println("******* Fim Print dos apps bloqueados *******")

                                            val blockList: List<Block> = order?.block ?: listOf()
                                            println("Dayone BlockList no começo: ${blockList}")
                                            val unBlockList: List<UnBlock> =
                                                    order?.unBlock ?: listOf()

                                            val bundleListBlock: List<String> =
                                                    blockList.map { it.bundle }
                                            val bundleIdListBlock: List<Int> =
                                                    blockList.map { it.id }

                                            val bundleListUnBlock: List<String> =
                                                    unBlockList.map { it.bundle }
                                            val bundleIdListUnBlock: List<Int> =
                                                    unBlockList.map { it.id }

                                            val args = HashMap<String, Any>()
                                            val argsUnblock = HashMap<String, Any>()
                                            val appList = ArrayList<Map<String, *>>()
                                            val app1 =
                                                    hashMapOf(
                                                            "package_name" to
                                                                    "com.google.android.youtube"
                                                    )

                                            if (execute == 0) {
                                                appList.add(app1)
                                            }
                                            execute++
                                            val mapList: ArrayList<Map<String, Any>> = ArrayList()
                                            val mapListUnblock: ArrayList<Map<String, Any>> =
                                                    ArrayList()

                                            bundleListBlock.forEach { bundle ->
                                                val map = hashMapOf("package_name" to bundle)
                                                mapList.add(map)
                                            }

                                            bundleListUnBlock.forEach { bundle ->
                                                val map = hashMapOf("package_name" to bundle)
                                                mapListUnblock.add(map)
                                            }

                                            println("Dayone MAPApp listBlock: ${mapList}")
                                            println("Dayone MAPApp listUnBlock: ${mapListUnblock}")

                                            if (blockList.isNotEmpty()) {

                                                args["app_list"] = mapList
                                                // blockApps(args)
                                                blockListSuccess = order?.block
                                                lockedAppList = blockApps(args)
                                                println(
                                                        "Dayone lockedAppList listBlock: ${mapList}"
                                                )
                                                lockedAppPackageNames =
                                                        lockedAppList
                                                                ?.map { it.packageName }
                                                                ?.toSet()
                                                val lockedAppPackageNamesCopy =
                                                        lockedAppPackageNames.orEmpty()
                                                matchingBlocks =
                                                        blockListSuccess?.filter {
                                                            it.bundle in lockedAppPackageNamesCopy
                                                        }
                                                matchingIds = matchingBlocks?.map { it.id }
                                            }

                                            // Fim do Get para pegar a lista dos apps bloqueados

                                            // Aqui começa a verificacao do GET para pegar a lista
                                            // dos apps desbloqueados

                                            if (unBlockList.isNotEmpty()) {
                                                argsUnblock["app_list"] = mapListUnblock
                                                println(
                                                        "Dayone *********************************************"
                                                )
                                                println(
                                                        "Dayone App desbloqueado ARGS++++++++: ${argsUnblock["app_list"]}"
                                                )
                                                unBlockListSuccess = order?.unBlock
                                                println(
                                                        "Dayone ----DESBLOQUEIO--- unBlockListSuccess: ${unBlockListSuccess}"
                                                )
                                                unLockedAppList = unblockApps(argsUnblock)
                                                println(
                                                        "Dayone ----DESBLOQUEIO--- unLockedAppList: ${unLockedAppList}"
                                                )
                                                unLockedAppPackageNames =
                                                        (argsUnblock["app_list"] as?
                                                                        List<Map<String, String>>)
                                                                ?.mapNotNull { it["package_name"] }
                                                                ?.toSet()
                                                println(
                                                        "Dayone ----DESBLOQUEIO--- unLockedAppPackageNames: ${unLockedAppPackageNames}"
                                                )
                                                val unLockedAppPackageNamesCopy =
                                                        unLockedAppPackageNames.orEmpty()
                                                println(
                                                        "Dayone ----DESBLOQUEIO--- unLockedAppPackageNamesCopy: ${unLockedAppPackageNamesCopy}"
                                                )
                                                matchingUnBlocks =
                                                        unBlockListSuccess?.filter {
                                                            it.bundle in unLockedAppPackageNamesCopy
                                                        }
                                                println(
                                                        "Dayone ----DESBLOQUEIO--- matchingUnBlocks: ${matchingUnBlocks}"
                                                )
                                                matchingUnBlocksIds =
                                                        matchingUnBlocks?.map { it.id }
                                            }

                                            // *************************   **********
                                            // ***************** */

                                            // Aqui começa a verificacao do tempo em foreground
                                            appsList.forEach { app ->
                                                // val (totalTimeForeground, totalTimeBackground,
                                                // total) = getAppUsageTime(this@ForegroundService,
                                                // app.bundle)
                                                //     println("Dayone Total time in foreground:
                                                // $totalTimeForeground")
                                                //     println("Dayone Total time in background:
                                                // $totalTimeBackground")
                                                //     println("Dayone Total time: $total")
                                                val totalTimeForeground =
                                                        getAppUsageTime(
                                                                this@ForegroundService,
                                                                app.bundle
                                                        )
                                                println(
                                                        "Dayone Total time in foreground for ${app.bundle}: $totalTimeForeground s"
                                                )

                                                if (totalTimeForeground > 0) {
                                                    // println("Dayone App bloqueado:
                                                    // ${blockApps(app.bundle)}")
                                                    val appTime =
                                                            AppTime(
                                                                    customerId = _newCustomerId
                                                                                    ?: 0,
                                                                    appId = app.appId,
                                                                    // time = total.toInt(),
                                                                    time =
                                                                            totalTimeForeground
                                                                                    .toInt(),
                                                                    companyId = _newCompanyId
                                                            )
                                                    println("Dayone AppTime: ${appTime}")
                                                    val api =
                                                            retrofit.create(
                                                                    RHBrasilAppTimeApi::class.java
                                                            )
                                                    val call =
                                                            api.postAppTime(
                                                                    "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoicmgtYnJhc2lsIiwiZW52IjoibG9jYWwiLCJpYXQiOjE3MDUxNTk3MzMsImV4cCI6MTAwMDAxNzA1MTU5NzMzfQ.TvnxFXLdz0dM9hIOGtmjhakIi2yLSMnhWb9QvNhiZZQ",
                                                                    appTime
                                                            )
                                                    call.enqueue(
                                                            object : Callback<Void> {
                                                                override fun onResponse(
                                                                        call: Call<Void>,
                                                                        response: Response<Void>
                                                                ) {
                                                                    if (response.isSuccessful) {
                                                                        println(
                                                                                "Dayone ****AppTime****POST Success ${response.code()}"
                                                                        )
                                                                    } else {
                                                                        println(
                                                                                "Dayone ****AppTime****Error no POST"
                                                                        )
                                                                    }
                                                                }

                                                                override fun onFailure(
                                                                        call: Call<Void>,
                                                                        t: Throwable
                                                                ) {
                                                                    println(
                                                                            "Dayone Failure: ${t.message}"
                                                                    )
                                                                }
                                                            }
                                                    )
                                                } else {
                                                    println(
                                                            "Dayone ****AppTime**** Error: O valor deve ser zero ${app.bundle}: $totalTimeForeground s"
                                                    )
                                                }
                                            }
                                            // Fim da verificacao do tempo em foreground

                                            // ************** ********* ********* ******** ********
                                            // ******** */

                                            // Aqui começa a verificacao do PUT para bloquear
                                            if (mapList.isNotEmpty()) {
                                                println("Dayone Success posso fazer o PUT")

                                                val orders =
                                                        matchingIds?.map {
                                                            Orders(id = it, status = 1)
                                                        }
                                                                ?: listOf()
                                                val orderBlock =
                                                        OrderBlock(
                                                                customerId = _customerId ?: 0,
                                                                orders = orders
                                                        )

                                                println("Dayone OrderBlock: ${orderBlock}")

                                                val api =
                                                        retrofit.create(
                                                                RHBrasilOrderApi::class.java
                                                        )
                                                val call =
                                                        api.putAllOrders(
                                                                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoicmgtYnJhc2lsIiwiZW52IjoibG9jYWwiLCJpYXQiOjE3MDUxNTk3MzMsImV4cCI6MTAwMDAxNzA1MTU5NzMzfQ.TvnxFXLdz0dM9hIOGtmjhakIi2yLSMnhWb9QvNhiZZQ",
                                                                orderBlock
                                                        )
                                                println("Dayone -----Call-----: ${call}")

                                                call.enqueue(
                                                        object : Callback<Void> {
                                                            override fun onResponse(
                                                                    call: Call<Void>,
                                                                    response: Response<Void>
                                                            ) {
                                                                if (response.isSuccessful) {
                                                                    val orderBlockResponse =
                                                                            response.body()
                                                                    if (orderBlockResponse != null
                                                                    ) {
                                                                        // println("Dayone
                                                                        // *****OrderBlock
                                                                        // Response****:
                                                                        // ${orderBlockResponse}")
                                                                        println(
                                                                                "Dayone Deu certo no PUT Bloqueio ${orderBlockResponse}"
                                                                        )
                                                                    } else {
                                                                        println(
                                                                                "Dayone PUT Success Bloqueio, but no response body."
                                                                        )
                                                                    }
                                                                    println(
                                                                            "Dayone PUT Success Bloqueio ${response.code()}"
                                                                    )
                                                                } else {
                                                                    // println("Dayone Res[ponse]
                                                                    // ${response.errorBody()?.string()}")
                                                                    println(
                                                                            "Dayone Error no PUT do Bloqueio"
                                                                    )
                                                                }
                                                            }

                                                            override fun onFailure(
                                                                    call: Call<Void>,
                                                                    t: Throwable
                                                            ) {
                                                                println(
                                                                        "Dayone Failure: ${t.message}"
                                                                )
                                                            }
                                                        }
                                                )
                                            } else {
                                                println("Dayone Error no PUT")
                                            }
                                            // Fim da verificacao do PUT para bloquear

                                            // Aqui começa a verificacao do PUT para desbloquear
                                            if (mapListUnblock.isNotEmpty()) {
                                                println(
                                                        "Dayone ----DESBLOQUEIO---Success posso fazer o PUT"
                                                )
                                                println(
                                                        "Dayone ----DESBLOQUEIO---MatchingUnBlocksIds: ${matchingUnBlocksIds}"
                                                )

                                                val orders =
                                                        matchingUnBlocksIds?.map {
                                                            Orders(id = it, status = 1)
                                                        }
                                                                ?: listOf()
                                                println(
                                                        "Dayone ----DESBLOQUEIO--- Orders: ${orders}"
                                                )
                                                val orderBlock =
                                                        OrderBlock(
                                                                customerId = _customerId ?: 0,
                                                                orders = orders
                                                        )

                                                println("Dayone OrderBlock: ${orderBlock}")

                                                val api =
                                                        retrofit.create(
                                                                RHBrasilOrderApi::class.java
                                                        )
                                                val call =
                                                        api.putAllOrders(
                                                                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55IjoicmgtYnJhc2lsIiwiZW52IjoibG9jYWwiLCJpYXQiOjE3MDUxNTk3MzMsImV4cCI6MTAwMDAxNzA1MTU5NzMzfQ.TvnxFXLdz0dM9hIOGtmjhakIi2yLSMnhWb9QvNhiZZQ",
                                                                orderBlock
                                                        )
                                                println("Dayone -----Call-----: ${call}")

                                                call.enqueue(
                                                        object : Callback<Void> {
                                                            override fun onResponse(
                                                                    call: Call<Void>,
                                                                    response: Response<Void>
                                                            ) {
                                                                if (response.isSuccessful) {
                                                                    val orderUnBlockResponse =
                                                                            response.body()
                                                                    if (orderUnBlockResponse != null
                                                                    ) {
                                                                        println(
                                                                                "Dayone *****OrderUnBlock Response****: ${orderUnBlockResponse}"
                                                                        )
                                                                        println(
                                                                                "Dayone Deu certo no PUT ${orderUnBlockResponse}"
                                                                        )
                                                                    } else {
                                                                        println(
                                                                                "Dayone PUT Success Desbloqueio, but no response body."
                                                                        )
                                                                    }
                                                                    println(
                                                                            "Dayone PUT Success Desbloqueio ${response.code()}"
                                                                    )
                                                                } else {
                                                                    // println("Dayone Res[ponse]
                                                                    // ${response.errorBody()?.string()}")
                                                                    println(
                                                                            "Dayone Error no PUT Desbloqueio"
                                                                    )
                                                                }
                                                            }

                                                            override fun onFailure(
                                                                    call: Call<Void>,
                                                                    t: Throwable
                                                            ) {
                                                                println(
                                                                        "Dayone Failure: ${t.message}"
                                                                )
                                                            }
                                                        }
                                                )
                                            } else {
                                                println("Dayone Error no PUT")
                                            }
                                            // Fim da verificacao do PUT para desbloquear

                                        } else {
                                            println(
                                                    "Dayone Error: ${response.errorBody()?.string()}"
                                            )
                                        }
                                    }

                                    override fun onFailure(call: Call<Order>, t: Throwable) {
                                        println("Dayone Failure: ${t.message}")
                                    }
                                }
                        )

                        handler.postDelayed(this, delay.toLong())
                    }
                }

        handler.post(periodicRunnable)
    }

    // override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
    //     return super.onStartCommand(intent, flags, startId)
    // }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val prefs = getSharedPreferences("MyPrefs", Context.MODE_PRIVATE)

        _customerId = prefs.getInt("customerId", 0)
        _companyId = prefs.getInt("companyId", 0)

        println("Dayone Received in ForegroundService - Customer ID: ${_customerId}")
        println("Dayone Received in ForegroundService - Company ID: ${_companyId}")

   
        return START_REDELIVER_INTENT
    }

    private fun startMyOwnForeground() {
        val window = Window(this)
        mHomeWatcher.setOnHomePressedListener(
                object : HomeWatcher.OnHomePressedListener {
                    override fun onHomePressed() {
                        println("Dayone onHomePressed")
                        currentAppActivityList.clear()
                        if (window.isOpen()) {
                            window.close()
                        }
                    }
                    override fun onHomeLongPressed() {
                        println("Dayone onHomeLongPressed")
                        currentAppActivityList.clear()
                        if (window.isOpen()) {
                            window.close()
                        }
                    }
                }
        )
        mHomeWatcher.startWatch()
        timerRun(window)
    }

    override fun onDestroy() {
        timer.cancel()
        mHomeWatcher.stopWatch()
        super.onDestroy()
    }

    private fun timerRun(window: Window) {
        timer.scheduleAtFixedRate(
                object : TimerTask() {
                    override fun run() {
                        isTimerStarted = true
                        isServiceRunning(window)
                    }
                },
                0,
                timerReload
        )
    }

    @SuppressLint("NewApi")
    fun getForegroundApp(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 1000 * 60 * 600 // Últimos 3 segundos

        // Buscar os eventos de uso recentes
        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        val event = UsageEvents.Event()
        var lastResumedPackage: String? = null

        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                lastResumedPackage = event.packageName // O último pacote que foi trazido para o primeiro plano
            }
        }
        return lastResumedPackage
    }

    fun isServiceRunning(window: Window) {
        val saveAppData: SharedPreferences =
                applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)


        val handler = Handler(Looper.getMainLooper())
        var isWindowOpen = false

        val monitorRunnable = object : Runnable {
            override fun run() {
                val foregroundApp = getForegroundApp()
                val lockedAppList: List<String> = saveAppData.getString("app_data", "AppList")!!
                        .replace("[", "")
                        .replace("]", "")
                        .split(",")
                        .map { it.trim() }
                if (foregroundApp != null && lockedAppList.contains(foregroundApp.trim())) {
                    if (!isWindowOpen) {
                        window.txtView?.visibility = View.INVISIBLE
                        window.open()
                        isWindowOpen = true
                    }
                } else {
                    if (isWindowOpen) {
                        window.close()
                        isWindowOpen = false
                    }
                }

                // Continuar monitorando
                handler.postDelayed(this, 3000) // Verifica a cada 1 segundo
            }
        }

        handler.post(monitorRunnable)
    }

    fun getAppUsageTime(context: Context, packageName: String): Long {
        val usageStatsManager =
                context.getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val timeNow = System.currentTimeMillis()
        val stats =
                usageStatsManager.queryUsageStats(
                        UsageStatsManager.INTERVAL_DAILY,
                        timeNow - 1000 * 3600,
                        timeNow
                )

        var totalTimeForeground: Long = 0
        for (usageStats in stats) {
            if (usageStats.packageName == packageName) {
                totalTimeForeground += usageStats.totalTimeInForeground
            }
        }
        return totalTimeForeground / 1000
    }
}
