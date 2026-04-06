import 'package:shared_preferences/shared_preferences.dart';

// Utility Class for Shared Preferences (Encapsulate credential logic)
class CredentialStorage {
  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
    await prefs.setString('saved_password', password);
    await prefs.setBool('save_login', true);
  }

  static Future<Map<String, String?>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('saved_email'),
      'password': prefs.getString('saved_password'),
    };
  }

// Add another method to fetch the save_login state
  static Future<bool> loadSaveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('save_login') ?? false;
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    await prefs.remove('saved_password');
    await prefs.setBool('save_login', false);
  }
}
