import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/marks_provider.dart';
import '../../widgets/app_badge.dart';

class StudentMarksScreen extends StatelessWidget {
  const StudentMarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final marksProvider = context.watch<MarksProvider>();
    final user = auth.user;

    final student = studentProvider.allStudents.firstWhere(
      (s) => s.id == (user?.studentId ?? '') || s.email.toLowerCase() == (user?.email.toLowerCase() ?? ''),
      orElse: () => studentProvider.allStudents.first,
    );

    final marksList = marksProvider.getMarksForStudent(student.studentId);
    final gpa = marksProvider.calculateGpa(student.studentId);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GPA Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Semester Academic Transcript', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                          'Enrolled in ${student.course} • Semester ${student.semester}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Cumulative GPA: $gpa',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Examination Results Table
          const Text('Course Evaluation & Examination Scores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      DataColumn(label: Text('Subject Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Internal (20)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Assignment (10)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Final Exam (70)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Total (100)', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Final Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: marksList.map((m) {
                      return DataRow(
                        cells: [
                          DataCell(Text(m.subjectName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(m.internalMarks.toStringAsFixed(1))),
                          DataCell(Text(m.assignmentMarks.toStringAsFixed(1))),
                          DataCell(Text(m.examMarks.toStringAsFixed(1))),
                          DataCell(Text(m.totalMarks.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(AppBadge.grade(m.grade)),
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
