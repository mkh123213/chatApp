import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:flutter/material.dart';

void showDisappearingMessagesDialog({
  required BuildContext context,
  required int? currentDuration,
  required void Function(int? durationInSeconds) onSelect,
}) {
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              context.translate(LangKeys.disappearingMessagesSetting),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RadioListTile<int?>(
            title: Text(context.translate(LangKeys.disappearingOff)),
            value: null,
            groupValue: currentDuration,
            onChanged: (v) {
              onSelect(null);
              Navigator.pop(sheetContext);
            },
          ),
          RadioListTile<int?>(
            title: Text(context.translate(LangKeys.disappearing24h)),
            value: 86400,
            groupValue: currentDuration,
            onChanged: (v) {
              onSelect(86400);
              Navigator.pop(sheetContext);
            },
          ),
          RadioListTile<int?>(
            title: Text(context.translate(LangKeys.disappearing7d)),
            value: 604800,
            groupValue: currentDuration,
            onChanged: (v) {
              onSelect(604800);
              Navigator.pop(sheetContext);
            },
          ),
          RadioListTile<int?>(
            title: Text(context.translate(LangKeys.disappearing30d)),
            value: 2592000,
            groupValue: currentDuration,
            onChanged: (v) {
              onSelect(2592000);
              Navigator.pop(sheetContext);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
