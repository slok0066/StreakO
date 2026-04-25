import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) {
      debugPrint('NOTIF_SYSTEM: WEB_MODE // SILENT_INITIALIZATION');
      return;
    }

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        // Handle notification tap
      },
    );
    debugPrint('NOTIF_SYSTEM: MOBILE_MODE // INITIALIZED');
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
  }) async {
    if (kIsWeb) {
      debugPrint('NOTIF_SYSTEM: SCHEDULE_REQUEST // ID: $id // SILENT_ON_WEB');
      return;
    }

    final scheduledDate = tz.TZDateTime.from(time, tz.local);

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('NOTIF_SYSTEM: SCHEDULED // ID: $id // TIME: $time');
  }

  static Future<void> cancelNotification(int id) async {
    if (kIsWeb) {
      debugPrint('NOTIF_SYSTEM: CANCEL_REQUEST // ID: $id // SILENT_ON_WEB');
      return;
    }
    await _notifications.cancel(id: id);
    debugPrint('NOTIF_SYSTEM: CANCELLED // ID: $id');
  }
}
