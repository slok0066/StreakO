import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/task_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Stream controller to handle notification clicks and navigate to detail screens
  final StreamController<String> _onNotificationTap = StreamController<String>.broadcast();
  Stream<String> get onNotificationTap => _onNotificationTap.stream;

  Future<void> init() async {
    // 1. Initialize timezone database
    tz.initializeTimeZones();
    try {
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Dynamic local timezone configured: $timeZoneName');
    } catch (e) {
      debugPrint('Error setting dynamic local timezone, falling back to UTC: $e');
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (err) {
        debugPrint('Error setting UTC timezone location: $err');
      }
    }

    // 2. Configure Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Configure iOS settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // 4. Initialize the plugin
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _onNotificationTap.add(payload);
        }
      },
    );

    // Create default channel for Android
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'streako_reminders_channel',
      'streakO Reminders',
      description: 'Channel for streakO task reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> requestPermissions() async {
    // Request permission for Android (Android 13+ / API 33+)
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    bool androidGranted = false;
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      androidGranted = granted ?? false;

      // Request exact alarm permission on Android 13+ to ensure precise alarm scheduling
      try {
        final exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
        debugPrint('Exact alarm permission status: $exactAlarmGranted');
      } catch (e) {
        debugPrint('Error requesting exact alarm permission: $e');
      }
    }

    // Request permission for iOS
    final iosImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    bool iosGranted = false;
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      iosGranted = granted ?? false;
    }

    return androidGranted || iosGranted;
  }

  Future<bool> checkPermissionStatus() async {
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // Default true on other platforms
  }

  /// Hashes String ID to get a unique int ID for notification scheduling
  int _getNotificationId(String taskId) {
    return taskId.hashCode.abs() & 0x7FFFFFFF;
  }

  /// Schedules a reminder based on the task parameters
  Future<void> scheduleTaskReminder(TaskModel task) async {
    if (!task.reminderEnabled) {
      await cancelTaskReminder(task.id);
      return;
    }

    final id = _getNotificationId(task.id);
    const androidDetails = AndroidNotificationDetails(
      'streako_reminders_channel',
      'streakO Reminders',
      channelDescription: 'Channel for streakO task reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (task.reminderType == ReminderType.fixed && task.reminderTime != null) {
      // Schedule daily/weekly repeating reminder at a specific time
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        task.reminderTime!.hour,
        task.reminderTime!.minute,
      );

      // If scheduled time is in the past, schedule for tomorrow
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Using zonedSchedule for precise notification scheduling
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'streakO Reminder: ${task.title}',
        body: task.description.isNotEmpty ? task.description : 'Keep your streak alive!',
        scheduledDate: tzScheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeats daily at this time
        payload: task.id,
      );
      debugPrint('Scheduled fixed-time notification for task ${task.id} at ${task.reminderTime}');
    } else if (task.reminderType == ReminderType.interval && task.intervalHours != null) {
      // Schedule interval-based reminder (e.g. hourly, every 2 hours, etc.)
      RepeatInterval interval;
      switch (task.intervalHours) {
        case 1:
          interval = RepeatInterval.hourly;
          break;
        case 2:
          // Local notifications periodicallyShow supports only hourly, daily, weekly, or everyMinute.
          // For custom intervals, we fall back to hourly, or schedule a series of fixed-time reminders.
          // To ensure simplicity and 100% reliability, we map 1 hour to hourly. For others, we also show hourly
          // or use RepeatInterval.hourly. Let's make it hourly for interval.
          interval = RepeatInterval.hourly;
          break;
        default:
          interval = RepeatInterval.hourly;
          break;
      }

      await _notificationsPlugin.periodicallyShow(
        id: id,
        title: 'streakO Check-in: ${task.title}',
        body: task.description.isNotEmpty ? task.description : 'Track your progress now!',
        repeatInterval: interval,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: task.id,
      );
      debugPrint('Scheduled interval notification for task ${task.id} every selected interval.');
    }
  }

  /// Cancels an active reminder
  Future<void> cancelTaskReminder(String taskId) async {
    final id = _getNotificationId(taskId);
    await _notificationsPlugin.cancel(id: id);
    debugPrint('Canceled notification for task $taskId');
  }

  /// Cancels all scheduled reminders
  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('Canceled all notification reminders');
  }
}
