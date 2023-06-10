import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

class Notifications{
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


  initialize() async{
    final status = await Permission.notification.request();

    var androidInit = const AndroidInitializationSettings('mipmap/ic_launcher');
    var initSettings = InitializationSettings(android: androidInit);

    await flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'channelId',
            'channelName',
            importance: Importance.max
        ),
    );
  }

  scheduleNotification({int id = 0, required String title,required String body, required DateTime date}) async{

    return flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      timezone.TZDateTime.from(date, timezone.local),
      await notificationDetails(),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}