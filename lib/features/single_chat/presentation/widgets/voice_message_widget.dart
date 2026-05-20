import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceMessageWidget extends StatefulWidget {
  const VoiceMessageWidget({
    super.key,
    required this.mediaUrl,
    required this.durationSeconds,
    required this.isMe,
  });

  final String mediaUrl;
  final int durationSeconds;
  final bool isMe;

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _durationSub;

  @override
  void initState() {
    super.initState();
    _totalDuration = Duration(seconds: widget.durationSeconds);

    _positionSub = _player.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });

    _stateSub = _player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
        if (state == PlayerState.completed) {
          setState(() => _position = Duration.zero);
        }
      }
    });

    _durationSub = _player.onDurationChanged.listen((dur) {
      if (mounted && dur.inMilliseconds > 0) {
        setState(() => _totalDuration = dur);
      }
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_position == Duration.zero) {
        await _player.play(UrlSource(widget.mediaUrl));
      } else {
        await _player.resume();
      }
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalDuration.inMilliseconds > 0
        ? _position.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    final displayDuration =
        _isPlaying || _position > Duration.zero ? _position : _totalDuration;

    return SizedBox(
      width: 200.w,
      child: Row(
        children: [
          // Mic icon
          Icon(
            Icons.mic,
            color: context.color.primary,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          // Play/pause button
          GestureDetector(
            onTap: _togglePlay,
            child: Container(
              width: 32.r,
              height: 32.r,
              decoration: BoxDecoration(
                color: context.color.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Progress bar + duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2.r),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor:
                        context.color.onSurfaceVariant.withValues(alpha: 0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(context.color.primary),
                    minHeight: 3.h,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDuration(displayDuration),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: context.color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
