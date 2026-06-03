import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/features/single_chat/data/repositories/user_presence_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_presence_state.dart';

class UserPresenceCubit extends Cubit<UserPresenceState> {
  UserPresenceCubit({
    required UserPresenceRepo userPresenceRepo,
  })  : _userPresenceRepo = userPresenceRepo,
        super(const UserPresenceState.initial());

  final UserPresenceRepo _userPresenceRepo;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  void watchUserPresence({required String userId}) {
    _subscription?.cancel();
    _subscription = _userPresenceRepo
        .getUserPresence(userId: userId)
        .listen(
      (data) {
        final isOnline = data['isOnline'] as bool? ?? false;
        final lastSeenRaw = data['lastSeen'];

        if (isOnline) {
          emit(const UserPresenceState.online());
        } else {
          DateTime? lastSeen;
          if (lastSeenRaw is Timestamp) {
            lastSeen = lastSeenRaw.toDate();
          } else if (lastSeenRaw is String) {
            lastSeen = DateTime.tryParse(lastSeenRaw);
          }
          if (lastSeen != null) {
            emit(UserPresenceState.offline(lastSeen: lastSeen));
          }
        }
      },
      onError: (error) {
        emit(UserPresenceState.error(message: error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
