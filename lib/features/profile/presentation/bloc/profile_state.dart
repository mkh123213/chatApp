part of 'profile_cubit.dart';

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = _Initial;
  const factory ProfileState.profileLoaded({required CurrentUserModel user}) = _ProfileLoaded;
  const factory ProfileState.logoutLoading() = _LogoutLoading;
  const factory ProfileState.logoutSuccess() = _LogoutSuccess;
  const factory ProfileState.logoutError({required String message}) = _LogoutError;
}
