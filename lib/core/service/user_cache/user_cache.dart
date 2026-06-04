class UserCache {
  UserCache._();
  static final UserCache instance = UserCache._();

  final Map<String, Map<String, String>> _cache = {};

  void cacheUser({required String userId, required String name, required String photoUrl}) {
    _cache[userId] = {'name': name, 'photoUrl': photoUrl};
  }

  Map<String, String>? getUser(String userId) {
    return _cache[userId];
  }
  
  void clear() {
    _cache.clear();
  }
}
