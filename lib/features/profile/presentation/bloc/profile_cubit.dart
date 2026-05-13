import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/app/models/current_user_model.dart';
import '../../../../core/service/shared_pref/shared_pref.dart';
import '../../../../core/service/shared_pref/pref_keys.dart';
import '../../../../core/utils/app_logout.dart';
import '../../data/datasources/profile_remote_data_source.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRemoteDataSource profileRemoteDataSource;
  CurrentUserModel? lastUser;

  ProfileCubit({required this.profileRemoteDataSource}) : super(const ProfileState.initial());

  void loadUser() {
    try {
      final userString = SharedPref().getString(PrefKeys.currentUser);
      if (userString != null) {
        lastUser = CurrentUserModel.fromJson(jsonDecode(userString));
        emit(ProfileState.profileLoaded(user: lastUser!));
      } else {
        lastUser = CurrentUserModel(uid: FirebaseAuth.instance.currentUser?.uid ?? '', emailVerified: false, isAnonymous: false);
        emit(ProfileState.profileLoaded(user: lastUser!));
      }
    } catch (e) {
      lastUser = CurrentUserModel(uid: FirebaseAuth.instance.currentUser?.uid ?? '', emailVerified: false, isAnonymous: false);
      emit(ProfileState.profileLoaded(user: lastUser!));
    }
    _refreshFromFirestore();
  }

  Future<void> _refreshFromFirestore() async {
    try {
      final refreshedUser = await profileRemoteDataSource.refreshCurrentUser();
      if (refreshedUser != null) {
        lastUser = refreshedUser;
        emit(ProfileState.profileLoaded(user: refreshedUser));
      }
    } catch (_) {
      // Swallows exceptions silently
    }
  }

  Future<void> logout() async {
    if (state is _LogoutLoading) return;
    
    emit(const ProfileState.logoutLoading());
    try {
      await AppLogout().logout();
      emit(const ProfileState.logoutSuccess());
    } catch (e) {
      emit(ProfileState.logoutError(message: e.toString()));
      if (lastUser != null) {
        emit(ProfileState.profileLoaded(user: lastUser!));
      }
    }
  }
}
