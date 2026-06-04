import 'dart:ui';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:chat_material3/chat_app.dart';
import 'package:chat_material3/core/app/app_cubit/cubit/app_cubit.dart';
import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_material3/core/service/env/env_variable.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/service/hive/hive_database.dart';
import 'package:chat_material3/core/service/push_notification/firebase_cloud_messaging.dart';
import 'package:chat_material3/core/service/push_notification/local_notfication_service.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/core/service/push_notification/chat_notification_service.dart';
import 'package:chat_material3/core/service/user_presence/user_presence_service.dart';
import 'package:chat_material3/core/service/call_service/callkit_service.dart';
import 'package:chat_material3/core/service/dnd/dnd_service.dart';
import 'package:chat_material3/core/service/wallpaper/wallpaper_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EnvVariable.instance.init(envType: EnvTypeEnum.dev);
  //
  //  "current_key": "AIzaSyBDzognjD6pwp6oKKOoEkklgOunZo3W-fs" ==> apiKey
  //  "mobilesdk_app_id": "1:255535904497:android:bf1c974c2689a199431b50" ==> appId
  // "project_number": "255535904497" ==> messagingSenderId
  // "project_id": "asroo-dev" ==> projectId
  await Firebase.initializeApp().whenComplete(() async {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    FirebaseCloudMessaging().init();
    LocalNotificationService.init();
  });
  await Supabase.initialize(
    url: 'https://nkzezuvubeloiglhdpfu.supabase.co',
    anonKey: EnvVariable.instance.supabaseAnonKey,
  );
  // Platform.isAndroid
  //     ? await Firebase.initializeApp()
  //     : await Firebase.initializeApp();
  await CallKitService.instance.init();
  await SharedPref().instantiatePreferences();
  await setupInjector();

  // await setupInjector();

  await HiveDatabase().setup();
  DndService().init();
  WallpaperService().init();

  final currentUserJson = SharedPref().getString(PrefKeys.currentUser);
  if (currentUserJson != null) {
    try {
      final user = getCurrentUser();
      sl<UserPresenceService>().start(userId: user.uid);
      ChatNotificationService.instance.saveFcmToken(userId: user.uid);
    } catch (_) {}
  }

  // await DynamicLink().initDynamicLink();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppCubit()
              ..changeLanguage(
                lang: SharedPref().getString(PrefKeys.language).toString(),
              )
              ..changeTheme(
                isShared: SharedPref().getBoolean(PrefKeys.themeMode),
              ),
          ),
          // faviourate cubit
          // BlocProvider(create: (context) => sl<FaviourateCubit>()),
        ],
        child: BlocProvider(
          create: (context) => sl<AuthCubit>(),
          child: const ChatApp(),
        ),
      ),
    );
  });
}
