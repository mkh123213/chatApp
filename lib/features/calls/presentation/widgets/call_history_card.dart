import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CallHistoryCard extends StatelessWidget {
  const CallHistoryCard({super.key, required this.call});

  final CallModel call;

  @override
  Widget build(BuildContext context) {
    final currentUserId = getCurrentUser().uid;
    final isOutgoing = call.callerId == currentUserId;
    final friendName = isOutgoing ? call.receiverName : call.callerName;
    final friendPhoto = isOutgoing ? call.receiverPhotoUrl : call.callerPhotoUrl;

    return ListTile(
      leading: CircleAvatar(
        radius: 24.r,
        backgroundImage:
            friendPhoto != null ? NetworkImage(friendPhoto) : null,
        child: friendPhoto == null ? Icon(Icons.person, size: 24.r) : null,
      ),
      title: TextApp(
        text: friendName,
        theme: context.textStyle.copyWith(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            _getCallDirectionIcon(isOutgoing),
            size: 14.r,
            color: _getStatusColor(call.status),
          ),
          SizedBox(width: 4.w),
          Icon(
            call.type == CallType.video ? Icons.videocam : Icons.call,
            size: 14.r,
            color: Colors.grey,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: TextApp(
              text: _getStatusLabel(context, isOutgoing),
              theme: context.textStyle.copyWith(
                fontSize: 12.sp,
                color: _getStatusColor(call.status),
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextApp(
            text: _formatTime(call.createdAt),
            theme: context.textStyle.copyWith(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
          if (call.durationInSeconds > 0) ...[
            SizedBox(height: 2.h),
            TextApp(
              text: _formatDuration(call.durationInSeconds),
              theme: context.textStyle.copyWith(
                fontSize: 11.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCallDirectionIcon(bool isOutgoing) {
    if (call.status == CallStatus.missed) return Icons.call_missed;
    if (call.status == CallStatus.rejected) return Icons.call_missed_outgoing;
    return isOutgoing ? Icons.call_made : Icons.call_received;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case CallStatus.missed:
        return Colors.red;
      case CallStatus.rejected:
        return Colors.orange;
      case CallStatus.ended:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(BuildContext context, bool isOutgoing) {
    switch (call.status) {
      case CallStatus.missed:
        return context.translate(LangKeys.missedCall);
      case CallStatus.rejected:
        return context.translate(LangKeys.rejectedCall);
      case CallStatus.ended:
        return context.translate(LangKeys.endedCall);
      default:
        return isOutgoing
            ? context.translate(LangKeys.outgoingCall)
            : context.translate(LangKeys.incomingCall);
    }
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('HH:mm').format(dateTime);
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
