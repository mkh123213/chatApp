import 'package:chat_material3/core/common/loading/empty_screen.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/chat/message_read_status.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/messages_cubit/messages_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class MessagesListView extends StatelessWidget {
  const MessagesListView({
    super.key,
    required this.chat,
    this.onReply,
  });

  final ChatModel chat;
  final void Function(MessageModel message)? onReply;

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
                final inSelectionMode = selectedIds.isNotEmpty;

                Widget bubble = ChatMessageBubble(
                  text: msg.text,
                  messageType: _mapType(msg.type),
                  isMe: isMe,
                  time: DateFormat.jm().format(msg.createdAt),
                  mediaUrl: msg.mediaUrl,
                  fileName: msg.fileName,
                  isEdited: msg.isEdited,
                  isSelected: selectedIds.contains(msg.id),
                  onImageTap: !inSelectionMode &&
                          msg.type == 'image' &&
                          msg.mediaUrl.isNotEmpty
                      ? () => openChatImageViewer(context, msg.mediaUrl)
                      : null,
                  onLongPress: isMe
                      ? () => cubit.toggleMessageSelection(msg.id)
                      : null,
                  readStatus: isMe
                      ? (msg.isRead ? ReadStatus.read : ReadStatus.delivered)
                      : null,
                  replyToText: msg.replyToText,
                  replyToSenderName: msg.replyToSenderName,
                  replyToType: msg.replyToType,
                );

                if (onReply != null && !inSelectionMode) {
                  bubble = _SwipeToReply(
                    onReply: () => onReply!(msg),
                    child: bubble,
                  );
                }

                return GestureDetector(
                  onTap: inSelectionMode
                      ? () => cubit.toggleMessageSelection(msg.id)
                      : null,
                  child: bubble,
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
      'voice' => ChatMessageType.voice,
      'sticker' => ChatMessageType.sticker,
      'gif' => ChatMessageType.gif,
      _ => ChatMessageType.text,
    };
  }
}

class _SwipeToReply extends StatefulWidget {
  const _SwipeToReply({required this.child, required this.onReply});

  final Widget child;
  final VoidCallback onReply;

  @override
  State<_SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<_SwipeToReply>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragOffset = 0;
  static const _threshold = 60.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, 80.0);
        });
      },
      onHorizontalDragEnd: (_) {
        if (_dragOffset >= _threshold) {
          widget.onReply();
        }
        setState(() => _dragOffset = 0);
      },
      child: Stack(
        children: [
          if (_dragOffset > 10)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Opacity(
                    opacity: (_dragOffset / _threshold).clamp(0.0, 1.0),
                    child: Icon(
                      Icons.reply,
                      color: Colors.grey[500],
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
