import 'package:chat_material3/core/common/loading/empty_screen.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_state.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/chat_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatsScereenBlocConsumer extends StatelessWidget {
  const ChatsScereenBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatsCubit, ChatsState>(
      listener: (context, state) {
        if (state is ChatsSearchEmpty) {
          ShowToast.showToastErrorTop(
            message: context.translate(LangKeys.noChatsFound),
          );
        } else if (state is ChatsError) {
          ShowToast.showToastErrorTop(message: state.message);
        }
      },
      builder: (context, state) {
        return switch (state) {
          ChatsLoading() || ChatsSearchLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          ChatsLoaded(:final chats) => ChatListView(chats: chats),
          ChatsSearchLoaded(:final chats) => ChatListView(chats: chats),
          ChatsEmpty() || ChatsSearchEmpty() => EmptyScreen(
              title: context.translate(LangKeys.noChatsYet),
            ),
          ChatsError(:final message) => EmptyScreen(title: message),
          _ => EmptyScreen(
              title: context.translate(LangKeys.noChatsYet),
            ),
        };
      },
    );
  }
}
