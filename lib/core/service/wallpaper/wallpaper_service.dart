import 'package:flutter/material.dart';
import 'package:chat_material3/core/service/shared_pref/pref_keys.dart';
import 'package:chat_material3/core/service/shared_pref/shared_pref.dart';

class WallpaperOption {
  const WallpaperOption({
    required this.name,
    required this.colors,
  });

  final String name;
  final List<Color> colors;

  bool get isGradient => colors.length > 1;
}

class WallpaperService {
  factory WallpaperService() => _instance;
  WallpaperService._();
  static final WallpaperService _instance = WallpaperService._();

  final ValueNotifier<int> selectedIndex = ValueNotifier(0);

  static const List<WallpaperOption> options = [
    WallpaperOption(name: 'Default', colors: [Color(0xFFF5F5F5)]),
    WallpaperOption(name: 'Dark', colors: [Color(0xFF1A1A2E)]),
    WallpaperOption(name: 'Ocean', colors: [Color(0xFF0F3460), Color(0xFF16213E)]),
    WallpaperOption(name: 'Sunset', colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)]),
    WallpaperOption(name: 'Forest', colors: [Color(0xFF11998E), Color(0xFF38EF7D)]),
    WallpaperOption(name: 'Lavender', colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
    WallpaperOption(name: 'Mint', colors: [Color(0xFFE0F7FA), Color(0xFFB2DFDB)]),
    WallpaperOption(name: 'Peach', colors: [Color(0xFFFFE0B2), Color(0xFFFFCCBC)]),
    WallpaperOption(name: 'Slate', colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)]),
  ];

  void init() {
    final saved = SharedPref().getString(PrefKeys.chatWallpaper);
    if (saved != null) {
      final idx = int.tryParse(saved) ?? 0;
      selectedIndex.value = idx.clamp(0, options.length - 1);
    }
  }

  Future<void> select(int index) async {
    selectedIndex.value = index.clamp(0, options.length - 1);
    await SharedPref().setString(PrefKeys.chatWallpaper, index.toString());
  }

  WallpaperOption get current => options[selectedIndex.value];

  BoxDecoration get decoration {
    final opt = current;
    if (opt.isGradient) {
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: opt.colors,
        ),
      );
    }
    return BoxDecoration(color: opt.colors.first);
  }
}
