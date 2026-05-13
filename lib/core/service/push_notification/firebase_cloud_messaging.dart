import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:chat_material3/core/app/env.variables.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/service/push_notification/firebase_messaging_navigate.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseMessagingNavigate.backGroundHandler(message);
}

class FirebaseCloudMessaging {
  factory FirebaseCloudMessaging() => _instance;

  FirebaseCloudMessaging._();

  static final FirebaseCloudMessaging _instance = FirebaseCloudMessaging._();

  static const String subscribeKey = 'chat_material3';

  final _firebaseMessaging = FirebaseMessaging.instance;

  ValueNotifier<bool> isNotificationSubscribe = ValueNotifier(true);

  bool isPermissionNotification = false;

  Future<void> init() async {
    //permission
    await _permissionsNotification();

    // forground
    FirebaseMessaging.onMessage.listen(
      FirebaseMessagingNavigate.forGroundHandler,
    );

    // terminated
    await FirebaseMessaging.instance.getInitialMessage().then(
          FirebaseMessagingNavigate.terminatedHandler,
        );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    // background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      FirebaseMessagingNavigate.backGroundHandler(message);
    });
  }

  /// controller for the notification if user subscribe or unsubscribed
  /// or accpeted the permission or not

  Future<void> controllerForUserSubscribe(BuildContext context) async {
    if (isPermissionNotification == false) {
      await _permissionsNotification();
      print("isPermissionNotification = $isPermissionNotification");
    } else {
      print("isPermissionNotification = $isPermissionNotification");

      if (isNotificationSubscribe.value == false) {
        await _subscribeNotification();
        if (!context.mounted) return;
        ShowToast.showToastSuccessTop(
          message: context.translate(LangKeys.subscribedToNotifications),
          seconds: 2,
        );
      } else {
        await _unSubscribeNotification();
        if (!context.mounted) return;
        ShowToast.showToastSuccessTop(
          message: context.translate(LangKeys.unsubscribedToNotifications),
          seconds: 2,
        );
      }
    }
  }

  /// permissions to notifications
  Future<void> _permissionsNotification() async {
    final settings = await _firebaseMessaging.requestPermission(badge: false);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      /// subscribe to notifications topic
      isPermissionNotification = true;
      await _subscribeNotification();
      debugPrint('🔔🔔 User accepted the notification permission');
    } else {
      isPermissionNotification = false;
      isNotificationSubscribe.value = false;
      debugPrint('🔕🔕 User not accepted the notification permission');
    }
  }

  /// subscribe notification

  Future<void> _subscribeNotification() async {
    isNotificationSubscribe.value = true;
    await FirebaseMessaging.instance.subscribeToTopic(subscribeKey);
    debugPrint('====🔔 Notification Subscribed 🔔=====');
  }

  /// unsubscribe notification

  Future<void> _unSubscribeNotification() async {
    isNotificationSubscribe.value = false;
    await FirebaseMessaging.instance.unsubscribeFromTopic(subscribeKey);
    debugPrint('====🔕 Notification Unsubscribed 🔕=====');
  }

  // get access token
  Future<String> getAccessToken() async {
    try {
      // Load the service account credentials JSON file
      final jsonString = await rootBundle.loadString(
        'assets/store-app-c9001-fa3b97881677.json',
      );

      // Parse the service account credentials
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(
        jsonString,
      );

      // Define the required scope for Cloud Messaging (or use cloud-platform)
      final scopes = ['https://www.googleapis.com/auth/cloud-platform'];

      // Create an authenticated client
      final client = await auth.clientViaServiceAccount(
        accountCredentials,
        scopes,
      );

      // Return the access token
      return client.credentials.accessToken.data;
    } catch (e) {
      // Handle errors here
      throw Exception("Failed to get access token: $e");
    }
  }
  // send topicnotifcation with api

  Future<void> sendTopicNotification({
    required String title,
    required String body,
    required int productId,
    required Map<String, String> data,
  }) async {
    try {
      final accessToken = await getAccessToken();
      final response = await Dio().post<dynamic>(
        EnvVariable.instance.notifcationBaseUrl,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        data: {
          'message': {
            'token': '/topics/$subscribeKey',
            'notification': {'title': title, 'body': body},
            'data': data, // Add custom data here

            'android': {
              'notification': {
                "sound": "custom_sound",
                'click_action':
                    'FLUTTER_NOTIFICATION_CLICK', // Required for tapping to trigger response
                'channel_id': 'high_importance_channel',
              },
            },
            'apns': {
              'payload': {
                'aps': {"sound": "custom_sound.caf", 'content-available': 1},
              },
            },
          },
        },
      );

      debugPrint('Notification Created => ${response.data}');
    } catch (e) {
      debugPrint('Notification Error => $e');
    }
  }

  //   Future<void> sendTopicNotification({
  //     required String title,
  //     required String body,
  //     required int productId,
  //   }) async {
  //     try {
  //       final response = await Dio().post<dynamic>(
  //         EnvVariable.instance.notifcationBaseUrl,
  //         options: Options(
  //           validateStatus: (_) => true,
  //           contentType: Headers.jsonContentType,
  //           responseType: ResponseType.json,
  //           headers: {
  //             'Content-Type': 'application/json',
  //             'Authorization': 'key=${EnvVariable.instance.firebaseKey}',
  //           },
  //         ),
  //         data: {
  //           'to': '/topics/$subscribeKey',
  //           'notification': {'title': title, 'body': body},
  //           'data': {'productId': productId},
  //         },
  //       );

  //       debugPrint('Notification Created => ${response.data}');
  //     } catch (e) {
  //       debugPrint('Notification Error => $e');
  //     }
  //   }
}
