import 'package:chat_material3/constants/app_images.dart';
import 'package:chat_material3/core/common/animations/animate_do.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/enums/nav_bar_enum.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
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
              color: context.color.surface.withOpacity(0.90),
              boxShadow: [
                BoxShadow(
                  color: context.color.background.withValues(alpha: 0.1),
                  blurRadius: 24.r,
                  offset: Offset(0, -8.h),
                ),
              ],
            ),
            child: BlocBuilder<MainCubit, MainState>(
              builder: (context, state) {
                final cubit = context.read<MainCubit>();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _items.map((item) {
                    final bool isSelected = cubit.navBarEnum == item.navBarEnum;

                    return _MainBottomNavItem(
                      title: item.title ?? '',
                      icon: item.icon,
                      isSelected: isSelected,
                      onTap: () {
                        cubit.selectedNavBarIcons(item.navBarEnum);
                      },
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

  @override
  Widget build(BuildContext context) {
    final Color activeColor = context.color.onPrimaryContainer;
    final Color inactiveColor = context.color.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: context.color.primaryContainer.withOpacity(0.16),
        highlightColor: context.color.primaryContainer.withOpacity(0.10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20.w : 14.w,
            vertical: 6.h,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.color.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTapNavBar(
                icon: icon,
                isSelected: isSelected,
                onTap: onTap,
              ),
              highspace(height: 4),
              TextApp(
                  text: title,
                  theme: context.textStyle.copyWith(
                    fontSize: 12.sp,
                    color: isSelected ? activeColor : inactiveColor,
                  )),
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
