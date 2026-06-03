import 'package:chat_material3/features/groups/data/datasources/groups_remote_data_source.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';

abstract class GroupsRepo {
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

class GroupsRepoImpl implements GroupsRepo {
  const GroupsRepoImpl({
    required GroupsRemoteDataSource groupsRemoteDataSource,
  }) : _groupsRemoteDataSource = groupsRemoteDataSource;

  final GroupsRemoteDataSource _groupsRemoteDataSource;

  @override
  Stream<List<GroupModel>> getGroups({required String currentUserId}) =>
      _groupsRemoteDataSource.getGroups(currentUserId: currentUserId);

  @override
  Future<void> createGroup({
    required String currentUserId,
    required String currentUserEmail,
    required String groupName,
    required List<String> membersIds,
    required List<String> membersEmails,
  }) =>
      _groupsRemoteDataSource.createGroup(
        currentUserId: currentUserId,
        currentUserEmail: currentUserEmail,
        groupName: groupName,
        membersIds: membersIds,
        membersEmails: membersEmails,
      );

  @override
  Stream<List<GroupMessageModel>> getGroupMessages({required String groupId}) =>
      _groupsRemoteDataSource.getGroupMessages(groupId: groupId);

  @override
  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required String senderEmail,
    required String text,
  }) =>
      _groupsRemoteDataSource.sendGroupMessage(
        groupId: groupId,
        senderId: senderId,
        senderEmail: senderEmail,
        text: text,
      );

  @override
  Future<void> updateGroupMessage({
    required String groupId,
    required String messageId,
    required String text,
  }) =>
      _groupsRemoteDataSource.updateGroupMessage(
        groupId: groupId,
        messageId: messageId,
        text: text,
      );

  @override
  Future<void> removeGroupMessage({
    required String groupId,
    required String messageId,
  }) =>
      _groupsRemoteDataSource.removeGroupMessage(
        groupId: groupId,
        messageId: messageId,
      );

  @override
  Stream<GroupModel> getGroupStream({required String groupId}) =>
      _groupsRemoteDataSource.getGroupStream(groupId: groupId);

  @override
  Future<void> addMemberByEmail({
    required String groupId,
    required String memberEmail,
  }) =>
      _groupsRemoteDataSource.addMemberByEmail(
        groupId: groupId,
        memberEmail: memberEmail,
      );

  @override
  Future<void> removeMember({
    required String groupId,
    required String userId,
    required String userEmail,
  }) =>
      _groupsRemoteDataSource.removeMember(
        groupId: groupId,
        userId: userId,
        userEmail: userEmail,
      );

  @override
  Future<void> makeAdmin({
    required String groupId,
    required String userId,
  }) =>
      _groupsRemoteDataSource.makeAdmin(
        groupId: groupId,
        userId: userId,
      );

  @override
  Future<void> removeAdmin({
    required String groupId,
    required String userId,
  }) =>
      _groupsRemoteDataSource.removeAdmin(
        groupId: groupId,
        userId: userId,
      );

  @override
  Future<void> exitGroup({
    required String groupId,
    required String userId,
    required String userEmail,
  }) =>
      _groupsRemoteDataSource.exitGroup(
        groupId: groupId,
        userId: userId,
        userEmail: userEmail,
      );

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
  }) =>
      _groupsRemoteDataSource.sendGroupAttachmentMessage(
        groupId: groupId,
        senderId: senderId,
        senderEmail: senderEmail,
        text: text,
        type: type,
        fileUrl: fileUrl,
        fileName: fileName,
        storagePath: storagePath,
      );

  @override
  Future<void> removeGroupMessages({
    required String groupId,
    required List<String> messageIds,
  }) =>
      _groupsRemoteDataSource.removeGroupMessages(
        groupId: groupId,
        messageIds: messageIds,
      );

  @override
  Future<void> updateGroupImage({
    required String groupId,
    required String imageUrl,
    required String storagePath,
  }) =>
      _groupsRemoteDataSource.updateGroupImage(
        groupId: groupId,
        imageUrl: imageUrl,
        storagePath: storagePath,
      );

  @override
  Future<void> deleteGroupIfCreatorOrExit({
    required String groupId,
    required String userId,
    required String userEmail,
  }) =>
      _groupsRemoteDataSource.deleteGroupIfCreatorOrExit(
        groupId: groupId,
        userId: userId,
        userEmail: userEmail,
      );

  @override
  Future<void> markGroupMessagesAsRead({
    required String groupId,
    required String currentUserId,
  }) =>
      _groupsRemoteDataSource.markGroupMessagesAsRead(
        groupId: groupId,
        currentUserId: currentUserId,
      );
}
