import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:chat_material3/features/status/presentation/bloc/status_cubit/status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_section_header.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBlocConsumer extends StatelessWidget {
  const StatusBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StatusCubit, StatusState>(
      listener: (context, state) {
        state.maybeWhen(
          error: (message) => ShowToast.showToastErrorTop(message: message),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loading: () => const Center(child: CircularProgressIndicator()),
          empty: () => Center(
            child: Padding(
              padding: EdgeInsets.all(32.r),
              child: Text(
                context.translate(LangKeys.statusEmpty),
                style: TextStyle(
                  fontSize: 15.sp,
                  color: context.color.onSurfaceVariant,
                ),
              ),
            ),
          ),
          loaded: (recent, viewed) {
            final recentGrouped = _groupByUser(recent);
            final viewedGrouped = _groupByUser(viewed);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recentGrouped.isNotEmpty) ...[
                  StatusSectionHeader(
                    title: context.translate(LangKeys.statusRecentUpdates),
                  ),
                  ...recentGrouped.map((group) => StatusUserCard(
                        statuses: group,
                        isViewed: false,
                      )),
                ],
                if (viewedGrouped.isNotEmpty) ...[
                  StatusSectionHeader(
                    title: context.translate(LangKeys.statusViewedUpdates),
                  ),
                  ...viewedGrouped.map((group) => StatusUserCard(
                        statuses: group,
                        isViewed: true,
                      )),
                ],
              ],
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }

  List<List<StatusModel>> _groupByUser(List<StatusModel> statuses) {
    final map = <String, List<StatusModel>>{};
    for (final s in statuses) {
      map.putIfAbsent(s.userId, () => []).add(s);
    }
    final groups = map.values.toList();
    groups.sort((a, b) {
      final aTime = a.first.createdAt ?? DateTime(2000);
      final bTime = b.first.createdAt ?? DateTime(2000);
      return bTime.compareTo(aTime);
    });
    return groups;
  }
}
