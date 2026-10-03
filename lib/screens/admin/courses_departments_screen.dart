import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/department_model.dart';
import '../../models/course_model.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CoursesDepartmentsScreen extends StatefulWidget {
  const CoursesDepartmentsScreen({super.key});

  @override
  State<CoursesDepartmentsScreen> createState() => _CoursesDepartmentsScreenState();
}

class _CoursesDepartmentsScreenState extends State<CoursesDepartmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showDepartmentDialog([DepartmentModel? dept]) {
    final nameCtrl = TextEditingController(text: dept?.departmentName ?? '');
    final codeCtrl = TextEditingController(text: dept?.departmentCode ?? '');
    final hodCtrl = TextEditingController(text: dept?.headOfDepartment ?? '');
    final descCtrl = TextEditingController(text: dept?.description ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(dept != null ? 'Edit Department' : 'Add Department'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: nameCtrl,
                label: 'Department Name *',
                hintText: 'Computer Science & Engineering',
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: codeCtrl,
                label: 'Department Code *',
                hintText: 'CSE',
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: hodCtrl,
                label: 'Head of Department (HOD) *',
                hintText: 'Dr. Alan Turing',
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: descCtrl,
                label: 'Description',
                hintText: 'Department overview',
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final academic = Provider.of<AcademicProvider>(context, listen: false);
              final model = DepartmentModel(
                id: dept?.id ?? '',
                departmentName: nameCtrl.text.trim(),
                departmentCode: codeCtrl.text.trim(),
                headOfDepartment: hodCtrl.text.trim(),
                description: descCtrl.text.trim(),
              );

              if (dept != null) {
                await academic.updateDepartment(model);
              } else {
                await academic.addDepartment(model);
              }
              if (mounted) Navigator.of(ctx).pop();
            },
            child: Text(dept != null ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showCourseDialog([CourseModel? course]) {
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final nameCtrl = TextEditingController(text: course?.courseName ?? '');
    final codeCtrl = TextEditingController(text: course?.courseCode ?? '');
    final durCtrl = TextEditingController(text: course?.duration ?? '4 Years');
    final descCtrl = TextEditingController(text: course?.description ?? '');
    String selectedDept = course?.department ?? (academic.departments.isNotEmpty ? academic.departments.first.departmentName : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(course != null ? 'Edit Course' : 'Create New Course'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Course Name *',
                    hintText: 'B.Tech Software Product Engineering',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: codeCtrl,
                    label: 'Course Code *',
                    hintText: 'SPE',
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Department *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedDept.isNotEmpty ? selectedDept : null,
                        items: academic.departments.map((d) => DropdownMenuItem(value: d.departmentName, child: Text(d.departmentName))).toList(),
                        onChanged: (v) => setDialogState(() => selectedDept = v ?? ''),
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: durCtrl,
                    label: 'Duration *',
                    hintText: '4 Years / 8 Semesters',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descCtrl,
                    label: 'Description',
                    hintText: 'Curriculum overview',
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final model = CourseModel(
                  id: course?.id ?? '',
                  courseName: nameCtrl.text.trim(),
                  courseCode: codeCtrl.text.trim(),
                  department: selectedDept,
                  duration: durCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  status: course?.status ?? 'Active',
                );

                if (course != null) {
                  await academic.updateCourse(model);
                } else {
                  await academic.addCourse(model);
                }
                if (mounted) Navigator.of(ctx).pop();
              },
              child: Text(course != null ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Academic Courses (${academic.courses.length})'),
                    Tab(text: 'Departments (${academic.departments.length})'),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (_tabController.index == 0) {
                    _showCourseDialog();
                  } else {
                    _showDepartmentDialog();
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(_tabController.index == 0 ? 'Add Course' : 'Add Department'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Courses Tab
                Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                        columns: const [
                          DataColumn(label: Text('Course Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: academic.courses.map((c) {
                          return DataRow(
                            cells: [
                              DataCell(Text(c.courseName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(c.courseCode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                              DataCell(Text(c.department)),
                              DataCell(Text(c.duration)),
                              DataCell(AppBadge.status(c.status)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                      onPressed: () => _showCourseDialog(c),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      onPressed: () async {
                                        final ok = await ConfirmDialog.show(
                                          context,
                                          title: 'Delete Course',
                                          message: 'Are you sure you want to delete course ${c.courseName}?',
                                        );
                                        if (ok == true && context.mounted) {
                                          await academic.deleteCourse(c.id);
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

                // Departments Tab
                Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 24,
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                        columns: const [
                          DataColumn(label: Text('Department Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Head of Department (HOD)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Description', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: academic.departments.map((d) {
                          return DataRow(
                            cells: [
                              DataCell(Text(d.departmentName, style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(d.departmentCode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary))),
                              DataCell(Text(d.headOfDepartment)),
                              DataCell(Text(d.description, maxLines: 1, overflow: TextOverflow.ellipsis)),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                      onPressed: () => _showDepartmentDialog(d),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                      onPressed: () async {
                                        final ok = await ConfirmDialog.show(
                                          context,
                                          title: 'Delete Department',
                                          message: 'Are you sure you want to delete department ${d.departmentName}?',
                                        );
                                        if (ok == true && context.mounted) {
                                          await academic.deleteDepartment(d.id);
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
