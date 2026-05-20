// REUSABLE SERVICE: Local notification display wrapper.
// REQUIRES: flutter_local_notifications package in pubspec.yaml
// CHANGE: Update the channel ID ('app-notifications') and name to match your project.
// CHANGE: Pass your own `onTap` handler to `init()`.
// CHANGE: Update '@mipmap/ic_launcher' if your app icon name differs.
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // CHANGE: Pass your notification tap handler
  static Future<void> init({
    required void Function(NotificationResponse) onTap,
    String androidIcon = '@mipmap/ic_launcher',
    String channelId = 'app-notifications',
    String channelName = 'App Notifications',
  }) async {
    final settings = InitializationSettings(
      android: AndroidInitializationSettings(androidIcon),
      iOS: const DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      final channel = AndroidNotificationChannel(
        channelId,
        channelName,
        importance: Importance.max,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
    String channelId = 'app-notifications',
    String channelName = 'App Notifications',
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      Random().nextInt(100000),
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
