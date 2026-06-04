// REUSABLE WIDGET: Placeholder for routes under construction.
// CHANGE: Pass your own background image asset path.
import 'package:flutter/material.dart';

class PageUnderBuildScreen extends StatelessWidget {
  const PageUnderBuildScreen({super.key, this.imagePath});

  final String? imagePath; // CHANGE: your "under build" image asset

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: imagePath != null
          ? Container(
              constraints: const BoxConstraints.expand(),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath!),
                  fit: BoxFit.fill,
                ),
              ),
            )
          : const Center(child: Text('Page Under Construction')),
    );
  }
}
