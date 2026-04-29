import 'package:fitness_pj_3/models/dashboard_summary.dart';
import 'package:fitness_pj_3/models/workout.dart';
import 'package:fitness_pj_3/services/workout_service.dart';
import 'package:flutter/material.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutService _service = WorkoutService();

  List<Workout> _workouts = [];
  List<String> _workoutTypes = [];
  bool _isLoading = false;
  String? _error;

  List<Workout> get workouts => _workouts;
  List<String> get workoutTypes => _workoutTypes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardSummary get summary => DashboardSummary.fromWorkouts(_workouts);

  Future<void> loadWorkouts({required int userId, required String token}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _workouts = await _service.fetchWorkouts(userId: userId, token: token);
      _error = null;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadWorkoutTypes() async {
    _workoutTypes = await _service.fetchWorkoutTypes();
    notifyListeners();
  }

  Future<bool> addWorkout(Workout workout, String token) async {
  _isLoading = true;
  _error = null;
  notifyListeners();
  try {
    await _service.addWorkout(workout: workout, token: token);

    // 👇 เพิ่มตรงนี้
    await loadWorkouts(userId: workout.userId, token: token);

    return true;
  } catch (e) {
    _error = e.toString().replaceFirst('Exception: ', '');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
  }

  Future<bool> updateWorkout(Workout workout, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.updateWorkout(workout: workout, token: token);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteWorkout(int workoutId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _service.deleteWorkout(workoutId: workoutId, token: token);
      _workouts.removeWhere((w) => w.id == workoutId);
      await loadWorkouts(userId: _workouts.first.userId, token: token);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Set<int> getWorkoutDaysThisWeek() {
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  Set<int> activeDays = {};

  for (var w in _workouts) {
    final date = w.date;

    if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(startOfWeek.add(const Duration(days: 7)))) {
      activeDays.add(date.weekday - 1); // MON = 0
    }
  }

  return activeDays;
}
}

