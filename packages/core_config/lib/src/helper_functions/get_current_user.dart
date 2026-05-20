// REUSABLE HELPER: Retrieves the current user from SharedPreferences.
// REQUIRES: The user must be saved via SharedPref with PrefKeys.currentUser as JSON.
import 'dart:convert';

import 'package:core_config/src/models/current_user_model.dart';
import 'package:core_config/src/service/shared_pref/pref_keys.dart';
import 'package:core_config/src/service/shared_pref/shared_pref.dart';

CurrentUserModel getCurrentUser() {
  final userJson = SharedPref().getString(PrefKeys.currentUser);
  if (userJson != null) {
    return CurrentUserModel.fromJson(jsonDecode(userJson));
  } else {
    throw Exception('No current user found in shared preferences.');
  }
}
