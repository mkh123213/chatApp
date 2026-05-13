import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateChatBlocConsumer extends StatelessWidget {
  const CreateChatBlocConsumer({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateChatCubit, CreateChatState>(
      builder: (context, state) {
        if (state is CreateChatLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomLinearButton(
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextApp(
              text: context.translate(LangKeys.createChat),
              theme: context.textStyle,
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state is CreateChatSuccess) {
          Navigator.pop(context);
          ShowToast.showToastSuccessTop(
            message: context.translate(LangKeys.chatCreatedSuccessfully),
          );
        } else if (state is CreateChatError) {
          ShowToast.showToastErrorTop(message: state.message);
        }
      },
    );
  }
}
