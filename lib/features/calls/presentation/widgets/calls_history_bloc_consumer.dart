import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/calls_history_cubit/calls_history_state.dart';
import 'package:chat_material3/features/calls/presentation/widgets/call_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallsHistoryBlocConsumer extends StatelessWidget {
  const CallsHistoryBlocConsumer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallsHistoryCubit, CallsHistoryState>(
      builder: (context, state) {
        return switch (state) {
          CallsHistoryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          CallsHistoryLoaded(:final calls) => ListView.builder(
              itemCount: calls.length,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemBuilder: (context, index) {
                final call = calls[index];
                return Dismissible(
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
                      message: context
                          .translate(LangKeys.callDeletedSuccessfully),
                    );
                  },
                  child: CallHistoryCard(call: call),
                );
              },
            ),
          CallsHistoryEmpty() => Center(
              child: TextApp(
                text: context.translate(LangKeys.noCallsYet),
                theme: context.textStyle.copyWith(
                  fontSize: 16.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          CallsHistoryError(:final message) => Center(
              child: TextApp(
                text: message,
                theme: context.textStyle.copyWith(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
            ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
