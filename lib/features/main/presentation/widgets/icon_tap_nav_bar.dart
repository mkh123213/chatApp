import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class IconTapNavBar extends StatelessWidget {
  const IconTapNavBar({
    required this.onTap,
    required this.icon,
    required this.isSelected,
    this.activeColor,
    this.inactiveColor,
    super.key,
  });
  final VoidCallback onTap;
  final String icon;
  final bool isSelected;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? (activeColor ?? const Color(0xFF25D366))
        : (inactiveColor ?? context.color.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        icon,
        height: 25.h,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ).animate(target: isSelected ? 1 : 0).scaleXY(end: 1.1),
    );
  }
}
