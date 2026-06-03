import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/utils/app_regex.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

class EditProfileForm extends StatefulWidget {
  const EditProfileForm({
    super.key,
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final TextEditingController emailController;
  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    final currentUser = getCurrentUser();

    emailController = TextEditingController(
      text: currentUser.email ?? '',
    );

    nameController = TextEditingController(
      text: currentUser.name ?? '',
    );

    phoneController = TextEditingController(
      text: currentUser.phoneNumber ?? '',
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (!widget.formKey.currentState!.validate()) return;

    context.read<AuthCubit>().updateUserProfile(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: phoneController.text.trim(),
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
                text: context.translate(LangKeys.editProfileInfo),
                theme: context.textStyle,
              ),
              highspace(height: 6),
              TextApp(
                text: context.translate(LangKeys.editProfileSubtitle),
                theme: context.textStyle,
              ),
              highspace(height: 24),
              CustomTextField(
                controller: nameController,
                hintText: context.translate(LangKeys.name),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.translate(LangKeys.nameCannotBeEmpty);
                  }
                  return null;
                },
              ),
              highspace(height: 24),
              CustomTextField(
                controller: emailController,
                hintText: context.translate(LangKeys.email),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.translate(LangKeys.emailCannotBeEmpty);
                  }
                  if (!AppRegex.isEmailValid(value.trim())) {
                    return context.translate(LangKeys.invalidEmail);
                  }
                  return null;
                },
              ),
              highspace(height: 24),
              CustomTextField(
                controller: phoneController,
                hintText: context.translate(LangKeys.phone),
                validator: (value) {
                  if (AppRegex.isPhoneValid(value ?? '')) {
                    return null;
                  } else {
                    return context.translate(LangKeys.invalidPhoneNumber);
                  }
                },
              ),
              highspace(height: 24),
              BlocConsumer<AuthCubit, AuthState>(
                listener: (context, state) {
                  // TODO: implement listener
                  state.whenOrNull(
                    userUpdated: () => ShowToast.showToastSuccessTop(
                      message: context
                          .translate(LangKeys.profileUpdatedSuccessfully),
                    ),
                    error: (message) =>
                        ShowToast.showToastErrorTop(message: message),
                  );
                },
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    orElse: () => CustomLinearButton(
                      onPressed: _updateProfile,
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
