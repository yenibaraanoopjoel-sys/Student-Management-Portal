import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/faculty_provider.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import 'faculty_form_dialog.dart';

class FacultyManagementScreen extends StatelessWidget {
  const FacultyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final facultyProvider = context.watch<FacultyProvider>();
    final academic = context.watch<AcademicProvider>();
    final facultyList = facultyProvider.filteredFaculty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter & Search Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      onChanged: facultyProvider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search by faculty name, ID, email, or department...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: facultyProvider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => facultyProvider.setSearchQuery(''),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: facultyProvider.selectedDepartment,
                      decoration: const InputDecoration(
                        labelText: 'Department',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      items: [
                        const DropdownMenuItem(value: 'All', child: Text('All Departments')),
                        ...academic.departments.map((d) => DropdownMenuItem(value: d.departmentName, child: Text(d.departmentCode))),
                      ],
                      onChanged: (v) => facultyProvider.setDepartmentFilter(v ?? 'All'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final newFac = await FacultyFormDialog.show(context);
                      if (newFac != null && context.mounted) {
                        await facultyProvider.addFaculty(newFac);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Faculty member ${newFac.fullName} added successfully!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.person_add_alt_rounded, size: 18),
                    label: const Text('Add Faculty'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Faculty List
          Expanded(
            child: facultyList.isEmpty
                ? EmptyStateView(
                    icon: Icons.person_search_rounded,
                    title: 'No Faculty Found',
                    description: 'No faculty members match your criteria.',
                    actionText: 'Add Faculty Member',
                    onAction: () async {
                      final newFac = await FacultyFormDialog.show(context);
                      if (newFac != null && context.mounted) {
                        await facultyProvider.addFaculty(newFac);
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
                            DataColumn(label: Text('Faculty Member', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Faculty ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Department & Role', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Assigned Subjects', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: facultyList.map((f) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: AppColors.secondary.withOpacity(0.15),
                                        child: Text(
                                          f.fullName.isNotEmpty ? f.fullName[0].toUpperCase() : 'F',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(f.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text(f.email, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(Text(f.facultyId, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(f.designation, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                      Text(f.department, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    f.subjects.isNotEmpty ? f.subjects.join(', ') : 'None assigned',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                DataCell(AppBadge.status(f.status)),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.secondary),
                                        tooltip: 'Edit Faculty',
                                        onPressed: () async {
                                          final updated = await FacultyFormDialog.show(context, faculty: f);
                                          if (updated != null && context.mounted) {
                                            await facultyProvider.updateFaculty(updated);
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                        tooltip: 'Delete Faculty',
                                        onPressed: () async {
                                          final confirmed = await ConfirmDialog.show(
                                            context,
                                            title: 'Delete Faculty Member',
                                            message: 'Are you sure you want to remove ${f.fullName}? This action cannot be undone.',
                                          );
                                          if (confirmed == true && context.mounted) {
                                            await facultyProvider.deleteFaculty(f.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Faculty member ${f.fullName} removed'),
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
