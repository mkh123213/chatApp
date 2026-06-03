import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/service/hive/hive_database.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/core/service/user_presence/user_presence_service.dart';

class AppLogout {
  factory AppLogout() {
    return _instance;
  }

  AppLogout._();

  static final AppLogout _instance = AppLogout._();

  Future<void> logout() async {
    final navState = sl<GlobalKey<NavigatorState>>().currentState;
    if (navState == null) return;

    sl<UserPresenceService>().stop();

    // Navigate away first so widgets that depend on currentUser are removed
    await navState.pushNamedAndRemoveUntil(AppRoutes.logIn, (route) => false);

    await FirebaseAuth.instance.signOut();

    await SharedPref().removePreference(PrefKeys.accessToken);
    await SharedPref().removePreference(PrefKeys.userId);
    await SharedPref().removePreference(PrefKeys.userRole);
    await SharedPref().removePreference(PrefKeys.currentUser);
    await SharedPref().removePreference(PrefKeys.currentUserUrl);
    await HiveDatabase().clearAllBox();
  }
}
