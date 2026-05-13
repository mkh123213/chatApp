import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:chat_material3/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CallControls extends StatefulWidget {
  const CallControls({
    super.key,
    required this.call,
    required this.onEndCall,
  });

  final CallModel call;
  final VoidCallback onEndCall;

  @override
  State<CallControls> createState() => _CallControlsState();
}

class _CallControlsState extends State<CallControls> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOff = false;

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.call.type == CallType.video;

    return Padding(
      padding: EdgeInsets.only(bottom: 40.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            onPressed: () {
              setState(() => _isMuted = !_isMuted);
              context.read<ActiveCallCubit>().toggleMute(_isMuted);
            },
          ),
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: 'Speaker',
            onPressed: () {
              setState(() => _isSpeakerOn = !_isSpeakerOn);
              context.read<ActiveCallCubit>().toggleSpeaker(_isSpeakerOn);
            },
          ),
          if (isVideo)
            _buildControlButton(
              icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
              label: 'Camera',
              onPressed: () {
                setState(() => _isCameraOff = !_isCameraOff);
                context.read<ActiveCallCubit>().toggleCamera(!_isCameraOff);
              },
            ),
          if (isVideo)
            _buildControlButton(
              icon: Icons.cameraswitch,
              label: 'Switch',
              onPressed: () {
                context.read<ActiveCallCubit>().switchCamera();
              },
            ),
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 28.r),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            padding: EdgeInsets.all(12.r),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: widget.onEndCall,
          icon: Icon(Icons.call_end, size: 28.r, color: Colors.white),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.all(12.r),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'End',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
        ),
      ],
    );
  }
}
