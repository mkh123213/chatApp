// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is AppState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AppState()';
  }
}

/// @nodoc
class $AppStateCopyWith<$Res> {
  $AppStateCopyWith(AppState _, $Res Function(AppState) __);
}

/// Adds pattern-matching-related methods to [AppState].
extension AppStatePatterns on AppState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(ChangeTheme value)? changeTheme,
    TResult Function(ChangeLanguage value)? changeLanguage,
    TResult Function(NavBarSelectedIcons value)? barSeletedIcons,
    TResult Function(LanguageChangeState value)? languageChange,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case ChangeTheme() when changeTheme != null:
        return changeTheme(_that);
      case ChangeLanguage() when changeLanguage != null:
        return changeLanguage(_that);
      case NavBarSelectedIcons() when barSeletedIcons != null:
        return barSeletedIcons(_that);
      case LanguageChangeState() when languageChange != null:
        return languageChange(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(ChangeTheme value) changeTheme,
    required TResult Function(ChangeLanguage value) changeLanguage,
    required TResult Function(NavBarSelectedIcons value) barSeletedIcons,
    required TResult Function(LanguageChangeState value) languageChange,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case ChangeTheme():
        return changeTheme(_that);
      case ChangeLanguage():
        return changeLanguage(_that);
      case NavBarSelectedIcons():
        return barSeletedIcons(_that);
      case LanguageChangeState():
        return languageChange(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(ChangeTheme value)? changeTheme,
    TResult? Function(ChangeLanguage value)? changeLanguage,
    TResult? Function(NavBarSelectedIcons value)? barSeletedIcons,
    TResult? Function(LanguageChangeState value)? languageChange,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case ChangeTheme() when changeTheme != null:
        return changeTheme(_that);
      case ChangeLanguage() when changeLanguage != null:
        return changeLanguage(_that);
      case NavBarSelectedIcons() when barSeletedIcons != null:
        return barSeletedIcons(_that);
      case LanguageChangeState() when languageChange != null:
        return languageChange(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(bool isDark)? changeTheme,
    TResult Function(String languageCode)? changeLanguage,
    TResult Function(NavBarEnum navBarEnum)? barSeletedIcons,
    TResult Function(Locale locale)? languageChange,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case ChangeTheme() when changeTheme != null:
        return changeTheme(_that.isDark);
      case ChangeLanguage() when changeLanguage != null:
        return changeLanguage(_that.languageCode);
      case NavBarSelectedIcons() when barSeletedIcons != null:
        return barSeletedIcons(_that.navBarEnum);
      case LanguageChangeState() when languageChange != null:
        return languageChange(_that.locale);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(bool isDark) changeTheme,
    required TResult Function(String languageCode) changeLanguage,
    required TResult Function(NavBarEnum navBarEnum) barSeletedIcons,
    required TResult Function(Locale locale) languageChange,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case ChangeTheme():
        return changeTheme(_that.isDark);
      case ChangeLanguage():
        return changeLanguage(_that.languageCode);
      case NavBarSelectedIcons():
        return barSeletedIcons(_that.navBarEnum);
      case LanguageChangeState():
        return languageChange(_that.locale);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(bool isDark)? changeTheme,
    TResult? Function(String languageCode)? changeLanguage,
    TResult? Function(NavBarEnum navBarEnum)? barSeletedIcons,
    TResult? Function(Locale locale)? languageChange,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case ChangeTheme() when changeTheme != null:
        return changeTheme(_that.isDark);
      case ChangeLanguage() when changeLanguage != null:
        return changeLanguage(_that.languageCode);
      case NavBarSelectedIcons() when barSeletedIcons != null:
        return barSeletedIcons(_that.navBarEnum);
      case LanguageChangeState() when languageChange != null:
        return languageChange(_that.locale);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements AppState {
  const _Initial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'AppState.initial()';
  }
}

/// @nodoc

class ChangeTheme implements AppState {
  const ChangeTheme({required this.isDark});

  final bool isDark;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChangeThemeCopyWith<ChangeTheme> get copyWith =>
      _$ChangeThemeCopyWithImpl<ChangeTheme>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChangeTheme &&
            (identical(other.isDark, isDark) || other.isDark == isDark));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isDark);

  @override
  String toString() {
    return 'AppState.changeTheme(isDark: $isDark)';
  }
}

/// @nodoc
abstract mixin class $ChangeThemeCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory $ChangeThemeCopyWith(
          ChangeTheme value, $Res Function(ChangeTheme) _then) =
      _$ChangeThemeCopyWithImpl;
  @useResult
  $Res call({bool isDark});
}

/// @nodoc
class _$ChangeThemeCopyWithImpl<$Res> implements $ChangeThemeCopyWith<$Res> {
  _$ChangeThemeCopyWithImpl(this._self, this._then);

  final ChangeTheme _self;
  final $Res Function(ChangeTheme) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isDark = null,
  }) {
    return _then(ChangeTheme(
      isDark: null == isDark
          ? _self.isDark
          : isDark // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class ChangeLanguage implements AppState {
  const ChangeLanguage({required this.languageCode});

  final String languageCode;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChangeLanguageCopyWith<ChangeLanguage> get copyWith =>
      _$ChangeLanguageCopyWithImpl<ChangeLanguage>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChangeLanguage &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, languageCode);

  @override
  String toString() {
    return 'AppState.changeLanguage(languageCode: $languageCode)';
  }
}

/// @nodoc
abstract mixin class $ChangeLanguageCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory $ChangeLanguageCopyWith(
          ChangeLanguage value, $Res Function(ChangeLanguage) _then) =
      _$ChangeLanguageCopyWithImpl;
  @useResult
  $Res call({String languageCode});
}

/// @nodoc
class _$ChangeLanguageCopyWithImpl<$Res>
    implements $ChangeLanguageCopyWith<$Res> {
  _$ChangeLanguageCopyWithImpl(this._self, this._then);

  final ChangeLanguage _self;
  final $Res Function(ChangeLanguage) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? languageCode = null,
  }) {
    return _then(ChangeLanguage(
      languageCode: null == languageCode
          ? _self.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class NavBarSelectedIcons implements AppState {
  const NavBarSelectedIcons({required this.navBarEnum});

  final NavBarEnum navBarEnum;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NavBarSelectedIconsCopyWith<NavBarSelectedIcons> get copyWith =>
      _$NavBarSelectedIconsCopyWithImpl<NavBarSelectedIcons>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NavBarSelectedIcons &&
            (identical(other.navBarEnum, navBarEnum) ||
                other.navBarEnum == navBarEnum));
  }

  @override
  int get hashCode => Object.hash(runtimeType, navBarEnum);

  @override
  String toString() {
    return 'AppState.barSeletedIcons(navBarEnum: $navBarEnum)';
  }
}

/// @nodoc
abstract mixin class $NavBarSelectedIconsCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory $NavBarSelectedIconsCopyWith(
          NavBarSelectedIcons value, $Res Function(NavBarSelectedIcons) _then) =
      _$NavBarSelectedIconsCopyWithImpl;
  @useResult
  $Res call({NavBarEnum navBarEnum});
}

/// @nodoc
class _$NavBarSelectedIconsCopyWithImpl<$Res>
    implements $NavBarSelectedIconsCopyWith<$Res> {
  _$NavBarSelectedIconsCopyWithImpl(this._self, this._then);

  final NavBarSelectedIcons _self;
  final $Res Function(NavBarSelectedIcons) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? navBarEnum = null,
  }) {
    return _then(NavBarSelectedIcons(
      navBarEnum: null == navBarEnum
          ? _self.navBarEnum
          : navBarEnum // ignore: cast_nullable_to_non_nullable
              as NavBarEnum,
    ));
  }
}

/// @nodoc

class LanguageChangeState implements AppState {
  const LanguageChangeState({required this.locale});

  final Locale locale;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LanguageChangeStateCopyWith<LanguageChangeState> get copyWith =>
      _$LanguageChangeStateCopyWithImpl<LanguageChangeState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LanguageChangeState &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, locale);

  @override
  String toString() {
    return 'AppState.languageChange(locale: $locale)';
  }
}

/// @nodoc
abstract mixin class $LanguageChangeStateCopyWith<$Res>
    implements $AppStateCopyWith<$Res> {
  factory $LanguageChangeStateCopyWith(
          LanguageChangeState value, $Res Function(LanguageChangeState) _then) =
      _$LanguageChangeStateCopyWithImpl;
  @useResult
  $Res call({Locale locale});
}

/// @nodoc
class _$LanguageChangeStateCopyWithImpl<$Res>
    implements $LanguageChangeStateCopyWith<$Res> {
  _$LanguageChangeStateCopyWithImpl(this._self, this._then);

  final LanguageChangeState _self;
  final $Res Function(LanguageChangeState) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? locale = null,
  }) {
    return _then(LanguageChangeState(
      locale: null == locale
          ? _self.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
    ));
  }
}

// dart format on
