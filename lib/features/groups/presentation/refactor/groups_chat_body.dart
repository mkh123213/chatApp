import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/groups/presentation/bloc/groups_cubit/groups_cubit.dart';
import 'package:chat_material3/features/groups/presentation/widgets/groups_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupsChatBody extends StatefulWidget {
  const GroupsChatBody({super.key});

  @override
  State<GroupsChatBody> createState() => _GroupsChatBodyState();
}

class _GroupsChatBodyState extends State<GroupsChatBody> {
  late final String _userInitial;

  @override
  void initState() {
    super.initState();
    final user = getCurrentUser();
    context.read<GroupsCubit>().getGroups(currentUserId: user.uid);
    final email = user.email ?? '';
    _userInitial = email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupsHeader(userInitial: _userInitial),
        _YourGroupsBar(),
        const Expanded(child: GroupsBlocConsumer()),
      ],
    );
  }
}

class _GroupsHeader extends StatelessWidget {
  const _GroupsHeader({required this.userInitial});
  final String userInitial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: context.color.surfaceContainerHigh,
            child: Text(
              userInitial,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: context.color.primary,
              ),
            ),
          ),
          const Spacer(),
          Text(
            context.translate(LangKeys.groups),
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeightHelper.bold,
              color: context.color.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.search,
                color: context.color.onSurface, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _YourGroupsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 16.w, 8.h),
      child: Row(
        children: [
          Text(
            context.translate(LangKeys.yourGroups),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeightHelper.semiBold,
              color: context.color.onSurface,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(
              context.translate(LangKeys.allGroups),
              style: TextStyle(
                fontSize: 13.sp,
                color: context.color.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
