import 'package:chat_material3/core/enums/nav_bar_enum.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'main_state.dart';
part 'main_cubit.freezed.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(const MainState.initial());

  NavBarEnum navBarEnum = NavBarEnum.singleChats;

  void selectedNavBarIcons(NavBarEnum viewEnum) {
    navBarEnum = viewEnum;
    emit(MainState.barSeletedIcons(navBarEnum: navBarEnum));
  }
}
