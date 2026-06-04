import 'package:flutter/material.dart';

void openChatImageViewer(BuildContext context, String imageUrl) {
  Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 64,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
