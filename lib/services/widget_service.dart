import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

    // Register binding lifecycle observer to sync background clicks when app resumes
    WidgetsBinding.instance.addObserver(_WidgetLifecycleObserver(provider));

    // Notify native Android that MethodCallHandler is active to catch buffered intents
    _channel.invokeMethod('initWidgetService');

    // Run initial sync for any background clicks occurred while app was fully terminated
    syncPendingToggles(provider);
  }

  /// Query native Android for any background click toggles and apply them in Hive
  static Future<void> syncPendingToggles(TaskProvider provider) async {
    try {
      final List<dynamic>? pendingIds = await _channel.invokeMethod<List<dynamic>>('getPendingToggles');
      if (pendingIds != null && pendingIds.isNotEmpty) {
        for (final id in pendingIds) {
          if (id is String) {
            await provider.toggleTaskCompletion(id);
          }
        }
      }
    } catch (e) {
      debugPrint('WidgetService error syncing pending toggles: $e');
    }
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
        'streakCount': t.streakCount,
      }).toList();

      final jsonString = jsonEncode(listData);
      await _channel.invokeMethod('updateWidgetData', jsonString);
    } catch (e) {
      // Quietly log error in debug environments
      debugPrint('WidgetService error syncing tasks: $e');
    }
  }
}

/// App lifecycle observer to sync background clicks when user resumes the app
class _WidgetLifecycleObserver extends WidgetsBindingObserver {
  final TaskProvider provider;
  _WidgetLifecycleObserver(this.provider);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      WidgetService.syncPendingToggles(provider);
    }
  }
}
