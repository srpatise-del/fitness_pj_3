import 'dart:convert';

import 'package:fitness_pj_3/models/app_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionStorageService {
  static const String _keyUser = 'session_user';
  static const String _keyToken = 'session_token';

  Future<void> saveSession(AppUser user) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(_keyUser, jsonEncode(user.toJson()));
    await pref.setString(_keyToken, user.token ?? '');
  }

  Future<AppUser?> getUser() async {
    final pref = await SharedPreferences.getInstance();
    final raw = pref.getString(_keyUser);
    if (raw == null || raw.isEmpty) return null;
    return AppUser.fromJson(jsonDecode(raw));
  }

  Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString(_keyToken);
  }

  Future<void> clearSession() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(_keyUser);
    await pref.remove(_keyToken);
  }
}

