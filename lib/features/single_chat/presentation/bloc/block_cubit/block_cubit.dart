import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/repositories/block_repo.dart';

import 'block_state.dart';

class BlockCubit extends Cubit<BlockState> {
  BlockCubit({required BlockRepo blockRepo})
      : _blockRepo = blockRepo,
        super(const BlockState.initial());

  final BlockRepo _blockRepo;
  StreamSubscription<bool>? _subscription;
  String? _currentUserId;
  String? _otherUserId;

  void watchBlockStatus({
    required String currentUserId,
    required String otherUserId,
  }) {
    _currentUserId = currentUserId;
    _otherUserId = otherUserId;
    _subscription?.cancel();
    _subscription = _blockRepo
        .isBlocked(currentUserId: currentUserId, otherUserId: otherUserId)
        .listen(
      (isBlocked) async {
        if (isBlocked) {
          final blockedByMe = await _isBlockedByMe(currentUserId, otherUserId);
          emit(BlockState.blocked(blockedByMe: blockedByMe));
        } else {
          emit(const BlockState.notBlocked());
        }
      },
      onError: (e) => emit(BlockState.error(message: e.toString())),
    );
  }

  Future<bool> _isBlockedByMe(String currentUserId, String otherUserId) async {
    final blockedUsers =
        await _blockRepo.getBlockedUsers(currentUserId: currentUserId);
    return blockedUsers.contains(otherUserId);
  }

  Future<void> blockUser() async {
    if (_currentUserId == null || _otherUserId == null) return;
    try {
      emit(const BlockState.loading());
      await _blockRepo.blockUser(
        currentUserId: _currentUserId!,
        blockedUserId: _otherUserId!,
      );
    } catch (e) {
      emit(BlockState.error(message: e.toString()));
    }
  }

  Future<void> unblockUser() async {
    if (_currentUserId == null || _otherUserId == null) return;
    try {
      emit(const BlockState.loading());
      await _blockRepo.unblockUser(
        currentUserId: _currentUserId!,
        blockedUserId: _otherUserId!,
      );
    } catch (e) {
      emit(BlockState.error(message: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
