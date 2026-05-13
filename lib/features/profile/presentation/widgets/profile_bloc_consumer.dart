import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:chat_material3/features/profile/presentation/refactor/profile_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileBlocConsumer extends StatelessWidget {
  const ProfileBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        state.whenOrNull(
          logoutSuccess: () => ShowToast.showToastSuccessTop(
            message: context.translate(LangKeys.loggedOutSuccessfully),
          ),
          logoutError: (message) => ShowToast.showToastErrorTop(message: message),
        );
      },
      builder: (context, state) {
        final user = context.read<ProfileCubit>().lastUser;
        return state.maybeWhen(
          profileLoaded: (loadedUser) => ProfileBody(user: loadedUser, isLogoutLoading: false),
          logoutLoading: () => user == null
              ? const SizedBox.shrink()
              : ProfileBody(user: user, isLogoutLoading: true),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
