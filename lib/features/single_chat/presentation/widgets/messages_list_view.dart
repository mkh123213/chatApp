import 'package:chat_material3/core/common/loading/empty_screen.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/chat/message_read_status.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/messages_cubit/messages_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({super.key, required this.chat});

  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesCubit, MessagesState>(
      builder: (context, state) {
        return switch (state) {
          MessagesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          MessagesLoaded(:final messages, :final selectedIds) =>
            ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderId == getCurrentUser().uid;
                final cubit = context.read<MessagesCubit>();
                return ChatMessageBubble(
                  text: msg.text,
                  messageType: _mapType(msg.type),
                  isMe: isMe,
                  time: DateFormat.jm().format(msg.createdAt),
                  mediaUrl: msg.mediaUrl,
                  fileName: msg.fileName,
                  isEdited: msg.isEdited,
                  isSelected: selectedIds.contains(msg.id),
                  onImageTap: msg.type == 'image' && msg.mediaUrl.isNotEmpty
                      ? () => openChatImageViewer(context, msg.mediaUrl)
                      : null,
                  onLongPress: isMe
                      ? () => cubit.toggleMessageSelection(msg.id)
                      : null,
                  readStatus: isMe
                      ? (msg.isRead ? ReadStatus.read : ReadStatus.delivered)
                      : null,
                );
              },
            ),
          MessagesEmpty() => EmptyScreen(
              title: context.translate(LangKeys.noMessagesYet),
            ),
          MessagesError(:final message) => EmptyScreen(title: message),
          _ => EmptyScreen(
              title: context.translate(LangKeys.noMessagesYet),
            ),
        };
      },
    );
  }

  ChatMessageType _mapType(String type) {
    return switch (type) {
      'image' => ChatMessageType.image,
      'file' => ChatMessageType.file,
      _ => ChatMessageType.text,
    };
  }
}
