import 'package:chat_material3/core/helper_functions/user_photo_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar({
    super.key,
    required this.userId,
    required this.displayName,
    this.radius = 26,
    this.fontSize = 16,
  });

  final String userId;
  final String displayName;
  final double radius;
  final double fontSize;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  @override
  void didUpdateWidget(UserAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadPhoto();
    }
  }

  Future<void> _loadPhoto() async {
    final cached = UserPhotoCache().getCached(widget.userId);
    if (cached != null) {
      if (mounted) setState(() { _photoUrl = cached; });
      return;
    }
    final url = await UserPhotoCache().getPhotoUrl(widget.userId);
    if (mounted) setState(() { _photoUrl = url; });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.displayName;
    final initials = _getInitials(name);
    final color = _getAvatarColor(name);
    final hasPhoto = _photoUrl != null && _photoUrl!.isNotEmpty;

    return CircleAvatar(
      radius: widget.radius.r,
      backgroundColor: color,
      backgroundImage: hasPhoto ? NetworkImage(_photoUrl!) : null,
      child: !hasPhoto
          ? Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: widget.fontSize.sp,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}

const List<Color> _avatarColors = [
  Color(0xFFEF5350),
  Color(0xFF42A5F5),
  Color(0xFF66BB6A),
  Color(0xFFFFA726),
  Color(0xFFAB47BC),
  Color(0xFF26C6DA),
  Color(0xFFEC407A),
  Color(0xFF8D6E63),
];

Color _getAvatarColor(String text) {
  final hash = text.codeUnits.fold<int>(0, (prev, c) => prev + c);
  return _avatarColors[hash % _avatarColors.length];
}

String _getInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  final cleanName = name.split('@').first;
  final nameParts = cleanName.split(RegExp(r'[._\-]'));
  if (nameParts.length >= 2) {
    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  }
  return cleanName.length >= 2
      ? '${cleanName[0]}${cleanName[1]}'.toUpperCase()
      : cleanName[0].toUpperCase();
}
