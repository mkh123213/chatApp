import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key, required this.chats});

  final List<ChatModel> chats;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _ChatCard(chat: chat);
      },
    );
  }
}

class _ChatCard extends StatelessWidget {
  const _ChatCard({required this.chat});

  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    final currentUser = getCurrentUser();
    final currentUserId = currentUser.uid;
    final currentUserEmail = currentUser.email ?? '';
    final friendEmail = chat.usersEmails
            ?.where((e) => e.toLowerCase() != currentUserEmail.toLowerCase())
            .firstOrNull ??
        '';

    final timeText = chat.lastMessageTime != null
        ? DateFormat.jm().format(chat.lastMessageTime!)
        : '';

    return Card(
      // color: context.color.primaryContainer,
      child: ListTile(
        onTap: () => context.pushName(
          AppRoutes.singleChat,
          arguments: chat,
        ),
        leading: CircleAvatar(
          // backgroundColor: context.color.surface,
          child: TextApp(
            text: friendEmail.isNotEmpty ? friendEmail[0].toUpperCase() : '?',
            theme: context.textStyle.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeightHelper.bold,
            ),
          ),
        ),
        title: TextApp(
          text: friendEmail,
          theme: context.textStyle.copyWith(
            fontSize: 16.sp,
          ),
        ),
        subtitle: TextApp(
          text: chat.lastMessage ?? '',
          theme: context.textStyle.copyWith(fontSize: 12.sp),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextApp(
              text: timeText,
              theme: context.textStyle
                  .copyWith(fontSize: 12.sp, color: context.color.primary),
            ),
            const SizedBox(height: 4),
            BlocProvider(
              create: (context) => sl<UnreadMessagesCubit>()
                ..getUnreadMessagesCount(chatId: chat.id),
              child: UnreadCountBadge(
                size: 22.r,
                backgroundColor: context.color.primary,
                textColor: context.color.onPrimary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
