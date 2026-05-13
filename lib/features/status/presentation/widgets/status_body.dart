import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/status/presentation/widgets/create_status_bottom_sheet.dart';
import 'package:chat_material3/features/status/presentation/widgets/my_status_card.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBody extends StatelessWidget {
  const StatusBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MyStatusCard(),
            SizedBox(height: 8.h),
            const StatusBlocConsumer(),
          ],
        ),
      ),
      floatingActionButton: _CameraFab(
        onPressed: () => showCreateStatusSheet(context),
      ),
    );
  }
}

class _CameraFab extends StatelessWidget {
  const _CameraFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      height: 60.w,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: context.color.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child:
            Icon(Icons.camera_alt_outlined, color: Colors.white, size: 26.sp),
      ),
    );
  }
}
