import 'package:fitness_pj_3/models/workout.dart';

class DashboardSummary {
  final int totalWorkouts;
  final int totalDuration;
  final Map<String, int> weeklySummary;

  const DashboardSummary({
    required this.totalWorkouts,
    required this.totalDuration,
    required this.weeklySummary,
  });

  factory DashboardSummary.fromWorkouts(List<Workout> workouts) {
    int duration = 0;
    final Map<String, int> weekly = {
      'Mon': 0,
      'Tue': 0,
      'Wed': 0,
      'Thu': 0,
      'Fri': 0,
      'Sat': 0,
      'Sun': 0,
    };

    for (final item in workouts) {
      duration += item.duration;
      final day = _weekday(item.date.weekday);
      weekly[day] = (weekly[day] ?? 0) + 1;
    }

    return DashboardSummary(
      totalWorkouts: workouts.length,
      totalDuration: duration,
      weeklySummary: weekly,
    );
  }

  static String _weekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return 'Sun';
    }
  }
}

