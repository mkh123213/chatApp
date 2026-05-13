import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/utils/app_regex.dart';
import 'package:chat_material3/features/auth/presentation/widgets/log_in/log_in_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

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
  bool isPasswordVisible = false;
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
                text: context.translate(LangKeys.welcomeBack),
                theme: Theme.of(context).textTheme.headlineLarge!,
              ),
              TextApp(
                text: context.translate(LangKeys.materialChatApp),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              CustomTextField(
                validator: (p0) {
                  if (!AppRegex.isEmailValid(p0!)) {
                    return context.translate(LangKeys.invalidEmail);
                  }
                  return null;
                },
                controller: widget.emailCon,
                hintText: context.translate(LangKeys.email),
                prefixIcon: Icon(Iconsax.direct),
              ),
              CustomTextField(
                validator: (p0) {
                  if (!AppRegex.isPasswordValid(p0!)) {
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
                    child: Icon(Iconsax.password_check)),
                obscureText: isPasswordVisible,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      context.pushName(AppRoutes.forgetPassword);
                    },
                    child: TextApp(
                      text: context.translate(LangKeys.forgetPassword),
                      theme: context.textStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LogInBlocConsumer(
                formKey: widget.formKey,
                emailCon: widget.emailCon,
                passCon: widget.passCon,
                authCubit: widget.authCubit,
              ),
              highspace(height: 16),
              CustomLinearButton(
                onPressed: () {
                  context.pushName(AppRoutes.signUp);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextApp(
                    text: context.translate(LangKeys.signUp),
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
