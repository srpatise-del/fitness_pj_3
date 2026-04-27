import 'package:fitness_pj_3/models/workout.dart';
import 'package:flutter/material.dart';

class WorkoutTile extends StatelessWidget {
  final Workout workout;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WorkoutTile({
    super.key,
    required this.workout,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(workout.type),
        subtitle: Text(
          '${workout.duration} นาที | ${workout.frequencyPerWeek} ครั้ง/สัปดาห์ | ${workout.dateText}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

