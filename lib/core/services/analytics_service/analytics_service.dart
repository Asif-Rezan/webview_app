import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  // Singleton pattern
  AnalyticsService._privateConstructor();
  static final AnalyticsService instance = AnalyticsService._privateConstructor();

  // Internal Firebase Analytics instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Navigator observer for automatic screen tracking
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Log a custom event safely with proper types
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters != null
          ? Map<String, Object>.from(parameters)
          : null,
    );
  }

  // Set user ID
  Future<void> setUserId(String id) async {
    await _analytics.setUserId(id: id);
  }

  // Set user property
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}






/// Use------------------------->>>
///
/// await AnalyticsService.instance.logEvent(
//   'login_pressed',
// );
//
// await AnalyticsService.instance.logEvent(
//   'pdf_downloaded',
//   parameters: {'source': 'notification'},
// );
// await AnalyticsService.instance.setUserId('user_123');
//
// await AnalyticsService.instance.setUserProperty(
// 'account_type',
// 'premium',
// );






