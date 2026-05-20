import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../utils/date_utils.dart';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('streako/widget');
  static bool _initialized = false;

  /// Setup dynamic MethodCall listeners to execute widget checkbox clicks
  static void initialize(TaskProvider provider) {
    if (_initialized) return;
    _initialized = true;

    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'widgetToggleTask':
          final taskId = call.arguments as String;
          await provider.toggleTaskCompletion(taskId);
          break;
        default:
          break;
      }
    });

    // Notify native Android that MethodCallHandler is active to catch buffered intents
    _channel.invokeMethod('initWidgetService');
  }

  /// Serialize and sync today's tasks lists with the native Android SharedPreferences
  static Future<void> updateWidgetTasks(List<TaskModel> allTasks) async {
    try {
      final now = DateTime.now();
      // Filter tasks due or created today (matches exact TODAY tab rules)
      final todayTasks = allTasks.where((t) {
        final isDue = AppDateUtils.isTaskDueOnDay(now, t.repeatType.name, t.customDays);
        final isCreatedToday = AppDateUtils.isToday(t.createdDate);
        return isDue || isCreatedToday;
      }).toList();

      final listData = todayTasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'isCompleted': t.isCompleted,
      }).toList();

      final jsonString = jsonEncode(listData);
      await _channel.invokeMethod('updateWidgetData', jsonString);
    } catch (e) {
      // Quietly log error in debug environments
      debugPrint('WidgetService error syncing tasks: $e');
    }
  }
}
