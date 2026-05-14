// REUSABLE SERVICE: Works in any project as-is.
// REQUIRES: connectivity_plus package in pubspec.yaml
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityController {
  ConnectivityController._();

  static final ConnectivityController instance = ConnectivityController._();

  ValueNotifier<bool> isConnected = ValueNotifier(true);

  Future<void> init() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);
    Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    isConnected.value = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
  }

  bool isInternetConnected(List<ConnectivityResult> results) {
    final connected = results.isNotEmpty &&
        !results.every((r) => r == ConnectivityResult.none);
    isConnected.value = connected;
    return connected;
  }
}
