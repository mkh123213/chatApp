sealed class CreateChatState {
  const CreateChatState();
}

final class CreateChatInitial extends CreateChatState {
  const CreateChatInitial();
}

final class CreateChatLoading extends CreateChatState {
  const CreateChatLoading();
}

final class CreateChatSuccess extends CreateChatState {
  const CreateChatSuccess();
}

final class CreateChatError extends CreateChatState {
  const CreateChatError({required this.message});
  final String message;
}
