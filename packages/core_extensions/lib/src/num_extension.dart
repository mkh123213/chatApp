import 'package:flutter/widgets.dart';

extension SpacingExt on num {
  /// Vertical gap — `16.vGap` instead of `SizedBox(height: 16)`.
  SizedBox get vGap => SizedBox(height: toDouble());

  /// Horizontal gap — `8.hGap` instead of `SizedBox(width: 8)`.
  SizedBox get hGap => SizedBox(width: toDouble());

  /// Square box of this size.
  SizedBox get box => SizedBox.square(dimension: toDouble());

  /// Uniform EdgeInsets — `12.paddingAll`.
  EdgeInsets get paddingAll => EdgeInsets.all(toDouble());

  /// Symmetric horizontal padding.
  EdgeInsets get paddingH => EdgeInsets.symmetric(horizontal: toDouble());

  /// Symmetric vertical padding.
  EdgeInsets get paddingV => EdgeInsets.symmetric(vertical: toDouble());

  /// Uniform BorderRadius — `12.radius`.
  BorderRadius get radius => BorderRadius.circular(toDouble());
}
