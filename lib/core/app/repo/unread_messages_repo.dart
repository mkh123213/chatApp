import 'package:chat_material3/core/app/data_source/un_read_messages_remote_data_source.dart';

class UnreadMessagesRepo {
  final UnReadMessagesRemoteDataSource unreadMessageDataSource;
  UnreadMessagesRepo({required this.unreadMessageDataSource});

  Stream<int> getUnreadMessagesCount({required String chatId}) {
    return unreadMessageDataSource.getUnreadMessagesCount(chatId: chatId);
  }

  Stream<int> getGroupUnreadMessagesCount({required String groupId}) {
    return unreadMessageDataSource.getGroupUnreadMessagesCount(
        groupId: groupId);
  }
}
