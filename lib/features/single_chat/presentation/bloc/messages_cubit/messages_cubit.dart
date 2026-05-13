import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';
import 'package:chat_material3/features/single_chat/domain/repositories/messages_repo.dart';

import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required MessagesRepo messagesRepo})
      : _messagesRepo = messagesRepo,
        super(const MessagesInitial());

  final MessagesRepo _messagesRepo;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  void loadMessages({required String chatId}) {
    emit(const MessagesLoading());

    _messagesSubscription =
        _messagesRepo.getMessages(chatId: chatId).listen(
      (messages) {
        if (isClosed) return;
        if (messages.isEmpty) {
          emit(const MessagesEmpty());
        } else {
          emit(MessagesLoaded(messages: messages));
        }
      },
      onError: (error) {
        if (isClosed) return;
        emit(MessagesError(message: error.toString()));
      },
    );
  }

  void toggleMessageSelection(String messageId) {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      final updated = Set<String>.of(currentState.selectedIds);
      if (updated.contains(messageId)) {
        updated.remove(messageId);
      } else {
        updated.add(messageId);
      }
      emit(MessagesLoaded(
        messages: currentState.messages,
        selectedIds: updated,
      ));
    }
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(MessagesLoaded(
        messages: currentState.messages,
        selectedIds: const {},
      ));
    }
  }

  Future<void> markAsRead({
    required String chatId,
    required String currentUserId,
  }) async {
    await _messagesRepo.markMessagesAsRead(
      chatId: chatId,
      currentUserId: currentUserId,
    );
  }

  Set<String> get selectedMessageIds {
    final s = state;
    if (s is MessagesLoaded) return s.selectedIds;
    return const {};
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
