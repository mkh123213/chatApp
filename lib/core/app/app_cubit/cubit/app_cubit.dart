import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/core/enums/nav_bar_enum.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';

part 'app_cubit.freezed.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState.initial());
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

    // languageCode = lang;
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

  // get the navbar icon
  NavBarEnum navBarEnum = NavBarEnum.singleChats;

  void selectedNavBarIcons(NavBarEnum viewEnum) {
    navBarEnum = viewEnum;
    emit(AppState.barSeletedIcons(navBarEnum: navBarEnum));
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
