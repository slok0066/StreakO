package com.streako.streako

import android.content.Context
import android.content.Intent
import android.text.Html
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONException
import com.streako.streako.R

class StreakOWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return StreakOWidgetFactory(this.applicationContext)
    }
}

class StreakOWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var tasksList = ArrayList<WidgetTask>()

    data class WidgetTask(val id: String, val title: String, val isCompleted: Boolean, val streakCount: Int)

    override fun onCreate() {
        loadData()
    }

    override fun onDataSetChanged() {
        loadData()
    }

    override fun onDestroy() {
        tasksList.clear()
    }

    override fun getCount(): Int {
        return tasksList.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_item)
        if (position >= tasksList.size) return views

        val task = tasksList[position]
        
        // Bind HTML-formatted title with strikethrough for completed tasks
        val formattedTitle = if (task.isCompleted) {
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
                Html.fromHtml("<s>${task.title}</s>", Html.FROM_HTML_MODE_LEGACY)
            } else {
                @Suppress("DEPRECATION")
                Html.fromHtml("<s>${task.title}</s>")
            }
        } else {
            task.title
        }
        views.setTextViewText(R.id.widget_item_title, formattedTitle)
        
        // Bind custom XML checkbox drawables
        if (task.isCompleted) {
            views.setImageViewResource(R.id.widget_item_checkbox, R.drawable.widget_checkbox_checked)
            views.setTextColor(R.id.widget_item_title, android.graphics.Color.parseColor("#666666")) // Strikeout Grey
        } else {
            views.setImageViewResource(R.id.widget_item_checkbox, R.drawable.widget_checkbox_unchecked)
            views.setTextColor(R.id.widget_item_title, android.graphics.Color.parseColor("#E8E8E8")) // Solid Display White
        }

        // Bind Streak Badge
        if (task.streakCount > 0) {
            views.setViewVisibility(R.id.widget_item_streak, View.VISIBLE)
            views.setTextViewText(R.id.widget_item_streak, "⚡ ${task.streakCount}")
            if (task.isCompleted) {
                views.setTextColor(R.id.widget_item_streak, android.graphics.Color.parseColor("#555555")) // Strikeout Grey
            } else {
                views.setTextColor(R.id.widget_item_streak, android.graphics.Color.parseColor("#E57C23")) // Flame color
            }
        } else {
            views.setViewVisibility(R.id.widget_item_streak, View.GONE)
        }

        // Attach click fill-in intent to the entire list item row container
        val fillIntent = Intent().apply {
            putExtra("task_id", task.id)
            putExtra("action", "toggle_task")
        }
        views.setOnClickFillInIntent(R.id.widget_item_root, fillIntent)

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }

    private fun loadData() {
        tasksList.clear()
        val prefs = context.getSharedPreferences("streako_widget_prefs", Context.MODE_PRIVATE)
        val jsonString = prefs.getString("widget_tasks", "[]") ?: "[]"
        try {
            val jsonArray = JSONArray(jsonString)
            for (i in 0 until jsonArray.length()) {
                val obj = jsonArray.getJSONObject(i)
                val id = obj.optString("id", "")
                val title = obj.optString("title", "")
                val isCompleted = obj.optBoolean("isCompleted", false)
                val streakCount = obj.optInt("streakCount", 0)
                if (id.isNotEmpty()) {
                    tasksList.add(WidgetTask(id, title, isCompleted, streakCount))
                }
            }
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }
}
