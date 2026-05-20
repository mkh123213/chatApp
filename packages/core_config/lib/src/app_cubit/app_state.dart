part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.initial() = _Initial;
  const factory AppState.changeTheme({required bool isDark}) = ChangeTheme;
  const factory AppState.changeLanguage({required String languageCode}) =
      ChangeLanguage;
  const factory AppState.languageChange({required Locale locale}) =
      LanguageChangeState;
}
