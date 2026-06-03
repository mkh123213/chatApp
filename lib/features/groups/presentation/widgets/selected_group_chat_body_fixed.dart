import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart';
import 'package:chat_material3/features/groups/presentation/widgets/group_message_input.dart';
import 'package:chat_material3/features/groups/presentation/widgets/group_messages_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedGroupChatBody extends StatefulWidget {
  const SelectedGroupChatBody({super.key, required this.group});

  final GroupModel group;

  @override
  State<SelectedGroupChatBody> createState() => _SelectedGroupChatBodyState();
}

class _SelectedGroupChatBodyState extends State<SelectedGroupChatBody> {
  late final String currentUserId;
  late final String currentUserEmail;

  @override
  void initState() {
    super.initState();

    final current = getCurrentUser();
    currentUserId = current.uid;
    currentUserEmail = current.email ?? '';

    context
        .read<SelectedGroupChatCubit>()
        .getGroupMessages(groupId: widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GroupMessagesBlocConsumer(
            groupId: widget.group.id,
            currentUserId: currentUserId,
          ),
        ),
        GroupMessageInput(
          group: widget.group,
          currentUserId: currentUserId,
          currentUserEmail: currentUserEmail,
        ),
      ],
    );
  }
}
