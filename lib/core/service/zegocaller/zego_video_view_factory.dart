// HELPER: Zego renders video into a platform "canvas view" (a Widget + viewID),
// unlike Agora's AgoraVideoView. Use these helpers when wiring CallScreen video.
// Returns the Widget to embed; null if the engine has no view to render yet.
import 'package:flutter/widgets.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class ZegoVideoViewFactory {
  ZegoVideoViewFactory._();

  /// Local camera preview. Call AFTER joinChannel() with isVideo: true.
  static Future<Widget?> createLocalView() async {
    return ZegoExpressEngine.instance.createCanvasView((viewID) {
      final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.startPreview(canvas: canvas);
    });
  }

  /// Remote participant view for a given stream id (from onRoomStreamUpdate).
  static Future<Widget?> createRemoteView(String remoteStreamId) async {
    return ZegoExpressEngine.instance.createCanvasView((viewID) {
      final canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance
          .startPlayingStream(remoteStreamId, canvas: canvas);
    });
  }
}
