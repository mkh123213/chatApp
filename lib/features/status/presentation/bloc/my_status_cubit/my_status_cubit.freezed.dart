// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_status_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MyStatusState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MyStatusState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MyStatusState()';
  }
}

/// @nodoc
class $MyStatusStateCopyWith<$Res> {
  $MyStatusStateCopyWith(MyStatusState _, $Res Function(MyStatusState) __);
}

/// Adds pattern-matching-related methods to [MyStatusState].
extension MyStatusStatePatterns on MyStatusState {
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
    TResult Function(_Loading value)? loading,
    TResult Function(_Loaded value)? loaded,
    TResult Function(_Empty value)? empty,
    TResult Function(_Error value)? error,
    TResult Function(_Deleting value)? deleting,
    TResult Function(_Deleted value)? deleted,
    TResult Function(_DeleteError value)? deleteError,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _Loaded() when loaded != null:
        return loaded(_that);
      case _Empty() when empty != null:
        return empty(_that);
      case _Error() when error != null:
        return error(_that);
      case _Deleting() when deleting != null:
        return deleting(_that);
      case _Deleted() when deleted != null:
        return deleted(_that);
      case _DeleteError() when deleteError != null:
        return deleteError(_that);
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
    required TResult Function(_Loading value) loading,
    required TResult Function(_Loaded value) loaded,
    required TResult Function(_Empty value) empty,
    required TResult Function(_Error value) error,
    required TResult Function(_Deleting value) deleting,
    required TResult Function(_Deleted value) deleted,
    required TResult Function(_DeleteError value) deleteError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case _Loading():
        return loading(_that);
      case _Loaded():
        return loaded(_that);
      case _Empty():
        return empty(_that);
      case _Error():
        return error(_that);
      case _Deleting():
        return deleting(_that);
      case _Deleted():
        return deleted(_that);
      case _DeleteError():
        return deleteError(_that);
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
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Loaded value)? loaded,
    TResult? Function(_Empty value)? empty,
    TResult? Function(_Error value)? error,
    TResult? Function(_Deleting value)? deleting,
    TResult? Function(_Deleted value)? deleted,
    TResult? Function(_DeleteError value)? deleteError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case _Loading() when loading != null:
        return loading(_that);
      case _Loaded() when loaded != null:
        return loaded(_that);
      case _Empty() when empty != null:
        return empty(_that);
      case _Error() when error != null:
        return error(_that);
      case _Deleting() when deleting != null:
        return deleting(_that);
      case _Deleted() when deleted != null:
        return deleted(_that);
      case _DeleteError() when deleteError != null:
        return deleteError(_that);
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
    TResult Function()? loading,
    TResult Function(List<StatusModel> mine)? loaded,
    TResult Function()? empty,
    TResult Function(String message)? error,
    TResult Function(String statusId)? deleting,
    TResult Function(String statusId)? deleted,
    TResult Function(String message)? deleteError,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Loaded() when loaded != null:
        return loaded(_that.mine);
      case _Empty() when empty != null:
        return empty();
      case _Error() when error != null:
        return error(_that.message);
      case _Deleting() when deleting != null:
        return deleting(_that.statusId);
      case _Deleted() when deleted != null:
        return deleted(_that.statusId);
      case _DeleteError() when deleteError != null:
        return deleteError(_that.message);
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
    required TResult Function() loading,
    required TResult Function(List<StatusModel> mine) loaded,
    required TResult Function() empty,
    required TResult Function(String message) error,
    required TResult Function(String statusId) deleting,
    required TResult Function(String statusId) deleted,
    required TResult Function(String message) deleteError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case _Loading():
        return loading();
      case _Loaded():
        return loaded(_that.mine);
      case _Empty():
        return empty();
      case _Error():
        return error(_that.message);
      case _Deleting():
        return deleting(_that.statusId);
      case _Deleted():
        return deleted(_that.statusId);
      case _DeleteError():
        return deleteError(_that.message);
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
    TResult? Function()? loading,
    TResult? Function(List<StatusModel> mine)? loaded,
    TResult? Function()? empty,
    TResult? Function(String message)? error,
    TResult? Function(String statusId)? deleting,
    TResult? Function(String statusId)? deleted,
    TResult? Function(String message)? deleteError,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case _Loading() when loading != null:
        return loading();
      case _Loaded() when loaded != null:
        return loaded(_that.mine);
      case _Empty() when empty != null:
        return empty();
      case _Error() when error != null:
        return error(_that.message);
      case _Deleting() when deleting != null:
        return deleting(_that.statusId);
      case _Deleted() when deleted != null:
        return deleted(_that.statusId);
      case _DeleteError() when deleteError != null:
        return deleteError(_that.message);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements MyStatusState {
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
    return 'MyStatusState.initial()';
  }
}

/// @nodoc

class _Loading implements MyStatusState {
  const _Loading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Loading);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MyStatusState.loading()';
  }
}

/// @nodoc

class _Loaded implements MyStatusState {
  const _Loaded({required final List<StatusModel> mine}) : _mine = mine;

  final List<StatusModel> _mine;
  List<StatusModel> get mine {
    if (_mine is EqualUnmodifiableListView) return _mine;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mine);
  }

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LoadedCopyWith<_Loaded> get copyWith =>
      __$LoadedCopyWithImpl<_Loaded>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Loaded &&
            const DeepCollectionEquality().equals(other._mine, _mine));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_mine));

  @override
  String toString() {
    return 'MyStatusState.loaded(mine: $mine)';
  }
}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res>
    implements $MyStatusStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) =
      __$LoadedCopyWithImpl;
  @useResult
  $Res call({List<StatusModel> mine});
}

/// @nodoc
class __$LoadedCopyWithImpl<$Res> implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? mine = null,
  }) {
    return _then(_Loaded(
      mine: null == mine
          ? _self._mine
          : mine // ignore: cast_nullable_to_non_nullable
              as List<StatusModel>,
    ));
  }
}

/// @nodoc

class _Empty implements MyStatusState {
  const _Empty();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _Empty);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MyStatusState.empty()';
  }
}

/// @nodoc

class _Error implements MyStatusState {
  const _Error({required this.message});

  final String message;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ErrorCopyWith<_Error> get copyWith =>
      __$ErrorCopyWithImpl<_Error>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Error &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'MyStatusState.error(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res>
    implements $MyStatusStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) =
      __$ErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$ErrorCopyWithImpl<$Res> implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_Error(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _Deleting implements MyStatusState {
  const _Deleting({required this.statusId});

  final String statusId;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeletingCopyWith<_Deleting> get copyWith =>
      __$DeletingCopyWithImpl<_Deleting>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Deleting &&
            (identical(other.statusId, statusId) ||
                other.statusId == statusId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, statusId);

  @override
  String toString() {
    return 'MyStatusState.deleting(statusId: $statusId)';
  }
}

/// @nodoc
abstract mixin class _$DeletingCopyWith<$Res>
    implements $MyStatusStateCopyWith<$Res> {
  factory _$DeletingCopyWith(_Deleting value, $Res Function(_Deleting) _then) =
      __$DeletingCopyWithImpl;
  @useResult
  $Res call({String statusId});
}

/// @nodoc
class __$DeletingCopyWithImpl<$Res> implements _$DeletingCopyWith<$Res> {
  __$DeletingCopyWithImpl(this._self, this._then);

  final _Deleting _self;
  final $Res Function(_Deleting) _then;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? statusId = null,
  }) {
    return _then(_Deleting(
      statusId: null == statusId
          ? _self.statusId
          : statusId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _Deleted implements MyStatusState {
  const _Deleted({required this.statusId});

  final String statusId;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeletedCopyWith<_Deleted> get copyWith =>
      __$DeletedCopyWithImpl<_Deleted>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Deleted &&
            (identical(other.statusId, statusId) ||
                other.statusId == statusId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, statusId);

  @override
  String toString() {
    return 'MyStatusState.deleted(statusId: $statusId)';
  }
}

/// @nodoc
abstract mixin class _$DeletedCopyWith<$Res>
    implements $MyStatusStateCopyWith<$Res> {
  factory _$DeletedCopyWith(_Deleted value, $Res Function(_Deleted) _then) =
      __$DeletedCopyWithImpl;
  @useResult
  $Res call({String statusId});
}

/// @nodoc
class __$DeletedCopyWithImpl<$Res> implements _$DeletedCopyWith<$Res> {
  __$DeletedCopyWithImpl(this._self, this._then);

  final _Deleted _self;
  final $Res Function(_Deleted) _then;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? statusId = null,
  }) {
    return _then(_Deleted(
      statusId: null == statusId
          ? _self.statusId
          : statusId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _DeleteError implements MyStatusState {
  const _DeleteError({required this.message});

  final String message;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DeleteErrorCopyWith<_DeleteError> get copyWith =>
      __$DeleteErrorCopyWithImpl<_DeleteError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DeleteError &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() {
    return 'MyStatusState.deleteError(message: $message)';
  }
}

/// @nodoc
abstract mixin class _$DeleteErrorCopyWith<$Res>
    implements $MyStatusStateCopyWith<$Res> {
  factory _$DeleteErrorCopyWith(
          _DeleteError value, $Res Function(_DeleteError) _then) =
      __$DeleteErrorCopyWithImpl;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$DeleteErrorCopyWithImpl<$Res> implements _$DeleteErrorCopyWith<$Res> {
  __$DeleteErrorCopyWithImpl(this._self, this._then);

  final _DeleteError _self;
  final $Res Function(_DeleteError) _then;

  /// Create a copy of MyStatusState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
  }) {
    return _then(_DeleteError(
      message: null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
