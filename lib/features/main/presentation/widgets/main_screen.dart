import 'package:chat_material3/core/common/screens/under_build_screen.dart';
import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/core/enums/nav_bar_enum.dart';
import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/features/groups/presentation/screens/groups_chat_screen.dart';
import 'package:chat_material3/features/single_chat/presentation/screens/chat_home_screen.dart';
import 'package:chat_material3/features/main/presentation/bloc/main_cubit.dart';
import 'package:chat_material3/features/main/presentation/refactor/bottom_nav_bar.dart';
import 'package:chat_material3/features/main/presentation/refactor/main_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MainCubit>(),
      child: Scaffold(
        appBar: const MainAppBar(),
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(context.assets.homeBg!),
              fit: BoxFit.fill,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<MainCubit, MainState>(
                  builder: (context, state) {
                    final cubit = context.read<MainCubit>();
                    if (cubit.navBarEnum == NavBarEnum.singleChats) {
                      return const ChatHomeScreen();
                    } else if (cubit.navBarEnum == NavBarEnum.groups) {
                      return const GroupsChatScreen();
                    } else if (cubit.navBarEnum == NavBarEnum.calls) {
                      return const PageUnderBuildScreen();
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
