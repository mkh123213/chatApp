import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StickerPickerPanel extends StatelessWidget {
  const StickerPickerPanel({super.key, required this.onStickerSelected});

  final void Function(String sticker) onStickerSelected;

  static const _stickers = [
    '😀', '😂', '🥹', '😍', '🥰', '😘', '😎', '🤩',
    '🥳', '😇', '🤗', '🤔', '😏', '😢', '😭', '😡',
    '🤯', '😱', '🥶', '🤮', '👻', '💀', '🤖', '👽',
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '💔',
    '💯', '🔥', '⭐', '🌈', '☀️', '🌙', '⚡', '💧',
    '👍', '👎', '👏', '🙌', '🤝', '✌️', '🤞', '💪',
    '🎉', '🎊', '🎂', '🎁', '🏆', '🎯', '🚀', '💎',
    '🐶', '🐱', '🐻', '🐼', '🦊', '🐸', '🐵', '🦁',
    '🌹', '🌺', '🌸', '🌻', '🌷', '🍀', '🌿', '🍃',
    '☕', '🍕', '🍔', '🍟', '🎵', '🎶', '💤', '✨',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250.h,
      child: GridView.builder(
        padding: EdgeInsets.all(8.r),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          mainAxisSpacing: 4.r,
          crossAxisSpacing: 4.r,
        ),
        itemCount: _stickers.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () => onStickerSelected(_stickers[index]),
          child: Center(
            child: Text(_stickers[index], style: TextStyle(fontSize: 28.sp)),
          ),
        ),
      ),
    );
  }
}
