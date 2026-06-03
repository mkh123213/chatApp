import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/features/calls/data/datasources/calls_remote_data_source.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';

abstract class CallsRepo {
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

class CallsRepoImpl implements CallsRepo {
  const CallsRepoImpl({
    required CallsRemoteDataSource callsRemoteDataSource,
  }) : _callsRemoteDataSource = callsRemoteDataSource;

  final CallsRemoteDataSource _callsRemoteDataSource;

  @override
  Future<CallModel> startCall({
    required ChatModel chat,
    required CurrentUserModel caller,
    required String type,
  }) {
    return _callsRemoteDataSource.startCall(
      chat: chat,
      caller: caller,
      type: type,
    );
  }

  @override
  Stream<CallModel?> listenForIncomingCalls({
    required String currentUserId,
  }) {
    return _callsRemoteDataSource.listenForIncomingCalls(
      currentUserId: currentUserId,
    );
  }

  @override
  Stream<CallModel> listenToCall({required String callId}) {
    return _callsRemoteDataSource.listenToCall(callId: callId);
  }

  @override
  Future<void> acceptCall({required String callId}) {
    return _callsRemoteDataSource.acceptCall(callId: callId);
  }

  @override
  Future<void> rejectCall({required String callId}) {
    return _callsRemoteDataSource.rejectCall(callId: callId);
  }

  @override
  Future<void> endCall({
    required String callId,
    required int durationInSeconds,
  }) {
    return _callsRemoteDataSource.endCall(
      callId: callId,
      durationInSeconds: durationInSeconds,
    );
  }

  @override
  Future<void> missCall({required String callId}) {
    return _callsRemoteDataSource.missCall(callId: callId);
  }

  @override
  Stream<List<CallModel>> getCallsHistory({required String currentUserId}) {
    return _callsRemoteDataSource.getCallsHistory(
      currentUserId: currentUserId,
    );
  }

  @override
  Future<bool> hasActiveCallBetweenUsers({required String chatId}) {
    return _callsRemoteDataSource.hasActiveCallBetweenUsers(chatId: chatId);
  }

  @override
  Future<void> deleteCallRecord({required String callId}) {
    return _callsRemoteDataSource.deleteCallRecord(callId: callId);
  }

  @override
  Future<void> deleteAllCallHistory({required String currentUserId}) {
    return _callsRemoteDataSource.deleteAllCallHistory(
        currentUserId: currentUserId);
  }
}
