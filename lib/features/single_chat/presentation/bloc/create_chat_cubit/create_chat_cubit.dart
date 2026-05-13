import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/repositories/chats_repo.dart';

import 'create_chat_state.dart';

class CreateChatCubit extends Cubit<CreateChatState> {
  CreateChatCubit({required ChatsRepo chatsRepo})
      : _chatsRepo = chatsRepo,
        super(const CreateChatInitial());

  final ChatsRepo _chatsRepo;

  Future<void> createChat({
    required String currentUserId,
    required String currentUserEmail,
    required String friendEmail,
  }) async {
    emit(const CreateChatLoading());

    try {
      await _chatsRepo.createChat(
        currentUserId: currentUserId,
        currentUserEmail: currentUserEmail,
        friendEmail: friendEmail,
      );
      emit(const CreateChatSuccess());
    } catch (error) {
      emit(CreateChatError(message: error.toString()));
    }
  }
}
