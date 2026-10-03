import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isEditing = false;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final user = auth.user;
    final st = studentProvider.allStudents.firstWhere(
      (s) => s.id == (user?.studentId ?? '') || s.email.toLowerCase() == (user?.email.toLowerCase() ?? ''),
      orElse: () => studentProvider.allStudents.first,
    );

    _phoneCtrl = TextEditingController(text: st.phone);
    _addressCtrl = TextEditingController(text: st.address);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final user = auth.user;

    final student = studentProvider.allStudents.firstWhere(
      (s) => s.id == (user?.studentId ?? '') || s.email.toLowerCase() == (user?.email.toLowerCase() ?? ''),
      orElse: () => studentProvider.allStudents.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
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
                            Text(student.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            AppBadge.status(student.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${student.studentId} • ${student.course}',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${student.department} • Year: ${student.year} (Semester ${student.semester}, Section ${student.section})',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                    icon: Icon(_isEditing ? Icons.close : Icons.edit_outlined, size: 16),
                    label: Text(_isEditing ? 'Cancel Edit' : 'Edit Contact Info'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Details / Editable Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal & Academic Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Registered Email Address', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          subtitle: Text(student.email, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Date of Birth', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          subtitle: Text(student.dob, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Date of Admission', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          subtitle: Text(student.admissionDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (!_isEditing) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Contact Phone Number', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            subtitle: Text(student.phone, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Current Residential Address', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            subtitle: Text(student.address, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _phoneCtrl,
                            label: 'Contact Phone Number',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: CustomTextField(
                            controller: _addressCtrl,
                            label: 'Residential Address',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        text: 'Save Personal Information',
                        icon: Icons.check,
                        onPressed: () async {
                          final updated = student.copyWith(
                            phone: _phoneCtrl.text.trim(),
                            address: _addressCtrl.text.trim(),
                          );
                          await studentProvider.updateStudent(updated);
                          setState(() => _isEditing = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Personal profile information updated successfully!'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Parent / Guardian Name', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          subtitle: Text(student.parentName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Parent Contact Number', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          subtitle: Text(student.parentContact, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
    );
  }
}
