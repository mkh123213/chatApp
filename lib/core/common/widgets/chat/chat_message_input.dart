import 'dart:async';
import 'dart:io';

import 'package:chat_material3/constants/giphy_constants.dart';
import 'package:chat_material3/core/common/widgets/chat/gif_picker_panel.dart';
import 'package:chat_material3/core/common/widgets/chat/sticker_picker_panel.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

typedef OnSendText = void Function(String text);
typedef OnPickImage = void Function(File imageFile, String caption);
typedef OnPickFile = void Function(File file, String fileName, String caption);
typedef OnShareLink = void Function(String link);
typedef OnSendVoice = void Function(File voiceFile, Duration duration);
typedef OnSendSticker = void Function(String sticker);
typedef OnSendGif = void Function(String gifUrl);

enum _InputPanel { none, emoji, sticker, gif }

class ChatMessageInput extends StatefulWidget {
  const ChatMessageInput({
    super.key,
    required this.onSendText,
    this.onPickImage,
    this.onPickFile,
    this.onShareLink,
    this.onSendVoice,
    this.onSendSticker,
    this.onSendGif,
    this.hintText,
    this.onTyping,
  });

  final OnSendText onSendText;
  final OnPickImage? onPickImage;
  final OnPickFile? onPickFile;
  final OnShareLink? onShareLink;
  final OnSendVoice? onSendVoice;
  final OnSendSticker? onSendSticker;
  final OnSendGif? onSendGif;
  final String? hintText;
  final VoidCallback? onTyping;

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _showAttachments = false;
  _InputPanel _activePanel = _InputPanel.none;

  // Voice recording state
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _recordTimer;
  String? _recordPath;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
      if (hasText) widget.onTyping?.call();
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _activePanel != _InputPanel.none) {
        setState(() => _activePanel = _InputPanel.none);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _recordTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSendText(text);
    _controller.clear();
  }

  void _toggleAttachments() {
    setState(() => _showAttachments = !_showAttachments);
  }

  void _togglePanel(_InputPanel panel) {
    if (_activePanel == panel) {
      setState(() => _activePanel = _InputPanel.none);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() {
        _activePanel = panel;
        _showAttachments = false;
      });
    }
  }

  // Voice recording methods
  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) return;

      final dir = await getTemporaryDirectory();
      _recordPath =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordPath!,
      );

      setState(() {
        _isRecording = true;
        _recordDuration = Duration.zero;
        _activePanel = _InputPanel.none;
      });

      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordDuration += const Duration(seconds: 1);
          });
        }
      });
    } catch (_) {}
  }

  Future<void> _stopRecordingAndSend() async {
    _recordTimer?.cancel();
    _recordTimer = null;

    try {
      final path = await _recorder.stop();
      final duration = _recordDuration;

      setState(() {
        _isRecording = false;
        _recordDuration = Duration.zero;
      });

      if (path != null && duration.inSeconds >= 1) {
        widget.onSendVoice?.call(File(path), duration);
      }
    } catch (_) {
      setState(() {
        _isRecording = false;
        _recordDuration = Duration.zero;
      });
    }
  }

  Future<void> _cancelRecording() async {
    _recordTimer?.cancel();
    _recordTimer = null;

    try {
      await _recorder.stop();
    } catch (_) {}

    if (_recordPath != null) {
      try {
        await File(_recordPath!).delete();
      } catch (_) {}
    }

    setState(() {
      _isRecording = false;
      _recordDuration = Duration.zero;
    });
  }

  String _formatRecordDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _pickImage() async {
    setState(() => _showAttachments = false);
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      _showCaptionSheet(
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
    setState(() => _showAttachments = false);
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
                    color: Theme.of(context).colorScheme.outlineVariant,
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
    setState(() => _showAttachments = false);
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showAttachments && _hasAttachments && !_isRecording)
            _AttachmentIconsRow(
              onPickImage: widget.onPickImage != null ? _pickImage : null,
              onPickFile: widget.onPickFile != null ? _pickFile : null,
              onShareLink:
                  widget.onShareLink != null ? _showLinkDialog : null,
              onSticker: widget.onSendSticker != null
                  ? () => _togglePanel(_InputPanel.sticker)
                  : null,
              onGif: widget.onSendGif != null
                  ? () => _togglePanel(_InputPanel.gif)
                  : null,
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            child: _isRecording
                ? _buildRecordingBar(context)
                : _buildInputBar(context, direction, isRtl),
          ),
          if (_activePanel == _InputPanel.emoji) _buildEmojiPicker(),
          if (_activePanel == _InputPanel.sticker)
            StickerPickerPanel(
              onStickerSelected: (sticker) {
                widget.onSendSticker?.call(sticker);
                setState(() => _activePanel = _InputPanel.none);
              },
            ),
          if (_activePanel == _InputPanel.gif)
            GifPickerPanel(
              giphyApiKey: GiphyConstants.apiKey,
              onGifSelected: (gifUrl) {
                widget.onSendGif?.call(gifUrl);
                setState(() => _activePanel = _InputPanel.none);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmojiPicker() {
    return SizedBox(
      height: 250.h,
      child: EmojiPicker(
        textEditingController: _controller,
        onBackspacePressed: () {
          _controller
            ..text = _controller.text.characters.skipLast(1).toString()
            ..selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            );
        },
        config: Config(
          height: 250.h,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.2
                    : 1.0),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: Theme.of(context).colorScheme.surface,
            indicatorColor: Theme.of(context).colorScheme.primary,
            iconColorSelected: Theme.of(context).colorScheme.primary,
          ),
          bottomActionBarConfig: const BottomActionBarConfig(enabled: false),
          searchViewConfig: SearchViewConfig(
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordingBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: _cancelRecording,
          icon: Icon(
            Icons.delete_outline,
            color: Colors.red,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: context.color.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  _formatRecordDuration(_recordDuration),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: context.color.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  'Recording...',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Material(
          color: context.color.primary,
          borderRadius: BorderRadius.circular(24.r),
          child: InkWell(
            onTap: _stopRecordingAndSend,
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: Icon(
                Icons.send_rounded,
                size: 22.sp,
                color: context.color.onPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(
      BuildContext context, TextDirection direction, bool isRtl) {
    return Row(
      textDirection: direction,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_hasAttachments)
          Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: IconButton(
              onPressed: _toggleAttachments,
              icon: Icon(
                _showAttachments ? Icons.close : Icons.attach_file,
                color: context.color.onSurfaceVariant,
                size: 24.sp,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 36.r, minHeight: 36.r),
            ),
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
                Padding(
                  padding: EdgeInsets.only(
                    left: isRtl ? 0 : 4.w,
                    right: isRtl ? 4.w : 0,
                    bottom: 4.h,
                  ),
                  child: IconButton(
                    onPressed: () => _togglePanel(_InputPanel.emoji),
                    icon: Icon(
                      _activePanel == _InputPanel.emoji
                          ? Icons.keyboard
                          : Icons.emoji_emotions_outlined,
                      color: _activePanel == _InputPanel.emoji
                          ? context.color.primary
                          : context.color.onSurfaceVariant,
                      size: 22.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints:
                        BoxConstraints(minWidth: 32.r, minHeight: 32.r),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: 5,
                    minLines: 1,
                    textDirection: direction,
                    textAlign: isRtl ? TextAlign.right : TextAlign.left,
                    textInputAction: TextInputAction.newline,
                    onTap: () {
                      if (_activePanel != _InputPanel.none) {
                        setState(() => _activePanel = _InputPanel.none);
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: widget.hintText ??
                          context.translate(LangKeys.enterMessage),
                      hintTextDirection: direction,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Material(
          color: context.color.primary,
          borderRadius: BorderRadius.circular(24.r),
          child: InkWell(
            onTap: _hasText ? _send : _startRecording,
            borderRadius: BorderRadius.circular(24.r),
            child: Padding(
              padding: EdgeInsets.all(12.r),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _hasText
                    ? Transform.rotate(
                        key: const ValueKey('send'),
                        angle: isRtl ? 3.14159 : 0,
                        child: Icon(
                          Icons.send_rounded,
                          size: 22.sp,
                          color: context.color.onPrimary,
                        ),
                      )
                    : Icon(
                        Icons.mic,
                        key: const ValueKey('mic'),
                        size: 22.sp,
                        color: context.color.onPrimary,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AttachmentIconsRow extends StatelessWidget {
  const _AttachmentIconsRow({
    this.onPickImage,
    this.onPickFile,
    this.onShareLink,
    this.onSticker,
    this.onGif,
  });

  final VoidCallback? onPickImage;
  final VoidCallback? onPickFile;
  final VoidCallback? onShareLink;
  final VoidCallback? onSticker;
  final VoidCallback? onGif;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: context.color.surface,
        border: Border(
          top: BorderSide(
            color: context.color.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (onPickImage != null)
            _AttachmentIcon(
              icon: Icons.photo_outlined,
              label: 'Photo',
              color: const Color(0xFFE91E63),
              backgroundColor: const Color(0xFFFCE4EC),
              onTap: onPickImage!,
            ),
          if (onPickFile != null)
            _AttachmentIcon(
              icon: Icons.description_outlined,
              label: 'Document',
              color: const Color(0xFF2196F3),
              backgroundColor: const Color(0xFFE3F2FD),
              onTap: onPickFile!,
            ),
          if (onSticker != null)
            _AttachmentIcon(
              icon: Icons.star_outline,
              label: 'Sticker',
              color: const Color(0xFFFF9800),
              backgroundColor: const Color(0xFFFFF3E0),
              onTap: onSticker!,
            ),
          if (onGif != null)
            _AttachmentIcon(
              icon: Icons.gif_box_outlined,
              label: 'GIF',
              color: const Color(0xFF9C27B0),
              backgroundColor: const Color(0xFFF3E5F5),
              onTap: onGif!,
            ),
        ],
      ),
    );
  }
}

class _AttachmentIcon extends StatelessWidget {
  const _AttachmentIcon({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 28.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: context.color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
