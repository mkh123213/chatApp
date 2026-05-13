import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  late final TextEditingController oldPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();

    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() {
    if (!widget.formKey.currentState!.validate()) return;

    final oldPassword = oldPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      ShowToast.showToastErrorTop(
        message: context.translate(LangKeys.pleaseEnterYourPassword),
      );
      return;
    }

    if (newPassword.length < 6) {
      ShowToast.showToastErrorTop(
        message: context.translate(LangKeys.passwordTooShort),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ShowToast.showToastErrorTop(
        message: context.translate(LangKeys.passwordsDoNotMatch),
      );
      return;
    }

    context.read<AuthCubit>().updateUserPasswordWithOldPassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextApp(
                text: context.translate(LangKeys.changePassword),
                theme: Theme.of(context).textTheme.headlineLarge!,
              ),
              TextApp(
                text: context.translate(LangKeys.changePasswordSubtitle),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              highspace(height: 24),
              CustomTextField(
                controller: oldPasswordController,
                hintText: context.translate(LangKeys.oldPassword),
                prefixIcon: Icon(
                  Iconsax.lock,
                ),
                obscureText: true,
              ),
              CustomTextField(
                controller: newPasswordController,
                hintText: context.translate(LangKeys.newPassword),
                prefixIcon: Icon(Iconsax.password_check),
                obscureText: true,
              ),
              CustomTextField(
                controller: confirmPasswordController,
                hintText: context.translate(LangKeys.confirmPassword),
                prefixIcon: Icon(Iconsax.password_check),
                obscureText: true,
              ),
              highspace(height: 24),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  state.whenOrNull(
                    passwordUpdated: () {
                      ShowToast.showToastSuccessTop(
                        message: context.translate(
                          LangKeys.passwordUpdatedSuccessfully,
                        ),
                      );

                      Navigator.pop(context);
                    },
                    error: (message) {
                      ShowToast.showToastErrorTop(message: message);
                    },
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    orElse: () => CustomLinearButton(
                      onPressed: _changePassword,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextApp(
                          text: context.translate(LangKeys.saveChanges),
                          theme: context.textStyle,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
