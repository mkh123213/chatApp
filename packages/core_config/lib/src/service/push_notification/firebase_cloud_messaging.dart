// REUSABLE SERVICE: FCM initialization, permission handling, and topic subscription.
// REQUIRES: firebase_messaging package in pubspec.yaml
// CHANGE: Update `subscribeKey` to your project's topic name.
// CHANGE: Pass your message handlers via `init()`.
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:core_config/src/common/toast/show_toast.dart';

class FirebaseCloudMessaging {
  factory FirebaseCloudMessaging() => _instance;

  FirebaseCloudMessaging._();

  static final FirebaseCloudMessaging _instance = FirebaseCloudMessaging._();

  // CHANGE: set this to your project's FCM topic name
  static String subscribeKey = 'my_app';

  final _firebaseMessaging = FirebaseMessaging.instance;

  ValueNotifier<bool> isNotificationSubscribe = ValueNotifier(true);

  bool isPermissionNotification = false;

  // CHANGE: Pass your project's message handlers
  Future<void> init({
    required void Function(RemoteMessage) onForegroundMessage,
    required Future<void> Function(RemoteMessage?) onTerminatedMessage,
    required Future<void> Function(RemoteMessage) onBackgroundMessage,
    required void Function(RemoteMessage?) onMessageOpenedApp,
  }) async {
    await _permissionsNotification();

    FirebaseMessaging.onMessage.listen(onForegroundMessage);

    await FirebaseMessaging.instance
        .getInitialMessage()
        .then(onTerminatedMessage);

    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  // CHANGE: Pass your subscribe/unsubscribe toast messages
  Future<void> controllerForUserSubscribe(
    BuildContext context, {
    String subscribedMessage = 'Subscribed to notifications',
    String unsubscribedMessage = 'Unsubscribed from notifications',
  }) async {
    if (isPermissionNotification == false) {
      await _permissionsNotification();
    } else {
      if (isNotificationSubscribe.value == false) {
        await _subscribeNotification();
        if (!context.mounted) return;
        ShowToast.showToastSuccessTop(
          message: subscribedMessage,
          seconds: 2,
        );
      } else {
        await _unSubscribeNotification();
        if (!context.mounted) return;
        ShowToast.showToastSuccessTop(
          message: unsubscribedMessage,
          seconds: 2,
        );
      }
    }
  }

  Future<void> _permissionsNotification() async {
    final settings = await _firebaseMessaging.requestPermission(badge: false);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      isPermissionNotification = true;
      await _subscribeNotification();
      debugPrint('User accepted the notification permission');
    } else {
      isPermissionNotification = false;
      isNotificationSubscribe.value = false;
      debugPrint('User not accepted the notification permission');
    }
  }

  Future<void> _subscribeNotification() async {
    isNotificationSubscribe.value = true;
    await FirebaseMessaging.instance.subscribeToTopic(subscribeKey);
    debugPrint('Notification Subscribed');
  }

  Future<void> _unSubscribeNotification() async {
    isNotificationSubscribe.value = false;
    await FirebaseMessaging.instance.unsubscribeFromTopic(subscribeKey);
    debugPrint('Notification Unsubscribed');
  }
}
