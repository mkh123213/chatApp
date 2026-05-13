import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/app_back_button.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/group_info_cubit/group_info_cubit.dart';
import 'package:chat_material3/features/groups/presentation/widgets/media_links_docs_screen.dart';
import 'package:chat_material3/features/single_chat/data/datasources/chats_remote_data_source.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupInfoScreen extends StatelessWidget {
  const GroupInfoScreen({super.key, required this.group});
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GroupInfoCubit>(
      create: (_) => sl<GroupInfoCubit>()..watchGroup(groupId: group.id),
      child: _GroupInfoContent(initialGroup: group),
    );
  }
}

class _GroupInfoContent extends StatefulWidget {
  const _GroupInfoContent({required this.initialGroup});
  final GroupModel initialGroup;

  @override
  State<_GroupInfoContent> createState() => _GroupInfoContentState();
}

class _GroupInfoContentState extends State<_GroupInfoContent> {
  late final String _currentUserId;
  late final String _currentUserEmail;
  bool _muteNotifications = false;

  @override
  void initState() {
    super.initState();
    final user = getCurrentUser();
    _currentUserId = user.uid;
    _currentUserEmail = user.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroupInfoCubit, GroupInfoState>(
      listener: (context, state) {
        if (state is GroupInfoExited) {
          ShowToast.showToastSuccessTop(
              message: context.translate(LangKeys.groupLeftSuccessfully));
          Navigator.of(context)
            ..pop()
            ..pop();
        }
        if (state is GroupInfoActionError) {
          ShowToast.showToastErrorTop(message: state.message);
        }
      },
      builder: (context, state) {
        final group = switch (state) {
          GroupInfoLoaded(:final group) => group,
          GroupInfoActionError(:final group) => group,
          _ => widget.initialGroup,
        };
        final isLoading = state is GroupInfoLoading;

        return Scaffold(
          backgroundColor: context.color.background,
          appBar: _GroupInfoAppBar(),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : _GroupInfoBody(
                  group: group,
                  currentUserId: _currentUserId,
                  currentUserEmail: _currentUserEmail,
                  muteNotifications: _muteNotifications,
                  onMuteChanged: (v) => setState(() => _muteNotifications = v),
                ),
        );
      },
    );
  }
}

class _GroupInfoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GroupInfoAppBar();

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.color.surface,
      elevation: 0,
      leading: const AppBackButton(),
      title: Text(
        'Group Info',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: context.color.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: context.color.primary),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _GroupInfoBody extends StatelessWidget {
  const _GroupInfoBody({
    required this.group,
    required this.currentUserId,
    required this.currentUserEmail,
    required this.muteNotifications,
    required this.onMuteChanged,
  });
  final GroupModel group;
  final String currentUserId;
  final String currentUserEmail;
  final bool muteNotifications;
  final ValueChanged<bool> onMuteChanged;

  bool get _isAdmin => group.admins.contains(currentUserId);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          _ProfileHeaderCard(group: group),
          SizedBox(height: 12.h),
          _MembersCard(
            group: group,
            currentUserId: currentUserId,
            currentUserEmail: currentUserEmail,
            isAdmin: _isAdmin,
          ),
          SizedBox(height: 12.h),
          _SettingsCard(
            muteNotifications: muteNotifications,
            onMuteChanged: onMuteChanged,
          ),
          SizedBox(height: 12.h),
          _LeaveGroupTile(
            group: group,
            currentUserId: currentUserId,
            currentUserEmail: currentUserEmail,
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.group});
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final initial =
        group.name.isNotEmpty ? group.name[0].toUpperCase() : '?';

    return _InfoCard(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundColor: context.color.primaryContainer,
                backgroundImage: group.imageUrl.isNotEmpty
                    ? NetworkImage(group.imageUrl)
                    : null,
                child: group.imageUrl.isEmpty
                    ? Text(
                        initial,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: context.color.primary,
                        ),
                      )
                    : null,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            group.name,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: context.color.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Text(
            'Created ${_formatDate(group.createdAt)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: context.color.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: context.color.outlineVariant, height: 1),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: context.color.primary,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MediaLinksDocsScreen(groupId: group.id),
              ),
            ),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: context.color.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: context.color.surface,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.perm_media_outlined,
                      size: 18.sp,
                      color: context.color.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Media, Links & Docs',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.color.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: context.color.onSurfaceVariant,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'unknown date';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.group,
    required this.currentUserId,
    required this.currentUserEmail,
    required this.isAdmin,
  });
  final GroupModel group;
  final String currentUserId;
  final String currentUserEmail;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    final displayed = group.membersEmails.take(4).toList();
    final remaining = group.membersEmails.length - displayed.length;

    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Members',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: context.color.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: context.color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  '${group.members.length} members',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.color.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (isAdmin)
            _AddMemberButton(
              group: group,
              currentUserId: currentUserId,
              currentUserEmail: currentUserEmail,
            ),
          if (isAdmin) SizedBox(height: 8.h),
          ...displayed.asMap().entries.map((e) {
            final email = e.value;
            final idx = group.membersEmails.indexOf(email);
            final uid =
                idx >= 0 && idx < group.members.length
                    ? group.members[idx]
                    : '';
            final isCurrentUser = uid == currentUserId;
            final memberIsAdmin = group.admins.contains(uid);

            return _MemberRow(
              email: email,
              uid: uid,
              isCurrentUser: isCurrentUser,
              isAdmin: memberIsAdmin,
              canManage: isAdmin && !isCurrentUser,
              group: group,
            );
          }),
          if (remaining > 0) ...[
            SizedBox(height: 4.h),
            Center(
              child: TextButton(
                onPressed: () => _showAllMembers(context),
                child: Text(
                  'View all ${group.members.length} members',
                  style: TextStyle(
                    color: context.color.primary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAllMembers(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<GroupInfoCubit>(),
        child: _AllMembersSheet(
          group: group,
          currentUserId: currentUserId,
          isAdmin: isAdmin,
        ),
      ),
    );
  }
}

class _AddMemberButton extends StatelessWidget {
  const _AddMemberButton({
    required this.group,
    required this.currentUserId,
    required this.currentUserEmail,
  });
  final GroupModel group;
  final String currentUserId;
  final String currentUserEmail;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => _showAddMemberDialog(context),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.color.outlineVariant,
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                color: context.color.surfaceContainerHigh,
              ),
              child: Icon(
                Icons.person_add_outlined,
                color: context.color.primary,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              context.translate(LangKeys.addMember),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: context.color.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final controller = TextEditingController();
    final cubit = context.read<GroupInfoCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.translate(LangKeys.addMember),
          style: TextStyle(
            color: context.color.primary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: context.translate(LangKeys.enterMemberEmail),
            hintStyle:
                TextStyle(color: context.color.onSurfaceVariant),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: context.color.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.translate(LangKeys.cancel),
              style:
                  TextStyle(color: context.color.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              final email = controller.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              cubit
                  .addMemberByEmail(
                      groupId: group.id, memberEmail: email)
                  .then((_) {
                if (cubit.state is! GroupInfoActionError) {
                  ShowToast.showToastSuccessTop(
                      message: 'Member added successfully');
                }
              });
            },
            child: Text(
              context.translate(LangKeys.addMember),
              style: TextStyle(
                color: context.color.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.email,
    required this.uid,
    required this.isCurrentUser,
    required this.isAdmin,
    required this.canManage,
    required this.group,
  });
  final String email;
  final String uid;
  final bool isCurrentUser;
  final bool isAdmin;
  final bool canManage;
  final GroupModel group;

  Future<void> _startChatWithMember(BuildContext context) async {
    final currentUser = getCurrentUser();
    final currentUserId = currentUser.uid;
    final currentUserEmail = currentUser.email ?? '';

    try {
      final dataSource = sl<ChatsRemoteDataSource>();
      final existingChats =
          await dataSource.getChats(currentUserId: currentUserId).first;

      ChatModel? existingChat;
      for (final chat in existingChats) {
        if (chat.users.contains(uid)) {
          existingChat = chat;
          break;
        }
      }

      if (existingChat != null) {
        if (context.mounted) {
          Navigator.pushNamed(context, AppRoutes.singleChat,
              arguments: existingChat);
        }
      } else {
        await dataSource.createChat(
          currentUserId: currentUserId,
          currentUserEmail: currentUserEmail,
          friendEmail: email,
        );
        final chats =
            await dataSource.getChats(currentUserId: currentUserId).first;
        final newChat = chats.firstWhere((c) => c.users.contains(uid));
        if (context.mounted) {
          Navigator.pushNamed(context, AppRoutes.singleChat,
              arguments: newChat);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ShowToast.showToastErrorTop(message: e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final displayName = isCurrentUser ? 'You' : email;

    return InkWell(
      onTap: isCurrentUser ? null : () => _startChatWithMember(context),
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: context.color.secondaryContainer,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: context.color.primary,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: context.color.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAdmin) ...[
                        SizedBox(width: 6.w),
                        _Badge(
                            label: 'ADMIN',
                            color: context.color.primary),
                      ],
                    ],
                  ),
                  Text(
                    isCurrentUser ? email : 'Member',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.color.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (canManage)
              _MemberOptionsButton(
                group: group,
                uid: uid,
                email: email,
                isAdmin: isAdmin,
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          color: context.color.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _MemberOptionsButton extends StatelessWidget {
  const _MemberOptionsButton({
    required this.group,
    required this.uid,
    required this.email,
    required this.isAdmin,
  });
  final GroupModel group;
  final String uid;
  final String email;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert,
          color: context.color.onSurfaceVariant, size: 20.sp),
      onSelected: (value) {
        final cubit = context.read<GroupInfoCubit>();
        final adminGrantedMsg =
            context.translate(LangKeys.adminGranted);
        final adminRevokedMsg =
            context.translate(LangKeys.adminRevoked);
        final removedMsg =
            context.translate(LangKeys.memberRemovedSuccessfully);
        switch (value) {
          case 'make_admin':
            cubit.makeAdmin(groupId: group.id, userId: uid).then((_) {
              if (cubit.state is! GroupInfoActionError) {
                ShowToast.showToastSuccessTop(message: adminGrantedMsg);
              }
            });
          case 'remove_admin':
            cubit.removeAdmin(groupId: group.id, userId: uid).then((_) {
              if (cubit.state is! GroupInfoActionError) {
                ShowToast.showToastSuccessTop(message: adminRevokedMsg);
              }
            });
          case 'remove':
            cubit
                .removeMember(
                    groupId: group.id, userId: uid, userEmail: email)
                .then((_) {
              if (cubit.state is! GroupInfoActionError) {
                ShowToast.showToastSuccessTop(message: removedMsg);
              }
            });
        }
      },
      itemBuilder: (_) => [
        if (!isAdmin)
          PopupMenuItem(
            value: 'make_admin',
            child: Row(children: [
              Icon(Icons.admin_panel_settings_outlined,
                  size: 18.sp, color: context.color.primary),
              SizedBox(width: 8.w),
              Text(context.translate(LangKeys.makeAdmin),
                  style: TextStyle(fontSize: 13.sp)),
            ]),
          ),
        if (isAdmin)
          PopupMenuItem(
            value: 'remove_admin',
            child: Row(children: [
              Icon(Icons.remove_moderator_outlined,
                  size: 18.sp, color: Colors.orange),
              SizedBox(width: 8.w),
              Text(context.translate(LangKeys.removeAdmin),
                  style: TextStyle(fontSize: 13.sp)),
            ]),
          ),
        PopupMenuItem(
          value: 'remove',
          child: Row(children: [
            Icon(Icons.person_remove_outlined,
                size: 18.sp, color: Colors.red),
            SizedBox(width: 8.w),
            Text(context.translate(LangKeys.removeMember),
                style:
                    TextStyle(fontSize: 13.sp, color: Colors.red)),
          ]),
        ),
      ],
    );
  }
}

class _AllMembersSheet extends StatelessWidget {
  const _AllMembersSheet({
    required this.group,
    required this.currentUserId,
    required this.isAdmin,
  });
  final GroupModel group;
  final String currentUserId;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (_, controller) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.color.outlineVariant,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Text(
                  'All Members',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: context.color.primary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: context.color.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${group.members.length} total',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: context.color.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: group.membersEmails.length,
                itemBuilder: (_, i) {
                  final email = group.membersEmails[i];
                  final uid =
                      i < group.members.length ? group.members[i] : '';
                  final isCurrentUser = uid == currentUserId;
                  final memberIsAdmin = group.admins.contains(uid);
                  return _MemberRow(
                    email: email,
                    uid: uid,
                    isCurrentUser: isCurrentUser,
                    isAdmin: memberIsAdmin,
                    canManage: isAdmin && !isCurrentUser,
                    group: group,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.muteNotifications,
    required this.onMuteChanged,
  });
  final bool muteNotifications;
  final ValueChanged<bool> onMuteChanged;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: context.color.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: context.color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.notifications_off_outlined,
                    size: 20.sp, color: context.color.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate(LangKeys.muteNotifications),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.color.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Silence alerts for this group',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: muteNotifications,
                onChanged: onMuteChanged,
                activeThumbColor: context.color.primary,
              ),
            ],
          ),
          Divider(height: 20.h, color: context.color.outlineVariant),
          Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: context.color.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.lock_outline,
                    size: 20.sp, color: context.color.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate(LangKeys.encryption),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: context.color.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Messages are end-to-end encrypted',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: context.color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.verified_user_outlined,
                  color: context.color.primary, size: 20.sp),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaveGroupTile extends StatelessWidget {
  const _LeaveGroupTile({
    required this.group,
    required this.currentUserId,
    required this.currentUserEmail,
  });
  final GroupModel group;
  final String currentUserId;
  final String currentUserEmail;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: InkWell(
        onTap: () => _confirmExit(context),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: context.color.errorContainer,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.logout,
                    size: 20.sp, color: context.color.error),
              ),
              SizedBox(width: 12.w),
              Text(
                context.translate(LangKeys.exitGroup),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: context.color.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    final cubit = context.read<GroupInfoCubit>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.translate(LangKeys.exitGroup),
          style: TextStyle(
            color: context.color.primary,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content:
            const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.translate(LangKeys.cancel),
              style:
                  TextStyle(color: context.color.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.exitGroup(
                groupId: group.id,
                userId: currentUserId,
                userEmail: currentUserEmail,
              );
            },
            child: Text(
              context.translate(LangKeys.exitGroup),
              style: TextStyle(
                color: context.color.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: context.color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: context.color.outline.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
