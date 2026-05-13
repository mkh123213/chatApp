import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/core/service/network/api_result.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:chat_material3/features/status/data/repositories/status_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_status_state.dart';
part 'my_status_cubit.freezed.dart';

class MyStatusCubit extends Cubit<MyStatusState> {
  MyStatusCubit({required StatusRepo statusRepo})
      : _repo = statusRepo,
        super(const MyStatusState.initial());

  final StatusRepo _repo;
  StreamSubscription<List<StatusModel>>? _sub;

  void subscribe(String currentUserId) {
    _sub?.cancel();
    emit(const MyStatusState.loading());

    _sub = _repo.watchMyActiveStatuses(currentUserId).listen(
      (mine) {
        if (isClosed) return;
        if (mine.isEmpty) {
          emit(const MyStatusState.empty());
        } else {
          emit(MyStatusState.loaded(mine: mine));
        }
      },
      onError: (Object e) {
        if (isClosed) return;
        emit(MyStatusState.error(message: e.toString()));
      },
    );
  }

  Future<void> delete(StatusModel status) async {
    emit(MyStatusState.deleting(statusId: status.id));
    final result = await _repo.deleteStatus(status);
    result.when(
      success: (_) => emit(MyStatusState.deleted(statusId: status.id)),
      failure: (message) => emit(MyStatusState.deleteError(message: message)),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
