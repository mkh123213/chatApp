import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/utils/app_regex.dart';
import 'package:chat_material3/features/auth/presentation/widgets/sign_up/sign_up_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    super.key,
    required this.formKey,
    required this.nameCon,
    required this.emailCon,
    required this.phoneCon,
    required this.passCon,
    required this.confirmPassCon,
    required this.authCubit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameCon;
  final TextEditingController emailCon;
  final TextEditingController phoneCon;
  final TextEditingController passCon;
  final TextEditingController confirmPassCon;
  final AuthCubit authCubit;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Form(
          key: widget.formKey,
          child: Column(
            children: [
              SizedBox(height: 8.h),

              // Back to sign in
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
              SizedBox(height: 8.h),

              Text(
                'Create your account',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: context.color.onSurface,
                ),
              ),
              SizedBox(height: 24.h),

              // Name
              _buildLabel(context.translate(LangKeys.name)),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: widget.nameCon,
                hint: context.translate(LangKeys.name),
                icon: Icons.person_outline,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.translate(LangKeys.nameCannotBeEmpty);
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Email
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

              // Phone
              _buildLabel(context.translate(LangKeys.phone)),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: widget.phoneCon,
                hint: context.translate(LangKeys.phone),
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.translate(LangKeys.phoneCannotBeEmpty);
                  }
                  if (!AppRegex.isPhoneValid(v)) {
                    return context.translate(LangKeys.invalidPhoneNumber);
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Password
              _buildLabel('Password'),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: widget.passCon,
                hint: 'Min. 8 characters',
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
              SizedBox(height: 16.h),

              // Confirm Password
              _buildLabel('Confirm Password'),
              SizedBox(height: 6.h),
              _buildTextField(
                controller: widget.confirmPassCon,
                hint: 'Re-enter password',
                icon: Icons.lock_outline,
                obscure: _obscureConfirm,
                validator: (v) {
                  if (v != widget.passCon.text) {
                    return context.translate(LangKeys.passwordsDoNotMatch);
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              SizedBox(height: 24.h),

              // Create account button
              SignUpBlocConsumer(
                formKey: widget.formKey,
                nameCon: widget.nameCon,
                emailCon: widget.emailCon,
                phoneCon: widget.phoneCon,
                passCon: widget.passCon,
                authCubit: widget.authCubit,
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
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      keyboardType: keyboardType,
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
