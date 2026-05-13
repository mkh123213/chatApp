import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/utils/app_regex.dart';
import 'package:chat_material3/features/auth/presentation/widgets/sign_up/sign_up_bloc_consumer.dart';
import 'package:chat_material3/features/groups/presentation/widgets/user_avatar_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

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
              Center(child: const UserAvararImage()),
              const SizedBox(height: 20),
              TextApp(
                text: context.translate(LangKeys.createAccount),
                theme: Theme.of(context).textTheme.headlineLarge!,
              ),
              TextApp(
                text: context.translate(LangKeys.materialChatApp),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              CustomTextField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.translate(LangKeys.nameCannotBeEmpty);
                  }
                  return null;
                },
                controller: widget.nameCon,
                hintText: context.translate(LangKeys.name),
                prefixIcon: Icon(Iconsax.user),
              ),
              CustomTextField(
                validator: (value) {
                  if (!AppRegex.isEmailValid(value!)) {
                    return context.translate(LangKeys.invalidEmail);
                  }
                  return null;
                },
                controller: widget.emailCon,
                hintText: context.translate(LangKeys.email),
                prefixIcon: Icon(Iconsax.direct),
              ),
              CustomTextField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.translate(LangKeys.phoneCannotBeEmpty);
                  }
                  if (!AppRegex.isPhoneValid(value)) {
                    return context.translate(LangKeys.invalidPhoneNumber);
                  }
                  return null;
                },
                controller: widget.phoneCon,
                hintText: context.translate(LangKeys.phone),
                prefixIcon: Icon(Iconsax.call),
              ),
              CustomTextField(
                validator: (value) {
                  if (!AppRegex.isPasswordValid(value!)) {
                    return context.translate(LangKeys.invalidPassword);
                  }
                  return null;
                },
                controller: widget.passCon,
                hintText: context.translate(LangKeys.password),
                prefixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                  child: Icon(Iconsax.password_check),
                ),
                obscureText: isPasswordVisible,
              ),
              CustomTextField(
                validator: (value) {
                  if (value != widget.passCon.text) {
                    return context.translate(LangKeys.passwordsDoNotMatch);
                  }
                  return null;
                },
                controller: widget.confirmPassCon,
                hintText: context.translate(LangKeys.confirmPassword),
                prefixIcon: InkWell(
                  onTap: () {
                    setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    });
                  },
                  child: Icon(Iconsax.password_check),
                ),
                obscureText: isConfirmPasswordVisible,
              ),
              const SizedBox(height: 16),
              SignUpBlocConsumer(
                formKey: widget.formKey,
                nameCon: widget.nameCon,
                emailCon: widget.emailCon,
                phoneCon: widget.phoneCon,
                passCon: widget.passCon,
                authCubit: widget.authCubit,
              ),
              highspace(height: 16),
              CustomLinearButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextApp(
                    text: context.translate(LangKeys.alreadyHaveAccount),
                    theme: context.textStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
