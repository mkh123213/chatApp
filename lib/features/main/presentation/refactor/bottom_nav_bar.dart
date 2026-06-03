import 'package:chat_material3/constants/app_images.dart';
import 'package:chat_material3/core/common/animations/animate_do.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/enums/nav_bar_enum.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/main/presentation/bloc/main_cubit.dart';
import 'package:chat_material3/features/main/presentation/widgets/icon_tap_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key});

  static final List<_NavBarItem> _items = [
    _NavBarItem(
      title: sl<GlobalKey<NavigatorState>>()
          .currentContext!
          .translate(LangKeys.chats),
      icon: Assets.assetsSvgSingleChats,
      navBarEnum: NavBarEnum.singleChats,
    ),
    _NavBarItem(
      title: sl<GlobalKey<NavigatorState>>()
          .currentContext!
          .translate(LangKeys.groups),
      icon: Assets.assetsSvgGoupIcon,
      navBarEnum: NavBarEnum.groups,
    ),
    _NavBarItem(
      title: sl<GlobalKey<NavigatorState>>()
          .currentContext!
          .translate(LangKeys.status),
      icon: Assets.assetsSvgWhatsappStatus,
      navBarEnum: NavBarEnum.status,
    ),
    _NavBarItem(
      title: sl<GlobalKey<NavigatorState>>()
          .currentContext!
          .translate(LangKeys.calls),
      icon: Assets.assetsSvgPhoneCall,
      navBarEnum: NavBarEnum.calls,
    ),
    _NavBarItem(
      title: sl<GlobalKey<NavigatorState>>()
          .currentContext!
          .translate(LangKeys.profile),
      icon: Assets.assetsSvgProfileTabIcon,
      navBarEnum: NavBarEnum.profile,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomFadeInUp(
      duration: 800,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SafeArea(
          top: false,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: context.color.surface,
              border: Border(
                top: BorderSide(
                  color: context.color.outlineVariant.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: BlocBuilder<MainCubit, MainState>(
              builder: (context, state) {
                final cubit = context.read<MainCubit>();

                return Row(
                  children: _items.map((item) {
                    final bool isSelected = cubit.navBarEnum == item.navBarEnum;

                    return Expanded(
                      child: _MainBottomNavItem(
                        title: item.title ?? '',
                        icon: item.icon,
                        isSelected: isSelected,
                        onTap: () {
                          cubit.selectedNavBarIcons(item.navBarEnum);
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MainBottomNavItem extends StatelessWidget {
  const _MainBottomNavItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  static const Color _selectedGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _selectedGreen;
    final Color inactiveColor = context.color.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: _selectedGreen.withValues(alpha: 0.1),
        highlightColor: _selectedGreen.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 6.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 28.h,
                child: Center(
                  child: IconTapNavBar(
                    icon: icon,
                    isSelected: isSelected,
                    onTap: onTap,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                  ),
                ),
              ),
              SizedBox(height: 4.h),
              TextApp(
                text: title,
                textAlign: TextAlign.center,
                theme: context.textStyle.copyWith(
                  fontSize: 12.sp,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem {
  _NavBarItem({
    this.title,
    required this.icon,
    required this.navBarEnum,
  });

  String? title;
  final String icon;
  final NavBarEnum navBarEnum;
}
