import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class HomeState {
  final bool isLoading;

  const HomeState({this.isLoading = false});

  HomeState copyWith({bool? isLoading}) {
    return HomeState(isLoading: isLoading ?? this.isLoading);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  /// No-op stub kept for backward compatibility with any
  /// call-sites that still invoke [loadAllData] (e.g. RefreshIndicator).
  Future<void> loadAllData() async {
    if (kDebugMode) {
      debugPrint(
        '[HomeNotifier] loadAllData() called — '
            'screen is in WebView mode, nothing to fetch.',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>(
      (_) => HomeNotifier(),
);