// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderEmail: json['senderEmail'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String,
      type: json['type'] as String,
      mediaUrl: json['mediaUrl'] as String,
      storagePath: json['storagePath'] as String,
      fileName: json['fileName'] as String,
      createdAt: MessageModel._dateTimeFromJson(json['createdAt']),
      updatedAt: MessageModel._dateTimeFromJson(json['updatedAt']),
      isEdited: json['isEdited'] as bool,
      isRead: json['isRead'] as bool? ?? false,
    );

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'senderEmail': instance.senderEmail,
      'receiverId': instance.receiverId,
      'text': instance.text,
      'type': instance.type,
      'mediaUrl': instance.mediaUrl,
      'storagePath': instance.storagePath,
      'fileName': instance.fileName,
      'createdAt': MessageModel._dateTimeToJson(instance.createdAt),
      'updatedAt': MessageModel._dateTimeToJson(instance.updatedAt),
      'isEdited': instance.isEdited,
      'isRead': instance.isRead,
    };
