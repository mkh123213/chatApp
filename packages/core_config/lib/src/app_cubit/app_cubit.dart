// REUSABLE CUBIT: Theme (dark/light) and language switching.
// REQUIRES: flutter_bloc, freezed_annotation packages in pubspec.yaml
// CHANGE: Update default language code if needed ('en' by default).
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core_config/src/service/shared_pref/pref_keys.dart';
import 'package:core_config/src/service/shared_pref/shared_pref.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState.initial());
  String languageCode = 'ar';
  bool isDark = true;

  String currentLangCode = 'en';

  Future<void> changeLanguage({String? lang}) async {
    if (lang != null) {
      languageCode = SharedPref().getString(PrefKeys.language).toString();
    } else if (languageCode == 'en') {
      languageCode = "ar";
    } else {
      languageCode = "en";
    }

    Locale(languageCode);
    await SharedPref().setString(PrefKeys.language, languageCode);
    emit(ChangeLanguage(languageCode: languageCode));
  }

  Future<void> changeTheme({bool? isShared}) async {
    if (isShared == null) {
      isDark = !isDark;
    } else {
      isDark = isShared;
    }
    await SharedPref().setBoolean(PrefKeys.themeMode, isDark);

    emit(ChangeTheme(isDark: isDark));
  }

  void getSavedLanguage() {
    final result = SharedPref().containPreference(PrefKeys.language)
        ? SharedPref().getString(PrefKeys.language)
        : 'en';

    currentLangCode = result!;

    emit(AppState.languageChange(locale: Locale(currentLangCode)));
  }

  Future<void> _changeLang(String langCode) async {
    await SharedPref().setString(PrefKeys.language, langCode);
    currentLangCode = langCode;
    emit(AppState.languageChange(locale: Locale(currentLangCode)));
  }

  void toArabic() => _changeLang('ar');

  void toEnglish() => _changeLang('en');
}
