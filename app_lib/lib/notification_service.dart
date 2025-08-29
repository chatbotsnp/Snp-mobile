import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotifService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);

    // Tạo kênh Android (nếu chưa có)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'tasks_channel',
      'Tasks',
      description: 'Nhắc việc & lịch',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> showNow(int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Tasks',
      channelDescription: 'Nhắc việc & lịch',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.show(id, title, body, details);
  }

  static Future<void> schedule(
    int id,
    String title,
    String body,
    DateTime when,
  ) async {
    final scheduleTime = tz.TZDateTime.from(when, tz.local);
    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Tasks',
      channelDescription: 'Nhắc việc & lịch',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'task',
      androidAllowWhileIdle: true,
    );
  }
}
