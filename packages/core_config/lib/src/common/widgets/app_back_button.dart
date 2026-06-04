// REUSABLE WIDGET: RTL-aware back button.
// CHANGE: Pass your own SVG icon asset path, or it falls back to a Material icon.
import 'package:flutter/material.dart';
import 'package:core_config/src/extensions/context_extension.dart';

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
          child: Icon(
            Icons.arrow_back_ios_new,
            size: size,
            color: color ?? context.color.onSurface,
          ),
        ),
      ),
    );
  }
}
