part of 'create_group_cubit.dart';

@freezed
class CreateGroupState with _$CreateGroupState {
  const factory CreateGroupState.initial() = _Initial;
  const factory CreateGroupState.loading() = Loading;
  const factory CreateGroupState.success() = _Success;
  const factory CreateGroupState.error({required String message}) = _Error;
}
