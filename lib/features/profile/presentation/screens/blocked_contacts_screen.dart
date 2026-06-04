import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/profile/presentation/bloc/blocked_contacts_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BlockedContactsScreen extends StatelessWidget {
  const BlockedContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate(LangKeys.blockedContacts)),
      ),
      body: BlocBuilder<BlockedContactsCubit, BlockedContactsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(child: Text(state.error!));
          }

          if (state.contacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: 64.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No blocked contacts',
                    style: context.textStyle.copyWith(
                      fontSize: 16.sp,
                      color: context.color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: state.contacts.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              indent: 72.w,
              color: context.color.outlineVariant.withValues(alpha: 0.5),
            ),
            itemBuilder: (context, index) {
              final contact = state.contacts[index];
              final displayName = contact.name.isNotEmpty
                  ? contact.name
                  : contact.email;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.person_off,
                    color: Colors.red,
                    size: 22.sp,
                  ),
                ),
                title: Text(
                  displayName,
                  style: context.textStyle.copyWith(fontSize: 15.sp),
                ),
                subtitle: contact.name.isNotEmpty && contact.email.isNotEmpty
                    ? Text(
                        contact.email,
                        style: context.textStyle.copyWith(
                          fontSize: 13.sp,
                          color: context.color.onSurfaceVariant,
                        ),
                      )
                    : null,
                trailing: TextButton(
                  onPressed: () {
                    _showUnblockDialog(context, contact);
                  },
                  child: Text(
                    context.translate(LangKeys.unblockUser),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, BlockedContact contact) {
    final displayName =
        contact.name.isNotEmpty ? contact.name : contact.email;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.translate(LangKeys.unblockUser)),
        content: Text('Unblock $displayName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.translate(LangKeys.cancel)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<BlockedContactsCubit>().unblockUser(
                    currentUserId: getCurrentUser().uid,
                    blockedUserId: contact.userId,
                  );
            },
            child: Text(
              context.translate(LangKeys.unblockUser),
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}
