import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({super.key, required this.user});

  final CurrentUserModel user;

  String _initials(CurrentUserModel u) {
    final name = u.name?.trim();
    if (name == null || name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (user.photoUrl != null)
            CircleAvatar(
                radius: 40.r, backgroundImage: NetworkImage(user.photoUrl!))
          else
            CircleAvatar(
              radius: 40.r,
              backgroundColor: context.color.primary.withOpacity(0.2),
              child: TextApp(
                text: _initials(user),
                theme: context.textStyle.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeightHelper.bold,
                ),
              ),
            ),
          SizedBox(height: 12.h),
          TextApp(
            text: user.name ?? user.uid,
            theme: context.textStyle
                .copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          highspace(height: 6.h),
          TextApp(
            text: user.email ?? '',
            theme: context.textStyle.copyWith(
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }
}
