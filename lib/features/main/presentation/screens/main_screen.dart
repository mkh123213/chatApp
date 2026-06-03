import 'dart:async';

import 'package:chat_material3/constants/fierstore_paths.dart';
import 'package:chat_material3/core/common/screens/under_build_screen.dart';
import 'package:chat_material3/core/service/pending_navigation/pending_navigation_service.dart';
import 'package:chat_material3/features/calls/data/models/call_model.dart';
import 'package:chat_material3/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart';
import 'package:chat_material3/features/calls/presentation/screens/calls_history_screen.dart';
import 'package:chat_material3/features/groups/data/models/group_model.dart';
import 'package:chat_material3/features/single_chat/data/models/chat_model.dart';
import 'package:chat_material3/features/status/presentation/bloc/my_status_cubit/my_status_cubit.dart';
import 'package:chat_material3/features/status/presentation/bloc/status_cubit/status_cubit.dart';
import 'package:chat_material3/features/status/presentation/widgets/status_body.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/enums/nav_bar_enum.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/service/push_notification/local_notfication_service.dart';
import 'package:chat_material3/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_cubit.dart';
import 'package:chat_material3/features/calls/presentation/bloc/incoming_call_cubit/incoming_call_state.dart';
import 'package:chat_material3/core/service/call_service/callkit_service.dart';
import 'package:chat_material3/features/calls/presentation/widgets/incoming_call_overlay.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/typing_cubit/chat_list_typing_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/screens/chat_home_screen.dart';
import 'package:chat_material3/features/main/presentation/bloc/main_cubit.dart';
import 'package:chat_material3/features/main/presentation/refactor/bottom_nav_bar.dart';
import 'package:chat_material3/features/main/presentation/refactor/main_app_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../groups/presentation/screens/groups_chat_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Timer? _pendingCheckTimer;

  @override
  void initState() {
    super.initState();
    _checkPendingNavigation();
  }

  @override
  void dispose() {
    _pendingCheckTimer?.cancel();
    super.dispose();
  }

  void _checkPendingNavigation() {
    final pending = PendingNavigationService.instance.consume();
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _executePendingNavigation(pending);
      });
      return;
    }

    // CallKit accept event may arrive slightly after MainScreen builds.
    // Poll briefly to catch it.
    var checks = 0;
    _pendingCheckTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      checks++;
      final action = PendingNavigationService.instance.consume();
      if (action != null) {
        timer.cancel();
        _executePendingNavigation(action);
      } else if (checks >= 10) {
        timer.cancel();
      }
    });
  }

  Future<void> _executePendingNavigation(PendingAction pending) async {
    if (!mounted) return;
    try {
      switch (pending.type) {
        case PendingType.call:
          final doc = await FirebaseFirestore.instance
              .doc('$callsCollection/${pending.id}')
              .get();
          if (!doc.exists || doc.data() == null) return;
          final call = CallModel.fromFirestore(id: doc.id, data: doc.data()!);
          if (!mounted) return;
          Navigator.of(context).pushNamed(AppRoutes.callScreen, arguments: call);
        case PendingType.chat:
          final doc = await FirebaseFirestore.instance
              .doc('$chatsCollection/${pending.id}')
              .get();
          if (!doc.exists || doc.data() == null) return;
          final chat = ChatModel.fromFirestore(id: doc.id, data: doc.data()!);
          if (!mounted) return;
          Navigator.of(context).pushNamed(AppRoutes.singleChat, arguments: chat);
        case PendingType.group:
          final doc = await FirebaseFirestore.instance
              .doc('$groupsCollection/${pending.id}')
              .get();
          if (!doc.exists || doc.data() == null) return;
          final group = GroupModel.fromFirestore(id: doc.id, data: doc.data()!);
          if (!mounted) return;
          Navigator.of(context).pushNamed(AppRoutes.selectedGroupChat, arguments: group);
      }
    } catch (e) {
      debugPrint('Pending navigation failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<ChatsCubit>()..getChats(currentUserId: getCurrentUser().uid),
        ),
        BlocProvider(
          create: (context) => sl<IncomingCallCubit>()
            ..listenForIncomingCalls(currentUserId: getCurrentUser().uid),
        ),
        BlocProvider(
          create: (_) => sl<CallsHistoryCubit>()
            ..getCallsHistory(currentUserId: getCurrentUser().uid),
        ),
        BlocProvider(
          create: (_) => sl<ChatListTypingCubit>(),
        ),
      ],
      child: BlocListener<IncomingCallCubit, IncomingCallState>(
        listener: (context, state) {
          if (state is IncomingCallReceived) {
            IncomingCallOverlay.show(context, state.call);
          } else if (state is IncomingCallNone) {
            IncomingCallOverlay.dismiss(context);
            CallKitService.instance.endAllCalls();
          }
        },
        child: Scaffold(
          appBar: const MainAppBar(),
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<MainCubit, MainState>(
                  builder: (context, state) {
                    final cubit = context.read<MainCubit>();
                    if (cubit.navBarEnum == NavBarEnum.singleChats) {
                      return BlocProvider(
                        create: (context) => sl<CreateChatCubit>(),
                        child: const ChatHomeScreen(),
                      );
                    } else if (cubit.navBarEnum == NavBarEnum.groups) {
                      return const GroupsChatScreen();
                    } else if (cubit.navBarEnum == NavBarEnum.status) {
                      return MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (_) => sl<StatusCubit>()
                              ..subscribe(getCurrentUser().uid),
                          ),
                          BlocProvider(
                            create: (_) => sl<MyStatusCubit>()
                              ..subscribe(getCurrentUser().uid),
                          ),
                        ],
                        child: const StatusBody(),
                      );
                    } else if (cubit.navBarEnum == NavBarEnum.calls) {
                      return const CallsHistoryScreen();
                    } else if (cubit.navBarEnum == NavBarEnum.profile) {
                      return const ProfileScreen();
                    }
                    return const ChatHomeScreen();
                  },
                ),
              ),
              const MainBottomNavBar(),
            ],
          ),
        ),
      ),
    );
  }
}
