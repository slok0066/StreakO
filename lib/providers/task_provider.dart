import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_database_service.dart';
import '../services/notification_service.dart';
import '../services/streak_service.dart';
import '../utils/date_utils.dart';
import '../services/widget_service.dart';

enum TaskFilter { all, pending, completed, today, high }

class TaskProvider extends ChangeNotifier {
  final TaskDatabaseService _db = TaskDatabaseService();
  final NotificationService _notifications = NotificationService();

  List<TaskModel> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  ThemeMode _themeMode = ThemeMode.dark; // Default to Dark mode (OLED Nothing vibe)
  bool _notificationPermissionGranted = false;

  List<TaskModel> get tasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  ThemeMode get themeMode => _themeMode;
  bool get notificationPermissionGranted => _notificationPermissionGranted;

  TaskProvider() {
    _init();
  }

  Future<void> _init() async {
    await _db.init();
    await _notifications.init();
    _loadTasks();
    _checkPermissions();
    // Initialize widget service after tasks are fully loaded to avoid startup race conditions
    WidgetService.initialize(this);
  }

  void _loadTasks() {
    _tasks = _db.getAllTasks();
    notifyListeners();
  }

  void refreshTasks() {
    _loadTasks();
  }

  Future<void> _checkPermissions() async {
    _notificationPermissionGranted = await _notifications.checkPermissionStatus();
    notifyListeners();
  }

  Future<void> requestNotificationPermission() async {
    _notificationPermissionGranted = await _notifications.requestPermissions();
    notifyListeners();
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Get tasks filtered by selected filter tab
  List<TaskModel> get filteredTasks {
    final now = DateTime.now();
    switch (_currentFilter) {
      case TaskFilter.pending:
        return _tasks.where((t) => !t.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((t) => t.isCompleted).toList();
      case TaskFilter.today:
        // Due today, or created today, or repeating today
        return _tasks.where((t) {
          final isDue = AppDateUtils.isTaskDueOnDay(now, t.repeatType.name, t.customDays);
          final isCreatedToday = AppDateUtils.isToday(t.createdDate);
          return isDue || isCreatedToday;
        }).toList();
      case TaskFilter.high:
        return _tasks.where((t) => t.priority == PriorityLevel.high).toList();
      case TaskFilter.all:
        return _tasks;
    }
  }

  // Dashboard Stats
  int get totalCompletedToday {
    return _tasks
        .where((t) =>
            t.isCompleted &&
            t.lastCompletedDate != null &&
            AppDateUtils.isToday(t.lastCompletedDate!))
        .length;
  }

  int get pendingCount {
    return _tasks.where((t) => !t.isCompleted).length;
  }

  int get totalAppStreak {
    return StreakService.calculateTotalAppStreak(_tasks);
  }

  // Add Task
  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
    await _db.saveTask(task);
    if (task.reminderEnabled) {
      await _notifications.scheduleTaskReminder(task);
    }
    notifyListeners();
  }

  // Edit Task
  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      // Cancel old reminder just in case
      await _notifications.cancelTaskReminder(updatedTask.id);

      _tasks[index] = updatedTask;
      await _db.saveTask(updatedTask);

      // Re-schedule reminder if enabled
      if (updatedTask.reminderEnabled) {
        await _notifications.scheduleTaskReminder(updatedTask);
      }
      notifyListeners();
    }
  }

  // Delete Task
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _db.deleteTask(id);
    await _notifications.cancelTaskReminder(id);
    notifyListeners();
  }

  // Mark Completed / Checkbox toggle
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      if (!task.isCompleted) {
        // Mark complete
        final now = DateTime.now();
        final updatedHistory = List<DateTime>.from(task.completionHistory)..add(now);
        final newStreak = StreakService.handleCompletion(task);

        final updatedTask = task.copyWith(
          isCompleted: true,
          streakCount: newStreak,
          lastCompletedDate: now,
          completionHistory: updatedHistory,
          updatedDate: now,
        );

        _tasks[index] = updatedTask;
        await _db.saveTask(updatedTask);
      } else {
        // Undo completion
        final now = DateTime.now();
        final updatedHistory = List<DateTime>.from(task.completionHistory);
        
        // Remove today's completion dates if present
        updatedHistory.removeWhere((d) => AppDateUtils.isToday(d));

        final previousStreak = task.streakCount > 0 ? task.streakCount - 1 : 0;
        final lastCompleted = updatedHistory.isNotEmpty ? updatedHistory.last : null;

        final updatedTask = task.copyWith(
          isCompleted: false,
          streakCount: previousStreak,
          lastCompletedDate: lastCompleted,
          completionHistory: updatedHistory,
          updatedDate: now,
        );

        _tasks[index] = updatedTask;
        await _db.saveTask(updatedTask);
      }
      notifyListeners();
    }
  }

  // Clear completed tasks
  Future<void> clearCompletedTasks() async {
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();
    for (var task in completedTasks) {
      await _db.deleteTask(task.id);
      await _notifications.cancelTaskReminder(task.id);
    }
    _tasks.removeWhere((t) => t.isCompleted);
    notifyListeners();
  }

  // Reset all streaks
  Future<void> resetAllStreaks() async {
    for (int i = 0; i < _tasks.length; i++) {
      final updatedTask = _tasks[i].copyWith(
        streakCount: 0,
        lastCompletedDate: null,
        completionHistory: [],
      );
      _tasks[i] = updatedTask;
      await _db.saveTask(updatedTask);
    }
    notifyListeners();
  }

  // Get task by ID
  TaskModel? getTaskById(String id) {
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
    WidgetService.updateWidgetTasks(_tasks);
  }
}
