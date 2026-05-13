import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showDeleteMessageDialog({
  required BuildContext context,
  required MessageModel message,
  required String chatId,
}) {
  final sendCubit = context.read<SendMessageCubit>();

  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        backgroundColor: context.color.surface,
        title: TextApp(
          text: context.translate(LangKeys.deleteMessage),
          theme: context.textStyle,
        ),
        content: TextApp(
          text: context.translate(LangKeys.removeMessagesConfirm),
          theme: Theme.of(context).textTheme.bodyMedium!,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: TextApp(
              text: context.translate(LangKeys.cancel),
              theme: context.textStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              sendCubit.deleteMessage(
                chatId: chatId,
                messageId: message.id,
                storagePath: message.storagePath,
              );
              Navigator.pop(context);
            },
            child: TextApp(
              text: context.translate(LangKeys.remove),
              theme: context.textStyle.copyWith(color: Colors.red),
            ),
          ),
        ],
      );
    },
  );
}
