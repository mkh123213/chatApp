import 'dart:io';

import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/core/service/push_notification/chat_notification_service.dart';
import 'package:chat_material3/core/service/supabase/supabase_storage_service.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class MessagesRemoteDataSource {
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

class MessagesRemoteDataSourceImpl implements MessagesRemoteDataSource {
  const MessagesRemoteDataSourceImpl({
    required DataBaseService dataBaseService,
    required SupabaseStorageService storageService,
  })  : _dataBaseService = dataBaseService,
        _storageService = storageService;

  final DataBaseService _dataBaseService;
  final SupabaseStorageService _storageService;

  @override
  Stream<List<MessageModel>> getMessages({required String chatId}) {
    return _dataBaseService.collectionStream(
      builder: (data, documentId) =>
          MessageModel.fromFirestore(id: documentId, data: data),
      path: '$chatsCollection/$chatId/$messagesCollection',
      queryBuilder: (query) => query.orderBy('createdAt', descending: true),
    );
  }

  @override
  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
    required String text,
  }) async {
    final now = DateTime.now();
    final messageId = FirebaseFirestore.instance
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc()
        .id;

    final message = MessageModel(
      id: messageId,
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      text: text,
      type: 'text',
      mediaUrl: '',
      storagePath: '',
      fileName: '',
      createdAt: now,
      updatedAt: now,
      isEdited: false,
    );

    await _dataBaseService.setData(
      path: '$chatsCollection/$chatId/$messagesCollection/$messageId',
      data: message.toJson(),
    );

    await _updateChatLastMessage(
      chatId: chatId,
      lastMessage: text,
      lastMessageType: 'text',
      time: now,
    );

    ChatNotificationService.instance.sendMessageNotification(
      receiverId: receiverId,
      chatId: chatId,
      senderName: getCurrentUser().name ?? senderEmail,
      message: text,
      type: 'text',
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
  }) async {
    final result = await _storageService.uploadChatImage(
      chatId: chatId,
      file: imageFile,
    );

    final now = DateTime.now();
    final messageId = FirebaseFirestore.instance
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc()
        .id;

    final message = MessageModel(
      id: messageId,
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      text: caption,
      type: 'image',
      mediaUrl: result.url,
      storagePath: result.storagePath,
      fileName: result.fileName,
      createdAt: now,
      updatedAt: now,
      isEdited: false,
    );

    await _dataBaseService.setData(
      path: '$chatsCollection/$chatId/$messagesCollection/$messageId',
      data: message.toJson(),
    );

    await _updateChatLastMessage(
      chatId: chatId,
      lastMessage: 'Image',
      lastMessageType: 'image',
      time: now,
    );

    ChatNotificationService.instance.sendMessageNotification(
      receiverId: receiverId,
      chatId: chatId,
      senderName: getCurrentUser().name ?? senderEmail,
      message: 'Image',
      type: 'image',
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
  }) async {
    final result = await _storageService.uploadChatFile(
      chatId: chatId,
      file: file,
      originalFileName: originalFileName,
    );

    final now = DateTime.now();
    final messageId = FirebaseFirestore.instance
        .collection(chatsCollection)
        .doc(chatId)
        .collection(messagesCollection)
        .doc()
        .id;

    final message = MessageModel(
      id: messageId,
      chatId: chatId,
      senderId: senderId,
      senderEmail: senderEmail,
      receiverId: receiverId,
      text: caption,
      type: 'file',
      mediaUrl: result.url,
      storagePath: result.storagePath,
      fileName: originalFileName,
      createdAt: now,
      updatedAt: now,
      isEdited: false,
    );

    await _dataBaseService.setData(
      path: '$chatsCollection/$chatId/$messagesCollection/$messageId',
      data: message.toJson(),
    );

    await _updateChatLastMessage(
      chatId: chatId,
      lastMessage: originalFileName,
      lastMessageType: 'file',
      time: now,
    );

    ChatNotificationService.instance.sendMessageNotification(
      receiverId: receiverId,
      chatId: chatId,
      senderName: getCurrentUser().name ?? senderEmail,
      message: originalFileName,
      type: 'file',
    );
  }

  @override
  Future<void> updateMessage({
    required String chatId,
    required String messageId,
    required String text,
  }) async {
    await _dataBaseService.setData(
      path: '$chatsCollection/$chatId/$messagesCollection/$messageId',
      data: {
        'text': text,
        'isEdited': true,
        'updatedAt': Timestamp.now(),
      },
      merge: true,
    );
  }

  @override
  Future<void> deleteMessage({
    required String chatId,
    required String messageId,
    required String storagePath,
  }) async {
    await _dataBaseService.deleteData(
      path: '$chatsCollection/$chatId/$messagesCollection/$messageId',
    );

    if (storagePath.isNotEmpty) {
      await _storageService.removeFile(storagePath: storagePath);
    }
  }

  Future<void> _updateChatLastMessage({
    required String chatId,
    required String lastMessage,
    required String lastMessageType,
    required DateTime time,
  }) async {
    await _dataBaseService.setData(
      path: '$chatsCollection/$chatId',
      data: {
        'lastMessage': lastMessage,
        'lastMessageType': lastMessageType,
        'lastMessageTime': Timestamp.fromDate(time),
        'updatedAt': Timestamp.fromDate(time),
      },
      merge: true,
    );
  }

  @override
  Future<void> markMessagesAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('$chatsCollection/$chatId/$messagesCollection')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> markMessagesByIdsAsRead({
    required String chatId,
    required List<String> messageIds,
  }) async {
    if (messageIds.isEmpty) return;
    final batch = FirebaseFirestore.instance.batch();
    final collectionRef = FirebaseFirestore.instance
        .collection('$chatsCollection/$chatId/$messagesCollection');
    for (final id in messageIds) {
      batch.update(collectionRef.doc(id), {'isRead': true});
    }
    await batch.commit();
  }
}
