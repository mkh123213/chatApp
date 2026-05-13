import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusUserCard extends StatelessWidget {
  const StatusUserCard(
      {required this.status, required this.isViewed, super.key});

  final StatusModel status;
  final bool isViewed;

  @override
  Widget build(BuildContext context) {
    final displayName =
        status.userName.isNotEmpty ? status.userName : status.userEmail;
    final timeAgo = _relativeTime(status.createdAt);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: GestureDetector(
        onTap: () => context.pushName(
          AppRoutes.statusViewer,
          arguments: {
            'statuses': [status],
            'initialIndex': 0,
            'isOwn': false,
          },
        ),
        child: Row(
          children: [
            _StatusAvatar(
              photoUrl: status.userPhotoUrl,
              name: displayName,
              isViewed: isViewed,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextApp(
                    text: displayName,
                    theme: context.textStyle.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeightHelper.semiBold,
                      color: isViewed
                          ? context.color.onSurface.withValues(alpha: 0.5)
                          : context.color.onSurface,
                    ),
                    maxLines: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  TextApp(
                    text: timeAgo,
                    theme: context.textStyle.copyWith(
                      fontSize: 12.sp,
                      color: context.color.onSurface
                          .withValues(alpha: isViewed ? 0.35 : 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    final d = time;
    final now = DateTime.now();
    if (d.day == now.day) return 'Today, ${_hhmm(d)}';
    final yesterday = now.subtract(const Duration(days: 1));
    if (d.day == yesterday.day) return 'Yesterday, ${_hhmm(d)}';
    return '${d.month}/${d.day}, ${_hhmm(d)}';
  }

  String _hhmm(DateTime t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
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
      width: 56.w,
      height: 56.w,
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
      child: TextApp(
        text: initial,
        theme: context.textStyle.copyWith(
          fontSize: 20.sp,
          color: Colors.white,
          fontWeight: FontWeightHelper.bold,
        ),
      ),
    );
  }
}
