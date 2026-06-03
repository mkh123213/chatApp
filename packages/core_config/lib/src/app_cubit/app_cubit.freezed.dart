// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(bool isDark) changeTheme,
    required TResult Function(String languageCode) changeLanguage,
    required TResult Function(Locale locale) languageChange,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(bool isDark)? changeTheme,
    TResult? Function(String languageCode)? changeLanguage,
    TResult? Function(Locale locale)? languageChange,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(bool isDark)? changeTheme,
    TResult Function(String languageCode)? changeLanguage,
    TResult Function(Locale locale)? languageChange,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(ChangeTheme value) changeTheme,
    required TResult Function(ChangeLanguage value) changeLanguage,
    required TResult Function(LanguageChangeState value) languageChange,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(ChangeTheme value)? changeTheme,
    TResult? Function(ChangeLanguage value)? changeLanguage,
    TResult? Function(LanguageChangeState value)? languageChange,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(ChangeTheme value)? changeTheme,
    TResult Function(ChangeLanguage value)? changeLanguage,
    TResult Function(LanguageChangeState value)? languageChange,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppStateCopyWith<$Res> {
  factory $AppStateCopyWith(AppState value, $Res Function(AppState) then) =
      _$AppStateCopyWithImpl<$Res, AppState>;
}

/// @nodoc
class _$AppStateCopyWithImpl<$Res, $Val extends AppState>
    implements $AppStateCopyWith<$Res> {
  _$AppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'AppState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(bool isDark) changeTheme,
    required TResult Function(String languageCode) changeLanguage,
    required TResult Function(Locale locale) languageChange,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(bool isDark)? changeTheme,
    TResult? Function(String languageCode)? changeLanguage,
    TResult? Function(Locale locale)? languageChange,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(bool isDark)? changeTheme,
    TResult Function(String languageCode)? changeLanguage,
    TResult Function(Locale locale)? languageChange,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(ChangeTheme value) changeTheme,
    required TResult Function(ChangeLanguage value) changeLanguage,
    required TResult Function(LanguageChangeState value) languageChange,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(ChangeTheme value)? changeTheme,
    TResult? Function(ChangeLanguage value)? changeLanguage,
    TResult? Function(LanguageChangeState value)? languageChange,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(ChangeTheme value)? changeTheme,
    TResult Function(ChangeLanguage value)? changeLanguage,
    TResult Function(LanguageChangeState value)? languageChange,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements AppState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$ChangeThemeImplCopyWith<$Res> {
  factory _$$ChangeThemeImplCopyWith(
          _$ChangeThemeImpl value, $Res Function(_$ChangeThemeImpl) then) =
      __$$ChangeThemeImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool isDark});
}

/// @nodoc
class __$$ChangeThemeImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$ChangeThemeImpl>
    implements _$$ChangeThemeImplCopyWith<$Res> {
  __$$ChangeThemeImplCopyWithImpl(
      _$ChangeThemeImpl _value, $Res Function(_$ChangeThemeImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDark = null,
  }) {
    return _then(_$ChangeThemeImpl(
      isDark: null == isDark
          ? _value.isDark
          : isDark // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ChangeThemeImpl implements ChangeTheme {
  const _$ChangeThemeImpl({required this.isDark});

  @override
  final bool isDark;

  @override
  String toString() {
    return 'AppState.changeTheme(isDark: $isDark)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangeThemeImpl &&
            (identical(other.isDark, isDark) || other.isDark == isDark));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isDark);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangeThemeImplCopyWith<_$ChangeThemeImpl> get copyWith =>
      __$$ChangeThemeImplCopyWithImpl<_$ChangeThemeImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(bool isDark) changeTheme,
    required TResult Function(String languageCode) changeLanguage,
    required TResult Function(Locale locale) languageChange,
  }) {
    return changeTheme(isDark);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(bool isDark)? changeTheme,
    TResult? Function(String languageCode)? changeLanguage,
    TResult? Function(Locale locale)? languageChange,
  }) {
    return changeTheme?.call(isDark);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(bool isDark)? changeTheme,
    TResult Function(String languageCode)? changeLanguage,
    TResult Function(Locale locale)? languageChange,
    required TResult orElse(),
  }) {
    if (changeTheme != null) {
      return changeTheme(isDark);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(ChangeTheme value) changeTheme,
    required TResult Function(ChangeLanguage value) changeLanguage,
    required TResult Function(LanguageChangeState value) languageChange,
  }) {
    return changeTheme(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(ChangeTheme value)? changeTheme,
    TResult? Function(ChangeLanguage value)? changeLanguage,
    TResult? Function(LanguageChangeState value)? languageChange,
  }) {
    return changeTheme?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(ChangeTheme value)? changeTheme,
    TResult Function(ChangeLanguage value)? changeLanguage,
    TResult Function(LanguageChangeState value)? languageChange,
    required TResult orElse(),
  }) {
    if (changeTheme != null) {
      return changeTheme(this);
    }
    return orElse();
  }
}

abstract class ChangeTheme implements AppState {
  const factory ChangeTheme({required final bool isDark}) = _$ChangeThemeImpl;

  bool get isDark;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangeThemeImplCopyWith<_$ChangeThemeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ChangeLanguageImplCopyWith<$Res> {
  factory _$$ChangeLanguageImplCopyWith(_$ChangeLanguageImpl value,
          $Res Function(_$ChangeLanguageImpl) then) =
      __$$ChangeLanguageImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String languageCode});
}

/// @nodoc
class __$$ChangeLanguageImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$ChangeLanguageImpl>
    implements _$$ChangeLanguageImplCopyWith<$Res> {
  __$$ChangeLanguageImplCopyWithImpl(
      _$ChangeLanguageImpl _value, $Res Function(_$ChangeLanguageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? languageCode = null,
  }) {
    return _then(_$ChangeLanguageImpl(
      languageCode: null == languageCode
          ? _value.languageCode
          : languageCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ChangeLanguageImpl implements ChangeLanguage {
  const _$ChangeLanguageImpl({required this.languageCode});

  @override
  final String languageCode;

  @override
  String toString() {
    return 'AppState.changeLanguage(languageCode: $languageCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChangeLanguageImpl &&
            (identical(other.languageCode, languageCode) ||
                other.languageCode == languageCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, languageCode);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChangeLanguageImplCopyWith<_$ChangeLanguageImpl> get copyWith =>
      __$$ChangeLanguageImplCopyWithImpl<_$ChangeLanguageImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(bool isDark) changeTheme,
    required TResult Function(String languageCode) changeLanguage,
    required TResult Function(Locale locale) languageChange,
  }) {
    return changeLanguage(languageCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(bool isDark)? changeTheme,
    TResult? Function(String languageCode)? changeLanguage,
    TResult? Function(Locale locale)? languageChange,
  }) {
    return changeLanguage?.call(languageCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(bool isDark)? changeTheme,
    TResult Function(String languageCode)? changeLanguage,
    TResult Function(Locale locale)? languageChange,
    required TResult orElse(),
  }) {
    if (changeLanguage != null) {
      return changeLanguage(languageCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(ChangeTheme value) changeTheme,
    required TResult Function(ChangeLanguage value) changeLanguage,
    required TResult Function(LanguageChangeState value) languageChange,
  }) {
    return changeLanguage(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(ChangeTheme value)? changeTheme,
    TResult? Function(ChangeLanguage value)? changeLanguage,
    TResult? Function(LanguageChangeState value)? languageChange,
  }) {
    return changeLanguage?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(ChangeTheme value)? changeTheme,
    TResult Function(ChangeLanguage value)? changeLanguage,
    TResult Function(LanguageChangeState value)? languageChange,
    required TResult orElse(),
  }) {
    if (changeLanguage != null) {
      return changeLanguage(this);
    }
    return orElse();
  }
}

abstract class ChangeLanguage implements AppState {
  const factory ChangeLanguage({required final String languageCode}) =
      _$ChangeLanguageImpl;

  String get languageCode;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChangeLanguageImplCopyWith<_$ChangeLanguageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LanguageChangeStateImplCopyWith<$Res> {
  factory _$$LanguageChangeStateImplCopyWith(_$LanguageChangeStateImpl value,
          $Res Function(_$LanguageChangeStateImpl) then) =
      __$$LanguageChangeStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Locale locale});
}

/// @nodoc
class __$$LanguageChangeStateImplCopyWithImpl<$Res>
    extends _$AppStateCopyWithImpl<$Res, _$LanguageChangeStateImpl>
    implements _$$LanguageChangeStateImplCopyWith<$Res> {
  __$$LanguageChangeStateImplCopyWithImpl(_$LanguageChangeStateImpl _value,
      $Res Function(_$LanguageChangeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? locale = null,
  }) {
    return _then(_$LanguageChangeStateImpl(
      locale: null == locale
          ? _value.locale
          : locale // ignore: cast_nullable_to_non_nullable
              as Locale,
    ));
  }
}

/// @nodoc

class _$LanguageChangeStateImpl implements LanguageChangeState {
  const _$LanguageChangeStateImpl({required this.locale});

  @override
  final Locale locale;

  @override
  String toString() {
    return 'AppState.languageChange(locale: $locale)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanguageChangeStateImpl &&
            (identical(other.locale, locale) || other.locale == locale));
  }

  @override
  int get hashCode => Object.hash(runtimeType, locale);

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LanguageChangeStateImplCopyWith<_$LanguageChangeStateImpl> get copyWith =>
      __$$LanguageChangeStateImplCopyWithImpl<_$LanguageChangeStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(bool isDark) changeTheme,
    required TResult Function(String languageCode) changeLanguage,
    required TResult Function(Locale locale) languageChange,
  }) {
    return languageChange(locale);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(bool isDark)? changeTheme,
    TResult? Function(String languageCode)? changeLanguage,
    TResult? Function(Locale locale)? languageChange,
  }) {
    return languageChange?.call(locale);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(bool isDark)? changeTheme,
    TResult Function(String languageCode)? changeLanguage,
    TResult Function(Locale locale)? languageChange,
    required TResult orElse(),
  }) {
    if (languageChange != null) {
      return languageChange(locale);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(ChangeTheme value) changeTheme,
    required TResult Function(ChangeLanguage value) changeLanguage,
    required TResult Function(LanguageChangeState value) languageChange,
  }) {
    return languageChange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(ChangeTheme value)? changeTheme,
    TResult? Function(ChangeLanguage value)? changeLanguage,
    TResult? Function(LanguageChangeState value)? languageChange,
  }) {
    return languageChange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(ChangeTheme value)? changeTheme,
    TResult Function(ChangeLanguage value)? changeLanguage,
    TResult Function(LanguageChangeState value)? languageChange,
    required TResult orElse(),
  }) {
    if (languageChange != null) {
      return languageChange(this);
    }
    return orElse();
  }
}

abstract class LanguageChangeState implements AppState {
  const factory LanguageChangeState({required final Locale locale}) =
      _$LanguageChangeStateImpl;

  Locale get locale;

  /// Create a copy of AppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LanguageChangeStateImplCopyWith<_$LanguageChangeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
