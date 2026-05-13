import 'package:chat_material3/core/common/widgets/app_back_button.dart';
import 'package:flutter/material.dart';

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
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            const AppBackButton(),
            if (avatar != null) ...[
              const SizedBox(width: 8),
              avatar!,
            ],
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: onTitleTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
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
