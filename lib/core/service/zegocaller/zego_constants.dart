// REUSABLE SERVICE: ZegoCloud credentials.
// REQUIRES: ZEGO_APP_ID and ZEGO_APP_SIGN in your .env files.
// CHANGE: Get these from https://console.zegocloud.com (your project -> AppID / AppSign).
import 'package:chat_material3/core/service/env/env_variable.dart';

/// Numeric ZegoCloud App ID.
final int zegoAppId = EnvVariable.instance.zegoAppId;

/// 64-char ZegoCloud App Sign (used for AppSign auth — no token server needed).
final String zegoAppSign = EnvVariable.instance.zegoAppSign;
