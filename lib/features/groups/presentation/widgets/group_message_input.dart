import 'dart:io';

import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class GroupMessageInput extends StatefulWidget {
  const GroupMessageInput({
    super.key,
    required this.group,
    required this.currentUserId,
    required this.currentUserEmail,
  });

  final GroupModel group;
  final String currentUserId;
  final String currentUserEmail;

  @override
  State<GroupMessageInput> createState() => _GroupMessageInputState();
}

class _GroupMessageInputState extends State<GroupMessageInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<SelectedGroupChatCubit>().sendGroupMessage(
          groupId: widget.group.id,
          senderId: widget.currentUserId,
          senderEmail: widget.currentUserEmail,
          text: text,
        );

    _controller.clear();
  }

  final ImagePicker _imagePicker = ImagePicker();

  void _showAttachmentSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Image'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text('File'),
              onTap: () {
                Navigator.pop(context);
                _pickAndSendFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Link'),
              onTap: () {
                Navigator.pop(context);
                _showLinkDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    if (!mounted) return;

    await context.read<SelectedGroupChatCubit>().sendImageMessage(
          groupId: widget.group.id,
          senderId: widget.currentUserId,
          senderEmail: widget.currentUserEmail,
          imageFile: File(picked.path),
        );
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.single.path == null) return;

    final picked = result.files.single;

    if (!mounted) return;

    await context.read<SelectedGroupChatCubit>().sendFileMessage(
          groupId: widget.group.id,
          senderId: widget.currentUserId,
          senderEmail: widget.currentUserEmail,
          file: File(picked.path!),
          fileName: picked.name,
        );
  }

  void _showLinkDialog() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Share link'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final link = controller.text.trim();
              if (link.isEmpty) return;

              context.read<SelectedGroupChatCubit>().sendLinkMessage(
                    groupId: widget.group.id,
                    senderId: widget.currentUserId,
                    senderEmail: widget.currentUserEmail,
                    link: link,
                  );

              Navigator.pop(dialogContext);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.color.surface,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.add, color: context.color.primary, size: 24.sp),
            onPressed: _showAttachmentSheet,
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: context.color.hint,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 8.h,
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: context.color.onSurface,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: context.color.onSurfaceVariant,
              size: 22.sp,
            ),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: _send,
            child: Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(
                color: context.color.primary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.send,
                color: context.color.onPrimary,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentItem extends StatelessWidget {
  const _AttachmentItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: context.color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  icon,
                  color: context.color.primary,
                  size: 24.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: context.color.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
