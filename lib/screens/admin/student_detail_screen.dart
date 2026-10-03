import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/marks_provider.dart';
import '../../widgets/app_badge.dart';
import 'student_form_dialog.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentModel student;

  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final attendance = context.watch<AttendanceProvider>();
    final marks = context.watch<MarksProvider>();

    final attPct = attendance.calculatePercentageForStudent(student.studentId);
    final presentCount = attendance.getPresentCount(student.studentId);
    final absentCount = attendance.getAbsentCount(student.studentId);

    final studentMarks = marks.getMarksForStudent(student.studentId);
    final gpa = marks.calculateGpa(student.studentId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${student.fullName} - Student Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () async {
              final updated = await StudentFormDialog.show(context, student: student);
              if (updated != null && context.mounted) {
                await context.read<StudentProvider>().updateStudent(updated);
                Navigator.of(context).pop();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                      child: Text(
                        student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : 'S',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                student.fullName,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              AppBadge.status(student.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${student.studentId} • ${student.course} • Section ${student.section}',
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.email_outlined, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(student.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(width: 16),
                              const Icon(Icons.phone_outlined, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(student.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
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

            // Performance & Academic Cards Row
            Row(
              children: [
                // Attendance Card
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Attendance Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: attPct >= 75 ? AppColors.successBg : AppColors.errorBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${attPct.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: attPct >= 75 ? AppColors.success : AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: attPct / 100,
                            minHeight: 10,
                            backgroundColor: AppColors.surfaceMuted,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              attPct >= 75 ? AppColors.success : AppColors.error,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Present: $presentCount classes', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              Text('Absent: $absentCount classes', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Cumulative GPA Card
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Academic Standing', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'GPA: $gpa / 10.0',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Year: ${student.year} • Semester: ${student.semester}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Department: ${student.department}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Admission Date: ${student.admissionDate}',
                            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Academic Marks Table
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Subject Marks & Grades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    if (studentMarks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('No examination marks recorded yet for this student.', style: TextStyle(color: AppColors.textMuted)),
                        ),
                      )
                    else
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Internal (20)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Assignment (10)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Exam (70)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Total (100)', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: studentMarks.map((m) {
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Guardian Details & Residence
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Parent & Guardian Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Parent / Guardian Name', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            subtitle: Text(student.parentName.isNotEmpty ? student.parentName : 'Not Specified', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Contact Number', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            subtitle: Text(student.parentContact.isNotEmpty ? student.parentContact : 'Not Specified', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Residential Address', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            subtitle: Text(student.address.isNotEmpty ? student.address : 'Not Specified', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
