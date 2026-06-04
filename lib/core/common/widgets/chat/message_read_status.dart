import 'package:flutter/material.dart';

enum ReadStatus { sent, delivered, read }

class MessageReadStatus extends StatelessWidget {
  const MessageReadStatus({
    super.key,
    required this.status,
    this.size = 16,
    this.readColor = const Color(0xFF4FC3F7),
    this.unreadColor = const Color(0xFF8895A7),
  });

  final ReadStatus status;
  final double size;
  final Color readColor;
  final Color unreadColor;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      ReadStatus.sent => Icon(
          Icons.done,
          size: size,
          color: unreadColor,
        ),
      ReadStatus.delivered => Icon(
          Icons.done_all,
          size: size,
          color: unreadColor,
        ),
      ReadStatus.read => Icon(
          Icons.done_all,
          size: size,
          color: readColor,
        ),
    };
  }
}
