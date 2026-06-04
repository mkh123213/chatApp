import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:chat_material3/features/status/data/repositories/status_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'status_state.dart';
part 'status_cubit.freezed.dart';

class StatusCubit extends Cubit<StatusState> {
  StatusCubit({required StatusRepo statusRepo})
      : _repo = statusRepo,
        super(const StatusState.initial());

  final StatusRepo _repo;
  StreamSubscription<List<StatusModel>>? _sub;
  String? _currentUserId;

  void subscribe(String currentUserId) {
    if (_currentUserId == currentUserId) return;
    _currentUserId = currentUserId;

    _sub?.cancel();
    emit(const StatusState.loading());

    _sub = _repo.watchActiveStatusesForContacts(currentUserId).listen(
      (statuses) {
        if (isClosed) return;
        final active = statuses.where((s) => !s.isExpired).toList();

        final recent =
            active.where((s) => !s.isViewedBy(currentUserId)).toList();
        final viewed =
            active.where((s) => s.isViewedBy(currentUserId)).toList();

        if (recent.isEmpty && viewed.isEmpty) {
          emit(const StatusState.empty());
        } else {
          emit(StatusState.loaded(recent: recent, viewed: viewed));
        }
      },
      onError: (Object e) {
        if (isClosed) return;
        emit(StatusState.error(message: e.toString()));
      },
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
