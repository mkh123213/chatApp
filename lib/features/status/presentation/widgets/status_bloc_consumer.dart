import 'package:chat_material3/core/common/loading/empty_screen.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/status/presentation/bloc/status_cubit/status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_section_header.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_user_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          empty: () => EmptyScreen(
            title: context.translate(LangKeys.statusEmpty),
          ),
          loaded: (recent, viewed) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recent.isNotEmpty) ...[
                StatusSectionHeader(
                  title: context.translate(LangKeys.statusRecentUpdates),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recent.length,
                  itemBuilder: (context, index) =>
                      StatusUserCard(status: recent[index], isViewed: false),
                ),
              ],
              if (viewed.isNotEmpty) ...[
                StatusSectionHeader(
                  title: context.translate(LangKeys.statusViewedUpdates),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: viewed.length,
                  itemBuilder: (context, index) =>
                      StatusUserCard(status: viewed[index], isViewed: true),
                ),
              ],
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        );
      },
    );
  }
}
