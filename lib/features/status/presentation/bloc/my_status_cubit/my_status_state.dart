part of 'my_status_cubit.dart';

@freezed
class MyStatusState with _$MyStatusState {
  const factory MyStatusState.initial() = _Initial;
  const factory MyStatusState.loading() = _Loading;
  const factory MyStatusState.loaded({required List<StatusModel> mine}) =
      _Loaded;
  const factory MyStatusState.empty() = _Empty;
  const factory MyStatusState.error({required String message}) = _Error;
  const factory MyStatusState.deleting({required String statusId}) = _Deleting;
  const factory MyStatusState.deleted({required String statusId}) = _Deleted;
  const factory MyStatusState.deleteError({required String message}) =
      _DeleteError;
}
