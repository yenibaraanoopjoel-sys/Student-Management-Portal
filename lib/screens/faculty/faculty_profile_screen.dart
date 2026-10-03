import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/faculty_provider.dart';
import '../../widgets/app_badge.dart';

class FacultyProfileScreen extends StatelessWidget {
  const FacultyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final facultyProvider = context.watch<FacultyProvider>();
    final user = auth.user;

    final fac = facultyProvider.allFaculty.firstWhere(
      (f) => f.id == (user?.facultyId ?? '') || f.email.toLowerCase() == (user?.email.toLowerCase() ?? ''),
      orElse: () => facultyProvider.allFaculty.isNotEmpty ? facultyProvider.allFaculty[1] : facultyProvider.allFaculty.first,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.secondary.withOpacity(0.15),
                    child: Text(
                      fac.fullName.isNotEmpty ? fac.fullName[0].toUpperCase() : 'F',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(fac.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            AppBadge.status(fac.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${fac.designation} • ${fac.department}',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.email_outlined, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(fac.email, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 16),
                            const Icon(Icons.phone_outlined, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(fac.phone, style: const TextStyle(fontSize: 13)),
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

          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Faculty Academic Portfolio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Faculty Identification ID', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    subtitle: Text(fac.facultyId, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date of Joining', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    subtitle: Text(fac.joiningDate, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Department', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                    subtitle: Text(fac.department, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text('Active Teaching Subjects:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: fac.subjects.map((sub) {
                      return Chip(
                        label: Text(sub, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        backgroundColor: AppColors.secondary.withOpacity(0.08),
                        side: const BorderSide(color: AppColors.border),
                      );
                    }).toList(),
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
