import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/status/presentation/bloc/create_status_cubit/create_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/create_status_bloc_consumer.dart';
import 'package:chat_material3/features/status/presentation/widgets/text_status_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TextStatusScreen extends StatelessWidget {
  const TextStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateStatusCubit>(),
      child: CreateStatusBlocListener(
        onSuccess: () => Navigator.of(context).pop(),
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.translate(LangKeys.statusAddText)),
          ),
          body: const TextStatusForm(),
        ),
      ),
    );
  }
}
