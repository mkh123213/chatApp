// REUSABLE SERVICE: ZegoCloud (Zego Express Engine) implementation for voice/video calls.
// REQUIRES: zego_express_engine package in pubspec.yaml.
// DROP-IN: Implements the same CallProviderService contract as AgoraCallProviderService,
//          so it can replace Agora in the DI container without touching the Cubit/UI logic.
// AUTH: Uses AppSign auth by default (token left empty). Pass a token to joinChannel
//       only if you switch the Zego project to "Token authentication" mode.
import 'dart:async';

import 'package:chat_material3/core/service/call_service/call_provider_service.dart';
import 'package:chat_material3/core/service/zegocaller/zego_constants.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoCallProviderService implements CallProviderService {
  bool _engineCreated = false;
  bool _isFrontCamera = true;

  String? _roomId;
  String? _localUserId;
  String? _localStreamId;
  String? _remoteStreamId;

  int? _remoteUid;
  StreamController<int?> _remoteUidController =
      StreamController<int?>.broadcast();

  @override
  dynamic get engine => _engineCreated ? ZegoExpressEngine.instance : null;

  @override
  int? get remoteUid => _remoteUid;

  @override
  Stream<int?> get onRemoteUserChanged => _remoteUidController.stream;

  @override
  Future<void> initialize() async {
    if (_remoteUidController.isClosed) {
      _remoteUidController = StreamController<int?>.broadcast();
    }
    _remoteUid = null;
    _remoteStreamId = null;

    if (_engineCreated) return;

    final profile = ZegoEngineProfile(
      zegoAppId,
      ZegoScenario.StandardVideoCall,
      appSign: zegoAppSign,
    );
    await ZegoExpressEngine.createEngineWithProfile(profile);
    _engineCreated = true;

    _registerEventHandlers();
  }

  void _registerEventHandlers() {
    // Fired when remote streams are added/removed in the room.
    ZegoExpressEngine.onRoomStreamUpdate =
        (roomID, updateType, streamList, extendedData) {
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          _remoteStreamId = stream.streamID;
          _remoteUid = int.tryParse(stream.user.userID);
          // Subscribe to the remote audio (and video if present).
          ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
          _remoteUidController.add(_remoteUid);
        }
      } else if (updateType == ZegoUpdateType.Delete) {
        for (final stream in streamList) {
          if (stream.streamID == _remoteStreamId) {
            ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
            _remoteStreamId = null;
            _remoteUid = null;
            _remoteUidController.add(null);
          }
        }
      }
    };
  }

  @override
  Future<void> joinChannel({
    required String channelId,
    required String token,
    required int uid,
    required bool isVideo,
  }) async {
    if (!_engineCreated) return;

    _roomId = channelId;
    _localUserId = uid.toString();
    _localStreamId = '${channelId}_${uid}_main';

    final roomConfig = ZegoRoomConfig.defaultConfig()
      ..isUserStatusNotify = true;
    // AppSign auth -> token stays empty. Token auth -> forward the passed token.
    if (token.isNotEmpty) {
      roomConfig.token = token;
    }

    await ZegoExpressEngine.instance.loginRoom(
      channelId,
      ZegoUser(_localUserId!, _localUserId!),
      config: roomConfig,
    );

    if (isVideo) {
      await ZegoExpressEngine.instance.enableCamera(true);
    }
    await ZegoExpressEngine.instance.muteMicrophone(false);

    await ZegoExpressEngine.instance.startPublishingStream(_localStreamId!);
  }

  @override
  Future<void> leaveChannel() async {
    if (!_engineCreated) return;
    if (_localStreamId != null) {
      await ZegoExpressEngine.instance.stopPublishingStream();
    }
    if (_remoteStreamId != null) {
      await ZegoExpressEngine.instance.stopPlayingStream(_remoteStreamId!);
    }
    if (_roomId != null) {
      await ZegoExpressEngine.instance.logoutRoom(_roomId!);
    }
    _roomId = null;
    _localStreamId = null;
    _remoteStreamId = null;
    _remoteUid = null;
  }

  @override
  Future<void> toggleMute(bool muted) async {
    await ZegoExpressEngine.instance.muteMicrophone(muted);
  }

  @override
  Future<void> toggleSpeaker(bool speakerOn) async {
    await ZegoExpressEngine.instance.setAudioRouteToSpeaker(speakerOn);
  }

  @override
  Future<void> toggleCamera(bool cameraOn) async {
    await ZegoExpressEngine.instance.enableCamera(cameraOn);
  }

  @override
  Future<void> switchCamera() async {
    _isFrontCamera = !_isFrontCamera;
    await ZegoExpressEngine.instance.useFrontCamera(_isFrontCamera);
  }

  @override
  Future<void> dispose() async {
    await leaveChannel();
    if (_engineCreated) {
      await ZegoExpressEngine.destroyEngine();
      _engineCreated = false;
    }
    _remoteUid = null;
    if (!_remoteUidController.isClosed) {
      await _remoteUidController.close();
    }
  }
}
