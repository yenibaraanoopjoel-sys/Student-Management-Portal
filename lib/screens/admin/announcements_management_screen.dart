import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/announcement_model.dart';
import '../../providers/academic_provider.dart';
import '../../widgets/app_badge.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_text_field.dart';

class AnnouncementsManagementScreen extends StatelessWidget {
  const AnnouncementsManagementScreen({super.key});

  void _showAddAnnouncementDialog(BuildContext context) {
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String priority = 'Medium';
    String targetAudience = 'Everyone';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Publish New Announcement'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      controller: titleCtrl,
                      label: 'Announcement Title *',
                      hintText: 'e.g. Mid-Term Examination Dates',
                      validator: (v) => v?.isEmpty == true ? 'Title is required' : null,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: descCtrl,
                      label: 'Announcement Details *',
                      hintText: 'Full content of the notice...',
                      maxLines: 4,
                      validator: (v) => v?.isEmpty == true ? 'Content is required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: priority,
                                items: ['Low', 'Medium', 'High', 'Urgent'].map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                                onChanged: (v) => setDialogState(() => priority = v ?? 'Medium'),
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
                              const Text('Target Audience', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: targetAudience,
                                items: ['Everyone', 'Students', 'Faculty', 'Department'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                                onChanged: (v) => setDialogState(() => targetAudience = v ?? 'Everyone'),
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
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final ann = AnnouncementModel(
                    id: '',
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    createdBy: 'admin_1',
                    createdByName: 'Dean Academic Affairs',
                    date: DateTime.now().toIso8601String().split('T').first,
                    priority: priority,
                    targetAudience: targetAudience,
                  );

                  await academic.addAnnouncement(ann);
                  if (context.mounted) Navigator.of(ctx).pop();
                },
                child: const Text('Publish Notice'),
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
                'Notice Board & Announcements (${academic.announcements.length})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddAnnouncementDialog(context),
                icon: const Icon(Icons.add_alert_rounded, size: 18),
                label: const Text('Create Announcement'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: academic.announcements.length,
              itemBuilder: (context, idx) {
                final a = academic.announcements[idx];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppBadge.priority(a.priority),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Audience: ${a.targetAudience}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                              ),
                            ),
                            const Spacer(),
                            Text(a.date, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                              onPressed: () async {
                                final ok = await ConfirmDialog.show(
                                  context,
                                  title: 'Delete Announcement',
                                  message: 'Are you sure you want to remove "${a.title}"?',
                                );
                                if (ok == true && context.mounted) {
                                  await academic.deleteAnnouncement(a.id);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(a.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(a.description, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.account_circle_outlined, size: 16, color: AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(
                              'Published by ${a.createdByName}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
