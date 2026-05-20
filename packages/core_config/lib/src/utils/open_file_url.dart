import 'package:url_launcher/url_launcher.dart';

Future<void> openFileUrl(String fileUrl) async {
  final uri = Uri.tryParse(fileUrl);

  if (uri == null) {
    return;
  }

  final canOpen = await canLaunchUrl(uri);

  if (!canOpen) {
    return;
  }

  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}
