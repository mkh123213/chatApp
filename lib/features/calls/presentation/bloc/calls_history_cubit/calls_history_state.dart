import 'package:chat_material3/features/calls/data/models/call_model.dart';

sealed class CallsHistoryState {
  const CallsHistoryState();
}

final class CallsHistoryInitial extends CallsHistoryState {
  const CallsHistoryInitial();
}

final class CallsHistoryLoading extends CallsHistoryState {
  const CallsHistoryLoading();
}

final class CallsHistoryLoaded extends CallsHistoryState {
  const CallsHistoryLoaded({required this.calls});
  final List<CallModel> calls;
}

final class CallsHistoryEmpty extends CallsHistoryState {
  const CallsHistoryEmpty();
}

final class CallsHistoryError extends CallsHistoryState {
  const CallsHistoryError({required this.message});
  final String message;
}
