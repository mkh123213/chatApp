import 'package:chat_material3/core/common/screens/under_build_screen.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:chat_material3/features/profile/presentation/widgets/notification_and_lang/dark_mode_change.dart';
import 'package:chat_material3/features/profile/presentation/widgets/notification_and_lang/language_change.dart';
import 'package:chat_material3/features/profile/presentation/widgets/notification_and_lang/notifications_change.dart';
import 'package:chat_material3/features/profile/presentation/widgets/profile_logout_tile.dart';
import 'package:chat_material3/features/profile/presentation/widgets/profile_section_title.dart';
import 'package:chat_material3/features/profile/presentation/widgets/profile_setting_tile.dart';
import 'package:chat_material3/features/profile/presentation/widgets/profile_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody(
      {super.key, required this.user, required this.isLogoutLoading});

  final CurrentUserModel user;
  final bool isLogoutLoading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileUserCard(user: user),
          SizedBox(height: 16.h),
          ProfileSectionTitle(
              title: context.translate(LangKeys.profileSection)),
          Card(
            color: context.color.surface,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: Column(children: [
              ProfileSettingTile(
                  icon: Icons.person_outline,
                  title: context.translate(LangKeys.editProfileInfo),
                  subtitle: context.translate(LangKeys.editProfileSubtitle),
                  onTap: () => context.pushName(AppRoutes.editProfile)),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ProfileSettingTile(
                  icon: Icons.security_outlined,
                  title: context.translate(LangKeys.accountSecurity),
                  subtitle: context.translate(LangKeys.accountSecuritySubtitle),
                  onTap: () => context.pushName(AppRoutes.security)),
            ]),
          ),
          SizedBox(height: 12.h),
          ProfileSectionTitle(
              title: context.translate(LangKeys.appPreferences)),
          Card(
            color: context.color.surface,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: Column(children: [
              const NotificationsChange(),
              SizedBox(height: 16.h),
              const LanguageChange(),
              SizedBox(height: 16.h),
              const DarkModeChange()
            ]),
          ),
          SizedBox(height: 16.h),
          Card(
            color: context.color.surface,
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r)),
            child: ProfileLogoutTile(
              title: context.translate(LangKeys.logout),
              subtitle: context.translate(LangKeys.logoutSubtitle),
              isLoading: isLogoutLoading,
              onTap: () => context.read<ProfileCubit>().logout(),
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}
