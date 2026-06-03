import 'package:chat_material3/core/common/widgets/app_back_button.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatAppBar extends StatelessWidget {
  const ChatAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.avatar,
    this.actions,
    this.onTitleTap,
  });

  final String title;
  final Widget? subtitle;
  final Widget? avatar;
  final List<Widget>? actions;
  final VoidCallback? onTitleTap;

  @override
  Widget build(BuildContext context) {
    final displayAvatar = avatar ?? _DefaultAvatar(name: title);

    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
        child: Row(
          children: [
            const AppBackButton(),
            SizedBox(width: 4.w),
            displayAvatar,
            SizedBox(width: 10.w),
            Expanded(
              child: GestureDetector(
                onTap: onTitleTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.lock_outline,
                          size: 14.sp,
                          color: context.color.onSurfaceVariant,
                        ),
                      ],
                    ),
                    if (subtitle != null) subtitle!,
                  ],
                ),
              ),
            ),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar({required this.name});

  final String name;

  static const List<Color> _colors = [
    Color(0xFF26A69A),
    Color(0xFF42A5F5),
    Color(0xFFEF5350),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
    Color(0xFF8D6E63),
  ];

  @override
  Widget build(BuildContext context) {
    final hash = name.codeUnits.fold<int>(0, (prev, c) => prev + c);
    final color = _colors[hash % _colors.length];
    final parts = name.split('@').first.split(RegExp(r'[._\-]'));
    String initials;
    if (parts.length >= 2) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      final n = parts.first;
      initials = n.length >= 2
          ? '${n[0]}${n[1]}'.toUpperCase()
          : n[0].toUpperCase();
    }

    return CircleAvatar(
      radius: 20.r,
      backgroundColor: color,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class ChatSelectedAppBar extends StatelessWidget {
  const ChatSelectedAppBar({
    super.key,
    required this.selectedCount,
    required this.onClose,
    this.onEdit,
    required this.onDelete,
  });

  final int selectedCount;
  final VoidCallback onClose;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
            Expanded(
              child: Text(
                '$selectedCount selected',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
