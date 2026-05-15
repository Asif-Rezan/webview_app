import 'package:shared_preferences/shared_preferences.dart';

class RememberMeStorage {
  static const _key = "rememberMe";

  // Save the user's choice as boolean
  Future<void> saveRememberMeData(bool userChoice) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, userChoice);
  }

  // Get the saved value, default to false if not set
  Future<bool> getRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  // Clear the saved value
  Future<void> clearRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}