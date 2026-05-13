// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusModel _$StatusModelFromJson(Map<String, dynamic> json) => StatusModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userEmail: json['userEmail'] as String,
      userPhotoUrl: json['userPhotoUrl'] as String?,
      mediaUrl: json['mediaUrl'] as String,
      storagePath: json['storagePath'] as String,
      type: json['type'] as String,
      text: json['text'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      viewers:
          (json['viewers'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: StatusModel._dateTimeFromJson(json['createdAt']),
      expiresAt: StatusModel._dateTimeFromJson(json['expiresAt']),
    );

Map<String, dynamic> _$StatusModelToJson(StatusModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userEmail': instance.userEmail,
      'userPhotoUrl': instance.userPhotoUrl,
      'mediaUrl': instance.mediaUrl,
      'storagePath': instance.storagePath,
      'type': instance.type,
      'text': instance.text,
      'backgroundColor': instance.backgroundColor,
      'viewers': instance.viewers,
      'createdAt': StatusModel._dateTimeToJson(instance.createdAt),
      'expiresAt': StatusModel._dateTimeToJson(instance.expiresAt),
    };
