package com.example.my_calendar_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.preference.PreferenceManager

class TodayWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefs = PreferenceManager.getDefaultSharedPreferences(context)
        val count = prefs.getInt("today_count", 0)
        val summary = prefs.getString("today_summary", "") ?: ""

        val componentName = ComponentName(context, TodayWidgetProvider::class.java)
        val remoteViews = RemoteViews(context.packageName, R.layout.widget_today)
        remoteViews.setTextViewText(R.id.widget_date, java.text.SimpleDateFormat("yyyy-MM-dd").format(java.util.Date()))
        remoteViews.setTextViewText(R.id.widget_count, "Events today: $count")
        remoteViews.setTextViewText(R.id.widget_summary, summary)

        appWidgetManager.updateAppWidget(componentName, remoteViews)
    }
}
