import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/presentation/widgets/active_call_bloc_consumer.dart';
import 'package:flutter/material.dart';

class CallBody extends StatelessWidget {
  const CallBody({super.key, required this.call});

  final CallModel call;

  @override
  Widget build(BuildContext context) {
    return ActiveCallBlocConsumer(initialCall: call);
  }
}
