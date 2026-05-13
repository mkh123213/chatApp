import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/attachment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class MessageInputBar extends StatefulWidget {
  const MessageInputBar({super.key, required this.chat});

  final ChatModel chat;

  @override
  State<MessageInputBar> createState() => _MessageInputBarState();
}

class _MessageInputBarState extends State<MessageInputBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<SendMessageCubit>().sendTextMessage(
          chat: widget.chat,
          text: text,
        );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => showAttachmentBottomSheet(
              context: context,
              chat: widget.chat,
            ),
            icon: const Icon(Iconsax.attach_circle),
          ),
          Expanded(
            child: Card(
              child: TextField(
                controller: _controller,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: context.translate(LangKeys.enterMessage),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
          IconButton.filled(
            onPressed: _hasText ? _sendMessage : null,
            icon: const Icon(Iconsax.send_1),
          ),
        ],
      ),
    );
  }
}
