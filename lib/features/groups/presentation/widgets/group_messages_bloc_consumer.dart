import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:chat_material3/core/common/widgets/chat/message_read_status.dart';

class GroupMessagesBlocConsumer extends StatelessWidget {
  const GroupMessagesBlocConsumer({
    super.key,
    required this.groupId,
    required this.currentUserId,
    this.totalMembers = 0,
  });

  final String groupId;
  final String currentUserId;
  final int totalMembers;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectedGroupChatCubit, SelectedGroupChatState>(
      listener: (_, __) {},
      builder: (context, state) {
        final cubit = context.read<SelectedGroupChatCubit>();
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          empty: () => Center(
            child: TextApp(
              text: context.translate(LangKeys.noMessagesYet),
              theme: context.textStyle,
            ),
          ),
          loaded: (messages, selectedIds) => ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final message = messages[i];
              final isMe = message.senderId == currentUserId;
              final time = message.createdAt != null
                  ? DateFormat('h:mm a').format(message.createdAt!)
                  : '';
              final initial = message.senderEmail.isNotEmpty
                  ? message.senderEmail[0].toUpperCase()
                  : '?';

              return ChatMessageBubble(
                text: message.text.isNotEmpty
                    ? message.text
                    : (message.fileUrl ?? message.fileName ?? ''),
                messageType: _mapType(message.type),
                isMe: isMe,
                time: time,
                mediaUrl: message.fileUrl,
                fileName: message.fileName,
                isSelected: selectedIds.contains(message.id),
                senderLabel: isMe ? null : message.senderEmail,
                senderInitial: isMe ? null : initial,
                onImageTap: message.type == GroupMessageType.image &&
                        message.fileUrl != null &&
                        message.fileUrl!.isNotEmpty
                    ? () => openChatImageViewer(context, message.fileUrl!)
                    : null,
                onLongPress: () => cubit.toggleMessageSelection(message.id),
                readStatus: isMe
                    ? (message.readBy.length >= totalMembers - 1 &&
                            totalMembers > 1
                        ? ReadStatus.read
                        : ReadStatus.delivered)
                    : null,
              );
            },
          ),
          error: (message) => Center(
            child: TextApp(
              text: message,
              theme: context.textStyle,
            ),
          ),
        );
      },
    );
  }

  ChatMessageType _mapType(GroupMessageType type) {
    return switch (type) {
      GroupMessageType.image => ChatMessageType.image,
      GroupMessageType.file => ChatMessageType.file,
      GroupMessageType.link => ChatMessageType.link,
      GroupMessageType.text => ChatMessageType.text,
    };
  }
}
