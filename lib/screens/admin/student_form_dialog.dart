import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/student_model.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StudentFormDialog extends StatefulWidget {
  final StudentModel? student;

  const StudentFormDialog({super.key, this.student});

  static Future<StudentModel?> show(BuildContext context, {StudentModel? student}) {
    return showDialog<StudentModel>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StudentFormDialog(student: student),
    );
  }

  @override
  State<StudentFormDialog> createState() => _StudentFormDialogState();
}

class _StudentFormDialogState extends State<StudentFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _studentIdCtrl;
  late TextEditingController _fullNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _admissionDateCtrl;
  late TextEditingController _parentNameCtrl;
  late TextEditingController _parentContactCtrl;

  String _gender = 'Male';
  String _department = '';
  String _course = '';
  String _year = '1st Year';
  String _semester = '1';
  String _section = 'A';
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    final s = widget.student;

    _studentIdCtrl = TextEditingController(text: s?.studentId ?? 'STU-${DateTime.now().year}-${DateTime.now().millisecond}');
    _fullNameCtrl = TextEditingController(text: s?.fullName ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone ?? '');
    _dobCtrl = TextEditingController(text: s?.dob ?? '2004-01-15');
    _addressCtrl = TextEditingController(text: s?.address ?? '');
    _admissionDateCtrl = TextEditingController(text: s?.admissionDate ?? '2024-08-15');
    _parentNameCtrl = TextEditingController(text: s?.parentName ?? '');
    _parentContactCtrl = TextEditingController(text: s?.parentContact ?? '');

    _gender = s?.gender ?? 'Male';
    _year = s?.year ?? '1st Year';
    _semester = s?.semester ?? '1';
    _section = s?.section ?? 'A';
    _status = s?.status ?? 'Active';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    if (_department.isEmpty && academic.departments.isNotEmpty) {
      _department = widget.student?.department ?? academic.departments.first.departmentName;
    }
    if (_course.isEmpty && academic.courses.isNotEmpty) {
      _course = widget.student?.course ?? academic.courses.first.courseName;
    }
  }

  @override
  void dispose() {
    _studentIdCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _addressCtrl.dispose();
    _admissionDateCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentContactCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final created = StudentModel(
      id: widget.student?.id ?? '',
      studentId: _studentIdCtrl.text.trim(),
      fullName: _fullNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      gender: _gender,
      department: _department,
      course: _course,
      year: _year,
      semester: _semester,
      section: _section,
      address: _addressCtrl.text.trim(),
      admissionDate: _admissionDateCtrl.text.trim(),
      parentName: _parentNameCtrl.text.trim(),
      parentContact: _parentContactCtrl.text.trim(),
      status: _status,
      profileImage: widget.student?.profileImage ?? '',
    );

    Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();
    final isEditing = widget.student != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 850),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      isEditing ? 'Edit Student Details' : 'Register New Student',
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

                // Form Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '1. Personal & Contact Information',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _studentIdCtrl,
                                label: 'Student ID *',
                                hintText: 'STU-2024-001',
                                validator: Validators.required,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _fullNameCtrl,
                                label: 'Full Name *',
                                hintText: 'Jane Doe',
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
                                hintText: 'student@portal.edu',
                                validator: Validators.email,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _phoneCtrl,
                                label: 'Phone Number *',
                                hintText: '+1 555-019-2831',
                                validator: Validators.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _dobCtrl,
                                label: 'Date of Birth (YYYY-MM-DD)',
                                hintText: '2004-05-14',
                                validator: Validators.required,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _gender,
                                    items: ['Male', 'Female', 'Other'].map((g) {
                                      return DropdownMenuItem(value: g, child: Text(g));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomTextField(
                          controller: _addressCtrl,
                          label: 'Residential Address',
                          hintText: 'Street, City, Postal Code',
                          maxLines: 2,
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          '2. Academic Placement',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Course *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: academic.courses.any((c) => c.courseName == _course)
                                        ? _course
                                        : (academic.courses.isNotEmpty ? academic.courses.first.courseName : null),
                                    items: academic.courses.map((c) {
                                      return DropdownMenuItem(value: c.courseName, child: Text(c.courseName));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _course = v ?? ''),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
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
                                  const Text('Year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _year,
                                    items: ['1st Year', '2nd Year', '3rd Year', '4th Year'].map((y) {
                                      return DropdownMenuItem(value: y, child: Text(y));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _year = v ?? '1st Year'),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Semester', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _semester,
                                    items: ['1', '2', '3', '4', '5', '6', '7', '8'].map((sm) {
                                      return DropdownMenuItem(value: sm, child: Text('Sem $sm'));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _semester = v ?? '1'),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Section', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _section,
                                    items: ['A', 'B', 'C'].map((sc) {
                                      return DropdownMenuItem(value: sc, child: Text('Section $sc'));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _section = v ?? 'A'),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _admissionDateCtrl,
                                label: 'Admission Date',
                                hintText: '2024-08-15',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Enrollment Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: _status,
                                    items: ['Active', 'Inactive', 'Graduated'].map((st) {
                                      return DropdownMenuItem(value: st, child: Text(st));
                                    }).toList(),
                                    onChanged: (v) => setState(() => _status = v ?? 'Active'),
                                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          '3. Parent / Guardian Details',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _parentNameCtrl,
                                label: 'Parent / Guardian Name',
                                hintText: 'Parent Name',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _parentContactCtrl,
                                label: 'Parent Contact Number',
                                hintText: '+1 555-019-9999',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: isEditing ? 'Update Student' : 'Save & Enroll Student',
                      icon: Icons.check_circle_outline,
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
