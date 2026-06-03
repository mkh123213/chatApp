import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/repositories/typing_repo.dart';

class ChatListTypingState {
  const ChatListTypingState({this.typingByChatId = const {}});
  final Map<String, Map<String, bool>> typingByChatId;

  bool isSomeoneTyping(String chatId, String currentUserId) {
    final chatTyping = typingByChatId[chatId];
    if (chatTyping == null) return false;
    return chatTyping.entries.any((e) => e.key != currentUserId && e.value);
  }
}

class ChatListTypingCubit extends Cubit<ChatListTypingState> {
  ChatListTypingCubit({required TypingRepo typingRepo})
      : _typingRepo = typingRepo,
        super(const ChatListTypingState());

  final TypingRepo _typingRepo;
  final Map<String, StreamSubscription<Map<String, bool>>> _subscriptions = {};

  void watchChats(List<String> chatIds) {
    for (final id in chatIds) {
      if (_subscriptions.containsKey(id)) continue;
      _subscriptions[id] = _typingRepo.watchTypingStatus(chatId: id).listen(
        (typingUsers) {
          if (isClosed) return;
          final updated = Map<String, Map<String, bool>>.from(state.typingByChatId);
          updated[id] = typingUsers;
          emit(ChatListTypingState(typingByChatId: updated));
        },
      );
    }
  }

  @override
  Future<void> close() {
    for (final sub in _subscriptions.values) {
      sub.cancel();
    }
    return super.close();
  }
}
