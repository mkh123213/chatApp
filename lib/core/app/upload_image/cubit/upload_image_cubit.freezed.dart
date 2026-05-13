// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_image_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadImageState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is UploadImageState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'UploadImageState()';
  }
}

/// @nodoc
class $UploadImageStateCopyWith<$Res> {
  $UploadImageStateCopyWith(
      UploadImageState _, $Res Function(UploadImageState) __);
}

/// Adds pattern-matching-related methods to [UploadImageState].
extension UploadImageStatePatterns on UploadImageState {
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
    TResult Function(LoadingState value)? loading,
    TResult Function(LoadingListState value)? loadingList,
    TResult Function(SuccessState value)? success,
    TResult Function(RemovemageState value)? removeImage,
    TResult Function(ErrorState value)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case LoadingState() when loading != null:
        return loading(_that);
      case LoadingListState() when loadingList != null:
        return loadingList(_that);
      case SuccessState() when success != null:
        return success(_that);
      case RemovemageState() when removeImage != null:
        return removeImage(_that);
      case ErrorState() when error != null:
        return error(_that);
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
    required TResult Function(LoadingState value) loading,
    required TResult Function(LoadingListState value) loadingList,
    required TResult Function(SuccessState value) success,
    required TResult Function(RemovemageState value) removeImage,
    required TResult Function(ErrorState value) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case LoadingState():
        return loading(_that);
      case LoadingListState():
        return loadingList(_that);
      case SuccessState():
        return success(_that);
      case RemovemageState():
        return removeImage(_that);
      case ErrorState():
        return error(_that);
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
    TResult? Function(LoadingState value)? loading,
    TResult? Function(LoadingListState value)? loadingList,
    TResult? Function(SuccessState value)? success,
    TResult? Function(RemovemageState value)? removeImage,
    TResult? Function(ErrorState value)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case LoadingState() when loading != null:
        return loading(_that);
      case LoadingListState() when loadingList != null:
        return loadingList(_that);
      case SuccessState() when success != null:
        return success(_that);
      case RemovemageState() when removeImage != null:
        return removeImage(_that);
      case ErrorState() when error != null:
        return error(_that);
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
    TResult Function(int index)? loadingList,
    TResult Function()? success,
    TResult Function(String imageUrl)? removeImage,
    TResult Function(String error)? error,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case LoadingState() when loading != null:
        return loading();
      case LoadingListState() when loadingList != null:
        return loadingList(_that.index);
      case SuccessState() when success != null:
        return success();
      case RemovemageState() when removeImage != null:
        return removeImage(_that.imageUrl);
      case ErrorState() when error != null:
        return error(_that.error);
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
    required TResult Function(int index) loadingList,
    required TResult Function() success,
    required TResult Function(String imageUrl) removeImage,
    required TResult Function(String error) error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case LoadingState():
        return loading();
      case LoadingListState():
        return loadingList(_that.index);
      case SuccessState():
        return success();
      case RemovemageState():
        return removeImage(_that.imageUrl);
      case ErrorState():
        return error(_that.error);
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
    TResult? Function(int index)? loadingList,
    TResult? Function()? success,
    TResult? Function(String imageUrl)? removeImage,
    TResult? Function(String error)? error,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case LoadingState() when loading != null:
        return loading();
      case LoadingListState() when loadingList != null:
        return loadingList(_that.index);
      case SuccessState() when success != null:
        return success();
      case RemovemageState() when removeImage != null:
        return removeImage(_that.imageUrl);
      case ErrorState() when error != null:
        return error(_that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements UploadImageState {
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
    return 'UploadImageState.initial()';
  }
}

/// @nodoc

class LoadingState implements UploadImageState {
  const LoadingState();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is LoadingState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'UploadImageState.loading()';
  }
}

/// @nodoc

class LoadingListState implements UploadImageState {
  const LoadingListState(this.index);

  final int index;

  /// Create a copy of UploadImageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LoadingListStateCopyWith<LoadingListState> get copyWith =>
      _$LoadingListStateCopyWithImpl<LoadingListState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LoadingListState &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, index);

  @override
  String toString() {
    return 'UploadImageState.loadingList(index: $index)';
  }
}

/// @nodoc
abstract mixin class $LoadingListStateCopyWith<$Res>
    implements $UploadImageStateCopyWith<$Res> {
  factory $LoadingListStateCopyWith(
          LoadingListState value, $Res Function(LoadingListState) _then) =
      _$LoadingListStateCopyWithImpl;
  @useResult
  $Res call({int index});
}

/// @nodoc
class _$LoadingListStateCopyWithImpl<$Res>
    implements $LoadingListStateCopyWith<$Res> {
  _$LoadingListStateCopyWithImpl(this._self, this._then);

  final LoadingListState _self;
  final $Res Function(LoadingListState) _then;

  /// Create a copy of UploadImageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? index = null,
  }) {
    return _then(LoadingListState(
      null == index
          ? _self.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class SuccessState implements UploadImageState {
  const SuccessState();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is SuccessState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'UploadImageState.success()';
  }
}

/// @nodoc

class RemovemageState implements UploadImageState {
  const RemovemageState({required this.imageUrl});

  final String imageUrl;

  /// Create a copy of UploadImageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RemovemageStateCopyWith<RemovemageState> get copyWith =>
      _$RemovemageStateCopyWithImpl<RemovemageState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RemovemageState &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @override
  int get hashCode => Object.hash(runtimeType, imageUrl);

  @override
  String toString() {
    return 'UploadImageState.removeImage(imageUrl: $imageUrl)';
  }
}

/// @nodoc
abstract mixin class $RemovemageStateCopyWith<$Res>
    implements $UploadImageStateCopyWith<$Res> {
  factory $RemovemageStateCopyWith(
          RemovemageState value, $Res Function(RemovemageState) _then) =
      _$RemovemageStateCopyWithImpl;
  @useResult
  $Res call({String imageUrl});
}

/// @nodoc
class _$RemovemageStateCopyWithImpl<$Res>
    implements $RemovemageStateCopyWith<$Res> {
  _$RemovemageStateCopyWithImpl(this._self, this._then);

  final RemovemageState _self;
  final $Res Function(RemovemageState) _then;

  /// Create a copy of UploadImageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? imageUrl = null,
  }) {
    return _then(RemovemageState(
      imageUrl: null == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class ErrorState implements UploadImageState {
  const ErrorState({required this.error});

  final String error;

  /// Create a copy of UploadImageState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ErrorStateCopyWith<ErrorState> get copyWith =>
      _$ErrorStateCopyWithImpl<ErrorState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ErrorState &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, error);

  @override
  String toString() {
    return 'UploadImageState.error(error: $error)';
  }
}

/// @nodoc
abstract mixin class $ErrorStateCopyWith<$Res>
    implements $UploadImageStateCopyWith<$Res> {
  factory $ErrorStateCopyWith(
          ErrorState value, $Res Function(ErrorState) _then) =
      _$ErrorStateCopyWithImpl;
  @useResult
  $Res call({String error});
}

/// @nodoc
class _$ErrorStateCopyWithImpl<$Res> implements $ErrorStateCopyWith<$Res> {
  _$ErrorStateCopyWithImpl(this._self, this._then);

  final ErrorState _self;
  final $Res Function(ErrorState) _then;

  /// Create a copy of UploadImageState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? error = null,
  }) {
    return _then(ErrorState(
      error: null == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
