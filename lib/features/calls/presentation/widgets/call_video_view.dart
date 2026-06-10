import 'dart:async';

import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';
import 'package:chat_material3/core/service/zegocaller/zego_video_view_factory.dart';
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
  Widget? _localView;
  Widget? _remoteView;

  @override
  void initState() {
    super.initState();
    _callProvider = sl<CallProviderService>();
    _remoteUid = _callProvider.remoteUid;
    _setupLocalView();
    if (_remoteUid != null) _setupRemoteView(_remoteUid!);
    _remoteUidSub = _callProvider.onRemoteUserChanged.listen(_onRemoteChanged);
  }

  Future<void> _setupLocalView() async {
    final view = await ZegoVideoViewFactory.createLocalView();
    if (mounted) setState(() => _localView = view);
  }

  void _onRemoteChanged(int? uid) {
    if (!mounted) return;
    setState(() => _remoteUid = uid);
    if (uid != null) {
      _setupRemoteView(uid);
    } else {
      setState(() => _remoteView = null);
    }
  }

  Future<void> _setupRemoteView(int uid) async {
    // Remote stream id mirrors the publisher format used in ZegoCallProviderService.
    final streamId = '${widget.channelId}_${uid}_main';
    final view = await ZegoVideoViewFactory.createRemoteView(streamId);
    if (mounted) setState(() => _remoteView = view);
  }

  @override
  void dispose() {
    _remoteUidSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _remoteView ??
              const Center(
                child: Text(
                  'Waiting for other user...',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
        ),
        Positioned(
          top: 16,
          right: 16,
          width: 120,
          height: 160,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _localView ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
