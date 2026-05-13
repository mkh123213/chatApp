part of 'group_info_cubit.dart';

sealed class GroupInfoState {}

final class GroupInfoInitial extends GroupInfoState {}

final class GroupInfoLoading extends GroupInfoState {}

final class GroupInfoLoaded extends GroupInfoState {
  final GroupModel group;
  GroupInfoLoaded({required this.group});
}

final class GroupInfoError extends GroupInfoState {
  final String message;
  GroupInfoError({required this.message});
}

final class GroupInfoActionError extends GroupInfoState {
  final GroupModel group;
  final String message;
  GroupInfoActionError({required this.group, required this.message});
}

final class GroupInfoExited extends GroupInfoState {}
