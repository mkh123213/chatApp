import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/screens/selected_group_chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class FeaturedGroupCard extends StatelessWidget {
  const FeaturedGroupCard({super.key, required this.group});
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.pushName(AppRoutes.selectedGroupChat, arguments: group),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: context.color.primaryContainer,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _MemberAvatarStack(
                    emails: group.membersEmails, count: group.members.length),
                const Spacer(),
                _TimeWidget(time: group.lastMessageTime),
                SizedBox(width: 8.w),
                _UnreadBadge(groupId: group.id),
              ],
            ),
            highspace(height: 10.h),
            TextApp(
              text: group.lastMessage?.isNotEmpty == true
                  ? group.lastMessage!
                  : group.name,
              theme: context.textStyle,
            ),
            highspace(height: 4.h),
            TextApp(
              text: group.lastMessage?.isNotEmpty == true
                  ? group.lastMessage!
                  : 'No messages yet',
              theme: context.textStyle,
            ),
            highspace(height: 8.h),
            TextApp(
              text: '${group.members.length} Members',
              theme: context.textStyle,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberAvatarStack extends StatelessWidget {
  const _MemberAvatarStack({required this.emails, required this.count});
  final List<String> emails;
  final int count;

  @override
  Widget build(BuildContext context) {
    final display = emails.take(3).toList();
    final extra = count - display.length;
    final totalWidth = display.length * 22.0 + (extra > 0 ? 30.0 : 0);

    return SizedBox(
      width: totalWidth,
      height: 34.h,
      child: Stack(
        children: [
          ...display.asMap().entries.map((e) => Positioned(
                left: e.key * 22.0,
                child: _InitialAvatar(email: e.value, size: 25.r),
              )),
          if (extra > 0)
            Positioned(
              left: display.length * 22.0,
              child: Container(
                width: 30.r,
                height: 30.r,
                decoration: BoxDecoration(
                  color: context.color.secondaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extra',
                    style: context.textStyle.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeightHelper.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.email, required this.size});
  final String email;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.color.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: TextApp(
          text: initial,
          theme: context.textStyle.copyWith(
            fontSize: size * 0.38,
            fontWeight: FontWeightHelper.bold,
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UnreadMessagesCubit>()
        ..getGroupUnreadMessagesCount(groupId: groupId),
      child: UnreadCountBadge(),
    );
  }
}

class _TimeWidget extends StatelessWidget {
  const _TimeWidget({required this.time});
  final DateTime? time;

  @override
  Widget build(BuildContext context) {
    if (time == null) return const SizedBox.shrink();
    final now = DateTime.now();
    final diff = now.difference(time!);
    final isToday = diff.inHours < 24 && now.day == time!.day;

    if (isToday) {
      return Row(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          TextApp(
            text: DateFormat('h:mm a').format(time!),
            theme: context.textStyle.copyWith(
              fontSize: 11.sp,
            ),
          ),
        ],
      );
    }

    final label =
        diff.inDays == 1 ? 'Yesterday' : DateFormat('MMM d').format(time!);
    return TextApp(
      text: label,
      theme: context.textStyle.copyWith(fontSize: 11.sp),
    );
  }
}
