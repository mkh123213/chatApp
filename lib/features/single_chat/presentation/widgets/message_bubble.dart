import 'package:chat_material3/core/common/widgets/chat/message_read_status.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/delete_message_dialog.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/edit_message_dialog.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/file_message_widget.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/image_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.chatId,
  });

  final MessageModel message;
  final String chatId;

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == getCurrentUser().uid;
    final timeText = DateFormat.jm().format(message.createdAt);

    return GestureDetector(
      onLongPress: isMe ? () => _showMessageActions(context) : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
            ),
            color: isMe ? context.color.primary : context.color.tertiary,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMessageContent(context),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (message.isEdited) ...[
                        TextApp(
                            text: context.translate(LangKeys.edited),
                            theme: context.textStyle),
                        const SizedBox(width: 4),
                      ],
                      TextApp(
                        text: timeText,
                        theme: context.textStyle
                            .copyWith(fontSize: 10, color: Colors.grey[600]),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        MessageReadStatus(
                          status: message.isRead
                              ? ReadStatus.read
                              : ReadStatus.delivered,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    return switch (message.type) {
      'image' => ImageMessageWidget(mediaUrl: message.mediaUrl),
      'file' => FileMessageWidget(
          mediaUrl: message.mediaUrl,
          fileName: message.fileName,
        ),
      _ => TextApp(
          text: message.text,
          theme: context.textStyle,
        ),
    };
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.type == 'text')
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: TextApp(
                    text: context.translate(LangKeys.editMessage),
                    theme: Theme.of(context).textTheme.bodyLarge!,
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    showEditMessageDialog(
                      context: context,
                      message: message,
                      chatId: chatId,
                    );
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: TextApp(
                  text: context.translate(LangKeys.deleteMessage),
                  theme: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                      ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  showDeleteMessageDialog(
                    context: context,
                    message: message,
                    chatId: chatId,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
