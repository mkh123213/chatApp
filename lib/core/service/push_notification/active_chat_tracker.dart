// REUSABLE SERVICE: Tracks which chat/group the user is currently viewing.
// REQUIRES: cloud_firestore package in pubspec.yaml
// CHANGE: Update `usersCollection` import to your project's Firestore collection paths.
// CHANGE: Update `getCurrentUser()` import to your project's current user helper.
import 'package:chat_material3/constants/fierstore_paths.dart'; // CHANGE: your collection paths
import 'package:chat_material3/core/helper_functions/get_current_user.dart'; // CHANGE: your current user helper
import 'package:cloud_firestore/cloud_firestore.dart';

class ActiveChatTracker {
  ActiveChatTracker._();
  static final ActiveChatTracker instance = ActiveChatTracker._();

  String? _activeChatId;
  String? _activeGroupId;

  void setActiveChat(String chatId) {
    _activeChatId = chatId;
    _activeGroupId = null;
    _syncToFirestore(activeChatId: chatId);
  }

  void setActiveGroup(String groupId) {
    _activeGroupId = groupId;
    _activeChatId = null;
    _syncToFirestore(activeGroupId: groupId);
  }

  void clear() {
    _activeChatId = null;
    _activeGroupId = null;
    _syncToFirestore();
  }

  bool isActiveChat(String chatId) => _activeChatId == chatId;
  bool isActiveGroup(String groupId) => _activeGroupId == groupId;

  void _syncToFirestore({String? activeChatId, String? activeGroupId}) {
    final uid = getCurrentUser().uid;
    FirebaseFirestore.instance.doc('$usersCollection/$uid').set(
      {
        'activeChatId': activeChatId ?? '',
        'activeGroupId': activeGroupId ?? '',
      },
      SetOptions(merge: true),
    );
  }
}
