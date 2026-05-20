// REUSABLE SERVICE: Image picker with permission handling.
// REQUIRES: image_picker, permission_handler packages in pubspec.yaml
// CHANGE: Pass a BuildContext or NavigatorState to show the permission dialog.
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PickImageUtils {
  factory PickImageUtils() {
    return _instance;
  }
  const PickImageUtils._();

  static const PickImageUtils _instance = PickImageUtils._();

  // CHANGE: Pass a BuildContext so the permission dialog can be shown
  Future<XFile?> pickImage({BuildContext? context}) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        return XFile(image.path);
      }
      return null;
    } catch (e) {
      final permissionStatus = await Permission.photos.status;

      if (permissionStatus.isDenied && context != null && context.mounted) {
        await _showAlertPermissionsDialog(context);
      } else {
        debugPrint('Image Exception ==> $e');
      }
    }
    return null;
  }

  Future<void> _showAlertPermissionsDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: const Text('Permissions Denied'),
          content: const Text('Allow access to gallery and photos'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            const CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: openAppSettings,
              child: Text('Settings'),
            ),
          ],
        );
      },
    );
  }
}
