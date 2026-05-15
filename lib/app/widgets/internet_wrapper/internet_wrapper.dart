import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connection_status.dart';
import '../../../core/network/internet_provider.dart';
import '../no_internet/premium_no_internet_screen.dart';

class InternetWrapper extends ConsumerWidget {
  final Widget child;

  const InternetWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ConnectionStatus>(internetProvider, (previous, next) {
      if (previous == next) return;

      final isConnected = next == ConnectionStatus.connected;

      print('Internet status changed → $next'); // debug

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       isConnected ? 'Internet Connected' : 'Internet Disconnected',
      //     ),
      //     backgroundColor: isConnected ? Colors.green : Colors.red,
      //     behavior: SnackBarBehavior.floating,
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //     duration: const Duration(seconds: 3),
      //   ),
      // );

    });

    final status = ref.watch(internetProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          ignoring: status == ConnectionStatus.disconnected,
          child: child,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: status == ConnectionStatus.disconnected
              ? const PremiumNoInternetScreen(key: ValueKey('no-internet'))
              : const SizedBox.shrink(key: ValueKey('online')),
        ),
      ],
    );
  }
}