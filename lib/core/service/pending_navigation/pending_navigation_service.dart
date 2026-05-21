class PendingNavigationService {
  PendingNavigationService._();
  static final PendingNavigationService instance = PendingNavigationService._();

  PendingAction? _pendingAction;

  PendingAction? consume() {
    final action = _pendingAction;
    _pendingAction = null;
    return action;
  }

  bool get hasPending => _pendingAction != null;

  void setPendingCall(String callId) {
    _pendingAction = PendingAction(type: PendingType.call, id: callId);
  }

  void setPendingChat(String chatId) {
    _pendingAction = PendingAction(type: PendingType.chat, id: chatId);
  }

  void setPendingGroup(String groupId) {
    _pendingAction = PendingAction(type: PendingType.group, id: groupId);
  }
}

enum PendingType { call, chat, group }

class PendingAction {
  final PendingType type;
  final String id;

  const PendingAction({required this.type, required this.id});
}
