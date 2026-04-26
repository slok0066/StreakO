package com.example.streako

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class StreakOListWidgetReceiver : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.streak_o_list_widget).apply {
                val habitsJson = widgetData.getString("pending_habits_json", "[]")
                try {
                    val habits = JSONArray(habitsJson)
                    val titleIds = intArrayOf(R.id.habit_title_1, R.id.habit_title_2)

                    for (i in 0 until 2) {
                        if (i < habits.length()) {
                            val habit = habits.getJSONObject(i)
                            setTextViewText(titleIds[i], habit.getString("title"))
                        } else {
                            setTextViewText(titleIds[i], "---")
                        }
                    }
                } catch (e: Exception) {
                    // Silent fail
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
