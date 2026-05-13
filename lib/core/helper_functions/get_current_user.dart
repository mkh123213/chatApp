import 'dart:convert';

import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';

CurrentUserModel getCurrentUser() {
  final userJson = SharedPref().getString(PrefKeys.currentUser);
  if (userJson != null) {
    return CurrentUserModel.fromJson(jsonDecode(userJson));
  } else {
    throw Exception('No current user found in shared preferences.');
  }
}
