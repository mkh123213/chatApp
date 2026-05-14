import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/service/fierstore/firestore_service.dart';
import 'package:chat_material3/core/service/push_notification/chat_notification_service.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/single_chat/data/datasources/block_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class GroupsRemoteDataSource {
  Stream<List<GroupModel>> getGroups({required String currentUserId});

  Future<void> createGroup({
    required String currentUserId,
    required String currentUserEmail,
    required String groupName,
    required List<String> membersIds,
    required List<String> membersEmails,
  });

  Stream<List<GroupMessageModel>> getGroupMessages({required String groupId});

  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required String text,
  });

  Future<void> updateGroupMessage({
    required String groupId,
    required String messageId,
    required String text,
  });

  Future<void> removeGroupMessage({
    required String groupId,
    required String messageId,
  });

  Stream<GroupModel> getGroupStream({required String groupId});

  Future<void> addMemberByEmail({
    required String groupId,
    required String memberEmail,
  });

  Future<void> removeMember({
    required String groupId,
    required String userId,
    required String userEmail,
  });

  Future<void> makeAdmin({required String groupId, required String userId});

  Future<void> removeAdmin({required String groupId, required String userId});

  Future<void> exitGroup({
    required String groupId,
    required String userId,
    required String userEmail,
  });

  ///////////////////// Helper methods for testing /////////////////////
  Future<void> sendGroupAttachmentMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required String text,
    required String type,
    required String fileUrl,
    required String fileName,
    required String storagePath,
  });

  Future<void> removeGroupMessages({
    required String groupId,
    required List<String> messageIds,
  });

  Future<void> updateGroupImage({
    required String groupId,
    required String imageUrl,
    required String storagePath,
  });

  Future<void> deleteGroupIfCreatorOrExit({
    required String groupId,
    required String userId,
    required String userEmail,
  });

  Future<void> markGroupMessagesAsRead({
    required String groupId,
    required String currentUserId,
  });
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  const GroupsRemoteDataSourceImpl({
    required DataBaseService dataBaseService,
    required BlockRemoteDataSource blockRemoteDataSource,
  })  : _dataBaseService = dataBaseService,
        _blockRemoteDataSource = blockRemoteDataSource;

  final DataBaseService _dataBaseService;
  final BlockRemoteDataSource _blockRemoteDataSource;

  @override
  Stream<List<GroupModel>> getGroups({required String currentUserId}) {
    return _dataBaseService.collectionStream(
      path: groupsCollection,
      builder: (data, id) => GroupModel.fromFirestore(id: id, data: data),
      queryBuilder: (query) =>
          query.where('members', arrayContains: currentUserId),
    );
  }

  @override
  Future<void> createGroup({
    required String currentUserId,
    required String currentUserEmail,
    required String groupName,
    required List<String> membersIds,
    required List<String> membersEmails,
  }) async {
    final groupId =
        FirebaseFirestore.instance.collection(groupsCollection).doc().id;

    final normalizedMemberIds = {...membersIds, currentUserId}.toList();
    final normalizedEmails = {
      ...membersEmails.map((e) => e.trim()).where((e) => e.isNotEmpty),
      currentUserEmail,
    }.toList();

    final groupData = {
      'id': groupId,
      'name': groupName,
      'imageUrl': '',
      'groupImageStoragePath': '',
      'creatorId': currentUserId,
      'members': normalizedMemberIds,
      'membersEmails': normalizedEmails,
      'admins': [currentUserId],
      'lastMessage': '',
      'lastMessageTime': null,
      'createdAt': Timestamp.now(),
    };

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: groupData,
    );
  }

  @override
  Stream<List<GroupMessageModel>> getGroupMessages({required String groupId}) {
    return _dataBaseService.collectionStream(
      path: '$groupsCollection/$groupId/$messagesCollection',
      builder: (data, id) =>
          GroupMessageModel.fromFirestore(id: id, data: data),
      queryBuilder: (query) => query.orderBy('createdAt', descending: true),
    );
  }

  @override
  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required String text,
  }) async {
    final messageId =
        FirebaseFirestore.instance.collection(groupsCollection).doc().id;
    final now = Timestamp.now();

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId/$messagesCollection/$messageId',
      data: {
        'id': messageId,
        'senderId': senderId,
        'senderEmail': senderEmail,
        'text': text,
        'createdAt': now,
        'updatedAt': null,
      },
    );

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'lastMessage': text,
        'lastMessageTime': now,
      },
    );

    final groupDoc = await FirebaseFirestore.instance
        .doc('$groupsCollection/$groupId')
        .get();
    final groupData = groupDoc.data();
    if (groupData != null) {
      final members = List<String>.from(groupData['members'] ?? []);
      final groupName = groupData['name'] as String? ?? 'Group';
      ChatNotificationService.instance.sendGroupMessageNotification(
        groupId: groupId,
        groupName: groupName,
        senderId: senderId,
        senderName: getCurrentUser().name ?? senderEmail,
        message: text,
        memberIds: members,
      );
    }
  }

  @override
  Stream<GroupModel> getGroupStream({required String groupId}) {
    return _dataBaseService.documentStream(
      path: '$groupsCollection/$groupId',
      builder: (data, id) => GroupModel.fromFirestore(id: id, data: data),
    );
  }

  @override
  Future<void> addMemberByEmail({
    required String groupId,
    required String memberEmail,
  }) async {
    final cleaned = memberEmail.trim().toLowerCase();

    final users = await _dataBaseService.getCollection<Map<String, dynamic>>(
      path: usersCollection,
      queryBuilder: (q) => q.where('email', isEqualTo: cleaned).limit(1),
      builder: (data, id) => {'id': id, ...data},
    );

    if (users.isEmpty) {
      throw Exception('No user found with this email.');
    }

    final user = users.first;
    final userId = user['id'] as String;
    final userEmail = user['email'] as String? ?? cleaned;

    final currentUserId = getCurrentUser().uid;
    final blocked = await _blockRemoteDataSource.isBlockedBetween(
      userId1: currentUserId,
      userId2: userId,
    );
    if (blocked) {
      throw Exception('Cannot add a blocked user to the group.');
    }

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'members': FieldValue.arrayUnion([userId]),
        'membersEmails': FieldValue.arrayUnion([userEmail]),
      },
    );
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
    required String userEmail,
  }) async {
    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'members': FieldValue.arrayRemove([userId]),
        'membersEmails': FieldValue.arrayRemove([userEmail]),
        'admins': FieldValue.arrayRemove([userId]),
      },
    );
  }

  @override
  Future<void> makeAdmin({
    required String groupId,
    required String userId,
  }) async {
    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'admins': FieldValue.arrayUnion([userId]),
      },
    );
  }

  @override
  Future<void> removeAdmin({
    required String groupId,
    required String userId,
  }) async {
    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'admins': FieldValue.arrayRemove([userId]),
      },
    );
  }

  @override
  Future<void> exitGroup({
    required String groupId,
    required String userId,
    required String userEmail,
  }) async {
    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'members': FieldValue.arrayRemove([userId]),
        'membersEmails': FieldValue.arrayRemove([userEmail]),
        'admins': FieldValue.arrayRemove([userId]),
      },
    );
  }

  @override
  Future<void> sendGroupAttachmentMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required String text,
    required String type,
    required String fileUrl,
    required String fileName,
    required String storagePath,
  }) async {
    final messageId =
        FirebaseFirestore.instance.collection(groupsCollection).doc().id;
    final now = Timestamp.now();

    final previewText = switch (type) {
      'image' => '📷 Image',
      'file' => '📎 $fileName',
      'link' => text,
      _ => text,
    };

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId/$messagesCollection/$messageId',
      data: {
        'id': messageId,
        'senderId': senderId,
        'senderEmail': senderEmail,
        'text': text,
        'type': type,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'storagePath': storagePath,
        'createdAt': now,
        'updatedAt': null,
      },
    );

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'lastMessage': previewText,
        'lastMessageTime': now,
      },
    );
  }

  @override
  Future<void> updateGroupMessage({
    required String groupId,
    required String messageId,
    required String text,
  }) async {
    final cleaned = text.trim();
    if (cleaned.isEmpty) return;

    final groupRef =
        FirebaseFirestore.instance.collection(groupsCollection).doc(groupId);

    final messageRef = groupRef.collection(messagesCollection).doc(messageId);

    final messageDoc = await messageRef.get();
    final data = messageDoc.data();

    if (data == null) return;

    final type = data['type'] as String? ?? 'text';

    // Only text and link messages can be edited.
    if (type != 'text' && type != 'link') return;

    await messageRef.update({
      'text': cleaned,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final latestMessage = await groupRef
        .collection(messagesCollection)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (latestMessage.docs.isNotEmpty &&
        latestMessage.docs.first.id == messageId) {
      await _dataBaseService.setData(
        path: '$groupsCollection/$groupId',
        data: {
          'lastMessage': cleaned,
        },
      );
    }
  }

  @override
  Future<void> removeGroupMessage({
    required String groupId,
    required String messageId,
  }) async {
    await removeGroupMessages(
      groupId: groupId,
      messageIds: [messageId],
    );
  }

  @override
  Future<void> removeGroupMessages({
    required String groupId,
    required List<String> messageIds,
  }) async {
    if (messageIds.isEmpty) return;

    final groupRef =
        FirebaseFirestore.instance.collection(groupsCollection).doc(groupId);

    final batch = FirebaseFirestore.instance.batch();

    for (final id in messageIds) {
      final ref = groupRef.collection(messagesCollection).doc(id);
      batch.delete(ref);
    }

    await batch.commit();

    final latestMessage = await groupRef
        .collection(messagesCollection)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (latestMessage.docs.isEmpty) {
      await _dataBaseService.setData(
        path: '$groupsCollection/$groupId',
        data: {
          'lastMessage': '',
          'lastMessageTime': null,
        },
      );
      return;
    }

    final latest = latestMessage.docs.first.data();
    final latestType = latest['type'] as String? ?? 'text';
    final latestText = latest['text'] as String? ?? '';
    final latestFileName = latest['fileName'] as String? ?? '';

    final previewText = switch (latestType) {
      'image' => '📷 Image',
      'file' => '📎 $latestFileName',
      'link' => latestText,
      _ => latestText,
    };

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'lastMessage': previewText,
        'lastMessageTime': latest['createdAt'],
      },
    );
  }

  @override
  Future<void> updateGroupImage({
    required String groupId,
    required String imageUrl,
    required String storagePath,
  }) async {
    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'imageUrl': imageUrl,
        'groupImageStoragePath': storagePath,
      },
    );
  }

  @override
  Future<void> deleteGroupIfCreatorOrExit({
    required String groupId,
    required String userId,
    required String userEmail,
  }) async {
    final groupRef =
        FirebaseFirestore.instance.collection(groupsCollection).doc(groupId);

    final groupDoc = await groupRef.get();
    final groupData = groupDoc.data();

    if (groupData == null) return;

    final creatorId = groupData['creatorId'] as String? ?? '';

    if (creatorId == userId) {
      final messages = await groupRef.collection(messagesCollection).get();

      final batch = FirebaseFirestore.instance.batch();

      for (final message in messages.docs) {
        batch.delete(message.reference);
      }

      batch.delete(groupRef);

      await batch.commit();
      return;
    }

    await _dataBaseService.setData(
      path: '$groupsCollection/$groupId',
      data: {
        'members': FieldValue.arrayRemove([userId]),
        'membersEmails': FieldValue.arrayRemove([userEmail]),
        'admins': FieldValue.arrayRemove([userId]),
      },
    );
  }

  @override
  Future<void> markGroupMessagesAsRead({
    required String groupId,
    required String currentUserId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('$groupsCollection/$groupId/$messagesCollection')
        .where('senderId', isNotEqualTo: currentUserId)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      final readBy = List<String>.from(doc.data()['readBy'] ?? []);
      if (!readBy.contains(currentUserId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
    }
    await batch.commit();
  }
}
