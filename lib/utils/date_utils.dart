import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppDateUtils {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  static bool isYesterday(DateTime date) {
    return isSameDay(date, DateTime.now().subtract(const Duration(days: 1)));
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date).toUpperCase();
  }

  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt).toUpperCase();
  }

  static String getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'MON';
      case 2:
        return 'TUE';
      case 3:
        return 'WED';
      case 4:
        return 'THU';
      case 5:
        return 'FRI';
      case 6:
        return 'SAT';
      case 7:
        return 'SUN';
      default:
        return '';
    }
  }

  static bool isTaskDueOnDay(DateTime date, String repeatType, List<int> customDays) {
    if (repeatType == 'none') {
      return true; // Single-use tasks are always visible on the day they're created/due
    } else if (repeatType == 'daily') {
      return true;
    } else if (repeatType == 'weekly') {
      // By default, weekly means same day of the week
      return true; // We'll simplify or match weekday if customDays isn't used
    } else if (repeatType == 'custom') {
      return customDays.contains(date.weekday);
    }
    return false;
  }
}
