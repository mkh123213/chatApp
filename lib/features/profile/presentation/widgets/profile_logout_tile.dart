import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileLogoutTile extends StatelessWidget {
  const ProfileLogoutTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isLoading,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: Colors.red),
      title: TextApp(text: title, theme: context.textStyle.copyWith(color: Colors.red)),
      subtitle: TextApp(
        text: subtitle,
        theme: context.textStyle.copyWith(fontSize: 12.sp, color: Colors.red.shade300),
      ),
      trailing: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
      onTap: isLoading ? null : onTap,
    );
  }
}
