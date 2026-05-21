import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogInBlocConsumer extends StatelessWidget {
  const LogInBlocConsumer({
    super.key,
    required this.formKey,
    required this.emailCon,
    required this.passCon,
    required this.authCubit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCon;
  final TextEditingController passCon;
  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          error: (message) {
            ShowToast.showToastErrorTop(message: message);
          },
          authenticated: () {
            context.pushName(AppRoutes.mainScreen);
            ShowToast.showToastSuccessTop(
              message: context.translate(LangKeys.loggedInSuccessfully),
            );
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Center(child: CircularProgressIndicator()),
          orElse: () => SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  authCubit.signInWithEmailAndPassword(
                    email: emailCon.text.trim(),
                    password: passCon.text,
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1E1E2E),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
