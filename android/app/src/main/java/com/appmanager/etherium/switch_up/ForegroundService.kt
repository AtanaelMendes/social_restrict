package com.example.flutter_screentime

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.*
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
import com.google.gson.Gson
import com.google.gson.GsonBuilder
import ViaCepService
import ViaCepResponse

import android.content.Context
import androidx.core.content.ContextCompat
import android.content.SharedPreferences
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager

class ForegroundService : Service() {
    private var appInfo: List<ApplicationInfo>? = null
    private var lockedAppList: List<ApplicationInfo> = emptyList()
    private var saveAppData: SharedPreferences? = null

    override fun onBind(intent: Intent): IBinder? {
        throw UnsupportedOperationException("")
    }
    var timer: Timer = Timer()
    var isTimerStarted = false
    var timerReload:Long = 500
    var currentAppActivityList = arrayListOf<String>()
    private var mHomeWatcher = HomeWatcher(this)

    override fun onCreate() {
        super.onCreate()
        val channelId = "AppLock-10"
        val channel = NotificationChannel(
            channelId,
            "Channel human readable title",
            NotificationManager.IMPORTANCE_DEFAULT
        )
        (getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(
            channel
        )
        val notification = NotificationCompat.Builder(this, channelId)
            .setContentTitle("")
            .setContentText("").build()

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
            startForeground(1, notification, 0x00000008) // LOCATION
        } else {
            startForeground(1, notification)
        }

        startMyOwnForeground()
        apllyPassword()
        startPeriodicTask()
    }

    private fun apllyPassword() {
        saveAppData =  applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
         val editor: SharedPreferences.Editor = saveAppData!!.edit()
        editor.putString("password", "$927594")
        editor.apply()
        println("Senha Aplicada")
    }

    private fun unblockBlockApps(args: HashMap<*, *>):String {
        lockedAppList = emptyList()

        appInfo  = packageManager.getInstalledApplications(PackageManager.GET_META_DATA)

        val arr : ArrayList<Map<String,*>> = args["app_list"]  as ArrayList<Map<String,*>>

        for (element in arr){
            run breaking@{
                for (i in appInfo!!.indices){
                    if(appInfo!![i].packageName.toString() == element["package_name"].toString()){
                        val ogList = lockedAppList
                        lockedAppList = ogList + appInfo!![i]
                        return@breaking
                    }
                }
            }
        }


        var packageData:List<String> = emptyList()

        for(element in lockedAppList){
            val ogList = packageData
            packageData = ogList + element.packageName
        }

        val editor: SharedPreferences.Editor =  saveAppData!!.edit()
        editor.remove("app_data")
        editor.putString("app_data", "$packageData")
        editor.apply()

        return "Success"
    }

   private fun startPeriodicTask() {
        val handler = Handler()
        val delay = 30 * 1000
        var execute = 0;

        val periodicRunnable = object : Runnable {
            override fun run() {
                println("-- 1 MINUTO -- Executado --")

                val retrofit = Retrofit.Builder()
                .baseUrl("https://viacep.com.br/")
                .addConverterFactory(GsonConverterFactory.create(GsonBuilder().setLenient().create()))
                .build()

                // Criação do serviço
                val viaCepService = retrofit.create(ViaCepService::class.java)

                // Chamada assíncrona para buscar o CEP
                val call = viaCepService.buscarCep("83404650")

                call.enqueue(object : retrofit2.Callback<ViaCepResponse> {
                    override fun onResponse(
                        call: Call<ViaCepResponse>,
                        response: retrofit2.Response<ViaCepResponse>
                    ) {
                        if (response.isSuccessful) {
                            val resultado = response.body()
                            println("CEP: ${resultado?.cep}")
                            println("Logradouro: ${resultado?.logradouro}")
                            println("Bairro: ${resultado?.bairro}")

                            val args = HashMap<String, Any>()
                            val appList = ArrayList<Map<String, *>>()

                            val app1 = hashMapOf(
                                "package_name" to "com.google.android.youtube"
                            )
                            
                            if (execute == 0) {
                                appList.add(app1)
                            }
                            execute ++
                            args["app_list"] = appList

                            unblockBlockApps(args)
                        } else {
                            println("Deu erro")
                        }
                    }

                    override fun onFailure(call: Call<ViaCepResponse>, t: Throwable) {
                        println("Erro na requisição: ${t}")
                    }
                })

                handler.postDelayed(this, delay.toLong())
            }
        }

        // Inicialize o primeiro agendamento
        handler.postDelayed(periodicRunnable, delay.toLong())
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        return super.onStartCommand(intent, flags, startId)
    }

    private fun startMyOwnForeground() {
        val window = Window(this)
        mHomeWatcher.setOnHomePressedListener(object : HomeWatcher.OnHomePressedListener {
            override fun onHomePressed() {
                println("onHomePressed")
                currentAppActivityList.clear()
                if(window.isOpen()){
                    window.close()
                }
            }
            override fun onHomeLongPressed() {
                println("onHomeLongPressed")
                currentAppActivityList.clear()
                if(window.isOpen()){
                    window.close()
                }
            }
        })
        mHomeWatcher.startWatch()
        timerRun(window)
    }

    override fun onDestroy() {
        timer.cancel()
        mHomeWatcher.stopWatch()
        super.onDestroy()
    }

    private fun timerRun(window:Window){
        timer.scheduleAtFixedRate(object : TimerTask() {
            override fun run() {
                isTimerStarted = true
                isServiceRunning(window)
            }
        }, 0, timerReload)
    }


    fun isServiceRunning(window:Window) {

        val saveAppData: SharedPreferences = applicationContext.getSharedPreferences("save_app_data", Context.MODE_PRIVATE)
        val lockedAppList: List<*> = saveAppData.getString("app_data", "AppList")!!.replace("[", "").replace("]", "").split(",")

        val mUsageStatsManager = getSystemService(USAGE_STATS_SERVICE) as UsageStatsManager
        val time = System.currentTimeMillis()

        val usageEvents = mUsageStatsManager.queryEvents(time - timerReload, time)
        val event = UsageEvents.Event()

        run breaking@{
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                for (element in lockedAppList) if(event.packageName.toString().trim() == element.toString().trim()){
                    println("${event.className} $element ${event.eventType}-----------Event Type")
                        if(event.eventType == UsageEvents.Event.ACTIVITY_RESUMED && currentAppActivityList.isEmpty())  {
                            currentAppActivityList.add(event.className)
                            println("$currentAppActivityList-----List--added")
                            window.txtView!!.visibility = View.INVISIBLE
                            Handler(Looper.getMainLooper()).post {
                                window.open()
                            }
                            return@breaking
                        }else if(event.eventType == UsageEvents.Event.ACTIVITY_RESUMED){
                            if(!currentAppActivityList.contains(event.className)){
                                currentAppActivityList.add(event.className)
                                println("$currentAppActivityList-----List--added")
                            }
                        }else if(event.eventType == UsageEvents.Event.ACTIVITY_STOPPED ){
                            if(currentAppActivityList.contains(event.className)){
                                currentAppActivityList.remove(event.className)
                                println("$currentAppActivityList-----List--remained")
                            }
                        }
                }
            }
        }
    }
}

