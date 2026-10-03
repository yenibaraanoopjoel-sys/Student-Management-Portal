import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/student_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../providers/academic_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/app_badge.dart';

class AdminDashboardTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const AdminDashboardTab({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().allStudents;
    final faculty = context.watch<FacultyProvider>().allFaculty;
    final academic = context.watch<AcademicProvider>();
    final attendance = context.watch<AttendanceProvider>();

    final avgAttendance = attendance.overallAverageAttendance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner / Welcome
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Welcome to Administrative Control Center',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage students, faculty members, academic programs, and institute analytics seamlessly.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final res = await academic.seedFirestore();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res
                                ? 'Sample data synchronized to Firebase Cloud Firestore successfully!'
                                : 'Demo data active locally. Cloud Firestore ready for live sync.',
                          ),
                          backgroundColor: res ? AppColors.success : AppColors.info,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.cloud_sync_rounded, size: 18),
                  label: const Text('Sync Demo Data'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 4
                  : (constraints.maxWidth > 700 ? 3 : 2);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: constraints.maxWidth > 700 ? 1.5 : 1.25,
                children: [
                  StatCard(
                    title: 'Total Students',
                    value: '${students.length}',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primaryLight,
                    subtitle: '${students.where((s) => s.status == "Active").length} Active Enrolled',
                    onTap: () => onNavigateToTab(1),
                  ),
                  StatCard(
                    title: 'Total Faculty',
                    value: '${faculty.length}',
                    icon: Icons.badge_rounded,
                    color: AppColors.secondary,
                    subtitle: '${faculty.where((f) => f.status == "Active").length} Active Teaching',
                    onTap: () => onNavigateToTab(2),
                  ),
                  StatCard(
                    title: 'Total Courses',
                    value: '${academic.courses.length}',
                    icon: Icons.auto_stories_rounded,
                    color: AppColors.accent,
                    subtitle: '${academic.departments.length} Departments',
                    onTap: () => onNavigateToTab(3),
                  ),
                  StatCard(
                    title: 'Total Subjects',
                    value: '${academic.subjects.length}',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF8B5CF6),
                    subtitle: 'Curriculum Catalog',
                    onTap: () => onNavigateToTab(4),
                  ),
                  StatCard(
                    title: 'Avg. Attendance',
                    value: '${avgAttendance.toStringAsFixed(1)}%',
                    icon: Icons.fact_check_rounded,
                    color: AppColors.success,
                    subtitle: 'Institute Average',
                    onTap: () => onNavigateToTab(6),
                  ),
                  StatCard(
                    title: 'Announcements',
                    value: '${academic.announcements.length}',
                    icon: Icons.campaign_rounded,
                    color: AppColors.warning,
                    subtitle: 'Active Notices',
                    onTap: () => onNavigateToTab(5),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),

          // Charts and Visual Analytics
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 950;
              final chartWidget = _buildAttendanceChart();
              final deptWidget = _buildDepartmentDistribution(academic, students);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: chartWidget),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: deptWidget),
                  ],
                );
              } else {
                return Column(
                  children: [
                    chartWidget,
                    const SizedBox(height: 20),
                    deptWidget,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 28),

          // Recent Students & Recent Announcements Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 950;
              final recentStudentsWidget = _buildRecentStudentsList(context, students);
              final recentAnnouncementsWidget = _buildRecentAnnouncements(academic);

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: recentStudentsWidget),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: recentAnnouncementsWidget),
                  ],
                );
              } else {
                return Column(
                  children: [
                    recentStudentsWidget,
                    const SizedBox(height: 20),
                    recentAnnouncementsWidget,
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Attendance Trends',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '+3.4% vs last week',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
                          if (val.toInt() < 0 || val.toInt() >= days.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(days[val.toInt()], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 25,
                        getTitlesWidget: (val, meta) {
                          return Text('${val.toInt()}%', style: const TextStyle(fontSize: 11, color: AppColors.textMuted));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (val) => const FlLine(color: AppColors.border, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _buildBarGroup(0, 88),
                    _buildBarGroup(1, 92),
                    _buildBarGroup(2, 85),
                    _buildBarGroup(3, 90),
                    _buildBarGroup(4, 87),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: AppColors.primary,
          width: 22,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(6),
            topRight: Radius.circular(6),
          ),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: AppColors.surfaceMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDistribution(AcademicProvider academic, List students) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Departments & Programs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...academic.departments.map((dept) {
              final studentCount = students.where((s) => s.department == dept.departmentName).length;
              final percent = students.isNotEmpty ? (studentCount / students.length) : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dept.departmentCode,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '$studentCount Students (${(percent * 100).toInt()}%)',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: percent > 0 ? percent : 0.1,
                        backgroundColor: AppColors.surfaceMuted,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentStudentsList(BuildContext context, List students) {
    final recent = students.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recently Enrolled Students',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, idx) {
                final s = recent[idx];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                    child: Text(
                      s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : 'S',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  title: Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('${s.studentId} • ${s.course}', style: const TextStyle(fontSize: 12)),
                  trailing: AppBadge.status(s.status),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAnnouncements(AcademicProvider academic) {
    final recent = academic.announcements.take(4).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Announcements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => onNavigateToTab(5),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recent.map((ann) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppBadge.priority(ann.priority),
                        Text(
                          ann.date,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ann.title,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ann.description,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
