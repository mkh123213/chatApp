import 'package:chat_material3/core/app/app_cubit/cubit/app_cubit.dart';
import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/common/dialogs/custom_dialogs.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/app_localizations.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/service/dnd/dnd_service.dart';
import 'package:chat_material3/core/service/push_notification/firebase_cloud_messaging.dart';
import 'package:chat_material3/core/service/wallpaper/wallpaper_service.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/features/profile/presentation/bloc/blocked_contacts_cubit.dart';
import 'package:chat_material3/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileBody extends StatelessWidget {
  const ProfileBody({
    super.key,
    required this.user,
    required this.isLogoutLoading,
  });

  final CurrentUserModel user;
  final bool isLogoutLoading;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          _ProfileHeader(user: user),
          SizedBox(height: 8.h),

          // Notifications section
          _SectionTitle(title: context.translate(LangKeys.notifications)),
          _NotificationTile(),
          _DoNotDisturbTile(),

          SizedBox(height: 8.h),

          // Privacy & Security section
          _SectionTitle(
              title: context.translate(LangKeys.privacyAndSecurity)),
          _DisappearingMessagesTile(),
          _BlockedContactsTile(),

          SizedBox(height: 8.h),

          // Appearance section
          _SectionTitle(title: context.translate(LangKeys.appearance)),
          _LightModeTile(),
          _WallpaperTile(),
          _LanguageTile(),

          SizedBox(height: 16.h),

          // Log Out
          _LogoutTile(
            isLoading: isLogoutLoading,
            onTap: () => context.read<ProfileCubit>().logout(),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final CurrentUserModel user;

  @override
  Widget build(BuildContext context) {
    final name = user.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          children: [
            // Avatar with edit badge
            Stack(
              children: [
                CircleAvatar(
                  radius: 50.r,
                  backgroundColor: context.color.primary,
                  backgroundImage: user.photoUrl != null &&
                          user.photoUrl!.isNotEmpty
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: user.photoUrl == null || user.photoUrl!.isEmpty
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => context.pushName(AppRoutes.editProfile),
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: context.color.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.color.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(Icons.edit, size: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Name with edit icon
            GestureDetector(
              onTap: () => context.pushName(AppRoutes.editProfile),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name.isNotEmpty ? name : 'User',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.edit, size: 16.sp,
                      color: context.color.onSurfaceVariant),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            // Email
            Text(
              user.email ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: context.color.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 4.h),
            // About text
            Text(
              context.translate(LangKeys.aboutStatus),
              style: TextStyle(
                fontSize: 13.sp,
                color: context.color.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: context.color.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FirebaseCloudMessaging().isNotificationSubscribe,
      builder: (_, value, __) {
        return ListTile(
          leading: Icon(Icons.notifications_outlined,
              color: context.color.onSurface),
          title: Text(
            context.translate(LangKeys.notifications),
            style: TextStyle(fontSize: 15.sp),
          ),
          trailing: Switch.adaptive(
            value: value,
            activeColor: context.color.primary,
            onChanged: (_) {
              FirebaseCloudMessaging().controllerForUserSubscribe(context);
            },
          ),
        );
      },
    );
  }
}

class _DoNotDisturbTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: DndService().isEnabled,
      builder: (_, enabled, __) {
        return ListTile(
          leading: Icon(Icons.do_not_disturb_on_outlined,
              color: context.color.onSurface),
          title: Text(
            context.translate(LangKeys.doNotDisturb),
            style: TextStyle(fontSize: 15.sp),
          ),
          subtitle: Text(
            enabled
                ? context.translate(LangKeys.on)
                : context.translate(LangKeys.off),
            style: TextStyle(
                fontSize: 13.sp, color: context.color.onSurfaceVariant),
          ),
          trailing: Switch.adaptive(
            value: enabled,
            activeColor: context.color.primary,
            onChanged: (_) => DndService().toggle(),
          ),
        );
      },
    );
  }
}

class _DisappearingMessagesTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.timer_outlined, color: context.color.onSurface),
      title: Text(
        context.translate(LangKeys.disappearingMessages),
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: Switch.adaptive(
        value: false,
        activeColor: context.color.primary,
        onChanged: (_) {},
      ),
    );
  }
}

class _BlockedContactsTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<BlockedContactsCubit>()
        ..loadBlockedContacts(currentUserId: getCurrentUser().uid),
      child: BlocBuilder<BlockedContactsCubit, BlockedContactsState>(
        builder: (context, state) {
          return ListTile(
            leading: Icon(Icons.person_off_outlined,
                color: context.color.onSurface),
            title: Text(
              context.translate(LangKeys.blockedContacts),
              style: TextStyle(fontSize: 15.sp),
            ),
            subtitle: Text(
              '${state.count} ${context.translate(LangKeys.blockedCount)}',
              style: TextStyle(
                  fontSize: 13.sp, color: context.color.onSurfaceVariant),
            ),
            trailing: Icon(Icons.chevron_right,
                color: context.color.onSurfaceVariant),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.blockedContacts);
            },
          );
        },
      ),
    );
  }
}

class _LightModeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    return ListTile(
      leading:
          Icon(Icons.light_mode_outlined, color: context.color.onSurface),
      title: Text(
        context.translate(LangKeys.lightMode),
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: Switch.adaptive(
        value: !cubit.isDark,
        activeColor: context.color.primary,
        onChanged: (_) => cubit.changeTheme(),
      ),
    );
  }
}

class _WallpaperTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: WallpaperService().selectedIndex,
      builder: (_, selectedIdx, __) {
        return ListTile(
          leading:
              Icon(Icons.wallpaper_outlined, color: context.color.onSurface),
          title: Text(
            context.translate(LangKeys.defaultWallpaper),
            style: TextStyle(fontSize: 15.sp),
          ),
          subtitle: Text(
            WallpaperService.options[selectedIdx].name,
            style: TextStyle(
                fontSize: 13.sp, color: context.color.onSurfaceVariant),
          ),
          trailing: Icon(Icons.chevron_right,
              color: context.color.onSurfaceVariant),
          onTap: () => _showWallpaperPicker(context),
        );
      },
    );
  }

  void _showWallpaperPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.color.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: context.color.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                context.translate(LangKeys.defaultWallpaper),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 80.h,
                child: ValueListenableBuilder<int>(
                  valueListenable: WallpaperService().selectedIndex,
                  builder: (_, selectedIdx, __) {
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: WallpaperService.options.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (_, index) {
                        final opt = WallpaperService.options[index];
                        final isSelected = index == selectedIdx;
                        return GestureDetector(
                          onTap: () => WallpaperService().select(index),
                          child: Column(
                            children: [
                              Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: opt.isGradient
                                      ? LinearGradient(colors: opt.colors)
                                      : null,
                                  color:
                                      opt.isGradient ? null : opt.colors.first,
                                  border: isSelected
                                      ? Border.all(
                                          color: context.color.primary,
                                          width: 3,
                                        )
                                      : Border.all(
                                          color: context.color.outlineVariant,
                                          width: 1,
                                        ),
                                ),
                                child: isSelected
                                    ? Icon(Icons.check,
                                        color: Colors.white, size: 20.sp)
                                    : null,
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                opt.name,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: isSelected
                                      ? context.color.primary
                                      : context.color.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
}

class _LanguageTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppCubit>();
    final langCode = context.translate(LangKeys.langCode);

    return ListTile(
      leading: Icon(Icons.language, color: context.color.onSurface),
      title: Text(
        context.translate(LangKeys.languageTitle),
        style: TextStyle(fontSize: 15.sp),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            langCode,
            style: TextStyle(
              fontSize: 14.sp,
              color: context.color.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.chevron_right,
              color: context.color.onSurfaceVariant, size: 20.sp),
        ],
      ),
      onTap: () {
        CustomDialog.twoButtonDialog(
          context: context,
          textBody: context.translate(LangKeys.changeToTheLanguage),
          textButton1: context.translate(LangKeys.sure),
          textButton2: context.translate(LangKeys.cancel),
          isLoading: false,
          onPressed: () {
            if (AppLocalizations.of(context)!.isEnLocale) {
              cubit.toArabic();
            } else {
              cubit.toEnglish();
            }
            context.pop();
          },
        );
      },
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.isLoading, required this.onTap});
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      leading: Icon(Icons.logout, color: Colors.red, size: 22.sp),
      title: Text(
        context.translate(LangKeys.logOut),
        style: TextStyle(
          fontSize: 15.sp,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: isLoading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: isLoading ? null : onTap,
    );
  }
}
