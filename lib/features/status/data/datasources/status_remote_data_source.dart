import 'dart:async';
import 'dart:io';

import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/core/service/supabase/supabase_storage_service.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class StatusRemoteDataSource {
  String newStatusId();

  Future<UploadedFileData> uploadStatusImage({
    required String userId,
    required File file,
  });

  Future<void> createStatus(StatusModel status);

  Stream<List<StatusModel>> watchActiveStatusesForUsers(List<String> userIds);

  Stream<List<StatusModel>> watchMyActiveStatuses(String userId);

  Future<void> markStatusViewed({
    required String statusId,
    required String viewerUid,
  });

  Future<void> deleteStatus(StatusModel status);

  Stream<List<String>> watchContactUserIds(String currentUserId);
}

class StatusRemoteDataSourceImpl implements StatusRemoteDataSource {
  const StatusRemoteDataSourceImpl({
    required DataBaseService db,
    required SupabaseStorageService storage,
  })  : _db = db,
        _storage = storage;

  final DataBaseService _db;
  final SupabaseStorageService _storage;

  // The only sanctioned direct use of FirebaseFirestore.instance.
  @override
  String newStatusId() =>
      FirebaseFirestore.instance.collection(statusesCollection).doc().id;

  @override
  Future<UploadedFileData> uploadStatusImage({
    required String userId,
    required File file,
  }) {
    return _storage.uploadStatusImage(userId: userId, file: file);
  }

  @override
  Future<void> createStatus(StatusModel status) {
    return _db.setData(
      path: '$statusesCollection/${status.id}',
      data: status.toJson(),
      merge: false,
    );
  }

  @override
  Stream<List<StatusModel>> watchActiveStatusesForUsers(List<String> userIds) {
    if (userIds.isEmpty) {
      return const Stream.empty();
    }

    // Cap at 30 — Firestore whereIn limit.
    final ids = userIds.take(30).toList();
    final now = Timestamp.now();

    return _db.collectionStream<StatusModel>(
      path: statusesCollection,
      builder: (data, id) => StatusModel.fromFirestore(id: id, data: data),
      queryBuilder: (query) => query
          .where('userId', whereIn: ids)
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true),
    );
  }

  @override
  Stream<List<StatusModel>> watchMyActiveStatuses(String userId) {
    final now = Timestamp.now();
    return _db.collectionStream<StatusModel>(
      path: statusesCollection,
      builder: (data, id) => StatusModel.fromFirestore(id: id, data: data),
      queryBuilder: (query) => query
          .where('userId', isEqualTo: userId)
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .orderBy('createdAt', descending: true),
    );
  }

  @override
  Future<void> markStatusViewed({
    required String statusId,
    required String viewerUid,
  }) {
    return _db.setData(
      path: '$statusesCollection/$statusId',
      data: {'viewers': FieldValue.arrayUnion([viewerUid])},
    );
  }

  @override
  Future<void> deleteStatus(StatusModel status) async {
    if (status.storagePath.isNotEmpty) {
      try {
        await _storage.removeFile(storagePath: status.storagePath);
      } catch (_) {
        // Storage file may already be missing; proceed to Firestore delete.
      }
    }
    await _db.deleteData(path: '$statusesCollection/${status.id}');
  }

  @override
  Stream<List<String>> watchContactUserIds(String currentUserId) {
    return _db
        .collectionStream<String?>(
          path: chatsCollection,
          builder: (data, _) {
            final users = List<String>.from(data['users'] as List? ?? []);
            return users.firstWhere(
              (uid) => uid != currentUserId,
              orElse: () => '',
            );
          },
          queryBuilder: (query) =>
              query.where('users', arrayContains: currentUserId),
        )
        .map((list) =>
            list.where((uid) => uid != null && uid.isNotEmpty).cast<String>().toList());
  }
}
