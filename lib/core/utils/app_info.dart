import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:chat_material3/core/language/app_localizations.dart';

class AppInfo {
  const AppInfo._();

  static Future<String> getAppVersion(BuildContext context) async {
    var buildNumberText = '';

    if (AppLocalizations.of(context)!.isEnLocale) {
      final packgeInfo = await PackageInfo.fromPlatform();
      buildNumberText = '${packgeInfo.version} (${packgeInfo.buildNumber})';
    } else {
      final packgeInfo = await PackageInfo.fromPlatform();
      buildNumberText = '(${packgeInfo.buildNumber}) ${packgeInfo.version}';
    }

    return buildNumberText;
  }
}
