// REUSABLE WIDGET: Empty state placeholder.
// CHANGE: Update the image asset path to your project's empty screen image.
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:core_config/src/common/widgets/text_app.dart';
import 'package:core_config/src/extensions/context_extension.dart';
import 'package:core_config/src/style/fonts/font_weight_helper.dart';

class EmptyScreen extends StatelessWidget {
  const EmptyScreen({
    super.key,
    this.title = 'No Data',
    this.imagePath, // CHANGE: pass your empty screen image asset path
  });

  final String? title;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Opacity(
        opacity: 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) Image.asset(imagePath!),
            TextApp(
              text: title!,
              theme: context.textStyle.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeightHelper.medium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
