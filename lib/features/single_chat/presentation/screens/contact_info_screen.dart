import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/block_cubit/block_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/block_cubit/block_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactInfoScreen extends StatefulWidget {
  const ContactInfoScreen({
    super.key,
    this.chat,
    required this.friendDisplayName,
    required this.friendId,
  });

  final ChatModel? chat;
  final String friendDisplayName;
  final String friendId;

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  Map<String, dynamic>? _friendData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    if (widget.friendId.isEmpty) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final doc = await FirebaseFirestore.instance
        .collection(usersCollection)
        .doc(widget.friendId)
        .get();
    if (mounted) {
      setState(() {
        _friendData = doc.data();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.friendDisplayName;
    final email = _friendData?['email'] as String? ?? _getFriendEmail();
    final phone = _friendData?['phoneNumber'] as String? ?? '';
    final about = _friendData?['about'] as String? ?? '';
    final profileImage = _friendData?['profileImage'] as String? ?? '';

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _ProfileSliverAppBar(
                  name: name,
                  profileImage: profileImage,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _InfoSection(
                        name: name,
                        email: email,
                        phone: phone,
                        about: about,
                      ),
                      SizedBox(height: 8.h),
                      _ActionTile(
                        icon: Icons.photo_library_outlined,
                        iconColor: context.color.primary,
                        title: context.translate(LangKeys.mediaLinksAndDocs),
                        onTap: () {},
                      ),
                      _ActionTile(
                        icon: Icons.notifications_outlined,
                        iconColor: context.color.primary,
                        title: context.translate(LangKeys.muteNotifications),
                        subtitle: context
                            .translate(LangKeys.muteNotificationsSubtitle),
                        onTap: () {},
                      ),
                      _ActionTile(
                        icon: Icons.lock_outline,
                        iconColor: context.color.primary,
                        title: context.translate(LangKeys.encryption),
                        subtitle:
                            context.translate(LangKeys.encryptionSubtitle),
                        onTap: () {},
                      ),
                      SizedBox(height: 8.h),
                      _BlockSection(
                        friendDisplayName: name,
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  String _getFriendEmail() {
    if (widget.chat == null) return '';
    final currentEmail = getCurrentUser().email ?? '';
    return widget.chat!.usersEmails
            ?.where((e) => e.toLowerCase() != currentEmail.toLowerCase())
            .firstOrNull ??
        '';
  }
}

class _ProfileSliverAppBar extends StatelessWidget {
  const _ProfileSliverAppBar({
    required this.name,
    required this.profileImage,
  });

  final String name;
  final String profileImage;

  @override
  Widget build(BuildContext context) {
    final hash = name.codeUnits.fold<int>(0, (prev, c) => prev + c);
    const colors = [
      Color(0xFF26A69A),
      Color(0xFF42A5F5),
      Color(0xFFEF5350),
      Color(0xFFFFA726),
      Color(0xFFAB47BC),
      Color(0xFF66BB6A),
      Color(0xFFEC407A),
      Color(0xFF8D6E63),
    ];
    final color = colors[hash % colors.length];

    final parts = name.split(RegExp(r'\s+'));
    String initials;
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.length >= 2) {
      initials = '${name[0]}${name[1]}'.toUpperCase();
    } else {
      initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    }

    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          name,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
        ),
        background: profileImage.isNotEmpty
            ? Image.network(
                profileImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _AvatarBackground(
                  color: color,
                  initials: initials,
                ),
              )
            : _AvatarBackground(color: color, initials: initials),
      ),
    );
  }
}

class _AvatarBackground extends StatelessWidget {
  const _AvatarBackground({required this.color, required this.initials});

  final Color color;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 72.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.name,
    required this.email,
    required this.phone,
    required this.about,
  });

  final String name;
  final String email;
  final String phone;
  final String about;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (about.isNotEmpty) ...[
            Text(
              about,
              style: TextStyle(
                fontSize: 15.sp,
                color: context.color.onSurface,
              ),
            ),
            SizedBox(height: 12.h),
            Divider(color: context.color.outlineVariant),
            SizedBox(height: 4.h),
          ],
          if (email.isNotEmpty)
            _InfoRow(
              icon: Icons.email_outlined,
              text: email,
            ),
          if (phone.isNotEmpty)
            _InfoRow(
              icon: Icons.phone_outlined,
              text: phone,
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: context.color.onSurfaceVariant),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15.sp,
                color: context.color.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 15.sp),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13.sp,
                color: context.color.onSurfaceVariant,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

class _BlockSection extends StatelessWidget {
  const _BlockSection({required this.friendDisplayName});

  final String friendDisplayName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlockCubit, BlockState>(
      builder: (context, state) {
        final blockedByMe = state.when(
          initial: () => false,
          loading: () => false,
          blocked: (byMe) => byMe,
          notBlocked: () => false,
          error: (_) => false,
        );

        return Column(
          children: [
            Divider(color: context.color.outlineVariant),
            ListTile(
              leading: Icon(
                Icons.block,
                color: blockedByMe ? Colors.green : Colors.red,
              ),
              title: Text(
                blockedByMe
                    ? '${context.translate(LangKeys.unblockUser)} $friendDisplayName'
                    : '${context.translate(LangKeys.blockUser)} $friendDisplayName',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: blockedByMe ? Colors.green : Colors.red,
                ),
              ),
              onTap: () => _handleBlockTap(context, blockedByMe),
            ),
            Divider(color: context.color.outlineVariant),
          ],
        );
      },
    );
  }

  void _handleBlockTap(BuildContext context, bool blockedByMe) {
    final blockCubit = context.read<BlockCubit>();
    if (blockedByMe) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.translate(LangKeys.unblockUser)),
          content: Text(context.translate(LangKeys.unblockConfirm)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.translate(LangKeys.cancel)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                blockCubit.unblockUser();
              },
              child: Text(
                context.translate(LangKeys.unblockUser),
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.translate(LangKeys.blockUser)),
          content: Text(context.translate(LangKeys.blockConfirm)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.translate(LangKeys.cancel)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                blockCubit.blockUser();
              },
              child: Text(
                context.translate(LangKeys.blockUser),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }
  }
}
