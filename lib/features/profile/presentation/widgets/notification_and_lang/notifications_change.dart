import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart' show LangKeys;
import 'package:chat_material3/core/service/push_notification/firebase_cloud_messaging.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsChange extends StatelessWidget {
  const NotificationsChange({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.notifications_active,
          color: context.color.onSurface,
        ),
        SizedBox(width: 10.w),
        TextApp(
          text: context.translate(LangKeys.notifications),
          theme: context.textStyle.copyWith(
            fontSize: 18.sp,
            fontWeight: FontWeightHelper.regular,
          ),
        ),
        const Spacer(),

        // radio buttons
        ValueListenableBuilder(
          valueListenable: FirebaseCloudMessaging().isNotificationSubscribe,
          builder: (_, value, __) {
            return Transform.scale(
              scale: 0.75,
              child: Switch.adaptive(
                value: value,
                inactiveTrackColor: context.color.surfaceContainerHighest,
                activeColor: Colors.green,
                onChanged: (value) {
                  FirebaseCloudMessaging().controllerForUserSubscribe(context);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
