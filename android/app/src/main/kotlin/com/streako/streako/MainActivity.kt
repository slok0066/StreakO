package com.streako.streako

import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.streako.streako.R

class MainActivity : FlutterActivity() {
    private val CHANNEL = "streako/widget"
    private var methodChannel: MethodChannel? = null
    private var pendingTaskIdToToggle: String? = null

    // BroadcastReceiver to capture toggles while the app is active in the background or foreground
    private val widgetToggleReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent != null && intent.action == StreakOWidgetProvider.TOGGLE_ACTION) {
                val taskId = intent.getStringExtra("task_id")
                if (taskId != null) {
                    methodChannel?.invokeMethod("widgetToggleTask", taskId)
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)

        // Register the real-time background sync receiver
        val filter = IntentFilter(StreakOWidgetProvider.TOGGLE_ACTION)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(widgetToggleReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(widgetToggleReceiver, filter)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(widgetToggleReceiver)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun handleIntent(intent: Intent?) {
        if (intent != null && intent.getStringExtra("action") == "toggle_task") {
            val taskId = intent.getStringExtra("task_id")
            if (taskId != null) {
                pendingTaskIdToToggle = taskId
                sendPendingToggleToFlutter()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidgetData" -> {
                    val jsonString = call.arguments as? String ?: "[]"
                    updateSharedPrefsAndWidget(jsonString)
                    result.success(true)
                }
                "initWidgetService" -> {
                    // Flutter MethodChannel listener is ready, dispatch any pending tasks
                    sendPendingToggleToFlutter()
                    result.success(true)
                }
                "getPendingToggles" -> {
                    val prefs = getSharedPreferences("streako_widget_prefs", Context.MODE_PRIVATE)
                    val pendingTogglesSet = prefs.getStringSet("pending_toggles", null)
                    val toggleList = pendingTogglesSet?.toList() ?: emptyList<String>()
                    
                    // Clear pending toggles now that Flutter is consuming them
                    prefs.edit().remove("pending_toggles").apply()
                    
                    result.success(toggleList)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updateSharedPrefsAndWidget(jsonString: String) {
        val prefs = getSharedPreferences("streako_widget_prefs", Context.MODE_PRIVATE)
        prefs.edit().putString("widget_tasks", jsonString).apply()

        // Notify app widgets that the list data factory changed
        val appWidgetManager = AppWidgetManager.getInstance(this)
        val componentName = ComponentName(this, StreakOWidgetProvider::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)

        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_list)

        // Trigger onUpdate broadcast to refresh background/text configurations
        val updateIntent = Intent(this, StreakOWidgetProvider::class.java).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
        }
        sendBroadcast(updateIntent)
    }

    private fun sendPendingToggleToFlutter() {
        val taskId = pendingTaskIdToToggle ?: return
        val channel = methodChannel ?: return
        channel.invokeMethod("widgetToggleTask", taskId)
        pendingTaskIdToToggle = null
    }
}
