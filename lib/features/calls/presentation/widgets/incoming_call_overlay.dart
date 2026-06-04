import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/presentation/widgets/incoming_call_dialog.dart';
import 'package:flutter/material.dart';

class IncomingCallOverlay {
  IncomingCallOverlay._();

  static bool _isDialogShowing = false;

  static void show(BuildContext context, CallModel call) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => IncomingCallDialog(call: call),
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  static void dismiss(BuildContext context) {
    if (_isDialogShowing) {
      Navigator.of(context).pop();
      _isDialogShowing = false;
    }
  }

  static bool get isShowing => _isDialogShowing;
}
