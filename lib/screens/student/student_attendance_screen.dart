import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/app_badge.dart';

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final attendance = context.watch<AttendanceProvider>();
    final user = auth.user;

    final student = studentProvider.allStudents.firstWhere(
      (s) => s.id == (user?.studentId ?? '') || s.email.toLowerCase() == (user?.email.toLowerCase() ?? ''),
      orElse: () => studentProvider.allStudents.first,
    );

    final records = attendance.getAttendanceForStudent(student.studentId);
    final attPct = attendance.calculatePercentageForStudent(student.studentId);
    final present = attendance.getPresentCount(student.studentId);
    final absent = attendance.getAbsentCount(student.studentId);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Attendance Summary Ring / Metric Banner
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Progress Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: (records.isNotEmpty ? attPct : 85) / 100,
                          strokeWidth: 10,
                          backgroundColor: AppColors.surfaceMuted,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            attPct >= 75 ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                      Text(
                        '${attPct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: attPct >= 75 ? AppColors.success : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attPct >= 75 ? 'Attendance Status: Good Standing' : 'Attendance Status: Below Minimum Threshold',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: attPct >= 75 ? AppColors.success : AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Minimum required attendance criteria is 75% for appearing in end-semester examinations.',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Total Conducted: ${records.length} Classes', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(width: 16),
                            Text('Present: $present', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.success, fontSize: 13)),
                            const SizedBox(width: 16),
                            Text('Absent: $absent', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.error, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Daily Attendance History Table
          const Text('Class Attendance Session History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                    columns: const [
                      DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Subject Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: records.map((rec) {
                      return DataRow(
                        cells: [
                          DataCell(Text(rec.date, style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(Text(rec.subjectName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(AppBadge.status(rec.status)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
