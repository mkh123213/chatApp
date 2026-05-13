import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/single_chat/data/models/message_model.dart';

class UnReadMessagesRemoteDataSource {
  final DataBaseService firestore;

  UnReadMessagesRemoteDataSource({required this.firestore});

  // unreadmessages
  Stream<int> getUnreadMessagesCount({required String chatId}) {
    return firestore
        .collectionStream(
          path: '$chatsCollection/$chatId/$messagesCollection',
          queryBuilder: (query) {
            final currentUserId = getCurrentUser().uid;
            return query
                .where('receiverId', isEqualTo: currentUserId)
                .where('isRead', isEqualTo: false);
          },
          builder: (data, documentId) {
            return MessageModel.fromFirestore(id: documentId, data: data);
          },
        )
        .map((messages) => messages.length);
  }

  // unreadmessages
  Stream<int> getGroupUnreadMessagesCount({required String groupId}) {
    final currentUserId = getCurrentUser().uid;

    return firestore
        .collectionStream<GroupMessageModel>(
      path: '$groupsCollection/$groupId/$messagesCollection',
      builder: (data, documentId) {
        return GroupMessageModel.fromFirestore(
          id: documentId,
          data: data,
        );
      },
    )
        .map((messages) {
      return messages.where((message) {
        final bool isReadByMe = message.readBy.contains(currentUserId);
        final bool isMyMessage = message.senderId == currentUserId;

        return !isReadByMe && !isMyMessage;
      }).length;
    });
  }
  // unreadmessages in group
}
