import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileMessageWidget extends StatelessWidget {
  const FileMessageWidget({
    super.key,
    required this.mediaUrl,
    required this.fileName,
  });

  final String mediaUrl;
  final String fileName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.tryParse(mediaUrl);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
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
