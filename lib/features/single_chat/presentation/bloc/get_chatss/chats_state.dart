import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';

sealed class ChatsState {
  const ChatsState();
}

final class ChatsInitial extends ChatsState {
  const ChatsInitial();
}

final class ChatsLoading extends ChatsState {
  const ChatsLoading();
}

final class ChatsLoaded extends ChatsState {
  const ChatsLoaded({
    required this.chats,
    this.hasMore = true,
    this.isLoadingMore = false,
  });
  final List<ChatModel> chats;
  final bool hasMore;
  final bool isLoadingMore;

  ChatsLoaded copyWith({
    List<ChatModel>? chats,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ChatsLoaded(
      chats: chats ?? this.chats,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final class ChatsEmpty extends ChatsState {
  const ChatsEmpty();
}

final class ChatsError extends ChatsState {
  const ChatsError({required this.message});
  final String message;
}

final class ChatsSearchLoading extends ChatsState {
  const ChatsSearchLoading();
}

final class ChatsSearchLoaded extends ChatsState {
  const ChatsSearchLoaded({required this.chats});
  final List<ChatModel> chats;
}

final class ChatsSearchEmpty extends ChatsState {
  const ChatsSearchEmpty();
}
