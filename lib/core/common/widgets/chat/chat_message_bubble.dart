import 'package:chat_material3/core/common/widgets/chat/chat_file_message.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_image_message.dart';
import 'package:chat_material3/core/common/widgets/chat/message_read_status.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/voice_message_widget.dart';
import 'package:flutter/material.dart';

enum ChatMessageType { text, image, file, link, voice, sticker, gif }

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.text,
    required this.messageType,
    required this.isMe,
    required this.time,
    this.mediaUrl,
    this.fileName,
    this.isEdited = false,
    this.isSelected = false,
    this.senderLabel,
    this.senderInitial,
    this.senderLabelColor,
    this.onLongPress,
    this.onImageTap,
    this.onAvatarTap,
    this.selectedColor,
    this.sentBubbleColor,
    this.receivedBubbleColor,
    this.readStatus,
  });

  final String text;
  final ChatMessageType messageType;
  final bool isMe;
  final String time;
  final String? mediaUrl;
  final String? fileName;
  final bool isEdited;
  final bool isSelected;
  final String? senderLabel;
  final String? senderInitial;
  final Color? senderLabelColor;
  final VoidCallback? onLongPress;
  final VoidCallback? onImageTap;
  final VoidCallback? onAvatarTap;
  final Color? selectedColor;
  final Color? sentBubbleColor;
  final Color? receivedBubbleColor;
  final ReadStatus? readStatus;

  @override
  Widget build(BuildContext context) {
    final bubble = GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && senderInitial != null) ...[
                GestureDetector(
                  onTap: onAvatarTap,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: senderLabelColor?.withValues(alpha: 0.2) ??
                        const Color(0xFFD0DCF8),
                    child: Text(
                      senderInitial!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: senderLabelColor ?? const Color(0xFF1A2C6B),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                  ),
                  color: isMe
                      ? (sentBubbleColor ?? context.color.primaryFixed)
                      : (receivedBubbleColor ?? context.color.inputBorder),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe && senderLabel != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              senderLabel!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: senderLabelColor ??
                                    const Color(0xFF1A2C6B),
                              ),
                            ),
                          ),
                        _buildContent(context),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isEdited) ...[
                              TextApp(
                                text: context.translate(LangKeys.edited),
                                theme: context.textStyle,
                              ),
                              const SizedBox(width: 4),
                            ],
                            TextApp(
                              text: time,
                              theme: context.textStyle.copyWith(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (isMe && readStatus != null) ...[
                              const SizedBox(width: 4),
                              MessageReadStatus(
                                status: readStatus!,
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
            ],
          ),
        ),
      ),
    );

    if (isSelected) {
      return Container(
        color:
            (selectedColor ?? const Color(0xFF1A2C6B)).withValues(alpha: 0.12),
        child: bubble,
      );
    }

    return bubble;
  }

  Widget _buildContent(BuildContext context) {
    switch (messageType) {
      case ChatMessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatImageMessage(imageUrl: mediaUrl ?? '', onTap: onImageTap),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 6),
              TextApp(
                  text: text,
                  theme: context.textStyle.copyWith(
                      fontSize: 10, color: context.color.onTertiaryFixed)),
            ],
          ],
        );
      case ChatMessageType.file:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatFileMessage(fileUrl: mediaUrl ?? '', fileName: fileName ?? ''),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 6),
              TextApp(text: text, theme: context.textStyle),
            ],
          ],
        );
      case ChatMessageType.voice:
        return VoiceMessageWidget(
          mediaUrl: mediaUrl ?? '',
          durationSeconds: int.tryParse(text) ?? 0,
          isMe: isMe,
        );
      case ChatMessageType.sticker:
        return Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 64),
          ),
        );
      case ChatMessageType.gif:
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            mediaUrl ?? '',
            width: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
          ),
        );
      default:
        return TextApp(
            text: text,
            theme: context.textStyle.copyWith(
                fontSize: 14, height: 1, color: context.color.onTertiaryFixed));
    }
  }
}
