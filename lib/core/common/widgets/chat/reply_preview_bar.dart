import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReplyPreviewBar extends StatelessWidget {
  const ReplyPreviewBar({
    super.key,
    required this.senderName,
    required this.text,
    required this.onCancel,
    this.type,
  });

  final String senderName;
  final String text;
  final VoidCallback onCancel;
  final String? type;

  @override
  Widget build(BuildContext context) {
    final displayText = switch (type) {
      'image' => 'Image',
      'file' => 'File',
      'voice' => 'Voice message',
      'sticker' => 'Sticker',
      'gif' => 'GIF',
      _ => text,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerHigh,
        border: Border(
          left: const BorderSide(
            color: Color(0xFF4CAF50),
            width: 3,
          ),
          top: BorderSide(
            color: context.color.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.reply, size: 18.sp, color: const Color(0xFF4CAF50)),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: Icon(Icons.close, size: 18.sp),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32.r, minHeight: 32.r),
          ),
        ],
      ),
    );
  }
}
