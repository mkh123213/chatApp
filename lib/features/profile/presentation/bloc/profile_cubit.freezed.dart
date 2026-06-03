// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is ProfileState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState()';
  }
}

/// @nodoc
class $ProfileStateCopyWith<$Res> {
  $ProfileStateCopyWith(ProfileState _, $Res Function(ProfileState) __);
}

/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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
    TResult Function(_ProfileLoaded value)? profileLoaded,
    TResult Function(_LogoutLoading value)? logoutLoading,
    TResult Function(_LogoutSuccess value)? logoutSuccess,
    TResult Function(_LogoutError value)? logoutError,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _ProfileLoaded() when profileLoaded != null:
        return profileLoaded(_that);
      case _LogoutLoading() when logoutLoading != null:
        return logoutLoading(_that);
      case _LogoutSuccess() when logoutSuccess != null:
        return logoutSuccess(_that);
      case _LogoutError() when logoutError != null:
        return logoutError(_that);
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
    required TResult Function(_ProfileLoaded value) profileLoaded,
    required TResult Function(_LogoutLoading value) logoutLoading,
    required TResult Function(_LogoutSuccess value) logoutSuccess,
    required TResult Function(_LogoutError value) logoutError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _ProfileLoaded():
        return profileLoaded(_that);
      case _LogoutLoading():
        return logoutLoading(_that);
      case _LogoutSuccess():
        return logoutSuccess(_that);
      case _LogoutError():
        return logoutError(_that);
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
    TResult? Function(_ProfileLoaded value)? profileLoaded,
    TResult? Function(_LogoutLoading value)? logoutLoading,
    TResult? Function(_LogoutSuccess value)? logoutSuccess,
    TResult? Function(_LogoutError value)? logoutError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _ProfileLoaded() when profileLoaded != null:
        return profileLoaded(_that);
      case _LogoutLoading() when logoutLoading != null:
        return logoutLoading(_that);
      case _LogoutSuccess() when logoutSuccess != null:
        return logoutSuccess(_that);
      case _LogoutError() when logoutError != null:
        return logoutError(_that);
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
    TResult Function(CurrentUserModel user)? profileLoaded,
    TResult Function()? logoutLoading,
    TResult Function()? logoutSuccess,
    TResult Function(String message)? logoutError,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _ProfileLoaded() when profileLoaded != null:
        return profileLoaded(_that.user);
      case _LogoutLoading() when logoutLoading != null:
        return logoutLoading();
      case _LogoutSuccess() when logoutSuccess != null:
        return logoutSuccess();
      case _LogoutError() when logoutError != null:
        return logoutError(_that.message);
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
    required TResult Function(CurrentUserModel user) profileLoaded,
    required TResult Function() logoutLoading,
    required TResult Function() logoutSuccess,
    required TResult Function(String message) logoutError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _ProfileLoaded():
        return profileLoaded(_that.user);
      case _LogoutLoading():
        return logoutLoading();
      case _LogoutSuccess():
        return logoutSuccess();
      case _LogoutError():
        return logoutError(_that.message);
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
    TResult? Function(CurrentUserModel user)? profileLoaded,
    TResult? Function()? logoutLoading,
    TResult? Function()? logoutSuccess,
    TResult? Function(String message)? logoutError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _ProfileLoaded() when profileLoaded != null:
        return profileLoaded(_that.user);
      case _LogoutLoading() when logoutLoading != null:
        return logoutLoading();
      case _LogoutSuccess() when logoutSuccess != null:
        return logoutSuccess();
      case _LogoutError() when logoutError != null:
        return logoutError(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements ProfileState {
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
    return 'ProfileState.initial()';
  }
}

/// @nodoc

class _ProfileLoaded implements ProfileState {
  const _ProfileLoaded({required this.user});

  final CurrentUserModel user;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileLoadedCopyWith<_ProfileLoaded> get copyWith =>
      __$ProfileLoadedCopyWithImpl<_ProfileLoaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileLoaded &&
            (identical(other.user, user) || other.user == user));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user);

  @override
  String toString() {
    return 'ProfileState.profileLoaded(user: $user)';
  }
}

/// @nodoc
abstract mixin class _$ProfileLoadedCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileLoadedCopyWith(
          _ProfileLoaded value, $Res Function(_ProfileLoaded) _then) =
      __$ProfileLoadedCopyWithImpl;
  @useResult
  $Res call({CurrentUserModel user});
}

/// @nodoc
class __$ProfileLoadedCopyWithImpl<$Res>
    implements _$ProfileLoadedCopyWith<$Res> {
  __$ProfileLoadedCopyWithImpl(this._self, this._then);

  final _ProfileLoaded _self;
  final $Res Function(_ProfileLoaded) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = null,
  }) {
    return _then(_ProfileLoaded(
      user: null == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as CurrentUserModel,
    ));
  }
}

/// @nodoc

class _LogoutLoading implements ProfileState {
  const _LogoutLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _LogoutLoading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState.logoutLoading()';
  }
}

/// @nodoc

class _LogoutSuccess implements ProfileState {
  const _LogoutSuccess();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _LogoutSuccess);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'ProfileState.logoutSuccess()';
  }
}

/// @nodoc

class _LogoutError implements ProfileState {
  const _LogoutError({required this.message});

  final String message;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LogoutErrorCopyWith<_LogoutError> get copyWith =>
      __$LogoutErrorCopyWithImpl<_LogoutError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LogoutError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'ProfileState.logoutError(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$LogoutErrorCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$LogoutErrorCopyWith(
          _LogoutError value, $Res Function(_LogoutError) _then) =
      __$LogoutErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$LogoutErrorCopyWithImpl<$Res> implements _$LogoutErrorCopyWith<$Res> {
  __$LogoutErrorCopyWithImpl(this._self, this._then);

  final _LogoutError _self;
  final $Res Function(_LogoutError) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_LogoutError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
