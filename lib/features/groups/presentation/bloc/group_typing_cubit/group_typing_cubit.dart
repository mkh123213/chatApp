import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/features/single_chat/data/repositories/typing_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupTypingState {
  const GroupTypingState({this.typingUsers = const {}});
  final Map<String, bool> typingUsers;

  List<String> get activeTypingUserIds =>
      typingUsers.entries.where((e) => e.value).map((e) => e.key).toList();
}

class GroupTypingCubit extends Cubit<GroupTypingState> {
  GroupTypingCubit({required TypingRepo typingRepo})
      : _typingRepo = typingRepo,
        super(const GroupTypingState());

  final TypingRepo _typingRepo;
  StreamSubscription<Map<String, bool>>? _subscription;
  Timer? _debounceTimer;
  final _nameCache = <String, String>{};

  void watchTyping({required String groupId}) {
    _subscription?.cancel();
    _subscription = _typingRepo
        .watchTypingStatus(chatId: groupId, collection: groupsCollection)
        .listen(
      (typingUsers) {
        if (!isClosed) {
          emit(GroupTypingState(typingUsers: typingUsers));
          _loadNamesForTypingUsers(typingUsers);
        }
      },
    );
  }

  Future<void> _loadNamesForTypingUsers(Map<String, bool> typingUsers) async {
    final activeIds =
        typingUsers.entries.where((e) => e.value).map((e) => e.key).toList();
    final unknownIds =
        activeIds.where((id) => !_nameCache.containsKey(id)).toList();
    if (unknownIds.isEmpty) return;

    for (final id in unknownIds) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(id)
            .get();
        final data = doc.data();
        final name = data?['name'] as String? ?? '';
        _nameCache[id] = name.isNotEmpty
            ? name
            : (data?['email'] as String? ?? '').split('@').first;
      } catch (_) {
        _nameCache[id] = '?';
      }
    }
    if (!isClosed) emit(GroupTypingState(typingUsers: state.typingUsers));
  }

  String getTypingText(String currentUserId) {
    final activeIds = state.activeTypingUserIds
        .where((id) => id != currentUserId)
        .toList();
    if (activeIds.isEmpty) return '';

    final names = activeIds.map((id) => _nameCache[id] ?? '...').toList();

    if (names.length == 1) return '${names[0]} is typing...';
    if (names.length == 2) return '${names[0]}, ${names[1]} are typing...';
    return '${names.length} people are typing...';
  }

  bool isAnyoneTyping(String currentUserId) {
    return state.activeTypingUserIds
        .any((id) => id != currentUserId);
  }

  Future<void> setTyping({
    required String groupId,
    required String userId,
  }) async {
    _debounceTimer?.cancel();
    await _typingRepo.setTyping(
      chatId: groupId,
      userId: userId,
      isTyping: true,
      collection: groupsCollection,
    );
    _debounceTimer = Timer(const Duration(seconds: 3), () {
      clearTyping(groupId: groupId, userId: userId);
    });
  }

  Future<void> clearTyping({
    required String groupId,
    required String userId,
  }) async {
    _debounceTimer?.cancel();
    await _typingRepo.setTyping(
      chatId: groupId,
      userId: userId,
      isTyping: false,
      collection: groupsCollection,
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }
}
