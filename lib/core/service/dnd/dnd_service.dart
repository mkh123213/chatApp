import 'package:flutter/foundation.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';

class DndService {
  factory DndService() => _instance;
  DndService._();
  static final DndService _instance = DndService._();

  final ValueNotifier<bool> isEnabled = ValueNotifier(false);

  void init() {
    isEnabled.value = SharedPref().getBoolean(PrefKeys.doNotDisturb) ?? false;
  }

  Future<void> toggle() async {
    isEnabled.value = !isEnabled.value;
    await SharedPref().setBoolean(PrefKeys.doNotDisturb, isEnabled.value);
  }

  Future<void> setEnabled(bool value) async {
    isEnabled.value = value;
    await SharedPref().setBoolean(PrefKeys.doNotDisturb, value);
  }
}
