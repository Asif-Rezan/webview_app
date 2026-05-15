import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../home/presentation/view/screen/home_screen.dart';
import '../../viewmodels/bottom_nav_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);

    final screens = [
      const HomeScreen(),
      const HomeScreen(),
      const HomeScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}