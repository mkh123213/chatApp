import 'package:chat_material3/features/calls/data/models/call_model.dart';

sealed class ActiveCallState {
  const ActiveCallState();
}

final class ActiveCallInitial extends ActiveCallState {
  const ActiveCallInitial();
}

final class ActiveCallLoading extends ActiveCallState {
  const ActiveCallLoading();
}

final class ActiveCallActive extends ActiveCallState {
  const ActiveCallActive({required this.call});
  final CallModel call;
}

final class ActiveCallEnded extends ActiveCallState {
  const ActiveCallEnded();
}

final class ActiveCallError extends ActiveCallState {
  const ActiveCallError({required this.message});
  final String message;
}
