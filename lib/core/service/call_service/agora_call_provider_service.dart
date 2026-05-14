// REUSABLE SERVICE: Agora RTC implementation for voice/video calls.
// REQUIRES: agora_rtc_engine package in pubspec.yaml
// CHANGE: Update agora_constants import to your project's Agora App ID.
import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_material3/constants/agora_constants.dart'; // CHANGE: your Agora App ID
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';

class AgoraCallProviderService implements CallProviderService {
  RtcEngine? _engine;
  int? _remoteUid;
  final _remoteUidController = StreamController<int?>.broadcast();

  @override
  RtcEngine? get engine => _engine;

  @override
  int? get remoteUid => _remoteUid;

  @override
  Stream<int?> get onRemoteUserChanged => _remoteUidController.stream;

  @override
  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, remoteUid, elapsed) {
          _remoteUid = remoteUid;
          _remoteUidController.add(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          _remoteUid = null;
          _remoteUidController.add(null);
        },
      ),
    );
  }

  @override
  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool isVideo,
  }) async {
    final engine = _engine;
    if (engine == null) return;

    await engine.enableAudio();
    if (isVideo) {
      await engine.enableVideo();
      await engine.startPreview();
    }

    await engine.joinChannel(
      token: token,
      channelId: channelId,
      uid: uid,
      options: ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: isVideo,
        publishMicrophoneTrack: true,
        publishCameraTrack: isVideo,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  @override
  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  @override
  Future<void> toggleMute(bool muted) async {
    await _engine?.muteLocalAudioStream(muted);
  }

  @override
  Future<void> toggleSpeaker(bool speakerOn) async {
    await _engine?.setEnableSpeakerphone(speakerOn);
  }

  @override
  Future<void> toggleCamera(bool cameraOn) async {
    await _engine?.muteLocalVideoStream(!cameraOn);
  }

  @override
  Future<void> switchCamera() async {
    await _engine?.switchCamera();
  }

  @override
  Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
    _remoteUid = null;
    await _remoteUidController.close();
  }
}
