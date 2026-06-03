import 'package:chat_material3/features/single_chat/data/datasources/block_remote_data_source.dart';

class BlockRepo {
  BlockRepo({required BlockRemoteDataSource dataSource})
      : _dataSource = dataSource;

  final BlockRemoteDataSource _dataSource;

  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) =>
      _dataSource.blockUser(
        currentUserId: currentUserId,
        blockedUserId: blockedUserId,
      );

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) =>
      _dataSource.unblockUser(
        currentUserId: currentUserId,
        blockedUserId: blockedUserId,
      );

  Stream<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  }) =>
      _dataSource.isBlocked(
        currentUserId: currentUserId,
        otherUserId: otherUserId,
      );

  Future<bool> isBlockedBetween({
    required String userId1,
    required String userId2,
  }) =>
      _dataSource.isBlockedBetween(userId1: userId1, userId2: userId2);

  Future<List<String>> getBlockedUsers({required String currentUserId}) =>
      _dataSource.getBlockedUsers(currentUserId: currentUserId);
}
