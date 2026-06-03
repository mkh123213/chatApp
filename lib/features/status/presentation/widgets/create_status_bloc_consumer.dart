import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/status/presentation/bloc/create_status_cubit/create_status_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateStatusBlocListener extends StatelessWidget {
  const CreateStatusBlocListener({
    required this.child,
    this.onSuccess,
    super.key,
  });

  final Widget child;
  final VoidCallback? onSuccess;

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateStatusCubit, CreateStatusState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (_) {
            ShowToast.showToastSuccessTop(
              message: context.translate(LangKeys.statusCreated),
            );
            onSuccess?.call();
          },
          error: (message) =>
              ShowToast.showToastErrorTop(message: message),
          orElse: () {},
        );
      },
      child: child,
    );
  }
}

class CreateStatusProgressOverlay extends StatelessWidget {
  const CreateStatusProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateStatusCubit, CreateStatusState>(
      builder: (context, state) {
        return state.maybeWhen(
          uploadingImage: () => _ProgressBanner(
            label: context.translate(LangKeys.statusUploading),
          ),
          savingDoc: () => _ProgressBanner(
            label: context.translate(LangKeys.statusSaving),
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}

class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black54,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16.w,
            height: 16.w,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 8.w),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
