import 'package:chat_material3/features/single_chat/data/datasources/typing_remote_data_source.dart';

class TypingRepo {
  const TypingRepo({required TypingRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final TypingRemoteDataSource _dataSource;

  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) {
    return _dataSource.setTyping(
      chatId: chatId,
      userId: userId,
      isTyping: isTyping,
    );
  }

  Stream<Map<String, bool>> watchTypingStatus({required String chatId}) {
    return _dataSource.watchTypingStatus(chatId: chatId);
  }
}
