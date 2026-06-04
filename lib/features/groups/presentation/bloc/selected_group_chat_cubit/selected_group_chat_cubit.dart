import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_material3/core/service/supabase/supabase_storage_service.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/groups/data/repositories/groups_repo.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selected_group_chat_state.dart';
part 'selected_group_chat_cubit.freezed.dart';

class SelectedGroupChatCubit extends Cubit<SelectedGroupChatState> {
  SelectedGroupChatCubit({
    required GroupsRepo groupsRepo,
    required SupabaseStorageService storageService,
  })  : _groupsRepo = groupsRepo,
        _storageService = storageService,
        super(const SelectedGroupChatState.initial());

  final GroupsRepo _groupsRepo;
  final SupabaseStorageService _storageService;

  StreamSubscription<List<GroupMessageModel>>? _messagesSubscription;
  bool _isListeningToMessages = false;
  int? _disappearingDuration;
  
  List<GroupMessageModel> _messages = [];
  DocumentSnapshot? _lastDocument;

  void setDisappearingDuration(int? duration) {
    _disappearingDuration = duration;
  }

  List<GroupMessageModel> _filterExpired(List<GroupMessageModel> messages) {
    if (_disappearingDuration == null || _disappearingDuration == 0) {
      return messages;
    }
    final cutoff = DateTime.now()
        .subtract(Duration(seconds: _disappearingDuration!));
    return messages.where((m) {
      if (m.createdAt == null) return true;
      return m.createdAt!.isAfter(cutoff);
    }).toList();
  }

  Set<String> get selectedMessageIds {
    final s = state;
    if (s is _Loaded) return s.selectedIds;
    return const {};
  }

  bool get hasSelection => selectedMessageIds.isNotEmpty;
  bool get canUpdateSelectedMessage => selectedMessageIds.length == 1;

  void getGroupMessages({required String groupId}) {
    if (_isListeningToMessages) return;

    _isListeningToMessages = true;
    emit(const SelectedGroupChatState.loading());
    _messages = [];
    _lastDocument = null;

    _messagesSubscription =
        _groupsRepo.getGroupMessages(groupId: groupId).listen(
      (messages) {
        final filtered = _filterExpired(messages);
        _messages = filtered;
        if (_messages.isEmpty) {
          emit(const SelectedGroupChatState.empty());
        } else {
          emit(SelectedGroupChatState.loaded(messages: _messages, hasMore: true));
        }
      },
      onError: (e) => emit(SelectedGroupChatState.error(message: e.toString())),
    );
  }

  Future<void> loadMoreGroupMessages({required String groupId}) async {
    final currentState = state;
    if (currentState is _Loaded) {
      if (!currentState.hasMore || currentState.isLoadingMore) return;

      emit(currentState.copyWith(isLoadingMore: true));

      final snapshot = await _groupsRepo.getGroupMessagesPage(
        groupId: groupId,
        limit: 30,
        lastDocument: _lastDocument,
      );

      final newMessages = snapshot.docs
          .map((doc) => GroupMessageModel.fromFirestore(
              id: doc.id, data: doc.data() as Map<String, dynamic>))
          .toList();

      if (newMessages.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _messages.addAll(newMessages);
        emit(currentState.copyWith(
          messages: List.from(_messages),
          isLoadingMore: false,
          hasMore: newMessages.length == 30,
        ));
      } else {
        emit(currentState.copyWith(isLoadingMore: false, hasMore: false));
      }
    }
  }

  void toggleMessageSelection(String messageId) {
    final currentState = state;
    if (currentState is _Loaded) {
      final updated = Set<String>.of(currentState.selectedIds);
      if (updated.contains(messageId)) {
        updated.remove(messageId);
      } else {
        updated.add(messageId);
      }
      emit(SelectedGroupChatState.loaded(
        messages: currentState.messages,
        selectedIds: updated,
      ));
    }
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is _Loaded) {
      emit(SelectedGroupChatState.loaded(
        messages: currentState.messages,
        selectedIds: const {},
      ));
    }
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required String text,
  }) async {
    await _groupsRepo.sendGroupMessage(
      groupId: groupId,
      senderId: senderId,
      senderEmail: senderEmail,
      text: text,
    );
  }

  Future<void> sendLinkMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required String link,
  }) async {
    await _groupsRepo.sendGroupAttachmentMessage(
      groupId: groupId,
      senderId: senderId,
      senderEmail: senderEmail,
      text: link,
      type: 'link',
      fileUrl: '',
      fileName: '',
      storagePath: '',
    );
  }

  Future<void> sendImageMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required File imageFile,
    String caption = '',
  }) async {
    final uploaded = await _storageService.uploadMessageImage(
      groupId: groupId,
      file: imageFile,
    );

    await _groupsRepo.sendGroupAttachmentMessage(
      groupId: groupId,
      senderId: senderId,
      senderEmail: senderEmail,
      text: caption,
      type: 'image',
      fileUrl: uploaded.url,
      fileName: uploaded.fileName,
      storagePath: uploaded.storagePath,
    );
  }

  Future<void> sendFileMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required File file,
    required String fileName,
    String caption = '',
  }) async {
    final uploaded = await _storageService.uploadMessageFile(
      groupId: groupId,
      file: file,
      originalFileName: fileName,
    );

    await _groupsRepo.sendGroupAttachmentMessage(
      groupId: groupId,
      senderId: senderId,
      senderEmail: senderEmail,
      text: caption,
      type: 'file',
      fileUrl: uploaded.url,
      fileName: uploaded.fileName,
      storagePath: uploaded.storagePath,
    );
  }

  Future<void> updateGroupMessage({
    required String groupId,
    required String messageId,
    required String text,
  }) async {
    await _groupsRepo.updateGroupMessage(
      groupId: groupId,
      messageId: messageId,
      text: text,
    );
  }

  Future<void> removeSelectedMessages({
    required String groupId,
  }) async {
    final ids = selectedMessageIds.toList();

    if (ids.isEmpty) return;

    await _groupsRepo.removeGroupMessages(
      groupId: groupId,
      messageIds: ids,
    );

    clearSelection();
  }

  Future<void> updateGroupImage({
    required String groupId,
    required File imageFile,
  }) async {
    final uploaded = await _storageService.uploadGroupImage(
      groupId: groupId,
      file: imageFile,
    );

    await _groupsRepo.updateGroupImage(
      groupId: groupId,
      imageUrl: uploaded.url,
      storagePath: uploaded.storagePath,
    );
  }

  Future<void> markAsRead({
    required String groupId,
    required String currentUserId,
  }) async {
    await _groupsRepo.markGroupMessagesAsRead(
      groupId: groupId,
      currentUserId: currentUserId,
    );
  }

  @override
  Future<void> close() async {
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
