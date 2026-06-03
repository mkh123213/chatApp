import 'package:chat_material3/features/calls/data/models/call_model.dart';

sealed class IncomingCallState {
  const IncomingCallState();
}

final class IncomingCallInitial extends IncomingCallState {
  const IncomingCallInitial();
}

final class IncomingCallListening extends IncomingCallState {
  const IncomingCallListening();
}

final class IncomingCallReceived extends IncomingCallState {
  const IncomingCallReceived({required this.call});
  final CallModel call;
}

final class IncomingCallNone extends IncomingCallState {
  const IncomingCallNone();
}

final class IncomingCallError extends IncomingCallState {
  const IncomingCallError({required this.message});
  final String message;
}
