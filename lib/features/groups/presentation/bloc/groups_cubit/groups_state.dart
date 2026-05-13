part of 'groups_cubit.dart';
@freezed
class GroupsState with _$GroupsState {
  const factory GroupsState.initial() = _Initial;
  const factory GroupsState.loading() = _Loading;
  const factory GroupsState.loaded({required List<GroupModel> groups}) = _Loaded;
  const factory GroupsState.empty() = _Empty;
  const factory GroupsState.error({required String message}) = _Error;
}
