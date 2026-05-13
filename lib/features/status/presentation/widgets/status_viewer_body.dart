import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:chat_material3/features/status/data/repositories/status_repo.dart';
import 'package:chat_material3/features/status/presentation/bloc/my_status_cubit/my_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/delete_status_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusViewerBody extends StatefulWidget {
  const StatusViewerBody({
    required this.statuses,
    required this.initialIndex,
    required this.isOwn,
    super.key,
  });

  final List<StatusModel> statuses;
  final int initialIndex;
  final bool isOwn;

  @override
  State<StatusViewerBody> createState() => _StatusViewerBodyState();
}

class _StatusViewerBodyState extends State<StatusViewerBody>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final List<StatusModel> _statuses;
  late int _currentPage;
  late AnimationController _progressController;
  final TextEditingController _replyController = TextEditingController();

  static const Duration _pageDuration = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _statuses = List.of(widget.statuses);
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _progressController = AnimationController(vsync: this, duration: _pageDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _goToNext();
        }
      })
      ..forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markViewed(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _markViewed(int index) {
    if (index < 0 || index >= _statuses.length) return;
    final status = _statuses[index];
    final uid = getCurrentUser().uid;
    if (status.isViewedBy(uid)) return;
    sl<StatusRepo>().markStatusViewed(statusId: status.id, viewerUid: uid);
  }

  void _goToNext() {
    if (_currentPage < _statuses.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _resetProgress() {
    _progressController.reset();
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyStatusCubit, MyStatusState>(
      listener: (context, state) {
        state.maybeWhen(
          deleted: (statusId) {
            _statuses.removeWhere((s) => s.id == statusId);
            if (_statuses.isEmpty) {
              Navigator.of(context).pop();
              return;
            }
            _currentPage = _currentPage.clamp(0, _statuses.length - 1);
            setState(() {});
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Page content
            PageView.builder(
              controller: _pageController,
              itemCount: _statuses.length,
              onPageChanged: (index) {
                _currentPage = index;
                _markViewed(index);
                _resetProgress();
                setState(() {});
              },
              itemBuilder: (_, index) {
                final status = _statuses[index];
                return _StatusPage(status: status);
              },
            ),
            // Top overlay: progress bars + header
            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProgressBars(
                    total: _statuses.length,
                    current: _currentPage,
                    controller: _progressController,
                  ),
                  SizedBox(height: 8.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        if (!widget.isOwn)
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
                          )
                        else
                          _AuthorAvatar(status: _statuses[_currentPage.clamp(0, _statuses.length - 1)]),
                        SizedBox(width: 8.w),
                        if (!widget.isOwn)
                          _AuthorAvatar(status: _statuses[_currentPage.clamp(0, _statuses.length - 1)]),
                        if (!widget.isOwn) SizedBox(width: 8.w),
                        Expanded(
                          child: _AuthorInfo(
                            status: _statuses[_currentPage.clamp(0, _statuses.length - 1)],
                          ),
                        ),
                        if (widget.isOwn)
                          Builder(
                            builder: (ctx) => IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.white),
                              tooltip: context.translate(LangKeys.statusDelete),
                              onPressed: () => showDeleteStatusDialog(
                                context: ctx,
                                status: _statuses[_currentPage],
                              ),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {},
                          ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom reply bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ReplyBar(controller: _replyController),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  const _ProgressBars({
    required this.total,
    required this.current,
    required this.controller,
  });

  final int total;
  final int current;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: i < current
                    ? Container(height: 3.h, color: Colors.white)
                    : i == current
                        ? AnimatedBuilder(
                            animation: controller,
                            builder: (_, __) => LinearProgressIndicator(
                              value: controller.value,
                              minHeight: 3.h,
                              backgroundColor: Colors.white.withValues(alpha: 0.4),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Container(
                            height: 3.h,
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _AuthorAvatar extends StatelessWidget {
  const _AuthorAvatar({required this.status});

  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    final name = status.userName.isNotEmpty ? status.userName : status.userEmail;
    return CircleAvatar(
      radius: 18.r,
      backgroundImage: status.userPhotoUrl != null && status.userPhotoUrl!.isNotEmpty
          ? CachedNetworkImageProvider(status.userPhotoUrl!)
          : null,
      backgroundColor: Colors.grey.shade800,
      child: status.userPhotoUrl == null || status.userPhotoUrl!.isEmpty
          ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: Colors.white, fontSize: 14.sp))
          : null,
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  const _AuthorInfo({required this.status});

  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    final name = status.userName.isNotEmpty ? status.userName : status.userEmail;
    final timeAgo = _relativeTime(status.createdAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextApp(
          text: name,
          theme: context.textStyle.copyWith(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeightHelper.semiBold,
          ),
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        TextApp(
          text: timeAgo,
          theme: context.textStyle.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }

  String _relativeTime(DateTime? time) {
    if (time == null) return '';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    return '${diff.inHours} hours ago';
  }
}

class _ReplyBar extends StatelessWidget {
  const _ReplyBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      padding: EdgeInsets.only(
        left: 12.w,
        right: 12.w,
        top: 8.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 22.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  height: 42.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: context.translate(LangKeys.statusReplyHint),
                      hintStyle: TextStyle(
                        color: Colors.white60,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      suffixIcon: Icon(Icons.emoji_emotions_outlined,
                          color: Colors.white60, size: 20.sp),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 18.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.keyboard_arrow_up, color: Colors.white54, size: 18.sp),
              SizedBox(width: 4.w),
              Text(
                context.translate(LangKeys.statusSwipeToReply),
                style: TextStyle(color: Colors.white54, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPage extends StatelessWidget {
  const _StatusPage({required this.status});

  final StatusModel status;

  @override
  Widget build(BuildContext context) {
    if (status.isImage && status.mediaUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: status.mediaUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image, color: Colors.white)),
      );
    }

    final bgColor = _parseColor(status.backgroundColor);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bgColor, Color.lerp(bgColor, Colors.black, 0.3)!],
        ),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: TextApp(
        text: status.text ?? '',
        theme: context.textStyle.copyWith(
          fontSize: 28.sp,
          color: Colors.white,
          fontWeight: FontWeightHelper.bold,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF3B1F8C);
    try {
      return Color(int.parse(hex));
    } catch (_) {
      return const Color(0xFF3B1F8C);
    }
  }
}
