// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Notifications extends ChangeNotifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> cancelAllNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  List<PendingNotificationRequest> notificationList = [];
  List<PendingNotificationRequest> notificationLists = [];

  Future<int> getPendingNotificationCount() async {
    notificationLists =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    if (notificationList.isNotEmpty) {
      debugPrint("görev sayın ${notificationList.length}");
      notificationList = notificationLists;
    } else {
      debugPrint("görev sayın ${notificationList.length}");
      notificationList = notificationLists;
    }
    return notificationList.length;
  }

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(String title) async {
    AndroidNotificationDetails androidPlatformChannelSpesific =
        const AndroidNotificationDetails(
      'your channel',
      'channel name',
      priority: Priority.max,
      importance: Importance.max,
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpesific,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      'inside the notification',
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleWeeklyNotification(
      int id, String body, int hour, int minute) async {
    // ignore: prefer_const_constructors
    final details = NotificationDetails(
      // ignore: prefer_const_constructors
      android: AndroidNotificationDetails(
        'id',
        'name',
        priority: Priority.max,
        playSound: true,
        importance: Importance.max,
      ),
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Hatırlatıcı',
      body,
      _netxinstanceofFryday(hour, minute),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _netxinstanceofFryday(int hour, int minute) {
    tz.TZDateTime scheduleDate = _netxinstanceofTenAM(hour, minute);
    /* while (scheduleDate.weekday != DateTime.friday) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    } */
    return scheduleDate;
  }

  tz.TZDateTime _netxinstanceofTenAM(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduleDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(seconds: 5));
    }

    return scheduleDate;
  }
}
