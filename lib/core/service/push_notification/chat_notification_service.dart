import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/app/env.variables.dart';
import 'package:chat_material3/core/service/push_notification/firebase_cloud_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class ChatNotificationService {
  ChatNotificationService._();
  static final ChatNotificationService instance = ChatNotificationService._();

  final _firestore = FirebaseFirestore.instance;

  Future<void> saveFcmToken({required String userId}) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) return;

    await _firestore.doc('$usersCollection/$userId').set(
      {'fcmToken': token},
      SetOptions(merge: true),
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _firestore.doc('$usersCollection/$userId').set(
        {'fcmToken': newToken},
        SetOptions(merge: true),
      );
    });
  }

  Future<void> removeFcmToken({required String userId}) async {
    await _firestore.doc('$usersCollection/$userId').update(
      {'fcmToken': FieldValue.delete()},
    );
  }

  Future<void> sendMessageNotification({
    required String receiverId,
    required String chatId,
    required String senderName,
    required String message,
    required String type,
  }) async {
    try {
      final receiverDoc =
          await _firestore.doc('$usersCollection/$receiverId').get();
      final data = receiverDoc.data();
      if (data == null) return;

      final fcmToken = data['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      String body;
      switch (type) {
        case 'image':
          body = '📷 Image';
        case 'file':
          body = '📎 File';
        default:
          body = message;
      }

      await _sendToToken(
        token: fcmToken,
        title: senderName,
        body: body,
        data: {'route': 'chat', 'chatId': chatId},
      );
    } catch (e) {
      debugPrint('Failed to send message notification: $e');
    }
  }

  Future<void> sendGroupMessageNotification({
    required String groupId,
    required String groupName,
    required String senderId,
    required String senderName,
    required String message,
    required List<String> memberIds,
  }) async {
    try {
      final otherMembers = memberIds.where((id) => id != senderId);

      for (final memberId in otherMembers) {
        final memberDoc =
            await _firestore.doc('$usersCollection/$memberId').get();
        final data = memberDoc.data();
        if (data == null) continue;

        final fcmToken = data['fcmToken'] as String?;
        if (fcmToken == null || fcmToken.isEmpty) continue;

        await _sendToToken(
          token: fcmToken,
          title: groupName,
          body: '$senderName: $message',
          data: {'route': 'group', 'groupId': groupId},
        );
      }
    } catch (e) {
      debugPrint('Failed to send group notification: $e');
    }
  }

  Future<void> sendCallNotification({
    required String receiverId,
    required String callId,
    required String callerName,
    required String callerPhotoUrl,
    required String callType,
  }) async {
    try {
      final receiverDoc =
          await _firestore.doc('$usersCollection/$receiverId').get();
      final data = receiverDoc.data();
      if (data == null) return;

      final fcmToken = data['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      await _sendDataOnly(
        token: fcmToken,
        data: {
          'route': 'call',
          'callId': callId,
          'callerName': callerName,
          'callerPhotoUrl': callerPhotoUrl,
          'callType': callType,
        },
      );
    } catch (e) {
      debugPrint('Failed to send call notification: $e');
    }
  }

  Future<void> _sendDataOnly({
    required String token,
    required Map<String, String> data,
  }) async {
    try {
      final accessToken = await FirebaseCloudMessaging().getAccessToken();

      await Dio().post<dynamic>(
        EnvVariable.instance.notifcationBaseUrl,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        data: {
          'message': {
            'token': token,
            'data': data,
            'android': {
              'priority': 'high',
            },
            'apns': {
              'payload': {
                'aps': {'content-available': 1},
              },
              'headers': {'apns-priority': '10'},
            },
          },
        },
      );
    } catch (e) {
      debugPrint('FCM data-only send error: $e');
    }
  }

  Future<void> _sendToToken({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final accessToken = await FirebaseCloudMessaging().getAccessToken();

      await Dio().post<dynamic>(
        EnvVariable.instance.notifcationBaseUrl,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        ),
        data: {
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': data,
            'android': {
              'notification': {
                'sound': 'default',
                'channel_id': 'high_importance_channel',
              },
            },
            'apns': {
              'payload': {
                'aps': {'sound': 'default', 'content-available': 1},
              },
            },
          },
        },
      );
    } catch (e) {
      debugPrint('FCM send error: $e');
    }
  }
}
