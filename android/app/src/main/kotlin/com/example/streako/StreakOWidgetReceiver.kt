package com.example.streako

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StreakOWidgetReceiver : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.streak_o_widget).apply {
                val progress = widgetData.getInt("progress_percentage", 0)
                val status = widgetData.getString("status_text", "AWAITING_SYNC")

                setTextViewText(R.id.widget_progress_text, "$progress%")
                setTextViewText(R.id.widget_status, status)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
