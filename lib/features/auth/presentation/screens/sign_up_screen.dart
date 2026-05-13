import 'package:chat_material3/core/app/auth_cubit/auth_cubit.dart';
import 'package:chat_material3/core/app/upload_image/cubit/upload_image_cubit.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/features/auth/presentation/widgets/sign_up/sign_up_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameCon = TextEditingController();
  final emailCon = TextEditingController();
  final phoneCon = TextEditingController();
  final passCon = TextEditingController();
  final confirmPassCon = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameCon.dispose();
    emailCon.dispose();
    phoneCon.dispose();
    passCon.dispose();
    confirmPassCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();

    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (context) => sl<UploadImageCubit>(),
        child: SignUpForm(
          formKey: formKey,
          nameCon: nameCon,
          emailCon: emailCon,
          phoneCon: phoneCon,
          passCon: passCon,
          confirmPassCon: confirmPassCon,
          authCubit: authCubit,
        ),
      ),
    );
  }
}
