import 'package:flutter/material.dart';

class WeeklyStreakCard extends StatelessWidget {
  final Set<int> activeDays;

  const WeeklyStreakCard({super.key, required this.activeDays});

  @override
  Widget build(BuildContext context) {
    final days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ความคืบหน้ารายสัปดาห์',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'ออกกำลังกายต่อเนื่องทุกวัน 🔥',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isActive = activeDays.contains(index);

                return Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.orange : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: isActive
                          ? const Icon(Icons.local_fire_department,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(days[index], style: const TextStyle(fontSize: 10)),
                  ],
                );
              }),
            ),

            const SizedBox(height: 16),
            Text(
              'คุณออกกำลังกายไปแล้ว ${activeDays.length} วันในสัปดาห์นี้',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}