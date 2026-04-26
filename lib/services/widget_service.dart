import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/habit.dart';

class WidgetService {
  static const String appGroupId = 'com.example.streako';
  static const String androidWidgetName = 'StreakOWidgetReceiver';
  static const String androidListWidgetName = 'StreakOListWidgetReceiver';

  static Future<void> init() async {
    if (kIsWeb) {
      debugPrint('WIDGET_SYSTEM: WEB_MODE // SILENT_INITIALIZATION');
      return;
    }
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      debugPrint('WIDGET_SYSTEM: MOBILE_MODE // INITIALIZED');
    } catch (e) {
      debugPrint('WIDGET_SYSTEM: ERROR // $e');
    }
  }

  static Future<void> updateWidgetData(List<Habit> habits) async {
    if (kIsWeb) {
      debugPrint('WIDGET_SYSTEM: UPDATE_REQUEST // SYNCING_DATA_FOR_WEB');
      return;
    }
    try {
      final completedCount = habits.where((h) => h.isCompletedToday).length;
      final totalCount = habits.length;
      final progress = totalCount > 0 ? (completedCount / totalCount) : 0.0;
      final progressPercentage = (progress * 100).toInt();

      final pendingHabits = habits.where((h) => !h.isCompletedToday).toList();
      
      // Data for Main Progress Widget
      await HomeWidget.saveWidgetData<int>('progress_percentage', progressPercentage);
      await HomeWidget.saveWidgetData<String>('status_text', 
        totalCount == 0 ? 'AWAITING_INPUT' : 
        completedCount == totalCount ? 'OPTIMAL_STATE' : 
        '$completedCount OF $totalCount SYNCED');

      // Data for List Widget
      final habitsJson = pendingHabits.take(3).map((h) => {
        'title': h.title.toUpperCase(),
        'icon': h.icon,
      }).toList();
      await HomeWidget.saveWidgetData<String>('pending_habits_json', jsonEncode(habitsJson));

      // Trigger updates
      await HomeWidget.updateWidget(name: androidWidgetName);
      await HomeWidget.updateWidget(name: androidListWidgetName);

      debugPrint('WIDGET_SYSTEM: DATA_SYNCED // PROGRESS: $progressPercentage%');
    } catch (e) {
      debugPrint('WIDGET_SYSTEM: UPDATE_ERROR // $e');
    }
  }
}
