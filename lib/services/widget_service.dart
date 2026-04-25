import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/habit.dart';

class WidgetService {
  static const String appGroupId = 'com.example.streako';
  static const String androidWidgetName = 'StreakOWidgetReceiver';

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
      final todayHabits = habits.where((h) => !h.isCompletedToday).toList();
      
      String widgetText = 'All done for today! 🎉';
      if (todayHabits.isNotEmpty) {
        widgetText = '${todayHabits.length} habits remaining today:\n';
        for (var i = 0; i < todayHabits.length && i < 3; i++) {
          widgetText += '${todayHabits[i].icon} ${todayHabits[i].title}\n';
        }
        if (todayHabits.length > 3) {
          widgetText += '...and ${todayHabits.length - 3} more';
        }
      }

      await HomeWidget.saveWidgetData<String>('habits_text', widgetText);
      await HomeWidget.updateWidget(
        name: androidWidgetName,
      );
      debugPrint('WIDGET_SYSTEM: DATA_SYNCED // $widgetText');
    } catch (e) {
      debugPrint('WIDGET_SYSTEM: UPDATE_ERROR // $e');
    }
  }
}
