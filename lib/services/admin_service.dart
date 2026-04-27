import 'package:fitness_pj_3/models/admin_report.dart';
import 'package:fitness_pj_3/models/app_user.dart';
import 'package:fitness_pj_3/models/workout.dart';
import 'package:fitness_pj_3/services/local_db_service.dart';

class AdminService {
  Future<List<AppUser>> fetchUsers() async {
    final db = await LocalDbService.instance.database;
    final rows = await db.query('users', orderBy: 'id DESC');
    return rows.map((e) => AppUser.fromJson(e)).toList();
  }

  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final db = await LocalDbService.instance.database;
    await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  Future<void> updateUser({
    required int id,
    required String username,
    required String email,
    required String role,
  }) async {
    final db = await LocalDbService.instance.database;
    await db.update(
      'users',
      {'username': username, 'email': email, 'role': role},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await LocalDbService.instance.database;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
    await db.delete('workouts', where: 'user_id = ?', whereArgs: [id]);
  }

  Future<AdminReport> buildReport() async {
    final db = await LocalDbService.instance.database;
    final users = await db.query('users');
    final workouts = await db.query('workouts');
    final activeUserIds = workouts.map((e) => e['user_id']).toSet().length;
    return AdminReport(
      totalUsers: users.length,
      activeUsers: activeUserIds,
      totalWorkouts: workouts.length,
    );
  }

  Future<Map<String, int>> userActivity() async {
    final db = await LocalDbService.instance.database;
    final rows = await db.rawQuery(
      '''
      SELECT users.username as username, COUNT(workouts.id) as total
      FROM users
      LEFT JOIN workouts ON workouts.user_id = users.id
      GROUP BY users.id
      ORDER BY total DESC
      ''',
    );
    return {for (final row in rows) row['username'].toString(): (row['total'] as int?) ?? 0};
  }

  Future<List<Workout>> latestWorkouts() async {
    final db = await LocalDbService.instance.database;
    final rows = await db.query('workouts', orderBy: 'date DESC', limit: 20);
    return rows.map((e) => Workout.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchWorkoutTypes() async {
    final db = await LocalDbService.instance.database;
    return db.query('workout_types', orderBy: 'name ASC');
  }

  Future<void> addWorkoutType(String name) async {
    final db = await LocalDbService.instance.database;
    await db.insert('workout_types', {'name': name});
  }

  Future<void> updateWorkoutType(int id, String name) async {
    final db = await LocalDbService.instance.database;
    await db.update('workout_types', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteWorkoutType(int id) async {
    final db = await LocalDbService.instance.database;
    await db.delete('workout_types', where: 'id = ?', whereArgs: [id]);
  }
}
