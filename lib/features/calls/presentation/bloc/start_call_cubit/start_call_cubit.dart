import 'package:bloc/bloc.dart';

import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/features/calls/data/repositories/calls_repo.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';

import 'start_call_state.dart';

class StartCallCubit extends Cubit<StartCallState> {
  StartCallCubit({
    required CallsRepo callsRepo,
  })  : _callsRepo = callsRepo,
        super(const StartCallInitial());

  final CallsRepo _callsRepo;

  Future<void> startAudioCall({required ChatModel chat}) async {
    await _startCall(chat: chat, type: 'audio');
  }

  Future<void> startVideoCall({required ChatModel chat}) async {
    await _startCall(chat: chat, type: 'video');
  }

  Future<void> _startCall({
    required ChatModel chat,
    required String type,
  }) async {
    emit(const StartCallLoading());
    try {
      final currentUser = getCurrentUser();
      final friendId = chat.users.firstWhere(
        (id) => id != currentUser.uid,
        orElse: () => currentUser.uid,
      );

      if (friendId == currentUser.uid) {
        emit(const StartCallError(message: 'Cannot call yourself.'));
        return;
      }

      final call = await _callsRepo.startCall(
        chat: chat,
        caller: currentUser,
        type: type,
      );
      emit(StartCallSuccess(call: call));
    } catch (e) {
      emit(StartCallError(message: e.toString()));
    }
  }
}
