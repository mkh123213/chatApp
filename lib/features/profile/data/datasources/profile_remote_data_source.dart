import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
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
    
    final model = CurrentUserModel.fromFirebaseUser(user);
    await SharedPref().setString(PrefKeys.currentUser, jsonEncode(model.toJson()));
    return model;
  }
}
