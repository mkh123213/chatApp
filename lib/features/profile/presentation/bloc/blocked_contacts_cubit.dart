import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/datasources/block_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_material3/constants/fierstore_paths.dart';

class BlockedContact {
  const BlockedContact({
    required this.userId,
    required this.name,
    required this.email,
  });

  final String userId;
  final String name;
  final String email;
}

class BlockedContactsState {
  const BlockedContactsState({
    this.contacts = const [],
    this.isLoading = false,
    this.error,
  });

  final List<BlockedContact> contacts;
  final bool isLoading;
  final String? error;

  int get count => contacts.length;
}

class BlockedContactsCubit extends Cubit<BlockedContactsState> {
  BlockedContactsCubit({required BlockRemoteDataSource blockDataSource})
      : _blockDataSource = blockDataSource,
        super(const BlockedContactsState());

  final BlockRemoteDataSource _blockDataSource;
  StreamSubscription? _subscription;

  void loadBlockedContacts({required String currentUserId}) {
    _subscription?.cancel();
    emit(const BlockedContactsState(isLoading: true));

    _subscription = FirebaseFirestore.instance
        .collection(blocksCollection)
        .where('blockerId', isEqualTo: currentUserId)
        .snapshots()
        .listen(
      (snapshot) async {
        final blockedUserIds = snapshot.docs
            .map((doc) => (doc.data())['blockedId'] as String)
            .toList();

        if (blockedUserIds.isEmpty) {
          if (!isClosed) emit(const BlockedContactsState());
          return;
        }

        final contacts = <BlockedContact>[];
        for (final userId in blockedUserIds) {
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection(usersCollection)
                .doc(userId)
                .get();
            if (userDoc.exists) {
              final data = userDoc.data()!;
              contacts.add(BlockedContact(
                userId: userId,
                name: data['name'] as String? ?? '',
                email: data['email'] as String? ?? '',
              ));
            } else {
              contacts.add(BlockedContact(
                userId: userId,
                name: '',
                email: userId,
              ));
            }
          } catch (_) {
            contacts.add(BlockedContact(
              userId: userId,
              name: '',
              email: userId,
            ));
          }
        }

        if (!isClosed) {
          emit(BlockedContactsState(contacts: contacts));
        }
      },
      onError: (e) {
        if (!isClosed) {
          emit(BlockedContactsState(error: e.toString()));
        }
      },
    );
  }

  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    await _blockDataSource.unblockUser(
      currentUserId: currentUserId,
      blockedUserId: blockedUserId,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
