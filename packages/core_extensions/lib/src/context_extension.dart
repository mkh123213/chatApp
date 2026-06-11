import 'package:flutter/material.dart';

/// Theme-agnostic [BuildContext] helpers. These intentionally avoid app
/// specific theme/localization types so the package stays reusable.
extension MediaQueryExt on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// True while the soft keyboard is visible.
  bool get isKeyboardOpen => MediaQuery.viewInsetsOf(this).bottom > 0;

  Orientation get orientation => MediaQuery.orientationOf(this);
  bool get isPortrait => orientation == Orientation.portrait;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Dismisses the keyboard by unfocusing the current node.
  void hideKeyboard() => FocusScope.of(this).unfocus();
}
