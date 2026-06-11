// Documentation way: high-level call invitations via zego_uikit_prebuilt_call.
// Docs: https://www.zegocloud.com/docs/uikit/callkit-flutter/quick-start-(with-call-invitation)
//
// Call [onUserLogin] right after the user is authenticated (and on app start
// if a session already exists), and [onUserLogout] on sign-out.
import 'package:flutter/foundation.dart';
import 'package:chat_material3/core/service/env/env_variable.dart';
import 'package:chat_material3/core/service/call_service/zego_call_history_recorder.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

/// resourceID created in the ZEGOCLOUD console for offline call invitations.
/// Keep this string in sync with the console and with every
/// [ZegoSendCallInvitationButton] in the app.
const String kZegoCallResourceID = 'zego_call';

class ZegoCallInvitationService {
  ZegoCallInvitationService._();
  static final ZegoCallInvitationService instance = ZegoCallInvitationService._();

  bool _initialized = false;

  /// Initializes the prebuilt call-invitation service for the signed-in user.
  /// Safe to call multiple times — it no-ops if already initialized.
  Future<void> onUserLogin({
    required String userId,
    required String userName,
  }) async {
    if (_initialized || userId.isEmpty) return;

    if (EnvVariable.instance.zegoAppId == 0 ||
        EnvVariable.instance.zegoAppSign.isEmpty) {
      debugPrint(
        '⚠️  ZEGO_APP_ID / ZEGO_APP_SIGN missing in .env — calls disabled.',
      );
      return;
    }

    final resolvedName = userName.trim().isEmpty ? userId : userName.trim();
    ZegoCallHistoryRecorder.instance.setSelf(id: userId, name: resolvedName);

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: EnvVariable.instance.zegoAppId,
      appSign: EnvVariable.instance.zegoAppSign,
      userID: userId,
      userName: resolvedName,
      plugins: [ZegoUIKitSignalingPlugin()],
      invitationEvents: _historyInvitationEvents(),
      events: ZegoUIKitPrebuiltCallEvents(
        onCallEnd: (event, defaultAction) {
          ZegoCallHistoryRecorder.instance.markEnded(event.callID);
          defaultAction();
        },
      ),
    );
    _initialized = true;
  }

  /// Maps Zego invitation lifecycle callbacks onto the call-history recorder so
  /// the existing history tab keeps populating under the prebuilt flow.
  ZegoUIKitPrebuiltCallInvitationEvents _historyInvitationEvents() {
    final recorder = ZegoCallHistoryRecorder.instance;
    return ZegoUIKitPrebuiltCallInvitationEvents(
      onOutgoingCallSent: (callID, caller, callType, callees, _) {
        if (callees.isEmpty) return;
        recorder.recordCall(
          callID: callID,
          callerId: caller.id,
          callerName: caller.name,
          receiverId: callees.first.id,
          receiverName: callees.first.name,
          isVideo: callType == ZegoCallInvitationType.videoCall,
        );
      },
      onOutgoingCallAccepted: (callID, _) => recorder.markAccepted(callID),
      onOutgoingCallDeclined: (callID, _, __) => recorder.markRejected(callID),
      onOutgoingCallRejectedCauseBusy: (callID, _, __) =>
          recorder.markRejected(callID),
      onOutgoingCallTimeout: (callID, _, __) => recorder.markMissed(callID),
      onIncomingCallReceived: (callID, caller, callType, _, __) {
        recorder.recordCall(
          callID: callID,
          callerId: caller.id,
          callerName: caller.name,
          receiverId: recorder.selfId,
          receiverName: recorder.selfName,
          isVideo: callType == ZegoCallInvitationType.videoCall,
        );
      },
      onIncomingCallAcceptButtonPressed: () {},
      onIncomingCallTimeout: (callID, _) => recorder.markMissed(callID),
      onIncomingCallCanceled: (callID, _, __) => recorder.markMissed(callID),
    );
  }

  /// Tears down the service on sign-out so the next user starts clean.
  Future<void> onUserLogout() async {
    if (!_initialized) return;
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _initialized = false;
  }
}
