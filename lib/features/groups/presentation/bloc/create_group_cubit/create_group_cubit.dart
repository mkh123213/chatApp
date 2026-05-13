import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/groups/data/repositories/groups_repo.dart';
import 'package:chat_material3/features/single_chat/data/repositories/block_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'create_group_state.dart';
part 'create_group_cubit.freezed.dart';

class CreateGroupCubit extends Cubit<CreateGroupState> {
  CreateGroupCubit({
    required GroupsRepo groupsRepo,
    required BlockRepo blockRepo,
  })  : _groupsRepo = groupsRepo,
        _blockRepo = blockRepo,
        super(const CreateGroupState.initial());

  final GroupsRepo _groupsRepo;
  final BlockRepo _blockRepo;

  Future<void> createGroup({
    required String currentUserId,
    required String currentUserEmail,
    required String groupName,
    required List<String> membersIds,
    required List<String> membersEmails,
  }) async {
    emit(const CreateGroupState.loading());
    try {
      for (final memberId in membersIds) {
        if (memberId == currentUserId) continue;
        final blocked = await _blockRepo.isBlockedBetween(
          userId1: currentUserId,
          userId2: memberId,
        );
        if (blocked) {
          emit(const CreateGroupState.error(
            message: 'cannot_create_group_with_blocked_user',
          ));
          return;
        }
      }

      await _groupsRepo.createGroup(
        currentUserId: currentUserId,
        currentUserEmail: currentUserEmail,
        groupName: groupName,
        membersIds: membersIds,
        membersEmails: membersEmails,
      );
      emit(const CreateGroupState.success());
    } catch (e) {
      emit(CreateGroupState.error(message: e.toString()));
    }
  }
}
