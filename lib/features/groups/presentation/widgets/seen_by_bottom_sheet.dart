import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/common/widgets/user_avatar.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeenByBottomSheet extends StatefulWidget {
  const SeenByBottomSheet({super.key, required this.readBy});

  final List<String> readBy;

  @override
  State<SeenByBottomSheet> createState() => _SeenByBottomSheetState();
}

class _SeenByBottomSheetState extends State<SeenByBottomSheet> {
  final _users = <_SeenByUser>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    for (final userId in widget.readBy) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(userId)
            .get();
        final data = doc.data();
        final name = data?['name'] as String? ?? '';
        final email = data?['email'] as String? ?? '';
        _users.add(_SeenByUser(
          id: userId,
          name: name.isNotEmpty ? name : email.split('@').first,
        ));
      } catch (_) {
        _users.add(_SeenByUser(id: userId, name: '?'));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 8.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: context.color.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Icon(Icons.done_all, size: 20.sp, color: Colors.blue),
                SizedBox(width: 8.w),
                TextApp(
                  text: context.translate(LangKeys.seenBy),
                  theme: context.textStyle.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeightHelper.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (_loading)
            Padding(
              padding: EdgeInsets.all(24.r),
              child: const CircularProgressIndicator(),
            )
          else if (_users.isEmpty)
            Padding(
              padding: EdgeInsets.all(24.r),
              child: TextApp(
                text: context.translate(LangKeys.seenByNobody),
                theme: context.textStyle.copyWith(
                  color: context.color.onSurfaceVariant,
                ),
              ),
            )
          else
            ...List.generate(_users.length, (index) {
              final user = _users[index];
              return ListTile(
                leading: UserAvatar(
                  userId: user.id,
                  displayName: user.name,
                  radius: 20,
                  fontSize: 14,
                ),
                title: TextApp(
                  text: user.name,
                  theme: context.textStyle.copyWith(fontSize: 14.sp),
                ),
              );
            }),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

class _SeenByUser {
  const _SeenByUser({required this.id, required this.name});
  final String id;
  final String name;
}

void showSeenByBottomSheet(BuildContext context, List<String> readBy) {
  showModalBottomSheet(
    context: context,
    builder: (_) => SeenByBottomSheet(readBy: readBy),
  );
}
