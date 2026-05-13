import 'package:chat_material3/core/common/animations/animate_do.dart';
import 'package:chat_material3/core/common/toast/show_toast.dart';
import 'package:chat_material3/core/common/widgets/text_app.dart';
import 'package:chat_material3/core/enums/nav_bar_enum.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/helper_functions/get_current_user.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/core/routes/app_routes.dart';
import 'package:chat_material3/core/style/fonts/font_weight_helper.dart';
import 'package:chat_material3/features/calls/presentation/bloc/calls_history_cubit/calls_history_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/get_chatss/chats_cubit.dart';
import 'package:chat_material3/features/main/presentation/bloc/main_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => Size(double.infinity, 70.h);
}

class _MainAppBarState extends State<MainAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<ChatsCubit>().clearSearch();
      }
    });
  }

  void _onSearchChanged(String text) {
    final currentUser = getCurrentUser();
    context.read<ChatsCubit>().searchChats(
          currentUserId: currentUser.uid,
          searchText: text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        final cubit = context.read<MainCubit>();

        if (_isSearching && cubit.navBarEnum != NavBarEnum.singleChats) {
          _isSearching = false;
          _searchController.clear();
        }

        return AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: context.color.surface,
          elevation: 0,
          title: _buildTitle(context, cubit.navBarEnum),
          actions: _buildActions(context, cubit.navBarEnum),
        );
      },
    );
  }

  Widget _buildTitle(BuildContext context, NavBarEnum navBarEnum) {
    if (navBarEnum == NavBarEnum.singleChats && _isSearching) {
      return CustomFadeInRight(
        duration: 300,
        child: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: _onSearchChanged,
          style: context.textStyle.copyWith(
            fontSize: 16.sp,
            color: context.color.onSurface,
          ),
          decoration: InputDecoration(
            hintText: context.translate(LangKeys.searchChats),
            hintStyle: context.textStyle.copyWith(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
            border: InputBorder.none,
          ),
        ),
      );
    }

    final title = switch (navBarEnum) {
      NavBarEnum.singleChats => context.translate(LangKeys.chats),
      NavBarEnum.groups => context.translate(LangKeys.yourGroups),
      NavBarEnum.status => context.translate(LangKeys.statusTitle),
      NavBarEnum.calls => context.translate(LangKeys.yourCalls),
    };

    return CustomFadeInRight(
      duration: 800,
      child: TextApp(
        text: title,
        theme: context.textStyle.copyWith(
          fontSize: 20.sp,
          fontWeight: FontWeightHelper.bold,
          color: context.color.onSurface,
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, NavBarEnum navBarEnum) {
    switch (navBarEnum) {
      case NavBarEnum.singleChats:
        return [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: context.color.onSurface,
            ),
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: Icon(
              Icons.person,
              color: context.color.onSurface,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ];
      case NavBarEnum.calls:
        return [
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: context.color.onSurface,
            ),
            onPressed: () => _showDeleteAllCallsDialog(context),
          ),
        ];
      default:
        return [];
    }
  }

  void _showDeleteAllCallsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: TextApp(
          text: context.translate(LangKeys.deleteAllCallHistory),
          theme: context.textStyle,
        ),
        content: TextApp(
          text: context.translate(LangKeys.deleteAllCallHistoryConfirm),
          theme: context.textStyle.copyWith(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: TextApp(
              text: context.translate(LangKeys.cancel),
              theme: context.textStyle,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CallsHistoryCubit>().deleteAllCallHistory(
                    currentUserId: getCurrentUser().uid,
                  );
              ShowToast.showToastSuccessTop(
                message: context
                    .translate(LangKeys.allCallsDeletedSuccessfully),
              );
            },
            child: TextApp(
              text: context.translate(LangKeys.yes),
              theme: context.textStyle.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
