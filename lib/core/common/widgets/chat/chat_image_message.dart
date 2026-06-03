import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatImageMessage extends StatelessWidget {
  const ChatImageMessage({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.width = 200,
    this.height = 200,
  });

  final String imageUrl;
  final VoidCallback? onTap;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (_, __) => SizedBox(
            width: width,
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (_, __, ___) => SizedBox(
            width: width,
            height: height,
            child: const Center(child: Icon(Icons.broken_image, size: 48)),
          ),
        ),
      ),
    );
  }
}
