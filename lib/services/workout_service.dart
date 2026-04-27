import 'package:fitness_pj_3/models/workout.dart';
import 'package:fitness_pj_3/services/api_service.dart';
import 'package:fitness_pj_3/services/local_db_service.dart';
import 'package:flutter/foundation.dart';

class WorkoutService {
  final ApiService _api = ApiService();

  Future<List<Workout>> fetchWorkouts({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await _api.get('get_workouts.php?user_id=$userId', token: token);
      final list = (response['data'] as List<dynamic>? ?? [])
          .map((e) => Workout.fromJson(e as Map<String, dynamic>))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (_) {
      return _fetchLocal(userId);
    }
  }

  Future<void> addWorkout({
    required Workout workout,
    required String token,
  }) async {
    try {
      await _api.post(
        'add_workout.php',
        token: token,
        body: {
          'user_id': workout.userId,
          'type': workout.type,
          'duration': workout.duration,
          'frequency_per_week': workout.frequencyPerWeek,
          'date': workout.date.toIso8601String(),
        },
      );
    } catch (_) {
      await _addLocal(workout);
    }
  }

  Future<void> updateWorkout({
    required Workout workout,
    required String token,
  }) async {
    try {
      await _api.post(
        'update_workout.php?id=${workout.id}',
        token: token,
        body: {
          'type': workout.type,
          'duration': workout.duration,
          'frequency_per_week': workout.frequencyPerWeek,
          'date': workout.date.toIso8601String(),
        },
      );
    } catch (_) {
      await _updateLocal(workout);
    }
  }

  Future<void> deleteWorkout({
    required int workoutId,
    required String token,
  }) async {
    try {
      await _api.get('delete_workout.php?id=$workoutId', token: token);
    } catch (_) {
      await _deleteLocal(workoutId);
    }
  }

  Future<List<String>> fetchWorkoutTypes() async {
    if (kIsWeb) {
      return ['Running', 'Weight Training', 'Yoga'];
    }
    final db = await LocalDbService.instance.database;
    final rows = await db.query('workout_types', orderBy: 'name ASC');
    return rows.map((e) => e['name'].toString()).toList();
  }

  Future<void> addWorkoutType(String name) async {
    if (kIsWeb) return;
    final db = await LocalDbService.instance.database;
    await db.insert('workout_types', {'name': name});
  }

  Future<void> updateWorkoutType(int id, String name) async {
    if (kIsWeb) return;
    final db = await LocalDbService.instance.database;
    await db.update('workout_types', {'name': name}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteWorkoutType(int id) async {
    if (kIsWeb) return;
    final db = await LocalDbService.instance.database;
    await db.delete('workout_types', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Workout>> _fetchLocal(int userId) async {
    final db = await LocalDbService.instance.database;
    final rows = await db.query('workouts', where: 'user_id = ?', whereArgs: [userId], orderBy: 'date DESC');
    return rows.map((e) => Workout.fromJson(e)).toList();
  }

  Future<void> _addLocal(Workout workout) async {
    final db = await LocalDbService.instance.database;
    await db.insert('workouts', {
      'user_id': workout.userId,
      'type': workout.type,
      'duration': workout.duration,
      'frequency_per_week': workout.frequencyPerWeek,
      'date': workout.date.toIso8601String(),
    });
  }

  Future<void> _updateLocal(Workout workout) async {
    final db = await LocalDbService.instance.database;
    await db.update(
      'workouts',
      {
        'type': workout.type,
        'duration': workout.duration,
        'frequency_per_week': workout.frequencyPerWeek,
        'date': workout.date.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [workout.id],
    );
  }

  Future<void> _deleteLocal(int workoutId) async {
    final db = await LocalDbService.instance.database;
    await db.delete('workouts', where: 'id = ?', whereArgs: [workoutId]);
  }
}
