import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:flutter/material.dart';

void showChatMessageActions({
  required BuildContext context,
  required bool canEdit,
  VoidCallback? onEdit,
  VoidCallback? onDelete,
}) {
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canEdit && onEdit != null)
            ListTile(
              leading: const Icon(Icons.edit),
              title: TextApp(
                text: context.translate(LangKeys.editMessage),
                theme: Theme.of(context).textTheme.bodyLarge!,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                onEdit();
              },
            ),
          if (onDelete != null)
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: TextApp(
                text: context.translate(LangKeys.deleteMessage),
                theme: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.red,
                    ),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                onDelete();
              },
            ),
        ],
      ),
    ),
  );
}

void showChatEditMessageDialog({
  required BuildContext context,
  required String currentText,
  required ValueChanged<String> onSave,
}) {
  final controller = TextEditingController(text: currentText);

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: TextApp(
        text: context.translate(LangKeys.editMessage),
        theme: Theme.of(context).textTheme.titleMedium!,
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 4,
        minLines: 1,
        decoration: InputDecoration(
          hintText: context.translate(LangKeys.enterMessage),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: TextApp(
            text: context.translate(LangKeys.cancel),
            theme: Theme.of(context).textTheme.bodyMedium!,
          ),
        ),
        TextButton(
          onPressed: () {
            final newText = controller.text.trim();
            if (newText.isNotEmpty && newText != currentText) {
              onSave(newText);
              Navigator.pop(dialogContext);
            }
          },
          child: TextApp(
            text: context.translate(LangKeys.save),
            theme: Theme.of(context).textTheme.bodyMedium!,
          ),
        ),
      ],
    ),
  ).then((_) => controller.dispose());
}

void showChatDeleteMessageDialog({
  required BuildContext context,
  required VoidCallback onDelete,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: TextApp(
        text: context.translate(LangKeys.deleteMessage),
        theme: Theme.of(context).textTheme.titleMedium!,
      ),
      content: TextApp(
        text: context.translate(LangKeys.removeMessagesConfirm),
        theme: Theme.of(context).textTheme.bodyMedium!,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: TextApp(
            text: context.translate(LangKeys.cancel),
            theme: Theme.of(context).textTheme.bodyMedium!,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onDelete();
          },
          child: TextApp(
            text: context.translate(LangKeys.remove),
            theme: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.red,
                ),
          ),
        ),
      ],
    ),
  );
}
