import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/ai_assistant/data/ai_assistant_service.dart';

part 'ai_assistant_state.dart';

class AiMessage {
  const AiMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
}

class AiAssistantCubit extends Cubit<AiAssistantState> {
  AiAssistantCubit({required AiAssistantService service})
      : _service = service,
        super(AiAssistantState(
          messages: [
            AiMessage(
              text: 'Hey! 👋 I\'m your AI Assistant. Ask me anything — jokes, facts, advice, or just chat!',
              isUser: false,
              timestamp: DateTime.now(),
            ),
          ],
          isLoading: false,
        ));

  final AiAssistantService _service;

  Future<void> sendMessage(String text) async {
    final userMsg = AiMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    emit(AiAssistantState(
      messages: [...state.messages, userMsg],
      isLoading: true,
    ));

    try {
      final response = await _service.sendMessage(text);
      final aiMsg = AiMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      if (!isClosed) {
        emit(AiAssistantState(
          messages: [...state.messages, aiMsg],
          isLoading: false,
        ));
      }
    } catch (e) {
      final errorMsg = AiMessage(
        text: 'Sorry, something went wrong. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      if (!isClosed) {
        emit(AiAssistantState(
          messages: [...state.messages, errorMsg],
          isLoading: false,
        ));
      }
    }
  }
}
