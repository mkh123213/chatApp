// REUSABLE SERVICE: Sends push notifications via Supabase Edge Function.
// REQUIRES: supabase_flutter, cloud_firestore, firebase_messaging packages in pubspec.yaml
// CHANGE: Update `usersCollection` import to your project's Firestore collection paths.
// CHANGE: Update the Supabase Edge Function name ('send-notification') if different.
// CHANGE: Update notification data fields (route, chatId, groupId) to match your app's navigation.
// CHANGE: Add/remove send methods to match your project's notification types.
import 'package:chat_material3/constants/fierstore_paths.dart'; // CHANGE: your collection paths
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      final activeChatId = data['activeChatId'] as String? ?? '';
      if (activeChatId == chatId) return;

      final fcmToken = data['fcmToken'] as String?;
      if (fcmToken == null || fcmToken.isEmpty) return;

      String body;
      switch (type) {
        case 'image':
          body = 'Image';
        case 'file':
          body = 'File';
        default:
          body = message;
      }

      await _sendViaEdgeFunction(
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

        final activeGroupId = data['activeGroupId'] as String? ?? '';
        if (activeGroupId == groupId) continue;

        final fcmToken = data['fcmToken'] as String?;
        if (fcmToken == null || fcmToken.isEmpty) continue;

        await _sendViaEdgeFunction(
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

      await _sendViaEdgeFunction(
        token: fcmToken,
        data: {
          'route': 'call',
          'callId': callId,
          'callerName': callerName,
          'callerPhotoUrl': callerPhotoUrl,
          'callType': callType,
        },
        dataOnly: true,
      );
    } catch (e) {
      debugPrint('Failed to send call notification: $e');
    }
  }

  Future<void> _sendViaEdgeFunction({
    required String token,
    String? title,
    String? body,
    required Map<String, String> data,
    bool dataOnly = false,
  }) async {
    try {
      await Supabase.instance.client.functions.invoke(
        'send-notification',
        body: {
          'token': token,
          if (title != null) 'title': title,
          if (body != null) 'body': body,
          'data': data,
          'dataOnly': dataOnly,
        },
      );
    } catch (e) {
      debugPrint('Edge function error: $e');
    }
  }
}
