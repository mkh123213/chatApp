import 'package:chat_material3/core/common/animations/animate_do.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/features/single_chat/presentation/refactor/chat_home_body.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ChatHomeScreen extends StatelessWidget {
  const ChatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CustomFadeInLeft(duration: 200, child: ChatHomeBody()),
        Positioned(
          bottom: 16,
          right: 16,
          child: CustomFadeInUp(
            duration: 300,
            child: FloatingActionButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.newChat),
              child: const Icon(Iconsax.add),
            ),
          ),
        ),
      ],
    );
  }
}
