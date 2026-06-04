import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_viewer_body.dart';
import 'package:flutter/material.dart';

class StatusViewerScreen extends StatelessWidget {
  const StatusViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments
        as Map<String, dynamic>;
    final statuses = List<StatusModel>.from(args['statuses'] as List);
    final initialIndex = (args['initialIndex'] as int?) ?? 0;
    final isOwn = (args['isOwn'] as bool?) ?? false;

    return StatusViewerBody(
      statuses: statuses,
      initialIndex: initialIndex,
      isOwn: isOwn,
    );
  }
}
