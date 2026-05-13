import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGroupBlocConsumer extends StatelessWidget {
  const CreateGroupBlocConsumer(
      {super.key,
      required this.groupNameController,
      required this.membersEmailsController});
  final TextEditingController groupNameController;
  final TextEditingController membersEmailsController;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateGroupCubit, CreateGroupState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            ShowToast.showToastSuccessTop(
                message: context.translate(LangKeys.groupCreatedSuccessfully));
            Navigator.pop(context);
          },
          error: (message) => ShowToast.showToastErrorTop(message: message),
        );
      },
      builder: (context, state) {
        if (state is Loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: CustomLinearButton(
            onPressed: () {
              final groupName = groupNameController.text.trim();
              if (groupName.isEmpty) return;
              final currentUser = getCurrentUser();
              final emails = membersEmailsController.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
              context.read<CreateGroupCubit>().createGroup(
                    currentUserId: currentUser.uid,
                    currentUserEmail: currentUser.email ?? '',
                    groupName: groupName,
                    membersIds: [currentUser.uid],
                    membersEmails: emails,
                  );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextApp(
                  text: context.translate(LangKeys.createGroup),
                  theme: context.textStyle),
            ),
          ),
        );
      },
    );
  }
}
