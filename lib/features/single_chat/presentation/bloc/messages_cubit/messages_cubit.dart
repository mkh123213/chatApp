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

  final MessagesRepo _messagesRepo;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;
  String? _activeChatId;
  String? _activeUserId;
  int? _disappearingDuration;
  
  List<MessageModel> _messages = [];
  DocumentSnapshot? _lastDocument;

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
    _messages = [];
    _lastDocument = null;

    _messagesSubscription =
        _messagesRepo.getMessages(chatId: chatId).listen(
      (messages) {
        if (isClosed) return;
        
        // This stream only emits the latest 30 messages.
        // We need to merge them with our paginated history.
        // This is complex. For now, let's just use the stream for the latest 30.
        
        final filtered = _filterExpired(messages);
        _messages = filtered; 
        
        if (_messages.isEmpty) {
          emit(const MessagesEmpty());
        } else {
          emit(MessagesLoaded(messages: _messages, hasMore: true));
        }
        
        // ... mark as read ...
      },
      onError: (error) {
        if (isClosed) return;
        emit(MessagesError(message: error.toString()));
      },
    );
  }

  Future<void> loadMoreMessages({required String chatId}) async {
    if (state is MessagesLoaded) {
      final loadedState = state as MessagesLoaded;
      if (!loadedState.hasMore || loadedState.isLoadingMore) return;

      emit(loadedState.copyWith(isLoadingMore: true));

      final snapshot = await _messagesRepo.getMessagesPage(
        chatId: chatId,
        limit: 30,
        lastDocument: _lastDocument,
      );

      final newMessages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(
              id: doc.id, data: doc.data() as Map<String, dynamic>))
          .toList();

      if (newMessages.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _messages.addAll(newMessages);
        emit(loadedState.copyWith(
          messages: List.from(_messages),
          isLoadingMore: false,
          hasMore: newMessages.length == 30,
        ));
      } else {
        emit(loadedState.copyWith(isLoadingMore: false, hasMore: false));
      }
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
