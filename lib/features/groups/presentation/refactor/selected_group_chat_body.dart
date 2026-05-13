import 'dart:io';

import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/push_notification/active_chat_tracker.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart';
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
    ActiveChatTracker.instance.setActiveGroup(widget.group.id);
    final cubit = context.read<SelectedGroupChatCubit>();
    cubit.getGroupMessages(groupId: widget.group.id);
    cubit.markAsRead(
      groupId: widget.group.id,
      currentUserId: currentUserId,
    );
  }

  @override
  void dispose() {
    ActiveChatTracker.instance.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SelectedGroupChatCubit>();

    return Column(
      children: [
        Expanded(
            child: GroupMessagesBlocConsumer(
                currentUserId: currentUserId,
                groupId: widget.group.id,
                totalMembers: widget.group.members.length)),
        ChatMessageInput(
          onSendText: (text) {
            cubit.sendGroupMessage(
              groupId: widget.group.id,
              senderId: currentUserId,
              senderEmail: currentUserEmail,
              text: text,
            );
          },
          onPickImage: (File imageFile, String caption) {
            cubit.sendImageMessage(
              groupId: widget.group.id,
              senderId: currentUserId,
              senderEmail: currentUserEmail,
              imageFile: imageFile,
              caption: caption,
            );
          },
          onPickFile: (File file, String fileName, String caption) {
            cubit.sendFileMessage(
              groupId: widget.group.id,
              senderId: currentUserId,
              senderEmail: currentUserEmail,
              file: file,
              fileName: fileName,
              caption: caption,
            );
          },
          onShareLink: (String link) {
            cubit.sendLinkMessage(
              groupId: widget.group.id,
              senderId: currentUserId,
              senderEmail: currentUserEmail,
              link: link,
            );
          },
        ),
      ],
    );
  }
}
