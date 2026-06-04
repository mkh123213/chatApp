// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrentUserModel _$CurrentUserModelFromJson(Map<String, dynamic> json) =>
    CurrentUserModel(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      name: json['name'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool,
      isAnonymous: json['isAnonymous'] as bool,
      providerId: json['providerId'] as String?,
      creationTime: json['creationTime'] == null
          ? null
          : DateTime.parse(json['creationTime'] as String),
      lastSignInTime: json['lastSignInTime'] == null
          ? null
          : DateTime.parse(json['lastSignInTime'] as String),
    );

Map<String, dynamic> _$CurrentUserModelToJson(CurrentUserModel instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'photoUrl': instance.photoUrl,
      'emailVerified': instance.emailVerified,
      'isAnonymous': instance.isAnonymous,
      'providerId': instance.providerId,
      'creationTime': instance.creationTime?.toIso8601String(),
      'lastSignInTime': instance.lastSignInTime?.toIso8601String(),
    };
