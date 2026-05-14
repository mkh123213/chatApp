import 'dart:io';

import 'package:chat_material3/features/single_chat/data/models/message_model.dart';

abstract class MessagesRepo {
  Stream<List<MessageModel>> getMessages({required String chatId});

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required String text,
  });

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required File imageFile,
    String caption = '',
  });

  Future<void> sendFileMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required File file,
    required String originalFileName,
    String caption = '',
  });

  Future<void> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  });

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String storagePath,
  });

  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  });

  Future<void> markMessagesByIdsAsRead({
    required String chatId,
    required List<String> messageIds,
  });
}
