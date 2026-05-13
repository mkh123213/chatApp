import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/network/api_result.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:chat_material3/features/status/data/repositories/status_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_status_state.dart';
part 'create_status_cubit.freezed.dart';

class CreateStatusCubit extends Cubit<CreateStatusState> {
  CreateStatusCubit({required StatusRepo statusRepo})
      : _repo = statusRepo,
        super(const CreateStatusState.initial());

  final StatusRepo _repo;

  Future<void> createImageStatus(File file) async {
    emit(const CreateStatusState.uploadingImage());
    final author = getCurrentUser();
    final result = await _repo.createImageStatus(author: author, image: file);
    result.when(
      success: (status) => emit(CreateStatusState.success(status)),
      failure: (message) => emit(CreateStatusState.error(message: message)),
    );
  }

  Future<void> createTextStatus({
    required String text,
    required String backgroundColor,
  }) async {
    emit(const CreateStatusState.savingDoc());
    final author = getCurrentUser();
    final result = await _repo.createTextStatus(
      author: author,
      text: text,
      backgroundColor: backgroundColor,
    );
    result.when(
      success: (status) => emit(CreateStatusState.success(status)),
      failure: (message) => emit(CreateStatusState.error(message: message)),
    );
  }

  void reset() => emit(const CreateStatusState.initial());
}
