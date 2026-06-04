import 'package:flutter/material.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';

class CustomFavoriteButton extends StatelessWidget {
  const CustomFavoriteButton({
    required this.size,
    required this.isFavorites,
    required this.onTap,
    super.key,
  });

  final double size;
  final bool isFavorites;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      padding: EdgeInsets.zero,
      icon: Icon(
        isFavorites ? Icons.favorite : Icons.favorite_outline,
        color: isFavorites
            ? context.color.tertiary
            : context.color.onSurface,
        size: size,
      ),
    );
  }
}
