package com.streako.streako

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
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
        const val FLUTTER_SYNC_ACTION = "com.streako.streako.FLUTTER_SYNC_ACTION"
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
                // 1. Read and update the task list in SharedPreferences directly in the background
                val prefs = context.getSharedPreferences("streako_widget_prefs", Context.MODE_PRIVATE)
                val jsonString = prefs.getString("widget_tasks", "[]") ?: "[]"
                try {
                    val jsonArray = JSONArray(jsonString)
                    var updated = false
                    for (i in 0 until jsonArray.length()) {
                        val obj = jsonArray.getJSONObject(i)
                        if (obj.optString("id") == taskId) {
                            val currentStatus = obj.optBoolean("isCompleted", false)
                            obj.put("isCompleted", !currentStatus)
                            updated = true
                            break
                        }
                    }
                    if (updated) {
                        prefs.edit().putString("widget_tasks", jsonArray.toString()).apply()
                    }

                    // 2. Add this task ID to the set of pending background toggles
                    val pendingTogglesSet = prefs.getStringSet("pending_toggles", null) ?: HashSet<String>()
                    val newPending = HashSet<String>(pendingTogglesSet)
                    if (newPending.contains(taskId)) {
                        newPending.remove(taskId) // Toggle back and forth cancels out
                    } else {
                        newPending.add(taskId)
                    }
                    prefs.edit().putStringSet("pending_toggles", newPending).apply()

                    // 2.5 Send a package-restricted broadcast so that the active app (MainActivity)
                    // updates the Hive database instantly in real-time
                    val syncIntent = Intent(FLUTTER_SYNC_ACTION).apply {
                        putExtra("task_id", taskId)
                        setPackage(context.packageName)
                    }
                    context.sendBroadcast(syncIntent)

                } catch (e: Exception) {
                    e.printStackTrace()
                }

                // 3. Notify widget list view to redraw instantly on the home screen
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val componentName = ComponentName(context, StreakOWidgetProvider::class.java)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_list)
            }
        } else {
            super.onReceive(context, intent)
        }
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

        // Click intent to launch the app when tapping the widget header
        val launchIntent = Intent(context, MainActivity::class.java)
        val launchFlags = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val headerPendingIntent = PendingIntent.getActivity(context, 1, launchIntent, launchFlags)
        views.setOnClickPendingIntent(R.id.widget_header, headerPendingIntent)

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

        // Click template pending intent routing for list items
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
