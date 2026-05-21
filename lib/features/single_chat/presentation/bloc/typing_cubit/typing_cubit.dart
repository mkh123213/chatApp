import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/repositories/typing_repo.dart';

class TypingState {
  const TypingState({this.typingUsers = const {}});
  final Map<String, bool> typingUsers;

  bool isUserTyping(String userId) => typingUsers[userId] == true;
}

class TypingCubit extends Cubit<TypingState> {
  TypingCubit({required TypingRepo typingRepo})
      : _typingRepo = typingRepo,
        super(const TypingState());

  final TypingRepo _typingRepo;
  StreamSubscription<Map<String, bool>>? _subscription;
  Timer? _debounceTimer;

  void watchTyping({required String chatId}) {
    _subscription?.cancel();
    _subscription = _typingRepo.watchTypingStatus(chatId: chatId).listen(
      (typingUsers) {
        if (!isClosed) emit(TypingState(typingUsers: typingUsers));
      },
    );
  }

  Future<void> setTyping({
    required String chatId,
    required String userId,
  }) async {
    _debounceTimer?.cancel();
    await _typingRepo.setTyping(
      chatId: chatId,
      userId: userId,
      isTyping: true,
    );
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      clearTyping(chatId: chatId, userId: userId);
    });
  }

  Future<void> clearTyping({
    required String chatId,
    required String userId,
  }) async {
    _debounceTimer?.cancel();
    await _typingRepo.setTyping(
      chatId: chatId,
      userId: userId,
      isTyping: false,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
