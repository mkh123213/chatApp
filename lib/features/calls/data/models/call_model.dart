import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'call_model.g.dart';

@JsonSerializable()
class CallModel {
  const CallModel({
    required this.id,
    required this.chatId,
    required this.callerId,
    required this.callerName,
    required this.callerEmail,
    this.callerPhotoUrl,
    required this.receiverId,
    required this.receiverName,
    required this.receiverEmail,
    this.receiverPhotoUrl,
    required this.type,
    required this.status,
    this.startedAt,
    this.acceptedAt,
    this.endedAt,
    this.durationInSeconds = 0,
    required this.channelId,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String chatId;
  final String callerId;
  final String callerName;
  final String callerEmail;
  final String? callerPhotoUrl;
  final String receiverId;
  final String receiverName;
  final String receiverEmail;
  final String? receiverPhotoUrl;
  final String type;
  final String status;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? startedAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? acceptedAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? endedAt;

  final int durationInSeconds;
  final String channelId;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? updatedAt;

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return _$CallModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CallModelToJson(this);
  }

  factory CallModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return CallModel.fromJson({
      'id': id,
      ...data,
    });
  }

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static dynamic _dateTimeToJson(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }
}
