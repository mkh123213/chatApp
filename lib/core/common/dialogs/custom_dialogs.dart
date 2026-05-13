import 'package:chat_material3/core/common/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chat_material3/core/common/widgets/custom_button.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/style/fonts/font_family_helper.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';

class CustomDialog {
  const CustomDialog._();

  static void twoButtonDialog({
    required BuildContext context,
    required String textBody,
    required String textButton1,
    required String textButton2,
    required void Function() onPressed,
    required bool isLoading,
  }) {
    showDialog<dynamic>(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.color.surface,
        title: Padding(
          padding: EdgeInsets.only(top: 30.h, bottom: 20.h),
          child: Column(
            children: [
              const Row(children: [AppBackButton()]),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextApp(
                    text: textBody,
                    theme: context.textStyle.copyWith(
                      fontWeight: FontWeightHelper.medium,
                      fontFamily: FontFamilyHelper.poppinsEnglish,
                      fontSize: 18.sp,
                      // color: Colors.black,
                    ),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            backgroundColor: context.color.tertiary,
            onPressed: onPressed,
            text: textButton1,
            isLoading: isLoading,
            lastRadius: 10,
            threeRadius: 10,
          ),
          SizedBox(height: 10.h, width: 1.w),
          CustomButton(
            backgroundColor: context.color.onTertiary,
            onPressed: () {
              context.pop();
            },
            text: textButton2,
            width: 320.w,
            height: 45.h,
            lastRadius: 10,
            threeRadius: 10,
          ),
        ],
      ),
    );
  }
}
