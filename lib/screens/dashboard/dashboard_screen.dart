import 'package:fitness_pj_3/providers/auth_provider.dart';
import 'package:fitness_pj_3/providers/workout_provider.dart';
import 'package:fitness_pj_3/services/notification_service.dart';
import 'package:fitness_pj_3/widgets/app_drawer.dart';
import 'package:fitness_pj_3/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fitness_pj_3/widgets/weekly_streak_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final user = auth.user;
      if (user != null) {
        context.read<WorkoutProvider>().loadWorkouts(
              userId: user.id,
              token: user.token ?? '',
            );
        context.read<WorkoutProvider>().loadWorkoutTypes();
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final summary = workoutProvider.summary;
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'แนะนำก่อนออกกำลังกาย',
            onPressed: () => NotificationService.instance.showPreWorkoutTip(),
            icon: const Icon(Icons.notifications_active),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/workout-form'),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่ม Workout'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (user != null) {
            await workoutProvider.loadWorkouts(
                userId: user.id, token: user.token ?? '');
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'สวัสดี คุณ ${user?.username ?? ''}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SummaryCard(
              title: 'Total Workouts',
              value: '${summary.totalWorkouts} ครั้ง',
              icon: Icons.fitness_center,
              color: Colors.blue,
            ),
            SummaryCard(
              title: 'Total Duration',
              value: '${summary.totalDuration} นาที',
              icon: Icons.timer,
              color: Colors.orange,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weekly Summary',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    ...summary.weeklySummary.entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('${e.key}: ${e.value} ครั้ง'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            workoutProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : WeeklyStreakCard(
                activeDays: workoutProvider.getWorkoutDaysThisWeek(),
      ),
            if (workoutProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  workoutProvider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
