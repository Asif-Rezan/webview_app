import 'package:shared_preferences/shared_preferences.dart';

class ThemeStorage {
  static const _key = "theme";

  Future<void> saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme);
  }

  Future<String?> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}