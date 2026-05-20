import '../models/task_model.dart';
import '../utils/date_utils.dart';

class StreakService {
  /// Computes the active streak count for a task.
  /// If the streak is dead because the user missed a due date, it returns 0.
  /// Otherwise, it returns the stored `streakCount`.
  static int getActiveStreak(TaskModel task) {
    if (!task.isCompleted && task.repeatType == RepeatType.none) {
      return 0;
    }
    if (task.lastCompletedDate == null) {
      return 0;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      task.lastCompletedDate!.year,
      task.lastCompletedDate!.month,
      task.lastCompletedDate!.day,
    );

    // If completed today, it's alive.
    if (AppDateUtils.isSameDay(lastCompleted, today)) {
      return task.streakCount;
    }

    // Determine the last day this task was due before today
    DateTime lastDueDay = today.subtract(const Duration(days: 1));
    if (task.repeatType == RepeatType.daily) {
      // Daily task was due yesterday. If last completed is before yesterday, streak is reset!
      if (lastCompleted.isBefore(lastDueDay)) {
        return 0;
      }
    } else if (task.repeatType == RepeatType.weekly) {
      // Weekly task was due 7 days ago. If last completed is before 7 days ago, reset!
      final sevenDaysAgo = today.subtract(const Duration(days: 7));
      if (lastCompleted.isBefore(sevenDaysAgo)) {
        return 0;
      }
    } else if (task.repeatType == RepeatType.custom) {
      if (task.customDays.isEmpty) return 0;
      // Look back day-by-day to find the last day in customDays
      bool found = false;
      for (int i = 1; i <= 14; i++) {
        final checkDay = today.subtract(Duration(days: i));
        if (task.customDays.contains(checkDay.weekday)) {
          lastDueDay = checkDay;
          found = true;
          break;
        }
      }
      if (found && lastCompleted.isBefore(lastDueDay)) {
        return 0;
      }
    }

    return task.streakCount;
  }

  /// Calculates the new streak count when a task is completed.
  static int handleCompletion(TaskModel task) {
    if (task.repeatType == RepeatType.none) {
      return 1;
    }

    if (task.lastCompletedDate == null) {
      return 1; // First completion starts the streak
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = DateTime(
      task.lastCompletedDate!.year,
      task.lastCompletedDate!.month,
      task.lastCompletedDate!.day,
    );

    // If completed today, keep current streak (avoid multiple increments in a single day)
    if (AppDateUtils.isSameDay(lastCompleted, today)) {
      return task.streakCount == 0 ? 1 : task.streakCount;
    }

    // Calculate active streak before this completion
    final activeStreak = getActiveStreak(task);

    if (activeStreak == 0) {
      // Streak was dead, starting a new one
      return 1;
    } else {
      // Streak was alive, increment it!
      return activeStreak + 1;
    }
  }

  /// Calculates the total app streak based on all active tasks.
  /// Total app streak represents the maximum of the active streaks of all tasks,
  /// or we can define it as the number of consecutive days any task was completed.
  /// Let's use the maximum active streak of repeating tasks, or the sum of active streaks.
  /// Maximum of all task streaks is a standard and engaging metric!
  static int calculateTotalAppStreak(List<TaskModel> tasks) {
    int maxStreak = 0;
    for (var task in tasks) {
      final active = getActiveStreak(task);
      if (active > maxStreak) {
        maxStreak = active;
      }
    }
    return maxStreak;
  }
}
