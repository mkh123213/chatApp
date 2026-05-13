import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/repositories/calls_repo.dart';

import 'incoming_call_state.dart';

class IncomingCallCubit extends Cubit<IncomingCallState> {
  IncomingCallCubit({
    required CallsRepo callsRepo,
  })  : _callsRepo = callsRepo,
        super(const IncomingCallInitial());

  final CallsRepo _callsRepo;
  StreamSubscription<CallModel?>? _subscription;

  void listenForIncomingCalls({required String currentUserId}) {
    emit(const IncomingCallListening());

    _subscription = _callsRepo
        .listenForIncomingCalls(currentUserId: currentUserId)
        .listen(
      (call) {
        if (isClosed) return;
        if (call != null) {
          emit(IncomingCallReceived(call: call));
        } else {
          emit(const IncomingCallNone());
        }
      },
      onError: (error) {
        if (isClosed) return;
        emit(IncomingCallError(message: error.toString()));
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
