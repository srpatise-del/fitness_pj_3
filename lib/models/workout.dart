import 'package:intl/intl.dart';

class Workout {
  final int id;
  final int userId;
  final String type;
  final int duration;
  final int frequencyPerWeek;
  final DateTime date;

  const Workout({
    required this.id,
    required this.userId,
    required this.type,
    required this.duration,
    required this.frequencyPerWeek,
    required this.date,
  });

  String get dateText => DateFormat('dd/MM/yyyy').format(date);

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      userId:
          json['user_id'] is int ? json['user_id'] : int.tryParse('${json['user_id']}') ?? 0,
      type: json['type']?.toString() ?? '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse('${json['duration']}') ?? 0,
      frequencyPerWeek: json['frequency_per_week'] is int
          ? json['frequency_per_week']
          : int.tryParse('${json['frequency_per_week']}') ?? 0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'duration': duration,
      'frequency_per_week': frequencyPerWeek,
      'date': date.toIso8601String(),
    };
  }

  Workout copyWith({
    int? id,
    int? userId,
    String? type,
    int? duration,
    int? frequencyPerWeek,
    DateTime? date,
  }) {
    return Workout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      frequencyPerWeek: frequencyPerWeek ?? this.frequencyPerWeek,
      date: date ?? this.date,
    );
  }
}

