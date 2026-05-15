import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/services/local_storage_service/theme_storage.dart';
/// Theme Mode Provider - Reactive theme selection
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Notification Enabled Provider - Tracks user's preference (ON/OFF)
final notificationEnabledProvider = StateProvider<bool>((ref) => false);

/// Loads persisted theme on app startup
final themeLoaderProvider = FutureProvider<void>((ref) async {
  final storage = ThemeStorage();
  final savedTheme = await storage.getTheme();

  final ThemeMode mode = switch (savedTheme) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  ref.read(themeModeProvider.notifier).state = mode;
});
