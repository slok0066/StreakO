package com.streako.streako

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray
import com.streako.streako.R

class StreakOWidgetProvider : AppWidgetProvider() {

    companion object {
        const val TOGGLE_ACTION = "com.streako.streako.TOGGLE_ACTION"
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
        super.onUpdate(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == TOGGLE_ACTION) {
            val taskId = intent.getStringExtra("task_id")
            if (taskId != null) {
                // Route task toggle action to MainActivity
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                    putExtra("action", "toggle_task")
                    putExtra("task_id", taskId)
                }
                context.startActivity(launchIntent)
            }
        }
        super.onReceive(context, intent)
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        val views = RemoteViews(context.packageName, R.layout.widget_layout)

        // Setup list remote service adapter
        val intent = Intent(context, StreakOWidgetService::class.java).apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
        }
        views.setRemoteAdapter(R.id.widget_list, intent)
        views.setEmptyView(R.id.widget_list, R.id.widget_empty)

        // Read preferences to toggle empty view state correctly
        val prefs = context.getSharedPreferences("streako_widget_prefs", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("widget_tasks", "[]") ?: "[]"
        try {
            val jsonArray = JSONArray(jsonString)
            if (jsonArray.length() == 0) {
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                views.setViewVisibility(R.id.widget_list, View.GONE)
            } else {
                views.setViewVisibility(R.id.widget_empty, View.GONE)
                views.setViewVisibility(R.id.widget_list, View.VISIBLE)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // Click template pending intent routing
        val clickIntent = Intent(context, StreakOWidgetProvider::class.java).apply {
            action = TOGGLE_ACTION
        }
        val flags = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val clickPendingIntent = PendingIntent.getBroadcast(context, 0, clickIntent, flags)
        views.setPendingIntentTemplate(R.id.widget_list, clickPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
        appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list)
    }
}
