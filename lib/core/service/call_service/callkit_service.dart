import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/service/pending_navigation/pending_navigation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

class CallKitService {
  CallKitService._();
  static final CallKitService instance = CallKitService._();

  Future<void> init() async {
    FlutterCallkitIncoming.onEvent.listen(_onCallKitEvent);
  }

  Future<void> showIncomingCall({
    required String callId,
    required String callerName,
    required String callerAvatar,
    required bool isVideo,
  }) async {
    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      avatar: callerAvatar,
      handle: callerName,
      type: isVideo ? 1 : 0,
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
      ),
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        isShowFullLockedScreen: true,
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  Future<void> endCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }

  void _onCallKitEvent(CallEvent? event) {
    if (event == null) return;

    final body = event.body as Map<dynamic, dynamic>? ?? {};
    final callId = body['id'] as String? ?? '';

    switch (event.event) {
      case Event.actionCallAccept:
        _handleAccept(callId);
        break;
      case Event.actionCallDecline:
        _handleDecline(callId);
        break;
      case Event.actionCallTimeout:
        _handleTimeout(callId);
        break;
      case Event.actionCallEnded:
        break;
      default:
        break;
    }
  }

  Future<void> _handleAccept(String callId) async {
    if (callId.isEmpty) return;
    try {
      await _acceptCallDirect(callId);
      PendingNavigationService.instance.setPendingCall(callId);
    } catch (e) {
      debugPrint('CallKit accept error: $e');
    }
  }

  Future<void> _handleDecline(String callId) async {
    if (callId.isEmpty) return;
    try {
      await _rejectCallDirect(callId);
    } catch (e) {
      debugPrint('CallKit decline error: $e');
    }
  }

  Future<void> _handleTimeout(String callId) async {
    if (callId.isEmpty) return;
    try {
      await _missCallDirect(callId);
    } catch (e) {
      debugPrint('CallKit timeout error: $e');
    }
  }

  Future<void> _acceptCallDirect(String callId) async {
    await FirebaseFirestore.instance.doc('$callsCollection/$callId').update({
      'status': 'accepted',
      'acceptedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> _rejectCallDirect(String callId) async {
    await FirebaseFirestore.instance.doc('$callsCollection/$callId').update({
      'status': 'rejected',
      'endedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> _missCallDirect(String callId) async {
    await FirebaseFirestore.instance.doc('$callsCollection/$callId').update({
      'status': 'missed',
      'endedAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    });
  }
}
