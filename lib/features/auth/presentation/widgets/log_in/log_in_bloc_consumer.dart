import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

            // context.pushReplacementName(AppRoutes.home);
          },
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          orElse: () => CustomLinearButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                authCubit.signInWithEmailAndPassword(
                  email: emailCon.text.trim(),
                  password: passCon.text,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextApp(
                text: context.translate(LangKeys.login),
                theme: context.textStyle,
              ),
            ),
          ),
        );
      },
    );
  }
}
