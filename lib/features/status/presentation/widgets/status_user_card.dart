import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusUserCard extends StatelessWidget {
  const StatusUserCard({
    required this.statuses,
    required this.isViewed,
    super.key,
  });

  final List<StatusModel> statuses;
  final bool isViewed;

  @override
  Widget build(BuildContext context) {
    final first = statuses.first;
    final displayName =
        first.userName.isNotEmpty ? first.userName : first.userEmail;
    final count = statuses.length;
    final latestTime = first.createdAt;
    final timeAgo = latestTime != null ? _relativeTime(latestTime) : '';
    final subtitle =
        '$count ${count == 1 ? 'update' : 'updates'}${timeAgo.isNotEmpty ? ' · $timeAgo' : ''}';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      leading: _StatusAvatar(
        photoUrl: first.userPhotoUrl,
        name: displayName,
        isViewed: isViewed,
      ),
      title: Text(
        displayName,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: isViewed
              ? context.color.onSurface.withValues(alpha: 0.5)
              : context.color.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13.sp,
          color: context.color.onSurfaceVariant,
        ),
      ),
      trailing: !isViewed
          ? Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: context.color.primary,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: () => context.pushName(
        AppRoutes.statusViewer,
        arguments: {
          'statuses': statuses,
          'initialIndex': 0,
          'isOwn': false,
        },
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusAvatar extends StatelessWidget {
  const _StatusAvatar({
    required this.photoUrl,
    required this.name,
    required this.isViewed,
  });

  final String? photoUrl;
  final String name;
  final bool isViewed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isViewed
            ? null
            : Border.all(color: context.color.primary, width: 2.5),
      ),
      child: ClipOval(
        child: photoUrl != null && photoUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: photoUrl!,
                fit: BoxFit.cover,
                colorBlendMode: isViewed ? BlendMode.saturation : null,
                color: isViewed ? Colors.grey : null,
                errorWidget: (_, __, ___) =>
                    _Initials(name: name, isViewed: isViewed),
              )
            : _Initials(name: name, isViewed: isViewed),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.name, required this.isViewed});

  final String name;
  final bool isViewed;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: isViewed
          ? context.color.onSurface.withValues(alpha: 0.2)
          : context.color.primary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 20.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
