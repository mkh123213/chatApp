import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/core/app/data_source/un_read_messages_remote_data_source.dart';
import 'package:chat_material3/core/app/repo/unread_messages_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unread_messages_state.dart';
part 'unread_messages_cubit.freezed.dart';

class UnreadMessagesCubit extends Cubit<UnreadMessagesState> {
  UnreadMessagesCubit({required this.unReadMessagesReo})
      : super(const UnreadMessagesState.initial());
  final UnreadMessagesRepo unReadMessagesReo;
  StreamSubscription<int>? _unreadMessagesSubscription;
// get unread messages in single  chat
  Future<void> getUnreadMessagesCount({required String chatId}) async {
    emit(const UnreadMessagesState.loading());
    _unreadMessagesSubscription?.cancel();

    _unreadMessagesSubscription =
        unReadMessagesReo.getUnreadMessagesCount(chatId: chatId).listen(
      (count) {
        emit(UnreadMessagesState.loaded(count: count));
      },
      onError: (error) {
        emit(UnreadMessagesState.error(message: error.toString()));
      },
    );
  }

  // get unread messages in group chats
  Future<void> getGroupUnreadMessagesCount({required String groupId}) async {
    emit(const UnreadMessagesState.loading());
    _unreadMessagesSubscription?.cancel();

    _unreadMessagesSubscription =
        unReadMessagesReo.getGroupUnreadMessagesCount(groupId: groupId).listen(
      (count) {
        emit(UnreadMessagesState.loaded(count: count));
      },
      onError: (error) {
        emit(UnreadMessagesState.error(message: error.toString()));
      },
    );
  }
}
