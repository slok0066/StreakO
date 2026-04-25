import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  throw UnimplementedError('databaseProvider must be overridden');
});

final habitStreamProvider = StreamProvider<List<Habit>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.listenToHabits();
});

class HabitNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> addHabit(Habit habit) async {
    state = const AsyncLoading();
    try {
      await ref.read(databaseProvider).saveHabit(habit);

      if (habit.reminderTime != null) {
        await NotificationService.scheduleDailyNotification(
          id: habit.id.hashCode,
          title: 'Time for ${habit.title}',
          body: habit.description ?? 'Keep up your streak!',
          time: habit.reminderTime!,
        );
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateHabit(Habit habit) async {
    state = const AsyncLoading();
    try {
      await ref.read(databaseProvider).saveHabit(habit);
      
      // Update notification
      if (habit.reminderTime != null) {
        await NotificationService.scheduleDailyNotification(
          id: habit.id.hashCode,
          title: 'Time for ${habit.title}',
          body: habit.description ?? 'Keep up your streak!',
          time: habit.reminderTime!,
        );
      } else {
        await NotificationService.cancelNotification(habit.id.hashCode);
      }
      
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    try {
      await ref.read(databaseProvider).toggleHabitCompletion(id, date);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteHabit(Habit habit) async {
    state = const AsyncLoading();
    try {
      await ref.read(databaseProvider).deleteHabit(habit.id);
      if (habit.reminderTime != null) {
        await NotificationService.cancelNotification(habit.id.hashCode);
      }
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final habitProvider =
    NotifierProvider<HabitNotifier, AsyncValue<void>>(HabitNotifier.new);
