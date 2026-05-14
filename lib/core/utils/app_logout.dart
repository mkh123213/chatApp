import 'package:flutter/widgets.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
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
    final context = sl<GlobalKey<NavigatorState>>().currentState!.context;

    sl<UserPresenceService>().stop();

    await SharedPref().removePreference(PrefKeys.accessToken);
    await SharedPref().removePreference(PrefKeys.userId);
    await SharedPref().removePreference(PrefKeys.userRole);
    await SharedPref().removePreference(PrefKeys.currentUser);
    await SharedPref().removePreference(PrefKeys.currentUserUrl);
    await HiveDatabase().clearAllBox();
    if (!context.mounted)
      return; //This checks whether the current BuildContext is still valid.
    await context.pushNamedAndRemoveUntil(AppRoutes.logIn);
  }
}
