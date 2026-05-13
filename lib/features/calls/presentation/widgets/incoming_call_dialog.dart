import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:chat_material3/features/calls/data/repositories/calls_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IncomingCallDialog extends StatelessWidget {
  const IncomingCallDialog({super.key, required this.call});

  final CallModel call;

  @override
  Widget build(BuildContext context) {
    final callTypeKey =
        call.type == CallType.video ? LangKeys.videoCall : LangKeys.audioCall;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40.r,
              backgroundImage: call.callerPhotoUrl != null
                  ? NetworkImage(call.callerPhotoUrl!)
                  : null,
              child: call.callerPhotoUrl == null
                  ? Icon(Icons.person, size: 40.r)
                  : null,
            ),
            SizedBox(height: 12.h),
            TextApp(
              text: call.callerName,
              theme: context.textStyle.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            TextApp(
              text: call.callerEmail,
              theme: context.textStyle.copyWith(
                fontSize: 13.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8.h),
            TextApp(
              text: context.translate(callTypeKey),
              theme: context.textStyle.copyWith(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context: context,
                  icon: Icons.call_end,
                  color: Colors.red,
                  label: context.translate(LangKeys.rejectCall),
                  onTap: () => _rejectCall(context),
                ),
                _buildActionButton(
                  context: context,
                  icon: Icons.call,
                  color: Colors.green,
                  label: context.translate(LangKeys.acceptCall),
                  onTap: () => _acceptCall(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 28.r, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.all(12.r),
          ),
        ),
        SizedBox(height: 4.h),
        TextApp(
          text: label,
          theme: context.textStyle.copyWith(
            fontSize: 12.sp,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Future<void> _acceptCall(BuildContext context) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    await sl<CallsRepo>().acceptCall(callId: call.id);
    navigator.pushNamed(AppRoutes.callScreen, arguments: call);
  }

  Future<void> _rejectCall(BuildContext context) async {
    Navigator.of(context).pop();
    await sl<CallsRepo>().rejectCall(callId: call.id);
  }
}
