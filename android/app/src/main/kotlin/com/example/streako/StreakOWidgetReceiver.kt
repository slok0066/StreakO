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
