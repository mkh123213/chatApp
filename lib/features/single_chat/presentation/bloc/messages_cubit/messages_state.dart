import 'package:chat_material3/features/single_chat/data/models/message_model.dart';

sealed class MessagesState {
  const MessagesState();
}

final class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

final class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

final class MessagesLoaded extends MessagesState {
  const MessagesLoaded({
    required this.messages,
    this.selectedIds = const {},
    this.hasMore = true,
    this.isLoadingMore = false,
  });
  final List<MessageModel> messages;
  final Set<String> selectedIds;
  final bool hasMore;
  final bool isLoadingMore;

  MessagesLoaded copyWith({
    List<MessageModel>? messages,
    Set<String>? selectedIds,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return MessagesLoaded(
      messages: messages ?? this.messages,
      selectedIds: selectedIds ?? this.selectedIds,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class MessagesEmpty extends MessagesState {
  const MessagesEmpty();
}

final class MessagesError extends MessagesState {
  const MessagesError({required this.message});
  final String message;
}
