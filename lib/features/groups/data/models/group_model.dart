import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {
  const GroupModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.members,
    required this.membersEmails,
    required this.admins,
    this.lastMessage,
    this.lastMessageTime,
    this.createdAt,
    required this.groupImageStoragePath,
    required this.creatorId,
  });

  final String id;
  final String name;
  final String imageUrl;
  final List<String> members;
  final List<String> membersEmails;
  final List<String> admins;
  final String? lastMessage;
  final String groupImageStoragePath;
  final String creatorId;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? lastMessageTime;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  factory GroupModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return GroupModel.fromJson({'id': id, ...data});
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
