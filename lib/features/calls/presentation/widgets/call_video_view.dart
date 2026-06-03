import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';
import 'package:flutter/material.dart';

class CallVideoView extends StatefulWidget {
  const CallVideoView({super.key, required this.channelId});

  final String channelId;

  @override
  State<CallVideoView> createState() => _CallVideoViewState();
}

class _CallVideoViewState extends State<CallVideoView> {
  late final CallProviderService _callProvider;
  StreamSubscription<int?>? _remoteUidSub;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    _callProvider = sl<CallProviderService>();
    _remoteUid = _callProvider.remoteUid;
    _remoteUidSub = _callProvider.onRemoteUserChanged.listen((uid) {
      if (mounted) setState(() => _remoteUid = uid);
    });
  }

  @override
  void dispose() {
    _remoteUidSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = _callProvider.engine as RtcEngine?;
    if (engine == null) return const SizedBox.shrink();

    return Stack(
      children: [
        _remoteUid != null
            ? AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: engine,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(
                    channelId: widget.channelId,
                  ),
                ),
              )
            : const Center(
                child: Text(
                  'Waiting for other user...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
        Positioned(
          top: 16,
          right: 16,
          width: 120,
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(uid: 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
