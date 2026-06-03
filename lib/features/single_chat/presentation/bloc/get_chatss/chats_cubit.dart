import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/data/repositories/chats_repo.dart';

import 'chats_state.dart';

class ChatsCubit extends Cubit<ChatsState> {
  ChatsCubit({
    required ChatsRepo chatsRepo,
  })  : _chatsRepo = chatsRepo,
        super(const ChatsInitial());

  final ChatsRepo _chatsRepo;
  StreamSubscription<List<ChatModel>>? _chatsSubscription;
  bool _isListeningToChats = false;
  List<ChatModel> _allChats = [];

  void getChats({required String currentUserId}) {
    if (_isListeningToChats) return;
    _isListeningToChats = true;

    emit(const ChatsLoading());

    _chatsSubscription =
        _chatsRepo.getChats(currentUserId: currentUserId).listen(
      (chats) {
        if (isClosed) return;
        _allChats = chats;
        if (chats.isEmpty) {
          emit(const ChatsEmpty());
        } else {
          emit(ChatsLoaded(chats: chats));
        }
      },
      onError: (error) {
        if (isClosed) return;
        emit(ChatsError(message: error.toString()));
      },
    );
  }

  void refreshChats({required String currentUserId}) {
    _chatsSubscription?.cancel();
    _isListeningToChats = false;
    getChats(currentUserId: currentUserId);
  }

  void searchChats({
    required String currentUserId,
    required String searchText,
  }) {
    final cleanedSearchText = searchText.trim().toLowerCase();

    if (cleanedSearchText.isEmpty) {
      if (_allChats.isEmpty) {
        emit(const ChatsEmpty());
      } else {
        emit(ChatsSearchLoaded(chats: _allChats));
      }
      return;
    }

    emit(const ChatsSearchLoading());

    final filteredChats = _allChats.where((chat) {
      final usersEmails =
          chat.usersEmails?.map((e) => e.toLowerCase()).toList() ?? [];
      final usersNames =
          chat.usersNames?.map((n) => n.toLowerCase()).toList() ?? [];
      return usersEmails.any((email) => email.contains(cleanedSearchText)) ||
          usersNames.any((name) => name.contains(cleanedSearchText));
    }).toList();

    if (filteredChats.isEmpty) {
      emit(const ChatsSearchEmpty());
    } else {
      emit(ChatsSearchLoaded(chats: filteredChats));
    }
  }

  Future<void> deleteChat({required String chatId}) async {
    try {
      await _chatsRepo.deleteChat(chatId: chatId);
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  Future<void> pinChat({required String chatId, required String userId}) async {
    try {
      await _chatsRepo.pinChat(chatId: chatId, userId: userId);
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  Future<void> unpinChat({required String chatId, required String userId}) async {
    try {
      await _chatsRepo.unpinChat(chatId: chatId, userId: userId);
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  Future<void> archiveChat({required String chatId, required String userId}) async {
    try {
      await _chatsRepo.archiveChat(chatId: chatId, userId: userId);
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  Future<void> unarchiveChat({required String chatId, required String userId}) async {
    try {
      await _chatsRepo.unarchiveChat(chatId: chatId, userId: userId);
    } catch (e) {
      emit(ChatsError(message: e.toString()));
    }
  }

  void clearSearch() {
    emit(ChatsLoaded(chats: _allChats));
  }

  @override
  Future<void> close() async {
    await _chatsSubscription?.cancel();
    return super.close();
  }
}
