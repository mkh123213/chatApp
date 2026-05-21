import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/data/models/call_status.dart';
import 'package:chat_material3/features/calls/presentation/bloc/active_call_cubit/active_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/active_call_cubit/active_call_state.dart';
import 'package:chat_material3/features/calls/presentation/widgets/call_controls.dart';
import 'package:chat_material3/features/calls/presentation/widgets/call_header.dart';
import 'package:chat_material3/features/calls/presentation/widgets/call_video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveCallBlocConsumer extends StatelessWidget {
  const ActiveCallBlocConsumer({super.key, required this.initialCall});

  final CallModel initialCall;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveCallCubit, ActiveCallState>(
      listener: (context, state) {
        if (state is ActiveCallError) {
          ShowToast.showToastErrorTop(message: state.message);
        }
      },
      builder: (context, state) {
        final call = switch (state) {
          ActiveCallActive(:final call) => call,
          _ => initialCall,
        };

        final isVideo = call.type == CallType.video;

        return Stack(
          children: [
            if (isVideo)
              Positioned.fill(child: CallVideoView(channelId: call.channelId)),
            Column(
              children: [
                if (!isVideo) CallHeader(call: call),
                if (isVideo)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        call.status == CallStatus.accepted
                            ? ''
                            : 'Connecting...',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                CallControls(
              call: call,
              onEndCall: () {
                final duration = call.acceptedAt != null
                    ? DateTime.now()
                        .difference(call.acceptedAt!)
                        .inSeconds
                    : 0;
                context.read<ActiveCallCubit>().endCall(
                      call: call,
                      durationInSeconds: duration,
                    );
              },
            ),
              ],
            ),
          ],
        );
      },
    );
  }
}
