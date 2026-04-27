import 'package:fitness_pj_3/models/admin_report.dart';
import 'package:fitness_pj_3/models/app_user.dart';
import 'package:fitness_pj_3/models/workout.dart';
import 'package:fitness_pj_3/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<AppUser> users = [];
  Map<String, int> activity = {};
  List<Workout> latestWorkouts = [];
  List<Map<String, dynamic>> workoutTypes = [];
  AdminReport report = const AdminReport(totalUsers: 0, activeUsers: 0, totalWorkouts: 0);

  bool isLoading = false;
  String? error;

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      users = await _service.fetchUsers();
      activity = await _service.userActivity();
      latestWorkouts = await _service.latestWorkouts();
      workoutTypes = await _service.fetchWorkoutTypes();
      report = await _service.buildReport();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    await _service.addUser(username: username, email: email, password: password, role: role);
    await loadAll();
  }

  Future<void> updateUser({
    required int id,
    required String username,
    required String email,
    required String role,
  }) async {
    await _service.updateUser(id: id, username: username, email: email, role: role);
    await loadAll();
  }

  Future<void> deleteUser(int id) async {
    await _service.deleteUser(id);
    await loadAll();
  }

  Future<void> addWorkoutType(String name) async {
    await _service.addWorkoutType(name);
    await loadAll();
  }

  Future<void> updateWorkoutType(int id, String name) async {
    await _service.updateWorkoutType(id, name);
    await loadAll();
  }

  Future<void> deleteWorkoutType(int id) async {
    await _service.deleteWorkoutType(id);
    await loadAll();
  }
}
