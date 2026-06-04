import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_material3/constants/fierstore_paths.dart';

abstract class TypingRemoteDataSource {
  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
    String collection = chatsCollection,
  });

  Stream<Map<String, bool>> watchTypingStatus({
    required String chatId,
    String collection = chatsCollection,
  });
}

class TypingRemoteDataSourceImpl implements TypingRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;

  @override
  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
    String collection = chatsCollection,
  }) async {
    await _firestore
        .collection(collection)
        .doc(chatId)
        .collection('typing')
        .doc(userId)
        .set({
      'isTyping': isTyping,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<Map<String, bool>> watchTypingStatus({
    required String chatId,
    String collection = chatsCollection,
  }) {
    return _firestore
        .collection(collection)
        .doc(chatId)
        .collection('typing')
        .snapshots()
        .map((snapshot) {
      final result = <String, bool>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final isTyping = data['isTyping'] as bool? ?? false;
        final timestamp = data['timestamp'] as Timestamp?;
        if (isTyping && timestamp != null) {
          final age = DateTime.now().difference(timestamp.toDate());
          result[doc.id] = age.inSeconds < 30;
        } else {
          result[doc.id] = false;
        }
      }
      return result;
    });
  }
}
