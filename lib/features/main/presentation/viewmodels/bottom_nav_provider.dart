import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class BottomNavNotifier extends StateNotifier<int> {
  BottomNavNotifier() : super(0);

  void changeIndex(int index) {
    state = index;
  }
}

final bottomNavProvider =
StateNotifierProvider<BottomNavNotifier, int>(
      (ref) => BottomNavNotifier(),
);