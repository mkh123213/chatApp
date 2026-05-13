import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  const ChatModel({
    required this.id,
    required this.users,
    this.usersEmails,
    this.lastMessage,
    this.lastMessageType,
    this.lastMessageTime,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final List<String> users;
  final List<String>? usersEmails;
  final String? lastMessage;
  final String? lastMessageType;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? lastMessageTime;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? updatedAt;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return _$ChatModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$ChatModelToJson(this);
  }

  factory ChatModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return ChatModel.fromJson({
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
