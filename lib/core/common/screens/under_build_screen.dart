import 'package:chat_material3/constants/app_images.dart';
import 'package:flutter/material.dart';
// import 'package:chat_material3/core/style/images/app_images.dart';

class PageUnderBuildScreen extends StatelessWidget {
  const PageUnderBuildScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.assetsImagesCorePageUnderBuild),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
