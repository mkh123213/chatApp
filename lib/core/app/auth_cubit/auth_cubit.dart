import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/service/auth_service_fierbase/auth_service_fierbase.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/utils/app_strings.dart';
import 'package:chat_material3/core/service/push_notification/chat_notification_service.dart';
import 'package:chat_material3/core/service/user_presence/user_presence_service.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required this.authService,
    required this.dataBaseService,
  }) : super(AuthState.initial());

  final AuthService authService;
  final DataBaseService dataBaseService;
  bool isObsecure = false;
  // You can add methods here to handle authentication logic, such as sign in, sign out, etc.
  void changePasswordVisibility() => isObsecure = !isObsecure;
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    emit(AuthState.loading());
    try {
      final user = await authService.signInWithEmailAndPassword(
          email: email, password: password);
      // Convert the Firebase User to your CurrentUserModel
      final userModel = CurrentUserModel.fromUserCredential(user);
// Save the user data to shared preferences
      SharedPref()
          .setString(PrefKeys.currentUser, jsonEncode(userModel.toJson()));
      // save the user data to firestore
      await dataBaseService.setData(
        path: '$usersCollection/${userModel.uid}',
        data: {
          ...userModel.toFirestore(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        merge: true,
      );
      sl<UserPresenceService>().start(userId: userModel.uid);
      ChatNotificationService.instance.saveFcmToken(userId: userModel.uid);
      emit(AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  // You can add more methods for other authentication actions like sign up, sign out, etc.

  Future<void> signOut() async {
    emit(AuthState.loading());
    try {
      sl<UserPresenceService>().stop();
      await authService.signOut();
      SharedPref().clearPreferences();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String photoUrl = '',
  }) async {
    emit(AuthState.loading());
    try {
      final credential = await authService.createUserWithEmailAndPassword(
          email: email, password: password);

      if (name.trim().isNotEmpty) {
        await authService.updateUserName(name: name.trim());
      }

      final userModel = CurrentUserModel.fromUserCredential(credential).copyWith(
        name: name.trim(),
        phoneNumber: phone.trim(),
        photoUrl: photoUrl.isNotEmpty ? photoUrl : null,
      );

      SharedPref()
          .setString(PrefKeys.currentUser, jsonEncode(userModel.toJson()));

      if (photoUrl.isNotEmpty) {
        SharedPref().setString(PrefKeys.currentUserUrl, photoUrl);
      }

      await dataBaseService.setData(
        path: '$usersCollection/${userModel.uid}',
        data: {
          ...userModel.toFirestore(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        merge: true,
      );

      sl<UserPresenceService>().start(userId: userModel.uid);
      ChatNotificationService.instance.saveFcmToken(userId: userModel.uid);

      emit(AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    emit(AuthState.loading());
    try {
      await authService.sendPasswordResetEmail(email: email);
      emit(const AuthState.passwordResetSent());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> sendEmailVerification() async {
    emit(AuthState.loading());
    try {
      await authService.sendEmailVerification();
      emit(AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> updateUserName({required String name}) async {
    emit(AuthState.loading());
    try {
      await authService.updateUserName(name: name);
      emit(AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> updateUserEmail({required String email}) async {
    emit(AuthState.loading());
    try {
      await authService.updateUserEmail(email: email);
      emit(AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> updateUserPasswordWithOldPassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const AuthState.loading());

    try {
      await authService.updateUserPasswordWithOldPassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      emit(const AuthState.passwordUpdated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> deleteAccount() async {
    emit(AuthState.loading());
    try {
      await authService.deleteAccount();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(AuthState.loading());
    try {
      await authService.signInWithGoogle();
      emit(AuthState.authenticated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }

  Future<void> updateUserProfile({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    emit(const AuthState.loading());

    try {
      final currentUserJson = SharedPref().getString(PrefKeys.currentUser);
      CurrentUserModel currentUser;

      if (currentUserJson != null && currentUserJson.isNotEmpty) {
        currentUser = CurrentUserModel.fromJson(
          jsonDecode(currentUserJson) as Map<String, dynamic>,
        );
      } else {
        final firebaseUser = authService.currentUser;
        if (firebaseUser == null) {
          throw Exception('No user is currently signed in.');
        }
        currentUser = CurrentUserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          name: firebaseUser.displayName,
          emailVerified: firebaseUser.emailVerified,
          isAnonymous: firebaseUser.isAnonymous,
        );
      }

      if (name.trim().isNotEmpty && name.trim() != currentUser.name) {
        await authService.updateUserName(name: name.trim());
      }

      final updatedUser = CurrentUserModel(
        uid: currentUser.uid,
        email: email.trim().isNotEmpty ? email.trim() : currentUser.email,
        name: name.trim().isNotEmpty ? name.trim() : currentUser.name,
        phoneNumber: phoneNumber.trim(),
        photoUrl: currentUser.photoUrl,
        emailVerified: currentUser.emailVerified,
        isAnonymous: currentUser.isAnonymous,
        providerId: currentUser.providerId,
        creationTime: currentUser.creationTime,
        lastSignInTime: DateTime.now(),
      );

      await SharedPref().setString(
        PrefKeys.currentUser,
        jsonEncode(updatedUser.toJson()),
      );

      await dataBaseService.setData(
        path: '$usersCollection/${updatedUser.uid}',
        data: {
          ...updatedUser.toFirestore(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        merge: true,
      );

      emit(const AuthState.userUpdated());
    } catch (e) {
      emit(AuthState.error(message: e.toString()));
    }
  }
}
