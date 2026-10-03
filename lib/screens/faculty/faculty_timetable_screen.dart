import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/academic_provider.dart';

class FacultyTimetableScreen extends StatelessWidget {
  const FacultyTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timetables = context.watch<AcademicProvider>().timetables;

    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Teaching Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: days.length,
              itemBuilder: (context, idx) {
                final day = days[idx];
                final daySlots = timetables.where((t) => t.day == day).toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                day.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.secondary),
                              ),
                            ),
                            const Spacer(),
                            Text('${daySlots.length} Lectures', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (daySlots.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('No lectures scheduled for this day.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          )
                        else
                          ...daySlots.map((slot) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.secondary),
                                  const SizedBox(width: 8),
                                  Text(slot.timeSlot, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Text(
                                      '${slot.subjectName} • ${slot.room}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  Text('Section ${slot.section}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
