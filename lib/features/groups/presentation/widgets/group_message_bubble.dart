import 'package:chat_material3/core/common/widgets/chat/message_read_status.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class GroupMessageBubble extends StatelessWidget {
  const GroupMessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.onLongPress,
    required this.isSelected,
    this.totalMembers = 0,
  });

  final GroupMessageModel message;
  final String currentUserId;
  final VoidCallback onLongPress;
  final bool isSelected;
  final int totalMembers;

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == currentUserId;
    final time = message.createdAt != null
        ? DateFormat('h:mm a').format(message.createdAt!)
        : '';
    final initial = message.senderEmail.isNotEmpty
        ? message.senderEmail[0].toUpperCase()
        : '?';

    Widget bubble;
    if (isMe) {
      bubble = _SentBubble(
        message: message,
        time: time,
        onLongPress: onLongPress,
        totalMembers: totalMembers,
      );
    } else {
      bubble = _ReceivedBubble(
        message: message,
        time: time,
        initial: initial,
        onLongPress: onLongPress,
      );
    }

    if (isSelected) {
      return Container(
        color: context.color.primary.withValues(alpha: 0.12),
        child: bubble,
      );
    }
    return bubble;
  }
}

// ---------- content builder ----------

Widget _buildContent(BuildContext context, GroupMessageModel message) {
  if (message.type == GroupMessageType.image &&
      message.fileUrl != null &&
      message.fileUrl!.isNotEmpty) {
    return GestureDetector(
      onTap: () => _openImageViewer(context, message.fileUrl!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.r),
        child: Image.network(
          message.fileUrl!,
          width: 200.w,
          height: 200.h,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : SizedBox(
                  width: 200.w,
                  height: 200.h,
                  child: const Center(child: CircularProgressIndicator()),
                ),
          errorBuilder: (_, __, ___) => SizedBox(
            width: 200.w,
            height: 200.h,
            child: const Center(child: Icon(Icons.broken_image, size: 48)),
          ),
        ),
      ),
    );
  }

  final displayText = message.text.isNotEmpty
      ? message.text
      : (message.fileUrl ?? message.fileName ?? '');

  return TextApp(
    text: displayText,
    theme: context.textStyle,
  );
}

void _openImageViewer(BuildContext context, String url) {
  Navigator.push<void>(
    context,
    MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 64),
            ),
          ),
        ),
      ),
    ),
  );
}

// ---------- sent ----------

class _SentBubble extends StatelessWidget {
  const _SentBubble({
    required this.message,
    required this.time,
    required this.onLongPress,
    required this.totalMembers,
  });

  final GroupMessageModel message;
  final String time;
  final VoidCallback onLongPress;
  final int totalMembers;

  @override
  Widget build(BuildContext context) {
    final isImage = message.type == GroupMessageType.image;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding:
            EdgeInsets.only(left: 60.w, right: 14.w, top: 4.h, bottom: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: isImage
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: isImage
                    ? Colors.transparent
                    : context.color.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                  bottomRight: Radius.circular(4.r),
                ),
              ),
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.color.onPrimary,
                  height: 1.4,
                ),
                child: _buildContent(context, message),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                      fontSize: 10.sp, color: context.color.onSurfaceVariant),
                ),
                SizedBox(width: 4.w),
                MessageReadStatus(
                  status: message.readBy.length >= totalMembers - 1 &&
                          totalMembers > 1
                      ? ReadStatus.read
                      : ReadStatus.delivered,
                  size: 14.sp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- received ----------

class _ReceivedBubble extends StatelessWidget {
  const _ReceivedBubble({
    required this.message,
    required this.time,
    required this.initial,
    required this.onLongPress,
  });

  final GroupMessageModel message;
  final String time;
  final String initial;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isImage = message.type == GroupMessageType.image;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding:
            EdgeInsets.only(left: 14.w, right: 60.w, top: 4.h, bottom: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: context.color.secondaryContainer,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: context.color.primary,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.senderEmail,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: context.color.primary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Container(
                    padding: isImage
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: isImage
                          ? Colors.transparent
                          : context.color.surfaceVariant,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.r),
                        topRight: Radius.circular(16.r),
                        bottomLeft: Radius.circular(16.r),
                        bottomRight: Radius.circular(16.r),
                      ),
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.color.onSurface,
                        height: 1.4,
                      ),
                      child: _buildContent(context, message),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    time,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: context.color.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
