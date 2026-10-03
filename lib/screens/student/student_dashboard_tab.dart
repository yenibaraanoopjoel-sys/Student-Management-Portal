import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/marks_provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_badge.dart';

class StudentDashboardTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const StudentDashboardTab({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final attendance = context.watch<AttendanceProvider>();
    final marks = context.watch<MarksProvider>();
    final academic = context.watch<AcademicProvider>();

    final user = auth.user;
    final student = studentProvider.allStudents.firstWhere(
      (s) => s.id == (user?.studentId ?? '') || s.email.toLowerCase() == (user?.email.toLowerCase() ?? ''),
      orElse: () => studentProvider.allStudents.isNotEmpty ? studentProvider.allStudents.first : studentProvider.allStudents.first,
    );

    final attPct = attendance.calculatePercentageForStudent(student.studentId);
    final presentCount = attendance.getPresentCount(student.studentId);
    final gpa = marks.calculateGpa(student.studentId);
    final studentMarks = marks.getMarksForStudent(student.studentId);

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
                colors: [Color(0xFF0F172A), AppColors.primary],
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
                        'Welcome, ${student.fullName}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${student.studentId} • ${student.course} (Semester ${student.semester})',
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'GPA: $gpa / 10.0',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
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
                  title: 'Attendance',
                  value: '${attPct.toStringAsFixed(1)}%',
                  icon: Icons.fact_check_rounded,
                  color: attPct >= 75 ? AppColors.success : AppColors.error,
                  subtitle: '$presentCount Classes Attended',
                  onTap: () => onNavigateToTab(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Cumulative GPA',
                  value: '$gpa',
                  icon: Icons.grade_rounded,
                  color: AppColors.primaryLight,
                  subtitle: 'Overall Academic Score',
                  onTap: () => onNavigateToTab(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Active Subjects',
                  value: '${academic.subjects.length}',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.secondary,
                  subtitle: 'Semester ${student.semester} Catalog',
                  onTap: () => onNavigateToTab(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'Announcements',
                  value: '${academic.announcements.length}',
                  icon: Icons.campaign_rounded,
                  color: AppColors.warning,
                  subtitle: 'New Notices Available',
                  onTap: () => onNavigateToTab(5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Quick Overview Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subjects & Grades Summary
              Expanded(
                flex: 3,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Semester Performance Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () => onNavigateToTab(3),
                              child: const Text('View All Marks'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (studentMarks.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('No results published yet.', style: TextStyle(color: AppColors.textMuted))),
                          )
                        else
                          ...studentMarks.map((m) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.book_outlined, size: 18, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(m.subjectName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                        Text('Score: ${m.totalMarks.toStringAsFixed(0)} / 100', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                      ],
                                    ),
                                  ),
                                  AppBadge.grade(m.grade),
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

              // Recent Announcements
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Campus Notices', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () => onNavigateToTab(5),
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...academic.announcements.take(3).map((ann) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppBadge.priority(ann.priority),
                                    Text(ann.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(ann.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
