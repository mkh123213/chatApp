import 'package:chat_material3/features/calls/data/models/call_model.dart';

sealed class StartCallState {
  const StartCallState();
}

final class StartCallInitial extends StartCallState {
  const StartCallInitial();
}

final class StartCallLoading extends StartCallState {
  const StartCallLoading();
}

final class StartCallSuccess extends StartCallState {
  const StartCallSuccess({required this.call});
  final CallModel call;
}

final class StartCallError extends StartCallState {
  const StartCallError({required this.message});
  final String message;
}
