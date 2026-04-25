package com.example.streako

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
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
                val habitsText = widgetData.getString("habits_text", "STREAKO // READY")
                setTextViewText(R.id.app_widget_text, habitsText)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
