import 'package:chat_material3/core/common/animations/animate_do.dart';
import 'package:chat_material3/core/common/bottom_shet/custom_bottom_sheet.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/refactor/chat_home_body.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/create_chat_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  void _showCreateChatBottomSheet() {
    CustomBottomSheet.showModalBottomSheetContainer(
      context: context,
      backgroundColor: context.color.surface,
      widget: CustomFadeInDown(
        duration: 500,
        child: BlocProvider(
          create: (context) => sl<CreateChatCubit>(),
          child: const CreateChatBottomSheet(),
        ),
      ),
    );
  }

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
              onPressed: _showCreateChatBottomSheet,
              child: const Icon(Iconsax.add),
            ),
          ),
        ),
      ],
    );
  }
}
