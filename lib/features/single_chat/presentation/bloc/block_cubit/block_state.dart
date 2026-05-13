import 'package:freezed_annotation/freezed_annotation.dart';

part 'block_state.freezed.dart';

@freezed
class BlockState with _$BlockState {
  const factory BlockState.initial() = _Initial;
  const factory BlockState.loading() = _Loading;
  const factory BlockState.blocked({required bool blockedByMe}) = _Blocked;
  const factory BlockState.notBlocked() = _NotBlocked;
  const factory BlockState.error({required String message}) = _Error;
}
