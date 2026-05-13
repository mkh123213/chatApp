import 'dart:async';
import 'dart:io';

import 'package:chat_material3/core/app/models/current_user_model.dart';
import 'package:chat_material3/core/service/network/api_result.dart';
import 'package:chat_material3/features/status/data/datasources/status_remote_data_source.dart';
import 'package:chat_material3/features/status/data/models/status_model.dart';

class StatusRepo {
  StatusRepo(this._ds);

  final StatusRemoteDataSource _ds;

  // Contacts' active statuses — manual switchMap: re-subscribes to statuses
  // whenever the contacts list changes, without requiring rxdart.
  Stream<List<StatusModel>> watchActiveStatusesForContacts(
      String currentUserId) {
    final controller = StreamController<List<StatusModel>>.broadcast();
    StreamSubscription<List<String>>? contactsSub;
    StreamSubscription<List<StatusModel>>? statusesSub;

    contactsSub = _ds.watchContactUserIds(currentUserId).listen(
      (uids) {
        statusesSub?.cancel();
        if (uids.isEmpty) {
          controller.add([]);
          return;
        }
        statusesSub = _ds.watchActiveStatusesForUsers(uids).listen(
          (statuses) {
            if (!controller.isClosed) controller.add(statuses);
          },
          onError: (Object e) {
            if (!controller.isClosed) controller.addError(e);
          },
        );
      },
      onError: (Object e) {
        if (!controller.isClosed) controller.addError(e);
      },
    );

    controller.onCancel = () {
      contactsSub?.cancel();
      statusesSub?.cancel();
    };

    return controller.stream;
  }

  Stream<List<StatusModel>> watchMyActiveStatuses(String currentUserId) {
    return _ds.watchMyActiveStatuses(currentUserId);
  }

  Future<ApiResult<StatusModel>> createImageStatus({
    required CurrentUserModel author,
    required File image,
  }) async {
    try {
      final uploaded = await _ds.uploadStatusImage(
        userId: author.uid,
        file: image,
      );

      final id = _ds.newStatusId();
      final now = DateTime.now().toUtc();
      final status = StatusModel(
        id: id,
        userId: author.uid,
        userName: author.name ?? '',
        userEmail: author.email ?? '',
        userPhotoUrl: author.photoUrl,
        mediaUrl: uploaded.url,
        storagePath: uploaded.storagePath,
        type: StatusModel.typeImage,
        viewers: const [],
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );

      await _ds.createStatus(status);
      return ApiResult.success(status);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<StatusModel>> createTextStatus({
    required CurrentUserModel author,
    required String text,
    required String backgroundColor,
  }) async {
    try {
      final id = _ds.newStatusId();
      final now = DateTime.now().toUtc();
      final status = StatusModel(
        id: id,
        userId: author.uid,
        userName: author.name ?? '',
        userEmail: author.email ?? '',
        userPhotoUrl: author.photoUrl,
        mediaUrl: '',
        storagePath: '',
        type: StatusModel.typeText,
        text: text,
        backgroundColor: backgroundColor,
        viewers: const [],
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      );

      await _ds.createStatus(status);
      return ApiResult.success(status);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> markStatusViewed({
    required String statusId,
    required String viewerUid,
  }) async {
    try {
      await _ds.markStatusViewed(statusId: statusId, viewerUid: viewerUid);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }

  Future<ApiResult<void>> deleteStatus(StatusModel status) async {
    try {
      await _ds.deleteStatus(status);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
