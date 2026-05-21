import 'package:google_generative_ai/google_generative_ai.dart';

class AiAssistantService {
  AiAssistantService({required String apiKey})
      : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: apiKey,
          systemInstruction: Content.system(
            'You are a friendly AI assistant in a chat app. '
            'Keep responses concise and conversational. '
            'You can help with jokes, fun facts, advice, motivational quotes, '
            'and general knowledge.',
          ),
        );

  final GenerativeModel _model;
  ChatSession? _chat;

  ChatSession get _session => _chat ??= _model.startChat();

  Future<String> sendMessage(String message) async {
    final response = await _session.sendMessage(Content.text(message));
    return response.text ?? 'Sorry, I could not generate a response.';
  }

  void reset() {
    _chat = null;
  }
}
