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
                    val iconIds = intArrayOf(R.id.habit_icon_1, R.id.habit_icon_2, R.id.habit_icon_3)
                    val titleIds = intArrayOf(R.id.habit_title_1, R.id.habit_title_2, R.id.habit_title_3)
                    val itemIds = intArrayOf(R.id.habit_item_1, R.id.habit_item_2, R.id.habit_item_3)

                    for (i in 0 until 3) {
                        if (i < habits.length()) {
                            val habit = habits.getJSONObject(i)
                            setTextViewText(iconIds[i], habit.getString("icon"))
                            setTextViewText(titleIds[i], habit.getString("title"))
                            setViewVisibility(itemIds[i], View.VISIBLE)
                        } else {
                            setViewVisibility(itemIds[i], View.GONE)
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
