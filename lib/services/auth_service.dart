import 'package:fitness_pj_3/models/app_user.dart';
import 'package:fitness_pj_3/services/api_service.dart';
import 'package:fitness_pj_3/services/local_db_service.dart';
import 'package:fitness_pj_3/services/session_storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final SessionStorageService _storage = SessionStorageService();

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        'login.php',
        body: {'email': email, 'password': password},
      );
      final user = AppUser.fromJson({
        ...response['user'] as Map<String, dynamic>,
        'token': response['token'] ?? '',
      });
      await _storage.saveSession(user);
      return user;
    } catch (_) {
      return _loginLocal(email: email, password: password);
    }
  }

  Future<AppUser> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.post(
        'register.php',
        body: {'username': username, 'email': email, 'password': password},
      );
      final user = AppUser.fromJson({
        ...response['user'] as Map<String, dynamic>,
        'token': response['token'] ?? '',
      });
      await _storage.saveSession(user);
      return user;
    } catch (_) {
      return _registerLocal(username: username, email: email, password: password);
    }
  }

  Future<void> logout() async {
    await _storage.clearSession();
  }

  Future<AppUser?> restoreSession() => _storage.getUser();

  Future<AppUser> _loginLocal({
    required String email,
    required String password,
  }) async {
    final db = await LocalDbService.instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );
    if (result.isEmpty) {
      throw Exception('อีเมลหรือรหัสผ่านไม่ถูกต้อง');
    }
    final user = AppUser.fromJson({
      ...result.first,
      'token': 'local-token-${result.first['id']}',
    });
    await _storage.saveSession(user);
    return user;
  }

  Future<AppUser> _registerLocal({
    required String username,
    required String email,
    required String password,
  }) async {
    final db = await LocalDbService.instance.database;
    final existed = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    if (existed.isNotEmpty) {
      throw Exception('อีเมลนี้ถูกใช้งานแล้ว');
    }

    final id = await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'role': email.contains('admin') ? 'admin' : 'user',
    });
    final user = AppUser(
      id: id,
      username: username,
      email: email,
      role: email.contains('admin') ? 'admin' : 'user',
      token: 'local-token-$id',
    );
    await _storage.saveSession(user);
    return user;
  }
}
