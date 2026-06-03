import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/groups_cubit/groups_cubit.dart';
import 'package:chat_material3/features/groups/presentation/widgets/group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupsBlocConsumer extends StatelessWidget {
  const GroupsBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsCubit, GroupsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          empty: () => Center(
            child: Padding(
              padding: EdgeInsets.all(32.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.group_outlined,
                      size: 64.sp, color: Colors.grey.shade300),
                  SizedBox(height: 16.h),
                  Text(
                    context.translate(LangKeys.noGroupsYet),
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          loaded: (groups) => _GroupsList(groups: groups),
          error: (message) => Center(
            child: Text(
              message,
              style: TextStyle(fontSize: 16.sp, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({required this.groups});
  final List<GroupModel> groups;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
          child: Text(
            '${groups.length} ${context.translate(LangKeys.groups).toLowerCase()}',
            style: TextStyle(
              fontSize: 13.sp,
              color: context.color.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) => GroupCard(
              key: ValueKey(groups[index].id),
              group: groups[index],
            ),
          ),
        ),
      ],
    );
  }
}
