import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/utils/app_regex.dart';
import 'package:chat_material3/features/auth/presentation/widgets/log_in/log_in_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({
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
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              SizedBox(height: 48.h),
              // Logo
              Container(
                width: 80.r,
                height: 80.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C54),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_tethering,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Welcome to EchoChat',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: context.color.onSurface,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                context.translate(LangKeys.signInToContinue),
                style: TextStyle(
                  fontSize: 14.sp,
                  color: context.color.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 32.h),

              // Google sign in
              OutlinedButton(
                onPressed: () {
                  context.read<AuthCubit>().signInWithGoogle();
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28.r),
                  ),
                  side: BorderSide(
                    color: context.color.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4285F4),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: context.color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // OR divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: context.color.outlineVariant),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: context.color.outlineVariant),
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              // Email label
              _buildLabel('Email'),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: widget.emailCon,
                hint: 'you@example.com',
                icon: Icons.email_outlined,
                validator: (v) {
                  if (!AppRegex.isEmailValid(v!)) {
                    return context.translate(LangKeys.invalidEmail);
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Password label
              _buildLabel('Password'),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: widget.passCon,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                validator: (v) {
                  if (!AppRegex.isPasswordValid(v!)) {
                    return context.translate(LangKeys.invalidPassword);
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              SizedBox(height: 24.h),

              // Sign in button
              LogInBlocConsumer(
                formKey: widget.formKey,
                emailCon: widget.emailCon,
                passCon: widget.passCon,
                authCubit: widget.authCubit,
              ),
              SizedBox(height: 16.h),

              // Forgot password
              GestureDetector(
                onTap: () => context.pushName(AppRoutes.forgetPassword),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Sign up link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Need an account? ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: context.color.onSurfaceVariant,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pushName(AppRoutes.signUp),
                    child: Text(
                      context.translate(LangKeys.signUp),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: context.color.onSurface,
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
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: context.color.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: context.color.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        prefixIcon: Icon(icon, size: 20.sp, color: context.color.onSurfaceVariant),
        suffixIcon: suffixIcon,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        filled: true,
        fillColor: context.color.surfaceContainerHigh.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.color.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.color.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.color.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
