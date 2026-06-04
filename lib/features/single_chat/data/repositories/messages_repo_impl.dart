import 'dart:io';

import '../datasources/messages_remote_data_source.dart';
import '../models/message_model.dart';
import '../../domain/repositories/messages_repo.dart';

class MessagesRepoImpl implements MessagesRepo {
  const MessagesRepoImpl({
    required MessagesRemoteDataSource messagesRemoteDataSource,
  }) : _messagesRemoteDataSource = messagesRemoteDataSource;

  final MessagesRemoteDataSource _messagesRemoteDataSource;

  @override
  Stream<List<MessageModel>> getMessages({required String chatId}) {
    return _messagesRemoteDataSource.getMessages(chatId: chatId);
  }

  @override
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required String text,
    String? replyToId,
    String? replyToText,
    String? replyToType,
    String? replyToSenderName,
  }) {
    return _messagesRemoteDataSource.sendTextMessage(
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      text: text,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToType: replyToType,
      replyToSenderName: replyToSenderName,
    );
  }

  @override
  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required File imageFile,
    String caption = '',
    String? replyToId,
    String? replyToText,
    String? replyToType,
    String? replyToSenderName,
  }) {
    return _messagesRemoteDataSource.sendImageMessage(
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      imageFile: imageFile,
      caption: caption,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToType: replyToType,
      replyToSenderName: replyToSenderName,
    );
  }

  @override
  Future<void> sendFileMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required File file,
    required String originalFileName,
    String caption = '',
    String? replyToId,
    String? replyToText,
    String? replyToType,
    String? replyToSenderName,
  }) {
    return _messagesRemoteDataSource.sendFileMessage(
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      file: file,
      originalFileName: originalFileName,
      caption: caption,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToType: replyToType,
      replyToSenderName: replyToSenderName,
    );
  }

  @override
  Future<void> sendVoiceMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required File voiceFile,
    required Duration duration,
    String? replyToId,
    String? replyToText,
    String? replyToType,
    String? replyToSenderName,
  }) {
    return _messagesRemoteDataSource.sendVoiceMessage(
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      voiceFile: voiceFile,
      duration: duration,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToType: replyToType,
      replyToSenderName: replyToSenderName,
    );
  }

  @override
  Future<void> sendStickerMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required String sticker,
    String? replyToId,
    String? replyToText,
    String? replyToType,
    String? replyToSenderName,
  }) {
    return _messagesRemoteDataSource.sendStickerMessage(
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      sticker: sticker,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToType: replyToType,
      replyToSenderName: replyToSenderName,
    );
  }

  @override
  Future<void> sendGifMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required String gifUrl,
    String? replyToId,
    String? replyToText,
    String? replyToType,
    String? replyToSenderName,
  }) {
    return _messagesRemoteDataSource.sendGifMessage(
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      gifUrl: gifUrl,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToType: replyToType,
      replyToSenderName: replyToSenderName,
    );
  }

  @override
  Future<void> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) {
    return _messagesRemoteDataSource.updateMessage(
      chatId: chatId,
      messageId: messageId,
      text: text,
    );
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String storagePath,
  }) {
    return _messagesRemoteDataSource.deleteMessage(
      chatId: chatId,
      messageId: messageId,
      storagePath: storagePath,
    );
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  }) {
    return _messagesRemoteDataSource.markMessagesAsRead(
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<void> markMessagesByIdsAsRead({
    required String chatId,
    required List<String> messageIds,
  }) {
    return _messagesRemoteDataSource.markMessagesByIdsAsRead(
      chatId: chatId,
      messageIds: messageIds,
    );
  }
}
