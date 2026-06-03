import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/service/call_service/callkit_service.dart';
import 'package:chat_material3/core/service/pending_navigation/pending_navigation_service.dart';
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
  /// App is in foreground — show local notification or skip if active chat.
  static Future<void> forGroundHandler(RemoteMessage? message) async {
    if (message == null) return;

    final data = message.data;
    final route = data['route'] as String? ?? '';

    // In foreground, incoming calls are handled by IncomingCallCubit via Firestore stream.
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

  /// User tapped notification while app was in background (not terminated).
  static Future<void> backGroundHandler(RemoteMessage? message) async {
    if (message == null) return;
    final data = message.data;
    final route = data['route'] as String? ?? '';

    if (route == 'call') {
      await _handleCallNotification(data);
      return;
    }

    await NotificationSaveService.save(message);
    _storePendingNavigation(data);
    _tryNavigateNow(data);
  }

  /// App was terminated when notification arrived — user opened app via notification.
  static Future<void> terminatedHandler(RemoteMessage? message) async {
    if (message == null) return;
    final data = message.data;
    final route = data['route'] as String? ?? '';

    if (route == 'call') {
      await _handleCallNotification(data);
      return;
    }

    await NotificationSaveService.save(message);
    _storePendingNavigation(data);
  }

  /// Store pending navigation so splash screen can pick it up after initialization.
  static void _storePendingNavigation(Map<String, dynamic> data) {
    final route = data['route'] as String?;
    if (route == 'chat') {
      final chatId = data['chatId'] as String?;
      if (chatId != null && chatId.isNotEmpty) {
        PendingNavigationService.instance.setPendingChat(chatId);
      }
    } else if (route == 'group') {
      final groupId = data['groupId'] as String?;
      if (groupId != null && groupId.isNotEmpty) {
        PendingNavigationService.instance.setPendingGroup(groupId);
      }
    }
  }

  /// Try to navigate now (works when app is in background, not terminated).
  static Future<void> _tryNavigateNow(Map<String, dynamic> data) async {
    try {
      final navState = sl<GlobalKey<NavigatorState>>().currentState;
      if (navState == null) return;

      final route = data['route'] as String?;
      if (route == 'chat') {
        final chatId = data['chatId'] as String?;
        if (chatId == null || chatId.isEmpty) return;
        final doc = await FirebaseFirestore.instance
            .doc('$chatsCollection/$chatId')
            .get();
        if (!doc.exists || doc.data() == null) return;
        final chat = ChatModel.fromFirestore(id: doc.id, data: doc.data()!);
        PendingNavigationService.instance.consume();
        navState.pushNamed(AppRoutes.singleChat, arguments: chat);
      } else if (route == 'group') {
        final groupId = data['groupId'] as String?;
        if (groupId == null || groupId.isEmpty) return;
        final doc = await FirebaseFirestore.instance
            .doc('$groupsCollection/$groupId')
            .get();
        if (!doc.exists || doc.data() == null) return;
        final group = GroupModel.fromFirestore(id: doc.id, data: doc.data()!);
        PendingNavigationService.instance.consume();
        navState.pushNamed(AppRoutes.selectedGroupChat, arguments: group);
      }
    } catch (_) {}
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

  /// Called when user taps a local notification (foreground notifications).
  static void handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) return;
    final parts = payload.split(':');
    if (parts.length < 2 || parts[1].isEmpty) return;

    final route = parts[0];
    final id = parts[1];

    if (route == 'chat') {
      _navigateToChatDirect(id);
    } else if (route == 'group') {
      _navigateToGroupDirect(id);
    }
  }

  static Future<void> _navigateToChatDirect(String chatId) async {
    try {
      final navState = sl<GlobalKey<NavigatorState>>().currentState;
      if (navState == null) return;
      final doc = await FirebaseFirestore.instance
          .doc('$chatsCollection/$chatId')
          .get();
      if (!doc.exists || doc.data() == null) return;
      final chat = ChatModel.fromFirestore(id: doc.id, data: doc.data()!);
      navState.pushNamed(AppRoutes.singleChat, arguments: chat);
    } catch (e) {
      debugPrint('Navigation to chat failed: $e');
    }
  }

  static Future<void> _navigateToGroupDirect(String groupId) async {
    try {
      final navState = sl<GlobalKey<NavigatorState>>().currentState;
      if (navState == null) return;
      final doc = await FirebaseFirestore.instance
          .doc('$groupsCollection/$groupId')
          .get();
      if (!doc.exists || doc.data() == null) return;
      final group = GroupModel.fromFirestore(id: doc.id, data: doc.data()!);
      navState.pushNamed(AppRoutes.selectedGroupChat, arguments: group);
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
}
