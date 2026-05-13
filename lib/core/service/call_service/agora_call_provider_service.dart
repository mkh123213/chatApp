import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:chat_material3/constants/agora_constants.dart';
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';

class AgoraCallProviderService implements CallProviderService {
  RtcEngine? _engine;

  @override
  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(const RtcEngineContext(
      appId: agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
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
  }
}
