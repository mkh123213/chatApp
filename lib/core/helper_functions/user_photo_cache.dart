import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPhotoCache {
  factory UserPhotoCache() => _instance;
  UserPhotoCache._();
  static final UserPhotoCache _instance = UserPhotoCache._();

  final Map<String, String?> _cache = {};

  String? getCached(String userId) => _cache[userId];

  Future<String?> getPhotoUrl(String userId) async {
    if (userId.isEmpty) return null;
    if (_cache.containsKey(userId)) return _cache[userId];

    try {
      final doc = await FirebaseFirestore.instance
          .collection(usersCollection)
          .doc(userId)
          .get();
      final photoUrl = doc.data()?['photoUrl'] as String?;
      _cache[userId] = (photoUrl != null && photoUrl.isNotEmpty) ? photoUrl : null;
      return _cache[userId];
    } catch (_) {
      return null;
    }
  }

  void invalidate(String userId) => _cache.remove(userId);

  void clear() => _cache.clear();
}
