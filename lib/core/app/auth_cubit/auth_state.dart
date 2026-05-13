part of 'auth_cubit.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated() = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.passwordUpdated() = _PasswordUpdated;
  const factory AuthState.passwordResetSent() = _PasswordResetSent;
  const factory AuthState.error({required String message}) = _Error;
  const factory AuthState.userUpdated() = _UserUpdated;
}
