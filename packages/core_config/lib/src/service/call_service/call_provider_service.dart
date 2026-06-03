// REUSABLE SERVICE: Abstract call provider interface. Works with any VoIP SDK.
// CHANGE: Add/remove methods to match your call features.
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

  dynamic get engine;

  int? get remoteUid;

  Stream<int?> get onRemoteUserChanged;

  Future<void> dispose();
}
