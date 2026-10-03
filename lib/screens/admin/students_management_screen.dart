import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import 'student_form_dialog.dart';
import 'student_detail_screen.dart';

class StudentsManagementScreen extends StatelessWidget {
  const StudentsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final academic = context.watch<AcademicProvider>();
    final students = studentProvider.filteredStudents;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Controls: Search & Filters & Add Student
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Search Box
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: studentProvider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search by name, student ID, email, or department...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: studentProvider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => studentProvider.setSearchQuery(''),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Department Filter
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: studentProvider.selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(value: 'All', child: Text('All Departments')),
                        ...academic.departments.map((d) => DropdownMenuItem(value: d.departmentName, child: Text(d.departmentCode))),
                      ],
                      onChanged: (v) => studentProvider.setDepartmentFilter(v ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Status Filter
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: studentProvider.selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All Statuses')),
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                        DropdownMenuItem(value: 'Graduated', child: Text('Graduated')),
                      ],
                      onChanged: (v) => studentProvider.setStatusFilter(v ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Add Student Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final newStudent = await StudentFormDialog.show(context);
                      if (newStudent != null && context.mounted) {
                        await studentProvider.addStudent(newStudent);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Student ${newStudent.fullName} added successfully!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: const Text('Add Student'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Students Table / List
          Expanded(
            child: students.isEmpty
                ? EmptyStateView(
                    icon: Icons.person_off_rounded,
                    title: 'No Students Found',
                    description: 'No students match your active search and filter criteria.',
                    actionText: 'Register New Student',
                    onAction: () async {
                      final newStudent = await StudentFormDialog.show(context);
                      if (newStudent != null && context.mounted) {
                        await studentProvider.addStudent(newStudent);
                      }
                    },
                  )
                : Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 24,
                          horizontalMargin: 20,
                          headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                          columns: const [
                            DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Course & Dept', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Year / Sem', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: students.map((s) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                                        child: Text(
                                          s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : 'S',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(s.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text(s.email, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(s.studentId, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(s.course, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      Text(s.department, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                DataCell(Text('${s.year} • Sem ${s.semester}', style: const TextStyle(fontSize: 12))),
                                DataCell(AppBadge.status(s.status)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility_outlined, size: 18, color: AppColors.primary),
                                        tooltip: 'View Profile',
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => StudentDetailScreen(student: s),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.secondary),
                                        tooltip: 'Edit Student',
                                        onPressed: () async {
                                          final updated = await StudentFormDialog.show(context, student: s);
                                          if (updated != null && context.mounted) {
                                            await studentProvider.updateStudent(updated);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                        tooltip: 'Delete Student',
                                        onPressed: () async {
                                          final confirmed = await ConfirmDialog.show(
                                            context,
                                            title: 'Delete Student',
                                            message: 'Are you sure you want to delete student ${s.fullName} (${s.studentId})? This action cannot be undone.',
                                          );
                                          if (confirmed == true && context.mounted) {
                                            await studentProvider.deleteStudent(s.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Student ${s.fullName} deleted'),
                                                backgroundColor: AppColors.error,
                                                behavior: SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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
