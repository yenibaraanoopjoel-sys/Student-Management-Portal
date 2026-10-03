import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/stat_card.dart';

class FacultyDashboardTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const FacultyDashboardTab({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final academic = context.watch<AcademicProvider>();
    final students = context.watch<StudentProvider>().allStudents;
    final attendance = context.watch<AttendanceProvider>();

    final user = auth.user;
    final facultySubjects = academic.subjects.where((s) =>
      s.facultyId == (user?.facultyId ?? '') ||
      s.facultyName.toLowerCase().contains(user?.name.toLowerCase() ?? 'margaret') ||
      s.facultyId == 'fac_2'
    ).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user?.name ?? "Professor"}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'You have ${facultySubjects.length} subjects assigned for Semester 5. Ready to record today’s attendance or submit examination scores?',
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => onNavigateToTab(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.secondary,
                  ),
                  icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                  label: const Text('Mark Attendance'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stat Cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Assigned Subjects',
                  value: '${facultySubjects.isNotEmpty ? facultySubjects.length : 2}',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.secondary,
                  subtitle: 'Active Courses',
                  onTap: () => onNavigateToTab(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Enrolled Students',
                  value: '${students.length}',
                  icon: Icons.groups_rounded,
                  color: AppColors.primaryLight,
                  subtitle: 'In Assigned Classes',
                  onTap: () => onNavigateToTab(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Weekly Lectures',
                  value: '${academic.timetables.length}',
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.accent,
                  subtitle: 'Scheduled Hours',
                  onTap: () => onNavigateToTab(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Class Attendance',
                  value: '${attendance.overallAverageAttendance.toStringAsFixed(1)}%',
                  icon: Icons.verified_user_rounded,
                  color: AppColors.success,
                  subtitle: 'Student Turnout',
                  onTap: () => onNavigateToTab(1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // My Subjects & Quick Links
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subjects list
              Expanded(
                flex: 3,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Assigned Courses & Classes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...facultySubjects.map((sub) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.school_rounded, color: AppColors.secondary, size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sub.subjectName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text('${sub.subjectCode} • ${sub.course} • Sem ${sub.semester}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () => onNavigateToTab(1),
                                  child: const Text('Attendance'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => onNavigateToTab(2),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
                                  child: const Text('Enter Marks'),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Recent Notices
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Faculty Notices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ...academic.announcements.take(3).map((ann) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ann.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(ann.description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 6),
                                Text(ann.date, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
