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
  String? _activeChatId;
  String? _activeUserId;
  int? _disappearingDuration;

  void setDisappearingDuration(int? duration) {
    _disappearingDuration = duration;
  }

  List<MessageModel> _filterExpired(List<MessageModel> messages) {
    if (_disappearingDuration == null || _disappearingDuration == 0) {
      return messages;
    }
    final cutoff = DateTime.now()
        .subtract(Duration(seconds: _disappearingDuration!));
    return messages.where((m) => m.createdAt.isAfter(cutoff)).toList();
  }

  void loadMessages({required String chatId}) {
    emit(const MessagesLoading());

    _messagesSubscription =
        _messagesRepo.getMessages(chatId: chatId).listen(
      (messages) {
        if (isClosed) return;
        final filtered = _filterExpired(messages);
        if (filtered.isEmpty) {
          emit(const MessagesEmpty());
        } else {
          emit(MessagesLoaded(messages: filtered));
        }
        if (_activeChatId != null && _activeUserId != null) {
          final unreadIds = messages
              .where((m) => !m.isRead && m.receiverId == _activeUserId)
              .map((m) => m.id)
              .toList();
          if (unreadIds.isNotEmpty) {
            _messagesRepo.markMessagesByIdsAsRead(
              chatId: _activeChatId!,
              messageIds: unreadIds,
            );
          }
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
    _activeChatId = chatId;
    _activeUserId = currentUserId;
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
