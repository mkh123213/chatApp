import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/core/service/push_notification/chat_notification_service.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';

abstract class CallsRemoteDataSource {
  Future<CallModel> startCall({
    required ChatModel chat,
    required CurrentUserModel caller,
    required String type,
  });

  Stream<CallModel?> listenForIncomingCalls({
    required String currentUserId,
  });

  Stream<CallModel> listenToCall({
    required String callId,
  });

  Future<void> acceptCall({required String callId});

  Future<void> rejectCall({required String callId});

  Future<void> endCall({
    required String callId,
    required int durationInSeconds,
  });

  Future<void> missCall({required String callId});

  Stream<List<CallModel>> getCallsHistory({
    required String currentUserId,
  });

  Future<bool> hasActiveCallBetweenUsers({
    required String chatId,
  });

  Future<void> deleteCallRecord({required String callId});

  Future<void> deleteAllCallHistory({required String currentUserId});
}

class CallsRemoteDataSourceImpl implements CallsRemoteDataSource {
  const CallsRemoteDataSourceImpl({
    required DataBaseService dataBaseService,
  }) : _dataBaseService = dataBaseService;

  final DataBaseService _dataBaseService;

  @override
  Future<bool> hasActiveCallBetweenUsers({required String chatId}) async {
    final result = await _dataBaseService.getCollection<Map<String, dynamic>>(
      path: callsCollection,
      queryBuilder: (query) => query
          .where('chatId', isEqualTo: chatId)
          .where('status', whereIn: [CallStatus.ringing, CallStatus.accepted]),
      builder: (data, documentId) => data,
    );
    return result.isNotEmpty;
  }

  @override
  Future<CallModel> startCall({
    required ChatModel chat,
    required CurrentUserModel caller,
    required String type,
  }) async {
    final receiverId = chat.users.firstWhere((id) => id != caller.uid);

    if (receiverId == caller.uid) {
      throw Exception('Cannot call yourself.');
    }

    final ids = [caller.uid, receiverId]..sort();
    final chatId = ids.join('_');

    final hasActive = await hasActiveCallBetweenUsers(chatId: chatId);
    if (hasActive) {
      throw Exception('A call is already active between you and this user.');
    }

    final receiverDoc =
        await _dataBaseService.getDocument<Map<String, dynamic>>(
      path: '$usersCollection/$receiverId',
      builder: (data, id) => data,
    );
    final receiverName = receiverDoc['name'] as String? ?? '';
    final receiverEmail = receiverDoc['email'] as String? ?? '';
    final receiverPhotoUrl = receiverDoc['photoUrl'] as String?;

    final callId =
        FirebaseFirestore.instance.collection(callsCollection).doc().id;
    final channelId = 'call_$callId';
    final now = DateTime.now();

    final callModel = CallModel(
      id: callId,
      chatId: chatId,
      callerId: caller.uid,
      callerName: caller.name ?? '',
      callerEmail: caller.email ?? '',
      callerPhotoUrl: caller.photoUrl,
      receiverId: receiverId,
      receiverName: receiverName,
      receiverEmail: receiverEmail,
      receiverPhotoUrl: receiverPhotoUrl,
      type: type,
      status: CallStatus.ringing,
      startedAt: now,
      durationInSeconds: 0,
      channelId: channelId,
      createdAt: now,
      updatedAt: now,
    );

    await _dataBaseService.setData(
      path: '$callsCollection/$callId',
      data: callModel.toJson(),
    );

    ChatNotificationService.instance.sendCallNotification(
      receiverId: receiverId,
      callId: callId,
      callerName: caller.name ?? caller.email ?? '',
      callerPhotoUrl: caller.photoUrl ?? '',
      callType: type,
    );

    return callModel;
  }

  @override
  Stream<CallModel?> listenForIncomingCalls({
    required String currentUserId,
  }) {
    return _dataBaseService
        .collectionStream<CallModel>(
      path: callsCollection,
      queryBuilder: (query) => query
          .where('receiverId', isEqualTo: currentUserId)
          .where('status', isEqualTo: CallStatus.ringing),
      builder: (data, documentId) =>
          CallModel.fromFirestore(id: documentId, data: data),
    )
        .map((calls) {
      return calls.isNotEmpty ? calls.first : null;
    });
  }

  @override
  Stream<CallModel> listenToCall({required String callId}) {
    return _dataBaseService.documentStream<CallModel>(
      path: '$callsCollection/$callId',
      builder: (data, documentId) =>
          CallModel.fromFirestore(id: documentId, data: data),
    );
  }

  @override
  Future<void> acceptCall({required String callId}) async {
    await _dataBaseService.setData(
      path: '$callsCollection/$callId',
      data: {
        'status': CallStatus.accepted,
        'acceptedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    );
  }

  @override
  Future<void> rejectCall({required String callId}) async {
    await _dataBaseService.setData(
      path: '$callsCollection/$callId',
      data: {
        'status': CallStatus.rejected,
        'endedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    );
  }

  @override
  Future<void> endCall({
    required String callId,
    required int durationInSeconds,
  }) async {
    await _dataBaseService.setData(
      path: '$callsCollection/$callId',
      data: {
        'status': CallStatus.ended,
        'endedAt': Timestamp.now(),
        'durationInSeconds': durationInSeconds,
        'updatedAt': Timestamp.now(),
      },
    );
  }

  @override
  Future<void> missCall({required String callId}) async {
    await _dataBaseService.setData(
      path: '$callsCollection/$callId',
      data: {
        'status': CallStatus.missed,
        'endedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      },
    );
  }

  @override
  Stream<List<CallModel>> getCallsHistory({
    required String currentUserId,
  }) {
    final callerStream = _dataBaseService.collectionStream<CallModel>(
      path: callsCollection,
      queryBuilder: (query) =>
          query.where('callerId', isEqualTo: currentUserId),
      builder: (data, documentId) =>
          CallModel.fromFirestore(id: documentId, data: data),
    );

    final receiverStream = _dataBaseService.collectionStream<CallModel>(
      path: callsCollection,
      queryBuilder: (query) =>
          query.where('receiverId', isEqualTo: currentUserId),
      builder: (data, documentId) =>
          CallModel.fromFirestore(id: documentId, data: data),
    );

    final controller = StreamController<List<CallModel>>();
    List<CallModel> callerCalls = [];
    List<CallModel> receiverCalls = [];

    final callerSub = callerStream.listen((calls) {
      callerCalls = calls;
      controller.add(_mergeCalls(callerCalls, receiverCalls));
    });

    final receiverSub = receiverStream.listen((calls) {
      receiverCalls = calls;
      controller.add(_mergeCalls(callerCalls, receiverCalls));
    });

    controller.onCancel = () {
      callerSub.cancel();
      receiverSub.cancel();
      controller.close();
    };

    return controller.stream;
  }

  @override
  Future<void> deleteCallRecord({required String callId}) async {
    await _dataBaseService.deleteData(path: '$callsCollection/$callId');
  }

  @override
  Future<void> deleteAllCallHistory({required String currentUserId}) async {
    final callerCalls =
        await _dataBaseService.getCollection<Map<String, dynamic>>(
      path: callsCollection,
      queryBuilder: (query) =>
          query.where('callerId', isEqualTo: currentUserId),
      builder: (data, documentId) => {'id': documentId, ...data},
    );

    final receiverCalls =
        await _dataBaseService.getCollection<Map<String, dynamic>>(
      path: callsCollection,
      queryBuilder: (query) =>
          query.where('receiverId', isEqualTo: currentUserId),
      builder: (data, documentId) => {'id': documentId, ...data},
    );

    final allCalls = [...callerCalls, ...receiverCalls];
    for (final call in allCalls) {
      await _dataBaseService.deleteData(
        path: '$callsCollection/${call['id']}',
      );
    }
  }

  List<CallModel> _mergeCalls(
    List<CallModel> callerCalls,
    List<CallModel> receiverCalls,
  ) {
    final Map<String, CallModel> callMap = {};
    for (final call in callerCalls) {
      callMap[call.id] = call;
    }
    for (final call in receiverCalls) {
      callMap[call.id] = call;
    }
    final merged = callMap.values.toList()
      ..sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
    return merged;
  }
}
