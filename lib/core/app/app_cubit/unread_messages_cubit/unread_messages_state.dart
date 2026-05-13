part of 'unread_messages_cubit.dart';

@freezed
class UnreadMessagesState with _$UnreadMessagesState {
  const factory UnreadMessagesState.initial() = _Initial;
  const factory UnreadMessagesState.loading() = _Loading;
  const factory UnreadMessagesState.loaded({required int count}) = _Loaded;
  const factory UnreadMessagesState.error({required String message}) = _Error;
}
