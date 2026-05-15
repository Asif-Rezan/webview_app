import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/bottom_nav_provider.dart';

class CustomBottomNavBar extends ConsumerWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 25,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(
              icon: Icons.home_rounded,
              index: 0,
              currentIndex: currentIndex,
              ref: ref,
            ),
            _navItem(
              icon: Icons.search_rounded,
              index: 1,
              currentIndex: currentIndex,
              ref: ref,
            ),
            _navItem(
              icon: Icons.person_rounded,
              index: 2,
              currentIndex: currentIndex,
              ref: ref,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required int index,
    required int currentIndex,
    required WidgetRef ref,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        ref.read(bottomNavProvider.notifier).changeIndex(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}