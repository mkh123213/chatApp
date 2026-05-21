import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/features/auth/presentation/widgets/forget_password/forget_password_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final emailCon = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return Scaffold(
      body: SafeArea(
        child: ForgetPasswordForm(
          formKey: formKey,
          emailCon: emailCon,
          authCubit: authCubit,
        ),
      ),
    );
  }
}
