import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/faculty_model.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class FacultyFormDialog extends StatefulWidget {
  final FacultyModel? faculty;

  const FacultyFormDialog({super.key, this.faculty});

  static Future<FacultyModel?> show(BuildContext context, {FacultyModel? faculty}) {
    return showDialog<FacultyModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FacultyFormDialog(faculty: faculty),
    );
  }

  @override
  State<FacultyFormDialog> createState() => _FacultyFormDialogState();
}

class _FacultyFormDialogState extends State<FacultyFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _facultyIdCtrl;
  late TextEditingController _fullNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _designationCtrl;
  late TextEditingController _joiningDateCtrl;
  late TextEditingController _subjectsCtrl;

  String _department = '';
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    final f = widget.faculty;

    _facultyIdCtrl = TextEditingController(text: f?.facultyId ?? 'FAC-${DateTime.now().year}-${DateTime.now().millisecond}');
    _fullNameCtrl = TextEditingController(text: f?.fullName ?? '');
    _emailCtrl = TextEditingController(text: f?.email ?? '');
    _phoneCtrl = TextEditingController(text: f?.phone ?? '');
    _designationCtrl = TextEditingController(text: f?.designation ?? 'Assistant Professor');
    _joiningDateCtrl = TextEditingController(text: f?.joiningDate ?? '2022-01-10');
    _subjectsCtrl = TextEditingController(text: f?.subjects.join(', ') ?? '');
    _status = f?.status ?? 'Active';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    if (_department.isEmpty && academic.departments.isNotEmpty) {
      _department = widget.faculty?.department ?? academic.departments.first.departmentName;
    }
  }

  @override
  void dispose() {
    _facultyIdCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _designationCtrl.dispose();
    _joiningDateCtrl.dispose();
    _subjectsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final subjectsList = _subjectsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final created = FacultyModel(
      id: widget.faculty?.id ?? '',
      facultyId: _facultyIdCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      department: _department,
      designation: _designationCtrl.text.trim(),
      subjects: subjectsList,
      joiningDate: _joiningDateCtrl.text.trim(),
      status: _status,
      profileImage: widget.faculty?.profileImage ?? '',
    );

    Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();
    final isEditing = widget.faculty != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.badge_rounded, color: AppColors.secondary),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      isEditing ? 'Edit Faculty Details' : 'Add Faculty Member',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _facultyIdCtrl,
                                label: 'Faculty ID *',
                                hintText: 'FAC-2024-001',
                                validator: Validators.required,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _fullNameCtrl,
                                label: 'Full Name *',
                                hintText: 'Dr. Margaret Hamilton',
                                validator: Validators.required,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _emailCtrl,
                                label: 'Email Address *',
                                hintText: 'faculty@portal.edu',
                                validator: Validators.email,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _phoneCtrl,
                                label: 'Phone Number *',
                                hintText: '+1 987-654-3210',
                                validator: Validators.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Department *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: academic.departments.any((d) => d.departmentName == _department)
                                        ? _department
                                        : (academic.departments.isNotEmpty ? academic.departments.first.departmentName : null),
                                    items: academic.departments.map((d) {
                                      return DropdownMenuItem(value: d.departmentName, child: Text(d.departmentName));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _department = v ?? ''),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _designationCtrl,
                                label: 'Designation *',
                                hintText: 'Professor / Lecturer',
                                validator: Validators.required,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _subjectsCtrl,
                          label: 'Assigned Subjects (comma separated)',
                          hintText: 'Data Structures, Cloud Computing',
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _joiningDateCtrl,
                                label: 'Joining Date',
                                hintText: '2022-01-10',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _status,
                                    items: ['Active', 'Inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                    onChanged: (v) => setState(() => _status = v ?? 'Active'),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: isEditing ? 'Update Faculty' : 'Save Faculty',
                      icon: Icons.check_circle_outline,
                      backgroundColor: AppColors.secondary,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
