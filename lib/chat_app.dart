import 'package:chat_material3/core/app/app_cubit/cubit/app_cubit.dart';
import 'package:chat_material3/core/app/connectivity_controller.dart';
import 'package:chat_material3/core/app/env.variables.dart';
import 'package:chat_material3/core/common/screens/no_network_screen.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/language/app_localizations_setup.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/core/style/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// final navigatorKey = GlobalKey<NavigatorState>();

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return ValueListenableBuilder(
      valueListenable: ConnectivityController.instance.isConnected,
      builder: (_, value, __) {
        if (value) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => sl<AppCubit>()
                  ..changeTheme(
                    isShared: SharedPref().getBoolean(PrefKeys.themeMode),
                  )
                  ..changeLanguage(
                    lang: SharedPref().getString(PrefKeys.language),
                  ),
              ),
            ],
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              child: BlocBuilder<AppCubit, AppState>(
                buildWhen: (previous, current) {
                  return previous != current;
                },
                builder: (context, state) {
                  final cubit = context.read<AppCubit>();
                  return MaterialApp(
                    title: 'ALKHATEEB CHAT',
                    debugShowCheckedModeBanner: EnvVariable.instance.debugMode,
                    theme: cubit.isDark ? themeLight() : themeDark(),
                    locale: Locale(cubit.languageCode),
                    supportedLocales: AppLocalizationsSetup.supportedLocales,
                    localizationsDelegates:
                        AppLocalizationsSetup.localizationsDelegates,
                    localeResolutionCallback:
                        AppLocalizationsSetup.localeResolutionCallback,
                    builder: (context, widget) {
                      return GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Scaffold(
                          body: Builder(
                            builder: (context) {
                              ConnectivityController.instance.init();
                              return widget!;
                            },
                          ),
                        ),
                      );
                    },
                    navigatorKey: sl<GlobalKey<NavigatorState>>(),
                    onGenerateRoute: AppRoutes.onGenerateRoute,
                    initialRoute: AppRoutes.splash,
                  );
                },
              ),
            ),
          );
        } else {
          return MaterialApp(
            navigatorKey: sl<GlobalKey<NavigatorState>>(),
            title: 'No NetWork ',
            debugShowCheckedModeBanner: EnvVariable.instance.debugMode,
            home: const NoNetWorkScreen(),
          );
        }
      },
    );
  }
}
