import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:core_config/src/common/widgets/custom_linear_button.dart';
import 'package:core_config/src/common/widgets/text_app.dart';
import 'package:core_config/src/extensions/context_extension.dart';
import 'package:core_config/src/style/fonts/font_weight_helper.dart';
import 'package:core_config/src/style/images/app_images.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({required this.title, super.key, this.backButton = true});

  final String title;
  final bool backButton;
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: context.color.surface,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,

      leading: backButton
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomLinearButton(
                onPressed: () {
                  context.pop();
                },
                child: SvgPicture.asset(AppImages.backButton),
              ),
            )
          : null,
      title: TextApp(
        text: title,
        theme: context.textStyle.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeightHelper.bold,
          color: context.color.onSurface,
        ),
        // textOverflow: TextOverflow.ellipsis,
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, 70.h);
}
