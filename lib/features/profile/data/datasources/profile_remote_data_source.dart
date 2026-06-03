import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../constants/fierstore_paths.dart';
import '../../../../core/app/models/current_user_model.dart';
import '../../../../core/service/shared_pref/shared_pref.dart';
import '../../../../core/service/shared_pref/pref_keys.dart';

abstract interface class ProfileRemoteDataSource {
  Future<CurrentUserModel?> refreshCurrentUser();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<CurrentUserModel?> refreshCurrentUser() async {
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    var model = CurrentUserModel.fromFirebaseUser(user);

    try {
      final doc = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(user.uid)
          .get();
      final firestorePhoto = doc.data()?['photoUrl'] as String?;
      final firestoreName = doc.data()?['name'] as String?;
      final firestorePhone = doc.data()?['phoneNumber'] as String?;
      model = model.copyWith(
        photoUrl: (firestorePhoto != null && firestorePhoto.isNotEmpty)
            ? firestorePhoto
            : model.photoUrl,
        name: (firestoreName != null && firestoreName.isNotEmpty)
            ? firestoreName
            : model.name,
        phoneNumber: (firestorePhone != null && firestorePhone.isNotEmpty)
            ? firestorePhone
            : model.phoneNumber,
      );
    } catch (_) {}

    await SharedPref().setString(PrefKeys.currentUser, jsonEncode(model.toJson()));
    return model;
  }
}
