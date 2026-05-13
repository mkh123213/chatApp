part of 'status_cubit.dart';

@freezed
class StatusState with _$StatusState {
  const factory StatusState.initial() = _Initial;
  const factory StatusState.loading() = _Loading;
  const factory StatusState.loaded({
    required List<StatusModel> recent,
    required List<StatusModel> viewed,
  }) = _Loaded;
  const factory StatusState.empty() = _Empty;
  const factory StatusState.error({required String message}) = _Error;
}
