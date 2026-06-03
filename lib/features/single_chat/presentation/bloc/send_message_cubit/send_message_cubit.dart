import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/domain/repositories/messages_repo.dart';

import 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  SendMessageCubit({required MessagesRepo messagesRepo})
      : _messagesRepo = messagesRepo,
        super(const SendMessageInitial());

  final MessagesRepo _messagesRepo;

  Future<void> sendTextMessage({
    required ChatModel chat,
    required String text,
  }) async {
    emit(const SendMessageSending());
    try {
      final currentUser = getCurrentUser();
      final receiverId = chat.users.firstWhere(
        (uid) => uid != currentUser.uid,
        orElse: () => '',
      );
      await _messagesRepo.sendTextMessage(
        chatId: chat.id,
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        receiverId: receiverId,
        text: text,
      );
      emit(const SendMessageSent());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> sendImageMessage({
    required ChatModel chat,
    required File imageFile,
    String caption = '',
  }) async {
    emit(const SendMessageSending());
    try {
      final currentUser = getCurrentUser();
      final receiverId = chat.users.firstWhere(
        (uid) => uid != currentUser.uid,
        orElse: () => '',
      );
      await _messagesRepo.sendImageMessage(
        chatId: chat.id,
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        receiverId: receiverId,
        imageFile: imageFile,
        caption: caption,
      );
      emit(const SendMessageSent());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> sendFileMessage({
    required ChatModel chat,
    required File file,
    required String originalFileName,
    String caption = '',
  }) async {
    emit(const SendMessageSending());
    try {
      final currentUser = getCurrentUser();
      final receiverId = chat.users.firstWhere(
        (uid) => uid != currentUser.uid,
        orElse: () => '',
      );
      await _messagesRepo.sendFileMessage(
        chatId: chat.id,
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        receiverId: receiverId,
        file: file,
        originalFileName: originalFileName,
        caption: caption,
      );
      emit(const SendMessageSent());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> sendVoiceMessage({
    required ChatModel chat,
    required File voiceFile,
    required Duration duration,
  }) async {
    emit(const SendMessageSending());
    try {
      final currentUser = getCurrentUser();
      final receiverId = chat.users.firstWhere(
        (uid) => uid != currentUser.uid,
        orElse: () => '',
      );
      await _messagesRepo.sendVoiceMessage(
        chatId: chat.id,
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        receiverId: receiverId,
        voiceFile: voiceFile,
        duration: duration,
      );
      emit(const SendMessageSent());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> sendStickerMessage({
    required ChatModel chat,
    required String sticker,
  }) async {
    emit(const SendMessageSending());
    try {
      final currentUser = getCurrentUser();
      final receiverId = chat.users.firstWhere(
        (uid) => uid != currentUser.uid,
        orElse: () => '',
      );
      await _messagesRepo.sendStickerMessage(
        chatId: chat.id,
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        receiverId: receiverId,
        sticker: sticker,
      );
      emit(const SendMessageSent());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> sendGifMessage({
    required ChatModel chat,
    required String gifUrl,
  }) async {
    emit(const SendMessageSending());
    try {
      final currentUser = getCurrentUser();
      final receiverId = chat.users.firstWhere(
        (uid) => uid != currentUser.uid,
        orElse: () => '',
      );
      await _messagesRepo.sendGifMessage(
        chatId: chat.id,
        senderId: currentUser.uid,
        senderEmail: currentUser.email ?? '',
        receiverId: receiverId,
        gifUrl: gifUrl,
      );
      emit(const SendMessageSent());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    emit(const SendMessageEditing());
    try {
      await _messagesRepo.updateMessage(
        chatId: chatId,
        messageId: messageId,
        text: text,
      );
      emit(const SendMessageEdited());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }

  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String storagePath,
  }) async {
    emit(const SendMessageDeleting());
    try {
      await _messagesRepo.deleteMessage(
        chatId: chatId,
        messageId: messageId,
        storagePath: storagePath,
      );
      emit(const SendMessageDeleted());
    } catch (e) {
      emit(SendMessageError(message: e.toString()));
    }
  }
}
