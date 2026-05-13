import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_presence_state.freezed.dart';

@freezed
class UserPresenceState with _$UserPresenceState {
  const factory UserPresenceState.initial() = _Initial;
  const factory UserPresenceState.online() = _Online;
  const factory UserPresenceState.offline({required DateTime lastSeen}) =
      _Offline;
  const factory UserPresenceState.error({required String message}) = _Error;
}
