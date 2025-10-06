import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/event.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = IOSInitializationSettings(); // ✅ بدل DarwinInitializationSettings
    final settings = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(settings);
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification(Event e) async {
    final scheduled = e.dateTime.subtract(const Duration(minutes: 10));

    if (scheduled.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      e.id.hashCode,
      'تذكير: ${e.title}',
      e.description,
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'calendar_chan',
          'Calendar',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true, // ✅ مضاف حديثاً
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
