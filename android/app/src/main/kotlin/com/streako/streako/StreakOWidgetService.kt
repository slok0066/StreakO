package com.streako.streako

import android.content.Context
import android.content.Intent
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

    data class WidgetTask(val id: String, val title: String, val isCompleted: Boolean)

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
        
        // Bind title
        views.setTextViewText(R.id.widget_item_title, task.title)
        
        // Bind Nothing dot-style checkbox status
        if (task.isCompleted) {
            views.setTextViewText(R.id.widget_item_checkbox, "●")
            views.setTextColor(R.id.widget_item_checkbox, android.graphics.Color.parseColor("#4A9E5C")) // Accent Success Green
            views.setTextColor(R.id.widget_item_title, android.graphics.Color.parseColor("#666666")) // Strikeout Color
        } else {
            views.setTextViewText(R.id.widget_item_checkbox, "○")
            views.setTextColor(R.id.widget_item_checkbox, android.graphics.Color.parseColor("#333333")) // Medium Boundary Gray
            views.setTextColor(R.id.widget_item_title, android.graphics.Color.parseColor("#E8E8E8")) // Solid Display White
        }

        // Attach click fill-in intent
        val fillIntent = Intent().apply {
            putExtra("task_id", task.id)
            putExtra("action", "toggle_task")
        }
        views.setOnClickFillInIntent(R.id.widget_item_checkbox, fillIntent)
        views.setOnClickFillInIntent(R.id.widget_item_title, fillIntent)

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
                if (id.isNotEmpty()) {
                    tasksList.add(WidgetTask(id, title, isCompleted))
                }
            }
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }
}
