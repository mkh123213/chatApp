// REUSABLE SERVICE: Generic app lifecycle presence tracker.
// CHANGE: Replace UserPresenceRepo with your project's presence repository.
import 'package:chat_material3/features/single_chat/data/repositories/user_presence_repo.dart'; // CHANGE: your presence repo import
import 'package:flutter/widgets.dart';

class UserPresenceService with WidgetsBindingObserver {
  UserPresenceService({
    required UserPresenceRepo userPresenceRepo, // CHANGE: your repo type
  }) : _userPresenceRepo = userPresenceRepo;

  final UserPresenceRepo _userPresenceRepo; // CHANGE: your repo type
  String? _userId;

  void start({required String userId}) {
    _userId = userId;
    WidgetsBinding.instance.addObserver(this);
    _userPresenceRepo.setOnline(userId: userId);
  }

  void stop() {
    if (_userId != null) {
      _userPresenceRepo.setOffline(userId: _userId!);
    }
    WidgetsBinding.instance.removeObserver(this);
    _userId = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_userId == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _userPresenceRepo.setOnline(userId: _userId!);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        _userPresenceRepo.setOffline(userId: _userId!);
        break;
      default:
        break;
    }
  }
}
