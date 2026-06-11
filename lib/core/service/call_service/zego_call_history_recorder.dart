// Writes call-history records to the same Firestore `calls` collection the
// history tab reads (features/calls). Records are keyed by Zego's callID so the
// caller's and callee's writes merge into a single document.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';

class ZegoCallHistoryRecorder {
  ZegoCallHistoryRecorder._();
  static final ZegoCallHistoryRecorder instance = ZegoCallHistoryRecorder._();

  String _selfId = '';
  String _selfName = '';

  /// In-memory accept times so [markEnded] can compute the duration.
  final Map<String, DateTime> _acceptedAt = {};

  void setSelf({required String id, required String name}) {
    _selfId = id;
    _selfName = name;
  }

  DocumentReference<Map<String, dynamic>> _doc(String callID) =>
      FirebaseFirestore.instance.collection(callsCollection).doc(callID);

  String _chatId(String a, String b) {
    final ids = [a, b]..sort();
    return ids.join('_');
  }

  /// Creates the call document (outgoing or incoming) in `ringing` state.
  Future<void> recordCall({
    required String callID,
    required String callerId,
    required String callerName,
    required String receiverId,
    required String receiverName,
    required bool isVideo,
  }) async {
    final now = Timestamp.now();
    await _doc(callID).set({
      'id': callID,
      'chatId': _chatId(callerId, receiverId),
      'callerId': callerId,
      'callerName': callerName,
      'callerEmail': '',
      'receiverId': receiverId,
      'receiverName': receiverName,
      'receiverEmail': '',
      'type': isVideo ? CallType.video : CallType.audio,
      'status': CallStatus.ringing,
      'startedAt': now,
      'durationInSeconds': 0,
      'channelId': callID,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  Future<void> markAccepted(String callID) async {
    _acceptedAt[callID] = DateTime.now();
    await _update(callID, {
      'status': CallStatus.accepted,
      'acceptedAt': Timestamp.now(),
    });
  }

  Future<void> markRejected(String callID) =>
      _update(callID, {'status': CallStatus.rejected, 'endedAt': Timestamp.now()});

  Future<void> markMissed(String callID) =>
      _update(callID, {'status': CallStatus.missed, 'endedAt': Timestamp.now()});

  Future<void> markEnded(String callID) async {
    final accepted = _acceptedAt.remove(callID);
    final duration =
        accepted == null ? 0 : DateTime.now().difference(accepted).inSeconds;
    await _update(callID, {
      // A call that ends without ever being accepted is a missed call.
      'status': accepted == null ? CallStatus.missed : CallStatus.ended,
      'endedAt': Timestamp.now(),
      'durationInSeconds': duration,
    });
  }

  Future<void> _update(String callID, Map<String, dynamic> data) async {
    await _doc(callID).set(
      {...data, 'updatedAt': Timestamp.now()},
      SetOptions(merge: true),
    );
  }

  String get selfId => _selfId;
  String get selfName => _selfName;
}
