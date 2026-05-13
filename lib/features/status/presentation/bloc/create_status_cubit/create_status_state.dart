part of 'create_status_cubit.dart';

@freezed
class CreateStatusState with _$CreateStatusState {
  const factory CreateStatusState.initial() = _Initial;
  const factory CreateStatusState.uploadingImage() = _UploadingImage;
  const factory CreateStatusState.savingDoc() = _SavingDoc;
  const factory CreateStatusState.success(StatusModel status) = _Success;
  const factory CreateStatusState.error({required String message}) = _Error;
}
