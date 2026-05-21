import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/service/call_service/callkit_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/service/push_notification/local_notfication_service.dart';
import 'package:chat_material3/core/service/push_notification/notification_save_service.dart';
import 'package:chat_material3/core/service/dnd/dnd_service.dart';
import 'package:chat_material3/core/service/push_notification/active_chat_tracker.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';

class FirebaseMessagingNavigate {
  static Future<void> forGroundHandler(RemoteMessage? message) async {
    if (message == null) return;

    final data = message.data;
    final route = data['route'] as String? ?? '';

    // In foreground, incoming calls are handled by IncomingCallCubit via Firestore stream.
    // Don't show CallKit overlay to avoid duplicate call UIs.
    if (route == 'call') return;

    if (route == 'chat' &&
        ActiveChatTracker.instance.isActiveChat(data['chatId'] ?? '')) {
      return;
    }
    if (route == 'group' &&
        ActiveChatTracker.instance.isActiveGroup(data['groupId'] ?? '')) {
      return;
    }

    await NotificationSaveService.save(message);
    if (!DndService().isEnabled.value) {
      await LocalNotificationService.showSimpleNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
        payload: _buildPayload(data),
      );
    }
  }

  static Future<void> backGroundHandler(RemoteMessage? message) async {
    if (message == null) return;
    final route = message.data['route'] as String? ?? '';
    if (route == 'call') {
      await _handleCallNotification(message.data);
      return;
    }
    await NotificationSaveService.save(message);
    _navigateFromData(message.data);
  }

  static Future<void> terminatedHandler(RemoteMessage? message) async {
    if (message == null) return;
    final route = message.data['route'] as String? ?? '';
    if (route == 'call') {
      await _handleCallNotification(message.data);
      return;
    }
    await NotificationSaveService.save(message);
    _navigateFromData(message.data);
  }

  static String _buildPayload(Map<String, dynamic> data) {
    final route = data['route'] as String? ?? '';
    if (route == 'chat') {
      return 'chat:${data['chatId'] ?? ''}';
    } else if (route == 'group') {
      return 'group:${data['groupId'] ?? ''}';
    }
    return '';
  }

  static void handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final parts = payload.split(':');
    if (parts.length < 2 || parts[1].isEmpty) return;

    final route = parts[0];
    final id = parts[1];

    if (route == 'chat') {
      _navigateToChatByIdDirect(id);
    } else if (route == 'group') {
      _navigateToGroupByIdDirect(id);
    }
  }

  static Future<void> _navigateToChatByIdDirect(String chatId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc('$chatsCollection/$chatId')
          .get();
      if (!doc.exists || doc.data() == null) return;

      final chat = ChatModel.fromFirestore(id: doc.id, data: doc.data()!);
      final navState = await _waitForNavigator();
      navState?.pushNamed(AppRoutes.singleChat, arguments: chat);
    } catch (e) {
      debugPrint('Navigation to chat failed: $e');
    }
  }

  static Future<void> _navigateToGroupByIdDirect(String groupId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc('$groupsCollection/$groupId')
          .get();
      if (!doc.exists || doc.data() == null) return;

      final group = GroupModel.fromFirestore(id: doc.id, data: doc.data()!);
      final navState = await _waitForNavigator();
      navState?.pushNamed(AppRoutes.selectedGroupChat, arguments: group);
    } catch (e) {
      debugPrint('Navigation to group failed: $e');
    }
  }

  static Future<void> _handleCallNotification(Map<String, dynamic> data) async {
    final callId = data['callId'] as String? ?? '';
    final callerName = data['callerName'] as String? ?? 'Unknown';
    final callerPhotoUrl = data['callerPhotoUrl'] as String? ?? '';
    final callType = data['callType'] as String? ?? 'audio';

    await CallKitService.instance.showIncomingCall(
      callId: callId,
      callerName: callerName,
      callerAvatar: callerPhotoUrl,
      isVideo: callType == 'video',
    );
  }

  static void _navigateFromData(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route == 'chat') {
      final chatId = data['chatId'] as String?;
      if (chatId != null && chatId.isNotEmpty) {
        _navigateToChatById(chatId);
      }
    } else if (route == 'group') {
      final groupId = data['groupId'] as String?;
      if (groupId != null && groupId.isNotEmpty) {
        _navigateToGroupById(groupId);
      }
    }
  }

  static Future<NavigatorState?> _waitForNavigator() async {
    for (var i = 0; i < 10; i++) {
      final navState = sl<GlobalKey<NavigatorState>>().currentState;
      if (navState != null) return navState;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    debugPrint('Navigator not ready after retries');
    return null;
  }

  static Future<void> _navigateToChatById(String chatId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc('$chatsCollection/$chatId')
          .get();
      if (!doc.exists || doc.data() == null) return;

      final chat = ChatModel.fromFirestore(id: doc.id, data: doc.data()!);
      final navState = await _waitForNavigator();
      if (navState == null) return;
      navState.pushNamedAndRemoveUntil(
        AppRoutes.mainScreen,
        (route) => false,
      );
      navState.pushNamed(AppRoutes.singleChat, arguments: chat);
    } catch (e) {
      debugPrint('Navigation to chat failed: $e');
    }
  }

  static Future<void> _navigateToGroupById(String groupId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .doc('$groupsCollection/$groupId')
          .get();
      if (!doc.exists || doc.data() == null) return;

      final group = GroupModel.fromFirestore(id: doc.id, data: doc.data()!);
      final navState = await _waitForNavigator();
      if (navState == null) return;
      navState.pushNamedAndRemoveUntil(
        AppRoutes.mainScreen,
        (route) => false,
      );
      navState.pushNamed(AppRoutes.selectedGroupChat, arguments: group);
    } catch (e) {
      debugPrint('Navigation to group failed: $e');
    }
  }
}
