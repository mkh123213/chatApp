import 'dart:io';

import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

void showAttachmentBottomSheet({
  required BuildContext context,
  required ChatModel chat,
}) {
  final sendCubit = context.read<SendMessageCubit>();

  showModalBottomSheet(
    context: context,
    builder: (bottomSheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: TextApp(
                text: context.translate(LangKeys.attachImage),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                final picker = ImagePicker();
                final xFile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (xFile != null) {
                  sendCubit.sendImageMessage(
                    chat: chat,
                    imageFile: File(xFile.path),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: TextApp(
                text: context.translate(LangKeys.attachFile),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              onTap: () async {
                Navigator.pop(bottomSheetContext);
                final result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  final fileName = result.files.single.name;
                  sendCubit.sendFileMessage(
                    chat: chat,
                    file: file,
                    originalFileName: fileName,
                  );
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
