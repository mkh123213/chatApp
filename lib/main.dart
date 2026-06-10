import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  await Firebase.initializeApp().whenComplete(() async {
    // Only collect crashes in release builds of the prod flavor.
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      !kDebugMode && EnvVariable.instance.isProd,
    );
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    FirebaseCloudMessaging().init();
    LocalNotificationService.init();
  });

  // Enable offline persistence so chats work without a connection and
  // outgoing writes are queued until reconnect.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Fail loud and early if Supabase isn't configured — otherwise the first
  // sign of trouble is a confusing "not authorized" when uploading media.
  final supabaseKey = EnvVariable.instance.supabaseAnonKey;
  if (supabaseKey.isEmpty || supabaseKey.contains('your_')) {
    debugPrint(
      '\n========================================================\n'
      '⚠️  SUPABASE_ANON_KEY is missing or still a placeholder.\n'
      '    File: .env.dev / .env.prod\n'
      '    Get the real key from: Supabase Dashboard →\n'
      '    Project Settings → API → "anon public".\n'
      '    Image/file/voice uploads WILL FAIL until this is set.\n'
      '========================================================\n',
    );
  }

  await Supabase.initialize(
    url: EnvVariable.instance.supabaseUrl,
    anonKey: supabaseKey,
  );

  // SharedPreferences must be ready before the DI container is built, because
  // DioFactory (created during setupInjector) reads SharedPref synchronously.
  // CallKit and Hive are independent, so run them alongside it.
  await Future.wait([
    SharedPref().instantiatePreferences(),
    CallKitService.instance.init(),
    HiveDatabase().setup(),
  ]);

  await setupInjector();

  // Non-critical background services — fire-and-forget, must not block startup.
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
