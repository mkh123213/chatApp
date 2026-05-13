import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageMessageWidget extends StatelessWidget {
  const ImageMessageWidget({super.key, required this.mediaUrl});

  final String mediaUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        placeholder: (context, url) => const SizedBox(
          width: 200,
          height: 200,
          child: Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => const SizedBox(
          width: 200,
          height: 200,
          child: Center(child: Icon(Icons.broken_image)),
        ),
      ),
    );
  }
}
