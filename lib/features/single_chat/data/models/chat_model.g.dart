// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => ChatModel(
      id: json['id'] as String,
      users: (json['users'] as List<dynamic>).map((e) => e as String).toList(),
      usersEmails: (json['usersEmails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      usersNames: (json['usersNames'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lastMessage: json['lastMessage'] as String?,
      lastMessageType: json['lastMessageType'] as String?,
      lastMessageTime: ChatModel._dateTimeFromJson(json['lastMessageTime']),
      createdAt: ChatModel._dateTimeFromJson(json['createdAt']),
      updatedAt: ChatModel._dateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) => <String, dynamic>{
      'id': instance.id,
      'users': instance.users,
      'usersEmails': instance.usersEmails,
      'usersNames': instance.usersNames,
      'lastMessage': instance.lastMessage,
      'lastMessageType': instance.lastMessageType,
      'lastMessageTime': ChatModel._dateTimeToJson(instance.lastMessageTime),
      'createdAt': ChatModel._dateTimeToJson(instance.createdAt),
      'updatedAt': ChatModel._dateTimeToJson(instance.updatedAt),
    };
