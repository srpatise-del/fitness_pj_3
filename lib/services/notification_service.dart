import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  bool get _supported => !kIsWeb;

  Future<void> initialize() async {
    if (!_supported) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    try {
      await _plugin.initialize(settings);
    } catch (_) {}
  }

  Future<void> showPreWorkoutTip() async {
    if (!_supported) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'pre_workout_channel',
        'Pre Workout Recommendation',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    try {
      await _plugin.show(
        1001,
        'คำแนะนำก่อนออกกำลังกาย',
        'อย่าลืมวอร์มอัพ 5-10 นาที และดื่มน้ำให้เพียงพอ',
        details,
      );
    } catch (_) {}
  }

  Future<void> scheduleDailyReminder({int hour = 19, int minute = 0}) async {
    if (!_supported) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_reminder_channel',
        'Daily Reminder',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);
    var schedule = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (schedule.isBefore(now)) {
      schedule = schedule.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        1002,
        'ถึงเวลาออกกำลังกายแล้ว',
        'มาเก็บสถิติการออกกำลังกายของวันนี้กัน',
        schedule,
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }
}

