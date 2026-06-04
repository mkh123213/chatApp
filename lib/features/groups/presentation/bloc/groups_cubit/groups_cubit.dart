import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/data/repositories/groups_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'groups_state.dart';
part 'groups_cubit.freezed.dart';
class GroupsCubit extends Cubit<GroupsState> {
  GroupsCubit({required GroupsRepo groupsRepo}) : _groupsRepo = groupsRepo, super(const GroupsState.initial());
  final GroupsRepo _groupsRepo;
  StreamSubscription<List<GroupModel>>? _groupsSubscription;
  bool _isListeningToGroups = false;
  void getGroups({required String currentUserId}) {
    if (_isListeningToGroups) return;
    _isListeningToGroups = true;
    emit(const GroupsState.loading());
    _groupsSubscription = _groupsRepo.getGroups(currentUserId: currentUserId).listen((groups) {
      if (groups.isEmpty) { emit(const GroupsState.empty()); } else { emit(GroupsState.loaded(groups: groups)); }
    }, onError: (e) => emit(GroupsState.error(message: e.toString())));
  }
  @override Future<void> close() async { await _groupsSubscription?.cancel(); return super.close(); }
}
