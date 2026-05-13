import 'dart:async';

import 'package:chat_material3/constants/agora_constants.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:chat_material3/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/refactor/call_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.call});

  final CallModel call;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final CallProviderService _callProvider;
  Timer? _missedCallTimer;

  @override
  void initState() {
    super.initState();
    _callProvider = sl<CallProviderService>();
    _initializeCall();
  }

  Future<void> _initializeCall() async {
    final isVideo = widget.call.type == CallType.video;
    final permissions = <Permission>[Permission.microphone];
    if (isVideo) permissions.add(Permission.camera);

    final statuses = await permissions.request();
    final micGranted = statuses[Permission.microphone]?.isGranted ?? false;
    final cameraGranted =
        !isVideo || (statuses[Permission.camera]?.isGranted ?? false);

    if (!micGranted || !cameraGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone and camera permissions are required'),
          ),
        );
        Navigator.of(context).pop();
      }
      return;
    }

    await _callProvider.initialize();
    await _callProvider.joinChannel(
      channelId: widget.call.channelId,
      token: agoraToken,
      uid: getCurrentUser().uid.hashCode,
      isVideo: isVideo,
    );

    _startMissedCallTimerIfCaller();
  }

  void _startMissedCallTimerIfCaller() {
    final currentUserId = getCurrentUser().uid;
    if (widget.call.callerId == currentUserId &&
        widget.call.status == CallStatus.ringing) {
      _missedCallTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          context.read<ActiveCallCubit>().missCall(call: widget.call);
        }
      });
    }
  }

  @override
  void dispose() {
    _missedCallTimer?.cancel();
    _callProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ActiveCallCubit>()..listenToCall(callId: widget.call.id),
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: CallBody(call: widget.call),
        ),
      ),
    );
  }
}
