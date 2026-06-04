import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusSectionHeader extends StatelessWidget {
  const StatusSectionHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, top: 16.h, bottom: 8.h),
      child: TextApp(
        text: title.toUpperCase(),
        theme: context.textStyle.copyWith(
          fontSize: 12.sp,
          fontWeight: FontWeightHelper.semiBold,
          color: context.color.onSurface,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
