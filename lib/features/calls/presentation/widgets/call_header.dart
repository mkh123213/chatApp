import 'dart:async';

import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallHeader extends StatefulWidget {
  const CallHeader({super.key, required this.call});

  final CallModel call;

  @override
  State<CallHeader> createState() => _CallHeaderState();
}

class _CallHeaderState extends State<CallHeader> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CallHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.call.status != widget.call.status) {
      _startTimerIfNeeded();
    }
  }

  void _startTimerIfNeeded() {
    if (widget.call.status == CallStatus.accepted && _timer == null) {
      if (widget.call.acceptedAt != null) {
        _seconds = DateTime.now().difference(widget.call.acceptedAt!).inSeconds;
      }
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() => _seconds++);
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getStatusText(BuildContext context) {
    switch (widget.call.status) {
      case CallStatus.ringing:
        return context.translate(LangKeys.ringing);
      case CallStatus.accepted:
        return context.translate(LangKeys.connected);
      case CallStatus.ended:
        return context.translate(LangKeys.callEnded);
      case CallStatus.rejected:
        return context.translate(LangKeys.callRejected);
      case CallStatus.missed:
        return context.translate(LangKeys.callMissed);
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = getCurrentUser().uid;
    final isCurrentUserCaller = widget.call.callerId == currentUserId;
    final friendName =
        isCurrentUserCaller ? widget.call.receiverName : widget.call.callerName;
    final friendPhoto = isCurrentUserCaller
        ? widget.call.receiverPhotoUrl
        : widget.call.callerPhotoUrl;
    final callTypeKey = widget.call.type == CallType.video
        ? LangKeys.videoCall
        : LangKeys.audioCall;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 60.h),
        CircleAvatar(
          radius: 50.r,
          backgroundImage:
              friendPhoto != null ? NetworkImage(friendPhoto) : null,
          child: friendPhoto == null
              ? Icon(Icons.person, size: 50.r)
              : null,
        ),
        SizedBox(height: 16.h),
        TextApp(
          text: friendName,
          theme: context.textStyle.copyWith(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextApp(
          text: context.translate(callTypeKey),
          theme: context.textStyle.copyWith(
            fontSize: 14.sp,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 8.h),
        TextApp(
          text: _getStatusText(context),
          theme: context.textStyle.copyWith(
            fontSize: 16.sp,
            color: widget.call.status == CallStatus.accepted
                ? Colors.green
                : null,
          ),
        ),
        if (widget.call.status == CallStatus.accepted) ...[
          SizedBox(height: 8.h),
          TextApp(
            text: _formatDuration(_seconds),
            theme: context.textStyle.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
