import 'package:chat_material3/core/common/animations/animate_do.dart';
import 'package:chat_material3/core/common/bottom_shet/custom_bottom_sheet.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.dart';
import 'package:chat_material3/features/groups/presentation/bloc/groups_cubit/groups_cubit.dart';
import 'package:chat_material3/features/groups/presentation/refactor/groups_chat_body.dart';
import 'package:chat_material3/features/groups/presentation/widgets/create_group_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GroupsChatScreen extends StatefulWidget {
  const GroupsChatScreen({super.key});

  @override
  State<GroupsChatScreen> createState() => _GroupsChatScreenState();
}

class _GroupsChatScreenState extends State<GroupsChatScreen> {
  void _showCreateGroupBottomSheet() {
    CustomBottomSheet.showModalBottomSheetContainer(
      context: context,
      backgroundColor: context.color.surface,
      widget: CustomFadeInDown(
        duration: 500,
        child: BlocProvider(
          create: (_) => sl<CreateGroupCubit>(),
          child: const CreateGroupBottomSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupsCubit>(
      create: (_) => sl<GroupsCubit>(),
      child: Stack(
        children: [
          const CustomFadeInLeft(duration: 200, child: GroupsChatBody()),
          Positioned(
            bottom: 16,
            right: 16,
            child: CustomFadeInUp(
              duration: 300,
              child: FloatingActionButton(
                onPressed: _showCreateGroupBottomSheet,
                child: const Icon(Icons.group_add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
