import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/groups/presentation/bloc/create_group_cubit/create_group_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateGroupBottomSheet extends StatefulWidget {
  const CreateGroupBottomSheet({super.key});

  @override
  State<CreateGroupBottomSheet> createState() => _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState extends State<CreateGroupBottomSheet> {
  final _groupNameController = TextEditingController();
  final _selectedUsers = <_UserItem>{};
  List<_UserItem> _allUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final currentUser = getCurrentUser();
    final snapshot = await FirebaseFirestore.instance
        .collection(usersCollection)
        .get();

    final users = <_UserItem>[];
    for (final doc in snapshot.docs) {
      if (doc.id == currentUser.uid) continue;
      final data = doc.data();
      users.add(_UserItem(
        id: doc.id,
        name: data['name'] as String? ?? '',
        email: data['email'] as String? ?? '',
      ));
    }
    users.sort((a, b) => a.displayName.compareTo(b.displayName));
    if (mounted) setState(() { _allUsers = users; _loading = false; });
  }

  void _createGroup() {
    final groupName = _groupNameController.text.trim();
    if (groupName.isEmpty) return;
    if (_selectedUsers.isEmpty) {
      ShowToast.showToastErrorTop(
        message: context.translate(LangKeys.addMembers),
      );
      return;
    }

    final currentUser = getCurrentUser();
    final memberIds = [currentUser.uid, ..._selectedUsers.map((u) => u.id)];
    final memberEmails = [
      currentUser.email ?? '',
      ..._selectedUsers.map((u) => u.email),
    ];

    context.read<CreateGroupCubit>().createGroup(
      currentUserId: currentUser.uid,
      currentUserEmail: currentUser.email ?? '',
      groupName: groupName,
      membersIds: memberIds,
      membersEmails: memberEmails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateGroupCubit, CreateGroupState>(
      listener: (context, state) {
        state.whenOrNull(
          success: () {
            ShowToast.showToastSuccessTop(
              message: context.translate(LangKeys.groupCreatedSuccessfully),
            );
            Navigator.pop(context);
          },
          error: (message) => ShowToast.showToastErrorTop(message: message),
        );
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20.w,
          right: 20.w,
          top: 16.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  context.translate(LangKeys.newGroup),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: context.translate(LangKeys.groupName),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              context.translate(LangKeys.addMembers).toUpperCase(),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.color.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 300.h,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _allUsers.isEmpty
                      ? Center(
                          child: Text(
                            context.translate(LangKeys.noContactsFound),
                            style: TextStyle(
                              color: context.color.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _allUsers.length,
                          itemBuilder: (context, index) {
                            final user = _allUsers[index];
                            final selected = _selectedUsers.contains(user);
                            return _MemberTile(
                              user: user,
                              selected: selected,
                              onToggle: () {
                                setState(() {
                                  if (selected) {
                                    _selectedUsers.remove(user);
                                  } else {
                                    _selectedUsers.add(user);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),
            SizedBox(height: 12.h),
            BlocBuilder<CreateGroupCubit, CreateGroupState>(
              builder: (context, state) {
                final isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                return SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : _createGroup,
                    child: isLoading
                        ? SizedBox(
                            height: 20.r,
                            width: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.translate(LangKeys.createGroup),
                            style: TextStyle(fontSize: 15.sp),
                          ),
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

class _UserItem {
  const _UserItem({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;

  String get displayName => name.isNotEmpty ? name : email;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _UserItem && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({
    required this.user,
    required this.selected,
    required this.onToggle,
  });

  final _UserItem user;
  final bool selected;
  final VoidCallback onToggle;

  static const _colors = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
    Color(0xFFEC407A),
    Color(0xFF8D6E63),
  ];

  @override
  Widget build(BuildContext context) {
    final name = user.displayName;
    final hash = name.codeUnits.fold<int>(0, (prev, c) => prev + c);
    final color = _colors[hash % _colors.length];
    final parts = name.split(RegExp(r'\s+'));
    String initials;
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      initials = '${name[0]}${name[1]}'.toUpperCase();
    } else {
      initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
      leading: CircleAvatar(
        backgroundColor: color,
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        name,
        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Checkbox(
        value: selected,
        onChanged: (_) => onToggle(),
        shape: const CircleBorder(),
      ),
      onTap: onToggle,
    );
  }
}
