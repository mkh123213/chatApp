part of 'selected_group_chat_cubit.dart';

@freezed
class SelectedGroupChatState with _$SelectedGroupChatState {
  const factory SelectedGroupChatState.initial() = _Initial;
  const factory SelectedGroupChatState.loading() = _Loading;
  const factory SelectedGroupChatState.loaded({
    required List<GroupMessageModel> messages,
    @Default({}) Set<String> selectedIds,
  }) = _Loaded;
  const factory SelectedGroupChatState.empty() = _Empty;
  const factory SelectedGroupChatState.error({required String message}) =
      _Error;
}
