import 'package:chat_material3/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:chat_material3/core/extensions/context_extension.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onTap,
    this.size = 24,
    this.padding = const EdgeInsets.all(8),
    this.color,
  });

  final VoidCallback? onTap;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap ?? () => Navigator.pop(context),
      child: Padding(
        padding: padding,
        child: Transform.flip(
          flipX: isRtl,
          child: SvgPicture.asset(
            Assets.assetsSvgArrowBack,
            width: size,
            height: size,
            colorFilter: ColorFilter.mode(
              color ?? context.color.onSurface,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
