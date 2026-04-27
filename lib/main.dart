import 'package:fitness_pj_3/providers/admin_provider.dart';
import 'package:fitness_pj_3/providers/auth_provider.dart';
import 'package:fitness_pj_3/providers/workout_provider.dart';
import 'package:fitness_pj_3/screens/admin/admin_panel_screen.dart';
import 'package:fitness_pj_3/screens/analytics/analytics_screen.dart';
import 'package:fitness_pj_3/screens/auth/login_screen.dart';
import 'package:fitness_pj_3/screens/auth/register_screen.dart';
import 'package:fitness_pj_3/screens/dashboard/dashboard_screen.dart';
import 'package:fitness_pj_3/screens/workouts/history_screen.dart';
import 'package:fitness_pj_3/screens/workouts/workout_form_screen.dart';
import 'package:fitness_pj_3/services/db_init.dart';
import 'package:fitness_pj_3/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();
  await NotificationService.instance.initialize();
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fitness Tracker App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/workout-form': (_) => const WorkoutFormScreen(),
          '/history': (_) => const HistoryScreen(),
          '/analytics': (_) => const AnalyticsScreen(),
          '/admin': (_) => const AdminPanelScreen(),
        },
      ),
    );
  }
}

