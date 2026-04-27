import 'package:fitness_pj_3/providers/auth_provider.dart';
import 'package:fitness_pj_3/providers/workout_provider.dart';
import 'package:fitness_pj_3/widgets/app_drawer.dart';
import 'package:fitness_pj_3/widgets/workout_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;
    await context.read<WorkoutProvider>().loadWorkouts(
          userId: user.id,
          token: user.token ?? '',
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkoutProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: provider.workouts.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('ยังไม่มีข้อมูลการออกกำลังกาย')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: provider.workouts.length,
                itemBuilder: (context, index) {
                  final workout = provider.workouts[index];
                  return WorkoutTile(
                    workout: workout,
                    onEdit: () => Navigator.pushNamed(
                      context,
                      '/workout-form',
                      arguments: workout,
                    ),
                    onDelete: () async {
                      final ok = await provider.deleteWorkout(workout.id, user?.token ?? '');
                      if (ok && context.mounted && user != null) {
                        await provider.loadWorkouts(userId: user.id, token: user.token ?? '');
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

