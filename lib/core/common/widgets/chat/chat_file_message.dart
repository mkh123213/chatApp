import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/helper_functions/open_file_url.dart';
import 'package:flutter/material.dart';

class ChatFileMessage extends StatelessWidget {
  const ChatFileMessage({
    super.key,
    required this.fileUrl,
    required this.fileName,
  });

  final String fileUrl;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        openFileUrl(fileUrl);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file, size: 32),
          const SizedBox(width: 8),
          Flexible(
            child: TextApp(
              text: fileName,
              theme: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    decoration: TextDecoration.underline,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
