// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CallModel _$CallModelFromJson(Map<String, dynamic> json) => CallModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String,
      callerEmail: json['callerEmail'] as String,
      callerPhotoUrl: json['callerPhotoUrl'] as String?,
      receiverId: json['receiverId'] as String,
      receiverName: json['receiverName'] as String,
      receiverEmail: json['receiverEmail'] as String,
      receiverPhotoUrl: json['receiverPhotoUrl'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      startedAt: CallModel._dateTimeFromJson(json['startedAt']),
      acceptedAt: CallModel._dateTimeFromJson(json['acceptedAt']),
      endedAt: CallModel._dateTimeFromJson(json['endedAt']),
      durationInSeconds: (json['durationInSeconds'] as num?)?.toInt() ?? 0,
      channelId: json['channelId'] as String,
      createdAt: CallModel._dateTimeFromJson(json['createdAt']),
      updatedAt: CallModel._dateTimeFromJson(json['updatedAt']),
    );

Map<String, dynamic> _$CallModelToJson(CallModel instance) => <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'callerId': instance.callerId,
      'callerName': instance.callerName,
      'callerEmail': instance.callerEmail,
      'callerPhotoUrl': instance.callerPhotoUrl,
      'receiverId': instance.receiverId,
      'receiverName': instance.receiverName,
      'receiverEmail': instance.receiverEmail,
      'receiverPhotoUrl': instance.receiverPhotoUrl,
      'type': instance.type,
      'status': instance.status,
      'startedAt': CallModel._dateTimeToJson(instance.startedAt),
      'acceptedAt': CallModel._dateTimeToJson(instance.acceptedAt),
      'endedAt': CallModel._dateTimeToJson(instance.endedAt),
      'durationInSeconds': instance.durationInSeconds,
      'channelId': instance.channelId,
      'createdAt': CallModel._dateTimeToJson(instance.createdAt),
      'updatedAt': CallModel._dateTimeToJson(instance.updatedAt),
    };
