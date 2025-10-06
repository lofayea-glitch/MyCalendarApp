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
    final ios = DarwinInitializationSettings();
    await _plugin.initialize(NotificationSettings(android: android, iOS: ios));
    tz.initializeTimeZones();
  }

  Future<void> scheduleNotification(Event e) async {
    final scheduled = e.dateTime.subtract(Duration(minutes: 10));
    if (scheduled.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      e.id.hashCode,
      'تذكير: ${e.title}',
      e.description,
      tz.TZDateTime.from(scheduled, tz.local),
      const NotificationDetails(android: AndroidNotificationDetails('calendar_chan', 'Calendar', importance: Importance.high)),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
