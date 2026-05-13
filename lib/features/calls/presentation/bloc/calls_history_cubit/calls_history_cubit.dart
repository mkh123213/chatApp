import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/repositories/calls_repo.dart';

import 'calls_history_state.dart';

class CallsHistoryCubit extends Cubit<CallsHistoryState> {
  CallsHistoryCubit({
    required CallsRepo callsRepo,
  })  : _callsRepo = callsRepo,
        super(const CallsHistoryInitial());

  final CallsRepo _callsRepo;
  StreamSubscription<List<CallModel>>? _subscription;

  void getCallsHistory({required String currentUserId}) {
    emit(const CallsHistoryLoading());

    _subscription = _callsRepo
        .getCallsHistory(currentUserId: currentUserId)
        .listen(
      (calls) {
        if (isClosed) return;
        if (calls.isEmpty) {
          emit(const CallsHistoryEmpty());
        } else {
          emit(CallsHistoryLoaded(calls: calls));
        }
      },
      onError: (error) {
        if (isClosed) return;
        emit(CallsHistoryError(message: error.toString()));
      },
    );
  }

  Future<void> deleteCallRecord({required String callId}) async {
    try {
      await _callsRepo.deleteCallRecord(callId: callId);
    } catch (e) {
      if (isClosed) return;
      emit(CallsHistoryError(message: e.toString()));
    }
  }

  Future<void> deleteAllCallHistory({required String currentUserId}) async {
    try {
      await _callsRepo.deleteAllCallHistory(currentUserId: currentUserId);
    } catch (e) {
      if (isClosed) return;
      emit(CallsHistoryError(message: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
