import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/core/utils/app_strings.dart';

class NotificationSaveService {
  static Future<void> save(RemoteMessage message) async {
    try {
      final userId = SharedPref().getInt(PrefKeys.userId);
      if (userId == null || userId == 0) return;

      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      final productId =
          int.tryParse(message.data['product']?.toString() ?? '') ?? -1;
      final fierStore = sl<DataBaseService>();
      // final collection = FirebaseFirestore.instance.collection(
      //   globalNotificationsCollection,
      // );
      // final docRef = collection.doc();

      fierStore.setData(
        path: '$globalNotificationsCollection/${message.messageId}',
        data: {
          'notification_id': message.messageId,
          'user_id': userId,
          'title': title,
          'body': body,
          'created_at': DateTime.now().toIso8601String(),
          'isSeen': false,
          'product_id': productId,
        },
      );
    } catch (e) {
      debugPrint('NotificationSaveService: failed to save notification: $e');
    }
  }
}
