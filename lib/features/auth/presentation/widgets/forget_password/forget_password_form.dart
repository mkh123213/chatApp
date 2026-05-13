import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/utils/app_regex.dart';
import 'package:chat_material3/features/auth/presentation/widgets/forget_password/forget_password_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ForgetPasswordForm extends StatelessWidget {
  const ForgetPasswordForm({
    super.key,
    required this.formKey,
    required this.emailCon,
    required this.authCubit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCon;
  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const LogoApp(),
              const SizedBox(height: 20),
              TextApp(
                text: context.translate(LangKeys.resetPassword),
                theme: Theme.of(context).textTheme.headlineLarge!,
              ),
              TextApp(
                text: context.translate(LangKeys.pleaseEnterYourEmail),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              CustomTextField(
                validator: (p0) {
                  if (!AppRegex.isEmailValid(p0!)) {
                    return context.translate(LangKeys.invalidEmail);
                  }
                  return null;
                },
                controller: emailCon,
                hintText: context.translate(LangKeys.email),
                prefixIcon: Icon(Iconsax.direct),
              ),
              const SizedBox(height: 16),
              ForgetPasswordBlocConsumer(
                formKey: formKey,
                emailCon: emailCon,
                authCubit: authCubit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
