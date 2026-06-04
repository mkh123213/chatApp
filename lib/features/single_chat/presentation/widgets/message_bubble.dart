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
import 'package:chat_material3/features/single_chat/presentation/widgets/voice_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

    final bubbleColor = isMe
        ? context.color.primary.withValues(alpha: 0.15)
        : context.color.surfaceContainerHigh;

    return GestureDetector(
      onLongPress: isMe ? () => _showMessageActions(context) : null,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: EdgeInsets.symmetric(vertical: 3.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
              bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
              bottomRight: Radius.circular(isMe ? 4.r : 16.r),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMessageContent(context),
              SizedBox(height: 4.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.isEdited) ...[
                    TextApp(
                      text: context.translate(LangKeys.edited),
                      theme: context.textStyle.copyWith(
                        fontSize: 10.sp,
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: 4.w),
                  ],
                  TextApp(
                    text: timeText,
                    theme: context.textStyle.copyWith(
                      fontSize: 10.sp,
                      color: context.color.onSurfaceVariant,
                    ),
                  ),
                  if (isMe) ...[
                    SizedBox(width: 4.w),
                    MessageReadStatus(
                      status: message.isRead
                          ? ReadStatus.read
                          : ReadStatus.delivered,
                      size: 14,
                      readColor: context.color.primary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    final isMe = message.senderId == getCurrentUser().uid;
    return switch (message.type) {
      'image' => ImageMessageWidget(mediaUrl: message.mediaUrl),
      'file' => FileMessageWidget(
          mediaUrl: message.mediaUrl,
          fileName: message.fileName,
        ),
      'voice' => VoiceMessageWidget(
          mediaUrl: message.mediaUrl,
          durationSeconds: int.tryParse(message.text) ?? 0,
          isMe: isMe,
        ),
      'sticker' => Center(
          child: Text(
            message.text,
            style: const TextStyle(fontSize: 64),
          ),
        ),
      'gif' => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            message.mediaUrl,
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        ),
      _ => TextApp(
          text: message.text,
          theme: context.textStyle.copyWith(
            fontSize: 15.sp,
            color: context.color.onSurface,
          ),
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
