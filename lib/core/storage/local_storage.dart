import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString('token', token);
  }

  static String? getToken() {
    return _prefs.getString('token');
  }

  static Future<void> saveRefreshToken(String token) async {
    await _prefs.setString('refresh_token', token);
  }

  static String? getRefreshToken() {
    return _prefs.getString('refresh_token');
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }
}
