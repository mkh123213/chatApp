import 'package:intl/intl.dart';

extension StringFormate on String {
  /// Strips surrounding `["..."]`-style wrappers from a stored image string.
  String imageProductFormate() {
    return replaceAll(RegExp(r'^\["?|"\]?|"$'), '');
  }

  /// Capitalizes the first character. Safe on empty strings.
  String toCapitalized() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of every whitespace-separated word.
  String toTitleCase() {
    if (trim().isEmpty) return this;
    return split(RegExp(r'\s+'))
        .map((word) => word.toCapitalized())
        .join(' ');
  }

  /// Drops the last whitespace-separated token. Safe when there is no space.
  String convertLongString() {
    final parts = split(' ');
    if (parts.length <= 1) return this;
    return parts.sublist(0, parts.length - 1).join(' ');
  }

  /// Parses this string as a date and formats it as `d MMM, y - h:mm a`.
  /// Falls back to the current time if the string is not a valid date.
  String convertDataFormate() {
    final parsed = DateTime.tryParse(this) ?? DateTime.now();
    return DateFormat('d MMM, y - h:mm a').format(parsed);
  }

  /// True when the string is a structurally valid email address.
  bool get isValidEmail =>
      RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(trim());

  /// True when the string has no non-whitespace characters.
  bool get isBlank => trim().isEmpty;

  /// First character upper-cased, or `?` when empty — handy for avatars.
  String get initial => isEmpty ? '?' : this[0].toUpperCase();
}
