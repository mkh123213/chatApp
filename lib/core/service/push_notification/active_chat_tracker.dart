class ActiveChatTracker {
  ActiveChatTracker._();
  static final ActiveChatTracker instance = ActiveChatTracker._();

  String? _activeChatId;
  String? _activeGroupId;

  void setActiveChat(String chatId) {
    _activeChatId = chatId;
    _activeGroupId = null;
  }

  void setActiveGroup(String groupId) {
    _activeGroupId = groupId;
    _activeChatId = null;
  }

  void clear() {
    _activeChatId = null;
    _activeGroupId = null;
  }

  bool isActiveChat(String chatId) => _activeChatId == chatId;
  bool isActiveGroup(String groupId) => _activeGroupId == groupId;
}
