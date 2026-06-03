part of 'ai_assistant_cubit.dart';

class AiAssistantState {
  const AiAssistantState({
    required this.messages,
    required this.isLoading,
  });

  final List<AiMessage> messages;
  final bool isLoading;
}
