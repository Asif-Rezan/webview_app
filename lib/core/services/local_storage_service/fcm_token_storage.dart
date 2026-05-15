import 'package:shared_preferences/shared_preferences.dart';

class FCMTokenStorage {
  static const _key = "fcm_token";

  Future<void> saveFcmToken(String fcmToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, fcmToken);
  }

  Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clearFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}