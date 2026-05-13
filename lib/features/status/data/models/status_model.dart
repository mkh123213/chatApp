import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'status_model.g.dart';

@JsonSerializable()
class StatusModel {
  const StatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl,
    required this.mediaUrl,
    required this.storagePath,
    required this.type,
    this.text,
    this.backgroundColor,
    required this.viewers,
    this.createdAt,
    this.expiresAt,
  });

  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhotoUrl;

  final String mediaUrl;
  final String storagePath;

  /// image, video, text
  final String type;

  final String? text;
  final String? backgroundColor;

  final List<String> viewers;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? createdAt;

  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? expiresAt;

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return _$StatusModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$StatusModelToJson(this);
  }

  static const String typeImage = 'image';
  static const String typeText = 'text';

  bool get isExpired {
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isImage => type == typeImage;
  bool get isText => type == typeText;
  bool isViewedBy(String uid) => viewers.contains(uid);

  factory StatusModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return StatusModel.fromJson({
      'id': id,
      ...data,
    });
  }

  static DateTime? _dateTimeFromJson(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static dynamic _dateTimeToJson(DateTime? value) {
    if (value == null) return null;
    return Timestamp.fromDate(value);
  }

  StatusModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhotoUrl,
    String? mediaUrl,
    String? storagePath,
    String? type,
    String? text,
    String? backgroundColor,
    List<String>? viewers,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StatusModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      storagePath: storagePath ?? this.storagePath,
      type: type ?? this.type,
      text: text ?? this.text,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      viewers: viewers ?? this.viewers,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
