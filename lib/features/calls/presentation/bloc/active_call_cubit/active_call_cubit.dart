import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:chat_material3/features/calls/data/repositories/calls_repo.dart';
import 'package:chat_material3/core/service/call_service/call_provider_service.dart';

import 'active_call_state.dart';

class ActiveCallCubit extends Cubit<ActiveCallState> {
  ActiveCallCubit({
    required CallsRepo callsRepo,
    required CallProviderService callProviderService,
  })  : _callsRepo = callsRepo,
        _callProviderService = callProviderService,
        super(const ActiveCallInitial());

  final CallsRepo _callsRepo;
  final CallProviderService _callProviderService;
  StreamSubscription<CallModel>? _callSubscription;

  void listenToCall({required String callId}) {
    emit(const ActiveCallLoading());

    _callSubscription = _callsRepo.listenToCall(callId: callId).listen(
      (call) {
        if (isClosed) return;
        if (call.status == CallStatus.ended ||
            call.status == CallStatus.rejected ||
            call.status == CallStatus.missed) {
          emit(const ActiveCallEnded());
        } else {
          emit(ActiveCallActive(call: call));
        }
      },
      onError: (error) {
        if (isClosed) return;
        emit(ActiveCallError(message: error.toString()));
      },
    );
  }

  Future<void> acceptCall({required CallModel call}) async {
    try {
      await _callsRepo.acceptCall(callId: call.id);
    } catch (e) {
      emit(ActiveCallError(message: e.toString()));
    }
  }

  Future<void> rejectCall({required CallModel call}) async {
    try {
      await _callsRepo.rejectCall(callId: call.id);
    } catch (e) {
      emit(ActiveCallError(message: e.toString()));
    }
  }

  Future<void> endCall({
    required CallModel call,
    required int durationInSeconds,
  }) async {
    try {
      await _callsRepo.endCall(
        callId: call.id,
        durationInSeconds: durationInSeconds,
      );
    } catch (e) {
      emit(ActiveCallError(message: e.toString()));
    }
  }

  Future<void> missCall({required CallModel call}) async {
    try {
      await _callsRepo.missCall(callId: call.id);
    } catch (e) {
      emit(ActiveCallError(message: e.toString()));
    }
  }

  Future<void> toggleMute(bool muted) async {
    await _callProviderService.toggleMute(muted);
  }

  Future<void> toggleSpeaker(bool speakerOn) async {
    await _callProviderService.toggleSpeaker(speakerOn);
  }

  Future<void> toggleCamera(bool cameraOn) async {
    await _callProviderService.toggleCamera(cameraOn);
  }

  Future<void> switchCamera() async {
    await _callProviderService.switchCamera();
  }

  Future<void> leaveChannel() async {
    await _callProviderService.leaveChannel();
  }

  @override
  Future<void> close() async {
    await _callSubscription?.cancel();
    return super.close();
  }
}
