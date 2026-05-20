import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class TaskDatabaseService {
  static const String _boxName = 'streako_tasks';

  static final TaskDatabaseService _instance = TaskDatabaseService._internal();

  factory TaskDatabaseService() {
    return _instance;
  }

  TaskDatabaseService._internal();

  Future<void> init() async {
    try {
      await Hive.initFlutter();
      await Hive.openBox(_boxName);
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  Box get _box => Hive.box(_boxName);

  List<TaskModel> getAllTasks() {
    final List<TaskModel> tasks = [];
    try {
      for (var key in _box.keys) {
        final value = _box.get(key);
        if (value != null) {
          try {
            final Map<String, dynamic> map = Map<String, dynamic>.from(value as Map);
            tasks.add(TaskModel.fromJson(map));
          } catch (e) {
            debugPrint('Error parsing task $key: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching tasks from Hive: $e');
    }
    return tasks;
  }

  Future<void> saveTask(TaskModel task) async {
    try {
      await _box.put(task.id, task.toJson());
    } catch (e) {
      debugPrint('Error saving task ${task.id} to Hive: $e');
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _box.delete(id);
    } catch (e) {
      debugPrint('Error deleting task $id from Hive: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _box.clear();
    } catch (e) {
      debugPrint('Error clearing Hive box: $e');
    }
  }
}
