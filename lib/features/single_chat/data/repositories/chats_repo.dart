import 'package:chat_material3/features/single_chat/data/datasources/chats_remote_data_source.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';

abstract class ChatsRepo {
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

  Future<void> pinChat({required String chatId, required String userId});
  Future<void> unpinChat({required String chatId, required String userId});
  Future<void> archiveChat({required String chatId, required String userId});
  Future<void> unarchiveChat({required String chatId, required String userId});
}

class ChatsRepoImpl implements ChatsRepo {
  const ChatsRepoImpl({
    required ChatsRemoteDataSource chatsRemoteDataSource,
  }) : _chatsRemoteDataSource = chatsRemoteDataSource;

  final ChatsRemoteDataSource _chatsRemoteDataSource;

  @override
  Stream<List<ChatModel>> getChats({required String currentUserId}) {
    return _chatsRemoteDataSource.getChats(currentUserId: currentUserId);
  }

  @override
  Future<void> createChat({
    required String currentUserId,
    required String currentUserEmail,
    required String friendEmail,
  }) {
    return _chatsRemoteDataSource.createChat(
      currentUserId: currentUserId,
      currentUserEmail: currentUserEmail,
      friendEmail: friendEmail,
    );
  }

  @override
  Future<void> deleteChat({required String chatId}) {
    return _chatsRemoteDataSource.deleteChat(chatId: chatId);
  }

  @override
  Stream<List<ChatModel>> searchChats({
    required String currentUserId,
    required String searchText,
  }) {
    return _chatsRemoteDataSource.searchChats(
      currentUserId: currentUserId,
      searchText: searchText,
    );
  }

  @override
  Future<void> pinChat({required String chatId, required String userId}) {
    return _chatsRemoteDataSource.pinChat(chatId: chatId, userId: userId);
  }

  @override
  Future<void> unpinChat({required String chatId, required String userId}) {
    return _chatsRemoteDataSource.unpinChat(chatId: chatId, userId: userId);
  }

  @override
  Future<void> archiveChat({required String chatId, required String userId}) {
    return _chatsRemoteDataSource.archiveChat(chatId: chatId, userId: userId);
  }

  @override
  Future<void> unarchiveChat({required String chatId, required String userId}) {
    return _chatsRemoteDataSource.unarchiveChat(chatId: chatId, userId: userId);
  }
}
