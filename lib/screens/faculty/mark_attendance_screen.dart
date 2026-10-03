import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/attendance_model.dart';
import '../../models/student_model.dart';
import '../../providers/academic_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key});

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  String? _selectedSubjectId;
  String _selectedDate = DateTime.now().toIso8601String().split('T').first;
  String _selectedSection = 'A';

  final Map<String, String> _attendanceMap = {}; // studentId -> 'present' | 'absent'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final academic = Provider.of<AcademicProvider>(context, listen: false);
      if (academic.subjects.isNotEmpty) {
        setState(() {
          _selectedSubjectId = academic.subjects.first.id;
        });
      }
    });
  }

  void _markAll(String status, List<StudentModel> students) {
    setState(() {
      for (final s in students) {
        _attendanceMap[s.id] = status;
      }
    });
  }

  Future<void> _submitAttendance(List<StudentModel> students) async {
    if (_selectedSubjectId == null) return;
    final academic = Provider.of<AcademicProvider>(context, listen: false);
    final attProvider = Provider.of<AttendanceProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final sub = academic.subjects.firstWhere((s) => s.id == _selectedSubjectId);

    final List<AttendanceModel> records = [];
    for (final st in students) {
      final status = _attendanceMap[st.id] ?? 'present';
      records.add(AttendanceModel(
        id: '',
        studentId: st.id,
        studentRoll: st.studentId,
        studentName: st.fullName,
        subjectId: sub.id,
        subjectName: sub.subjectName,
        facultyId: auth.user?.uid ?? 'fac_2',
        date: _selectedDate,
        status: status,
      ));
    }

    await attProvider.submitAttendance(records);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Attendance recorded for ${records.length} students on $_selectedDate!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final academic = context.watch<AcademicProvider>();
    final studentProvider = context.watch<StudentProvider>();
    final attendance = context.watch<AttendanceProvider>();

    final students = studentProvider.allStudents.where((s) => s.section == _selectedSection).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Controls Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Subject Dropdown
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Subject *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSubjectId,
                          items: academic.subjects.map((s) {
                            return DropdownMenuItem(
                              value: s.id,
                              child: Text('${s.subjectName} (${s.subjectCode})'),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedSubjectId = v),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Date Picker
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lecture Date *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.tryParse(_selectedDate) ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked.toIso8601String().split('T').first;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined, size: 18, color: AppColors.textMuted),
                                const SizedBox(width: 8),
                                Text(_selectedDate, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Section Dropdown
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Section', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSection,
                          items: ['A', 'B', 'C'].map((sec) => DropdownMenuItem(value: sec, child: Text('Section $sec'))).toList(),
                          onChanged: (v) => setState(() => _selectedSection = v ?? 'A'),
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Students Attendance Table
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Class Roll Call (${students.length} Students)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        OutlinedButton.icon(
                          onPressed: () => _markAll('present', students),
                          icon: const Icon(Icons.check, size: 16, color: AppColors.success),
                          label: const Text('Mark All Present'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () => _markAll('absent', students),
                          icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                          label: const Text('Mark All Absent'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: students.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final st = students[idx];
                          final currentStatus = _attendanceMap[st.id] ?? 'present';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppColors.primaryLight.withOpacity(0.15),
                                  child: Text(
                                    st.fullName[0].toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(st.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                      Text('${st.studentId} • Section ${st.section}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment(value: 'present', label: Text('Present'), icon: Icon(Icons.check, size: 14)),
                                    ButtonSegment(value: 'absent', label: Text('Absent'), icon: Icon(Icons.close, size: 14)),
                                  ],
                                  selected: {currentStatus},
                                  onSelectionChanged: (set) {
                                    setState(() {
                                      _attendanceMap[st.id] = set.first;
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return currentStatus == 'present' ? AppColors.success : AppColors.error;
                                      }
                                      return null;
                                    }),
                                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                                      if (states.contains(WidgetState.selected)) {
                                        return Colors.white;
                                      }
                                      return null;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomButton(
                        text: 'Submit Attendance to Cloud',
                        icon: Icons.cloud_upload_rounded,
                        isLoading: attendance.isLoading,
                        onPressed: () => _submitAttendance(students),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
