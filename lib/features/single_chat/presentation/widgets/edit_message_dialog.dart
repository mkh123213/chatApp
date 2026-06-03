import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

void showEditMessageDialog({
  required BuildContext context,
  required MessageModel message,
  required String chatId,
}) {
  final sendCubit = context.read<SendMessageCubit>();

  showDialog(
    context: context,
    builder: (_) {
      return _EditMessageDialogContent(
        message: message,
        chatId: chatId,
        sendCubit: sendCubit,
      );
    },
  );
}

class _EditMessageDialogContent extends StatefulWidget {
  const _EditMessageDialogContent({
    required this.message,
    required this.chatId,
    required this.sendCubit,
  });

  final MessageModel message;
  final String chatId;
  final SendMessageCubit sendCubit;

  @override
  State<_EditMessageDialogContent> createState() =>
      _EditMessageDialogContentState();
}

class _EditMessageDialogContentState extends State<_EditMessageDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.message.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.color.surface,
      title: TextApp(
        text: context.translate(LangKeys.editMessage),
        theme: context.textStyle,
      ),
      content: CustomTextField(
        controller: _controller,
        hintText: context.translate(LangKeys.enterMessage),
        prefixIcon: const Icon(Iconsax.edit),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: TextApp(
            text: context.translate(LangKeys.cancel),
            theme: context.textStyle,
          ),
        ),
        CustomLinearButton(
          onPressed: () {
            final newText = _controller.text.trim();
            if (newText.isNotEmpty && newText != widget.message.text) {
              widget.sendCubit.updateMessage(
                chatId: widget.chatId,
                messageId: widget.message.id,
                text: newText,
              );
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextApp(
              text: context.translate(LangKeys.updateMessage),
              theme: context.textStyle,
            ),
          ),
        ),
      ],
    );
  }
}
