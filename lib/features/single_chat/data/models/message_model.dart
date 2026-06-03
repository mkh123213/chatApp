import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.text,
    required this.type,
    required this.mediaUrl,
    required this.storagePath,
    required this.fileName,
    required this.createdAt,
    required this.updatedAt,
    required this.isEdited,
    this.isRead = false,
  });

  final String id;
  final String chatId;
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String text;
  final String type;
  final String mediaUrl;
  final String storagePath;
  final String fileName;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  final bool isEdited;
  final bool isRead;

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return _$MessageModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$MessageModelToJson(this);
  }

  factory MessageModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return MessageModel.fromJson({
      'id': id,
      ...data,
    });
  }

  static DateTime _dateTimeFromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static dynamic _dateTimeToJson(DateTime value) {
    return Timestamp.fromDate(value);
  }
}
