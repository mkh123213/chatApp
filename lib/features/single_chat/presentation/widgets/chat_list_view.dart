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
import 'package:chat_material3/features/single_chat/presentation/bloc/typing_cubit/chat_list_typing_cubit.dart';
import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ChatListView extends StatefulWidget {
  const ChatListView({super.key, required this.chats});

  final List<ChatModel> chats;

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  bool _archivedExpanded = false;

  @override
  void initState() {
    super.initState();
    _watchTyping();
  }

  @override
  void didUpdateWidget(covariant ChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chats.length != widget.chats.length) {
      _watchTyping();
    }
  }

  void _watchTyping() {
    final chatIds = widget.chats.map((c) => c.id).toList();
    if (chatIds.isNotEmpty) {
      context.read<ChatListTypingCubit>().watchChats(chatIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = getCurrentUser().uid;

    final pinnedChats = widget.chats
        .where((c) =>
            c.pinnedBy?.contains(currentUserId) == true &&
            c.archivedBy?.contains(currentUserId) != true)
        .toList();
    final regularChats = widget.chats
        .where((c) =>
            c.pinnedBy?.contains(currentUserId) != true &&
            c.archivedBy?.contains(currentUserId) != true)
        .toList();
    final archivedChats = widget.chats
        .where((c) => c.archivedBy?.contains(currentUserId) == true)
        .toList();

    return BlocBuilder<ChatListTypingCubit, ChatListTypingState>(
      builder: (context, typingState) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          children: [
            if (pinnedChats.isNotEmpty) ...[
              _SectionHeader(
                icon: Icons.push_pin,
                label: context.translate(LangKeys.pinned),
              ),
              ...pinnedChats.map((chat) => _ChatTile(
                    key: ValueKey(chat.id),
                    chat: chat,
                    isPinned: true,
                    isArchived: false,
                    isTyping: typingState.isSomeoneTyping(chat.id, currentUserId),
                  )),
              Divider(
                height: 1,
                color: context.color.outlineVariant.withValues(alpha: 0.5),
              ),
            ],
            ...regularChats.map((chat) => _ChatTile(
                  key: ValueKey(chat.id),
                  chat: chat,
                  isPinned: false,
                  isArchived: false,
                  isTyping: typingState.isSomeoneTyping(chat.id, currentUserId),
                )),
            if (archivedChats.isNotEmpty) ...[
              Divider(
                height: 1,
                color: context.color.outlineVariant.withValues(alpha: 0.5),
              ),
              _ArchivedSection(
                archivedChats: archivedChats,
                expanded: _archivedExpanded,
                onToggle: () => setState(() => _archivedExpanded = !_archivedExpanded),
                typingState: typingState,
                currentUserId: currentUserId,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.sp, color: context.color.onSurfaceVariant),
          SizedBox(width: 6.w),
          Text(
            label,
            style: context.textStyle.copyWith(
              fontSize: 12.sp,
              fontWeight: FontWeightHelper.semiBold,
              color: context.color.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivedSection extends StatelessWidget {
  const _ArchivedSection({
    required this.archivedChats,
    required this.expanded,
    required this.onToggle,
    required this.typingState,
    required this.currentUserId,
  });

  final List<ChatModel> archivedChats;
  final bool expanded;
  final VoidCallback onToggle;
  final ChatListTypingState typingState;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Icon(
                  Icons.archive_outlined,
                  size: 20.sp,
                  color: context.color.onSurfaceVariant,
                ),
                SizedBox(width: 10.w),
                Text(
                  context.translate(LangKeys.archived),
                  style: context.textStyle.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeightHelper.semiBold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${archivedChats.length}',
                  style: context.textStyle.copyWith(
                    fontSize: 13.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20.sp,
                  color: context.color.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          ...archivedChats.map((chat) => _ChatTile(
                key: ValueKey(chat.id),
                chat: chat,
                isPinned: false,
                isArchived: true,
                isTyping: typingState.isSomeoneTyping(chat.id, currentUserId),
              )),
      ],
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

  final userIndex = chat.users.indexOf(currentUserId);
  if (chat.usersNames != null && chat.usersNames!.length >= 2) {
    final friendIndex = userIndex == 0 ? 1 : 0;
    final friendName = chat.usersNames![friendIndex];
    if (friendName.isNotEmpty) return friendName;
  }

  final friendEmail = chat.usersEmails
          ?.where((e) => e.toLowerCase() != currentUserEmail.toLowerCase())
          .firstOrNull ??
      '';
  return friendEmail;
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    super.key,
    required this.chat,
    required this.isPinned,
    required this.isArchived,
    this.isTyping = false,
  });

  final ChatModel chat;
  final bool isPinned;
  final bool isArchived;
  final bool isTyping;

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
      onLongPress: () => _showOptionsDialog(context),
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
                  Row(
                    children: [
                      if (isPinned) ...[
                        Icon(
                          Icons.push_pin,
                          size: 14.sp,
                          color: context.color.onSurfaceVariant,
                        ),
                        SizedBox(width: 4.w),
                      ],
                      Expanded(
                        child: TextApp(
                          text: displayName,
                          theme: context.textStyle.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeightHelper.semiBold,
                          ),
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  if (isTyping)
                    Text(
                      'typing...',
                      style: context.textStyle.copyWith(
                        fontSize: 13.sp,
                        color: const Color(0xFF4CAF50),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
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

  void _showOptionsDialog(BuildContext context) {
    final currentUserId = getCurrentUser().uid;
    final chatsCubit = context.read<ChatsCubit>();

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isArchived) ...[
              ListTile(
                leading: Icon(isPinned ? Icons.push_pin_outlined : Icons.push_pin),
                title: Text(
                  context.translate(
                    isPinned ? LangKeys.unpinChat : LangKeys.pinChat,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  if (isPinned) {
                    chatsCubit.unpinChat(chatId: chat.id, userId: currentUserId);
                  } else {
                    chatsCubit.pinChat(chatId: chat.id, userId: currentUserId);
                  }
                },
              ),
            ],
            ListTile(
              leading: Icon(
                isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
              ),
              title: Text(
                context.translate(
                  isArchived ? LangKeys.unarchiveChat : LangKeys.archiveChat,
                ),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                if (isArchived) {
                  chatsCubit.unarchiveChat(chatId: chat.id, userId: currentUserId);
                } else {
                  chatsCubit.archiveChat(chatId: chat.id, userId: currentUserId);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                context.translate(LangKeys.deleteChat),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showDeleteDialog(context);
              },
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
