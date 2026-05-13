import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/groups_cubit/groups_cubit.dart';
import 'package:chat_material3/features/groups/presentation/widgets/featured_group_card.dart';
import 'package:chat_material3/features/groups/presentation/widgets/group_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupsBlocConsumer extends StatelessWidget {
  const GroupsBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupsCubit, GroupsState>(
      listener: (_, __) {},
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
                  TextApp(
                    text: context.translate(LangKeys.noGroupsYet),
                    theme: context.textStyle
                        .copyWith(fontSize: 16.sp, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          loaded: (groups) => _GroupsListLayout(groups: groups),
          error: (message) => Center(
            child: TextApp(
                text: message,
                theme: context.textStyle
                    .copyWith(fontSize: 16, color: Colors.red)),
          ),
        );
      },
    );
  }
}

class _GroupsListLayout extends StatelessWidget {
  const _GroupsListLayout({required this.groups});
  final List<GroupModel> groups;

  @override
  Widget build(BuildContext context) {
    final featured = groups.take(2).toList();
    final rest = groups.skip(2).toList();

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
        child: GroupCard(group: groups[index]),
      ),
      // children: [
      //   ...featured.map((g) => Padding(
      //         padding: EdgeInsets.only(bottom: 12.h),
      //         child: FeaturedGroupCard(group: g),
      //       )),
      //   if (rest.isNotEmpty) ...[
      //     Padding(
      //       padding: EdgeInsets.only(top: 4.h, bottom: 10.h),
      //       child: TextApp(
      //         text: context.translate(LangKeys.allGroups),
      //         theme: context.textStyle.copyWith(
      //           fontSize: 11.sp,
      //           fontWeight: FontWeightHelper.semiBold,
      //         ),
      //       ),
      //     ),
      //     ...rest.map((g) => GroupCard(group: g)),
      //   ],
      //   SizedBox(height: 16.h),
      // ],
    );
  }
}
