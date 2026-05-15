import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'connection_status.dart';

final internetProvider = StateNotifierProvider<InternetNotifier, ConnectionStatus>(
      (ref) => InternetNotifier(),
);

class InternetNotifier extends StateNotifier<ConnectionStatus> with WidgetsBindingObserver {
  InternetNotifier() : super(ConnectionStatus.connected) {
    _init();
  }

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicTimer;

  Future<void> _init() async {
    WidgetsBinding.instance.addObserver(this);

    await checkNow();

    _subscription = Connectivity().onConnectivityChanged.listen(
          (results) {
        print('Connectivity stream: $results');
        _updateFromConnectivity(results);
      },
    );

    _periodicTimer = Timer.periodic(
      const Duration(seconds: 8),
          (_) {
        if (state == ConnectionStatus.connected) {
          print('Periodic probe');
          _probeInternet().then((has) {
            if (!has) {
              print('Periodic → offline');
              state = ConnectionStatus.disconnected;
            }
          });
        }
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('Resumed → checkNow');
      checkNow();
    }
  }

  Future<void> checkNow() async {
    try {
      final results = await Connectivity().checkConnectivity();
      print('checkNow success: $results');
      await _updateFromConnectivity(results);
    } catch (e) {
      print('checkNow failed: $e - falling back to probe');
      // Fallback probe when plugin throws (common after hot-restart)
      final hasInternet = await _probeInternet();
      state = hasInternet ? ConnectionStatus.connected : ConnectionStatus.disconnected;
    }
  }

  Future<void> _updateFromConnectivity(List<ConnectivityResult> results) async {
    final hasNoInterface = results.contains(ConnectivityResult.none) ||
        results.every((r) => r == ConnectivityResult.none);

    if (hasNoInterface) {
      print('No interface → disconnected');
      state = ConnectionStatus.disconnected;
      return;
    }

    final hasInternet = await _probeInternet();
    print('Probe result: $hasInternet');
    state = hasInternet ? ConnectionStatus.connected : ConnectionStatus.disconnected;
  }

  Future<bool> _probeInternet() async {
    // DNS first
    try {
      final dns = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 4));
      if (dns.isNotEmpty && dns.any((e) => e.rawAddress.isNotEmpty)) {
        print('DNS OK');
        return true;
      }
    } catch (e) {
      print('DNS fail: $e');
    }

    // HTTP fallback
    try {
      final client = HttpClient();
      final req = await client
          .getUrl(Uri.parse('http://connectivitycheck.gstatic.com/generate_204'))
          .timeout(const Duration(seconds: 6));
      final res = await req.close();
      print('HTTP code: ${res.statusCode}');
      return res.statusCode == 204;
    } catch (e) {
      print('HTTP fail: $e');
      return false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    _periodicTimer?.cancel();
    super.dispose();
  }
}