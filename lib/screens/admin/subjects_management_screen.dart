import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/subject_model.dart';
import '../../providers/academic_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_text_field.dart';

class SubjectsManagementScreen extends StatelessWidget {
  const SubjectsManagementScreen({super.key});

  void _showSubjectDialog(BuildContext context, [SubjectModel? sub]) {
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final facultyProvider = Provider.of<FacultyProvider>(context, listen: false);

    final nameCtrl = TextEditingController(text: sub?.subjectName ?? '');
    final codeCtrl = TextEditingController(text: sub?.subjectCode ?? '');
    final semCtrl = TextEditingController(text: sub?.semester ?? '3');
    final creditsCtrl = TextEditingController(text: sub?.credits.toString() ?? '4');
    final descCtrl = TextEditingController(text: sub?.description ?? '');

    String selectedDept = sub?.department ?? (academic.departments.isNotEmpty ? academic.departments.first.departmentName : '');
    String selectedCourse = sub?.course ?? (academic.courses.isNotEmpty ? academic.courses.first.courseName : '');
    String selectedFacultyId = sub?.facultyId ?? (facultyProvider.allFaculty.isNotEmpty ? facultyProvider.allFaculty.first.id : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(sub != null ? 'Edit Subject' : 'Add New Subject'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: nameCtrl,
                      label: 'Subject Name *',
                      hintText: 'Data Structures & Algorithms',
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: codeCtrl,
                            label: 'Subject Code *',
                            hintText: 'CS301',
                            validator: (v) => v?.isEmpty == true ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: creditsCtrl,
                            label: 'Credits *',
                            hintText: '4',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomTextField(
                            controller: semCtrl,
                            label: 'Semester *',
                            hintText: '3',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Course *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedCourse.isNotEmpty ? selectedCourse : null,
                          items: academic.courses.map((c) => DropdownMenuItem(value: c.courseName, child: Text(c.courseName))).toList(),
                          onChanged: (v) => setDialogState(() => selectedCourse = v ?? ''),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assigned Faculty *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedFacultyId.isNotEmpty ? selectedFacultyId : null,
                          items: facultyProvider.allFaculty.map((f) => DropdownMenuItem(value: f.id, child: Text('${f.fullName} (${f.designation})'))).toList(),
                          onChanged: (v) => setDialogState(() => selectedFacultyId = v ?? ''),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: descCtrl,
                      label: 'Description',
                      hintText: 'Syllabus and scope',
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
                  final fac = facultyProvider.getFacultyById(selectedFacultyId);
                  final model = SubjectModel(
                    id: sub?.id ?? '',
                    subjectName: nameCtrl.text.trim(),
                    subjectCode: codeCtrl.text.trim(),
                    course: selectedCourse,
                    department: selectedDept,
                    semester: semCtrl.text.trim(),
                    credits: int.tryParse(creditsCtrl.text.trim()) ?? 3,
                    facultyId: selectedFacultyId,
                    facultyName: fac?.fullName ?? 'Unassigned',
                    description: descCtrl.text.trim(),
                  );

                  if (sub != null) {
                    await academic.updateSubject(model);
                  } else {
                    await academic.addSubject(model);
                  }
                  if (context.mounted) Navigator.of(ctx).pop();
                },
                child: Text(sub != null ? 'Update' : 'Create'),
              ),
            ],
          );
        },
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subjects & Course Catalog (${academic.subjects.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showSubjectDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Subject'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
                    columns: const [
                      DataColumn(label: Text('Subject', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Course / Dept', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Sem / Credits', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Assigned Faculty', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: academic.subjects.map((sub) {
                      return DataRow(
                        cells: [
                          DataCell(Text(sub.subjectName, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(sub.subjectCode, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                          DataCell(Text('${sub.course}\n${sub.department}', style: const TextStyle(fontSize: 12))),
                          DataCell(Text('Sem ${sub.semester} • ${sub.credits} Credits')),
                          DataCell(Text(sub.facultyName, style: const TextStyle(fontWeight: FontWeight.w500))),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                  onPressed: () => _showSubjectDialog(context, sub),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  onPressed: () async {
                                    final ok = await ConfirmDialog.show(
                                      context,
                                      title: 'Delete Subject',
                                      message: 'Are you sure you want to delete subject ${sub.subjectName}?',
                                    );
                                    if (ok == true && context.mounted) {
                                      await academic.deleteSubject(sub.id);
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
