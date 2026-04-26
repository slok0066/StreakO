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

                setTextViewText(R.id.widget_progress_text, String.format("%02d", progress))
                setTextViewText(R.id.widget_status, status)

                val segmentIds = intArrayOf(
                    R.id.seg_1, R.id.seg_2, R.id.seg_3, R.id.seg_4, R.id.seg_5,
                    R.id.seg_6, R.id.seg_7, R.id.seg_8, R.id.seg_9, R.id.seg_10
                )
                
                val filledSegments = progress / 10
                for (i in 0 until 10) {
                    val color = if (i < filledSegments) 0xFFFFFFFF.toInt() else 0x33FFFFFF.toInt()
                    setInt(segmentIds[i], "setBackgroundColor", color)
                }
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

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
                    val habits = org.json.JSONArray(habitsJson)
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
