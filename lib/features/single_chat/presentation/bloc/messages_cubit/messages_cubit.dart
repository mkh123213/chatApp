import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';
import 'package:chat_material3/features/single_chat/data/repositories/messages_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  MessagesCubit({required MessagesRepo messagesRepo})
      : _messagesRepo = messagesRepo,
        super(const MessagesInitial());

  static const _pageSize = 30;

  final MessagesRepo _messagesRepo;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  int? _disappearingDuration;

  // Single source of truth, keyed by message id to guarantee de-duplication
  // across the live (newest) window and paginated history.
  final Map<String, MessageModel> _messagesById = {};
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

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

  /// Newest-first, de-duplicated, with disappearing messages filtered out.
  List<MessageModel> _visibleMessages() {
    final list = _messagesById.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return _filterExpired(list);
  }

  /// Merges the latest live window into the store and reconciles deletions
  /// that happened within that window (messages no longer present are removed).
  void _applyLiveBatch(List<MessageModel> live) {
    if (live.isNotEmpty) {
      final oldestLive = live
          .map((m) => m.createdAt)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      final liveIds = live.map((m) => m.id).toSet();
      // Anything at or newer than the live window that's missing was deleted.
      _messagesById.removeWhere((id, m) =>
          !m.createdAt.isBefore(oldestLive) && !liveIds.contains(id));
    }
    for (final m in live) {
      _messagesById[m.id] = m;
    }
  }

  void loadMessages({required String chatId}) {
    emit(const MessagesLoading());
    _messagesById.clear();
    _lastDocument = null;
    _hasMore = true;

    _messagesSubscription = _messagesRepo.getMessages(chatId: chatId).listen(
      (messages) {
        if (isClosed) return;

        _applyLiveBatch(messages);
        final visible = _visibleMessages();

        if (visible.isEmpty) {
          emit(const MessagesEmpty());
        } else {
          final selected =
              state is MessagesLoaded ? (state as MessagesLoaded).selectedIds : const <String>{};
          emit(MessagesLoaded(
            messages: visible,
            selectedIds: selected,
            hasMore: _hasMore,
          ));
        }
      },
      onError: (error) {
        if (isClosed) return;
        emit(MessagesError(message: error.toString()));
      },
    );
  }

  Future<void> loadMoreMessages({required String chatId}) async {
    final current = state;
    if (current is! MessagesLoaded) return;
    if (!_hasMore || current.isLoadingMore) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      var addedNew = false;

      // The first page overlaps the live window; keep paging until we load
      // messages we don't already have (or reach the end).
      while (!addedNew && _hasMore) {
        final snapshot = await _messagesRepo.getMessagesPage(
          chatId: chatId,
          limit: _pageSize,
          lastDocument: _lastDocument,
        );

        if (snapshot.docs.isEmpty) {
          _hasMore = false;
          break;
        }

        _lastDocument = snapshot.docs.last;
        _hasMore = snapshot.docs.length == _pageSize;

        for (final doc in snapshot.docs) {
          final m = MessageModel.fromFirestore(
            id: doc.id,
            data: doc.data() as Map<String, dynamic>,
          );
          if (!_messagesById.containsKey(m.id)) addedNew = true;
          _messagesById[m.id] = m;
        }
      }

      if (isClosed) return;
      emit(MessagesLoaded(
        messages: _visibleMessages(),
        selectedIds: current.selectedIds,
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
    } catch (error) {
      if (isClosed) return;
      emit(current.copyWith(isLoadingMore: false));
    }
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
      emit(currentState.copyWith(selectedIds: updated));
    }
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is MessagesLoaded) {
      emit(currentState.copyWith(selectedIds: const {}));
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

  Future<void> forwardMessage({
    required MessageModel message,
    required String targetChatId,
    required String senderId,
    required String senderEmail,
    required String receiverId,
  }) async {
    // For text, just resend it. For media, reuse URL (don't re-upload).
    if (message.type == 'text') {
      await _messagesRepo.sendTextMessage(
        chatId: targetChatId,
        senderId: senderId,
        senderEmail: senderEmail,
        receiverId: receiverId,
        text: message.text,
      );
    } else {
      // Logic for media reuse (e.g., sendImageMessage, sendFileMessage helpers)
      // This requires helper methods or service calls. 
      // Simplified for now:
      await _messagesRepo.sendTextMessage(
        chatId: targetChatId,
        senderId: senderId,
        senderEmail: senderEmail,
        receiverId: receiverId,
        text: "Forwarded: ${message.text}", // Simple placeholder
      );
    }
    clearSelection();
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
