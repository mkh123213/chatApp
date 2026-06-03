import 'package:chat_material3/core/common/dialogs/custom_dialogs.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/calls_history_cubit/calls_history_state.dart';
import 'package:chat_material3/features/calls/presentation/widgets/call_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CallsHistoryBlocConsumer extends StatelessWidget {
  const CallsHistoryBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate(LangKeys.calls),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    BlocBuilder<CallsHistoryCubit, CallsHistoryState>(
                      builder: (context, state) {
                        final count = state is CallsHistoryLoaded
                            ? state.calls.length
                            : 0;
                        return Text(
                          '$count ${context.translate(LangKeys.callHistory).toLowerCase()}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: context.color.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              BlocBuilder<CallsHistoryCubit, CallsHistoryState>(
                builder: (context, state) {
                  if (state is! CallsHistoryLoaded) return const SizedBox.shrink();
                  return IconButton(
                    icon: Icon(Icons.delete_outline, size: 22.sp),
                    onPressed: () {
                      CustomDialog.twoButtonDialog(
                        context: context,
                        textBody: context.translate(LangKeys.deleteAllCallHistoryConfirm),
                        textButton1: context.translate(LangKeys.yes),
                        textButton2: context.translate(LangKeys.cancel),
                        isLoading: false,
                        onPressed: () {
                          context.read<CallsHistoryCubit>().deleteAllCallHistory(
                            currentUserId: getCurrentUser().uid,
                          );
                          context.pop();
                          ShowToast.showToastSuccessTop(
                            message: context.translate(LangKeys.allCallsDeletedSuccessfully),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<CallsHistoryCubit, CallsHistoryState>(
            builder: (context, state) {
              return switch (state) {
                CallsHistoryLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                CallsHistoryLoaded(:final calls) => _GroupedCallsList(calls: calls),
                CallsHistoryEmpty() => Center(
                    child: Text(
                      context.translate(LangKeys.noCallsYet),
                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                    ),
                  ),
                CallsHistoryError(:final message) => Center(
                    child: Text(
                      message,
                      style: TextStyle(fontSize: 14.sp, color: Colors.red),
                    ),
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _GroupedCallsList extends StatelessWidget {
  const _GroupedCallsList({required this.calls});
  final List<CallModel> calls;

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDate(calls);
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
              child: Text(
                group.label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: context.color.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            ...group.calls.map((call) => Dismissible(
                  key: Key(call.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.w),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) {
                    context
                        .read<CallsHistoryCubit>()
                        .deleteCallRecord(callId: call.id);
                    ShowToast.showToastSuccessTop(
                      message: context.translate(LangKeys.callDeletedSuccessfully),
                    );
                  },
                  child: CallHistoryCard(call: call),
                )),
          ],
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<CallModel> calls) {
    final Map<String, List<CallModel>> map = {};
    final Map<String, String> labels = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final call in calls) {
      final date = call.createdAt ?? now;
      final dayStart = DateTime(date.year, date.month, date.day);
      String key;
      String label;
      if (dayStart == today) {
        key = 'today';
        label = 'Today';
      } else if (dayStart == yesterday) {
        key = 'yesterday';
        label = 'Yesterday';
      } else {
        key = dayStart.toIso8601String();
        label = DateFormat('EEE').format(date).toUpperCase();
      }
      map.putIfAbsent(key, () => []);
      map[key]!.add(call);
      labels[key] = label;
    }

    return map.entries
        .map((e) => _DateGroup(label: labels[e.key]!, calls: e.value))
        .toList();
  }
}

class _DateGroup {
  final String label;
  final List<CallModel> calls;
  const _DateGroup({required this.label, required this.calls});
}
