import 'dart:io';

import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/chat/chat_widgets.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/service/push_notification/active_chat_tracker.dart';
import 'package:chat_material3/features/calls/presentation/bloc/start_call_cubit/start_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/start_call_cubit/start_call_state.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/block_cubit/block_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/block_cubit/block_state.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/messages_cubit/messages_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/messages_cubit/messages_state.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/send_message_cubit/send_message_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/send_message_cubit/send_message_state.dart';
import 'package:chat_material3/core/app/app_cubit/unread_messages_cubit/unread_messages_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/user_presence_cubit/user_presence_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/messages_list_view.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/user_presence_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SingleChatScreen extends StatefulWidget {
  const SingleChatScreen({super.key, required this.chat});

  final ChatModel chat;

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  @override
  void initState() {
    super.initState();
    ActiveChatTracker.instance.setActiveChat(widget.chat.id);
  }

  @override
  void dispose() {
    ActiveChatTracker.instance.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = widget.chat;
    final currentUser = getCurrentUser();
    final currentUserId = currentUser.uid;
    final friendId =
        chat.users.where((id) => id != currentUserId).firstOrNull ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<MessagesCubit>()
            ..loadMessages(chatId: chat.id)
            ..markAsRead(
              chatId: chat.id,
              currentUserId: currentUserId,
            ),
        ),
        BlocProvider(
          create: (_) => sl<SendMessageCubit>(),
        ),
        BlocProvider(
          create: (_) => sl<StartCallCubit>(),
        ),
        if (friendId.isNotEmpty)
          BlocProvider(
            create: (_) =>
                sl<UserPresenceCubit>()..watchUserPresence(userId: friendId),
          ),
        BlocProvider(
          create: (_) => sl<BlockCubit>()
            ..watchBlockStatus(
              currentUserId: currentUserId,
              otherUserId: friendId,
            ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<SendMessageCubit, SendMessageState>(
            listener: (context, state) {
              if (state is SendMessageError) {
                ShowToast.showToastErrorTop(message: state.message);
              } else if (state is SendMessageEdited) {
                ShowToast.showToastSuccessTop(
                  message:
                      context.translate(LangKeys.messageUpdatedSuccessfully),
                );
              } else if (state is SendMessageDeleted) {
                ShowToast.showToastSuccessTop(
                  message:
                      context.translate(LangKeys.messageDeletedSuccessfully),
                );
              }
            },
          ),
          BlocListener<StartCallCubit, StartCallState>(
            listener: (context, state) {
              if (state is StartCallSuccess) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.callScreen,
                  arguments: state.call,
                );
              } else if (state is StartCallError) {
                ShowToast.showToastErrorTop(message: state.message);
              }
            },
          ),
          BlocListener<BlockCubit, BlockState>(
            listener: (context, state) {
              state.when(
                initial: () {},
                loading: () {},
                blocked: (blockedByMe) {
                  if (blockedByMe) {
                    ShowToast.showToastSuccessTop(
                      message: context.translate(LangKeys.userBlocked),
                    );
                  }
                },
                notBlocked: () {},
                error: (msg) => ShowToast.showToastErrorTop(message: msg),
              );
            },
          ),
        ],
        child: Builder(
            builder: (context) => Column(
                  children: [
                    _SingleChatHeader(
                      chat: chat,
                      friendDisplayName: _getFriendDisplayName(chat),
                      friendId: friendId,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        child: Column(
                          children: [
                            Expanded(
                              child: MessagesListView(chat: chat),
                            ),
                            BlocBuilder<BlockCubit, BlockState>(
                              builder: (context, blockState) {
                                final isBlocked = blockState.when(
                                  initial: () => false,
                                  loading: () => false,
                                  blocked: (_) => true,
                                  notBlocked: () => false,
                                  error: (_) => false,
                                );
                                if (isBlocked) {
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      context
                                          .translate(LangKeys.blockedMessage),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.red,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                }
                                return ChatMessageInput(
                                  onSendText: (text) {
                                    context
                                        .read<SendMessageCubit>()
                                        .sendTextMessage(
                                          chat: chat,
                                          text: text,
                                        );
                                  },
                                  onPickImage: (File imageFile, String caption) {
                                    context
                                        .read<SendMessageCubit>()
                                        .sendImageMessage(
                                          chat: chat,
                                          imageFile: imageFile,
                                          caption: caption,
                                        );
                                  },
                                  onPickFile: (File file, String fileName, String caption) {
                                    context
                                        .read<SendMessageCubit>()
                                        .sendFileMessage(
                                          chat: chat,
                                          file: file,
                                          originalFileName: fileName,
                                          caption: caption,
                                        );
                                  },
                                  onSendVoice: (File voiceFile, Duration duration) {
                                    context
                                        .read<SendMessageCubit>()
                                        .sendVoiceMessage(
                                          chat: chat,
                                          voiceFile: voiceFile,
                                          duration: duration,
                                        );
                                  },
                                  onSendSticker: (String sticker) {
                                    context
                                        .read<SendMessageCubit>()
                                        .sendStickerMessage(
                                          chat: chat,
                                          sticker: sticker,
                                        );
                                  },
                                  onSendGif: (String gifUrl) {
                                    context
                                        .read<SendMessageCubit>()
                                        .sendGifMessage(
                                          chat: chat,
                                          gifUrl: gifUrl,
                                        );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
      ),
    );
  }
}

String _getFriendDisplayName(ChatModel chat) {
  final currentUser = getCurrentUser();
  final currentUserId = currentUser.uid;
  final currentUserEmail = currentUser.email ?? '';

  final userIndex = chat.users.indexOf(currentUserId);
  if (chat.usersNames != null && chat.usersNames!.length >= 2) {
    final friendIndex = userIndex == 0 ? 1 : 0;
    final friendName = chat.usersNames![friendIndex];
    if (friendName.isNotEmpty) return friendName;
  }

  return chat.usersEmails
          ?.where((e) => e.toLowerCase() != currentUserEmail.toLowerCase())
          .firstOrNull ??
      '';
}

class _SingleChatHeader extends StatelessWidget {
  const _SingleChatHeader({
    required this.chat,
    required this.friendDisplayName,
    required this.friendId,
  });

  final ChatModel chat;
  final String friendDisplayName;
  final String friendId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessagesCubit, MessagesState>(
      buildWhen: (prev, curr) {
        final prevSelected =
            prev is MessagesLoaded ? prev.selectedIds : const <String>{};
        final currSelected =
            curr is MessagesLoaded ? curr.selectedIds : const <String>{};
        return prevSelected != currSelected;
      },
      builder: (context, state) {
        final messagesCubit = context.read<MessagesCubit>();
        final selectedIds = messagesCubit.selectedMessageIds;

        if (selectedIds.isNotEmpty) {
          return ChatSelectedAppBar(
            selectedCount: selectedIds.length,
            onClose: messagesCubit.clearSelection,
            onEdit: selectedIds.length == 1
                ? () => _handleEdit(context, messagesCubit)
                : null,
            onDelete: () => _handleDelete(context, messagesCubit),
          );
        }

        return BlocBuilder<BlockCubit, BlockState>(
          builder: (context, blockState) {
            final isBlocked = blockState.when(
              initial: () => false,
              loading: () => false,
              blocked: (_) => true,
              notBlocked: () => false,
              error: (_) => false,
            );
            final blockedByMe = blockState.when(
              initial: () => false,
              loading: () => false,
              blocked: (byMe) => byMe,
              notBlocked: () => false,
              error: (_) => false,
            );

            return ChatAppBar(
              title: friendDisplayName,
              subtitle: isBlocked
                  ? null
                  : (friendId.isNotEmpty ? const UserPresenceStatus() : null),
              onTitleTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.contactInfo,
                  arguments: {
                    'chat': chat,
                    'friendDisplayName': friendDisplayName,
                    'friendId': friendId,
                    'blockCubit': context.read<BlockCubit>(),
                  },
                );
              },
              actions: [
                if (!isBlocked) ...[
                  IconButton(
                    icon: const Icon(Icons.videocam),
                    onPressed: () => context
                        .read<StartCallCubit>()
                        .startVideoCall(chat: chat),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call),
                    onPressed: () => context
                        .read<StartCallCubit>()
                        .startAudioCall(chat: chat),
                  ),
                ],
                PopupMenuButton<String>(
                  onSelected: (value) =>
                      _handleMenuAction(context, value, blockedByMe),
                  itemBuilder: (context) => [
                    if (blockedByMe)
                      PopupMenuItem(
                        value: 'unblock',
                        child: Row(
                          children: [
                            const Icon(Icons.block, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(context.translate(LangKeys.unblockUser)),
                          ],
                        ),
                      )
                    else
                      PopupMenuItem(
                        value: 'block',
                        child: Row(
                          children: [
                            const Icon(Icons.block, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(context.translate(LangKeys.blockUser)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleMenuAction(
      BuildContext context, String action, bool blockedByMe) {
    final blockCubit = context.read<BlockCubit>();
    if (action == 'block') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.translate(LangKeys.blockUser)),
          content: Text(context.translate(LangKeys.blockConfirm)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.translate(LangKeys.cancel)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                blockCubit.blockUser();
              },
              child: Text(
                context.translate(LangKeys.blockUser),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else if (action == 'unblock') {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.translate(LangKeys.unblockUser)),
          content: Text(context.translate(LangKeys.unblockConfirm)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.translate(LangKeys.cancel)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                blockCubit.unblockUser();
              },
              child: Text(
                context.translate(LangKeys.unblockUser),
                style: const TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _handleEdit(BuildContext context, MessagesCubit messagesCubit) {
    final sendCubit = context.read<SendMessageCubit>();
    final state = messagesCubit.state;
    if (state is! MessagesLoaded) return;

    final messageId = messagesCubit.selectedMessageIds.first;
    final msg = state.messages.firstWhere((m) => m.id == messageId);

    if (msg.type != 'text') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.translate(LangKeys.onlyTextMessagesCanBeEdited),
          ),
        ),
      );
      return;
    }

    showChatEditMessageDialog(
      context: context,
      currentText: msg.text,
      onSave: (newText) {
        sendCubit.updateMessage(
          chatId: chat.id,
          messageId: messageId,
          text: newText,
        );
        messagesCubit.clearSelection();
      },
    );
  }

  void _handleDelete(BuildContext context, MessagesCubit messagesCubit) {
    final sendCubit = context.read<SendMessageCubit>();
    final state = messagesCubit.state;
    if (state is! MessagesLoaded) return;

    final ids = messagesCubit.selectedMessageIds.toList();

    showChatDeleteMessageDialog(
      context: context,
      onDelete: () {
        for (final id in ids) {
          final msg = state.messages.firstWhere((m) => m.id == id);
          sendCubit.deleteMessage(
            chatId: chat.id,
            messageId: id,
            storagePath: msg.storagePath,
          );
        }
        messagesCubit.clearSelection();
      },
    );
  }
}
