import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  late String icon;

  @HiveField(4)
  late int colorValue;

  @HiveField(5)
  DateTime? reminderTime;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  List<DateTime> completedDates = [];

  /// Current streak count
  int get streak {
    if (completedDates.isEmpty) return 0;

    final sorted = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));

    final today = _dayOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    final hasToday = sorted.any((d) => _isSameDay(d, today));
    final hasYesterday = sorted.any((d) => _isSameDay(d, yesterday));

    if (!hasToday && !hasYesterday) return 0;

    DateTime checkDate = hasToday ? today : yesterday;
    int count = 0;

    for (final date in sorted) {
      if (_isSameDay(date, checkDate)) {
        count++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }

    return count;
  }

  /// Whether this habit has been completed today
  bool get isCompletedToday {
    if (completedDates.isEmpty) return false;
    return completedDates.any((d) => _isSameDay(d, DateTime.now()));
  }

  DateTime _dayOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
