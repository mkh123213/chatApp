abstract class CallProviderService {
  Future<void> initialize();

  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool isVideo,
  });

  Future<void> leaveChannel();

  Future<void> toggleMute(bool muted);

  Future<void> toggleSpeaker(bool speakerOn);

  Future<void> toggleCamera(bool cameraOn);

  Future<void> switchCamera();

  Future<void> dispose();
}
