import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart';
import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatListView extends StatelessWidget {
  const ChatListView({super.key, required this.chats});

  final List<ChatModel> chats;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      itemCount: chats.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 76.w,
        color: context.color.outlineVariant.withValues(alpha: 0.5),
      ),
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _ChatTile(key: ValueKey(chat.id), chat: chat);
      },
    );
  }
}

const List<Color> _avatarColors = [
  Color(0xFFEF5350),
  Color(0xFF42A5F5),
  Color(0xFF66BB6A),
  Color(0xFFFFA726),
  Color(0xFFAB47BC),
  Color(0xFF26C6DA),
  Color(0xFFEC407A),
  Color(0xFF8D6E63),
];

Color _getAvatarColor(String text) {
  final hash = text.codeUnits.fold<int>(0, (prev, c) => prev + c);
  return _avatarColors[hash % _avatarColors.length];
}

String _getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  // Fallback for single-word or email-based names
  final cleanName = name.split('@').first;
  final nameParts = cleanName.split(RegExp(r'[._\-]'));
  if (nameParts.length >= 2) {
    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  }
  return cleanName.length >= 2
      ? '${cleanName[0]}${cleanName[1]}'.toUpperCase()
      : cleanName[0].toUpperCase();
}

String _formatTime(DateTime? time) {
  if (time == null) return '';
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inDays == 0 && now.day == time.day) {
    return DateFormat.jm().format(time);
  } else if (diff.inDays == 1 || (diff.inDays == 0 && now.day != time.day)) {
    return 'Yesterday';
  } else if (diff.inDays < 7) {
    return DateFormat.E().format(time);
  }
  return DateFormat.MMMd().format(time);
}

String _getFriendDisplayName(ChatModel chat) {
  final currentUser = getCurrentUser();
  final currentUserId = currentUser.uid;
  final currentUserEmail = currentUser.email ?? '';

  // Try to find friend name from usersNames
  final userIndex = chat.users.indexOf(currentUserId);
  if (chat.usersNames != null && chat.usersNames!.length >= 2) {
    final friendIndex = userIndex == 0 ? 1 : 0;
    final friendName = chat.usersNames![friendIndex];
    if (friendName.isNotEmpty) return friendName;
  }

  // Fallback to email
  final friendEmail = chat.usersEmails
          ?.where((e) => e.toLowerCase() != currentUserEmail.toLowerCase())
          .firstOrNull ??
      '';
  return friendEmail;
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({super.key, required this.chat});

  final ChatModel chat;

  @override
  Widget build(BuildContext context) {
    final displayName = _getFriendDisplayName(chat);
    final initials = _getInitials(displayName);
    final avatarColor = _getAvatarColor(displayName);
    final timeText = _formatTime(chat.lastMessageTime);

    return InkWell(
      onTap: () => context.pushName(
        AppRoutes.singleChat,
        arguments: chat,
      ),
      onLongPress: () => _showDeleteDialog(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26.r,
              backgroundColor: avatarColor,
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextApp(
                    text: displayName,
                    theme: context.textStyle.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeightHelper.semiBold,
                    ),
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  TextApp(
                    text: chat.lastMessage ?? '',
                    theme: context.textStyle.copyWith(
                      fontSize: 13.sp,
                      color: context.color.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextApp(
                  text: timeText,
                  theme: context.textStyle.copyWith(
                    fontSize: 12.sp,
                    color: context.color.primary,
                  ),
                ),
                SizedBox(height: 6.h),
                BlocProvider(
                  create: (context) => sl<UnreadMessagesCubit>()
                    ..getUnreadMessagesCount(chatId: chat.id),
                  child: UnreadCountBadge(
                    size: 20.r,
                    backgroundColor: context.color.primary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.translate(LangKeys.deleteChat)),
        content: Text(context.translate(LangKeys.deleteChatConfirm)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.translate(LangKeys.cancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ChatsCubit>().deleteChat(chatId: chat.id);
              ShowToast.showToastSuccessTop(
                message: context.translate(LangKeys.chatDeletedSuccessfully),
              );
            },
            child: Text(
              context.translate(LangKeys.deleteChat),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
