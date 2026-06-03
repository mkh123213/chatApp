import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityController {
  /// Private constructor
  ConnectivityController._();

  /// Static instance
  static final ConnectivityController instance = ConnectivityController._();

  /// Notifier for connection status
  ValueNotifier<bool> isConnected = ValueNotifier(true);

  /// Initialize connectivity monitoring
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
