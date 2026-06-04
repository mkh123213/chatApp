import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/groups/data/repositories/groups_repo.dart';

part 'group_info_state.dart';

class GroupInfoCubit extends Cubit<GroupInfoState> {
  GroupInfoCubit({required GroupsRepo groupsRepo})
      : _groupsRepo = groupsRepo,
        super(GroupInfoInitial());

  final GroupsRepo _groupsRepo;
  StreamSubscription<GroupModel>? _groupSubscription;

  void watchGroup({required String groupId}) {
    _groupSubscription?.cancel();
    emit(GroupInfoLoading());
    _groupSubscription = _groupsRepo
        .getGroupStream(groupId: groupId)
        .listen(
          (group) => emit(GroupInfoLoaded(group: group)),
          onError: (e) => emit(GroupInfoError(message: e.toString())),
        );
  }

  Future<void> addMemberByEmail({
    required String groupId,
    required String memberEmail,
  }) async {
    final current = state;
    if (current is! GroupInfoLoaded) return;
    try {
      await _groupsRepo.addMemberByEmail(
          groupId: groupId, memberEmail: memberEmail);
    } catch (e) {
      emit(GroupInfoActionError(group: current.group, message: e.toString()));
      emit(GroupInfoLoaded(group: current.group));
    }
  }

  Future<void> removeMember({
    required String groupId,
    required String userId,
    required String userEmail,
  }) async {
    final current = state;
    if (current is! GroupInfoLoaded) return;
    try {
      await _groupsRepo.removeMember(
          groupId: groupId, userId: userId, userEmail: userEmail);
    } catch (e) {
      emit(GroupInfoActionError(group: current.group, message: e.toString()));
      emit(GroupInfoLoaded(group: current.group));
    }
  }

  Future<void> makeAdmin({
    required String groupId,
    required String userId,
  }) async {
    final current = state;
    if (current is! GroupInfoLoaded) return;
    try {
      await _groupsRepo.makeAdmin(groupId: groupId, userId: userId);
    } catch (e) {
      emit(GroupInfoActionError(group: current.group, message: e.toString()));
      emit(GroupInfoLoaded(group: current.group));
    }
  }

  Future<void> removeAdmin({
    required String groupId,
    required String userId,
  }) async {
    final current = state;
    if (current is! GroupInfoLoaded) return;
    try {
      await _groupsRepo.removeAdmin(groupId: groupId, userId: userId);
    } catch (e) {
      emit(GroupInfoActionError(group: current.group, message: e.toString()));
      emit(GroupInfoLoaded(group: current.group));
    }
  }

  Future<void> exitGroup({
    required String groupId,
    required String userId,
    required String userEmail,
  }) async {
    try {
      await _groupsRepo.exitGroup(
          groupId: groupId, userId: userId, userEmail: userEmail);
      emit(GroupInfoExited());
    } catch (e) {
      final current = state;
      if (current is GroupInfoLoaded) {
        emit(GroupInfoActionError(group: current.group, message: e.toString()));
        emit(GroupInfoLoaded(group: current.group));
      }
    }
  }

  @override
  Future<void> close() async {
    await _groupSubscription?.cancel();
    return super.close();
  }
}
