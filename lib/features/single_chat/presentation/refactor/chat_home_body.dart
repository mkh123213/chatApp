import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/chats_scereen_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatHomeBody extends StatelessWidget {
  const ChatHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: RefreshIndicator(
        onRefresh: () async {
          context
              .read<ChatsCubit>()
              .refreshChats(currentUserId: getCurrentUser().uid);
        },
        child: const ChatsScereenBlocConsumer(),
      ),
    );
  }
}
