import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChatsRemoteDataSource {
  Stream<List<ChatModel>> getChats({required String currentUserId});

  Future<void> createChat({
    required String currentUserId,
    required String currentUserEmail,
    required String friendEmail,
  });

  Future<void> deleteChat({required String chatId});

  Stream<List<ChatModel>> searchChats({
    required String currentUserId,
    required String searchText,
  });
}

class ChatsRemoteDataSourceImpl implements ChatsRemoteDataSource {
  const ChatsRemoteDataSourceImpl({
    required DataBaseService dataBaseService,
  }) : _dataBaseService = dataBaseService;

  final DataBaseService _dataBaseService;

  @override
  Stream<List<ChatModel>> getChats({required String currentUserId}) {
    return _dataBaseService.collectionStream(
      builder: (data, documentId) => ChatModel.fromFirestore(
        id: documentId,
        data: data,
      ),
      path: chatsCollection,
      queryBuilder: (query) =>
          query.where('users', arrayContains: currentUserId),
    );
  }

  @override
  Future<void> createChat({
    required String currentUserId,
    required String currentUserEmail,
    required String friendEmail,
  }) async {
    final cleanedFriendEmail = friendEmail.trim().toLowerCase();
    final cleanedCurrentEmail = currentUserEmail.trim().toLowerCase();

    if (cleanedFriendEmail.isEmpty) {
      throw Exception('Please enter friend email.');
    }

    if (cleanedFriendEmail == cleanedCurrentEmail) {
      throw Exception('Cannot create chat with yourself.');
    }

    final users = await _dataBaseService.getCollection<Map<String, dynamic>>(
      path: usersCollection,
      queryBuilder: (query) =>
          query.where('email', isEqualTo: cleanedFriendEmail).limit(1),
      builder: (data, documentId) => {'id': documentId, ...data},
    );

    if (users.isEmpty) {
      throw Exception('No user found with this email.');
    }

    final friendData = users.first;
    final friendId = friendData['id'] as String;
    final friendUserEmail =
        friendData['email'] as String? ?? cleanedFriendEmail;
    final friendName = friendData['name'] as String? ?? '';

    final existingChats =
        await _dataBaseService.getCollection<Map<String, dynamic>>(
      path: chatsCollection,
      queryBuilder: (query) =>
          query.where('users', arrayContains: currentUserId),
      builder: (data, documentId) => {'id': documentId, ...data},
    );

    for (final chat in existingChats) {
      final chatUsers = List<String>.from(chat['users'] ?? []);
      if (chatUsers.contains(friendId)) {
        throw Exception('Chat already exists.');
      }
    }

    final chatId = _createChatId(
      currentUserId: currentUserId,
      friendId: friendId,
    );

    final currentUserName = getCurrentUser().name ?? '';

    final chatToAdd = ChatModel(
      id: chatId,
      users: [currentUserId, friendId],
      usersEmails: [cleanedCurrentEmail, friendUserEmail],
      usersNames: [currentUserName, friendName],
      lastMessage: '',
      lastMessageTime: null,
      createdAt: DateTime.now(),
    );

    await _dataBaseService.setData(
      path: '$chatsCollection/$chatId',
      data: chatToAdd.toJson(),
    );
  }

  @override
  Future<void> deleteChat({required String chatId}) async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('$chatsCollection/$chatId/$messagesCollection')
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    await _dataBaseService.deleteData(path: '$chatsCollection/$chatId');
  }

  @override
  Stream<List<ChatModel>> searchChats({
    required String currentUserId,
    required String searchText,
  }) {
    final cleanedSearchText = searchText.trim().toLowerCase();

    if (cleanedSearchText.isEmpty) {
      return getChats(currentUserId: currentUserId);
    }

    return _dataBaseService
        .collectionStream<ChatModel>(
      builder: (data, documentId) =>
          ChatModel.fromFirestore(id: documentId, data: data),
      path: chatsCollection,
      queryBuilder: (query) =>
          query.where('users', arrayContains: currentUserId),
    )
        .map((chats) {
      return chats.where((chat) {
        final usersEmails =
            chat.usersEmails?.map((e) => e.toLowerCase()).toList() ?? [];
        return usersEmails.any((email) => email.contains(cleanedSearchText));
      }).toList();
    });
  }

  String _createChatId({
    required String currentUserId,
    required String friendId,
  }) {
    final ids = [currentUserId, friendId]..sort();
    return ids.join('_');
  }
}
