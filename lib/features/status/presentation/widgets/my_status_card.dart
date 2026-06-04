import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/features/status/presentation/bloc/my_status_cubit/my_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/create_status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyStatusCard extends StatelessWidget {
  const MyStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyStatusCubit, MyStatusState>(
      listener: (context, state) {
        state.maybeWhen(
          deleteError: (message) =>
              ShowToast.showToastErrorTop(message: message),
          deleted: (_) => ShowToast.showToastSuccessTop(
            message: context.translate(LangKeys.statusDeleted),
          ),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.maybeWhen(
          loaded: (mine) {
            final user = getCurrentUser();
            final latest = mine.isNotEmpty ? mine.first.createdAt : null;
            return _MyStatusTile(
              photoUrl: user.photoUrl,
              title: context.translate(LangKeys.statusMyStatus),
              subtitle: latest != null ? _relativeTime(latest) : '',
              onTap: () => context.pushName(
                AppRoutes.statusViewer,
                arguments: {
                  'statuses': mine,
                  'initialIndex': 0,
                  'isOwn': true,
                },
              ),
            );
          },
          empty: () {
            final user = getCurrentUser();
            return _MyStatusTile(
              photoUrl: user.photoUrl,
              title: context.translate(LangKeys.statusMyStatus),
              subtitle: context.translate(LangKeys.statusTapToAdd),
              onTap: () => showCreateStatusSheet(context),
            );
          },
          orElse: () => const SizedBox(height: 72),
        );
      },
    );
  }

  static String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _MyStatusTile extends StatelessWidget {
  const _MyStatusTile({
    required this.photoUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String? photoUrl;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      leading: _MyStatusAvatar(photoUrl: photoUrl),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13.sp,
          color: context.color.onSurfaceVariant,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _MyStatusAvatar extends StatelessWidget {
  const _MyStatusAvatar({required this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.color.primary, width: 2.5),
          ),
          child: ClipOval(
            child: photoUrl != null && photoUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: photoUrl!,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _FallbackAvatar(),
                  )
                : _FallbackAvatar(),
          ),
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: context.color.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.color.surface,
                width: 1.5,
              ),
            ),
            child: Icon(Icons.add, size: 13.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _FallbackAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.color.primary,
      alignment: Alignment.center,
      child: Icon(Icons.person, color: Colors.white, size: 24.sp),
    );
  }
}
