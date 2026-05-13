sealed class SendMessageState {
  const SendMessageState();
}

final class SendMessageInitial extends SendMessageState {
  const SendMessageInitial();
}

final class SendMessageSending extends SendMessageState {
  const SendMessageSending();
}

final class SendMessageSent extends SendMessageState {
  const SendMessageSent();
}

final class SendMessageError extends SendMessageState {
  const SendMessageError({required this.message});
  final String message;
}

final class SendMessageEditing extends SendMessageState {
  const SendMessageEditing();
}

final class SendMessageEdited extends SendMessageState {
  const SendMessageEdited();
}

final class SendMessageDeleting extends SendMessageState {
  const SendMessageDeleting();
}

final class SendMessageDeleted extends SendMessageState {
  const SendMessageDeleted();
}
