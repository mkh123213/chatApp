import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserPresenceRemoteDataSource {
  Future<void> setOnline({required String userId});
  Future<void> setOffline({required String userId});
  Stream<Map<String, dynamic>> getUserPresence({required String userId});
}

class UserPresenceRemoteDataSourceImpl implements UserPresenceRemoteDataSource {
  const UserPresenceRemoteDataSourceImpl({
    required DataBaseService dataBaseService,
  }) : _dataBaseService = dataBaseService;

  final DataBaseService _dataBaseService;

  @override
  Future<void> setOnline({required String userId}) async {
    await _dataBaseService.setData(
      path: '$usersCollection/$userId',
      data: {
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      merge: true,
    );
  }

  @override
  Future<void> setOffline({required String userId}) async {
    await _dataBaseService.setData(
      path: '$usersCollection/$userId',
      data: {
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      },
      merge: true,
    );
  }

  @override
  Stream<Map<String, dynamic>> getUserPresence({required String userId}) {
    return _dataBaseService.documentStream<Map<String, dynamic>>(
      path: '$usersCollection/$userId',
      builder: (data, documentId) => data,
    );
  }
}
