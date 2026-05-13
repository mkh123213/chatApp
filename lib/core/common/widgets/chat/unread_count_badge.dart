import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UnreadCountBadge extends StatelessWidget {
  const UnreadCountBadge({
    super.key,
    this.backgroundColor = const Color(0xFFE53935),
    this.textColor = Colors.white,
    this.size,
  });

  final Color backgroundColor;
  final Color textColor;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size ?? 22.r;

    return BlocBuilder<UnreadMessagesCubit, UnreadMessagesState>(
      builder: (context, state) {
        return state.maybeWhen(loaded: (count) {
          final label = count > 99 ? '99+' : count.toString();
          return count > 0
              ? Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: backgroundColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: EdgeInsets.all(3.r),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }, orElse: () {
          return const SizedBox.shrink();
        });
      },
    );
  }
}
