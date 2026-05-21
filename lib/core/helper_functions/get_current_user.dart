import 'dart:convert';

import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';

const _emptyUser = CurrentUserModel(
  uid: '',
  emailVerified: false,
  isAnonymous: false,
);

CurrentUserModel getCurrentUser() {
  final userJson = SharedPref().getString(PrefKeys.currentUser);
  if (userJson != null && userJson.isNotEmpty) {
    try {
      return CurrentUserModel.fromJson(jsonDecode(userJson));
    } catch (_) {
      return _emptyUser;
    }
  }
  return _emptyUser;
}

CurrentUserModel? tryGetCurrentUser() {
  final userJson = SharedPref().getString(PrefKeys.currentUser);
  if (userJson != null && userJson.isNotEmpty) {
    try {
      return CurrentUserModel.fromJson(jsonDecode(userJson));
    } catch (_) {}
  }
  return null;
}
