import 'dart:async';

import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  bool _isLoading = false;
  bool _canResend = true;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.emailVerified) {
        _timer?.cancel();
        if (mounted) {
          final nav = Navigator.of(context);
          final msg = context.translate(LangKeys.emailVerifiedSuccessfully);
          ShowToast.showToastSuccessTop(message: msg);
          nav.pushNamedAndRemoveUntil(
            AppRoutes.mainScreen,
            (route) => false,
          );
        }
      }
    });
  }

  Future<void> _sendVerificationEmail() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (_) {}
    setState(() {
      _isLoading = false;
      _canResend = false;
    });
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back, size: 18.sp),
                    label: Text(
                      'Back to sign in',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  context.translate(LangKeys.verifyYourEmail),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: context.color.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.translate(LangKeys.verificationEmailSentTo),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: context.color.onSurface,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  context.translate(LangKeys.checkEmailForVerification),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 32.h),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final nav = Navigator.of(context);
                        final verifiedMsg = context
                            .translate(LangKeys.emailVerifiedSuccessfully);
                        final notVerifiedMsg =
                            context.translate(LangKeys.emailNotVerifiedYet);
                        await FirebaseAuth.instance.currentUser?.reload();
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null && user.emailVerified) {
                          ShowToast.showToastSuccessTop(message: verifiedMsg);
                          nav.pushNamedAndRemoveUntil(
                            AppRoutes.mainScreen,
                            (route) => false,
                          );
                        } else {
                          ShowToast.showToastErrorTop(
                              message: notVerifiedMsg);
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
                        context.translate(LangKeys.verifyEmail),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Didn't receive the email? ",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: _canResend ? _sendVerificationEmail : null,
                      child: Text(
                        'Resend',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: _canResend
                              ? context.color.onSurface
                              : context.color.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
