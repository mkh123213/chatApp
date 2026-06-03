import 'dart:async';

import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/call_service/agora_token_service.dart';
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:chat_material3/features/calls/data/repositories/calls_repo.dart';
import 'package:chat_material3/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/active_call_cubit/active_call_state.dart';
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

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  late final CallProviderService _callProvider;
  late final CallsRepo _callsRepo;
  late final ActiveCallCubit _activeCallCubit;
  StreamSubscription<int?>? _remoteUserSub;
  Timer? _missedCallTimer;
  bool _callEnded = false;
  bool _remoteUserJoined = false;
  CallModel? _latestCall;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _callProvider = sl<CallProviderService>();
    _callsRepo = sl<CallsRepo>();
    _activeCallCubit = sl<ActiveCallCubit>()
      ..listenToCall(callId: widget.call.id);
    _activeCallCubit.stream.listen((state) {
      if (state is ActiveCallActive) {
        _latestCall = state.call;
      }
    });
    _initializeCall();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.paused) {
      _endCallOnTermination();
    }
  }

  Future<void> _endCallOnTermination() async {
    if (_callEnded) return;
    _callEnded = true;

    final call = _latestCall ?? widget.call;
    if (call.status == CallStatus.ringing ||
        call.status == CallStatus.missed) {
      await _callsRepo.missCall(callId: call.id);
    } else if (call.status == CallStatus.accepted) {
      final duration = call.acceptedAt != null
          ? DateTime.now().difference(call.acceptedAt!).inSeconds
          : 0;
      await _callsRepo.endCall(callId: call.id, durationInSeconds: duration);
    }
  }

  Future<void> _initializeCall() async {
    final isVideo = widget.call.type == CallType.video;
    final permissions = <Permission>[
      Permission.microphone,
      Permission.bluetoothConnect,
    ];
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

    final uid = _stableUidHash(getCurrentUser().uid);
    final channelId = widget.call.channelId;
    final tokenService = AgoraTokenService();
    final token = await tokenService.generateToken(
      channelName: channelId,
      uid: uid,
    );

    await _callProvider.initialize();
    await _callProvider.joinChannel(
      channelId: channelId,
      token: token,
      uid: uid,
      isVideo: isVideo,
    );

    _listenForRemoteUserLeave();
    _startMissedCallTimerIfCaller();
  }

  void _listenForRemoteUserLeave() {
    _remoteUserSub = _callProvider.onRemoteUserChanged.listen((uid) {
      if (uid != null) {
        _remoteUserJoined = true;
      } else if (_remoteUserJoined && uid == null) {
        _endCallOnTermination();
        if (mounted) Navigator.of(context).pop();
      }
    });
  }

  void _startMissedCallTimerIfCaller() {
    final currentUserId = getCurrentUser().uid;
    if (widget.call.callerId == currentUserId &&
        widget.call.status == CallStatus.ringing) {
      _missedCallTimer = Timer(const Duration(seconds: 30), () {
        if (mounted) {
          _activeCallCubit.missCall(call: widget.call);
        }
      });
    }
  }

  // FNV-1a 32-bit hash — deterministic across all devices unlike String.hashCode
  static int _stableUidHash(String s) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < s.length; i++) {
      hash ^= s.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _remoteUserSub?.cancel();
    _missedCallTimer?.cancel();
    _endCallOnTermination();
    _callProvider.dispose();
    _activeCallCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _activeCallCubit,
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: CallBody(call: widget.call),
        ),
      ),
    );
  }
}
