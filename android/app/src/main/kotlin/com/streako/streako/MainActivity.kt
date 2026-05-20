package com.streako.streako

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.streako.streako.R

class MainActivity : FlutterActivity() {
    private val CHANNEL = "streako/widget"
    private var methodChannel: MethodChannel? = null
    private var pendingTaskIdToToggle: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
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
