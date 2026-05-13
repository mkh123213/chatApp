// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'main_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MainState {
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is MainState);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return 'MainState()';
  }
}

/// @nodoc
class $MainStateCopyWith<$Res> {
  $MainStateCopyWith(MainState _, $Res Function(MainState) __);
}

/// Adds pattern-matching-related methods to [MainState].
extension MainStatePatterns on MainState {
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
    TResult Function(BarSeletedIconsState value)? barSeletedIcons,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case BarSeletedIconsState() when barSeletedIcons != null:
        return barSeletedIcons(_that);
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
    required TResult Function(BarSeletedIconsState value) barSeletedIcons,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial(_that);
      case BarSeletedIconsState():
        return barSeletedIcons(_that);
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
    TResult? Function(BarSeletedIconsState value)? barSeletedIcons,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial(_that);
      case BarSeletedIconsState() when barSeletedIcons != null:
        return barSeletedIcons(_that);
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
    TResult Function(NavBarEnum navBarEnum)? barSeletedIcons,
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case BarSeletedIconsState() when barSeletedIcons != null:
        return barSeletedIcons(_that.navBarEnum);
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
    required TResult Function(NavBarEnum navBarEnum) barSeletedIcons,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial():
        return initial();
      case BarSeletedIconsState():
        return barSeletedIcons(_that.navBarEnum);
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
    TResult? Function(NavBarEnum navBarEnum)? barSeletedIcons,
  }) {
    final _that = this;
    switch (_that) {
      case _Initial() when initial != null:
        return initial();
      case BarSeletedIconsState() when barSeletedIcons != null:
        return barSeletedIcons(_that.navBarEnum);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Initial implements MainState {
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
    return 'MainState.initial()';
  }
}

/// @nodoc

class BarSeletedIconsState implements MainState {
  const BarSeletedIconsState({required this.navBarEnum});

  final NavBarEnum navBarEnum;

  /// Create a copy of MainState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BarSeletedIconsStateCopyWith<BarSeletedIconsState> get copyWith =>
      _$BarSeletedIconsStateCopyWithImpl<BarSeletedIconsState>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BarSeletedIconsState &&
            (identical(other.navBarEnum, navBarEnum) ||
                other.navBarEnum == navBarEnum));
  }

  @override
  int get hashCode => Object.hash(runtimeType, navBarEnum);

  @override
  String toString() {
    return 'MainState.barSeletedIcons(navBarEnum: $navBarEnum)';
  }
}

/// @nodoc
abstract mixin class $BarSeletedIconsStateCopyWith<$Res>
    implements $MainStateCopyWith<$Res> {
  factory $BarSeletedIconsStateCopyWith(BarSeletedIconsState value,
          $Res Function(BarSeletedIconsState) _then) =
      _$BarSeletedIconsStateCopyWithImpl;
  @useResult
  $Res call({NavBarEnum navBarEnum});
}

/// @nodoc
class _$BarSeletedIconsStateCopyWithImpl<$Res>
    implements $BarSeletedIconsStateCopyWith<$Res> {
  _$BarSeletedIconsStateCopyWithImpl(this._self, this._then);

  final BarSeletedIconsState _self;
  final $Res Function(BarSeletedIconsState) _then;

  /// Create a copy of MainState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  $Res call({
    Object? navBarEnum = null,
  }) {
    return _then(BarSeletedIconsState(
      navBarEnum: null == navBarEnum
          ? _self.navBarEnum
          : navBarEnum // ignore: cast_nullable_to_non_nullable
              as NavBarEnum,
    ));
  }
}

// dart format on
