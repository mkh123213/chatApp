import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BlockRemoteDataSource {
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  });

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  });

  Stream<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  });

  Future<bool> isBlockedBetween({
    required String userId1,
    required String userId2,
  });

  Future<List<String>> getBlockedUsers({required String currentUserId});
}

class BlockRemoteDataSourceImpl implements BlockRemoteDataSource {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _blocksCollection =>
      _firestore.collection(blocksCollection);

  String _blockDocId(String blockerId, String blockedId) =>
      '${blockerId}_$blockedId';

  @override
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _blocksCollection.doc(_blockDocId(currentUserId, blockedUserId)).set({
      'blockerId': currentUserId,
      'blockedId': blockedUserId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _blocksCollection
        .doc(_blockDocId(currentUserId, blockedUserId))
        .delete();
  }

  @override
  Stream<bool> isBlocked({
    required String currentUserId,
    required String otherUserId,
  }) {
    return _blocksCollection
        .where('blockerId', whereIn: [currentUserId, otherUserId])
        .snapshots()
        .map((snapshot) {
          for (final doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final blockerId = data['blockerId'] as String;
            final blockedId = data['blockedId'] as String;
            if ((blockerId == currentUserId && blockedId == otherUserId) ||
                (blockerId == otherUserId && blockedId == currentUserId)) {
              return true;
            }
          }
          return false;
        });
  }

  @override
  Future<bool> isBlockedBetween({
    required String userId1,
    required String userId2,
  }) async {
    final doc1 = await _blocksCollection.doc(_blockDocId(userId1, userId2)).get();
    if (doc1.exists) return true;
    final doc2 = await _blocksCollection.doc(_blockDocId(userId2, userId1)).get();
    return doc2.exists;
  }

  @override
  Future<List<String>> getBlockedUsers({required String currentUserId}) async {
    final snapshot = await _blocksCollection
        .where('blockerId', isEqualTo: currentUserId)
        .get();
    return snapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['blockedId'] as String)
        .toList();
  }
}
