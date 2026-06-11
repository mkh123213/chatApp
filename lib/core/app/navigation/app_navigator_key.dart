import 'package:flutter/material.dart';

/// Single global navigator key shared by [MaterialApp] and ZegoUIKit's
/// call-invitation service.
///
/// ZegoUIKitPrebuiltCallInvitationService needs the SAME navigator key that
/// MaterialApp uses, otherwise the prebuilt call screen cannot be pushed when
/// a call is accepted (especially from an offline/background invitation).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
