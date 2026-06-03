import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/features/groups/data/models/group_message_model.dart';
import 'package:chat_material3/features/groups/presentation/bloc/selected_group_chat_cubit/selected_group_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/block_cubit/block_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_material3/core/common/widgets/chat/message_read_status.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:intl/intl.dart';

class GroupMessagesBlocConsumer extends StatefulWidget {
  const GroupMessagesBlocConsumer({
    super.key,
    required this.groupId,
    required this.currentUserId,
    this.totalMembers = 0,
  });

  final String groupId;
  final String currentUserId;
  final int totalMembers;

  @override
  State<GroupMessagesBlocConsumer> createState() =>
      _GroupMessagesBlocConsumerState();
}

class _GroupMessagesBlocConsumerState extends State<GroupMessagesBlocConsumer> {
  final _nameCache = <String, String>{};

  static const _senderColors = [
    Color(0xFFEF5350),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
    Color(0xFFEC407A),
    Color(0xFF00897B),
  ];

  Future<void> _ensureNamesLoaded(List<GroupMessageModel> messages) async {
    final unknownIds = <String>{};
    for (final msg in messages) {
      if (msg.senderId != widget.currentUserId &&
          !_nameCache.containsKey(msg.senderId)) {
        unknownIds.add(msg.senderId);
      }
    }
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
    if (mounted) setState(() {});
  }

  Color _colorForSender(String senderId) {
    final hash = senderId.codeUnits.fold<int>(0, (prev, c) => prev + c);
    return _senderColors[hash % _senderColors.length];
  }

  String _initialForName(String name) {
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _navigateToContactInfo(BuildContext context, String senderId) {
    final currentUser = getCurrentUser();
    final name = _nameCache[senderId] ?? '?';

    Navigator.pushNamed(
      context,
      AppRoutes.contactInfo,
      arguments: {
        'chat': null,
        'friendDisplayName': name,
        'friendId': senderId,
        'blockCubit': BlockCubit(blockRepo: sl())
          ..watchBlockStatus(
            currentUserId: currentUser.uid,
            otherUserId: senderId,
          ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SelectedGroupChatCubit, SelectedGroupChatState>(
      listener: (_, __) {},
      builder: (context, state) {
        final cubit = context.read<SelectedGroupChatCubit>();
        return state.when(
          initial: () => const Center(child: CircularProgressIndicator()),
          loading: () => const Center(child: CircularProgressIndicator()),
          empty: () => Center(
            child: TextApp(
              text: context.translate(LangKeys.noMessagesYet),
              theme: context.textStyle,
            ),
          ),
          loaded: (messages, selectedIds) {
            _ensureNamesLoaded(messages);
            return ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final message = messages[i];
                final isMe = message.senderId == widget.currentUserId;
                final time = message.createdAt != null
                    ? DateFormat('h:mm a').format(message.createdAt!)
                    : '';

                final senderName =
                    _nameCache[message.senderId] ?? message.senderEmail.split('@').first;
                final senderColor = _colorForSender(message.senderId);
                final initial = _initialForName(senderName);

                return ChatMessageBubble(
                  text: message.text.isNotEmpty
                      ? message.text
                      : (message.fileUrl ?? message.fileName ?? ''),
                  messageType: _mapType(message.type),
                  isMe: isMe,
                  time: time,
                  mediaUrl: message.fileUrl,
                  fileName: message.fileName,
                  isSelected: selectedIds.contains(message.id),
                  senderLabel: isMe ? null : senderName,
                  senderInitial: isMe ? null : initial,
                  senderLabelColor: isMe ? null : senderColor,
                  onAvatarTap: isMe
                      ? null
                      : () => _navigateToContactInfo(context, message.senderId),
                  onImageTap: message.type == GroupMessageType.image &&
                          message.fileUrl != null &&
                          message.fileUrl!.isNotEmpty
                      ? () => openChatImageViewer(context, message.fileUrl!)
                      : null,
                  onLongPress: () => cubit.toggleMessageSelection(message.id),
                  readStatus: isMe
                      ? (message.readBy.length >= widget.totalMembers - 1 &&
                              widget.totalMembers > 1
                          ? ReadStatus.read
                          : ReadStatus.delivered)
                      : null,
                );
              },
            );
          },
          error: (message) => Center(
            child: TextApp(
              text: message,
              theme: context.textStyle,
            ),
          ),
        );
      },
    );
  }

  ChatMessageType _mapType(GroupMessageType type) {
    return switch (type) {
      GroupMessageType.image => ChatMessageType.image,
      GroupMessageType.file => ChatMessageType.file,
      GroupMessageType.link => ChatMessageType.link,
      GroupMessageType.text => ChatMessageType.text,
    };
  }
}
