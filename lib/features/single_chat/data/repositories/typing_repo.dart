import '../datasources/typing_remote_data_source.dart';

class TypingRepo {
  const TypingRepo({required TypingRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final TypingRemoteDataSource _dataSource;

  Future<void> setTyping({
    required String chatId,
    required String userId,
    required bool isTyping,
    String? collection,
  }) {
    return _dataSource.setTyping(
      chatId: chatId,
      userId: userId,
      isTyping: isTyping,
      collection: collection ?? 'chats',
    );
  }

  Stream<Map<String, bool>> watchTypingStatus({
    required String chatId,
    String? collection,
  }) {
    return _dataSource.watchTypingStatus(
      chatId: chatId,
      collection: collection ?? 'chats',
    );
  }
}
