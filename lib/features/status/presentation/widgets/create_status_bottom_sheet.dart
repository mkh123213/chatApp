import 'dart:io';

import 'package:chat_material3/core/common/bottom_shet/custom_bottom_sheet.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/status/presentation/bloc/create_status_cubit/create_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/create_status_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

void showCreateStatusSheet(BuildContext context) {
  CustomBottomSheet.showModalBottomSheetContainer(
    context: context,
    widget: BlocProvider(
      create: (_) => sl<CreateStatusCubit>(),
      child: const _CreateStatusSheetBody(),
    ),
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    // ),
  );
}

class _CreateStatusSheetBody extends StatelessWidget {
  const _CreateStatusSheetBody();

  @override
  Widget build(BuildContext context) {
    return CreateStatusBlocListener(
      onSuccess: () => Navigator.of(context).pop(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 4.h),
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: context.color.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _OptionButton(
              label: context.translate(LangKeys.statusAddImage),
              icon: Icons.image_outlined,
              onPressed: () => _pickImage(context),
            ),
            SizedBox(height: 12.h),
            _OptionButton(
              label: context.translate(LangKeys.statusAddText),
              icon: Icons.text_fields_outlined,
              onPressed: () {
                Navigator.of(context).pop();
                context.pushName(AppRoutes.textStatus);
              },
            ),
            SizedBox(height: 24.h),
            const CreateStatusProgressOverlay(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _pickFromSource(context, ImageSource.gallery);
            },
            child: Text(context.translate(LangKeys.statusFromGallery)),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _pickFromSource(context, ImageSource.camera);
            },
            child: Text(context.translate(LangKeys.statusFromCamera)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromSource(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;
      if (context.mounted) {
        context.read<CreateStatusCubit>().createImageStatus(File(picked.path));
      }
    } catch (e) {
      if (context.mounted) {
        ShowToast.showToastErrorTop(
          message: context.translate(LangKeys.statusPermissionDenied),
        );
      }
    }
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CustomLinearButton(
      onPressed: onPressed,
      height: 52.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20.sp),
          SizedBox(width: 8.w),
          TextApp(
            text: label,
            theme: context.textStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeightHelper.medium,
              fontSize: 15.sp,
            ),
          ),
        ],
      ),
    );
  }
}
