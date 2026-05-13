import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/screens/selected_group_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
  });

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _openGroupChat(context),
        child: Container(
          margin: EdgeInsets.only(bottom: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: context.color.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              _GroupAvatar(group: group),
              SizedBox(width: 14.w),
              Expanded(child: _GroupInfo(group: group)),
            ],
          ),
        ),
      ),
    );
  }

  void _openGroupChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectedGroupChatScreen(group: group),
      ),
    );
  }
}

class _GroupAvatar extends StatelessWidget {
  const _GroupAvatar({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final imageUrl = group.imageUrl.trim();
    final initial =
        group.name.trim().isNotEmpty ? group.name.trim()[0].toUpperCase() : '?';

    return Container(
      width: 56.r,
      height: 56.r,
      decoration: BoxDecoration(
        color: context.color.primaryContainer,
        borderRadius: BorderRadius.circular(14.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: context.color.primary,
                ),
              ),
            )
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: CircularProgressIndicator(strokeWidth: 2.w),
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: context.color.primary,
                  ),
                ),
              ),
            ),
    );
  }
}

class _GroupInfo extends StatelessWidget {
  const _GroupInfo({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final lastMessage = group.lastMessage?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextApp(
                text: group.name,
                theme: context.textStyle.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeightHelper.semiBold,
                ),
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            TextApp(
              text: _formatTime(group.lastMessageTime),
              theme: context.textStyle.copyWith(
                fontSize: 11.sp,
                color: context.color.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Expanded(
              child: TextApp(
                text: lastMessage != null && lastMessage.isNotEmpty
                    ? lastMessage
                    : context.translate(LangKeys.noMessagesYet),
                theme: context.textStyle.copyWith(
                  fontSize: 12.sp,
                  color: context.color.onSurfaceVariant,
                ),
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 8.w),
            BlocProvider(
              create: (context) => sl<UnreadMessagesCubit>()
                ..getGroupUnreadMessagesCount(groupId: group.id),
              child: const UnreadCountBadge(),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final isToday = now.year == time.year &&
        now.month == time.month &&
        now.day == time.day;

    if (isToday) return DateFormat('h:mm a').format(time);

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday = yesterday.year == time.year &&
        yesterday.month == time.month &&
        yesterday.day == time.day;

    if (isYesterday) return 'Yesterday';

    if (now.difference(time).inDays < 7) return DateFormat('EEE').format(time);

    return DateFormat('MMM d').format(time);
  }
}
