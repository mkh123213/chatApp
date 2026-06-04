import 'package:chat_material3/core/di/injection_container.dart';
import 'package:chat_material3/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:chat_material3/features/profile/presentation/widgets/profile_bloc_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileCubit>(
      create: (context) => sl<ProfileCubit>()..loadUser(),
      child: const ProfileBlocConsumer(),
    );
  }
}
