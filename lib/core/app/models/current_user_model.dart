import 'package:firebase_auth/firebase_auth.dart';
import 'package:json_annotation/json_annotation.dart';

part 'current_user_model.g.dart';

@JsonSerializable()
class CurrentUserModel {
  const CurrentUserModel({
    required this.uid,
    this.email,
    this.name,
    this.phoneNumber,
    this.photoUrl,
    required this.emailVerified,
    required this.isAnonymous,
    this.providerId,
    this.creationTime,
    this.lastSignInTime,
  });

  final String uid;
  final String? email;
  final String? name;
  final String? phoneNumber;
  final String? photoUrl;
  final bool emailVerified;
  final bool isAnonymous;
  final String? providerId;
  final DateTime? creationTime;
  final DateTime? lastSignInTime;

  factory CurrentUserModel.fromFirebaseUser(User user) {
    return CurrentUserModel(
      uid: user.uid,
      email: user.email,
      name: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      isAnonymous: user.isAnonymous,
      providerId: user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : null,
      creationTime: user.metadata.creationTime,
      lastSignInTime: user.metadata.lastSignInTime,
    );
  }

  factory CurrentUserModel.fromUserCredential(UserCredential credential) {
    final user = credential.user;

    if (user == null) {
      throw Exception('No user found in credential.');
    }

    return CurrentUserModel.fromFirebaseUser(user);
  }

  factory CurrentUserModel.fromJson(Map<String, dynamic> json) {
    return _$CurrentUserModelFromJson(json);
  }

  Map<String, dynamic> toJson() {
    return _$CurrentUserModelToJson(this);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'isAnonymous': isAnonymous,
      'providerId': providerId,
      'creationTime': creationTime?.toIso8601String(),
      'lastSignInTime': lastSignInTime?.toIso8601String(),
    };
  }

  CurrentUserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    bool? emailVerified,
    bool? isAnonymous,
    String? providerId,
    DateTime? creationTime,
    DateTime? lastSignInTime,
  }) {
    return CurrentUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      providerId: providerId ?? this.providerId,
      creationTime: creationTime ?? this.creationTime,
      lastSignInTime: lastSignInTime ?? this.lastSignInTime,
    );
  }
}
