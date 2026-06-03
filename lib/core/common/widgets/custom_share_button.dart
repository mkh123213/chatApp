import 'package:flutter/material.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';

class CustomShareButton extends StatelessWidget {
  const CustomShareButton({required this.size, required this.onTap, super.key});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      icon: Icon(Icons.share, color: context.color.onSurface, size: size),
    );
  }
}
