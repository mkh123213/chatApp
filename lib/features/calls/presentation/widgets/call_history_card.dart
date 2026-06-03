import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CallHistoryCard extends StatelessWidget {
  const CallHistoryCard({super.key, required this.call});

  final CallModel call;

  static const List<Color> _avatarColors = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
    Color(0xFF009688),
    Color(0xFFE91E63),
    Color(0xFF3F51B5),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUserId = getCurrentUser().uid;
    final isOutgoing = call.callerId == currentUserId;
    final friendName = isOutgoing ? call.receiverName : call.callerName;
    final friendPhoto = isOutgoing ? call.receiverPhotoUrl : call.callerPhotoUrl;
    final friendId = isOutgoing ? call.receiverId : call.callerId;
    final initial = friendName.isNotEmpty ? friendName[0].toUpperCase() : '?';
    final avatarColor = _avatarColors[friendId.hashCode.abs() % _avatarColors.length];
    final hasPhoto = friendPhoto != null && friendPhoto.isNotEmpty;
    final isVideo = call.type == CallType.video;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: CircleAvatar(
        radius: 24.r,
        backgroundColor: avatarColor,
        backgroundImage: hasPhoto ? CachedNetworkImageProvider(friendPhoto) : null,
        child: !hasPhoto
            ? Text(
                initial,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Icon(
            isVideo ? Icons.videocam_outlined : Icons.call_outlined,
            size: 16.sp,
            color: _statusColor,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              friendName,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: call.status == CallStatus.missed ? Colors.red : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Icon(
            _directionIcon(isOutgoing),
            size: 14.sp,
            color: _statusColor,
          ),
          SizedBox(width: 4.w),
          Text(
            _subtitleText,
            style: TextStyle(
              fontSize: 12.sp,
              color: context.color.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: Icon(
        isVideo ? Icons.videocam : Icons.call,
        color: context.color.primary,
        size: 22.sp,
      ),
    );
  }

  Color get _statusColor {
    switch (call.status) {
      case CallStatus.missed:
        return Colors.red;
      case CallStatus.rejected:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _directionIcon(bool isOutgoing) {
    if (call.status == CallStatus.missed) return Icons.call_missed;
    if (call.status == CallStatus.rejected) return Icons.call_missed_outgoing;
    return isOutgoing ? Icons.call_made : Icons.call_received;
  }

  String get _subtitleText {
    final time = call.createdAt != null
        ? DateFormat('h:mm a').format(call.createdAt!)
        : '';
    final status = _statusLabel;
    final duration = call.durationInSeconds > 0
        ? ' · ${_formatDuration(call.durationInSeconds)}'
        : '';
    return '$status · $time$duration';
  }

  String get _statusLabel {
    switch (call.status) {
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.rejected:
        return 'Declined';
      case CallStatus.ended:
        return 'Ended';
      default:
        return '';
    }
  }

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}
