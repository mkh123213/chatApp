import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/create_chat_cubit/create_chat_state.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/contacts_tab.dart';
import 'package:chat_material3/features/single_chat/presentation/widgets/search_users_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewChatScreen extends StatelessWidget {
  const NewChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CreateChatCubit>(),
      child: const _NewChatScreenBody(),
    );
  }
}

class _NewChatScreenBody extends StatefulWidget {
  const _NewChatScreenBody();

  @override
  State<_NewChatScreenBody> createState() => _NewChatScreenBodyState();
}

class _NewChatScreenBodyState extends State<_NewChatScreenBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onUserSelected(Map<String, dynamic> user) {
    final email = user['email'] as String? ?? '';
    if (email.isEmpty) {
      ShowToast.showToastErrorTop(
        message: context.translate(LangKeys.pleaseEnterEmail),
      );
      return;
    }

    context.read<CreateChatCubit>().createChat(
          currentUserId: getCurrentUser().uid,
          currentUserEmail: getCurrentUser().email ?? '',
          friendEmail: email,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateChatCubit, CreateChatState>(
      listener: (context, state) {
        if (state is CreateChatSuccess) {
          ShowToast.showToastSuccessTop(
            message: context.translate(LangKeys.chatCreatedSuccessfully),
          );
          Navigator.pop(context);
        } else if (state is CreateChatError) {
          ShowToast.showToastErrorTop(message: state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.translate(LangKeys.newChat)),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: context.translate(LangKeys.contacts)),
              Tab(text: context.translate(LangKeys.searchUsers)),
            ],
            indicatorColor: context.color.primary,
            labelColor: context.color.primary,
          ),
        ),
        body: BlocBuilder<CreateChatCubit, CreateChatState>(
          builder: (context, state) {
            if (state is CreateChatLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return TabBarView(
              controller: _tabController,
              children: [
                ContactsTab(onUserSelected: _onUserSelected),
                SearchUsersTab(onUserSelected: _onUserSelected),
              ],
            );
          },
        ),
      ),
    );
  }
}
