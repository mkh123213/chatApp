import 'dart:io';

import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

typedef OnSendText = void Function(String text);
typedef OnPickImage = void Function(File imageFile, String caption);
typedef OnPickFile = void Function(File file, String fileName, String caption);
typedef OnShareLink = void Function(String link);

class ChatMessageInput extends StatefulWidget {
  const ChatMessageInput({
    super.key,
    required this.onSendText,
    this.onPickImage,
    this.onPickFile,
    this.onShareLink,
    this.hintText,
  });

  final OnSendText onSendText;
  final OnPickImage? onPickImage;
  final OnPickFile? onPickFile;
  final OnShareLink? onShareLink;
  final String? hintText;

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 12.h),
            if (widget.onPickImage != null)
              ListTile(
                leading: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.image_outlined,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(context.translate(LangKeys.attachImage)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            if (widget.onPickFile != null)
              ListTile(
                leading: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.insert_drive_file_outlined,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                title: Text(context.translate(LangKeys.attachFile)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFile();
                },
              ),
            if (widget.onShareLink != null)
              ListTile(
                leading: Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.link,
                      color: Theme.of(context).colorScheme.tertiary),
                ),
                title: Text(context.translate(LangKeys.shareLink)),
                onTap: () {
                  Navigator.pop(context);
                  _showLinkDialog();
                },
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      _showCaptionSheet(
        imageFile: File(picked.path),
        previewWidget: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(picked.path),
            height: 180.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        onSend: (caption) =>
            widget.onPickImage?.call(File(picked.path), caption),
      );
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null && mounted) {
      final file = result.files.single;
      _showCaptionSheet(
        previewWidget: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.insert_drive_file_outlined,
                  color: Theme.of(context).colorScheme.secondary, size: 28.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                file.name,
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        onSend: (caption) =>
            widget.onPickFile?.call(File(file.path!), file.name, caption),
      );
    }
  }

  void _showCaptionSheet({
    File? imageFile,
    required Widget previewWidget,
    required void Function(String caption) onSend,
  }) {
    final captionController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                previewWidget,
                SizedBox(height: 16.h),
                TextField(
                  controller: captionController,
                  maxLines: 3,
                  minLines: 1,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: context.translate(LangKeys.enterMessage),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 12.h),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      final caption = captionController.text.trim();
                      onSend(caption);
                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(Icons.send),
                    label: Text(context.translate(LangKeys.send)),
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        captionController.dispose();
      });
    });
  }

  void _showLinkDialog() {
    final linkController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.translate(LangKeys.shareLink)),
        content: TextField(
          controller: linkController,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://example.com'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.translate(LangKeys.cancel)),
          ),
          TextButton(
            onPressed: () {
              final link = linkController.text.trim();
              if (link.isEmpty) return;
              widget.onShareLink?.call(link);
              Navigator.pop(dialogContext);
            },
            child: Text(context.translate(LangKeys.send)),
          ),
        ],
      ),
    ).then((_) => linkController.dispose());
  }

  bool get _hasAttachments =>
      widget.onPickImage != null ||
      widget.onPickFile != null ||
      widget.onShareLink != null;

  @override
  Widget build(BuildContext context) {
    final TextDirection direction = Directionality.of(context);
    final bool isRtl = direction == TextDirection.rtl;

    return Directionality(
      textDirection: direction,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          textDirection: direction,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_hasAttachments)
              IconButton(
                onPressed: _showAttachmentSheet,
                icon: Icon(
                  Icons.add,
                  color: context.color.onSurface,
                  size: 26.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 36.r, minHeight: 36.r),
              ),
            SizedBox(width: 4.w),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        maxLines: 5,
                        minLines: 1,
                        textDirection: direction,
                        textAlign: isRtl ? TextAlign.right : TextAlign.left,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: widget.hintText ??
                              context.translate(LangKeys.enterMessage),
                          hintTextDirection: direction,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 4.w, bottom: 4.h),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.emoji_emotions_outlined,
                          color: context.color.onSurfaceVariant,
                          size: 22.sp,
                        ),
                        padding: EdgeInsets.zero,
                        constraints:
                            BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Material(
              color: _hasText
                  ? context.color.primary
                  : context.color.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                onTap: _hasText ? _send : null,
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Transform.rotate(
                    angle: isRtl ? 3.14159 : 0,
                    child: Icon(
                      Icons.send_rounded,
                      size: 22.sp,
                      color: _hasText
                          ? context.color.onPrimary
                          : context.color.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
