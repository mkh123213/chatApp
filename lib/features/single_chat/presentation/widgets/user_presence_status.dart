import 'dart:async';

import 'package:chat_material3/core/extensions/context_extension.dart';
import 'package:chat_material3/core/language/lang_keys.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/user_presence_cubit/user_presence_cubit.dart';
import 'package:chat_material3/features/single_chat/presentation/bloc/user_presence_cubit/user_presence_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class UserPresenceStatus extends StatefulWidget {
  const UserPresenceStatus({super.key});

  @override
  State<UserPresenceStatus> createState() => _UserPresenceStatusState();
}

class _UserPresenceStatusState extends State<UserPresenceStatus> {
  late final Timer _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPresenceCubit, UserPresenceState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          online: () => Text(
            context.translate(LangKeys.online),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.greenAccent,
                ),
          ),
          offline: (lastSeen) => Text(
            _formatLastSeen(context, lastSeen),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          error: (_) => const SizedBox.shrink(),
        );
      },
    );
  }

  String _formatLastSeen(BuildContext context, DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.isNegative) {
      return '${context.translate(LangKeys.lastSeenAt)} ${context.translate(LangKeys.lastSeenJustNow)}';
    }

    final String timeStr;
    if (diff.inMinutes < 1) {
      timeStr = context.translate(LangKeys.lastSeenJustNow);
    } else if (diff.inHours < 1) {
      timeStr =
          '${diff.inMinutes} ${context.translate(LangKeys.lastSeenMinutesAgo)}';
    } else if (diff.inDays < 1) {
      timeStr = DateFormat.jm().format(lastSeen);
    } else if (diff.inDays == 1) {
      timeStr = context.translate(LangKeys.lastSeenYesterday);
    } else {
      timeStr = DateFormat.yMMMd().format(lastSeen);
    }

    return '${context.translate(LangKeys.lastSeenAt)} $timeStr';
  }
}
