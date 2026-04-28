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
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fitness_pj_3/services/notification_service.dart';
import 'package:fitness_pj_3/services/db_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ใช้ helper service ในการจัดการ database factory ตาม platform
  initializeDatabaseFactory();

  print("🔥 DB INIT DONE"); // debug

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
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3), // Blue theme
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Color(0xFF2196F3),
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
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
