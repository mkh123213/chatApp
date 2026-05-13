// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
      membersEmails: (json['membersEmails'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      admins:
          (json['admins'] as List<dynamic>).map((e) => e as String).toList(),
      lastMessage: json['lastMessage'] as String?,
      lastMessageTime: GroupModel._dateTimeFromJson(json['lastMessageTime']),
      createdAt: GroupModel._dateTimeFromJson(json['createdAt']),
      groupImageStoragePath: json['groupImageStoragePath'] as String,
      creatorId: json['creatorId'] as String,
    );

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'members': instance.members,
      'membersEmails': instance.membersEmails,
      'admins': instance.admins,
      'lastMessage': instance.lastMessage,
      'groupImageStoragePath': instance.groupImageStoragePath,
      'creatorId': instance.creatorId,
      'lastMessageTime': GroupModel._dateTimeToJson(instance.lastMessageTime),
      'createdAt': GroupModel._dateTimeToJson(instance.createdAt),
    };
