// REUSABLE SERVICE: Local notification display wrapper.
// REQUIRES: flutter_local_notifications package in pubspec.yaml
// CHANGE: Update the channel ID ('chat-notifications') and name to match your project.
// CHANGE: Update the `onTap` handler to your project's navigation logic.
// CHANGE: Update '@mipmap/ic_launcher' if your app icon name differs.
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chat_material3/core/service/push_notification/firebase_messaging_navigate.dart'; // CHANGE: your nav handler

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: onTap,
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();

      const channel = AndroidNotificationChannel(
        'chat-notifications',
        'Chat Notifications',
        importance: Importance.max,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  static void onTap(NotificationResponse notificationResponse) {
    FirebaseMessagingNavigate.handleNotificationTap(
      notificationResponse.payload,
    );
  }

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'chat-notifications',
        'Chat Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await flutterLocalNotificationsPlugin.show(
      id: Random().nextInt(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }
}
