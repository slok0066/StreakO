import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';

class DatabaseService {
  static const _boxName = 'habits';
  late Box<Habit> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HabitAdapter());
    _box = await Hive.openBox<Habit>(_boxName);
  }

  Stream<List<Habit>> listenToHabits() async* {
    // Emit immediately
    yield _box.values.toList();
    // Then yield on every change
    await for (final _ in _box.watch()) {
      yield _box.values.toList();
    }
  }

  Future<void> saveHabit(Habit habit) async {
    if (habit.id.isEmpty) {
      habit.id = const Uuid().v4();
    }
    await _box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
  }

  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    final habit = _box.get(id);
    if (habit == null) return;

    final today = DateTime(date.year, date.month, date.day);
    final dates = List<DateTime>.from(habit.completedDates);

    bool removed = false;
    for (int i = 0; i < dates.length; i++) {
      if (dates[i].year == today.year &&
          dates[i].month == today.month &&
          dates[i].day == today.day) {
        dates.removeAt(i);
        removed = true;
        break;
      }
    }
    if (!removed) dates.add(today);

    habit.completedDates = dates;
    await habit.save();
  }

  Future<void> close() async {
    await _box.close();
  }
}
