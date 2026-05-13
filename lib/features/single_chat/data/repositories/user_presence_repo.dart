import 'package:chat_material3/features/single_chat/data/datasources/user_presence_remote_data_source.dart';

class UserPresenceRepo {
  const UserPresenceRepo({
    required UserPresenceRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final UserPresenceRemoteDataSource _remoteDataSource;

  Future<void> setOnline({required String userId}) {
    return _remoteDataSource.setOnline(userId: userId);
  }

  Future<void> setOffline({required String userId}) {
    return _remoteDataSource.setOffline(userId: userId);
  }

  Stream<Map<String, dynamic>> getUserPresence({required String userId}) {
    return _remoteDataSource.getUserPresence(userId: userId);
  }
}
