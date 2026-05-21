import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/app/upload_image/cubit/upload_image_cubit.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/utils/app_regex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileScreenBody extends StatefulWidget {
  const EditProfileScreenBody({super.key});

  @override
  State<EditProfileScreenBody> createState() => _EditProfileScreenBodyState();
}

class _EditProfileScreenBodyState extends State<EditProfileScreenBody> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCon;
  late final TextEditingController _emailCon;
  late final TextEditingController _phoneCon;

  @override
  void initState() {
    super.initState();
    final user = getCurrentUser();
    _nameCon = TextEditingController(text: user.name ?? '');
    _emailCon = TextEditingController(text: user.email ?? '');
    _phoneCon = TextEditingController(text: user.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameCon.dispose();
    _emailCon.dispose();
    _phoneCon.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().updateUserProfile(
          name: _nameCon.text.trim(),
          email: _emailCon.text.trim(),
          phoneNumber: _phoneCon.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final user = getCurrentUser();
    final name = user.name ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              color: context.color.primary,
            ),
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.arrow_back,
                            color: Colors.white, size: 22.sp),
                      ),
                      Expanded(
                        child: Text(
                          context.translate(LangKeys.editProfileInfo),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.share_outlined,
                            color: Colors.white, size: 22.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                // Avatar
                GestureDetector(
                  onTap: () {
                    context.read<UploadImageCubit>().uploadImage();
                  },
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    backgroundImage:
                        user.photoUrl != null && user.photoUrl!.isNotEmpty
                            ? NetworkImage(user.photoUrl!)
                            : null,
                    child: user.photoUrl == null || user.photoUrl!.isEmpty
                        ? Text(
                            initial,
                            style: TextStyle(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.translate(LangKeys.changePicture),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      _buildLabel(
                          context, context.translate(LangKeys.username)),
                      SizedBox(height: 6.h),
                      _buildField(
                        controller: _nameCon,
                        hint: context.translate(LangKeys.name),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return context.translate(LangKeys.nameCannotBeEmpty);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildLabel(context, context.translate(LangKeys.emailId)),
                      SizedBox(height: 6.h),
                      _buildField(
                        controller: _emailCon,
                        hint: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return context
                                .translate(LangKeys.emailCannotBeEmpty);
                          }
                          if (!AppRegex.isEmailValid(v.trim())) {
                            return context.translate(LangKeys.invalidEmail);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildLabel(
                          context, context.translate(LangKeys.phoneNumber)),
                      SizedBox(height: 6.h),
                      _buildField(
                        controller: _phoneCon,
                        hint: context.translate(LangKeys.phone),
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v != null &&
                              v.isNotEmpty &&
                              !AppRegex.isPhoneValid(v)) {
                            return context
                                .translate(LangKeys.invalidPhoneNumber);
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),
                      _buildLabel(context, context.translate(LangKeys.password)),
                      SizedBox(height: 6.h),
                      _buildField(
                        hint: '••••••••',
                        readOnly: true,
                        onTap: () => Navigator.pushNamed(
                            context, 'security'),
                      ),
                      SizedBox(height: 32.h),
                      // Update button
                      BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          state.whenOrNull(
                            userUpdated: () => ShowToast.showToastSuccessTop(
                              message: context.translate(
                                  LangKeys.profileUpdatedSuccessfully),
                            ),
                            error: (message) =>
                                ShowToast.showToastErrorTop(message: message),
                          );
                        },
                        builder: (context, state) {
                          return state.maybeWhen(
                            loading: () => const Center(
                                child: CircularProgressIndicator()),
                            orElse: () => SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _updateProfile,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E1E2E),
                                  padding:
                                      EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                child: Text(
                                  context.translate(LangKeys.update),
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
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: context.color.onSurface,
      ),
    );
  }

  Widget _buildField({
    TextEditingController? controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      style: TextStyle(fontSize: 15.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 14.sp,
          color: context.color.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
