import 'package:chat_material3/core/common/dialogs/custom_dialogs.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/custom_linear_button.dart';
import 'package:chat_material3/core/common/widgets/custom_text_field.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/spacing.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart';
import 'package:chat_material3/features/groups/presentation/refactor/selected_group_chat_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectedGroupChatScreen extends StatelessWidget {
  const SelectedGroupChatScreen({
    super.key,
    required this.group,
  });

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SelectedGroupChatCubit>(
      create: (_) => sl<SelectedGroupChatCubit>(),
      child: SafeArea(
        child: Column(
          children: [
            _GroupChatHeader(group: group),
            Expanded(
              child: SelectedGroupChatBody(group: group),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupChatHeader extends StatelessWidget {
  const _GroupChatHeader({
    required this.group,
  });

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedGroupChatCubit, SelectedGroupChatState>(
      builder: (context, state) {
        final cubit = context.read<SelectedGroupChatCubit>();
        final selectedCount = cubit.selectedMessageIds.length;

        if (selectedCount > 0) {
          return _SelectedMessagesHeader(
            group: group,
            cubit: cubit,
            selectedCount: selectedCount,
          );
        }

        return _buildNormalHeader(context);
      },
    );
  }

  Widget _buildNormalHeader(BuildContext context) {
    final initial = group.name.isNotEmpty ? group.name[0].toUpperCase() : '?';

    return ChatAppBar(
      title: group.name,
      subtitle: TextApp(
        text: '${group.members.length} ${context.translate(LangKeys.members)}',
        theme: context.textStyle.copyWith(
          fontSize: 11.sp,
          color: context.color.onSurface.withAlpha(150),
        ),
      ),
      avatar: CircleAvatar(
        radius: 20.r,
        backgroundColor: context.color.primaryContainer,
        backgroundImage:
            group.imageUrl.isNotEmpty ? NetworkImage(group.imageUrl) : null,
        child: group.imageUrl.isEmpty
            ? TextApp(
                text: initial,
                theme: context.textStyle.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeightHelper.bold,
                  color: context.color.primary,
                ),
              )
            : null,
      ),
      onTitleTap: () => context.pushName(AppRoutes.groupInfo, arguments: group),
      actions: [
        IconButton(
          icon: Icon(Icons.videocam_outlined, color: context.color.onSurface),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.call_outlined, color: context.color.onSurface),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: context.color.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SelectedMessagesHeader extends StatelessWidget {
  const _SelectedMessagesHeader({
    required this.group,
    required this.cubit,
    required this.selectedCount,
  });

  final GroupModel group;
  final SelectedGroupChatCubit cubit;
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    return ChatSelectedAppBar(
      selectedCount: selectedCount,
      onClose: cubit.clearSelection,
      onEdit: selectedCount == 1
          ? () {
              final messageId = cubit.selectedMessageIds.first;
              final messages = cubit.state.maybeWhen(
                loaded: (msgs, _) => msgs,
                orElse: () => null,
              );
              if (messages == null) return;

              final msg = messages.firstWhere(
                (m) => m.id == messageId,
                orElse: () => throw StateError('message not found'),
              );

              if (msg.type == GroupMessageType.text ||
                  msg.type == GroupMessageType.link) {
                _showEditDialog(context, cubit, messageId, msg.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Only text messages can be edited.'),
                  ),
                );
              }
            }
          : null,
      onDelete: () => _showDeleteConfirmDialog(context, cubit),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SelectedGroupChatCubit cubit,
    String messageId,
    String oldText,
  ) {
    final controller = TextEditingController(text: oldText);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: TextApp(
          text: context.translate(LangKeys.editMessage),
          theme: context.textStyle.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeightHelper.bold,
          ),
        ),
        content: CustomTextField(
          controller: controller,
          maxLines: 4,
          hintText: context.translate(LangKeys.enterMessage),
        ),
        actions: [
          CustomLinearButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextApp(
                    text: context.translate(LangKeys.cancel),
                    theme: context.textStyle.copyWith(color: Colors.white)),
              )),
          highspace(height: 10.h),
          CustomLinearButton(
            onPressed: () {
              final newText = controller.text.trim();

              if (newText.isEmpty) return;

              cubit.updateGroupMessage(
                groupId: group.id,
                messageId: messageId,
                text: newText,
              );

              cubit.clearSelection();
              Navigator.pop(dialogContext);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextApp(
                  text: context.translate(LangKeys.save),
                  theme: context.textStyle.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    SelectedGroupChatCubit cubit,
  ) {
    CustomDialog.twoButtonDialog(
      context: context,
      textBody: context.translate(LangKeys.deleteMessage),
      textButton1: context.translate(LangKeys.yes),
      textButton2: context.translate(LangKeys.no),
      isLoading: false,
      onPressed: () {
        cubit.removeSelectedMessages(
          groupId: group.id,
        );
        cubit.clearSelection();
        context.pop();
      },
    );
  }
}
