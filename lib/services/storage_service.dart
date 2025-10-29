import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _usersKey = 'via_users';
  static const String _contractsKey = 'via_contracts';
  static const String _tasksKey = 'via_tasks';
  static const String _notificationsKey = 'via_notifications';
  static const String _currentUserKey = 'via_current_user';

  Future<void> saveData(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<List<Map<String, dynamic>>> loadData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(jsonString));
  }

  Future<void> saveCurrentUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, userId);
  }

  Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }

  Future<void> clearCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  String get usersKey => _usersKey;
  String get contractsKey => _contractsKey;
  String get tasksKey => _tasksKey;
  String get notificationsKey => _notificationsKey;
}
