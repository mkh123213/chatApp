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
  @override
  void initState() {
    super.initState();
    final user = getCurrentUser();
    context.read<GroupsCubit>().getGroups(currentUserId: user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
          child: Text(
            context.translate(LangKeys.groups),
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeightHelper.bold,
              color: context.color.onSurface,
            ),
          ),
        ),
        const Expanded(child: GroupsBlocConsumer()),
      ],
    );
  }
}
